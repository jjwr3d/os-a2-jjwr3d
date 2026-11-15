#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/sysinfo.h"

void testmem() {
  struct sysinfo info;
  printf("Testing memory counting...\n");
  
  if (sysinfo(&info) < 0) {
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 free1 = info.freemem;

  // Allocate a page of memory to see if freemem drops
  char *p = sbrk(4096);
  if (p == (char*)-1) {
    printf("FAIL: sbrk failed\n");
    exit(1);
  }

  if (sysinfo(&info) < 0) {
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 free2 = info.freemem;

  if (free1 <= free2) {
    printf("FAIL: free memory did not decrease (before: %lu, after: %lu)\n", free1, free2);
    exit(1);
  }
  printf("Memory test: OK\n");
}

void testproc() {
  struct sysinfo info;
  printf("Testing process counting...\n");

  if (sysinfo(&info) < 0) {
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nproc1 = info.nproc;

  int pid = fork();
  if (pid < 0) {
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    // Child process hooks into the system state
    pause(2);
    exit(0);
  } else {
    if (sysinfo(&info) < 0) {
      printf("FAIL: sysinfo failed\n");
      exit(1);
    }
    uint64 nproc2 = info.nproc;

    if (nproc2 != nproc1 + 1) {
      printf("FAIL: process count did not increase by 1 (before: %lu, after: %lu)\n", nproc1, nproc2);
      wait(0);
      exit(1);
    }
    wait(0);
  }
  printf("Process test: OK\n");
}

void testfile() {
  struct sysinfo info;
  printf("Testing file descriptor counting...\n");

  if (sysinfo(&info) < 0) {
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nfile1 = info.nopenfile;

  int fd = open("README", 0);
  if (fd < 0) {
    printf("FAIL: open failed\n");
    exit(1);
  }

  if (sysinfo(&info) < 0) {
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nfile2 = info.nopenfile;

  close(fd);

  if (nfile2 != nfile1 + 1) {
    printf("FAIL: open files count incorrect (before: %lu, after: %lu)\n", nfile1, nfile2);
    exit(1);
  }
  printf("File test: OK\n");
}

int main(int argc, char *argv[]) {
  printf("sysinfotest: start\n");
  testmem();
  testproc();
  testfile();
  printf("sysinfotest: OK\n");
  exit(0);
}
