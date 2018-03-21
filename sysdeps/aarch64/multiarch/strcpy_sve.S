/* Optimized strcpy for SVE.
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

/* To build as stpcpy, define BUILD_STPCPY before compiling this file.  */
#ifdef BUILD_STPCPY
# define FUNC  __stpcpy_sve
#else
# define FUNC  __strcpy_sve
#endif

	.arch	armv8-a+sve
	.section  .text.sve, "ax", @progbits
	.hidden	FUNC

ENTRY_ALIGN (FUNC, 6)

	setffr				/* initialize FFR */
	ptrue	p2.b, all		/* all ones; loop invariant */
	mov	x2, 0			/* initialize offset */
	DELOUSE(0)
	DELOUSE(1)

	.align	4
	/* Read a vector's worth of bytes, stopping on first fault.  */
0:	ldff1b	z0.b, p2/z, [x1, x2]
	rdffrs	p0.b, p2/z
	b.nlast	1f

	/* First fault did not fail: the whole vector is valid.
	   Avoid depending on the contexts of FFR beyond the branch.  */
	cmpeq	p1.b, p2/z, z0.b, 0	/* search for zeros */
	b.any	2f

	/* No zero found.  Store the whole vector and loop.  */
	st1b	z0.b, p2, [x0, x2]
	incb	x2, all
	b	0b

	/* First fault failed: only some of the vector is valid.
	   Perform the comparison only on the valid bytes.  */
1:	cmpeq	p1.b, p0/z, z0.b, 0	/* search for zeros */
	b.any	2f

	/* No zero found.  Store the valid portion of the vector and loop.  */
	setffr				/* re-init FFR */
	st1b	z0.b, p0, [x0, x2]
	incp	x2, p0.b
	b	0b

	.align	4
	/* Zero found.  Crop the vector to the found zero and finish.  */
2:	brka	p0.b, p2/z, p1.b
	st1b	z0.b, p0, [x0, x2]
#ifdef BUILD_STPCPY
	add	x0, x0, x2
	sub	x0, x0, 1
	incp	x0, p0.b
#endif
	ret

END (FUNC)
#endif
