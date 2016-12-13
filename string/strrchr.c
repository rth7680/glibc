/* Copyright (C) 1991-2017 Free Software Foundation, Inc.
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

#include <string.h>
#include <stdint.h>
#include <string-fzb.h>
#include <string-fzi.h>
#include <string-extbyte.h>

#undef strrchr
#undef rindex

#ifdef STRRCHR
#define strrchr STRRCHR
#endif

/* Find the last occurrence of C in S.  */
char *
strrchr (const char *s, int int_c)
{
  const unsigned char *found_c = NULL, *ptr_c;
  const op_t *found_w = NULL, *ptr_w;
  op_t word, repeated_c;
  uintptr_t i, align;
  unsigned char c;

  c = (unsigned char) int_c;
  ptr_c = (const unsigned char *) s;

  /* Handle the first few characters by reading one character at a time.
     Do this until CHAR_PTR is aligned on a word boundary.  */
  align = -(uintptr_t)ptr_c % sizeof(word);
  for (i = 0; i < align; ++i, ++ptr_c)
    {
      unsigned char this_c = *ptr_c;
      if (this_c == c)
        found_c = ptr_c;
      if (this_c == '\0')
        return (char *) found_c;
    }

  /* Set up a word, each of whose bytes is C.  */
  repeated_c = ((op_t)-1 / 0xff) * c;

  /* Search words for C.  At this point, merely record the last word
     that contained the character.  Stop when we find EOS.  */
  ptr_w = (const op_t *) ptr_c;
  while (1)
    {
      word = *ptr_w;
      if (has_zero (word))
	break;
      if (has_eq (word, repeated_c))
	found_w = ptr_w;
      ptr_w++;
    }

  /* Check to see if we've got C in the last word.  */
  i = index_first_zero_eq (word, repeated_c);
  if (extractbyte (word, i) == c)
    found_w = ptr_w;

  /* If we found a word containing C, go back and search it byte by byte.
     This is probably cheaper than indexing for the zero within WORD,
     using that to mask out following bytes that might be C, and then
     indexing to find the last C.  */
  if (found_w)
    {
      ptr_c = (const unsigned char *) found_w;
      for (i = 0; i < sizeof (word); ++i, ++ptr_c)
	{
	  unsigned char this_c = *ptr_c;
	  if (this_c == c)
	    found_c = ptr_c;
	  if (this_c == '\0')
	    break;
	}
    }
  return (char *) found_c;
}

#ifndef STRRCHR
weak_alias (strrchr, rindex)
#endif
libc_hidden_builtin_def (strrchr)
