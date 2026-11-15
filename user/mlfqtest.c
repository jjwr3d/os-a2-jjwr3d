#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/pinfo.h"

struct pinfo buf[64];

int
get_my_info(int pid, int *level, int *runticks)
{
  int n = getpinfo(buf, 64);
  for (int i = 0; i < n; i++) {
    if (buf[i].pid == pid) {
      *level = buf[i].level;
      *runticks = buf[i].runticks;
      return 0;
    }
  }
  return -1;
}

int
main(int argc, char *argv[])
{
  int pid = getpid();
  int lvl = 0, rt = 0;

  get_my_info(pid, &lvl, &rt);
  printf("mlfqtest: starting (pid %d, level %d, runticks %d)\n", pid, lvl, rt);

  int last_level = -1;
  volatile int x = 0;
  for (int iter = 0; iter < 500000000; iter++) {
    x += iter;
    if (iter % 5000000 == 0) {
      if (get_my_info(pid, &lvl, &rt) == 0 && lvl != last_level) {
        printf("  [runticks=%d] transitioned to MLFQ level %d\n", rt, lvl);
        last_level = lvl;
      }
    }
  }

  printf("mlfqtest: DONE\n");
  exit(0);
}
