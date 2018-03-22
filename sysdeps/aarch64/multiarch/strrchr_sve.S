/* Optimized strrchr for SVE.
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
	.hidden   __strrchr_sve

ENTRY_ALIGN (__strrchr_sve, 4)

        cbz     w1, 9f

	setffr				/* initialize FFR */
	dup	z1.b, w1		/* replicate byte across vector */
	ptrue	p1.b			/* all ones; loop invariant */
	mov	x2, 0			/* no match found so far */
	pfalse	p2.b
	DELOUSE(0)

	.align 4
	/* Read a vector's worth of bytes, stopping on first fault.  */
0:	ldff1b	z0.b, p1/z, [x0, xzr]
	rdffrs	p0.b, p1/z
	b.nlast	1f

	/* First fault did not fail: the whole vector is valid.
	   Avoid depending on the contents of FFR beyond the branch.  */
	incb	x0, all			/* skip bytes this round */
	cmpeq	p3.b, p1/z, z0.b, 0	/* search for 0 */
	b.any	6f

	cmpeq	p3.b, p1/z, z0.b, z1.b	/* search for c; no eos */
	b.none	0b

	mov	x2, x0			/* save advanced base */
	mov	p2.b, p3.b		/* save current search */
	b	0b

	/* First fault failed: only some of the vector is valid.
	   Perform the comparisions only on the valid bytes.  */
1:	cmpeq	p3.b, p0/z, z0.b, 0	/* search for 0 */
	b.any	5f

	cmpeq	p3.b, p0/z, z0.b, z1.b	/* search for c; no eos */
	b.none	2f

	addvl	x2, x0, 1		/* save advanced base */
	mov	p2.b, p3.b		/* save current search */

2:	incp	x0, p0.b		/* skip bytes this round */
	setffr				/* re-init FFR */
	b	0b

	/* Found end-of-string.  */
5:	incb	x0, all			/* advance base */
6:	brka	p3.b, p1/z, p3.b	/* mask after first 0 */
	cmpeq	p3.b, p3/z, z0.b, z1.b	/* search for c not after eos */
	b.any	7f

	/* No C within last vector.  Did we have one before?  */
	cbnz	x2, 8f
	mov	x0, x2			/* restore advanced base */
	mov	p3.b, p2.b		/* restore saved search */

	/* Find the *last* match in the predicate.  This is slightly
	   more complicated than finding the first match.  */
7:	rev	p3.b, p3.b		/* reverse the bits */
	brka	p3.b, p3/z, p3.b	/* find position of last match */
	decp	x0, p3.b		/* retard pointer to last match */
	ret

	/* No C whatsoever.  Return NULL.  */
8:	mov	x0, 0
	ret

	/* C == 0 -- defer to rawmemchr.  */
9:	b	__rawmemchr_sve

END (__strrchr_sve)
#endif
