/* Optimized strchr for SVE.
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

/* To build as strchrnul, define BUILD_STRCHRNUL before compiling this file.  */
#ifdef BUILD_STRCHRNUL
# define FUNC  __strchrnul_sve
#else
# define FUNC  __strchr_sve
#endif

	.arch	armv8-a+sve
	.section  .text.sve, "ax", @progbits
	.hidden   FUNC

ENTRY_ALIGN (FUNC, 4)

	setffr				/* initialize FFR */
	dup	z1.b, w1		/* replicate byte across vector */
	ptrue	p1.b			/* all ones; loop invariant */
	DELOUSE(0)

	.align	4
	/* Read a vector's worth of bytes, stopping on first fault.  */
0:	ldff1b	z0.b, p1/z, [x0, xzr]
	rdffrs	p0.b, p1/z
	b.nlast	2f

	/* First fault did not fail: the whole vector is valid.
	   Avoid depending on the contents of FFR beyond the branch.  */
	incb	x0				/* speculate increment */
	cmpeq	p2.b, p1/z, z0.b, z1.b		/* search for c */
	cmpeq	p3.b, p1/z, z0.b, 0		/* search for 0 */
	orrs	p4.b, p1/z, p2.b, p3.b		/* c | 0 */
	b.none	0b
	decb	x0				/* undo speculate */

	/* Found C or 0.  */
1:	brka	p4.b, p1/z, p4.b	/* find first such */
	sub	x0, x0, 1		/* adjust pointer for that byte */
	incp	x0, p4.b
#ifndef BUILD_STRCHRNUL
	ptest	p4, p2.b		/* was first in c? */
	csel	x0, xzr, x0, none	/* if there was no c, return null */
#endif
	ret

	/* First fault failed: only some of the vector is valid.
	   Perform the comparision only on the valid bytes.  */
2:	cmpeq	p2.b, p0/z, z0.b, z1.b		/* search for c */
	cmpeq	p3.b, p0/z, z0.b, 0		/* search for 0 */
	orrs	p4.b, p0/z, p2.b, p3.b		/* c | 0 */
	b.any	1b

	/* No C or 0 found.  Re-init FFR, increment, and loop.  */
	setffr
	incp	x0, p0.b
	b	0b

END (FUNC)
#endif
