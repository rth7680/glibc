/* Optimized memchr for SVE.
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
	.hidden   __memchr_sve

ENTRY_ALIGN (__memchr_sve, 6)

	setffr					/* initialize FFR */
	dup	z1.b, w1			/* duplicate c to a vector */
	mov	x3, 0				/* initialize off */
	DELOUSE(0)
	DELOUSE(2)

	.align	4
0:	whilelo	p1.b, x3, x2			/* make sure off < max */
	b.none	9f

	/* Read a vector's worth of bytes, bounded by max,
	   stopping on first fault.  */
	ldff1b	z0.b, p1/z, [x0, x3]
	rdffrs	p0.b, p1/z
	b.nlast	2f

	/* First fault did not fail: the vector bounded by max is valid.
	   Avoid depending on the contents of FFR beyond the branch.  */
	incb	x3				/* speculate increment */
	cmpeq	p2.b, p1/z, z0.b, z1.b		/* search for c */
	b.none	0b
	decb	x3				/* undo speculate */

	/* Found C.  */
1:	brkb	p2.b, p1/z, p2.b	/* find the first c */
	add	x0, x0, x3		/* form partial pointer */
	incp	x0, p2.b		/* form final pointer to c */
	ret

	/* First fault failed: only some of the vector is valid.
	   Perform the comparision only on the valid bytes.  */
2:	cmpeq	p2.b, p0/z, z0.b, z1.b
	b.any	1b

	/* No C found.  Re-init FFR, increment, and loop.  */
	setffr
	incp	x3, p0.b
	b	0b

	/* Found end of count.  */
9:	mov	x0, 0			/* return null */
	ret

END (__memchr_sve)
#endif
