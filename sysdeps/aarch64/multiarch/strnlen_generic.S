/* A Generic Optimized strnlen implementation for AARCH64.
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

/* The actual strnlen code is in ../strnlen.S.  If we are building libc this
   file defines __strnlen_generic.  Otherwise the include of ../strnlen.S
   will define the normal __strnlen entry point.  */

#include <sysdep.h>

#if IS_IN (libc)
# undef libc_hidden_def
# define libc_hidden_def(name)
# undef weak_alias
# define weak_alias(name1, name2)

# define __strnlen __strnlen_generic
#endif

#include "../strnlen.S"
