;! HP-PA  strchrnul
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		__strchrnul
	.balign		16
__strchrnul:
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
	 copy		%r26, %r28

	;! ptr % 4 == 1
	ldb		0(%r28), %r20
	nop
	cmpclr,=	%r25, %r20, %r0
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 2
	ldb		0(%r28), %r20
	nop
	cmpclr,=	%r25, %r20, %r0
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 3
	ldb		0(%r28), %r20
	nop
	cmpclr,=	%r25, %r20, %r0
	cmpclr,<>	%r0, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28

	;! ptr % 4 == 0
	ldw,ma		4(%r28), %r20
	depw		%r25, 23, 8, %r25
	depw		%r25, 15, 16, %r25

	;! Main loop.  Use the No Byte Zero unit condition to find
	;! a word containing C or 0.
0:	uxor,nbz	%r25, %r20, %r21
	b,n		1f
	uxor,nbz	%r0, %r20, %r0
	b,n		1f
	b		0b
	 ldw,ma		4(%r28), %r20

	;! Found, somewhere in with word in %r20.
	;! Test each byte in sequence.
1:	ldo		-4(%r28), %r28
	extrw,u,=	%r21,  7, 8, %r0
	extrw,u,<>	%r20,  7, 8, %r0
	bv,n		0(%r2)

	ldo		1(%r28), %r28
	extrw,u,=	%r21, 15, 8, %r0
	extrw,u,<>	%r20, 15, 8, %r0
	bv,n		0(%r2)

	ldo		1(%r28), %r28
	extrw,u,=	%r21, 23, 8, %r0
	extrw,u,<>	%r20, 23, 8, %r0
	bv,n		0(%r2)

	bv		0(%r2)
	 ldo		1(%r28), %r28

	.exit
	.procend

weak_alias (__strchrnul, strchrnul)
