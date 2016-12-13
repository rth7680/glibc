/* memrchr -- find the last occurrence of a byte in a memory block
   Copyright (C) 1991-2017 Free Software Foundation, Inc.
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

#include <string.h>
#include <stdint.h>
#include <limits.h>
#include <string-fzb.h>
#include <string-fzi.h>
#include <string-opthr.h>

#undef __memrchr
#undef memrchr

/* Search no more than N bytes of S for C.  */

#ifdef MEMRCHR
# define __memrchr MEMRCHR
#endif

void *
__memrchr (const void *s, int c_in, size_t n)
{
  const unsigned char *char_ptr = (const unsigned char *) s + n;
  const op_t *word_ptr;
  op_t word, repeated_c;
  uintptr_t i, align;
  unsigned char c;

  c = (unsigned char) c_in;

  /* Handle the last few characters by reading one character at a time.
     Do this until CHAR_PTR is aligned on a word boundary, or
     the entirety of small inputs.  */
  align = (uintptr_t)char_ptr % sizeof (word);
  if (n < OP_T_THRES || align > n)
    align = n;
  for (i = 0; i < align; ++i)
    if (*--char_ptr == c)
      return (void *) char_ptr;

  /* Set up a word, each of whose bytes is C.  */
  repeated_c = ((op_t)-1 / 0xff) * c;

  word_ptr = (const op_t *) char_ptr;
  n -= align;
  if (__glibc_unlikely (n == 0))
    return NULL;

  /* Loop while we have at least one word remaining.  */
  while (n >= sizeof (word))
    {
      word = *--word_ptr;
      if (has_eq (word, repeated_c))
	{
	  word ^= repeated_c;
	  goto found;
	}
      n -= sizeof (word);
    }

  /* Handle any remaining portion of a word.  */
  if (n > 0)
    {
      word = *--word_ptr ^ repeated_c;

      /* Mask out the garbage bytes at the front of WORD.  */
      op_t m = -1;
      if (__BYTE_ORDER == __LITTLE_ENDIAN)
	m >>= n * CHAR_BIT;
      else
	m <<= n * CHAR_BIT;
      word |= m;

      if (has_zero (word))
	{
	found:
	  return (char *) word_ptr + index_last_zero (word);
	}
    }
  return NULL;
}

#ifndef MEMRCHR
weak_alias (__memrchr, memrchr)
#endif
