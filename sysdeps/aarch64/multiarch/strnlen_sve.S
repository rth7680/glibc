/* Optimized strnlen for SVE.
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
	.hidden   __strnlen_sve

ENTRY_ALIGN (__strnlen_sve, 6)

	setffr				/* initialize FFR */
	mov	x2, 0			/* initialize len */
	DELOUSE(0)
	DELOUSE(1)

	.align	4
0:	whilelo	p0.b, x2, x1
	b.nlast	1f

	/* We have off + vl <= max, and so may read the whole vector.  */
	ldff1b	z0.b, p0/z, [x0, x2]
	rdffrs	p1.b, p0/z
	b.nlast	2f

	/* First fault did not fail: the whole vector is valid.
	   Avoid depending on the contents of FFR beyond the branch.  */
	incb	x2			/* speculate for next round */
	cmpeq	p2.b, p0/z, z0.b, 0
	b.none	0b
	decb	x2			/* undo speculate */

	/* Found end-of-string.  */
8:	brkb	p2.b, p0/z, p2.b
	mov	x0, x2
	incp	x0, p2.b
	ret

	.align	4
	/* We have off + vl < max.  Test for off == max before proceeding.  */
1:	b.none	9f

	ldff1b	z0.b, p0/z, [x0, x2]
	rdffrs	p1.b, p0/z
	b.nlast	2f

	/* First fault did not fail: the vector up to max is valid.
	   Avoid depending on the contents of FFR beyond the branch.
	   Compare for end-of-string, but there are no more bytes.  */
	cmpeq	p2.b, p0/z, z0.b, 0
	b.any	8b

	/* End of count.  Return max.  */
9:	mov	x0, x1
	ret

	/* First fault failed: only some of the vector is valid.
	   Perform the comparison only on the valid bytes.  */
2:	cmpeq	p2.b, p1/z, z0.b, 0
	b.any	8b

	/* No zero found.  Re-init FFR, incr and loop.  */
	setffr
	incp	x2, p1.b
	b	0b

END (__strnlen_sve)
#endif
