/* Optimized strncmp for SVE.
   Copyright (C) 2018 Free Software Foundation, Inc.

   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>

#if IS_IN (libc)

	.arch	armv8-a+sve
	.section  .text.sve, "ax", @progbits
	.hidden   __strncmp_sve

ENTRY_ALIGN (__strncmp_sve, 4)

	setffr				/* initialize FFR */
	mov	x3, 0			/* initialize off */
	DELOUSE(0)
	DELOUSE(1)
	DELOUSE(2)

	.align	4
0:	whilelo	p0.b, x3, x2		/* while off < max */
	b.none	9f

	ldff1b	z0.b, p0/z, [x0, x3]
	ldff1b	z1.b, p0/z, [x1, x3]
	rdffrs	p1.b, p0/z
	b.nlast	2f

	/* First fault did not fail: the vector up to max is valid.
	   Avoid depending on the contents of FFR beyond the branch.
	   Increment for a whole vector, even if we've only read a partial.
	   This is significantly cheaper than INCP, and since OFF is not
	   used after the loop it is ok to increment OFF past MAX.  */
	incb	x3
	cmpeq	p1.b, p0/z, z0.b, z1.b	/* compare strings */
	cmpne	p2.b, p0/z, z0.b, 0	/* search for ~zero */
	nands	p2.b, p0/z, p1.b, p2.b	/* ~(eq & ~zero) -> ne | zero */
	b.none	0b

	/* Found end-of-string or inequality.  */
1:	brkb	p2.b, p0/z, p2.b	/* find first such */
	lasta	w0, p2, z0.b		/* extract each char */
	lasta	w1, p2, z1.b
	sub	x0, x0, x1		/* return comparison */
	ret

	/* First fault failed: only some of the vector is valid.
	   Perform the comparison only on the valid bytes.  */
2:	cmpeq	p2.b, p1/z, z0.b, z1.b	/* compare strings, as above */
	cmpne	p3.b, p1/z, z0.b, 0
	nands	p2.b, p1/z, p2.b, p3.b
	b.any	1b

	/* No inequality or zero found.  Re-init FFR, incr and loop.  */
	setffr
	incp	x3, p1.b
	b	0b

	/* Found end-of-count.  */
9:	mov	x0, 0			/* return equal */
	ret

END (__strncmp_sve)
#endif
