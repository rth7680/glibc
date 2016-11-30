/* Copyright (C) 1991-2016 Free Software Foundation, Inc.
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
#include <limits.h>
#include <endian.h>

#undef strcmp

#ifndef STRCMP
# define STRCMP strcmp
#endif

/* See https://graphics.stanford.edu/~seander/bithacks.html#ZeroInWord.  */
static inline unsigned long int
haszero(unsigned long int x)
{
  unsigned long int ones = -1ul / 0xff;
  unsigned long int signs = ones * 0x80;
  return (x - ones) & ~x & signs;
}

/* With A as the data at the lesser address, and B as the data at the
   greater address, discard the first F bits to return the value
   as if a single word had been read from lesser address + ofs.  */
static inline unsigned long int
alignword(unsigned long int a, unsigned long int b, uintptr_t f, uintptr_t r)
{
  if (__BYTE_ORDER == __LITTLE_ENDIAN)
    return (a >> f) | (b << r);
  else
    return (a << f) | (b >> r);
}

/* Extract the Nth byte from A, as it would appear in memory.  */
static inline unsigned char
extractbyte(unsigned long int a, uintptr_t n)
{
  if (__BYTE_ORDER == __LITTLE_ENDIAN)
    return a >> n * CHAR_BIT;
  else
    return a >> (sizeof(unsigned long int) - 1 - n) * CHAR_BIT;
}

/* Compare S1 and S2, returning less than, equal to or
   greater than zero if S1 is lexicographically less than,
   equal to or greater than S2.  */
int
STRCMP (const char *p1, const char *p2)
{
  const unsigned long int *x1, *x2;
  unsigned long int w1, w2;
  unsigned char c1, c2;
  uintptr_t i, n, ofs;
  int diff;

  /* Handle the unaligned bytes of p1 first.  */
  n = -(uintptr_t)p1 % sizeof(unsigned long int);
  for (i = 0; i < n; ++i)
    {
      c1 = *p1++;
      c2 = *p2++;
      diff = c1 - c2;
      if (c1 == '\0' || diff)
	return diff;
    }

  /* P1 is now aligned to unsigned long.  P2 may or may not be.  */
  x1 = (const unsigned long int *)p1;
  w1 = *x1++;
  ofs = (uintptr_t)p2 % sizeof(unsigned long int);
  if (ofs == 0)
    {
      x2 = (const unsigned long int *)p2;
      w2 = *x2++;
      /* Aligned loop.  If a difference is found, exit to compare the
         bytes.  Else if a zero is found we have equal strings.  */
      while (w1 == w2)
	{
	  if (haszero(w1))
	    return 0;
          w1 = *x1++;
          w2 = *x2++;
	}
    }
  else
    {
      unsigned long int w2a, w2b;
      uintptr_t bofs, rofs;

      x2 = (const unsigned long int *)(p2 - ofs);
      w2a = *x2++;
      bofs = ofs * CHAR_BIT;
      rofs = sizeof(unsigned long int) * CHAR_BIT - bofs;

      /* Align the first partial of P2, with 0xff for the rest of the
         bytes so that we can also apply the haszero test to see if we
         have already reached EOS.  If we have, then we can simply fall
         through to the final comparison.  */
      w2 = alignword(w2a, -1, bofs, rofs);
      if (!haszero(w2))
	{
	  w2b = *x2++;

	  /* Unaligned loop.  The invariant is that W2B, which is "ahead"
             of W1, does not contain end-of-string.  Therefore it is safe
             (and necessary) to read another word from each while we do
             not have a difference.  */
	  while (1)
	    {
	      w2 = alignword(w2a, w2b, bofs, rofs);
	      if (w1 != w2)
		goto final_cmp;
	      if (haszero(w2b))
		break;
	      w1 = *x1++;
	      w2a = w2b;
	      w2b = *x2++;
	    }

	  /* Zero found in the second partial of P2.  If we had EOS
	     in the aligned word, we have equality.  */
	  if (haszero(w1))
	    return 0;

          /* Load the final word of P1 and align the final partial of P2.  */
	  w1 = *x1++;
          w2 = alignword(w2b, 0, bofs, rofs);
	}
    }

 final_cmp:
  /* We have two aligned words of data.  Compare the bytes in sequence
     looking for the difference or EOS.  */
  for (i = 0; i < sizeof(unsigned long int); ++i)
    {
      c1 = extractbyte(w1, i);
      c2 = extractbyte(w2, i);
      diff = c1 - c2;
      if (c1 == '\0' || diff)
	return diff;
    }
  return 0;
}

libc_hidden_builtin_def (strcmp)
