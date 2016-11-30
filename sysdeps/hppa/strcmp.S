;! HP-PA  strcmp
;! Copyright (C) 2016 Free Software Foundation, Inc.

#include <sysdep.h>

	.text
	.export		strcmp
	.balign		16
strcmp:
	.proc
	.callinfo	frame=0,no_calls
	.entry

	;! Compute the number of bytes required to align the first pointer.
	;! Multiply by 4, giving us 8 insns per entry to work with.
	ldo		-1(%r26), %r20
	depw,z		%r20, 29, 2, %r20
	blr		%r20, %r0
	 nop

	;! Process the first 1-3 bytes as bytes.
	;! src1 % 4 == 1
	ldb		0(%r26), %r28
	ldb		0(%r25), %r29
	nop
	cmpclr,=	%r0, %r29, %r0
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)
	ldo		1(%r26), %r26
	ldo		1(%r25), %r25

	;! src1 % 4 == 2
	ldb		0(%r26), %r28
	ldb		0(%r25), %r29
	nop
	cmpclr,=	%r0, %r29, %r0
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)
	ldo		1(%r26), %r26
	ldo		1(%r25), %r25

	;! src1 % 4 == 3
	ldb		0(%r26), %r28
	ldb		0(%r25), %r29
	nop
	cmpclr,=	%r0, %r29, %r0
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)
	ldo		1(%r26), %r26
	ldo		1(%r25), %r25

	;! src1 % 4 == 0
	;! Now src1 is aligned.  Look to see if src2 is as well.
	ldw,ma		4(%r26), %r20		;! load 1st word of src1 asap
	depw,z,=	%r25, 28, 2, %r24	;! bit offset of src2
	b		1f
	 depi		0, 31, 2, %r25		;! align src2

	;!
	;! Aligned main loop.
	;!
0:	ldw,ma		4(%r25), %r21
	cmpclr,=	%r20, %r21, %r28	;! compare; ensure ret=0
	b,n		9f
	uxor,nbz	%r0, %r20, %r0		;! if zero found, return equal
	bv,n		0(%r2)
	b		0b
	 ldw,ma		4(%r26), %r20

	;!
	;! Unaligned entry.
	;!
1:	ldw,ma		4(%r25), %r22		;! load 1st word of src2 asap
	subi		32, %r24, %r24		;! rshift for offset
	mtsar		%r24
	ldi		-1, %r21
	shrpw		%r22, %r21, %sar, %r21	;! shift out garbage for -1
	uxor,nbz	%r0, %r21, %r0		;! ensure no zero in 1st half
	b,n		9f

	;!
	;! Unaligned main loop.
	;!
2:	ldw,ma		4(%r25), %r23
	shrpw		%r22, %r23, %sar, %r21	;! create word2
	cmpclr,=	%r20, %r21, %r28	;! compare; ensure ret=0
	b,n		9f
	uxor,nbz	%r0, %r23, %r0		;! ensure no zero in 2nd half
	b,n		3f
	ldw,ma		4(%r26), %r20
	b		2b
	 copy		%r23, %r22		;! 2nd half becomes 1st half
	nop

	;! Zero found in the second half of src2, %r23.
	;! Ensure that we didn't also have a zero in the aligned word, %r20.
	;! If so, we had equality at end-of-string.
3:	uxor,nbz	%r0, %r20, %r0
	bv,n		0(%r2)

	;! Otherwise, we must load one more word from src1 against which
	;! to compare the final bytes of src2.
	ldw		0(%r26), %r20
	shrpw		%r23, %r0, %sar, %r21	;! align for final compare

	;! Inequality found.  Co-aligned words are in %r20 and %r21.
9:	extrw,u		%r20, 7, 8, %r28
	extrw,u,=	%r21, 7, 8, %r29
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)

	extrw,u		%r20, 15, 8, %r28
	extrw,u,=	%r21, 15, 8, %r29
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)

	extrw,u		%r20, 23, 8, %r28
	extrw,u,=	%r21, 23, 8, %r29
	sub,=		%r28, %r29, %r28
	bv,n		0(%r2)

	extrw,u		%r20, 31, 8, %r28
	extrw,u		%r21, 31, 8, %r29
	bv		0(%r2)
	 sub		%r28, %r29, %r28

	.exit
	.procend

libc_hidden_builtin_def (strcmp)
