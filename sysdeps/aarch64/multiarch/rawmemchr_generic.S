/* A Generic Optimized rawmemchr implementation for AARCH64.
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
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

/* The actual rawmemchr code is in ../rawmemchr.S.  If we are building libc this
   file defines __rawmemchr_generic.  Otherwise the include of ../rawmemchr.S
   will define the normal __rawmemchr entry point.  */

#include <sysdep.h>

#if IS_IN (libc)
/* Do not hide the generic version rawmemchr, we use them internally.  */
# undef libc_hidden_builtin_def
# define libc_hidden_builtin_def(name)
# undef weak_alias
# define weak_alias(name1, name2)

# define __rawmemchr __rawmemchr_generic
#endif

#include "../rawmemchr.S"

/* It doesn't make sense to send libc-internal rawmemchr calls through a PLT. */
	.globl __GI___rawmemchr; __GI___rawmemchr = __rawmemchr
