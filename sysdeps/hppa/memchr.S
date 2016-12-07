;! HP-PA  memchr
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		__memchr
	.balign		16
__memchr:
	.proc
	.callinfo	frame=0,no_calls
	.entry

	;! Enter the word loop only if we're certain to loop once.
	;! This implies at least 12 bytes.
	extrw,u		%r25, 31, 8, %r25
	copy		%r26, %r28
	cmpib,>>	12, %r24, 2f
	 add,l		%r24, %r26, %r29

	;! Compute the number of bytes required to align the pointer.
	;! Multiply by 2, giving us 4 insns per entry to work with.
	ldo		-1(%r26), %r20
	depw,z		%r20, 30, 2, %r20
	blr		%r20, %r0
	 nop

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
	depw		%r25, 23, 8, %r25	;! replicate C to all bytes
	sub		%r29, %r28, %r24	;! recompute bytes after above
	depw		%r25, 15, 16, %r25
	extrw,u		%r24, 29, 30, %r24	;! compute words remaining
	nop

	;! Word loop.  Use the No Byte Zero unit condition to find
	;! a word containing C.
0:	uxor,nbz	%r25, %r20, %r21
	b,n		3f
	addib,<>,n	-1, %r24, 0b
	 ldw,ma		4(%r28), %r20

	b		2f
	 extrw,u	%r25, 31, 8, %r25

	;! Remaining bytes one at a time.
1:	cmpclr,<>	%r25, %r20, %r0
	bv,n		0(%r2)
	ldo		1(%r28), %r28
2:	cmpb,<>,n	%r28, %r29, 1b
	 ldb		0(%r28), %r20

	;! Not found.
	bv		0(%r2)
	 ldi		0, %r28
	nop

	;! Found, somewhere in with word in %r21.
	;! Test each byte in sequence.
3:	ldo		-4(%r28), %r28
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

weak_alias (__memchr, memchr)
libc_hidden_builtin_def (memchr)
