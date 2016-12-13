/* Copyright (C) 1991-2017 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Based on strlen implementation by Torbjorn Granlund (tege@sics.se),
   with help from Dan Sahlin (dan@sics.se) and
   commentary by Jim Blandy (jimb@ai.mit.edu);
   adaptation to memchr suggested by Dick Karpinski (dick@cca.ucsf.edu),
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

#ifndef _LIBC
# include <config.h>
#endif

#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <string-fzb.h>
#include <string-fzi.h>
#include <string-opthr.h>

#undef memchr

#ifdef MEMCHR
#define memchr MEMCHR
#endif

/* Search no more than N bytes of S for C.  */
void *
memchr (void const *s, int c_in, size_t n)
{
  const unsigned char *char_ptr;
  const op_t *word_ptr;
  op_t word, repeated_c;
  unsigned char c;
  uintptr_t i, align;

  c = (unsigned char) c_in;
  char_ptr = (const unsigned char *) s;

  /* Handle the first few bytes by reading one byte at a time.
     Do this until CHAR_PTR is aligned on a word boundary, or
     the entirety of small inputs.  */
  align = -(uintptr_t)char_ptr % sizeof (word);
  if (n < OP_T_THRES || align > n)
    align = n;
  for (i = 0; i < align; ++i, ++char_ptr)
    if (*char_ptr == c)
      return (void *) char_ptr;

  /* Set up a word, each of whose bytes is C.  */
  repeated_c = ((op_t)-1 / 0xff) * c;

  word_ptr = (const op_t *) char_ptr;
  n -= align;
  if (__glibc_unlikely (n == 0))
    return NULL;

  /* Loop while we have more than one word remaining.  */
  while (n > sizeof (word))
    {
      word = *word_ptr;
      if (has_eq (word, repeated_c))
	goto found;
      word_ptr++;
      n -= sizeof (word);
    }

  /* Since our pointer is aligned, we can always read the last word.  */
  word = *word_ptr;
  if (has_eq (word, repeated_c))
    {
 found:
      i = index_first_eq (word, repeated_c);
      if (i < n)
	return (char *) word_ptr + i;
    }

  return NULL;
}

#ifndef MEMCHR
libc_hidden_builtin_def (memchr)
#endif
