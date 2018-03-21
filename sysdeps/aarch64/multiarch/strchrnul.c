/* Multiple versions of strchrnul. AARCH64 version.
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
/* Redefine strchrnul so that the compiler won't complain about the type
   mismatch with the IFUNC selector in strong_alias, below.  */
# undef strchrnul
# define strchrnul __redirect_strchrnul
# include <string.h>
# include <init-arch.h>
# include <sys/auxv.h>
# undef strchrnul

extern __typeof (__redirect_strchrnul) __strchrnul;
extern __typeof (__redirect_strchrnul) __strchrnul_sve attribute_hidden;
extern __typeof (__redirect_strchrnul) __strchrnul_generic attribute_hidden;

libc_ifunc (__strchrnul,
	    hwcap & HWCAP_SVE ? __strchrnul_sve : __strchrnul_generic);

weak_alias (__strchrnul, strchrnul);
#endif
