/* Copyright (C) 2017 Free Software Foundation, Inc.
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
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/auxv.h>


static long int linux_sysconf (int name);

/* Get the value of the system variable NAME.  */
long int
__sysconf (int name)
{
  unsigned long tmp;

  /* The auxv entries describing the proper cache geometry were
     added for kernel 4.11.  Thankfully, getauxval returns 0 when
     the entry isn't present and is also the return from sysconf
     when the value is unknown.

     For the L1 linesize names, when the proper auxv entries are
     not present, we fall back on older auxv entries that provide
     the "block" linesize used for cache flushing.  It is a fair
     guess that this does in fact correspond to the L1 shape.  */
  switch (name)
    {
    case _SC_LEVEL1_ICACHE_SIZE:
      return getauxval(AT_L1I_CACHESIZE);
    case _SC_LEVEL1_ICACHE_ASSOC:
      return (getauxval(AT_L1I_CACHEGEOMETRY) >> 16) & 0xffff;
    case _SC_LEVEL1_ICACHE_LINESIZE:
      tmp = getauxval(AT_L1I_CACHEGEOMETRY);
      if (tmp)
        return tmp & 0xffff;
      return getauxval(AT_ICACHEBSIZE);

    case _SC_LEVEL1_DCACHE_SIZE:
      return getauxval(AT_L1D_CACHESIZE);
    case _SC_LEVEL1_DCACHE_ASSOC:
      return (getauxval(AT_L1D_CACHEGEOMETRY) >> 16) & 0xffff;
    case _SC_LEVEL1_DCACHE_LINESIZE:
      tmp = getauxval(AT_L1D_CACHEGEOMETRY);
      if (tmp)
        return tmp & 0xffff;
      return getauxval(AT_DCACHEBSIZE);

    case _SC_LEVEL2_CACHE_SIZE:
      return getauxval(AT_L2_CACHESIZE);
    case _SC_LEVEL2_CACHE_ASSOC:
      return (getauxval(AT_L2_CACHEGEOMETRY) >> 16) & 0xffff;
    case _SC_LEVEL2_CACHE_LINESIZE:
      return getauxval(AT_L2_CACHEGEOMETRY) & 0xffff;

    case _SC_LEVEL3_CACHE_SIZE:
      return getauxval(AT_L3_CACHESIZE);
    case _SC_LEVEL3_CACHE_ASSOC:
      return (getauxval(AT_L3_CACHEGEOMETRY) >> 16) & 0xffff;
    case _SC_LEVEL3_CACHE_LINESIZE:
      return getauxval(AT_L3_CACHEGEOMETRY) & 0xffff;

    case _SC_LEVEL4_CACHE_SIZE:
    case _SC_LEVEL4_CACHE_ASSOC:
    case _SC_LEVEL4_CACHE_LINESIZE:
      return 0;
    }

  return linux_sysconf (name);
}

/* Now the generic Linux version.  */
#undef __sysconf
#define __sysconf static linux_sysconf
#include <sysdeps/unix/sysv/linux/sysconf.c>
