/* Multiple versions of stpcpy.  AARCH64 version.
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
# define stpcpy __redirect_stpcpy
# define __stpcpy __redirect___stpcpy
# define __NO_STRING_INLINES
# define NO_MEMPCPY_STPCPY_REDIRECT
# include <string.h>
# include <init-arch.h>
# undef stpcpy
# undef __stpcpy

extern __typeof (__redirect_stpcpy) __stpcpy_sve attribute_hidden;
extern __typeof (__redirect_stpcpy) __stpcpy_generic attribute_hidden;

libc_ifunc_redirected (__redirect_stpcpy, __stpcpy,
		       sve ? __stpcpy_sve : __stpcpy_generic);

weak_alias (__stpcpy, stpcpy);
hidden_ver (__stpcpy, __stpcpy);
hidden_ver (__stpcpy, stpcpy);
#endif
