/* Copyright (C) 1991-2017 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Based on strlen implementation by Torbjorn Granlund (tege@sics.se),
   with help from Dan Sahlin (dan@sics.se) and
   bug fix and commentary by Jim Blandy (jimb@ai.mit.edu);
   adaptation to strchr suggested by Dick Karpinski (dick@cca.ucsf.edu),
   and implemented by Roland McGrath (roland@ai.mit.edu).

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

#undef __strchrnul
#undef strchrnul

#ifdef STRCHRNUL
# define __strchrnul STRCHRNUL
#endif

/* Find the first occurrence of C in S or the final NUL byte.  */
char *
__strchrnul (const char *s, int c_in)
{
  const unsigned char *char_ptr;
  const op_t *word_ptr;
  op_t word, repeated_c;
  uintptr_t i, align, found;
  unsigned char c;

  c = (unsigned char) c_in;
  char_ptr = (const unsigned char *) s;

  /* Handle the first few characters by reading one character at a time.
     Do this until CHAR_PTR is aligned on a word boundary.  */
  align = -(uintptr_t)char_ptr % sizeof(word);
  for (i = 0; i < align; ++i, ++char_ptr)
    if (*char_ptr == c || *char_ptr == '\0')
      return (char *) char_ptr;

  /* Set up a word, each of whose bytes is C.  */
  repeated_c = ((op_t)-1 / 0xff) * c;

  word_ptr = (op_t *) char_ptr;
  do
    {
      word = *word_ptr++;
    }
  while (!has_zero_eq (word, repeated_c));

  found = index_first_zero_eq (word, repeated_c);
  return (char *) (word_ptr - 1) + found;
}

#ifndef STRCHRNUL
weak_alias (__strchrnul, strchrnul)
#endif
