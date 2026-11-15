
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  [3] "runnable",
  [4] "running",
  [5] "zombie"
};

int main(int argc, char *argv[]) {
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7f010413          	addi	s0,sp,2032
  20:	dc010113          	addi	sp,sp,-576
    struct uproc buf[64];
    int count = getprocs(buf, 64);
  24:	757d                	lui	a0,0xfffff
  26:	04000593          	li	a1,64
  2a:	5d050793          	addi	a5,a0,1488 # fffffffffffff5d0 <base+0xffffffffffffe590>
  2e:	00878533          	add	a0,a5,s0
  32:	3d2000ef          	jal	404 <getprocs>
    if(count < 0) {
  36:	06054363          	bltz	a0,9c <main+0x9c>
  3a:	892a                	mv	s2,a0
        fprintf(2, "ps: failed to fetch process states\n");
        exit(1);
    }

    // Print header using explicit single-tab layouts matching specs
    printf("PID\tPPID\tSTATE\tSIZE\tNAME\n");
  3c:	00001517          	auipc	a0,0x1
  40:	92c50513          	addi	a0,a0,-1748 # 968 <malloc+0x120>
  44:	750000ef          	jal	794 <printf>
    for(int i = 0; i < count; i++) {
  48:	05205763          	blez	s2,96 <main+0x96>
  4c:	74fd                	lui	s1,0xfffff
  4e:	5e848793          	addi	a5,s1,1512 # fffffffffffff5e8 <base+0xffffffffffffe5a8>
  52:	008784b3          	add	s1,a5,s0
  56:	02800793          	li	a5,40
  5a:	02f90933          	mul	s2,s2,a5
  5e:	9926                	add	s2,s2,s1
        printf("%d\t%d\t%s\t%lu\t%s\n", 
  60:	00001a17          	auipc	s4,0x1
  64:	fa0a0a13          	addi	s4,s4,-96 # 1000 <states>
  68:	00001997          	auipc	s3,0x1
  6c:	92098993          	addi	s3,s3,-1760 # 988 <malloc+0x140>
  70:	ff04a683          	lw	a3,-16(s1)
  74:	068e                	slli	a3,a3,0x3
  76:	96d2                	add	a3,a3,s4
  78:	87a6                	mv	a5,s1
  7a:	ff84b703          	ld	a4,-8(s1)
  7e:	6294                	ld	a3,0(a3)
  80:	fec4a603          	lw	a2,-20(s1)
  84:	fe84a583          	lw	a1,-24(s1)
  88:	854e                	mv	a0,s3
  8a:	70a000ef          	jal	794 <printf>
    for(int i = 0; i < count; i++) {
  8e:	02848493          	addi	s1,s1,40
  92:	fd249fe3          	bne	s1,s2,70 <main+0x70>
               buf[i].ppid, 
               states[buf[i].state], 
               buf[i].sz, 
               buf[i].name);
    }
    exit(0);
  96:	4501                	li	a0,0
  98:	2ac000ef          	jal	344 <exit>
        fprintf(2, "ps: failed to fetch process states\n");
  9c:	00001597          	auipc	a1,0x1
  a0:	8a458593          	addi	a1,a1,-1884 # 940 <malloc+0xf8>
  a4:	4509                	li	a0,2
  a6:	6c4000ef          	jal	76a <fprintf>
        exit(1);
  aa:	4505                	li	a0,1
  ac:	298000ef          	jal	344 <exit>

00000000000000b0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e406                	sd	ra,8(sp)
  b4:	e022                	sd	s0,0(sp)
  b6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  b8:	f49ff0ef          	jal	0 <main>
  exit(r);
  bc:	288000ef          	jal	344 <exit>

00000000000000c0 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb91                	beqz	a5,fa <strcmp+0x1e>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71763          	bne	a4,a5,fa <strcmp+0x1e>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbe5                	bnez	a5,e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fa:	0005c503          	lbu	a0,0(a1)
}
  fe:	40a7853b          	subw	a0,a5,a0
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strlen>:

uint
strlen(const char *s)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x26>
 114:	0505                	addi	a0,a0,1
 116:	87aa                	mv	a5,a0
 118:	86be                	mv	a3,a5
 11a:	0785                	addi	a5,a5,1
 11c:	fff7c703          	lbu	a4,-1(a5)
 120:	ff65                	bnez	a4,118 <strlen+0x10>
 122:	40a6853b          	subw	a0,a3,a0
 126:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for (n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strlen+0x20>

0000000000000132 <memset>:

void *
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 138:	ca19                	beqz	a2,14e <memset+0x1c>
 13a:	87aa                	mv	a5,a0
 13c:	1602                	slli	a2,a2,0x20
 13e:	9201                	srli	a2,a2,0x20
 140:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 144:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 148:	0785                	addi	a5,a5,1
 14a:	fee79de3          	bne	a5,a4,144 <memset+0x12>
  }
  return dst;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strchr>:

char *
strchr(const char *s, char c)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  for (; *s; s++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb99                	beqz	a5,174 <strchr+0x20>
    if (*s == c)
 160:	00f58763          	beq	a1,a5,16e <strchr+0x1a>
  for (; *s; s++)
 164:	0505                	addi	a0,a0,1
 166:	00054783          	lbu	a5,0(a0)
 16a:	fbfd                	bnez	a5,160 <strchr+0xc>
      return (char *)s;
  return 0;
 16c:	4501                	li	a0,0
}
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  return 0;
 174:	4501                	li	a0,0
 176:	bfe5                	j	16e <strchr+0x1a>

0000000000000178 <gets>:

char *
gets(char *buf, int max)
{
 178:	711d                	addi	sp,sp,-96
 17a:	ec86                	sd	ra,88(sp)
 17c:	e8a2                	sd	s0,80(sp)
 17e:	e4a6                	sd	s1,72(sp)
 180:	e0ca                	sd	s2,64(sp)
 182:	fc4e                	sd	s3,56(sp)
 184:	f852                	sd	s4,48(sp)
 186:	f456                	sd	s5,40(sp)
 188:	f05a                	sd	s6,32(sp)
 18a:	ec5e                	sd	s7,24(sp)
 18c:	1080                	addi	s0,sp,96
 18e:	8baa                	mv	s7,a0
 190:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 192:	892a                	mv	s2,a0
 194:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 196:	4aa9                	li	s5,10
 198:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 19a:	89a6                	mv	s3,s1
 19c:	2485                	addiw	s1,s1,1
 19e:	0344d663          	bge	s1,s4,1ca <gets+0x52>
    cc = read(0, &c, 1);
 1a2:	4605                	li	a2,1
 1a4:	faf40593          	addi	a1,s0,-81
 1a8:	4501                	li	a0,0
 1aa:	1b2000ef          	jal	35c <read>
    if (cc < 1)
 1ae:	00a05e63          	blez	a0,1ca <gets+0x52>
    buf[i++] = c;
 1b2:	faf44783          	lbu	a5,-81(s0)
 1b6:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1ba:	01578763          	beq	a5,s5,1c8 <gets+0x50>
 1be:	0905                	addi	s2,s2,1
 1c0:	fd679de3          	bne	a5,s6,19a <gets+0x22>
    buf[i++] = c;
 1c4:	89a6                	mv	s3,s1
 1c6:	a011                	j	1ca <gets+0x52>
 1c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ca:	99de                	add	s3,s3,s7
 1cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d0:	855e                	mv	a0,s7
 1d2:	60e6                	ld	ra,88(sp)
 1d4:	6446                	ld	s0,80(sp)
 1d6:	64a6                	ld	s1,72(sp)
 1d8:	6906                	ld	s2,64(sp)
 1da:	79e2                	ld	s3,56(sp)
 1dc:	7a42                	ld	s4,48(sp)
 1de:	7aa2                	ld	s5,40(sp)
 1e0:	7b02                	ld	s6,32(sp)
 1e2:	6be2                	ld	s7,24(sp)
 1e4:	6125                	addi	sp,sp,96
 1e6:	8082                	ret

00000000000001e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e8:	1101                	addi	sp,sp,-32
 1ea:	ec06                	sd	ra,24(sp)
 1ec:	e822                	sd	s0,16(sp)
 1ee:	e04a                	sd	s2,0(sp)
 1f0:	1000                	addi	s0,sp,32
 1f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	4581                	li	a1,0
 1f6:	18e000ef          	jal	384 <open>
  if (fd < 0)
 1fa:	02054263          	bltz	a0,21e <stat+0x36>
 1fe:	e426                	sd	s1,8(sp)
 200:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 202:	85ca                	mv	a1,s2
 204:	198000ef          	jal	39c <fstat>
 208:	892a                	mv	s2,a0
  close(fd);
 20a:	8526                	mv	a0,s1
 20c:	160000ef          	jal	36c <close>
  return r;
 210:	64a2                	ld	s1,8(sp)
}
 212:	854a                	mv	a0,s2
 214:	60e2                	ld	ra,24(sp)
 216:	6442                	ld	s0,16(sp)
 218:	6902                	ld	s2,0(sp)
 21a:	6105                	addi	sp,sp,32
 21c:	8082                	ret
    return -1;
 21e:	597d                	li	s2,-1
 220:	bfcd                	j	212 <stat+0x2a>

0000000000000222 <atoi>:

int
atoi(const char *s)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 228:	00054683          	lbu	a3,0(a0)
 22c:	fd06879b          	addiw	a5,a3,-48
 230:	0ff7f793          	zext.b	a5,a5
 234:	4625                	li	a2,9
 236:	02f66863          	bltu	a2,a5,266 <atoi+0x44>
 23a:	872a                	mv	a4,a0
  n = 0;
 23c:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 23e:	0705                	addi	a4,a4,1
 240:	0025179b          	slliw	a5,a0,0x2
 244:	9fa9                	addw	a5,a5,a0
 246:	0017979b          	slliw	a5,a5,0x1
 24a:	9fb5                	addw	a5,a5,a3
 24c:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 250:	00074683          	lbu	a3,0(a4)
 254:	fd06879b          	addiw	a5,a3,-48
 258:	0ff7f793          	zext.b	a5,a5
 25c:	fef671e3          	bgeu	a2,a5,23e <atoi+0x1c>
  return n;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  n = 0;
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <atoi+0x3e>

000000000000026a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 270:	02b57463          	bgeu	a0,a1,298 <memmove+0x2e>
    while (n-- > 0)
 274:	00c05f63          	blez	a2,292 <memmove+0x28>
 278:	1602                	slli	a2,a2,0x20
 27a:	9201                	srli	a2,a2,0x20
 27c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 280:	872a                	mv	a4,a0
      *dst++ = *src++;
 282:	0585                	addi	a1,a1,1
 284:	0705                	addi	a4,a4,1
 286:	fff5c683          	lbu	a3,-1(a1)
 28a:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 28e:	fef71ae3          	bne	a4,a5,282 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
    dst += n;
 298:	00c50733          	add	a4,a0,a2
    src += n;
 29c:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 29e:	fec05ae3          	blez	a2,292 <memmove+0x28>
 2a2:	fff6079b          	addiw	a5,a2,-1
 2a6:	1782                	slli	a5,a5,0x20
 2a8:	9381                	srli	a5,a5,0x20
 2aa:	fff7c793          	not	a5,a5
 2ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b0:	15fd                	addi	a1,a1,-1
 2b2:	177d                	addi	a4,a4,-1
 2b4:	0005c683          	lbu	a3,0(a1)
 2b8:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 2bc:	fee79ae3          	bne	a5,a4,2b0 <memmove+0x46>
 2c0:	bfc9                	j	292 <memmove+0x28>

00000000000002c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c8:	ca05                	beqz	a2,2f8 <memcmp+0x36>
 2ca:	fff6069b          	addiw	a3,a2,-1
 2ce:	1682                	slli	a3,a3,0x20
 2d0:	9281                	srli	a3,a3,0x20
 2d2:	0685                	addi	a3,a3,1
 2d4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00e79863          	bne	a5,a4,2ee <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e2:	0505                	addi	a0,a0,1
    p2++;
 2e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e6:	fed518e3          	bne	a0,a3,2d6 <memcmp+0x14>
  }
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	a019                	j	2f2 <memcmp+0x30>
      return *p1 - *p2;
 2ee:	40e7853b          	subw	a0,a5,a4
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	bfe5                	j	2f2 <memcmp+0x30>

