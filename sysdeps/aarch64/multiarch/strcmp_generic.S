/* A Generic Optimized strcmp implementation for AARCH64.
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

/* The actual strcmp code is in ../strcmp.S.  If we are building libc this
   file defines __strcmp_generic.  Otherwise the include of ../strcmp.S
   will define the normal __strcmp entry point.  */

#include <sysdep.h>

#if IS_IN (libc)
# undef libc_hidden_builtin_def
# define libc_hidden_builtin_def(name)

# define strcmp __strcmp_generic
#endif

#include "../strcmp.S"
