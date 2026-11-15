/*
Jeremiah Whittenburg
Operating Systems CS33211
*/

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/uproc.h"

// Map state integers to string keywords
char *states[] = {
  [0] "unused",
  [1] "used",
  [2] "sleeping",
  [3] "runnable",
  [4] "running",
  [5] "zombie"
};

int main(int argc, char *argv[]) {
    struct uproc buf[64];
    int count = getprocs(buf, 64);
    if(count < 0) {
        fprintf(2, "ps: failed to fetch process states\n");
        exit(1);
    }

    // Print header using explicit single-tab layouts matching specs
    printf("PID\tPPID\tSTATE\tSIZE\tNAME\n");
    for(int i = 0; i < count; i++) {
        printf("%d\t%d\t%s\t%lu\t%s\n", 
               buf[i].pid, 
               buf[i].ppid, 
               states[buf[i].state], 
               buf[i].sz, 
               buf[i].name);
    }
    exit(0);
}
