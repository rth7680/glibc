;! HP-PA  strlen
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		strlen
	.balign		16
strlen:
	.proc
	.callinfo	frame=0,no_calls
	.entry

	;! Compute the number of bytes required to align the pointer.
	;! Shifting by 1 gets us 4 insns to play with per entry.
	ldo		-1(%r26), %r20
	depw,z		%r20, 30, 2, %r20
	blr		%r20, %r0
	 copy		%r26, %r28

	;! ptr % 4 == 1
	ldb		0(%r26), %r20
	cmpiclr,<>	0, %r20, %r0
	b,n		9f
	ldo		1(%r26), %r26

	;! ptr % 4 == 2
	ldb		0(%r26), %r20
	cmpiclr,<>	0, %r20, %r0
	b,n		9f
	ldo		1(%r26), %r26

	;! ptr % 4 == 3
	ldb		0(%r26), %r20
	cmpiclr,<>	0, %r20, %r0
	b,n		9f
	ldo		1(%r26), %r26

	;! ptr % 4 == 0
	;! Main loop.  Use the Some Byte Zero unit condition to find
	;; a word containing the string terminator.
0:	ldw,ma		4(%r26), %r20
	uxor,sbz	%r0, %r20, %r0
	b,n		0b

	;! Found, somewhere in with word in %r20.  Test each byte in
	;! sequence, computing the appopriate offset from %r26 into %r21.
	ldo		-1(%r26), %r21
	extrw,u,<>	%r20, 23, 8, %r0
	ldo		-2(%r26), %r21
	extrw,u,<>	%r20, 15, 8, %r0
	ldo		-3(%r26), %r21
	extrw,u,<>	%r20,  7, 8, %r0
	ldo		-4(%r26), %r21
	bv		0(%r2)
	 sub		%r21, %r28, %r28

	;! Found, with no displacement off %r26.
9:	bv		0(%r2)
	 sub		%r26, %r28, %r28

	.exit
	.procend

libc_hidden_builtin_def (strlen)
