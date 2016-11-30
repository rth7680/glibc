;! HP-PA  strrchr
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		strrchr
	.balign		16
strrchr:
	.proc
	.callinfo	frame=0,no_calls
	.entry

	;! Compute the number of bytes required to align the pointer.
	;! Multiply by 3, giving us 6 insns per entry to work with.
	ldo		-1(%r26), %r20
	extrw,u		%r25, 31, 8, %r25
	extrw,u		%r20, 31, 2, %r20
	shladd,l	%r20, 1, %r20, %r20
	blr		%r20, %r0
	 ;! Begin by assuming that C is not present.
	 ldi		0, %r28

	;! ptr % 4 == 1
	ldb		0(%r26), %r20
	cmpclr,<>	%r25, %r20, %r0
	copy		%r26, %r28
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r26), %r26

	;! ptr % 4 == 2
	ldb		0(%r26), %r20
	cmpclr,<>	%r25, %r20, %r0
	copy		%r26, %r28
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r26), %r26

	;! ptr % 4 == 3
	ldb		0(%r26), %r20
	cmpclr,<>	%r25, %r20, %r0
	copy		%r26, %r28
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r26), %r26

	;! ptr % 4 == 0
	ldw,ma		4(%r26), %r20
	depw		%r25, 23, 8, %r25
	depw		%r25, 15, 16, %r25

	;! Main loop.
0:	;; Test for a NUL terminator within the word and exit if found.
	uxor,nbz	%r0, %r20, %r0
	b,n		1f

	;; Test for C within the word.  If not found, loop and load the
	;; next word in the delay slot.  If found, load the next word
	;; now anyway, since we know that we havn't seen end-of-string.
	uxor,sbz	%r25, %r20, %r21
	b		0b
	 ldw,ma		4(%r26), %r20

	;; Found C within the "current" word, which is 0 within $r21,
	;; and the address for the beginning of that word is now -8(%r26),
	;; since we have incremented the pointer twice since the load.
	extrw,u,<>	%r21,  7, 8, %r0
	ldo		-8(%r26), %r28
	extrw,u,<>	%r21, 15, 8, %r0
	ldo		-7(%r26), %r28
	extrw,u,<>	%r21, 23, 8, %r0
	ldo		-6(%r26), %r28
	extrw,u,<>	%r21, 31, 8, %r0
	ldo		-5(%r26), %r28
	b,n		0b

	;! Found NUL somewhere in with word in %r20, loaded from -4(%r26).
	;! Test each byte in sequence.
1:	xor		%r25, %r20, %r21

	extrw,u,<>	%r21,  7, 8, %r0
	ldo		-4(%r26), %r28
	extrw,u,<>	%r20,  7, 8, %r0
	bv,n		0(%r2)

	extrw,u,<>	%r21, 15, 8, %r0
	ldo		-3(%r26), %r28
	extrw,u,<>	%r20, 15, 8, %r0
	bv,n		0(%r2)

	extrw,u,<>	%r21, 23, 8, %r0
	ldo		-2(%r26), %r28
	extrw,u,<>	%r20, 23, 8, %r0
	bv,n		0(%r2)

	;; Having checked the others, the last byte must be NUL.
	;; Do check for the unusual case of C == NUL.
	extrw,u,<>	%r21, 31, 8, %r0
	ldo		-1(%r26), %r28
	bv,n		0(%r2)

	.exit
	.procend

libc_hidden_builtin_def (strrchr)
weak_alias (strrchr, rindex)
