/* A Generic Optimized strcpy implementation for AARCH64.
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

/* The actual strcpy code is in ../strcpy.S.  If we are building libc this
   file defines __strcpy_generic.  Otherwise the include of ../strcpy.S
   will define the normal __strcpy entry point.  */

#include <sysdep.h>

#if IS_IN (libc)

/* Do not hide the generic version strcpy, we use them internally.  */
# undef libc_hidden_builtin_def
# define libc_hidden_builtin_def(name)
# undef weak_alias
# define weak_alias(name1, name2)

# define strcpy __strcpy_generic

#endif

#include "../strcpy.S"

/* It doesn't make sense to send libc-internal strcpy calls through a PLT. */
	.globl __GI_strcpy; __GI_strcpy = strcpy
