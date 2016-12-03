/* Copyright (C) 2016 Free Software Foundation, Inc.
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

#include <features.h>
#undef __USE_STRING_INLINES
#define __NO_STRING_INLINES
#include <string.h>

/* Set LEN bytes of S to 0.  The compiler will not delete a call to
   this function, even if S is dead after the call.  */
void
__internal_explicit_bzero (void *s, size_t len)
{
  memset (s, '\0', len);
  __internal_glibc_read_memory (s, len);
}
libc_hidden_def (__internal_explicit_bzero)
strong_alias (__internal_explicit_bzero, __explicit_bzero)
weak_alias (__internal_explicit_bzero, explicit_bzero)
