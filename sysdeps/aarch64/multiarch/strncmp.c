/* Multiple versions of strncmp. AARCH64 version.
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
/* Redefine strncmp so that the compiler won't complain about the type
   mismatch with the IFUNC selector in strong_alias, below.  */
# undef strncmp
# define strncmp __redirect_strncmp
# include <string.h>
# include <init-arch.h>
# include <sys/auxv.h>
# undef strncmp

extern __typeof (__redirect_strncmp) __libc_strncmp;
extern __typeof (__redirect_strncmp) __strncmp_sve attribute_hidden;
extern __typeof (__redirect_strncmp) __strncmp_generic attribute_hidden;

libc_ifunc (__libc_strncmp,
	    hwcap & HWCAP_SVE ? __strncmp_sve : __strncmp_generic);

strong_alias (__libc_strncmp, strncmp);
#endif
