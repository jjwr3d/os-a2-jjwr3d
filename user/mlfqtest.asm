
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <get_my_info>:

struct pinfo buf[64];

int
get_my_info(int pid, int *level, int *runticks)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  10:	89ae                	mv	s3,a1
  12:	8932                	mv	s2,a2
  int n = getpinfo(buf, 64);
  14:	04000593          	li	a1,64
  18:	00001517          	auipc	a0,0x1
  1c:	ff850513          	addi	a0,a0,-8 # 1010 <buf>
  20:	456000ef          	jal	476 <getpinfo>
  for (int i = 0; i < n; i++) {
  24:	04a05c63          	blez	a0,7c <get_my_info+0x7c>
  28:	00001717          	auipc	a4,0x1
  2c:	fe870713          	addi	a4,a4,-24 # 1010 <buf>
  30:	4781                	li	a5,0
    if (buf[i].pid == pid) {
  32:	4314                	lw	a3,0(a4)
  34:	00968963          	beq	a3,s1,46 <get_my_info+0x46>
  for (int i = 0; i < n; i++) {
  38:	2785                	addiw	a5,a5,1
  3a:	02870713          	addi	a4,a4,40
  3e:	fef51ae3          	bne	a0,a5,32 <get_my_info+0x32>
      *level = buf[i].level;
      *runticks = buf[i].runticks;
      return 0;
    }
  }
  return -1;
  42:	557d                	li	a0,-1
  44:	a02d                	j	6e <get_my_info+0x6e>
      *level = buf[i].level;
  46:	00001617          	auipc	a2,0x1
  4a:	fca60613          	addi	a2,a2,-54 # 1010 <buf>
  4e:	00279713          	slli	a4,a5,0x2
  52:	00f706b3          	add	a3,a4,a5
  56:	068e                	slli	a3,a3,0x3
  58:	96b2                	add	a3,a3,a2
  5a:	4694                	lw	a3,8(a3)
  5c:	00d9a023          	sw	a3,0(s3)
      *runticks = buf[i].runticks;
  60:	973e                	add	a4,a4,a5
  62:	070e                	slli	a4,a4,0x3
  64:	963a                	add	a2,a2,a4
  66:	465c                	lw	a5,12(a2)
  68:	00f92023          	sw	a5,0(s2)
      return 0;
  6c:	4501                	li	a0,0
}
  6e:	70a2                	ld	ra,40(sp)
  70:	7402                	ld	s0,32(sp)
  72:	64e2                	ld	s1,24(sp)
  74:	6942                	ld	s2,16(sp)
  76:	69a2                	ld	s3,8(sp)
  78:	6145                	addi	sp,sp,48
  7a:	8082                	ret
  return -1;
  7c:	557d                	li	a0,-1
  7e:	bfc5                	j	6e <get_my_info+0x6e>

0000000000000080 <main>:

