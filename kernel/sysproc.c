#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "kernel/sysinfo.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_trace(void)
{
  int mask;

  //Grab first integer argument from register a0
  argint(0, &mask);

  myproc()->trace_mask = mask;
  return 0;
}

uint64
sys_sysinfo(void)
{
  uint64 addr;
  struct sysinfo info;
  struct proc *p = myproc();

  // Fetch the user space pointer address passed as an argument
  argaddr(0, &addr);

  // Populate our structure fields
  info.freemem = count_free_mem();
  info.nproc = count_active_procs();
  info.nopenfile = count_open_files();

  // Pass all 5 arguments to match your kernel's copyout signature:
if(copyout(p->pagetable, addr, addr, (char *)&info, sizeof(info)) < 0){
    // If it fails, print a kernel log to console to pinpoint exactly why
    printk("sysinfo kernel alert: copyout failed for pid %d at addr 0x%lx\n", p->pid, addr);
    return -1;
  }

  return 0;
}

uint64
sys_getprocs(void)
{
  uint64 buf;
  int max;

  argaddr(0, &buf);
  argint(1, &max);

  return get_uprocs(buf, max);
}

uint64
sys_getpinfo(void)
{
  uint64 buf;
  int max;

  argaddr(0, &buf);
  argint(1, &max);

  return get_pinfos(buf, max);
}