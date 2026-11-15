
user/_pinfotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find_proc>:

struct pinfo buf[64];

int
find_proc(struct pinfo *buf, int n, int pid)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  for (int i = 0; i < n; i++) {
   6:	02b05063          	blez	a1,26 <find_proc+0x26>
   a:	87aa                	mv	a5,a0
   c:	4501                	li	a0,0
    if (buf[i].pid == pid) {
   e:	4398                	lw	a4,0(a5)
  10:	00c70863          	beq	a4,a2,20 <find_proc+0x20>
  for (int i = 0; i < n; i++) {
  14:	2505                	addiw	a0,a0,1
  16:	02878793          	addi	a5,a5,40
  1a:	fea59ae3          	bne	a1,a0,e <find_proc+0xe>
      return i;
    }
  }
  return -1;
  1e:	557d                	li	a0,-1
}
  20:	6422                	ld	s0,8(sp)
  22:	0141                	addi	sp,sp,16
  24:	8082                	ret
  return -1;
  26:	557d                	li	a0,-1
  28:	bfe5                	j	20 <find_proc+0x20>

000000000000002a <main>:

int
main(int argc, char *argv[])
{
  2a:	81010113          	addi	sp,sp,-2032
  2e:	7e113423          	sd	ra,2024(sp)
  32:	7e813023          	sd	s0,2016(sp)
  36:	7c913c23          	sd	s1,2008(sp)
  3a:	7d213823          	sd	s2,2000(sp)
  3e:	7d313423          	sd	s3,1992(sp)
  42:	7d413023          	sd	s4,1984(sp)
  46:	7f010413          	addi	s0,sp,2032
  4a:	da010113          	addi	sp,sp,-608
  int mypid = getpid();
  4e:	4f4000ef          	jal	542 <getpid>
  52:	84aa                	mv	s1,a0

  printf("pinfotest: starting...\n");
  54:	00001517          	auipc	a0,0x1
  58:	a6c50513          	addi	a0,a0,-1428 # ac0 <malloc+0xfa>
  5c:	0b7000ef          	jal	912 <printf>

  int n1 = getpinfo(buf, 64);
  60:	04000593          	li	a1,64
  64:	00002517          	auipc	a0,0x2
  68:	fac50513          	addi	a0,a0,-84 # 2010 <buf>
  6c:	4fe000ef          	jal	56a <getpinfo>
  if (n1 < 0) {
  70:	0c054363          	bltz	a0,136 <main+0x10c>
  74:	85aa                	mv	a1,a0
    printf("FAIL: getpinfo returned -1\n");
    exit(1);
  }

  int idx1 = find_proc(buf, n1, mypid);
  76:	8626                	mv	a2,s1
  78:	00002517          	auipc	a0,0x2
  7c:	f9850513          	addi	a0,a0,-104 # 2010 <buf>
  80:	f81ff0ef          	jal	0 <find_proc>
  if (idx1 < 0) {
  84:	0c054263          	bltz	a0,148 <main+0x11e>
    printf("FAIL: current process not found in pinfo\n");
    exit(1);
  }

  int start_ticks = buf[idx1].runticks;
  88:	02800793          	li	a5,40
  8c:	02f50533          	mul	a0,a0,a5
  90:	00002797          	auipc	a5,0x2
  94:	f8078793          	addi	a5,a5,-128 # 2010 <buf>
  98:	97aa                	add	a5,a5,a0
  9a:	00c7a903          	lw	s2,12(a5)
  int start_nsched = buf[idx1].nsched;
  9e:	0107a983          	lw	s3,16(a5)
  printf("Initial -> pid: %d, runticks: %d, nsched: %d, ctime: %d\n",
  a2:	4bd8                	lw	a4,20(a5)
  a4:	86ce                	mv	a3,s3
  a6:	864a                	mv	a2,s2
  a8:	85a6                	mv	a1,s1
  aa:	00001517          	auipc	a0,0x1
  ae:	a7e50513          	addi	a0,a0,-1410 # b28 <malloc+0x162>
  b2:	061000ef          	jal	912 <printf>
         mypid, start_ticks, start_nsched, buf[idx1].ctime);

  // Spin on the CPU to accumulate timer ticks and scheduler switches
  volatile int x = 0;
  b6:	fc042623          	sw	zero,-52(s0)
  for (int i = 0; i < 50000000; i++) {
  ba:	4781                	li	a5,0
  bc:	02faf6b7          	lui	a3,0x2faf
  c0:	08068693          	addi	a3,a3,128 # 2faf080 <base+0x2fac670>
    x += i;
  c4:	fcc42703          	lw	a4,-52(s0)
  c8:	9f3d                	addw	a4,a4,a5
  ca:	fce42623          	sw	a4,-52(s0)
  for (int i = 0; i < 50000000; i++) {
  ce:	2785                	addiw	a5,a5,1
  d0:	fed79ae3          	bne	a5,a3,c4 <main+0x9a>
  }

  int n2 = getpinfo(buf, 64);
  d4:	04000593          	li	a1,64
  d8:	00002517          	auipc	a0,0x2
  dc:	f3850513          	addi	a0,a0,-200 # 2010 <buf>
  e0:	48a000ef          	jal	56a <getpinfo>
  e4:	85aa                	mv	a1,a0
  int idx2 = find_proc(buf, n2, mypid);
  e6:	8626                	mv	a2,s1
  e8:	00002517          	auipc	a0,0x2
  ec:	f2850513          	addi	a0,a0,-216 # 2010 <buf>
  f0:	f11ff0ef          	jal	0 <find_proc>
  int end_ticks = buf[idx2].runticks;
  f4:	02800793          	li	a5,40
  f8:	02f50733          	mul	a4,a0,a5
  fc:	00002797          	auipc	a5,0x2
 100:	f1478793          	addi	a5,a5,-236 # 2010 <buf>
 104:	97ba                	add	a5,a5,a4
 106:	47c4                	lw	s1,12(a5)
  int end_nsched = buf[idx2].nsched;
 108:	0107aa03          	lw	s4,16(a5)

  printf("After spin -> runticks: %d, nsched: %d\n", end_ticks, end_nsched);
 10c:	8652                	mv	a2,s4
 10e:	85a6                	mv	a1,s1
 110:	00001517          	auipc	a0,0x1
 114:	a5850513          	addi	a0,a0,-1448 # b68 <malloc+0x1a2>
 118:	7fa000ef          	jal	912 <printf>

  if (end_ticks <= start_ticks) {
 11c:	02995f63          	bge	s2,s1,15a <main+0x130>
    printf("FAIL: runticks did not increase during CPU spin\n");
    exit(1);
  }
  if (end_nsched <= start_nsched) {
 120:	0549c663          	blt	s3,s4,16c <main+0x142>
    printf("FAIL: nsched did not increase\n");
 124:	00001517          	auipc	a0,0x1
 128:	aa450513          	addi	a0,a0,-1372 # bc8 <malloc+0x202>
 12c:	7e6000ef          	jal	912 <printf>
    exit(1);
 130:	4505                	li	a0,1
 132:	390000ef          	jal	4c2 <exit>
    printf("FAIL: getpinfo returned -1\n");
 136:	00001517          	auipc	a0,0x1
 13a:	9a250513          	addi	a0,a0,-1630 # ad8 <malloc+0x112>
 13e:	7d4000ef          	jal	912 <printf>
    exit(1);
 142:	4505                	li	a0,1
 144:	37e000ef          	jal	4c2 <exit>
    printf("FAIL: current process not found in pinfo\n");
 148:	00001517          	auipc	a0,0x1
 14c:	9b050513          	addi	a0,a0,-1616 # af8 <malloc+0x132>
 150:	7c2000ef          	jal	912 <printf>
    exit(1);
 154:	4505                	li	a0,1
 156:	36c000ef          	jal	4c2 <exit>
    printf("FAIL: runticks did not increase during CPU spin\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	a3650513          	addi	a0,a0,-1482 # b90 <malloc+0x1ca>
 162:	7b0000ef          	jal	912 <printf>
    exit(1);
 166:	4505                	li	a0,1
 168:	35a000ef          	jal	4c2 <exit>
  }

  // Test that a child starts with fresh counters and does not inherit parent's
  int pid = fork();
 16c:	34e000ef          	jal	4ba <fork>
  if (pid < 0) {
 170:	08054763          	bltz	a0,1fe <main+0x1d4>
    printf("FAIL: fork failed\n");
    exit(1);
  }

  if (pid == 0) {
 174:	e14d                	bnez	a0,216 <main+0x1ec>
    struct pinfo cbuf[64];
    int cn = getpinfo(cbuf, 64);
 176:	77fd                	lui	a5,0xfffff
 178:	5c878793          	addi	a5,a5,1480 # fffffffffffff5c8 <base+0xffffffffffffcbb8>
 17c:	97a2                	add	a5,a5,s0
 17e:	79fd                	lui	s3,0xfffff
 180:	5b898713          	addi	a4,s3,1464 # fffffffffffff5b8 <base+0xffffffffffffcba8>
 184:	9722                	add	a4,a4,s0
 186:	e31c                	sd	a5,0(a4)
 188:	04000593          	li	a1,64
 18c:	6308                	ld	a0,0(a4)
 18e:	3dc000ef          	jal	56a <getpinfo>
 192:	892a                	mv	s2,a0
    int cidx = find_proc(cbuf, cn, getpid());
 194:	3ae000ef          	jal	542 <getpid>
 198:	862a                	mv	a2,a0
 19a:	85ca                	mv	a1,s2
 19c:	5b898793          	addi	a5,s3,1464
 1a0:	97a2                	add	a5,a5,s0
 1a2:	6388                	ld	a0,0(a5)
 1a4:	e5dff0ef          	jal	0 <find_proc>
 1a8:	892a                	mv	s2,a0
    printf("Child -> pid: %d, runticks: %d, nsched: %d, level: %d\n",
 1aa:	398000ef          	jal	542 <getpid>
 1ae:	85aa                	mv	a1,a0
 1b0:	77fd                	lui	a5,0xfffff
 1b2:	02800713          	li	a4,40
 1b6:	02e90933          	mul	s2,s2,a4
 1ba:	fd078793          	addi	a5,a5,-48 # ffffffffffffefd0 <base+0xffffffffffffc5c0>
 1be:	97a2                	add	a5,a5,s0
 1c0:	5b898713          	addi	a4,s3,1464
 1c4:	9722                	add	a4,a4,s0
 1c6:	e31c                	sd	a5,0(a4)
 1c8:	631c                	ld	a5,0(a4)
 1ca:	993e                	add	s2,s2,a5
 1cc:	60092703          	lw	a4,1536(s2)
 1d0:	60892683          	lw	a3,1544(s2)
 1d4:	60492603          	lw	a2,1540(s2)
 1d8:	00001517          	auipc	a0,0x1
 1dc:	a2850513          	addi	a0,a0,-1496 # c00 <malloc+0x23a>
 1e0:	732000ef          	jal	912 <printf>
           getpid(), cbuf[cidx].runticks, cbuf[cidx].nsched, cbuf[cidx].level);

    if (cbuf[cidx].runticks >= end_ticks) {
 1e4:	60492783          	lw	a5,1540(s2)
 1e8:	0297c463          	blt	a5,s1,210 <main+0x1e6>
      printf("FAIL: child inherited parent runticks\n");
 1ec:	00001517          	auipc	a0,0x1
 1f0:	a4c50513          	addi	a0,a0,-1460 # c38 <malloc+0x272>
 1f4:	71e000ef          	jal	912 <printf>
      exit(1);
 1f8:	4505                	li	a0,1
 1fa:	2c8000ef          	jal	4c2 <exit>
    printf("FAIL: fork failed\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	9ea50513          	addi	a0,a0,-1558 # be8 <malloc+0x222>
 206:	70c000ef          	jal	912 <printf>
    exit(1);
 20a:	4505                	li	a0,1
 20c:	2b6000ef          	jal	4c2 <exit>
    }
    exit(0);
 210:	4501                	li	a0,0
 212:	2b0000ef          	jal	4c2 <exit>
  }

  wait(0);
 216:	4501                	li	a0,0
 218:	2b2000ef          	jal	4ca <wait>
  printf("pinfotest: ALL CHECKS PASSED\n");
 21c:	00001517          	auipc	a0,0x1
 220:	a4450513          	addi	a0,a0,-1468 # c60 <malloc+0x29a>
 224:	6ee000ef          	jal	912 <printf>
  exit(0);
 228:	4501                	li	a0,0
 22a:	298000ef          	jal	4c2 <exit>

000000000000022e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e406                	sd	ra,8(sp)
 232:	e022                	sd	s0,0(sp)
 234:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 236:	df5ff0ef          	jal	2a <main>
  exit(r);
 23a:	288000ef          	jal	4c2 <exit>

000000000000023e <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 244:	87aa                	mv	a5,a0
 246:	0585                	addi	a1,a1,1
 248:	0785                	addi	a5,a5,1
 24a:	fff5c703          	lbu	a4,-1(a1)
 24e:	fee78fa3          	sb	a4,-1(a5)
 252:	fb75                	bnez	a4,246 <strcpy+0x8>
    ;
  return os;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	cb91                	beqz	a5,278 <strcmp+0x1e>
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00f71763          	bne	a4,a5,278 <strcmp+0x1e>
    p++, q++;
 26e:	0505                	addi	a0,a0,1
 270:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 272:	00054783          	lbu	a5,0(a0)
 276:	fbe5                	bnez	a5,266 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 278:	0005c503          	lbu	a0,0(a1)
}
 27c:	40a7853b          	subw	a0,a5,a0
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strlen>:

uint
strlen(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cf91                	beqz	a5,2ac <strlen+0x26>
 292:	0505                	addi	a0,a0,1
 294:	87aa                	mv	a5,a0
 296:	86be                	mv	a3,a5
 298:	0785                	addi	a5,a5,1
 29a:	fff7c703          	lbu	a4,-1(a5)
 29e:	ff65                	bnez	a4,296 <strlen+0x10>
 2a0:	40a6853b          	subw	a0,a3,a0
 2a4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  for (n = 0; s[n]; n++)
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strlen+0x20>

00000000000002b0 <memset>:

void *
memset(void *dst, int c, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 2b6:	ca19                	beqz	a2,2cc <memset+0x1c>
 2b8:	87aa                	mv	a5,a0
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2c2:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 2c6:	0785                	addi	a5,a5,1
 2c8:	fee79de3          	bne	a5,a4,2c2 <memset+0x12>
  }
  return dst;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strchr>:

char *
strchr(const char *s, char c)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  for (; *s; s++)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	cb99                	beqz	a5,2f2 <strchr+0x20>
    if (*s == c)
 2de:	00f58763          	beq	a1,a5,2ec <strchr+0x1a>
  for (; *s; s++)
 2e2:	0505                	addi	a0,a0,1
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	fbfd                	bnez	a5,2de <strchr+0xc>
      return (char *)s;
  return 0;
 2ea:	4501                	li	a0,0
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <strchr+0x1a>

00000000000002f6 <gets>:

char *
gets(char *buf, int max)
{
 2f6:	711d                	addi	sp,sp,-96
 2f8:	ec86                	sd	ra,88(sp)
 2fa:	e8a2                	sd	s0,80(sp)
 2fc:	e4a6                	sd	s1,72(sp)
 2fe:	e0ca                	sd	s2,64(sp)
 300:	fc4e                	sd	s3,56(sp)
 302:	f852                	sd	s4,48(sp)
 304:	f456                	sd	s5,40(sp)
 306:	f05a                	sd	s6,32(sp)
 308:	ec5e                	sd	s7,24(sp)
 30a:	1080                	addi	s0,sp,96
 30c:	8baa                	mv	s7,a0
 30e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 310:	892a                	mv	s2,a0
 312:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 314:	4aa9                	li	s5,10
 316:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 318:	89a6                	mv	s3,s1
 31a:	2485                	addiw	s1,s1,1
 31c:	0344d663          	bge	s1,s4,348 <gets+0x52>
    cc = read(0, &c, 1);
 320:	4605                	li	a2,1
 322:	faf40593          	addi	a1,s0,-81
 326:	4501                	li	a0,0
 328:	1b2000ef          	jal	4da <read>
    if (cc < 1)
 32c:	00a05e63          	blez	a0,348 <gets+0x52>
    buf[i++] = c;
 330:	faf44783          	lbu	a5,-81(s0)
 334:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 338:	01578763          	beq	a5,s5,346 <gets+0x50>
 33c:	0905                	addi	s2,s2,1
 33e:	fd679de3          	bne	a5,s6,318 <gets+0x22>
    buf[i++] = c;
 342:	89a6                	mv	s3,s1
 344:	a011                	j	348 <gets+0x52>
 346:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 348:	99de                	add	s3,s3,s7
 34a:	00098023          	sb	zero,0(s3)
  return buf;
}
 34e:	855e                	mv	a0,s7
 350:	60e6                	ld	ra,88(sp)
 352:	6446                	ld	s0,80(sp)
 354:	64a6                	ld	s1,72(sp)
 356:	6906                	ld	s2,64(sp)
 358:	79e2                	ld	s3,56(sp)
 35a:	7a42                	ld	s4,48(sp)
 35c:	7aa2                	ld	s5,40(sp)
 35e:	7b02                	ld	s6,32(sp)
 360:	6be2                	ld	s7,24(sp)
 362:	6125                	addi	sp,sp,96
 364:	8082                	ret

0000000000000366 <stat>:

int
stat(const char *n, struct stat *st)
{
 366:	1101                	addi	sp,sp,-32
 368:	ec06                	sd	ra,24(sp)
 36a:	e822                	sd	s0,16(sp)
 36c:	e04a                	sd	s2,0(sp)
 36e:	1000                	addi	s0,sp,32
 370:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 372:	4581                	li	a1,0
 374:	18e000ef          	jal	502 <open>
  if (fd < 0)
 378:	02054263          	bltz	a0,39c <stat+0x36>
 37c:	e426                	sd	s1,8(sp)
 37e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 380:	85ca                	mv	a1,s2
 382:	198000ef          	jal	51a <fstat>
 386:	892a                	mv	s2,a0
  close(fd);
 388:	8526                	mv	a0,s1
 38a:	160000ef          	jal	4ea <close>
  return r;
 38e:	64a2                	ld	s1,8(sp)
}
 390:	854a                	mv	a0,s2
 392:	60e2                	ld	ra,24(sp)
 394:	6442                	ld	s0,16(sp)
 396:	6902                	ld	s2,0(sp)
 398:	6105                	addi	sp,sp,32
 39a:	8082                	ret
    return -1;
 39c:	597d                	li	s2,-1
 39e:	bfcd                	j	390 <stat+0x2a>

00000000000003a0 <atoi>:

int
atoi(const char *s)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e422                	sd	s0,8(sp)
 3a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 3a6:	00054683          	lbu	a3,0(a0)
 3aa:	fd06879b          	addiw	a5,a3,-48
 3ae:	0ff7f793          	zext.b	a5,a5
 3b2:	4625                	li	a2,9
 3b4:	02f66863          	bltu	a2,a5,3e4 <atoi+0x44>
 3b8:	872a                	mv	a4,a0
  n = 0;
 3ba:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 3bc:	0705                	addi	a4,a4,1
 3be:	0025179b          	slliw	a5,a0,0x2
 3c2:	9fa9                	addw	a5,a5,a0
 3c4:	0017979b          	slliw	a5,a5,0x1
 3c8:	9fb5                	addw	a5,a5,a3
 3ca:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 3ce:	00074683          	lbu	a3,0(a4)
 3d2:	fd06879b          	addiw	a5,a3,-48
 3d6:	0ff7f793          	zext.b	a5,a5
 3da:	fef671e3          	bgeu	a2,a5,3bc <atoi+0x1c>
  return n;
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  n = 0;
 3e4:	4501                	li	a0,0
 3e6:	bfe5                	j	3de <atoi+0x3e>

00000000000003e8 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e422                	sd	s0,8(sp)
 3ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ee:	02b57463          	bgeu	a0,a1,416 <memmove+0x2e>
    while (n-- > 0)
 3f2:	00c05f63          	blez	a2,410 <memmove+0x28>
 3f6:	1602                	slli	a2,a2,0x20
 3f8:	9201                	srli	a2,a2,0x20
 3fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 400:	0585                	addi	a1,a1,1
 402:	0705                	addi	a4,a4,1
 404:	fff5c683          	lbu	a3,-1(a1)
 408:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 40c:	fef71ae3          	bne	a4,a5,400 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 410:	6422                	ld	s0,8(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret
    dst += n;
 416:	00c50733          	add	a4,a0,a2
    src += n;
 41a:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 41c:	fec05ae3          	blez	a2,410 <memmove+0x28>
 420:	fff6079b          	addiw	a5,a2,-1
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	fff7c793          	not	a5,a5
 42c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 42e:	15fd                	addi	a1,a1,-1
 430:	177d                	addi	a4,a4,-1
 432:	0005c683          	lbu	a3,0(a1)
 436:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 43a:	fee79ae3          	bne	a5,a4,42e <memmove+0x46>
 43e:	bfc9                	j	410 <memmove+0x28>

0000000000000440 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e422                	sd	s0,8(sp)
 444:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 446:	ca05                	beqz	a2,476 <memcmp+0x36>
 448:	fff6069b          	addiw	a3,a2,-1
 44c:	1682                	slli	a3,a3,0x20
 44e:	9281                	srli	a3,a3,0x20
 450:	0685                	addi	a3,a3,1
 452:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 454:	00054783          	lbu	a5,0(a0)
 458:	0005c703          	lbu	a4,0(a1)
 45c:	00e79863          	bne	a5,a4,46c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 460:	0505                	addi	a0,a0,1
    p2++;
 462:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 464:	fed518e3          	bne	a0,a3,454 <memcmp+0x14>
  }
  return 0;
 468:	4501                	li	a0,0
 46a:	a019                	j	470 <memcmp+0x30>
      return *p1 - *p2;
 46c:	40e7853b          	subw	a0,a5,a4
}
 470:	6422                	ld	s0,8(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret
  return 0;
 476:	4501                	li	a0,0
 478:	bfe5                	j	470 <memcmp+0x30>

000000000000047a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 47a:	1141                	addi	sp,sp,-16
 47c:	e406                	sd	ra,8(sp)
 47e:	e022                	sd	s0,0(sp)
 480:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 482:	f67ff0ef          	jal	3e8 <memmove>
}
 486:	60a2                	ld	ra,8(sp)
 488:	6402                	ld	s0,0(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret

000000000000048e <sbrk>:

char *
sbrk(int n)
{
 48e:	1141                	addi	sp,sp,-16
 490:	e406                	sd	ra,8(sp)
 492:	e022                	sd	s0,0(sp)
 494:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 496:	4585                	li	a1,1
 498:	0b2000ef          	jal	54a <sys_sbrk>
}
 49c:	60a2                	ld	ra,8(sp)
 49e:	6402                	ld	s0,0(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret

00000000000004a4 <sbrklazy>:

char *
sbrklazy(int n)
{
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e406                	sd	ra,8(sp)
 4a8:	e022                	sd	s0,0(sp)
 4aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ac:	4589                	li	a1,2
 4ae:	09c000ef          	jal	54a <sys_sbrk>
}
 4b2:	60a2                	ld	ra,8(sp)
 4b4:	6402                	ld	s0,0(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret

00000000000004ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4ba:	4885                	li	a7,1
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c2:	4889                	li	a7,2
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ca:	488d                	li	a7,3
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d2:	4891                	li	a7,4
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <read>:
.global read
read:
 li a7, SYS_read
 4da:	4895                	li	a7,5
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <write>:
.global write
write:
 li a7, SYS_write
 4e2:	48c1                	li	a7,16
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <close>:
.global close
close:
 li a7, SYS_close
 4ea:	48d5                	li	a7,21
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f2:	4899                	li	a7,6
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fa:	489d                	li	a7,7
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <open>:
.global open
open:
 li a7, SYS_open
 502:	48bd                	li	a7,15
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50a:	48c5                	li	a7,17
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 512:	48c9                	li	a7,18
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51a:	48a1                	li	a7,8
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <link>:
.global link
link:
 li a7, SYS_link
 522:	48cd                	li	a7,19
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52a:	48d1                	li	a7,20
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 532:	48a5                	li	a7,9
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <dup>:
.global dup
dup:
 li a7, SYS_dup
 53a:	48a9                	li	a7,10
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 542:	48ad                	li	a7,11
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 54a:	48b1                	li	a7,12
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <pause>:
.global pause
pause:
 li a7, SYS_pause
 552:	48b5                	li	a7,13
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55a:	48b9                	li	a7,14
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <sync>:
.global sync
sync:
 li a7, SYS_sync
 562:	48d9                	li	a7,22
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 56a:	48dd                	li	a7,23
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <trace>:
.global trace
trace:
 li a7, SYS_trace
 572:	48e1                	li	a7,24
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 57a:	48e5                	li	a7,25
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 582:	48e9                	li	a7,26
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 58a:	1101                	addi	sp,sp,-32
 58c:	ec06                	sd	ra,24(sp)
 58e:	e822                	sd	s0,16(sp)
 590:	1000                	addi	s0,sp,32
 592:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 596:	4605                	li	a2,1
 598:	fef40593          	addi	a1,s0,-17
 59c:	f47ff0ef          	jal	4e2 <write>
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	6105                	addi	sp,sp,32
 5a6:	8082                	ret

00000000000005a8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5a8:	715d                	addi	sp,sp,-80
 5aa:	e486                	sd	ra,72(sp)
 5ac:	e0a2                	sd	s0,64(sp)
 5ae:	f84a                	sd	s2,48(sp)
 5b0:	0880                	addi	s0,sp,80
 5b2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 5b4:	c299                	beqz	a3,5ba <printint+0x12>
 5b6:	0805c363          	bltz	a1,63c <printint+0x94>
  neg = 0;
 5ba:	4881                	li	a7,0
 5bc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5c0:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 5c2:	00000517          	auipc	a0,0x0
 5c6:	6c650513          	addi	a0,a0,1734 # c88 <digits>
 5ca:	883e                	mv	a6,a5
 5cc:	2785                	addiw	a5,a5,1
 5ce:	02c5f733          	remu	a4,a1,a2
 5d2:	972a                	add	a4,a4,a0
 5d4:	00074703          	lbu	a4,0(a4)
 5d8:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 5dc:	872e                	mv	a4,a1
 5de:	02c5d5b3          	divu	a1,a1,a2
 5e2:	0685                	addi	a3,a3,1
 5e4:	fec773e3          	bgeu	a4,a2,5ca <printint+0x22>
  if (neg)
 5e8:	00088b63          	beqz	a7,5fe <printint+0x56>
    buf[i++] = '-';
 5ec:	fd078793          	addi	a5,a5,-48
 5f0:	97a2                	add	a5,a5,s0
 5f2:	02d00713          	li	a4,45
 5f6:	fee78423          	sb	a4,-24(a5)
 5fa:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 5fe:	02f05a63          	blez	a5,632 <printint+0x8a>
 602:	fc26                	sd	s1,56(sp)
 604:	f44e                	sd	s3,40(sp)
 606:	fb840713          	addi	a4,s0,-72
 60a:	00f704b3          	add	s1,a4,a5
 60e:	fff70993          	addi	s3,a4,-1
 612:	99be                	add	s3,s3,a5
 614:	37fd                	addiw	a5,a5,-1
 616:	1782                	slli	a5,a5,0x20
 618:	9381                	srli	a5,a5,0x20
 61a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 61e:	fff4c583          	lbu	a1,-1(s1)
 622:	854a                	mv	a0,s2
 624:	f67ff0ef          	jal	58a <putc>
  while (--i >= 0)
 628:	14fd                	addi	s1,s1,-1
 62a:	ff349ae3          	bne	s1,s3,61e <printint+0x76>
 62e:	74e2                	ld	s1,56(sp)
 630:	79a2                	ld	s3,40(sp)
}
 632:	60a6                	ld	ra,72(sp)
 634:	6406                	ld	s0,64(sp)
 636:	7942                	ld	s2,48(sp)
 638:	6161                	addi	sp,sp,80
 63a:	8082                	ret
    x = -xx;
 63c:	40b005b3          	neg	a1,a1
    neg = 1;
 640:	4885                	li	a7,1
    x = -xx;
 642:	bfad                	j	5bc <printint+0x14>

0000000000000644 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 644:	711d                	addi	sp,sp,-96
 646:	ec86                	sd	ra,88(sp)
 648:	e8a2                	sd	s0,80(sp)
 64a:	e0ca                	sd	s2,64(sp)
 64c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 64e:	0005c903          	lbu	s2,0(a1)
 652:	28090663          	beqz	s2,8de <vprintf+0x29a>
 656:	e4a6                	sd	s1,72(sp)
 658:	fc4e                	sd	s3,56(sp)
 65a:	f852                	sd	s4,48(sp)
 65c:	f456                	sd	s5,40(sp)
 65e:	f05a                	sd	s6,32(sp)
 660:	ec5e                	sd	s7,24(sp)
 662:	e862                	sd	s8,16(sp)
 664:	e466                	sd	s9,8(sp)
 666:	8b2a                	mv	s6,a0
 668:	8a2e                	mv	s4,a1
 66a:	8bb2                	mv	s7,a2
  state = 0;
 66c:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 66e:	4481                	li	s1,0
 670:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 672:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 676:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 67a:	06c00c93          	li	s9,108
 67e:	a005                	j	69e <vprintf+0x5a>
        putc(fd, c0);
 680:	85ca                	mv	a1,s2
 682:	855a                	mv	a0,s6
 684:	f07ff0ef          	jal	58a <putc>
 688:	a019                	j	68e <vprintf+0x4a>
    } else if (state == '%') {
 68a:	03598263          	beq	s3,s5,6ae <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 68e:	2485                	addiw	s1,s1,1
 690:	8726                	mv	a4,s1
 692:	009a07b3          	add	a5,s4,s1
 696:	0007c903          	lbu	s2,0(a5)
 69a:	22090a63          	beqz	s2,8ce <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 69e:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 6a2:	fe0994e3          	bnez	s3,68a <vprintf+0x46>
      if (c0 == '%') {
 6a6:	fd579de3          	bne	a5,s5,680 <vprintf+0x3c>
        state = '%';
 6aa:	89be                	mv	s3,a5
 6ac:	b7cd                	j	68e <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 6ae:	00ea06b3          	add	a3,s4,a4
 6b2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6b6:	8636                	mv	a2,a3
      if (c1)
 6b8:	c681                	beqz	a3,6c0 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 6ba:	9752                	add	a4,a4,s4
 6bc:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 6c0:	05878363          	beq	a5,s8,706 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 6c4:	05978d63          	beq	a5,s9,71e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 6c8:	07500713          	li	a4,117
 6cc:	0ee78763          	beq	a5,a4,7ba <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 6d0:	07800713          	li	a4,120
 6d4:	12e78963          	beq	a5,a4,806 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 6d8:	07000713          	li	a4,112
 6dc:	14e78e63          	beq	a5,a4,838 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 6e0:	06300713          	li	a4,99
 6e4:	18e78e63          	beq	a5,a4,880 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 6e8:	07300713          	li	a4,115
 6ec:	1ae78463          	beq	a5,a4,894 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 6f0:	02500713          	li	a4,37
 6f4:	04e79563          	bne	a5,a4,73e <vprintf+0xfa>
        putc(fd, '%');
 6f8:	02500593          	li	a1,37
 6fc:	855a                	mv	a0,s6
 6fe:	e8dff0ef          	jal	58a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 702:	4981                	li	s3,0
 704:	b769                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 706:	008b8913          	addi	s2,s7,8
 70a:	4685                	li	a3,1
 70c:	4629                	li	a2,10
 70e:	000ba583          	lw	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	e95ff0ef          	jal	5a8 <printint>
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bf8d                	j	68e <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 71e:	06400793          	li	a5,100
 722:	02f68963          	beq	a3,a5,754 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 726:	06c00793          	li	a5,108
 72a:	04f68263          	beq	a3,a5,76e <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 72e:	07500793          	li	a5,117
 732:	0af68063          	beq	a3,a5,7d2 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 736:	07800793          	li	a5,120
 73a:	0ef68263          	beq	a3,a5,81e <vprintf+0x1da>
        putc(fd, '%');
 73e:	02500593          	li	a1,37
 742:	855a                	mv	a0,s6
 744:	e47ff0ef          	jal	58a <putc>
        putc(fd, c0);
 748:	85ca                	mv	a1,s2
 74a:	855a                	mv	a0,s6
 74c:	e3fff0ef          	jal	58a <putc>
      state = 0;
 750:	4981                	li	s3,0
 752:	bf35                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 754:	008b8913          	addi	s2,s7,8
 758:	4685                	li	a3,1
 75a:	4629                	li	a2,10
 75c:	000bb583          	ld	a1,0(s7)
 760:	855a                	mv	a0,s6
 762:	e47ff0ef          	jal	5a8 <printint>
        i += 1;
 766:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 768:	8bca                	mv	s7,s2
      state = 0;
 76a:	4981                	li	s3,0
        i += 1;
 76c:	b70d                	j	68e <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 76e:	06400793          	li	a5,100
 772:	02f60763          	beq	a2,a5,7a0 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 776:	07500793          	li	a5,117
 77a:	06f60963          	beq	a2,a5,7ec <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 77e:	07800793          	li	a5,120
 782:	faf61ee3          	bne	a2,a5,73e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 786:	008b8913          	addi	s2,s7,8
 78a:	4681                	li	a3,0
 78c:	4641                	li	a2,16
 78e:	000bb583          	ld	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	e15ff0ef          	jal	5a8 <printint>
        i += 2;
 798:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 79a:	8bca                	mv	s7,s2
      state = 0;
 79c:	4981                	li	s3,0
        i += 2;
 79e:	bdc5                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a0:	008b8913          	addi	s2,s7,8
 7a4:	4685                	li	a3,1
 7a6:	4629                	li	a2,10
 7a8:	000bb583          	ld	a1,0(s7)
 7ac:	855a                	mv	a0,s6
 7ae:	dfbff0ef          	jal	5a8 <printint>
        i += 2;
 7b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b4:	8bca                	mv	s7,s2
      state = 0;
 7b6:	4981                	li	s3,0
        i += 2;
 7b8:	bdd9                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7ba:	008b8913          	addi	s2,s7,8
 7be:	4681                	li	a3,0
 7c0:	4629                	li	a2,10
 7c2:	000be583          	lwu	a1,0(s7)
 7c6:	855a                	mv	a0,s6
 7c8:	de1ff0ef          	jal	5a8 <printint>
 7cc:	8bca                	mv	s7,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	bd7d                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d2:	008b8913          	addi	s2,s7,8
 7d6:	4681                	li	a3,0
 7d8:	4629                	li	a2,10
 7da:	000bb583          	ld	a1,0(s7)
 7de:	855a                	mv	a0,s6
 7e0:	dc9ff0ef          	jal	5a8 <printint>
        i += 1;
 7e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e6:	8bca                	mv	s7,s2
      state = 0;
 7e8:	4981                	li	s3,0
        i += 1;
 7ea:	b555                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ec:	008b8913          	addi	s2,s7,8
 7f0:	4681                	li	a3,0
 7f2:	4629                	li	a2,10
 7f4:	000bb583          	ld	a1,0(s7)
 7f8:	855a                	mv	a0,s6
 7fa:	dafff0ef          	jal	5a8 <printint>
        i += 2;
 7fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 800:	8bca                	mv	s7,s2
      state = 0;
 802:	4981                	li	s3,0
        i += 2;
 804:	b569                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 806:	008b8913          	addi	s2,s7,8
 80a:	4681                	li	a3,0
 80c:	4641                	li	a2,16
 80e:	000be583          	lwu	a1,0(s7)
 812:	855a                	mv	a0,s6
 814:	d95ff0ef          	jal	5a8 <printint>
 818:	8bca                	mv	s7,s2
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bd8d                	j	68e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81e:	008b8913          	addi	s2,s7,8
 822:	4681                	li	a3,0
 824:	4641                	li	a2,16
 826:	000bb583          	ld	a1,0(s7)
 82a:	855a                	mv	a0,s6
 82c:	d7dff0ef          	jal	5a8 <printint>
        i += 1;
 830:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 832:	8bca                	mv	s7,s2
      state = 0;
 834:	4981                	li	s3,0
        i += 1;
 836:	bda1                	j	68e <vprintf+0x4a>
 838:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 83a:	008b8d13          	addi	s10,s7,8
 83e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	855a                	mv	a0,s6
 848:	d43ff0ef          	jal	58a <putc>
  putc(fd, 'x');
 84c:	07800593          	li	a1,120
 850:	855a                	mv	a0,s6
 852:	d39ff0ef          	jal	58a <putc>
 856:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 858:	00000b97          	auipc	s7,0x0
 85c:	430b8b93          	addi	s7,s7,1072 # c88 <digits>
 860:	03c9d793          	srli	a5,s3,0x3c
 864:	97de                	add	a5,a5,s7
 866:	0007c583          	lbu	a1,0(a5)
 86a:	855a                	mv	a0,s6
 86c:	d1fff0ef          	jal	58a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 870:	0992                	slli	s3,s3,0x4
 872:	397d                	addiw	s2,s2,-1
 874:	fe0916e3          	bnez	s2,860 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 878:	8bea                	mv	s7,s10
      state = 0;
 87a:	4981                	li	s3,0
 87c:	6d02                	ld	s10,0(sp)
 87e:	bd01                	j	68e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 880:	008b8913          	addi	s2,s7,8
 884:	000bc583          	lbu	a1,0(s7)
 888:	855a                	mv	a0,s6
 88a:	d01ff0ef          	jal	58a <putc>
 88e:	8bca                	mv	s7,s2
      state = 0;
 890:	4981                	li	s3,0
 892:	bbf5                	j	68e <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 894:	008b8993          	addi	s3,s7,8
 898:	000bb903          	ld	s2,0(s7)
 89c:	00090f63          	beqz	s2,8ba <vprintf+0x276>
        for (; *s; s++)
 8a0:	00094583          	lbu	a1,0(s2)
 8a4:	c195                	beqz	a1,8c8 <vprintf+0x284>
          putc(fd, *s);
 8a6:	855a                	mv	a0,s6
 8a8:	ce3ff0ef          	jal	58a <putc>
        for (; *s; s++)
 8ac:	0905                	addi	s2,s2,1
 8ae:	00094583          	lbu	a1,0(s2)
 8b2:	f9f5                	bnez	a1,8a6 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 8b4:	8bce                	mv	s7,s3
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	bbd9                	j	68e <vprintf+0x4a>
          s = "(null)";
 8ba:	00000917          	auipc	s2,0x0
 8be:	3c690913          	addi	s2,s2,966 # c80 <malloc+0x2ba>
        for (; *s; s++)
 8c2:	02800593          	li	a1,40
 8c6:	b7c5                	j	8a6 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 8c8:	8bce                	mv	s7,s3
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	b3c9                	j	68e <vprintf+0x4a>
 8ce:	64a6                	ld	s1,72(sp)
 8d0:	79e2                	ld	s3,56(sp)
 8d2:	7a42                	ld	s4,48(sp)
 8d4:	7aa2                	ld	s5,40(sp)
 8d6:	7b02                	ld	s6,32(sp)
 8d8:	6be2                	ld	s7,24(sp)
 8da:	6c42                	ld	s8,16(sp)
 8dc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8de:	60e6                	ld	ra,88(sp)
 8e0:	6446                	ld	s0,80(sp)
 8e2:	6906                	ld	s2,64(sp)
 8e4:	6125                	addi	sp,sp,96
 8e6:	8082                	ret

00000000000008e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8e8:	715d                	addi	sp,sp,-80
 8ea:	ec06                	sd	ra,24(sp)
 8ec:	e822                	sd	s0,16(sp)
 8ee:	1000                	addi	s0,sp,32
 8f0:	e010                	sd	a2,0(s0)
 8f2:	e414                	sd	a3,8(s0)
 8f4:	e818                	sd	a4,16(s0)
 8f6:	ec1c                	sd	a5,24(s0)
 8f8:	03043023          	sd	a6,32(s0)
 8fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 900:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 904:	8622                	mv	a2,s0
 906:	d3fff0ef          	jal	644 <vprintf>
}
 90a:	60e2                	ld	ra,24(sp)
 90c:	6442                	ld	s0,16(sp)
 90e:	6161                	addi	sp,sp,80
 910:	8082                	ret

0000000000000912 <printf>:

void
printf(const char *fmt, ...)
{
 912:	711d                	addi	sp,sp,-96
 914:	ec06                	sd	ra,24(sp)
 916:	e822                	sd	s0,16(sp)
 918:	1000                	addi	s0,sp,32
 91a:	e40c                	sd	a1,8(s0)
 91c:	e810                	sd	a2,16(s0)
 91e:	ec14                	sd	a3,24(s0)
 920:	f018                	sd	a4,32(s0)
 922:	f41c                	sd	a5,40(s0)
 924:	03043823          	sd	a6,48(s0)
 928:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 92c:	00840613          	addi	a2,s0,8
 930:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 934:	85aa                	mv	a1,a0
 936:	4505                	li	a0,1
 938:	d0dff0ef          	jal	644 <vprintf>
}
 93c:	60e2                	ld	ra,24(sp)
 93e:	6442                	ld	s0,16(sp)
 940:	6125                	addi	sp,sp,96
 942:	8082                	ret

0000000000000944 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 944:	1141                	addi	sp,sp,-16
 946:	e422                	sd	s0,8(sp)
 948:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 94a:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94e:	00001797          	auipc	a5,0x1
 952:	6b27b783          	ld	a5,1714(a5) # 2000 <freep>
 956:	a02d                	j	980 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 958:	4618                	lw	a4,8(a2)
 95a:	9f2d                	addw	a4,a4,a1
 95c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	6398                	ld	a4,0(a5)
 962:	6310                	ld	a2,0(a4)
 964:	a83d                	j	9a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 966:	ff852703          	lw	a4,-8(a0)
 96a:	9f31                	addw	a4,a4,a2
 96c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 96e:	ff053683          	ld	a3,-16(a0)
 972:	a091                	j	9b6 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 974:	6398                	ld	a4,0(a5)
 976:	00e7e463          	bltu	a5,a4,97e <free+0x3a>
 97a:	00e6ea63          	bltu	a3,a4,98e <free+0x4a>
{
 97e:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 980:	fed7fae3          	bgeu	a5,a3,974 <free+0x30>
 984:	6398                	ld	a4,0(a5)
 986:	00e6e463          	bltu	a3,a4,98e <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	fee7eae3          	bltu	a5,a4,97e <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 98e:	ff852583          	lw	a1,-8(a0)
 992:	6390                	ld	a2,0(a5)
 994:	02059813          	slli	a6,a1,0x20
 998:	01c85713          	srli	a4,a6,0x1c
 99c:	9736                	add	a4,a4,a3
 99e:	fae60de3          	beq	a2,a4,958 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9a2:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 9a6:	4790                	lw	a2,8(a5)
 9a8:	02061593          	slli	a1,a2,0x20
 9ac:	01c5d713          	srli	a4,a1,0x1c
 9b0:	973e                	add	a4,a4,a5
 9b2:	fae68ae3          	beq	a3,a4,966 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9b8:	00001717          	auipc	a4,0x1
 9bc:	64f73423          	sd	a5,1608(a4) # 2000 <freep>
}
 9c0:	6422                	ld	s0,8(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret

00000000000009c6 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 9c6:	7139                	addi	sp,sp,-64
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	f426                	sd	s1,40(sp)
 9ce:	ec4e                	sd	s3,24(sp)
 9d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 9d2:	02051493          	slli	s1,a0,0x20
 9d6:	9081                	srli	s1,s1,0x20
 9d8:	04bd                	addi	s1,s1,15
 9da:	8091                	srli	s1,s1,0x4
 9dc:	0014899b          	addiw	s3,s1,1
 9e0:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 9e2:	00001517          	auipc	a0,0x1
 9e6:	61e53503          	ld	a0,1566(a0) # 2000 <freep>
 9ea:	c915                	beqz	a0,a1e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 9ec:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 9ee:	4798                	lw	a4,8(a5)
 9f0:	08977a63          	bgeu	a4,s1,a84 <malloc+0xbe>
 9f4:	f04a                	sd	s2,32(sp)
 9f6:	e852                	sd	s4,16(sp)
 9f8:	e456                	sd	s5,8(sp)
 9fa:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 9fc:	8a4e                	mv	s4,s3
 9fe:	0009871b          	sext.w	a4,s3
 a02:	6685                	lui	a3,0x1
 a04:	00d77363          	bgeu	a4,a3,a0a <malloc+0x44>
 a08:	6a05                	lui	s4,0x1
 a0a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a0e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 a12:	00001917          	auipc	s2,0x1
 a16:	5ee90913          	addi	s2,s2,1518 # 2000 <freep>
  if (p == SBRK_ERROR)
 a1a:	5afd                	li	s5,-1
 a1c:	a081                	j	a5c <malloc+0x96>
 a1e:	f04a                	sd	s2,32(sp)
 a20:	e852                	sd	s4,16(sp)
 a22:	e456                	sd	s5,8(sp)
 a24:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a26:	00002797          	auipc	a5,0x2
 a2a:	fea78793          	addi	a5,a5,-22 # 2a10 <base>
 a2e:	00001717          	auipc	a4,0x1
 a32:	5cf73923          	sd	a5,1490(a4) # 2000 <freep>
 a36:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a38:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 a3c:	b7c1                	j	9fc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a3e:	6398                	ld	a4,0(a5)
 a40:	e118                	sd	a4,0(a0)
 a42:	a8a9                	j	a9c <malloc+0xd6>
  hp->s.size = nu;
 a44:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 a48:	0541                	addi	a0,a0,16
 a4a:	efbff0ef          	jal	944 <free>
  return freep;
 a4e:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 a52:	c12d                	beqz	a0,ab4 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 a54:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 a56:	4798                	lw	a4,8(a5)
 a58:	02977263          	bgeu	a4,s1,a7c <malloc+0xb6>
    if (p == freep)
 a5c:	00093703          	ld	a4,0(s2)
 a60:	853e                	mv	a0,a5
 a62:	fef719e3          	bne	a4,a5,a54 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a66:	8552                	mv	a0,s4
 a68:	a27ff0ef          	jal	48e <sbrk>
  if (p == SBRK_ERROR)
 a6c:	fd551ce3          	bne	a0,s5,a44 <malloc+0x7e>
        return 0;
 a70:	4501                	li	a0,0
 a72:	7902                	ld	s2,32(sp)
 a74:	6a42                	ld	s4,16(sp)
 a76:	6aa2                	ld	s5,8(sp)
 a78:	6b02                	ld	s6,0(sp)
 a7a:	a03d                	j	aa8 <malloc+0xe2>
 a7c:	7902                	ld	s2,32(sp)
 a7e:	6a42                	ld	s4,16(sp)
 a80:	6aa2                	ld	s5,8(sp)
 a82:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 a84:	fae48de3          	beq	s1,a4,a3e <malloc+0x78>
        p->s.size -= nunits;
 a88:	4137073b          	subw	a4,a4,s3
 a8c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a8e:	02071693          	slli	a3,a4,0x20
 a92:	01c6d713          	srli	a4,a3,0x1c
 a96:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a98:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a9c:	00001717          	auipc	a4,0x1
 aa0:	56a73223          	sd	a0,1380(a4) # 2000 <freep>
      return (void *)(p + 1);
 aa4:	01078513          	addi	a0,a5,16
  }
}
 aa8:	70e2                	ld	ra,56(sp)
 aaa:	7442                	ld	s0,48(sp)
 aac:	74a2                	ld	s1,40(sp)
 aae:	69e2                	ld	s3,24(sp)
 ab0:	6121                	addi	sp,sp,64
 ab2:	8082                	ret
 ab4:	7902                	ld	s2,32(sp)
 ab6:	6a42                	ld	s4,16(sp)
 ab8:	6aa2                	ld	s5,8(sp)
 aba:	6b02                	ld	s6,0(sp)
 abc:	b7f5                	j	aa8 <malloc+0xe2>