int
main(int argc, char *argv[])
{
  80:	711d                	addi	sp,sp,-96
  82:	ec86                	sd	ra,88(sp)
  84:	e8a2                	sd	s0,80(sp)
  86:	e4a6                	sd	s1,72(sp)
  88:	e0ca                	sd	s2,64(sp)
  8a:	fc4e                	sd	s3,56(sp)
  8c:	f852                	sd	s4,48(sp)
  8e:	f456                	sd	s5,40(sp)
  90:	f05a                	sd	s6,32(sp)
  92:	ec5e                	sd	s7,24(sp)
  94:	1080                	addi	s0,sp,96
  int pid = getpid();
  96:	3b8000ef          	jal	44e <getpid>
  9a:	8aaa                	mv	s5,a0
  int lvl = 0, rt = 0;
  9c:	fa042623          	sw	zero,-84(s0)
  a0:	fa042423          	sw	zero,-88(s0)

  get_my_info(pid, &lvl, &rt);
  a4:	fa840613          	addi	a2,s0,-88
  a8:	fac40593          	addi	a1,s0,-84
  ac:	f55ff0ef          	jal	0 <get_my_info>
  printf("mlfqtest: starting (pid %d, level %d, runticks %d)\n", pid, lvl, rt);
  b0:	fa842683          	lw	a3,-88(s0)
  b4:	fac42603          	lw	a2,-84(s0)
  b8:	85d6                	mv	a1,s5
  ba:	00001517          	auipc	a0,0x1
  be:	91650513          	addi	a0,a0,-1770 # 9d0 <malloc+0xfe>
  c2:	75c000ef          	jal	81e <printf>

  int last_level = -1;
  volatile int x = 0;
  c6:	fa042223          	sw	zero,-92(s0)
  for (int iter = 0; iter < 500000000; iter++) {
  ca:	4481                	li	s1,0
  int last_level = -1;
  cc:	5b7d                	li	s6,-1
    x += iter;
    if (iter % 5000000 == 0) {
  ce:	004c59b7          	lui	s3,0x4c5
  d2:	b409899b          	addiw	s3,s3,-1216 # 4c4b40 <base+0x4c3130>
      if (get_my_info(pid, &lvl, &rt) == 0 && lvl != last_level) {
        printf("  [runticks=%d] transitioned to MLFQ level %d\n", rt, lvl);
  d6:	00001b97          	auipc	s7,0x1
  da:	932b8b93          	addi	s7,s7,-1742 # a08 <malloc+0x136>
  for (int iter = 0; iter < 500000000; iter++) {
  de:	1dcd6937          	lui	s2,0x1dcd6
  e2:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd4af0>
  e6:	a819                	j	fc <main+0x7c>
        printf("  [runticks=%d] transitioned to MLFQ level %d\n", rt, lvl);
  e8:	8652                	mv	a2,s4
  ea:	fa842583          	lw	a1,-88(s0)
  ee:	855e                	mv	a0,s7
  f0:	72e000ef          	jal	81e <printf>
        last_level = lvl;
  f4:	8b52                	mv	s6,s4
  for (int iter = 0; iter < 500000000; iter++) {
  f6:	2485                	addiw	s1,s1,1
  f8:	03248863          	beq	s1,s2,128 <main+0xa8>
    x += iter;
  fc:	fa442783          	lw	a5,-92(s0)
 100:	9fa5                	addw	a5,a5,s1
 102:	faf42223          	sw	a5,-92(s0)
    if (iter % 5000000 == 0) {
 106:	0334e7bb          	remw	a5,s1,s3
 10a:	f7f5                	bnez	a5,f6 <main+0x76>
      if (get_my_info(pid, &lvl, &rt) == 0 && lvl != last_level) {
 10c:	fa840613          	addi	a2,s0,-88
 110:	fac40593          	addi	a1,s0,-84
 114:	8556                	mv	a0,s5
 116:	eebff0ef          	jal	0 <get_my_info>
 11a:	fd71                	bnez	a0,f6 <main+0x76>
 11c:	fac42a03          	lw	s4,-84(s0)
 120:	fd6a14e3          	bne	s4,s6,e8 <main+0x68>
 124:	8b52                	mv	s6,s4
 126:	bfc1                	j	f6 <main+0x76>
      }
    }
  }

  printf("mlfqtest: DONE\n");
 128:	00001517          	auipc	a0,0x1
 12c:	91050513          	addi	a0,a0,-1776 # a38 <malloc+0x166>
 130:	6ee000ef          	jal	81e <printf>
  exit(0);
 134:	4501                	li	a0,0
 136:	298000ef          	jal	3ce <exit>

000000000000013a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e406                	sd	ra,8(sp)
 13e:	e022                	sd	s0,0(sp)
 140:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 142:	f3fff0ef          	jal	80 <main>
  exit(r);
 146:	288000ef          	jal	3ce <exit>

000000000000014a <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0x8>
    ;
  return os;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb91                	beqz	a5,184 <strcmp+0x1e>
 172:	0005c703          	lbu	a4,0(a1)
 176:	00f71763          	bne	a4,a5,184 <strcmp+0x1e>
    p++, q++;
 17a:	0505                	addi	a0,a0,1
 17c:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	fbe5                	bnez	a5,172 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 184:	0005c503          	lbu	a0,0(a1)
}
 188:	40a7853b          	subw	a0,a5,a0
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strlen>:

uint
strlen(const char *s)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cf91                	beqz	a5,1b8 <strlen+0x26>
 19e:	0505                	addi	a0,a0,1
 1a0:	87aa                	mv	a5,a0
 1a2:	86be                	mv	a3,a5
 1a4:	0785                	addi	a5,a5,1
 1a6:	fff7c703          	lbu	a4,-1(a5)
 1aa:	ff65                	bnez	a4,1a2 <strlen+0x10>
 1ac:	40a6853b          	subw	a0,a3,a0
 1b0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  for (n = 0; s[n]; n++)
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <strlen+0x20>

00000000000001bc <memset>:

void *
memset(void *dst, int c, uint n)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 1c2:	ca19                	beqz	a2,1d8 <memset+0x1c>
 1c4:	87aa                	mv	a5,a0
 1c6:	1602                	slli	a2,a2,0x20
 1c8:	9201                	srli	a2,a2,0x20
 1ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ce:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 1d2:	0785                	addi	a5,a5,1
 1d4:	fee79de3          	bne	a5,a4,1ce <memset+0x12>
  }
  return dst;
}
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strchr>:

char *
strchr(const char *s, char c)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  for (; *s; s++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cb99                	beqz	a5,1fe <strchr+0x20>
    if (*s == c)
 1ea:	00f58763          	beq	a1,a5,1f8 <strchr+0x1a>
  for (; *s; s++)
 1ee:	0505                	addi	a0,a0,1
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	fbfd                	bnez	a5,1ea <strchr+0xc>
      return (char *)s;
  return 0;
 1f6:	4501                	li	a0,0
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  return 0;
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strchr+0x1a>

0000000000000202 <gets>:

char *
gets(char *buf, int max)
{
 202:	711d                	addi	sp,sp,-96
 204:	ec86                	sd	ra,88(sp)
 206:	e8a2                	sd	s0,80(sp)
 208:	e4a6                	sd	s1,72(sp)
 20a:	e0ca                	sd	s2,64(sp)
 20c:	fc4e                	sd	s3,56(sp)
 20e:	f852                	sd	s4,48(sp)
 210:	f456                	sd	s5,40(sp)
 212:	f05a                	sd	s6,32(sp)
 214:	ec5e                	sd	s7,24(sp)
 216:	1080                	addi	s0,sp,96
 218:	8baa                	mv	s7,a0
 21a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 21c:	892a                	mv	s2,a0
 21e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 220:	4aa9                	li	s5,10
 222:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 224:	89a6                	mv	s3,s1
 226:	2485                	addiw	s1,s1,1
 228:	0344d663          	bge	s1,s4,254 <gets+0x52>
    cc = read(0, &c, 1);
 22c:	4605                	li	a2,1
 22e:	faf40593          	addi	a1,s0,-81
 232:	4501                	li	a0,0
 234:	1b2000ef          	jal	3e6 <read>
    if (cc < 1)
 238:	00a05e63          	blez	a0,254 <gets+0x52>
    buf[i++] = c;
 23c:	faf44783          	lbu	a5,-81(s0)
 240:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 244:	01578763          	beq	a5,s5,252 <gets+0x50>
 248:	0905                	addi	s2,s2,1
 24a:	fd679de3          	bne	a5,s6,224 <gets+0x22>
    buf[i++] = c;
 24e:	89a6                	mv	s3,s1
 250:	a011                	j	254 <gets+0x52>
 252:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 254:	99de                	add	s3,s3,s7
 256:	00098023          	sb	zero,0(s3)
  return buf;
}
 25a:	855e                	mv	a0,s7
 25c:	60e6                	ld	ra,88(sp)
 25e:	6446                	ld	s0,80(sp)
 260:	64a6                	ld	s1,72(sp)
 262:	6906                	ld	s2,64(sp)
 264:	79e2                	ld	s3,56(sp)
 266:	7a42                	ld	s4,48(sp)
 268:	7aa2                	ld	s5,40(sp)
 26a:	7b02                	ld	s6,32(sp)
 26c:	6be2                	ld	s7,24(sp)
 26e:	6125                	addi	sp,sp,96
 270:	8082                	ret

0000000000000272 <stat>:

int
stat(const char *n, struct stat *st)
{
 272:	1101                	addi	sp,sp,-32
 274:	ec06                	sd	ra,24(sp)
 276:	e822                	sd	s0,16(sp)
 278:	e04a                	sd	s2,0(sp)
 27a:	1000                	addi	s0,sp,32
 27c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	4581                	li	a1,0
 280:	18e000ef          	jal	40e <open>
  if (fd < 0)
 284:	02054263          	bltz	a0,2a8 <stat+0x36>
 288:	e426                	sd	s1,8(sp)
 28a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28c:	85ca                	mv	a1,s2
 28e:	198000ef          	jal	426 <fstat>
 292:	892a                	mv	s2,a0
  close(fd);
 294:	8526                	mv	a0,s1
 296:	160000ef          	jal	3f6 <close>
  return r;
 29a:	64a2                	ld	s1,8(sp)
}
 29c:	854a                	mv	a0,s2
 29e:	60e2                	ld	ra,24(sp)
 2a0:	6442                	ld	s0,16(sp)
 2a2:	6902                	ld	s2,0(sp)
 2a4:	6105                	addi	sp,sp,32
 2a6:	8082                	ret
    return -1;
 2a8:	597d                	li	s2,-1
 2aa:	bfcd                	j	29c <stat+0x2a>

00000000000002ac <atoi>:

int
atoi(const char *s)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 2b2:	00054683          	lbu	a3,0(a0)
 2b6:	fd06879b          	addiw	a5,a3,-48
 2ba:	0ff7f793          	zext.b	a5,a5
 2be:	4625                	li	a2,9
 2c0:	02f66863          	bltu	a2,a5,2f0 <atoi+0x44>
 2c4:	872a                	mv	a4,a0
  n = 0;
 2c6:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 2c8:	0705                	addi	a4,a4,1
 2ca:	0025179b          	slliw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	slliw	a5,a5,0x1
 2d4:	9fb5                	addw	a5,a5,a3
 2d6:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 2da:	00074683          	lbu	a3,0(a4)
 2de:	fd06879b          	addiw	a5,a3,-48
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	fef671e3          	bgeu	a2,a5,2c8 <atoi+0x1c>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x3e>

00000000000002f4 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while (n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	slli	a2,a2,0x20
 304:	9201                	srli	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	addi	a1,a1,1
 30e:	0705                	addi	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 318:	fef71ae3          	bne	a4,a5,30c <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addiw	a3,a2,-1
 358:	1682                	slli	a3,a3,0x20
 35a:	9281                	srli	a3,a3,0x20
 35c:	0685                	addi	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	addi	a0,a0,1
    p2++;
 36e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38e:	f67ff0ef          	jal	2f4 <memmove>
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret

000000000000039a <sbrk>:

char *
sbrk(int n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a2:	4585                	li	a1,1
 3a4:	0b2000ef          	jal	456 <sys_sbrk>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <sbrklazy>:

char *
sbrklazy(int n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3b8:	4589                	li	a1,2
 3ba:	09c000ef          	jal	456 <sys_sbrk>
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c6:	4885                	li	a7,1
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ce:	4889                	li	a7,2
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d6:	488d                	li	a7,3
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3de:	4891                	li	a7,4
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <read>:
.global read
read:
 li a7, SYS_read
 3e6:	4895                	li	a7,5
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <write>:
.global write
write:
 li a7, SYS_write
 3ee:	48c1                	li	a7,16
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <close>:
.global close
close:
 li a7, SYS_close
 3f6:	48d5                	li	a7,21
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fe:	4899                	li	a7,6
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exec>:
.global exec
exec:
 li a7, SYS_exec
 406:	489d                	li	a7,7
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <open>:
.global open
open:
 li a7, SYS_open
 40e:	48bd                	li	a7,15
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 416:	48c5                	li	a7,17
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41e:	48c9                	li	a7,18
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 426:	48a1                	li	a7,8
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <link>:
.global link
link:
 li a7, SYS_link
 42e:	48cd                	li	a7,19
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 436:	48d1                	li	a7,20
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43e:	48a5                	li	a7,9
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <dup>:
.global dup
dup:
 li a7, SYS_dup
 446:	48a9                	li	a7,10
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44e:	48ad                	li	a7,11
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 456:	48b1                	li	a7,12
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <pause>:
.global pause
pause:
 li a7, SYS_pause
 45e:	48b5                	li	a7,13
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 466:	48b9                	li	a7,14
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <sync>:
.global sync
sync:
 li a7, SYS_sync
 46e:	48d9                	li	a7,22
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 476:	48dd                	li	a7,23
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <trace>:
.global trace
trace:
 li a7, SYS_trace
 47e:	48e1                	li	a7,24
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 486:	48e5                	li	a7,25
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 48e:	48e9                	li	a7,26
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 496:	1101                	addi	sp,sp,-32
 498:	ec06                	sd	ra,24(sp)
 49a:	e822                	sd	s0,16(sp)
 49c:	1000                	addi	s0,sp,32
 49e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a2:	4605                	li	a2,1
 4a4:	fef40593          	addi	a1,s0,-17
 4a8:	f47ff0ef          	jal	3ee <write>
}
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6105                	addi	sp,sp,32
 4b2:	8082                	ret

00000000000004b4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4b4:	715d                	addi	sp,sp,-80
 4b6:	e486                	sd	ra,72(sp)
 4b8:	e0a2                	sd	s0,64(sp)
 4ba:	f84a                	sd	s2,48(sp)
 4bc:	0880                	addi	s0,sp,80
 4be:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 4c0:	c299                	beqz	a3,4c6 <printint+0x12>
 4c2:	0805c363          	bltz	a1,548 <printint+0x94>
  neg = 0;
 4c6:	4881                	li	a7,0
 4c8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4cc:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 4ce:	00000517          	auipc	a0,0x0
 4d2:	58250513          	addi	a0,a0,1410 # a50 <digits>
 4d6:	883e                	mv	a6,a5
 4d8:	2785                	addiw	a5,a5,1
 4da:	02c5f733          	remu	a4,a1,a2
 4de:	972a                	add	a4,a4,a0
 4e0:	00074703          	lbu	a4,0(a4)
 4e4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 4e8:	872e                	mv	a4,a1
 4ea:	02c5d5b3          	divu	a1,a1,a2
 4ee:	0685                	addi	a3,a3,1
 4f0:	fec773e3          	bgeu	a4,a2,4d6 <printint+0x22>
  if (neg)
 4f4:	00088b63          	beqz	a7,50a <printint+0x56>
    buf[i++] = '-';
 4f8:	fd078793          	addi	a5,a5,-48
 4fc:	97a2                	add	a5,a5,s0
 4fe:	02d00713          	li	a4,45
 502:	fee78423          	sb	a4,-24(a5)
 506:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 50a:	02f05a63          	blez	a5,53e <printint+0x8a>
 50e:	fc26                	sd	s1,56(sp)
 510:	f44e                	sd	s3,40(sp)
 512:	fb840713          	addi	a4,s0,-72
 516:	00f704b3          	add	s1,a4,a5
 51a:	fff70993          	addi	s3,a4,-1
 51e:	99be                	add	s3,s3,a5
 520:	37fd                	addiw	a5,a5,-1
 522:	1782                	slli	a5,a5,0x20
 524:	9381                	srli	a5,a5,0x20
 526:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 52a:	fff4c583          	lbu	a1,-1(s1)
 52e:	854a                	mv	a0,s2
 530:	f67ff0ef          	jal	496 <putc>
  while (--i >= 0)
 534:	14fd                	addi	s1,s1,-1
 536:	ff349ae3          	bne	s1,s3,52a <printint+0x76>
 53a:	74e2                	ld	s1,56(sp)
 53c:	79a2                	ld	s3,40(sp)
}
 53e:	60a6                	ld	ra,72(sp)
 540:	6406                	ld	s0,64(sp)
 542:	7942                	ld	s2,48(sp)
 544:	6161                	addi	sp,sp,80
 546:	8082                	ret
    x = -xx;
 548:	40b005b3          	neg	a1,a1
    neg = 1;
 54c:	4885                	li	a7,1
    x = -xx;
 54e:	bfad                	j	4c8 <printint+0x14>

0000000000000550 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 550:	711d                	addi	sp,sp,-96
 552:	ec86                	sd	ra,88(sp)
 554:	e8a2                	sd	s0,80(sp)
 556:	e0ca                	sd	s2,64(sp)
 558:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 55a:	0005c903          	lbu	s2,0(a1)
 55e:	28090663          	beqz	s2,7ea <vprintf+0x29a>
 562:	e4a6                	sd	s1,72(sp)
 564:	fc4e                	sd	s3,56(sp)
 566:	f852                	sd	s4,48(sp)
 568:	f456                	sd	s5,40(sp)
 56a:	f05a                	sd	s6,32(sp)
 56c:	ec5e                	sd	s7,24(sp)
 56e:	e862                	sd	s8,16(sp)
 570:	e466                	sd	s9,8(sp)
 572:	8b2a                	mv	s6,a0
 574:	8a2e                	mv	s4,a1
 576:	8bb2                	mv	s7,a2
  state = 0;
 578:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 57a:	4481                	li	s1,0
 57c:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 57e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 582:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 586:	06c00c93          	li	s9,108
 58a:	a005                	j	5aa <vprintf+0x5a>
        putc(fd, c0);
 58c:	85ca                	mv	a1,s2
 58e:	855a                	mv	a0,s6
 590:	f07ff0ef          	jal	496 <putc>
 594:	a019                	j	59a <vprintf+0x4a>
    } else if (state == '%') {
 596:	03598263          	beq	s3,s5,5ba <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 59a:	2485                	addiw	s1,s1,1
 59c:	8726                	mv	a4,s1
 59e:	009a07b3          	add	a5,s4,s1
 5a2:	0007c903          	lbu	s2,0(a5)
 5a6:	22090a63          	beqz	s2,7da <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5aa:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 5ae:	fe0994e3          	bnez	s3,596 <vprintf+0x46>
      if (c0 == '%') {
 5b2:	fd579de3          	bne	a5,s5,58c <vprintf+0x3c>
        state = '%';
 5b6:	89be                	mv	s3,a5
 5b8:	b7cd                	j	59a <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 5ba:	00ea06b3          	add	a3,s4,a4
 5be:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c2:	8636                	mv	a2,a3
      if (c1)
 5c4:	c681                	beqz	a3,5cc <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 5c6:	9752                	add	a4,a4,s4
 5c8:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 5cc:	05878363          	beq	a5,s8,612 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 5d0:	05978d63          	beq	a5,s9,62a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 5d4:	07500713          	li	a4,117
 5d8:	0ee78763          	beq	a5,a4,6c6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 5dc:	07800713          	li	a4,120
 5e0:	12e78963          	beq	a5,a4,712 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 5e4:	07000713          	li	a4,112
 5e8:	14e78e63          	beq	a5,a4,744 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 5ec:	06300713          	li	a4,99
 5f0:	18e78e63          	beq	a5,a4,78c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 5f4:	07300713          	li	a4,115
 5f8:	1ae78463          	beq	a5,a4,7a0 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 5fc:	02500713          	li	a4,37
 600:	04e79563          	bne	a5,a4,64a <vprintf+0xfa>
        putc(fd, '%');
 604:	02500593          	li	a1,37
 608:	855a                	mv	a0,s6
 60a:	e8dff0ef          	jal	496 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 60e:	4981                	li	s3,0
 610:	b769                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 612:	008b8913          	addi	s2,s7,8
 616:	4685                	li	a3,1
 618:	4629                	li	a2,10
 61a:	000ba583          	lw	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e95ff0ef          	jal	4b4 <printint>
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
 628:	bf8d                	j	59a <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 62a:	06400793          	li	a5,100
 62e:	02f68963          	beq	a3,a5,660 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 632:	06c00793          	li	a5,108
 636:	04f68263          	beq	a3,a5,67a <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 63a:	07500793          	li	a5,117
 63e:	0af68063          	beq	a3,a5,6de <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 642:	07800793          	li	a5,120
 646:	0ef68263          	beq	a3,a5,72a <vprintf+0x1da>
        putc(fd, '%');
 64a:	02500593          	li	a1,37
 64e:	855a                	mv	a0,s6
 650:	e47ff0ef          	jal	496 <putc>
        putc(fd, c0);
 654:	85ca                	mv	a1,s2
 656:	855a                	mv	a0,s6
 658:	e3fff0ef          	jal	496 <putc>
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bf35                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 660:	008b8913          	addi	s2,s7,8
 664:	4685                	li	a3,1
 666:	4629                	li	a2,10
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	e47ff0ef          	jal	4b4 <printint>
        i += 1;
 672:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 1;
 678:	b70d                	j	59a <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 67a:	06400793          	li	a5,100
 67e:	02f60763          	beq	a2,a5,6ac <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 682:	07500793          	li	a5,117
 686:	06f60963          	beq	a2,a5,6f8 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 68a:	07800793          	li	a5,120
 68e:	faf61ee3          	bne	a2,a5,64a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 692:	008b8913          	addi	s2,s7,8
 696:	4681                	li	a3,0
 698:	4641                	li	a2,16
 69a:	000bb583          	ld	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	e15ff0ef          	jal	4b4 <printint>
        i += 2;
 6a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
        i += 2;
 6aa:	bdc5                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4685                	li	a3,1
 6b2:	4629                	li	a2,10
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	dfbff0ef          	jal	4b4 <printint>
        i += 2;
 6be:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
        i += 2;
 6c4:	bdd9                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4629                	li	a2,10
 6ce:	000be583          	lwu	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	de1ff0ef          	jal	4b4 <printint>
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd7d                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4681                	li	a3,0
 6e4:	4629                	li	a2,10
 6e6:	000bb583          	ld	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	dc9ff0ef          	jal	4b4 <printint>
        i += 1;
 6f0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	8bca                	mv	s7,s2
      state = 0;
 6f4:	4981                	li	s3,0
        i += 1;
 6f6:	b555                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	008b8913          	addi	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4629                	li	a2,10
 700:	000bb583          	ld	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	dafff0ef          	jal	4b4 <printint>
        i += 2;
 70a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
        i += 2;
 710:	b569                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 712:	008b8913          	addi	s2,s7,8
 716:	4681                	li	a3,0
 718:	4641                	li	a2,16
 71a:	000be583          	lwu	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	d95ff0ef          	jal	4b4 <printint>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bd8d                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 72a:	008b8913          	addi	s2,s7,8
 72e:	4681                	li	a3,0
 730:	4641                	li	a2,16
 732:	000bb583          	ld	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	d7dff0ef          	jal	4b4 <printint>
        i += 1;
 73c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 73e:	8bca                	mv	s7,s2
      state = 0;
 740:	4981                	li	s3,0
        i += 1;
 742:	bda1                	j	59a <vprintf+0x4a>
 744:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 746:	008b8d13          	addi	s10,s7,8
 74a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 74e:	03000593          	li	a1,48
 752:	855a                	mv	a0,s6
 754:	d43ff0ef          	jal	496 <putc>
  putc(fd, 'x');
 758:	07800593          	li	a1,120
 75c:	855a                	mv	a0,s6
 75e:	d39ff0ef          	jal	496 <putc>
 762:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 764:	00000b97          	auipc	s7,0x0
 768:	2ecb8b93          	addi	s7,s7,748 # a50 <digits>
 76c:	03c9d793          	srli	a5,s3,0x3c
 770:	97de                	add	a5,a5,s7
 772:	0007c583          	lbu	a1,0(a5)
 776:	855a                	mv	a0,s6
 778:	d1fff0ef          	jal	496 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77c:	0992                	slli	s3,s3,0x4
 77e:	397d                	addiw	s2,s2,-1
 780:	fe0916e3          	bnez	s2,76c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 784:	8bea                	mv	s7,s10
      state = 0;
 786:	4981                	li	s3,0
 788:	6d02                	ld	s10,0(sp)
 78a:	bd01                	j	59a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 78c:	008b8913          	addi	s2,s7,8
 790:	000bc583          	lbu	a1,0(s7)
 794:	855a                	mv	a0,s6
 796:	d01ff0ef          	jal	496 <putc>
 79a:	8bca                	mv	s7,s2
      state = 0;
 79c:	4981                	li	s3,0
 79e:	bbf5                	j	59a <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 7a0:	008b8993          	addi	s3,s7,8
 7a4:	000bb903          	ld	s2,0(s7)
 7a8:	00090f63          	beqz	s2,7c6 <vprintf+0x276>
        for (; *s; s++)
 7ac:	00094583          	lbu	a1,0(s2)
 7b0:	c195                	beqz	a1,7d4 <vprintf+0x284>
          putc(fd, *s);
 7b2:	855a                	mv	a0,s6
 7b4:	ce3ff0ef          	jal	496 <putc>
        for (; *s; s++)
 7b8:	0905                	addi	s2,s2,1
 7ba:	00094583          	lbu	a1,0(s2)
 7be:	f9f5                	bnez	a1,7b2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 7c0:	8bce                	mv	s7,s3
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	bbd9                	j	59a <vprintf+0x4a>
          s = "(null)";
 7c6:	00000917          	auipc	s2,0x0
 7ca:	28290913          	addi	s2,s2,642 # a48 <malloc+0x176>
        for (; *s; s++)
 7ce:	02800593          	li	a1,40
 7d2:	b7c5                	j	7b2 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 7d4:	8bce                	mv	s7,s3
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	b3c9                	j	59a <vprintf+0x4a>
 7da:	64a6                	ld	s1,72(sp)
 7dc:	79e2                	ld	s3,56(sp)
 7de:	7a42                	ld	s4,48(sp)
 7e0:	7aa2                	ld	s5,40(sp)
 7e2:	7b02                	ld	s6,32(sp)
 7e4:	6be2                	ld	s7,24(sp)
 7e6:	6c42                	ld	s8,16(sp)
 7e8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ea:	60e6                	ld	ra,88(sp)
 7ec:	6446                	ld	s0,80(sp)
 7ee:	6906                	ld	s2,64(sp)
 7f0:	6125                	addi	sp,sp,96
 7f2:	8082                	ret

00000000000007f4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f4:	715d                	addi	sp,sp,-80
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e010                	sd	a2,0(s0)
 7fe:	e414                	sd	a3,8(s0)
 800:	e818                	sd	a4,16(s0)
 802:	ec1c                	sd	a5,24(s0)
 804:	03043023          	sd	a6,32(s0)
 808:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 80c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 810:	8622                	mv	a2,s0
 812:	d3fff0ef          	jal	550 <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6161                	addi	sp,sp,80
 81c:	8082                	ret

000000000000081e <printf>:

void
printf(const char *fmt, ...)
{
 81e:	711d                	addi	sp,sp,-96
 820:	ec06                	sd	ra,24(sp)
 822:	e822                	sd	s0,16(sp)
 824:	1000                	addi	s0,sp,32
 826:	e40c                	sd	a1,8(s0)
 828:	e810                	sd	a2,16(s0)
 82a:	ec14                	sd	a3,24(s0)
 82c:	f018                	sd	a4,32(s0)
 82e:	f41c                	sd	a5,40(s0)
 830:	03043823          	sd	a6,48(s0)
 834:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	00840613          	addi	a2,s0,8
 83c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 840:	85aa                	mv	a1,a0
 842:	4505                	li	a0,1
 844:	d0dff0ef          	jal	550 <vprintf>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6125                	addi	sp,sp,96
 84e:	8082                	ret

0000000000000850 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 850:	1141                	addi	sp,sp,-16
 852:	e422                	sd	s0,8(sp)
 854:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 856:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	00000797          	auipc	a5,0x0
 85e:	7a67b783          	ld	a5,1958(a5) # 1000 <freep>
 862:	a02d                	j	88c <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 864:	4618                	lw	a4,8(a2)
 866:	9f2d                	addw	a4,a4,a1
 868:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	6310                	ld	a2,0(a4)
 870:	a83d                	j	8ae <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 872:	ff852703          	lw	a4,-8(a0)
 876:	9f31                	addw	a4,a4,a2
 878:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 87a:	ff053683          	ld	a3,-16(a0)
 87e:	a091                	j	8c2 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 880:	6398                	ld	a4,0(a5)
 882:	00e7e463          	bltu	a5,a4,88a <free+0x3a>
 886:	00e6ea63          	bltu	a3,a4,89a <free+0x4a>
{
 88a:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88c:	fed7fae3          	bgeu	a5,a3,880 <free+0x30>
 890:	6398                	ld	a4,0(a5)
 892:	00e6e463          	bltu	a3,a4,89a <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	fee7eae3          	bltu	a5,a4,88a <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 89a:	ff852583          	lw	a1,-8(a0)
 89e:	6390                	ld	a2,0(a5)
 8a0:	02059813          	slli	a6,a1,0x20
 8a4:	01c85713          	srli	a4,a6,0x1c
 8a8:	9736                	add	a4,a4,a3
 8aa:	fae60de3          	beq	a2,a4,864 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8ae:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 8b2:	4790                	lw	a2,8(a5)
 8b4:	02061593          	slli	a1,a2,0x20
 8b8:	01c5d713          	srli	a4,a1,0x1c
 8bc:	973e                	add	a4,a4,a5
 8be:	fae68ae3          	beq	a3,a4,872 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72f73e23          	sd	a5,1852(a4) # 1000 <freep>
}
 8cc:	6422                	ld	s0,8(sp)
 8ce:	0141                	addi	sp,sp,16
 8d0:	8082                	ret

00000000000008d2 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 8d2:	7139                	addi	sp,sp,-64
 8d4:	fc06                	sd	ra,56(sp)
 8d6:	f822                	sd	s0,48(sp)
 8d8:	f426                	sd	s1,40(sp)
 8da:	ec4e                	sd	s3,24(sp)
 8dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 8de:	02051493          	slli	s1,a0,0x20
 8e2:	9081                	srli	s1,s1,0x20
 8e4:	04bd                	addi	s1,s1,15
 8e6:	8091                	srli	s1,s1,0x4
 8e8:	0014899b          	addiw	s3,s1,1
 8ec:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 8ee:	00000517          	auipc	a0,0x0
 8f2:	71253503          	ld	a0,1810(a0) # 1000 <freep>
 8f6:	c915                	beqz	a0,92a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8f8:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8fa:	4798                	lw	a4,8(a5)
 8fc:	08977a63          	bgeu	a4,s1,990 <malloc+0xbe>
 900:	f04a                	sd	s2,32(sp)
 902:	e852                	sd	s4,16(sp)
 904:	e456                	sd	s5,8(sp)
 906:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 908:	8a4e                	mv	s4,s3
 90a:	0009871b          	sext.w	a4,s3
 90e:	6685                	lui	a3,0x1
 910:	00d77363          	bgeu	a4,a3,916 <malloc+0x44>
 914:	6a05                	lui	s4,0x1
 916:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 91a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 91e:	00000917          	auipc	s2,0x0
 922:	6e290913          	addi	s2,s2,1762 # 1000 <freep>
  if (p == SBRK_ERROR)
 926:	5afd                	li	s5,-1
 928:	a081                	j	968 <malloc+0x96>
 92a:	f04a                	sd	s2,32(sp)
 92c:	e852                	sd	s4,16(sp)
 92e:	e456                	sd	s5,8(sp)
 930:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 932:	00001797          	auipc	a5,0x1
 936:	0de78793          	addi	a5,a5,222 # 1a10 <base>
 93a:	00000717          	auipc	a4,0x0
 93e:	6cf73323          	sd	a5,1734(a4) # 1000 <freep>
 942:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 944:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 948:	b7c1                	j	908 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 94a:	6398                	ld	a4,0(a5)
 94c:	e118                	sd	a4,0(a0)
 94e:	a8a9                	j	9a8 <malloc+0xd6>
  hp->s.size = nu;
 950:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 954:	0541                	addi	a0,a0,16
 956:	efbff0ef          	jal	850 <free>
  return freep;
 95a:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 95e:	c12d                	beqz	a0,9c0 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 960:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 962:	4798                	lw	a4,8(a5)
 964:	02977263          	bgeu	a4,s1,988 <malloc+0xb6>
    if (p == freep)
 968:	00093703          	ld	a4,0(s2)
 96c:	853e                	mv	a0,a5
 96e:	fef719e3          	bne	a4,a5,960 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 972:	8552                	mv	a0,s4
 974:	a27ff0ef          	jal	39a <sbrk>
  if (p == SBRK_ERROR)
 978:	fd551ce3          	bne	a0,s5,950 <malloc+0x7e>
        return 0;
 97c:	4501                	li	a0,0
 97e:	7902                	ld	s2,32(sp)
 980:	6a42                	ld	s4,16(sp)
 982:	6aa2                	ld	s5,8(sp)
 984:	6b02                	ld	s6,0(sp)
 986:	a03d                	j	9b4 <malloc+0xe2>
 988:	7902                	ld	s2,32(sp)
 98a:	6a42                	ld	s4,16(sp)
 98c:	6aa2                	ld	s5,8(sp)
 98e:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 990:	fae48de3          	beq	s1,a4,94a <malloc+0x78>
        p->s.size -= nunits;
 994:	4137073b          	subw	a4,a4,s3
 998:	c798                	sw	a4,8(a5)
        p += p->s.size;
 99a:	02071693          	slli	a3,a4,0x20
 99e:	01c6d713          	srli	a4,a3,0x1c
 9a2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9a4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9a8:	00000717          	auipc	a4,0x0
 9ac:	64a73c23          	sd	a0,1624(a4) # 1000 <freep>
      return (void *)(p + 1);
 9b0:	01078513          	addi	a0,a5,16
  }
}
 9b4:	70e2                	ld	ra,56(sp)
 9b6:	7442                	ld	s0,48(sp)
 9b8:	74a2                	ld	s1,40(sp)
 9ba:	69e2                	ld	s3,24(sp)
 9bc:	6121                	addi	sp,sp,64
 9be:	8082                	ret
 9c0:	7902                	ld	s2,32(sp)
 9c2:	6a42                	ld	s4,16(sp)
 9c4:	6aa2                	ld	s5,8(sp)
 9c6:	6b02                	ld	s6,0(sp)
 9c8:	b7f5                	j	9b4 <malloc+0xe2>
