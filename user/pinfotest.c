#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/pinfo.h"

struct pinfo buf[64];

int
find_proc(struct pinfo *buf, int n, int pid)
{
  for (int i = 0; i < n; i++) {
    if (buf[i].pid == pid) {
      return i;
    }
  }
  return -1;
}

int
main(int argc, char *argv[])
{
  int mypid = getpid();

  printf("pinfotest: starting...\n");

  int n1 = getpinfo(buf, 64);
  if (n1 < 0) {
    printf("FAIL: getpinfo returned -1\n");
    exit(1);
  }

  int idx1 = find_proc(buf, n1, mypid);
  if (idx1 < 0) {
    printf("FAIL: current process not found in pinfo\n");
    exit(1);
  }

  int start_ticks = buf[idx1].runticks;
  int start_nsched = buf[idx1].nsched;
  printf("Initial -> pid: %d, runticks: %d, nsched: %d, ctime: %d\n",
         mypid, start_ticks, start_nsched, buf[idx1].ctime);

  // Spin on the CPU to accumulate timer ticks and scheduler switches
  volatile int x = 0;
  for (int i = 0; i < 50000000; i++) {
    x += i;
  }

  int n2 = getpinfo(buf, 64);
  int idx2 = find_proc(buf, n2, mypid);
  int end_ticks = buf[idx2].runticks;
  int end_nsched = buf[idx2].nsched;

  printf("After spin -> runticks: %d, nsched: %d\n", end_ticks, end_nsched);

  if (end_ticks <= start_ticks) {
    printf("FAIL: runticks did not increase during CPU spin\n");
    exit(1);
  }
  if (end_nsched <= start_nsched) {
    printf("FAIL: nsched did not increase\n");
    exit(1);
  }

  // Test that a child starts with fresh counters and does not inherit parent's
  int pid = fork();
  if (pid < 0) {
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    struct pinfo cbuf[64];
    int cn = getpinfo(cbuf, 64);
    int cidx = find_proc(cbuf, cn, getpid());
    printf("Child -> pid: %d, runticks: %d, nsched: %d, level: %d\n",
           getpid(), cbuf[cidx].runticks, cbuf[cidx].nsched, cbuf[cidx].level);

    if (cbuf[cidx].runticks >= end_ticks) {
      printf("FAIL: child inherited parent runticks\n");
      exit(1);
    }
    exit(0);
  }

  wait(0);
  printf("pinfotest: ALL CHECKS PASSED\n");
  exit(0);
}
