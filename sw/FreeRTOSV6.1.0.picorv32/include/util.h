// See LICENSE for license details.

#ifndef __UTIL_H
#define __UTIL_H

#include <stdint.h>
#include <sys/types.h>

#define static_assert(cond) switch(0) { case 0: case !!(uint32_t)(cond): ; }

static uint64_t lfsr(uint64_t x)
{
  uint64_t bit = (x ^ (x >> 1)) & 1;
  return (x >> 1) | (bit << 62);
}

static uintptr_t insn_len(uintptr_t pc)
{
  return (*(unsigned short*)pc & 3) ? 4 : 2;
}

#endif //__UTIL_H
