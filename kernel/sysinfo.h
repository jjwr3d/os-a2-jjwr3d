/*
Jeremiah Whittenburg
Operating Systems CS33211
*/

#ifndef _SYSINFO_H_
#define _SYSINFO_H_

#include "kernel/types.h"

struct sysinfo {
  uint64 freemem;   // bytes of free physical memory
  uint64 nproc;     // processes whose state is not UNUSED
  uint64 nopenfile; // entries in the system file table with ref > 0
};

#endif
