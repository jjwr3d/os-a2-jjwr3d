
user/_sysinfotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testmem>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/sysinfo.h"

void testmem() {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  struct sysinfo info;
  printf("Testing memory counting...\n");
   a:	00001517          	auipc	a0,0x1
   e:	ae650513          	addi	a0,a0,-1306 # af0 <malloc+0xfe>
  12:	12d000ef          	jal	93e <printf>
  
  if (sysinfo(&info) < 0) {
  16:	fc840513          	addi	a0,s0,-56
  1a:	58c000ef          	jal	5a6 <sysinfo>
  1e:	02054f63          	bltz	a0,5c <testmem+0x5c>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 free1 = info.freemem;
  22:	fc843483          	ld	s1,-56(s0)

  // Allocate a page of memory to see if freemem drops
  char *p = sbrk(4096);
  26:	6505                	lui	a0,0x1
  28:	492000ef          	jal	4ba <sbrk>
  if (p == (char*)-1) {
  2c:	57fd                	li	a5,-1
  2e:	04f50063          	beq	a0,a5,6e <testmem+0x6e>
    printf("FAIL: sbrk failed\n");
    exit(1);
  }

  if (sysinfo(&info) < 0) {
  32:	fc840513          	addi	a0,s0,-56
  36:	570000ef          	jal	5a6 <sysinfo>
  3a:	04054363          	bltz	a0,80 <testmem+0x80>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 free2 = info.freemem;
  3e:	fc843603          	ld	a2,-56(s0)

  if (free1 <= free2) {
  42:	04967863          	bgeu	a2,s1,92 <testmem+0x92>
    printf("FAIL: free memory did not decrease (before: %lu, after: %lu)\n", free1, free2);
    exit(1);
  }
  printf("Memory test: OK\n");
  46:	00001517          	auipc	a0,0x1
  4a:	b3a50513          	addi	a0,a0,-1222 # b80 <malloc+0x18e>
  4e:	0f1000ef          	jal	93e <printf>
}
  52:	70e2                	ld	ra,56(sp)
  54:	7442                	ld	s0,48(sp)
  56:	74a2                	ld	s1,40(sp)
  58:	6121                	addi	sp,sp,64
  5a:	8082                	ret
    printf("FAIL: sysinfo failed\n");
  5c:	00001517          	auipc	a0,0x1
  60:	ab450513          	addi	a0,a0,-1356 # b10 <malloc+0x11e>
  64:	0db000ef          	jal	93e <printf>
    exit(1);
  68:	4505                	li	a0,1
  6a:	484000ef          	jal	4ee <exit>
    printf("FAIL: sbrk failed\n");
  6e:	00001517          	auipc	a0,0x1
  72:	aba50513          	addi	a0,a0,-1350 # b28 <malloc+0x136>
  76:	0c9000ef          	jal	93e <printf>
    exit(1);
  7a:	4505                	li	a0,1
  7c:	472000ef          	jal	4ee <exit>
    printf("FAIL: sysinfo failed\n");
  80:	00001517          	auipc	a0,0x1
  84:	a9050513          	addi	a0,a0,-1392 # b10 <malloc+0x11e>
  88:	0b7000ef          	jal	93e <printf>
    exit(1);
  8c:	4505                	li	a0,1
  8e:	460000ef          	jal	4ee <exit>
    printf("FAIL: free memory did not decrease (before: %lu, after: %lu)\n", free1, free2);
  92:	85a6                	mv	a1,s1
  94:	00001517          	auipc	a0,0x1
  98:	aac50513          	addi	a0,a0,-1364 # b40 <malloc+0x14e>
  9c:	0a3000ef          	jal	93e <printf>
    exit(1);
  a0:	4505                	li	a0,1
  a2:	44c000ef          	jal	4ee <exit>

00000000000000a6 <testproc>:

void testproc() {
  a6:	7139                	addi	sp,sp,-64
  a8:	fc06                	sd	ra,56(sp)
  aa:	f822                	sd	s0,48(sp)
  ac:	f426                	sd	s1,40(sp)
  ae:	0080                	addi	s0,sp,64
  struct sysinfo info;
  printf("Testing process counting...\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	ae850513          	addi	a0,a0,-1304 # b98 <malloc+0x1a6>
  b8:	087000ef          	jal	93e <printf>

  if (sysinfo(&info) < 0) {
  bc:	fc840513          	addi	a0,s0,-56
  c0:	4e6000ef          	jal	5a6 <sysinfo>
  c4:	04054363          	bltz	a0,10a <testproc+0x64>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nproc1 = info.nproc;
  c8:	fd043483          	ld	s1,-48(s0)

  int pid = fork();
  cc:	41a000ef          	jal	4e6 <fork>
  if (pid < 0) {
  d0:	04054663          	bltz	a0,11c <testproc+0x76>
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if (pid == 0) {
  d4:	cd29                	beqz	a0,12e <testproc+0x88>
    // Child process hooks into the system state
    pause(2);
    exit(0);
  } else {
    if (sysinfo(&info) < 0) {
  d6:	fc840513          	addi	a0,s0,-56
  da:	4cc000ef          	jal	5a6 <sysinfo>
  de:	04054e63          	bltz	a0,13a <testproc+0x94>
      printf("FAIL: sysinfo failed\n");
      exit(1);
    }
    uint64 nproc2 = info.nproc;
  e2:	fd043603          	ld	a2,-48(s0)

    if (nproc2 != nproc1 + 1) {
  e6:	00148793          	addi	a5,s1,1
  ea:	06c79163          	bne	a5,a2,14c <testproc+0xa6>
      printf("FAIL: process count did not increase by 1 (before: %lu, after: %lu)\n", nproc1, nproc2);
      wait(0);
      exit(1);
    }
    wait(0);
  ee:	4501                	li	a0,0
  f0:	406000ef          	jal	4f6 <wait>
  }
  printf("Process test: OK\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	b2450513          	addi	a0,a0,-1244 # c18 <malloc+0x226>
  fc:	043000ef          	jal	93e <printf>
}
 100:	70e2                	ld	ra,56(sp)
 102:	7442                	ld	s0,48(sp)
 104:	74a2                	ld	s1,40(sp)
 106:	6121                	addi	sp,sp,64
 108:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	a0650513          	addi	a0,a0,-1530 # b10 <malloc+0x11e>
 112:	02d000ef          	jal	93e <printf>
    exit(1);
 116:	4505                	li	a0,1
 118:	3d6000ef          	jal	4ee <exit>
    printf("FAIL: fork failed\n");
 11c:	00001517          	auipc	a0,0x1
 120:	a9c50513          	addi	a0,a0,-1380 # bb8 <malloc+0x1c6>
 124:	01b000ef          	jal	93e <printf>
    exit(1);
 128:	4505                	li	a0,1
 12a:	3c4000ef          	jal	4ee <exit>
    pause(2);
 12e:	4509                	li	a0,2
 130:	44e000ef          	jal	57e <pause>
    exit(0);
 134:	4501                	li	a0,0
 136:	3b8000ef          	jal	4ee <exit>
      printf("FAIL: sysinfo failed\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	9d650513          	addi	a0,a0,-1578 # b10 <malloc+0x11e>
 142:	7fc000ef          	jal	93e <printf>
      exit(1);
 146:	4505                	li	a0,1
 148:	3a6000ef          	jal	4ee <exit>
      printf("FAIL: process count did not increase by 1 (before: %lu, after: %lu)\n", nproc1, nproc2);
 14c:	85a6                	mv	a1,s1
 14e:	00001517          	auipc	a0,0x1
 152:	a8250513          	addi	a0,a0,-1406 # bd0 <malloc+0x1de>
 156:	7e8000ef          	jal	93e <printf>
      wait(0);
 15a:	4501                	li	a0,0
 15c:	39a000ef          	jal	4f6 <wait>
      exit(1);
 160:	4505                	li	a0,1
 162:	38c000ef          	jal	4ee <exit>

0000000000000166 <testfile>:

void testfile() {
 166:	715d                	addi	sp,sp,-80
 168:	e486                	sd	ra,72(sp)
 16a:	e0a2                	sd	s0,64(sp)
 16c:	fc26                	sd	s1,56(sp)
 16e:	f84a                	sd	s2,48(sp)
 170:	f44e                	sd	s3,40(sp)
 172:	0880                	addi	s0,sp,80
  struct sysinfo info;
  printf("Testing file descriptor counting...\n");
 174:	00001517          	auipc	a0,0x1
 178:	abc50513          	addi	a0,a0,-1348 # c30 <malloc+0x23e>
 17c:	7c2000ef          	jal	93e <printf>

  if (sysinfo(&info) < 0) {
 180:	fb840513          	addi	a0,s0,-72
 184:	422000ef          	jal	5a6 <sysinfo>
 188:	04054a63          	bltz	a0,1dc <testfile+0x76>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nfile1 = info.nopenfile;
 18c:	fc843903          	ld	s2,-56(s0)

  int fd = open("README", 0);
 190:	4581                	li	a1,0
 192:	00001517          	auipc	a0,0x1
 196:	ac650513          	addi	a0,a0,-1338 # c58 <malloc+0x266>
 19a:	394000ef          	jal	52e <open>
 19e:	84aa                	mv	s1,a0
  if (fd < 0) {
 1a0:	04054763          	bltz	a0,1ee <testfile+0x88>
    printf("FAIL: open failed\n");
    exit(1);
  }

  if (sysinfo(&info) < 0) {
 1a4:	fb840513          	addi	a0,s0,-72
 1a8:	3fe000ef          	jal	5a6 <sysinfo>
 1ac:	04054a63          	bltz	a0,200 <testfile+0x9a>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  uint64 nfile2 = info.nopenfile;
 1b0:	fc843983          	ld	s3,-56(s0)

  close(fd);
 1b4:	8526                	mv	a0,s1
 1b6:	360000ef          	jal	516 <close>

  if (nfile2 != nfile1 + 1) {
 1ba:	00190793          	addi	a5,s2,1
 1be:	05379a63          	bne	a5,s3,212 <testfile+0xac>
    printf("FAIL: open files count incorrect (before: %lu, after: %lu)\n", nfile1, nfile2);
    exit(1);
  }
  printf("File test: OK\n");
 1c2:	00001517          	auipc	a0,0x1
 1c6:	af650513          	addi	a0,a0,-1290 # cb8 <malloc+0x2c6>
 1ca:	774000ef          	jal	93e <printf>
}
 1ce:	60a6                	ld	ra,72(sp)
 1d0:	6406                	ld	s0,64(sp)
 1d2:	74e2                	ld	s1,56(sp)
 1d4:	7942                	ld	s2,48(sp)
 1d6:	79a2                	ld	s3,40(sp)
 1d8:	6161                	addi	sp,sp,80
 1da:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	93450513          	addi	a0,a0,-1740 # b10 <malloc+0x11e>
 1e4:	75a000ef          	jal	93e <printf>
    exit(1);
 1e8:	4505                	li	a0,1
 1ea:	304000ef          	jal	4ee <exit>
    printf("FAIL: open failed\n");
 1ee:	00001517          	auipc	a0,0x1
 1f2:	a7250513          	addi	a0,a0,-1422 # c60 <malloc+0x26e>
 1f6:	748000ef          	jal	93e <printf>
    exit(1);
 1fa:	4505                	li	a0,1
 1fc:	2f2000ef          	jal	4ee <exit>
    printf("FAIL: sysinfo failed\n");
 200:	00001517          	auipc	a0,0x1
 204:	91050513          	addi	a0,a0,-1776 # b10 <malloc+0x11e>
 208:	736000ef          	jal	93e <printf>
    exit(1);
 20c:	4505                	li	a0,1
 20e:	2e0000ef          	jal	4ee <exit>
    printf("FAIL: open files count incorrect (before: %lu, after: %lu)\n", nfile1, nfile2);
 212:	864e                	mv	a2,s3
 214:	85ca                	mv	a1,s2
 216:	00001517          	auipc	a0,0x1
 21a:	a6250513          	addi	a0,a0,-1438 # c78 <malloc+0x286>
 21e:	720000ef          	jal	93e <printf>
    exit(1);
 222:	4505                	li	a0,1
 224:	2ca000ef          	jal	4ee <exit>

0000000000000228 <main>:

int main(int argc, char *argv[]) {
 228:	1141                	addi	sp,sp,-16
 22a:	e406                	sd	ra,8(sp)
 22c:	e022                	sd	s0,0(sp)
 22e:	0800                	addi	s0,sp,16
  printf("sysinfotest: start\n");
 230:	00001517          	auipc	a0,0x1
 234:	a9850513          	addi	a0,a0,-1384 # cc8 <malloc+0x2d6>
 238:	706000ef          	jal	93e <printf>
  testmem();
 23c:	dc5ff0ef          	jal	0 <testmem>
  testproc();
 240:	e67ff0ef          	jal	a6 <testproc>
  testfile();
 244:	f23ff0ef          	jal	166 <testfile>
  printf("sysinfotest: OK\n");
 248:	00001517          	auipc	a0,0x1
 24c:	a9850513          	addi	a0,a0,-1384 # ce0 <malloc+0x2ee>
 250:	6ee000ef          	jal	93e <printf>
  exit(0);
 254:	4501                	li	a0,0
 256:	298000ef          	jal	4ee <exit>

000000000000025a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 262:	fc7ff0ef          	jal	228 <main>
  exit(r);
 266:	288000ef          	jal	4ee <exit>

000000000000026a <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 270:	87aa                	mv	a5,a0
 272:	0585                	addi	a1,a1,1
 274:	0785                	addi	a5,a5,1
 276:	fff5c703          	lbu	a4,-1(a1)
 27a:	fee78fa3          	sb	a4,-1(a5)
 27e:	fb75                	bnez	a4,272 <strcpy+0x8>
    ;
  return os;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cb91                	beqz	a5,2a4 <strcmp+0x1e>
 292:	0005c703          	lbu	a4,0(a1)
 296:	00f71763          	bne	a4,a5,2a4 <strcmp+0x1e>
    p++, q++;
 29a:	0505                	addi	a0,a0,1
 29c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbe5                	bnez	a5,292 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2a4:	0005c503          	lbu	a0,0(a1)
}
 2a8:	40a7853b          	subw	a0,a5,a0
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <strlen>:

uint
strlen(const char *s)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	cf91                	beqz	a5,2d8 <strlen+0x26>
 2be:	0505                	addi	a0,a0,1
 2c0:	87aa                	mv	a5,a0
 2c2:	86be                	mv	a3,a5
 2c4:	0785                	addi	a5,a5,1
 2c6:	fff7c703          	lbu	a4,-1(a5)
 2ca:	ff65                	bnez	a4,2c2 <strlen+0x10>
 2cc:	40a6853b          	subw	a0,a3,a0
 2d0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  for (n = 0; s[n]; n++)
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <strlen+0x20>

00000000000002dc <memset>:

void *
memset(void *dst, int c, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 2e2:	ca19                	beqz	a2,2f8 <memset+0x1c>
 2e4:	87aa                	mv	a5,a0
 2e6:	1602                	slli	a2,a2,0x20
 2e8:	9201                	srli	a2,a2,0x20
 2ea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ee:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 2f2:	0785                	addi	a5,a5,1
 2f4:	fee79de3          	bne	a5,a4,2ee <memset+0x12>
  }
  return dst;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <strchr>:

char *
strchr(const char *s, char c)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e422                	sd	s0,8(sp)
 302:	0800                	addi	s0,sp,16
  for (; *s; s++)
 304:	00054783          	lbu	a5,0(a0)
 308:	cb99                	beqz	a5,31e <strchr+0x20>
    if (*s == c)
 30a:	00f58763          	beq	a1,a5,318 <strchr+0x1a>
  for (; *s; s++)
 30e:	0505                	addi	a0,a0,1
 310:	00054783          	lbu	a5,0(a0)
 314:	fbfd                	bnez	a5,30a <strchr+0xc>
      return (char *)s;
  return 0;
 316:	4501                	li	a0,0
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <strchr+0x1a>

0000000000000322 <gets>:

char *
gets(char *buf, int max)
{
 322:	711d                	addi	sp,sp,-96
 324:	ec86                	sd	ra,88(sp)
 326:	e8a2                	sd	s0,80(sp)
 328:	e4a6                	sd	s1,72(sp)
 32a:	e0ca                	sd	s2,64(sp)
 32c:	fc4e                	sd	s3,56(sp)
 32e:	f852                	sd	s4,48(sp)
 330:	f456                	sd	s5,40(sp)
 332:	f05a                	sd	s6,32(sp)
 334:	ec5e                	sd	s7,24(sp)
 336:	1080                	addi	s0,sp,96
 338:	8baa                	mv	s7,a0
 33a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 33c:	892a                	mv	s2,a0
 33e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 340:	4aa9                	li	s5,10
 342:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 344:	89a6                	mv	s3,s1
 346:	2485                	addiw	s1,s1,1
 348:	0344d663          	bge	s1,s4,374 <gets+0x52>
    cc = read(0, &c, 1);
 34c:	4605                	li	a2,1
 34e:	faf40593          	addi	a1,s0,-81
 352:	4501                	li	a0,0
 354:	1b2000ef          	jal	506 <read>
    if (cc < 1)
 358:	00a05e63          	blez	a0,374 <gets+0x52>
    buf[i++] = c;
 35c:	faf44783          	lbu	a5,-81(s0)
 360:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 364:	01578763          	beq	a5,s5,372 <gets+0x50>
 368:	0905                	addi	s2,s2,1
 36a:	fd679de3          	bne	a5,s6,344 <gets+0x22>
    buf[i++] = c;
 36e:	89a6                	mv	s3,s1
 370:	a011                	j	374 <gets+0x52>
 372:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 374:	99de                	add	s3,s3,s7
 376:	00098023          	sb	zero,0(s3)
  return buf;
}
 37a:	855e                	mv	a0,s7
 37c:	60e6                	ld	ra,88(sp)
 37e:	6446                	ld	s0,80(sp)
 380:	64a6                	ld	s1,72(sp)
 382:	6906                	ld	s2,64(sp)
 384:	79e2                	ld	s3,56(sp)
 386:	7a42                	ld	s4,48(sp)
 388:	7aa2                	ld	s5,40(sp)
 38a:	7b02                	ld	s6,32(sp)
 38c:	6be2                	ld	s7,24(sp)
 38e:	6125                	addi	sp,sp,96
 390:	8082                	ret

0000000000000392 <stat>:

int
stat(const char *n, struct stat *st)
{
 392:	1101                	addi	sp,sp,-32
 394:	ec06                	sd	ra,24(sp)
 396:	e822                	sd	s0,16(sp)
 398:	e04a                	sd	s2,0(sp)
 39a:	1000                	addi	s0,sp,32
 39c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 39e:	4581                	li	a1,0
 3a0:	18e000ef          	jal	52e <open>
  if (fd < 0)
 3a4:	02054263          	bltz	a0,3c8 <stat+0x36>
 3a8:	e426                	sd	s1,8(sp)
 3aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ac:	85ca                	mv	a1,s2
 3ae:	198000ef          	jal	546 <fstat>
 3b2:	892a                	mv	s2,a0
  close(fd);
 3b4:	8526                	mv	a0,s1
 3b6:	160000ef          	jal	516 <close>
  return r;
 3ba:	64a2                	ld	s1,8(sp)
}
 3bc:	854a                	mv	a0,s2
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6902                	ld	s2,0(sp)
 3c4:	6105                	addi	sp,sp,32
 3c6:	8082                	ret
    return -1;
 3c8:	597d                	li	s2,-1
 3ca:	bfcd                	j	3bc <stat+0x2a>

00000000000003cc <atoi>:

int
atoi(const char *s)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 3d2:	00054683          	lbu	a3,0(a0)
 3d6:	fd06879b          	addiw	a5,a3,-48
 3da:	0ff7f793          	zext.b	a5,a5
 3de:	4625                	li	a2,9
 3e0:	02f66863          	bltu	a2,a5,410 <atoi+0x44>
 3e4:	872a                	mv	a4,a0
  n = 0;
 3e6:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 3e8:	0705                	addi	a4,a4,1
 3ea:	0025179b          	slliw	a5,a0,0x2
 3ee:	9fa9                	addw	a5,a5,a0
 3f0:	0017979b          	slliw	a5,a5,0x1
 3f4:	9fb5                	addw	a5,a5,a3
 3f6:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 3fa:	00074683          	lbu	a3,0(a4)
 3fe:	fd06879b          	addiw	a5,a3,-48
 402:	0ff7f793          	zext.b	a5,a5
 406:	fef671e3          	bgeu	a2,a5,3e8 <atoi+0x1c>
  return n;
}
 40a:	6422                	ld	s0,8(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret
  n = 0;
 410:	4501                	li	a0,0
 412:	bfe5                	j	40a <atoi+0x3e>

0000000000000414 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 414:	1141                	addi	sp,sp,-16
 416:	e422                	sd	s0,8(sp)
 418:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41a:	02b57463          	bgeu	a0,a1,442 <memmove+0x2e>
    while (n-- > 0)
 41e:	00c05f63          	blez	a2,43c <memmove+0x28>
 422:	1602                	slli	a2,a2,0x20
 424:	9201                	srli	a2,a2,0x20
 426:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42a:	872a                	mv	a4,a0
      *dst++ = *src++;
 42c:	0585                	addi	a1,a1,1
 42e:	0705                	addi	a4,a4,1
 430:	fff5c683          	lbu	a3,-1(a1)
 434:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 438:	fef71ae3          	bne	a4,a5,42c <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
    dst += n;
 442:	00c50733          	add	a4,a0,a2
    src += n;
 446:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 448:	fec05ae3          	blez	a2,43c <memmove+0x28>
 44c:	fff6079b          	addiw	a5,a2,-1
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	fff7c793          	not	a5,a5
 458:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45a:	15fd                	addi	a1,a1,-1
 45c:	177d                	addi	a4,a4,-1
 45e:	0005c683          	lbu	a3,0(a1)
 462:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 466:	fee79ae3          	bne	a5,a4,45a <memmove+0x46>
 46a:	bfc9                	j	43c <memmove+0x28>

000000000000046c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e422                	sd	s0,8(sp)
 470:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 472:	ca05                	beqz	a2,4a2 <memcmp+0x36>
 474:	fff6069b          	addiw	a3,a2,-1
 478:	1682                	slli	a3,a3,0x20
 47a:	9281                	srli	a3,a3,0x20
 47c:	0685                	addi	a3,a3,1
 47e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 480:	00054783          	lbu	a5,0(a0)
 484:	0005c703          	lbu	a4,0(a1)
 488:	00e79863          	bne	a5,a4,498 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48c:	0505                	addi	a0,a0,1
    p2++;
 48e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 490:	fed518e3          	bne	a0,a3,480 <memcmp+0x14>
  }
  return 0;
 494:	4501                	li	a0,0
 496:	a019                	j	49c <memcmp+0x30>
      return *p1 - *p2;
 498:	40e7853b          	subw	a0,a5,a4
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  return 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <memcmp+0x30>

00000000000004a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ae:	f67ff0ef          	jal	414 <memmove>
}
 4b2:	60a2                	ld	ra,8(sp)
 4b4:	6402                	ld	s0,0(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret

00000000000004ba <sbrk>:

char *
sbrk(int n)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e406                	sd	ra,8(sp)
 4be:	e022                	sd	s0,0(sp)
 4c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4c2:	4585                	li	a1,1
 4c4:	0b2000ef          	jal	576 <sys_sbrk>
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret

00000000000004d0 <sbrklazy>:

char *
sbrklazy(int n)
{
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e406                	sd	ra,8(sp)
 4d4:	e022                	sd	s0,0(sp)
 4d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4d8:	4589                	li	a1,2
 4da:	09c000ef          	jal	576 <sys_sbrk>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4e6:	4885                	li	a7,1
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ee:	4889                	li	a7,2
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4f6:	488d                	li	a7,3
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4fe:	4891                	li	a7,4
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <read>:
.global read
read:
 li a7, SYS_read
 506:	4895                	li	a7,5
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <write>:
.global write
write:
 li a7, SYS_write
 50e:	48c1                	li	a7,16
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <close>:
.global close
close:
 li a7, SYS_close
 516:	48d5                	li	a7,21
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <kill>:
.global kill
kill:
 li a7, SYS_kill
 51e:	4899                	li	a7,6
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exec>:
.global exec
exec:
 li a7, SYS_exec
 526:	489d                	li	a7,7
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <open>:
.global open
open:
 li a7, SYS_open
 52e:	48bd                	li	a7,15
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 536:	48c5                	li	a7,17
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 53e:	48c9                	li	a7,18
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 546:	48a1                	li	a7,8
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <link>:
.global link
link:
 li a7, SYS_link
 54e:	48cd                	li	a7,19
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 556:	48d1                	li	a7,20
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 55e:	48a5                	li	a7,9
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <dup>:
.global dup
dup:
 li a7, SYS_dup
 566:	48a9                	li	a7,10
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 56e:	48ad                	li	a7,11
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 576:	48b1                	li	a7,12
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <pause>:
.global pause
pause:
 li a7, SYS_pause
 57e:	48b5                	li	a7,13
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 586:	48b9                	li	a7,14
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <sync>:
.global sync
sync:
 li a7, SYS_sync
 58e:	48d9                	li	a7,22
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 596:	48dd                	li	a7,23
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <trace>:
.global trace
trace:
 li a7, SYS_trace
 59e:	48e1                	li	a7,24
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 5a6:	48e5                	li	a7,25
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 5ae:	48e9                	li	a7,26
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b6:	1101                	addi	sp,sp,-32
 5b8:	ec06                	sd	ra,24(sp)
 5ba:	e822                	sd	s0,16(sp)
 5bc:	1000                	addi	s0,sp,32
 5be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c2:	4605                	li	a2,1
 5c4:	fef40593          	addi	a1,s0,-17
 5c8:	f47ff0ef          	jal	50e <write>
}
 5cc:	60e2                	ld	ra,24(sp)
 5ce:	6442                	ld	s0,16(sp)
 5d0:	6105                	addi	sp,sp,32
 5d2:	8082                	ret

00000000000005d4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5d4:	715d                	addi	sp,sp,-80
 5d6:	e486                	sd	ra,72(sp)
 5d8:	e0a2                	sd	s0,64(sp)
 5da:	f84a                	sd	s2,48(sp)
 5dc:	0880                	addi	s0,sp,80
 5de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 5e0:	c299                	beqz	a3,5e6 <printint+0x12>
 5e2:	0805c363          	bltz	a1,668 <printint+0x94>
  neg = 0;
 5e6:	4881                	li	a7,0
 5e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5ec:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 5ee:	00000517          	auipc	a0,0x0
 5f2:	71250513          	addi	a0,a0,1810 # d00 <digits>
 5f6:	883e                	mv	a6,a5
 5f8:	2785                	addiw	a5,a5,1
 5fa:	02c5f733          	remu	a4,a1,a2
 5fe:	972a                	add	a4,a4,a0
 600:	00074703          	lbu	a4,0(a4)
 604:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 608:	872e                	mv	a4,a1
 60a:	02c5d5b3          	divu	a1,a1,a2
 60e:	0685                	addi	a3,a3,1
 610:	fec773e3          	bgeu	a4,a2,5f6 <printint+0x22>
  if (neg)
 614:	00088b63          	beqz	a7,62a <printint+0x56>
    buf[i++] = '-';
 618:	fd078793          	addi	a5,a5,-48
 61c:	97a2                	add	a5,a5,s0
 61e:	02d00713          	li	a4,45
 622:	fee78423          	sb	a4,-24(a5)
 626:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 62a:	02f05a63          	blez	a5,65e <printint+0x8a>
 62e:	fc26                	sd	s1,56(sp)
 630:	f44e                	sd	s3,40(sp)
 632:	fb840713          	addi	a4,s0,-72
 636:	00f704b3          	add	s1,a4,a5
 63a:	fff70993          	addi	s3,a4,-1
 63e:	99be                	add	s3,s3,a5
 640:	37fd                	addiw	a5,a5,-1
 642:	1782                	slli	a5,a5,0x20
 644:	9381                	srli	a5,a5,0x20
 646:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 64a:	fff4c583          	lbu	a1,-1(s1)
 64e:	854a                	mv	a0,s2
 650:	f67ff0ef          	jal	5b6 <putc>
  while (--i >= 0)
 654:	14fd                	addi	s1,s1,-1
 656:	ff349ae3          	bne	s1,s3,64a <printint+0x76>
 65a:	74e2                	ld	s1,56(sp)
 65c:	79a2                	ld	s3,40(sp)
}
 65e:	60a6                	ld	ra,72(sp)
 660:	6406                	ld	s0,64(sp)
 662:	7942                	ld	s2,48(sp)
 664:	6161                	addi	sp,sp,80
 666:	8082                	ret
    x = -xx;
 668:	40b005b3          	neg	a1,a1
    neg = 1;
 66c:	4885                	li	a7,1
    x = -xx;
 66e:	bfad                	j	5e8 <printint+0x14>

0000000000000670 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 670:	711d                	addi	sp,sp,-96
 672:	ec86                	sd	ra,88(sp)
 674:	e8a2                	sd	s0,80(sp)
 676:	e0ca                	sd	s2,64(sp)
 678:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 67a:	0005c903          	lbu	s2,0(a1)
 67e:	28090663          	beqz	s2,90a <vprintf+0x29a>
 682:	e4a6                	sd	s1,72(sp)
 684:	fc4e                	sd	s3,56(sp)
 686:	f852                	sd	s4,48(sp)
 688:	f456                	sd	s5,40(sp)
 68a:	f05a                	sd	s6,32(sp)
 68c:	ec5e                	sd	s7,24(sp)
 68e:	e862                	sd	s8,16(sp)
 690:	e466                	sd	s9,8(sp)
 692:	8b2a                	mv	s6,a0
 694:	8a2e                	mv	s4,a1
 696:	8bb2                	mv	s7,a2
  state = 0;
 698:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 69a:	4481                	li	s1,0
 69c:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 69e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 6a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 6a6:	06c00c93          	li	s9,108
 6aa:	a005                	j	6ca <vprintf+0x5a>
        putc(fd, c0);
 6ac:	85ca                	mv	a1,s2
 6ae:	855a                	mv	a0,s6
 6b0:	f07ff0ef          	jal	5b6 <putc>
 6b4:	a019                	j	6ba <vprintf+0x4a>
    } else if (state == '%') {
 6b6:	03598263          	beq	s3,s5,6da <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 6ba:	2485                	addiw	s1,s1,1
 6bc:	8726                	mv	a4,s1
 6be:	009a07b3          	add	a5,s4,s1
 6c2:	0007c903          	lbu	s2,0(a5)
 6c6:	22090a63          	beqz	s2,8fa <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6ca:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 6ce:	fe0994e3          	bnez	s3,6b6 <vprintf+0x46>
      if (c0 == '%') {
 6d2:	fd579de3          	bne	a5,s5,6ac <vprintf+0x3c>
        state = '%';
 6d6:	89be                	mv	s3,a5
 6d8:	b7cd                	j	6ba <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 6da:	00ea06b3          	add	a3,s4,a4
 6de:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6e2:	8636                	mv	a2,a3
      if (c1)
 6e4:	c681                	beqz	a3,6ec <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 6e6:	9752                	add	a4,a4,s4
 6e8:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 6ec:	05878363          	beq	a5,s8,732 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 6f0:	05978d63          	beq	a5,s9,74a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 6f4:	07500713          	li	a4,117
 6f8:	0ee78763          	beq	a5,a4,7e6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 6fc:	07800713          	li	a4,120
 700:	12e78963          	beq	a5,a4,832 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 704:	07000713          	li	a4,112
 708:	14e78e63          	beq	a5,a4,864 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 70c:	06300713          	li	a4,99
 710:	18e78e63          	beq	a5,a4,8ac <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 714:	07300713          	li	a4,115
 718:	1ae78463          	beq	a5,a4,8c0 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 71c:	02500713          	li	a4,37
 720:	04e79563          	bne	a5,a4,76a <vprintf+0xfa>
        putc(fd, '%');
 724:	02500593          	li	a1,37
 728:	855a                	mv	a0,s6
 72a:	e8dff0ef          	jal	5b6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 72e:	4981                	li	s3,0
 730:	b769                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 732:	008b8913          	addi	s2,s7,8
 736:	4685                	li	a3,1
 738:	4629                	li	a2,10
 73a:	000ba583          	lw	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	e95ff0ef          	jal	5d4 <printint>
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
 748:	bf8d                	j	6ba <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 74a:	06400793          	li	a5,100
 74e:	02f68963          	beq	a3,a5,780 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 752:	06c00793          	li	a5,108
 756:	04f68263          	beq	a3,a5,79a <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 75a:	07500793          	li	a5,117
 75e:	0af68063          	beq	a3,a5,7fe <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 762:	07800793          	li	a5,120
 766:	0ef68263          	beq	a3,a5,84a <vprintf+0x1da>
        putc(fd, '%');
 76a:	02500593          	li	a1,37
 76e:	855a                	mv	a0,s6
 770:	e47ff0ef          	jal	5b6 <putc>
        putc(fd, c0);
 774:	85ca                	mv	a1,s2
 776:	855a                	mv	a0,s6
 778:	e3fff0ef          	jal	5b6 <putc>
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bf35                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 780:	008b8913          	addi	s2,s7,8
 784:	4685                	li	a3,1
 786:	4629                	li	a2,10
 788:	000bb583          	ld	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	e47ff0ef          	jal	5d4 <printint>
        i += 1;
 792:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 794:	8bca                	mv	s7,s2
      state = 0;
 796:	4981                	li	s3,0
        i += 1;
 798:	b70d                	j	6ba <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 79a:	06400793          	li	a5,100
 79e:	02f60763          	beq	a2,a5,7cc <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 7a2:	07500793          	li	a5,117
 7a6:	06f60963          	beq	a2,a5,818 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 7aa:	07800793          	li	a5,120
 7ae:	faf61ee3          	bne	a2,a5,76a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b2:	008b8913          	addi	s2,s7,8
 7b6:	4681                	li	a3,0
 7b8:	4641                	li	a2,16
 7ba:	000bb583          	ld	a1,0(s7)
 7be:	855a                	mv	a0,s6
 7c0:	e15ff0ef          	jal	5d4 <printint>
        i += 2;
 7c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c6:	8bca                	mv	s7,s2
      state = 0;
 7c8:	4981                	li	s3,0
        i += 2;
 7ca:	bdc5                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	4685                	li	a3,1
 7d2:	4629                	li	a2,10
 7d4:	000bb583          	ld	a1,0(s7)
 7d8:	855a                	mv	a0,s6
 7da:	dfbff0ef          	jal	5d4 <printint>
        i += 2;
 7de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e0:	8bca                	mv	s7,s2
      state = 0;
 7e2:	4981                	li	s3,0
        i += 2;
 7e4:	bdd9                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7e6:	008b8913          	addi	s2,s7,8
 7ea:	4681                	li	a3,0
 7ec:	4629                	li	a2,10
 7ee:	000be583          	lwu	a1,0(s7)
 7f2:	855a                	mv	a0,s6
 7f4:	de1ff0ef          	jal	5d4 <printint>
 7f8:	8bca                	mv	s7,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bd7d                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	008b8913          	addi	s2,s7,8
 802:	4681                	li	a3,0
 804:	4629                	li	a2,10
 806:	000bb583          	ld	a1,0(s7)
 80a:	855a                	mv	a0,s6
 80c:	dc9ff0ef          	jal	5d4 <printint>
        i += 1;
 810:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 812:	8bca                	mv	s7,s2
      state = 0;
 814:	4981                	li	s3,0
        i += 1;
 816:	b555                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 818:	008b8913          	addi	s2,s7,8
 81c:	4681                	li	a3,0
 81e:	4629                	li	a2,10
 820:	000bb583          	ld	a1,0(s7)
 824:	855a                	mv	a0,s6
 826:	dafff0ef          	jal	5d4 <printint>
        i += 2;
 82a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 82c:	8bca                	mv	s7,s2
      state = 0;
 82e:	4981                	li	s3,0
        i += 2;
 830:	b569                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 832:	008b8913          	addi	s2,s7,8
 836:	4681                	li	a3,0
 838:	4641                	li	a2,16
 83a:	000be583          	lwu	a1,0(s7)
 83e:	855a                	mv	a0,s6
 840:	d95ff0ef          	jal	5d4 <printint>
 844:	8bca                	mv	s7,s2
      state = 0;
 846:	4981                	li	s3,0
 848:	bd8d                	j	6ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 84a:	008b8913          	addi	s2,s7,8
 84e:	4681                	li	a3,0
 850:	4641                	li	a2,16
 852:	000bb583          	ld	a1,0(s7)
 856:	855a                	mv	a0,s6
 858:	d7dff0ef          	jal	5d4 <printint>
        i += 1;
 85c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 85e:	8bca                	mv	s7,s2
      state = 0;
 860:	4981                	li	s3,0
        i += 1;
 862:	bda1                	j	6ba <vprintf+0x4a>
 864:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 866:	008b8d13          	addi	s10,s7,8
 86a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 86e:	03000593          	li	a1,48
 872:	855a                	mv	a0,s6
 874:	d43ff0ef          	jal	5b6 <putc>
  putc(fd, 'x');
 878:	07800593          	li	a1,120
 87c:	855a                	mv	a0,s6
 87e:	d39ff0ef          	jal	5b6 <putc>
 882:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 884:	00000b97          	auipc	s7,0x0
 888:	47cb8b93          	addi	s7,s7,1148 # d00 <digits>
 88c:	03c9d793          	srli	a5,s3,0x3c
 890:	97de                	add	a5,a5,s7
 892:	0007c583          	lbu	a1,0(a5)
 896:	855a                	mv	a0,s6
 898:	d1fff0ef          	jal	5b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 89c:	0992                	slli	s3,s3,0x4
 89e:	397d                	addiw	s2,s2,-1
 8a0:	fe0916e3          	bnez	s2,88c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8a4:	8bea                	mv	s7,s10
      state = 0;
 8a6:	4981                	li	s3,0
 8a8:	6d02                	ld	s10,0(sp)
 8aa:	bd01                	j	6ba <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8ac:	008b8913          	addi	s2,s7,8
 8b0:	000bc583          	lbu	a1,0(s7)
 8b4:	855a                	mv	a0,s6
 8b6:	d01ff0ef          	jal	5b6 <putc>
 8ba:	8bca                	mv	s7,s2
      state = 0;
 8bc:	4981                	li	s3,0
 8be:	bbf5                	j	6ba <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 8c0:	008b8993          	addi	s3,s7,8
 8c4:	000bb903          	ld	s2,0(s7)
 8c8:	00090f63          	beqz	s2,8e6 <vprintf+0x276>
        for (; *s; s++)
 8cc:	00094583          	lbu	a1,0(s2)
 8d0:	c195                	beqz	a1,8f4 <vprintf+0x284>
          putc(fd, *s);
 8d2:	855a                	mv	a0,s6
 8d4:	ce3ff0ef          	jal	5b6 <putc>
        for (; *s; s++)
 8d8:	0905                	addi	s2,s2,1
 8da:	00094583          	lbu	a1,0(s2)
 8de:	f9f5                	bnez	a1,8d2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 8e0:	8bce                	mv	s7,s3
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	bbd9                	j	6ba <vprintf+0x4a>
          s = "(null)";
 8e6:	00000917          	auipc	s2,0x0
 8ea:	41290913          	addi	s2,s2,1042 # cf8 <malloc+0x306>
        for (; *s; s++)
 8ee:	02800593          	li	a1,40
 8f2:	b7c5                	j	8d2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 8f4:	8bce                	mv	s7,s3
      state = 0;
 8f6:	4981                	li	s3,0
 8f8:	b3c9                	j	6ba <vprintf+0x4a>
 8fa:	64a6                	ld	s1,72(sp)
 8fc:	79e2                	ld	s3,56(sp)
 8fe:	7a42                	ld	s4,48(sp)
 900:	7aa2                	ld	s5,40(sp)
 902:	7b02                	ld	s6,32(sp)
 904:	6be2                	ld	s7,24(sp)
 906:	6c42                	ld	s8,16(sp)
 908:	6ca2                	ld	s9,8(sp)
    }
  }
}
 90a:	60e6                	ld	ra,88(sp)
 90c:	6446                	ld	s0,80(sp)
 90e:	6906                	ld	s2,64(sp)
 910:	6125                	addi	sp,sp,96
 912:	8082                	ret

0000000000000914 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 914:	715d                	addi	sp,sp,-80
 916:	ec06                	sd	ra,24(sp)
 918:	e822                	sd	s0,16(sp)
 91a:	1000                	addi	s0,sp,32
 91c:	e010                	sd	a2,0(s0)
 91e:	e414                	sd	a3,8(s0)
 920:	e818                	sd	a4,16(s0)
 922:	ec1c                	sd	a5,24(s0)
 924:	03043023          	sd	a6,32(s0)
 928:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 92c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 930:	8622                	mv	a2,s0
 932:	d3fff0ef          	jal	670 <vprintf>
}
 936:	60e2                	ld	ra,24(sp)
 938:	6442                	ld	s0,16(sp)
 93a:	6161                	addi	sp,sp,80
 93c:	8082                	ret

000000000000093e <printf>:

void
printf(const char *fmt, ...)
{
 93e:	711d                	addi	sp,sp,-96
 940:	ec06                	sd	ra,24(sp)
 942:	e822                	sd	s0,16(sp)
 944:	1000                	addi	s0,sp,32
 946:	e40c                	sd	a1,8(s0)
 948:	e810                	sd	a2,16(s0)
 94a:	ec14                	sd	a3,24(s0)
 94c:	f018                	sd	a4,32(s0)
 94e:	f41c                	sd	a5,40(s0)
 950:	03043823          	sd	a6,48(s0)
 954:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 958:	00840613          	addi	a2,s0,8
 95c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 960:	85aa                	mv	a1,a0
 962:	4505                	li	a0,1
 964:	d0dff0ef          	jal	670 <vprintf>
}
 968:	60e2                	ld	ra,24(sp)
 96a:	6442                	ld	s0,16(sp)
 96c:	6125                	addi	sp,sp,96
 96e:	8082                	ret

0000000000000970 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 970:	1141                	addi	sp,sp,-16
 972:	e422                	sd	s0,8(sp)
 974:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 976:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97a:	00001797          	auipc	a5,0x1
 97e:	6867b783          	ld	a5,1670(a5) # 2000 <freep>
 982:	a02d                	j	9ac <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 984:	4618                	lw	a4,8(a2)
 986:	9f2d                	addw	a4,a4,a1
 988:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	6310                	ld	a2,0(a4)
 990:	a83d                	j	9ce <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 992:	ff852703          	lw	a4,-8(a0)
 996:	9f31                	addw	a4,a4,a2
 998:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 99a:	ff053683          	ld	a3,-16(a0)
 99e:	a091                	j	9e2 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a0:	6398                	ld	a4,0(a5)
 9a2:	00e7e463          	bltu	a5,a4,9aa <free+0x3a>
 9a6:	00e6ea63          	bltu	a3,a4,9ba <free+0x4a>
{
 9aa:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ac:	fed7fae3          	bgeu	a5,a3,9a0 <free+0x30>
 9b0:	6398                	ld	a4,0(a5)
 9b2:	00e6e463          	bltu	a3,a4,9ba <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b6:	fee7eae3          	bltu	a5,a4,9aa <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 9ba:	ff852583          	lw	a1,-8(a0)
 9be:	6390                	ld	a2,0(a5)
 9c0:	02059813          	slli	a6,a1,0x20
 9c4:	01c85713          	srli	a4,a6,0x1c
 9c8:	9736                	add	a4,a4,a3
 9ca:	fae60de3          	beq	a2,a4,984 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9ce:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 9d2:	4790                	lw	a2,8(a5)
 9d4:	02061593          	slli	a1,a2,0x20
 9d8:	01c5d713          	srli	a4,a1,0x1c
 9dc:	973e                	add	a4,a4,a5
 9de:	fae68ae3          	beq	a3,a4,992 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9e4:	00001717          	auipc	a4,0x1
 9e8:	60f73e23          	sd	a5,1564(a4) # 2000 <freep>
}
 9ec:	6422                	ld	s0,8(sp)
 9ee:	0141                	addi	sp,sp,16
 9f0:	8082                	ret

00000000000009f2 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 9f2:	7139                	addi	sp,sp,-64
 9f4:	fc06                	sd	ra,56(sp)
 9f6:	f822                	sd	s0,48(sp)
 9f8:	f426                	sd	s1,40(sp)
 9fa:	ec4e                	sd	s3,24(sp)
 9fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9fe:	02051493          	slli	s1,a0,0x20
 a02:	9081                	srli	s1,s1,0x20
 a04:	04bd                	addi	s1,s1,15
 a06:	8091                	srli	s1,s1,0x4
 a08:	0014899b          	addiw	s3,s1,1
 a0c:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 a0e:	00001517          	auipc	a0,0x1
 a12:	5f253503          	ld	a0,1522(a0) # 2000 <freep>
 a16:	c915                	beqz	a0,a4a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a18:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a1a:	4798                	lw	a4,8(a5)
 a1c:	08977a63          	bgeu	a4,s1,ab0 <malloc+0xbe>
 a20:	f04a                	sd	s2,32(sp)
 a22:	e852                	sd	s4,16(sp)
 a24:	e456                	sd	s5,8(sp)
 a26:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 a28:	8a4e                	mv	s4,s3
 a2a:	0009871b          	sext.w	a4,s3
 a2e:	6685                	lui	a3,0x1
 a30:	00d77363          	bgeu	a4,a3,a36 <malloc+0x44>
 a34:	6a05                	lui	s4,0x1
 a36:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a3a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a3e:	00001917          	auipc	s2,0x1
 a42:	5c290913          	addi	s2,s2,1474 # 2000 <freep>
  if (p == SBRK_ERROR)
 a46:	5afd                	li	s5,-1
 a48:	a081                	j	a88 <malloc+0x96>
 a4a:	f04a                	sd	s2,32(sp)
 a4c:	e852                	sd	s4,16(sp)
 a4e:	e456                	sd	s5,8(sp)
 a50:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a52:	00001797          	auipc	a5,0x1
 a56:	5be78793          	addi	a5,a5,1470 # 2010 <base>
 a5a:	00001717          	auipc	a4,0x1
 a5e:	5af73323          	sd	a5,1446(a4) # 2000 <freep>
 a62:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a64:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a68:	b7c1                	j	a28 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a6a:	6398                	ld	a4,0(a5)
 a6c:	e118                	sd	a4,0(a0)
 a6e:	a8a9                	j	ac8 <malloc+0xd6>
  hp->s.size = nu;
 a70:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a74:	0541                	addi	a0,a0,16
 a76:	efbff0ef          	jal	970 <free>
  return freep;
 a7a:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 a7e:	c12d                	beqz	a0,ae0 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a80:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a82:	4798                	lw	a4,8(a5)
 a84:	02977263          	bgeu	a4,s1,aa8 <malloc+0xb6>
    if (p == freep)
 a88:	00093703          	ld	a4,0(s2)
 a8c:	853e                	mv	a0,a5
 a8e:	fef719e3          	bne	a4,a5,a80 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a92:	8552                	mv	a0,s4
 a94:	a27ff0ef          	jal	4ba <sbrk>
  if (p == SBRK_ERROR)
 a98:	fd551ce3          	bne	a0,s5,a70 <malloc+0x7e>
        return 0;
 a9c:	4501                	li	a0,0
 a9e:	7902                	ld	s2,32(sp)
 aa0:	6a42                	ld	s4,16(sp)
 aa2:	6aa2                	ld	s5,8(sp)
 aa4:	6b02                	ld	s6,0(sp)
 aa6:	a03d                	j	ad4 <malloc+0xe2>
 aa8:	7902                	ld	s2,32(sp)
 aaa:	6a42                	ld	s4,16(sp)
 aac:	6aa2                	ld	s5,8(sp)
 aae:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 ab0:	fae48de3          	beq	s1,a4,a6a <malloc+0x78>
        p->s.size -= nunits;
 ab4:	4137073b          	subw	a4,a4,s3
 ab8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 aba:	02071693          	slli	a3,a4,0x20
 abe:	01c6d713          	srli	a4,a3,0x1c
 ac2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ac4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ac8:	00001717          	auipc	a4,0x1
 acc:	52a73c23          	sd	a0,1336(a4) # 2000 <freep>
      return (void *)(p + 1);
 ad0:	01078513          	addi	a0,a5,16
  }
}
 ad4:	70e2                	ld	ra,56(sp)
 ad6:	7442                	ld	s0,48(sp)
 ad8:	74a2                	ld	s1,40(sp)
 ada:	69e2                	ld	s3,24(sp)
 adc:	6121                	addi	sp,sp,64
 ade:	8082                	ret
 ae0:	7902                	ld	s2,32(sp)
 ae2:	6a42                	ld	s4,16(sp)
 ae4:	6aa2                	ld	s5,8(sp)
 ae6:	6b02                	ld	s6,0(sp)
 ae8:	b7f5                	j	ad4 <malloc+0xe2>
