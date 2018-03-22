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
# define memchr __redirect_memchr
# include <string.h>
# undef memchr

# include <init-arch.h>
# include <sys/auxv.h>

extern __typeof (__redirect_memchr) __libc_memchr;
extern __typeof (__redirect_memchr) __memchr_sve attribute_hidden;
extern __typeof (__redirect_memchr) __memchr_generic attribute_hidden;

libc_ifunc (__libc_memchr,
	    hwcap & HWCAP_SVE ? __memchr_sve : __memchr_generic);

strong_alias (__libc_memchr, memchr);
#endif
