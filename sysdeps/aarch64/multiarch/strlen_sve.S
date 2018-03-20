/* Optimized strlen for SVE.
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
	.section .text.sve, "ax", @progbits
	.hidden	__strlen_sve

ENTRY_ALIGN (__strlen_sve, 4)

	setffr				/* initialize FFR */
	ptrue	p2.b			/* all ones; loop invariant */
	mov	x1, 0			/* initialize length */
	DELOUSE(0)

	.align	4
	/* Read a vector's worth of bytes, stopping on first fault.  */
0:	ldff1b	z0.b, p2/z, [x0, x1]
	rdffrs	p0.b, p2/z
	b.nlast	2f

	/* First fault did not fail: the whole vector is valid.
	   Avoid depending on the contents of FFR beyond the branch.  */
	incb	x1, all			/* speculate increment */
	cmpeq	p1.b, p2/z, z0.b, 0	/* loop if no zeros */
	b.none	0b
	decb	x1, all			/* undo speculate */

	/* Zero found.  Select the bytes before the first and count them.  */
1:	brkb	p0.b, p2/z, p1.b
	mov	x0, x1
	incp	x0, p0.b
	ret

	/* First fault failed: only some of the vector is valid.
	   Perform the comparison only on the valid bytes.  */
2:	cmpeq	p1.b, p0/z, z0.b, 0
	b.any	1b

	/* No zero found.  Re-init FFR, increment, and loop.  */
	setffr
	incp	x1, p0.b
	b	0b

END (__strlen_sve)
#endif