00000000000002fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e406                	sd	ra,8(sp)
 300:	e022                	sd	s0,0(sp)
 302:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 304:	f67ff0ef          	jal	26a <memmove>
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <sbrk>:

char *
sbrk(int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 318:	4585                	li	a1,1
 31a:	0b2000ef          	jal	3cc <sys_sbrk>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <sbrklazy>:

char *
sbrklazy(int n)
{
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 32e:	4589                	li	a1,2
 330:	09c000ef          	jal	3cc <sys_sbrk>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33c:	4885                	li	a7,1
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exit>:
.global exit
exit:
 li a7, SYS_exit
 344:	4889                	li	a7,2
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <wait>:
.global wait
wait:
 li a7, SYS_wait
 34c:	488d                	li	a7,3
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 354:	4891                	li	a7,4
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <read>:
.global read
read:
 li a7, SYS_read
 35c:	4895                	li	a7,5
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <write>:
.global write
write:
 li a7, SYS_write
 364:	48c1                	li	a7,16
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <close>:
.global close
close:
 li a7, SYS_close
 36c:	48d5                	li	a7,21
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <kill>:
.global kill
kill:
 li a7, SYS_kill
 374:	4899                	li	a7,6
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exec>:
.global exec
exec:
 li a7, SYS_exec
 37c:	489d                	li	a7,7
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <open>:
.global open
open:
 li a7, SYS_open
 384:	48bd                	li	a7,15
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38c:	48c5                	li	a7,17
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 394:	48c9                	li	a7,18
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39c:	48a1                	li	a7,8
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <link>:
.global link
link:
 li a7, SYS_link
 3a4:	48cd                	li	a7,19
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ac:	48d1                	li	a7,20
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b4:	48a5                	li	a7,9
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3bc:	48a9                	li	a7,10
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c4:	48ad                	li	a7,11
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3cc:	48b1                	li	a7,12
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d4:	48b5                	li	a7,13
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3dc:	48b9                	li	a7,14
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sync>:
.global sync
sync:
 li a7, SYS_sync
 3e4:	48d9                	li	a7,22
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3ec:	48dd                	li	a7,23
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3f4:	48e1                	li	a7,24
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3fc:	48e5                	li	a7,25
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 404:	48e9                	li	a7,26
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	addi	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	addi	a1,s0,-17
 41e:	f47ff0ef          	jal	364 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42a:	715d                	addi	sp,sp,-80
 42c:	e486                	sd	ra,72(sp)
 42e:	e0a2                	sd	s0,64(sp)
 430:	f84a                	sd	s2,48(sp)
 432:	0880                	addi	s0,sp,80
 434:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 436:	c299                	beqz	a3,43c <printint+0x12>
 438:	0805c363          	bltz	a1,4be <printint+0x94>
  neg = 0;
 43c:	4881                	li	a7,0
 43e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 442:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 444:	00000517          	auipc	a0,0x0
 448:	5a450513          	addi	a0,a0,1444 # 9e8 <digits>
 44c:	883e                	mv	a6,a5
 44e:	2785                	addiw	a5,a5,1
 450:	02c5f733          	remu	a4,a1,a2
 454:	972a                	add	a4,a4,a0
 456:	00074703          	lbu	a4,0(a4)
 45a:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 45e:	872e                	mv	a4,a1
 460:	02c5d5b3          	divu	a1,a1,a2
 464:	0685                	addi	a3,a3,1
 466:	fec773e3          	bgeu	a4,a2,44c <printint+0x22>
  if (neg)
 46a:	00088b63          	beqz	a7,480 <printint+0x56>
    buf[i++] = '-';
 46e:	fd078793          	addi	a5,a5,-48
 472:	97a2                	add	a5,a5,s0
 474:	02d00713          	li	a4,45
 478:	fee78423          	sb	a4,-24(a5)
 47c:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 480:	02f05a63          	blez	a5,4b4 <printint+0x8a>
 484:	fc26                	sd	s1,56(sp)
 486:	f44e                	sd	s3,40(sp)
 488:	fb840713          	addi	a4,s0,-72
 48c:	00f704b3          	add	s1,a4,a5
 490:	fff70993          	addi	s3,a4,-1
 494:	99be                	add	s3,s3,a5
 496:	37fd                	addiw	a5,a5,-1
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4a0:	fff4c583          	lbu	a1,-1(s1)
 4a4:	854a                	mv	a0,s2
 4a6:	f67ff0ef          	jal	40c <putc>
  while (--i >= 0)
 4aa:	14fd                	addi	s1,s1,-1
 4ac:	ff349ae3          	bne	s1,s3,4a0 <printint+0x76>
 4b0:	74e2                	ld	s1,56(sp)
 4b2:	79a2                	ld	s3,40(sp)
}
 4b4:	60a6                	ld	ra,72(sp)
 4b6:	6406                	ld	s0,64(sp)
 4b8:	7942                	ld	s2,48(sp)
 4ba:	6161                	addi	sp,sp,80
 4bc:	8082                	ret
    x = -xx;
 4be:	40b005b3          	neg	a1,a1
    neg = 1;
 4c2:	4885                	li	a7,1
    x = -xx;
 4c4:	bfad                	j	43e <printint+0x14>

00000000000004c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c6:	711d                	addi	sp,sp,-96
 4c8:	ec86                	sd	ra,88(sp)
 4ca:	e8a2                	sd	s0,80(sp)
 4cc:	e0ca                	sd	s2,64(sp)
 4ce:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 4d0:	0005c903          	lbu	s2,0(a1)
 4d4:	28090663          	beqz	s2,760 <vprintf+0x29a>
 4d8:	e4a6                	sd	s1,72(sp)
 4da:	fc4e                	sd	s3,56(sp)
 4dc:	f852                	sd	s4,48(sp)
 4de:	f456                	sd	s5,40(sp)
 4e0:	f05a                	sd	s6,32(sp)
 4e2:	ec5e                	sd	s7,24(sp)
 4e4:	e862                	sd	s8,16(sp)
 4e6:	e466                	sd	s9,8(sp)
 4e8:	8b2a                	mv	s6,a0
 4ea:	8a2e                	mv	s4,a1
 4ec:	8bb2                	mv	s7,a2
  state = 0;
 4ee:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 4f0:	4481                	li	s1,0
 4f2:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 4f4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 4f8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4fc:	06c00c93          	li	s9,108
 500:	a005                	j	520 <vprintf+0x5a>
        putc(fd, c0);
 502:	85ca                	mv	a1,s2
 504:	855a                	mv	a0,s6
 506:	f07ff0ef          	jal	40c <putc>
 50a:	a019                	j	510 <vprintf+0x4a>
    } else if (state == '%') {
 50c:	03598263          	beq	s3,s5,530 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 510:	2485                	addiw	s1,s1,1
 512:	8726                	mv	a4,s1
 514:	009a07b3          	add	a5,s4,s1
 518:	0007c903          	lbu	s2,0(a5)
 51c:	22090a63          	beqz	s2,750 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 520:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 524:	fe0994e3          	bnez	s3,50c <vprintf+0x46>
      if (c0 == '%') {
 528:	fd579de3          	bne	a5,s5,502 <vprintf+0x3c>
        state = '%';
 52c:	89be                	mv	s3,a5
 52e:	b7cd                	j	510 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 530:	00ea06b3          	add	a3,s4,a4
 534:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 538:	8636                	mv	a2,a3
      if (c1)
 53a:	c681                	beqz	a3,542 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 53c:	9752                	add	a4,a4,s4
 53e:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 542:	05878363          	beq	a5,s8,588 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 546:	05978d63          	beq	a5,s9,5a0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 54a:	07500713          	li	a4,117
 54e:	0ee78763          	beq	a5,a4,63c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 552:	07800713          	li	a4,120
 556:	12e78963          	beq	a5,a4,688 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 55a:	07000713          	li	a4,112
 55e:	14e78e63          	beq	a5,a4,6ba <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 562:	06300713          	li	a4,99
 566:	18e78e63          	beq	a5,a4,702 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 56a:	07300713          	li	a4,115
 56e:	1ae78463          	beq	a5,a4,716 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 572:	02500713          	li	a4,37
 576:	04e79563          	bne	a5,a4,5c0 <vprintf+0xfa>
        putc(fd, '%');
 57a:	02500593          	li	a1,37
 57e:	855a                	mv	a0,s6
 580:	e8dff0ef          	jal	40c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 584:	4981                	li	s3,0
 586:	b769                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 588:	008b8913          	addi	s2,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000ba583          	lw	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	e95ff0ef          	jal	42a <printint>
 59a:	8bca                	mv	s7,s2
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bf8d                	j	510 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 5a0:	06400793          	li	a5,100
 5a4:	02f68963          	beq	a3,a5,5d6 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5a8:	06c00793          	li	a5,108
 5ac:	04f68263          	beq	a3,a5,5f0 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 5b0:	07500793          	li	a5,117
 5b4:	0af68063          	beq	a3,a5,654 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 5b8:	07800793          	li	a5,120
 5bc:	0ef68263          	beq	a3,a5,6a0 <vprintf+0x1da>
        putc(fd, '%');
 5c0:	02500593          	li	a1,37
 5c4:	855a                	mv	a0,s6
 5c6:	e47ff0ef          	jal	40c <putc>
        putc(fd, c0);
 5ca:	85ca                	mv	a1,s2
 5cc:	855a                	mv	a0,s6
 5ce:	e3fff0ef          	jal	40c <putc>
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bf35                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000bb583          	ld	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e47ff0ef          	jal	42a <printint>
        i += 1;
 5e8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
        i += 1;
 5ee:	b70d                	j	510 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5f0:	06400793          	li	a5,100
 5f4:	02f60763          	beq	a2,a5,622 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 5f8:	07500793          	li	a5,117
 5fc:	06f60963          	beq	a2,a5,66e <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 600:	07800793          	li	a5,120
 604:	faf61ee3          	bne	a2,a5,5c0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e15ff0ef          	jal	42a <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	bdc5                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	008b8913          	addi	s2,s7,8
 626:	4685                	li	a3,1
 628:	4629                	li	a2,10
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	dfbff0ef          	jal	42a <printint>
        i += 2;
 634:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bdd9                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4629                	li	a2,10
 644:	000be583          	lwu	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	de1ff0ef          	jal	42a <printint>
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bd7d                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	dc9ff0ef          	jal	42a <printint>
        i += 1;
 666:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	b555                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	dafff0ef          	jal	42a <printint>
        i += 2;
 680:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
        i += 2;
 686:	b569                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000be583          	lwu	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	d95ff0ef          	jal	42a <printint>
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bd8d                	j	510 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d7dff0ef          	jal	42a <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	bda1                	j	510 <vprintf+0x4a>
 6ba:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6bc:	008b8d13          	addi	s10,s7,8
 6c0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c4:	03000593          	li	a1,48
 6c8:	855a                	mv	a0,s6
 6ca:	d43ff0ef          	jal	40c <putc>
  putc(fd, 'x');
 6ce:	07800593          	li	a1,120
 6d2:	855a                	mv	a0,s6
 6d4:	d39ff0ef          	jal	40c <putc>
 6d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6da:	00000b97          	auipc	s7,0x0
 6de:	30eb8b93          	addi	s7,s7,782 # 9e8 <digits>
 6e2:	03c9d793          	srli	a5,s3,0x3c
 6e6:	97de                	add	a5,a5,s7
 6e8:	0007c583          	lbu	a1,0(a5)
 6ec:	855a                	mv	a0,s6
 6ee:	d1fff0ef          	jal	40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f2:	0992                	slli	s3,s3,0x4
 6f4:	397d                	addiw	s2,s2,-1
 6f6:	fe0916e3          	bnez	s2,6e2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6fa:	8bea                	mv	s7,s10
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	6d02                	ld	s10,0(sp)
 700:	bd01                	j	510 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 702:	008b8913          	addi	s2,s7,8
 706:	000bc583          	lbu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	d01ff0ef          	jal	40c <putc>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bbf5                	j	510 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 716:	008b8993          	addi	s3,s7,8
 71a:	000bb903          	ld	s2,0(s7)
 71e:	00090f63          	beqz	s2,73c <vprintf+0x276>
        for (; *s; s++)
 722:	00094583          	lbu	a1,0(s2)
 726:	c195                	beqz	a1,74a <vprintf+0x284>
          putc(fd, *s);
 728:	855a                	mv	a0,s6
 72a:	ce3ff0ef          	jal	40c <putc>
        for (; *s; s++)
 72e:	0905                	addi	s2,s2,1
 730:	00094583          	lbu	a1,0(s2)
 734:	f9f5                	bnez	a1,728 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 736:	8bce                	mv	s7,s3
      state = 0;
 738:	4981                	li	s3,0
 73a:	bbd9                	j	510 <vprintf+0x4a>
          s = "(null)";
 73c:	00000917          	auipc	s2,0x0
 740:	2a490913          	addi	s2,s2,676 # 9e0 <malloc+0x198>
        for (; *s; s++)
 744:	02800593          	li	a1,40
 748:	b7c5                	j	728 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b3c9                	j	510 <vprintf+0x4a>
 750:	64a6                	ld	s1,72(sp)
 752:	79e2                	ld	s3,56(sp)
 754:	7a42                	ld	s4,48(sp)
 756:	7aa2                	ld	s5,40(sp)
 758:	7b02                	ld	s6,32(sp)
 75a:	6be2                	ld	s7,24(sp)
 75c:	6c42                	ld	s8,16(sp)
 75e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 760:	60e6                	ld	ra,88(sp)
 762:	6446                	ld	s0,80(sp)
 764:	6906                	ld	s2,64(sp)
 766:	6125                	addi	sp,sp,96
 768:	8082                	ret

000000000000076a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76a:	715d                	addi	sp,sp,-80
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e010                	sd	a2,0(s0)
 774:	e414                	sd	a3,8(s0)
 776:	e818                	sd	a4,16(s0)
 778:	ec1c                	sd	a5,24(s0)
 77a:	03043023          	sd	a6,32(s0)
 77e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 786:	8622                	mv	a2,s0
 788:	d3fff0ef          	jal	4c6 <vprintf>
}
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret

0000000000000794 <printf>:

void
printf(const char *fmt, ...)
{
 794:	711d                	addi	sp,sp,-96
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e40c                	sd	a1,8(s0)
 79e:	e810                	sd	a2,16(s0)
 7a0:	ec14                	sd	a3,24(s0)
 7a2:	f018                	sd	a4,32(s0)
 7a4:	f41c                	sd	a5,40(s0)
 7a6:	03043823          	sd	a6,48(s0)
 7aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	00840613          	addi	a2,s0,8
 7b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b6:	85aa                	mv	a1,a0
 7b8:	4505                	li	a0,1
 7ba:	d0dff0ef          	jal	4c6 <vprintf>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6125                	addi	sp,sp,96
 7c4:	8082                	ret

00000000000007c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c6:	1141                	addi	sp,sp,-16
 7c8:	e422                	sd	s0,8(sp)
 7ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 7cc:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	00001797          	auipc	a5,0x1
 7d4:	8607b783          	ld	a5,-1952(a5) # 1030 <freep>
 7d8:	a02d                	j	802 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 7da:	4618                	lw	a4,8(a2)
 7dc:	9f2d                	addw	a4,a4,a1
 7de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e2:	6398                	ld	a4,0(a5)
 7e4:	6310                	ld	a2,0(a4)
 7e6:	a83d                	j	824 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 7e8:	ff852703          	lw	a4,-8(a0)
 7ec:	9f31                	addw	a4,a4,a2
 7ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f0:	ff053683          	ld	a3,-16(a0)
 7f4:	a091                	j	838 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e7e463          	bltu	a5,a4,800 <free+0x3a>
 7fc:	00e6ea63          	bltu	a3,a4,810 <free+0x4a>
{
 800:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	fed7fae3          	bgeu	a5,a3,7f6 <free+0x30>
 806:	6398                	ld	a4,0(a5)
 808:	00e6e463          	bltu	a3,a4,810 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	fee7eae3          	bltu	a5,a4,800 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 810:	ff852583          	lw	a1,-8(a0)
 814:	6390                	ld	a2,0(a5)
 816:	02059813          	slli	a6,a1,0x20
 81a:	01c85713          	srli	a4,a6,0x1c
 81e:	9736                	add	a4,a4,a3
 820:	fae60de3          	beq	a2,a4,7da <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 824:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 828:	4790                	lw	a2,8(a5)
 82a:	02061593          	slli	a1,a2,0x20
 82e:	01c5d713          	srli	a4,a1,0x1c
 832:	973e                	add	a4,a4,a5
 834:	fae68ae3          	beq	a3,a4,7e8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 838:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83a:	00000717          	auipc	a4,0x0
 83e:	7ef73b23          	sd	a5,2038(a4) # 1030 <freep>
}
 842:	6422                	ld	s0,8(sp)
 844:	0141                	addi	sp,sp,16
 846:	8082                	ret

0000000000000848 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 848:	7139                	addi	sp,sp,-64
 84a:	fc06                	sd	ra,56(sp)
 84c:	f822                	sd	s0,48(sp)
 84e:	f426                	sd	s1,40(sp)
 850:	ec4e                	sd	s3,24(sp)
 852:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 854:	02051493          	slli	s1,a0,0x20
 858:	9081                	srli	s1,s1,0x20
 85a:	04bd                	addi	s1,s1,15
 85c:	8091                	srli	s1,s1,0x4
 85e:	0014899b          	addiw	s3,s1,1
 862:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 864:	00000517          	auipc	a0,0x0
 868:	7cc53503          	ld	a0,1996(a0) # 1030 <freep>
 86c:	c915                	beqz	a0,8a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 86e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 870:	4798                	lw	a4,8(a5)
 872:	08977a63          	bgeu	a4,s1,906 <malloc+0xbe>
 876:	f04a                	sd	s2,32(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 87e:	8a4e                	mv	s4,s3
 880:	0009871b          	sext.w	a4,s3
 884:	6685                	lui	a3,0x1
 886:	00d77363          	bgeu	a4,a3,88c <malloc+0x44>
 88a:	6a05                	lui	s4,0x1
 88c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 890:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 894:	00000917          	auipc	s2,0x0
 898:	79c90913          	addi	s2,s2,1948 # 1030 <freep>
  if (p == SBRK_ERROR)
 89c:	5afd                	li	s5,-1
 89e:	a081                	j	8de <malloc+0x96>
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a8:	00000797          	auipc	a5,0x0
 8ac:	79878793          	addi	a5,a5,1944 # 1040 <base>
 8b0:	00000717          	auipc	a4,0x0
 8b4:	78f73023          	sd	a5,1920(a4) # 1030 <freep>
 8b8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ba:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 8be:	b7c1                	j	87e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	e118                	sd	a4,0(a0)
 8c4:	a8a9                	j	91e <malloc+0xd6>
  hp->s.size = nu;
 8c6:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 8ca:	0541                	addi	a0,a0,16
 8cc:	efbff0ef          	jal	7c6 <free>
  return freep;
 8d0:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 8d4:	c12d                	beqz	a0,936 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8d6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8d8:	4798                	lw	a4,8(a5)
 8da:	02977263          	bgeu	a4,s1,8fe <malloc+0xb6>
    if (p == freep)
 8de:	00093703          	ld	a4,0(s2)
 8e2:	853e                	mv	a0,a5
 8e4:	fef719e3          	bne	a4,a5,8d6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	a27ff0ef          	jal	310 <sbrk>
  if (p == SBRK_ERROR)
 8ee:	fd551ce3          	bne	a0,s5,8c6 <malloc+0x7e>
        return 0;
 8f2:	4501                	li	a0,0
 8f4:	7902                	ld	s2,32(sp)
 8f6:	6a42                	ld	s4,16(sp)
 8f8:	6aa2                	ld	s5,8(sp)
 8fa:	6b02                	ld	s6,0(sp)
 8fc:	a03d                	j	92a <malloc+0xe2>
 8fe:	7902                	ld	s2,32(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 906:	fae48de3          	beq	s1,a4,8c0 <malloc+0x78>
        p->s.size -= nunits;
 90a:	4137073b          	subw	a4,a4,s3
 90e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 910:	02071693          	slli	a3,a4,0x20
 914:	01c6d713          	srli	a4,a3,0x1c
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	70a73923          	sd	a0,1810(a4) # 1030 <freep>
      return (void *)(p + 1);
 926:	01078513          	addi	a0,a5,16
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	74a2                	ld	s1,40(sp)
 930:	69e2                	ld	s3,24(sp)
 932:	6121                	addi	sp,sp,64
 934:	8082                	ret
 936:	7902                	ld	s2,32(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
 93e:	b7f5                	j	92a <malloc+0xe2>
