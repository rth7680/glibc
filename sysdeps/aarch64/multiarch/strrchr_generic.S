/* A Generic Optimized strrchr implementation for AARCH64.
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

/* The actual strrchr code is in ../strrchr.S.  If we are building libc this
   file defines __strrchr_generic.  Otherwise the include of ../strrchr.S
   will define the normal strrchr entry point.  */

#include <sysdep.h>

#if IS_IN (libc)
# undef libc_hidden_builtin_def
# define libc_hidden_builtin_def(name)
# undef weak_alias
# define weak_alias(name1, name2)

# define strrchr	__strrchr_generic
# define __strlen	__strlen_generic
#endif

#include "../strrchr.S"
