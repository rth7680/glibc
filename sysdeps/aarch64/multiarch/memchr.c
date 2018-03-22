/* Multiple versions of memchr. AARCH64 version.
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

/* Define multiple versions only for the definition in libc.  */

#if IS_IN (libc)
# define __NO_STRING_INLINES
# define NO_MEMPCPY_STPCPY_REDIRECT
# include <string.h>
# include <init-arch.h>

extern __typeof (memchr) __memchr_sve attribute_hidden;
extern __typeof (memchr) __memchr_generic attribute_hidden;

libc_ifunc_hidden (memchr, memchr, sve ? __memchr_sve : __memchr_generic);
libc_hidden_def (memchr);
#endif
