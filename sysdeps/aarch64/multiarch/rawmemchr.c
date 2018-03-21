/* Multiple versions of rawmemchr. AARCH64 version.
   Copyright (C) 2017-2018 Free Software Foundation, Inc.
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
# define rawmemchr __redirect_rawmemchr
# define __rawmemchr __redirect___rawmemchr
# define __NO_STRING_INLINES
# define NO_MEMPCPY_STPCPY_REDIRECT
# include <string.h>
# include <init-arch.h>
# undef rawmemchr
# undef __rawmemchr

extern __typeof (__redirect_rawmemchr) __rawmemchr_sve attribute_hidden;
extern __typeof (__redirect_rawmemchr) __rawmemchr_generic attribute_hidden;

libc_ifunc_redirected (__redirect_rawmemchr, __rawmemchr,
		       sve ? __rawmemchr_sve : __rawmemchr_generic);

weak_alias (__rawmemchr, rawmemchr);
hidden_ver (__rawmemchr, __rawmemchr);
#endif
