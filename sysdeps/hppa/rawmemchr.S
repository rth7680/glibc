;! HP-PA  rawmemchr
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		__rawmemchr
	.balign		16
__rawmemchr:
	.proc
	.callinfo	frame=0,no_calls
	.entry

	;! Compute the number of bytes required to align the pointer.
	;! Multiply by 2, giving us 4 insns per entry to work with.
	ldo		-1(%r26), %r20
	extrw,u		%r25, 31, 8, %r25
	depw,z		%r20, 30, 2, %r20
	blr		%r20, %r0
	 copy		%r26, %r28

	;! ptr % 4 == 1
	ldb		0(%r28), %r20
	cmpclr,<>	%r25, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 2
	ldb		0(%r28), %r20
	cmpclr,<>	%r25, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 3
	ldb		0(%r28), %r20
	cmpclr,<>	%r25, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 0
	ldw,ma		4(%r28), %r20
	depw		%r25, 23, 8, %r25
	depw		%r25, 15, 16, %r25

	;! Main loop.  Use the No Byte Zero unit condition to find
	;! a word containing C.
0:	uxor,nbz	%r25, %r20, %r21
	b,n		1f
	b		0b
	 ldw,ma		4(%r28), %r20

	;! Found, somewhere in with word in %r20.
	;! Test each byte in sequence.
1:	ldo		-4(%r28), %r28
	extrw,u,<>	%r21,  7, 8, %r0
	bv,n		0(%r2)

	ldo		1(%r28), %r28
	extrw,u,<>	%r21, 15, 8, %r0
	bv,n		0(%r2)

	ldo		1(%r28), %r28
	extrw,u,<>	%r21, 23, 8, %r0
	bv,n		0(%r2)

	bv		0(%r2)
	 ldo		1(%r28), %r28

	.exit
	.procend

libc_hidden_def (__rawmemchr)
weak_alias (__rawmemchr, rawmemchr)
