/* Copyright (C) 1991-2017 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Written by Torbjorn Granlund (tege@sics.se),
   with help from Dan Sahlin (dan@sics.se);
   commentary by Jim Blandy (jimb@ai.mit.edu).

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

#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <string-fzb.h>
#include <string-fzi.h>

#undef strlen

#ifdef STRLEN
# define strlen STRLEN
#endif

/* Return the length of the null-terminated string STR.  Scan for
   the null terminator quickly by testing four bytes at a time.  */
size_t
strlen (const char *str)
{
  const char *char_ptr = str;
  const op_t *word_ptr;
  op_t word;
  uintptr_t i, align;

  /* Handle the first few characters by reading one character at a time.
     Do this until CHAR_PTR is aligned on a longword boundary.  */
  align = -(uintptr_t)char_ptr % sizeof(word);
  for (i = 0; i < align; ++i, ++char_ptr)
    if (*char_ptr == '\0')
      return char_ptr - str;

  word_ptr = (const op_t *) char_ptr;
  do
    {
      word = *word_ptr++;
    }
  while (!has_zero (word));

  char_ptr = (const char *) (word_ptr - 1);
  char_ptr += index_first_zero (word);
  return char_ptr - str;
}

#ifndef STRLEN
libc_hidden_builtin_def (strlen)
#endif
