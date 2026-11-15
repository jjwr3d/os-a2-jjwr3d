
user/_trace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    if (argc < 3) {
   8:	4789                	li	a5,2
   a:	00a7cd63          	blt	a5,a0,24 <main+0x24>
   e:	e426                	sd	s1,8(sp)
        fprintf(2, "usage: trace <mask> <cmd> [args...]\n");
  10:	00001597          	auipc	a1,0x1
  14:	8f058593          	addi	a1,a1,-1808 # 900 <malloc+0x100>
  18:	4509                	li	a0,2
  1a:	708000ef          	jal	722 <fprintf>
        exit(1);
  1e:	4505                	li	a0,1
  20:	2dc000ef          	jal	2fc <exit>
  24:	e426                	sd	s1,8(sp)
  26:	84ae                	mv	s1,a1
    }

    int mask = atoi(argv[1]);
  28:	6588                	ld	a0,8(a1)
  2a:	1b0000ef          	jal	1da <atoi>
    if (trace(mask) < 0) {
  2e:	37e000ef          	jal	3ac <trace>
  32:	02054163          	bltz	a0,54 <main+0x54>
        fprintf(2, "trace: failed to set mask\n");
        exit(1);
    }

    // Shift user land command execution vector past trace arguments
    exec(argv[2], &argv[2]);
  36:	01048593          	addi	a1,s1,16
  3a:	6888                	ld	a0,16(s1)
  3c:	2f8000ef          	jal	334 <exec>
    
    fprintf(2, "trace: exec failed\n");
  40:	00001597          	auipc	a1,0x1
  44:	90858593          	addi	a1,a1,-1784 # 948 <malloc+0x148>
  48:	4509                	li	a0,2
  4a:	6d8000ef          	jal	722 <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	2ac000ef          	jal	2fc <exit>
        fprintf(2, "trace: failed to set mask\n");
  54:	00001597          	auipc	a1,0x1
  58:	8d458593          	addi	a1,a1,-1836 # 928 <malloc+0x128>
  5c:	4509                	li	a0,2
  5e:	6c4000ef          	jal	722 <fprintf>
        exit(1);
  62:	4505                	li	a0,1
  64:	298000ef          	jal	2fc <exit>

0000000000000068 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  70:	f91ff0ef          	jal	0 <main>
  exit(r);
  74:	288000ef          	jal	2fc <exit>

0000000000000078 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  7e:	87aa                	mv	a5,a0
  80:	0585                	addi	a1,a1,1
  82:	0785                	addi	a5,a5,1
  84:	fff5c703          	lbu	a4,-1(a1)
  88:	fee78fa3          	sb	a4,-1(a5)
  8c:	fb75                	bnez	a4,80 <strcpy+0x8>
    ;
  return os;
}
  8e:	6422                	ld	s0,8(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  9a:	00054783          	lbu	a5,0(a0)
  9e:	cb91                	beqz	a5,b2 <strcmp+0x1e>
  a0:	0005c703          	lbu	a4,0(a1)
  a4:	00f71763          	bne	a4,a5,b2 <strcmp+0x1e>
    p++, q++;
  a8:	0505                	addi	a0,a0,1
  aa:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	fbe5                	bnez	a5,a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b2:	0005c503          	lbu	a0,0(a1)
}
  b6:	40a7853b          	subw	a0,a5,a0
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strlen>:

uint
strlen(const char *s)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cf91                	beqz	a5,e6 <strlen+0x26>
  cc:	0505                	addi	a0,a0,1
  ce:	87aa                	mv	a5,a0
  d0:	86be                	mv	a3,a5
  d2:	0785                	addi	a5,a5,1
  d4:	fff7c703          	lbu	a4,-1(a5)
  d8:	ff65                	bnez	a4,d0 <strlen+0x10>
  da:	40a6853b          	subw	a0,a3,a0
  de:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  for (n = 0; s[n]; n++)
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strlen+0x20>

00000000000000ea <memset>:

void *
memset(void *dst, int c, uint n)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  f0:	ca19                	beqz	a2,106 <memset+0x1c>
  f2:	87aa                	mv	a5,a0
  f4:	1602                	slli	a2,a2,0x20
  f6:	9201                	srli	a2,a2,0x20
  f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  fc:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 100:	0785                	addi	a5,a5,1
 102:	fee79de3          	bne	a5,a4,fc <memset+0x12>
  }
  return dst;
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret

000000000000010c <strchr>:

char *
strchr(const char *s, char c)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  for (; *s; s++)
 112:	00054783          	lbu	a5,0(a0)
 116:	cb99                	beqz	a5,12c <strchr+0x20>
    if (*s == c)
 118:	00f58763          	beq	a1,a5,126 <strchr+0x1a>
  for (; *s; s++)
 11c:	0505                	addi	a0,a0,1
 11e:	00054783          	lbu	a5,0(a0)
 122:	fbfd                	bnez	a5,118 <strchr+0xc>
      return (char *)s;
  return 0;
 124:	4501                	li	a0,0
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret
  return 0;
 12c:	4501                	li	a0,0
 12e:	bfe5                	j	126 <strchr+0x1a>

0000000000000130 <gets>:

char *
gets(char *buf, int max)
{
 130:	711d                	addi	sp,sp,-96
 132:	ec86                	sd	ra,88(sp)
 134:	e8a2                	sd	s0,80(sp)
 136:	e4a6                	sd	s1,72(sp)
 138:	e0ca                	sd	s2,64(sp)
 13a:	fc4e                	sd	s3,56(sp)
 13c:	f852                	sd	s4,48(sp)
 13e:	f456                	sd	s5,40(sp)
 140:	f05a                	sd	s6,32(sp)
 142:	ec5e                	sd	s7,24(sp)
 144:	1080                	addi	s0,sp,96
 146:	8baa                	mv	s7,a0
 148:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 14a:	892a                	mv	s2,a0
 14c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 14e:	4aa9                	li	s5,10
 150:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 152:	89a6                	mv	s3,s1
 154:	2485                	addiw	s1,s1,1
 156:	0344d663          	bge	s1,s4,182 <gets+0x52>
    cc = read(0, &c, 1);
 15a:	4605                	li	a2,1
 15c:	faf40593          	addi	a1,s0,-81
 160:	4501                	li	a0,0
 162:	1b2000ef          	jal	314 <read>
    if (cc < 1)
 166:	00a05e63          	blez	a0,182 <gets+0x52>
    buf[i++] = c;
 16a:	faf44783          	lbu	a5,-81(s0)
 16e:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 172:	01578763          	beq	a5,s5,180 <gets+0x50>
 176:	0905                	addi	s2,s2,1
 178:	fd679de3          	bne	a5,s6,152 <gets+0x22>
    buf[i++] = c;
 17c:	89a6                	mv	s3,s1
 17e:	a011                	j	182 <gets+0x52>
 180:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 182:	99de                	add	s3,s3,s7
 184:	00098023          	sb	zero,0(s3)
  return buf;
}
 188:	855e                	mv	a0,s7
 18a:	60e6                	ld	ra,88(sp)
 18c:	6446                	ld	s0,80(sp)
 18e:	64a6                	ld	s1,72(sp)
 190:	6906                	ld	s2,64(sp)
 192:	79e2                	ld	s3,56(sp)
 194:	7a42                	ld	s4,48(sp)
 196:	7aa2                	ld	s5,40(sp)
 198:	7b02                	ld	s6,32(sp)
 19a:	6be2                	ld	s7,24(sp)
 19c:	6125                	addi	sp,sp,96
 19e:	8082                	ret

00000000000001a0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a0:	1101                	addi	sp,sp,-32
 1a2:	ec06                	sd	ra,24(sp)
 1a4:	e822                	sd	s0,16(sp)
 1a6:	e04a                	sd	s2,0(sp)
 1a8:	1000                	addi	s0,sp,32
 1aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ac:	4581                	li	a1,0
 1ae:	18e000ef          	jal	33c <open>
  if (fd < 0)
 1b2:	02054263          	bltz	a0,1d6 <stat+0x36>
 1b6:	e426                	sd	s1,8(sp)
 1b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ba:	85ca                	mv	a1,s2
 1bc:	198000ef          	jal	354 <fstat>
 1c0:	892a                	mv	s2,a0
  close(fd);
 1c2:	8526                	mv	a0,s1
 1c4:	160000ef          	jal	324 <close>
  return r;
 1c8:	64a2                	ld	s1,8(sp)
}
 1ca:	854a                	mv	a0,s2
 1cc:	60e2                	ld	ra,24(sp)
 1ce:	6442                	ld	s0,16(sp)
 1d0:	6902                	ld	s2,0(sp)
 1d2:	6105                	addi	sp,sp,32
 1d4:	8082                	ret
    return -1;
 1d6:	597d                	li	s2,-1
 1d8:	bfcd                	j	1ca <stat+0x2a>

00000000000001da <atoi>:

int
atoi(const char *s)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 1e0:	00054683          	lbu	a3,0(a0)
 1e4:	fd06879b          	addiw	a5,a3,-48
 1e8:	0ff7f793          	zext.b	a5,a5
 1ec:	4625                	li	a2,9
 1ee:	02f66863          	bltu	a2,a5,21e <atoi+0x44>
 1f2:	872a                	mv	a4,a0
  n = 0;
 1f4:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1f6:	0705                	addi	a4,a4,1
 1f8:	0025179b          	slliw	a5,a0,0x2
 1fc:	9fa9                	addw	a5,a5,a0
 1fe:	0017979b          	slliw	a5,a5,0x1
 202:	9fb5                	addw	a5,a5,a3
 204:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 208:	00074683          	lbu	a3,0(a4)
 20c:	fd06879b          	addiw	a5,a3,-48
 210:	0ff7f793          	zext.b	a5,a5
 214:	fef671e3          	bgeu	a2,a5,1f6 <atoi+0x1c>
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  n = 0;
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <atoi+0x3e>

0000000000000222 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 228:	02b57463          	bgeu	a0,a1,250 <memmove+0x2e>
    while (n-- > 0)
 22c:	00c05f63          	blez	a2,24a <memmove+0x28>
 230:	1602                	slli	a2,a2,0x20
 232:	9201                	srli	a2,a2,0x20
 234:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 238:	872a                	mv	a4,a0
      *dst++ = *src++;
 23a:	0585                	addi	a1,a1,1
 23c:	0705                	addi	a4,a4,1
 23e:	fff5c683          	lbu	a3,-1(a1)
 242:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 246:	fef71ae3          	bne	a4,a5,23a <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
    dst += n;
 250:	00c50733          	add	a4,a0,a2
    src += n;
 254:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 256:	fec05ae3          	blez	a2,24a <memmove+0x28>
 25a:	fff6079b          	addiw	a5,a2,-1
 25e:	1782                	slli	a5,a5,0x20
 260:	9381                	srli	a5,a5,0x20
 262:	fff7c793          	not	a5,a5
 266:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 268:	15fd                	addi	a1,a1,-1
 26a:	177d                	addi	a4,a4,-1
 26c:	0005c683          	lbu	a3,0(a1)
 270:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 274:	fee79ae3          	bne	a5,a4,268 <memmove+0x46>
 278:	bfc9                	j	24a <memmove+0x28>

000000000000027a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 280:	ca05                	beqz	a2,2b0 <memcmp+0x36>
 282:	fff6069b          	addiw	a3,a2,-1
 286:	1682                	slli	a3,a3,0x20
 288:	9281                	srli	a3,a3,0x20
 28a:	0685                	addi	a3,a3,1
 28c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28e:	00054783          	lbu	a5,0(a0)
 292:	0005c703          	lbu	a4,0(a1)
 296:	00e79863          	bne	a5,a4,2a6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 29a:	0505                	addi	a0,a0,1
    p2++;
 29c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29e:	fed518e3          	bne	a0,a3,28e <memcmp+0x14>
  }
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	a019                	j	2aa <memcmp+0x30>
      return *p1 - *p2;
 2a6:	40e7853b          	subw	a0,a5,a4
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	bfe5                	j	2aa <memcmp+0x30>

00000000000002b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2bc:	f67ff0ef          	jal	222 <memmove>
}
 2c0:	60a2                	ld	ra,8(sp)
 2c2:	6402                	ld	s0,0(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <sbrk>:

char *
sbrk(int n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2d0:	4585                	li	a1,1
 2d2:	0b2000ef          	jal	384 <sys_sbrk>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <sbrklazy>:

char *
sbrklazy(int n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e406                	sd	ra,8(sp)
 2e2:	e022                	sd	s0,0(sp)
 2e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e6:	4589                	li	a1,2
 2e8:	09c000ef          	jal	384 <sys_sbrk>
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f4:	4885                	li	a7,1
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fc:	4889                	li	a7,2
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <wait>:
.global wait
wait:
 li a7, SYS_wait
 304:	488d                	li	a7,3
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30c:	4891                	li	a7,4
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <read>:
.global read
read:
 li a7, SYS_read
 314:	4895                	li	a7,5
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <write>:
.global write
write:
 li a7, SYS_write
 31c:	48c1                	li	a7,16
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <close>:
.global close
close:
 li a7, SYS_close
 324:	48d5                	li	a7,21
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <kill>:
.global kill
kill:
 li a7, SYS_kill
 32c:	4899                	li	a7,6
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exec>:
.global exec
exec:
 li a7, SYS_exec
 334:	489d                	li	a7,7
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <open>:
.global open
open:
 li a7, SYS_open
 33c:	48bd                	li	a7,15
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 344:	48c5                	li	a7,17
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34c:	48c9                	li	a7,18
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 354:	48a1                	li	a7,8
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <link>:
.global link
link:
 li a7, SYS_link
 35c:	48cd                	li	a7,19
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 364:	48d1                	li	a7,20
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36c:	48a5                	li	a7,9
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <dup>:
.global dup
dup:
 li a7, SYS_dup
 374:	48a9                	li	a7,10
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37c:	48ad                	li	a7,11
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 384:	48b1                	li	a7,12
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pause>:
.global pause
pause:
 li a7, SYS_pause
 38c:	48b5                	li	a7,13
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 394:	48b9                	li	a7,14
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sync>:
.global sync
sync:
 li a7, SYS_sync
 39c:	48d9                	li	a7,22
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3a4:	48dd                	li	a7,23
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <trace>:
.global trace
trace:
 li a7, SYS_trace
 3ac:	48e1                	li	a7,24
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3b4:	48e5                	li	a7,25
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 3bc:	48e9                	li	a7,26
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c4:	1101                	addi	sp,sp,-32
 3c6:	ec06                	sd	ra,24(sp)
 3c8:	e822                	sd	s0,16(sp)
 3ca:	1000                	addi	s0,sp,32
 3cc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d0:	4605                	li	a2,1
 3d2:	fef40593          	addi	a1,s0,-17
 3d6:	f47ff0ef          	jal	31c <write>
}
 3da:	60e2                	ld	ra,24(sp)
 3dc:	6442                	ld	s0,16(sp)
 3de:	6105                	addi	sp,sp,32
 3e0:	8082                	ret

00000000000003e2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3e2:	715d                	addi	sp,sp,-80
 3e4:	e486                	sd	ra,72(sp)
 3e6:	e0a2                	sd	s0,64(sp)
 3e8:	f84a                	sd	s2,48(sp)
 3ea:	0880                	addi	s0,sp,80
 3ec:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 3ee:	c299                	beqz	a3,3f4 <printint+0x12>
 3f0:	0805c363          	bltz	a1,476 <printint+0x94>
  neg = 0;
 3f4:	4881                	li	a7,0
 3f6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3fa:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 3fc:	00000517          	auipc	a0,0x0
 400:	56c50513          	addi	a0,a0,1388 # 968 <digits>
 404:	883e                	mv	a6,a5
 406:	2785                	addiw	a5,a5,1
 408:	02c5f733          	remu	a4,a1,a2
 40c:	972a                	add	a4,a4,a0
 40e:	00074703          	lbu	a4,0(a4)
 412:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 416:	872e                	mv	a4,a1
 418:	02c5d5b3          	divu	a1,a1,a2
 41c:	0685                	addi	a3,a3,1
 41e:	fec773e3          	bgeu	a4,a2,404 <printint+0x22>
  if (neg)
 422:	00088b63          	beqz	a7,438 <printint+0x56>
    buf[i++] = '-';
 426:	fd078793          	addi	a5,a5,-48
 42a:	97a2                	add	a5,a5,s0
 42c:	02d00713          	li	a4,45
 430:	fee78423          	sb	a4,-24(a5)
 434:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 438:	02f05a63          	blez	a5,46c <printint+0x8a>
 43c:	fc26                	sd	s1,56(sp)
 43e:	f44e                	sd	s3,40(sp)
 440:	fb840713          	addi	a4,s0,-72
 444:	00f704b3          	add	s1,a4,a5
 448:	fff70993          	addi	s3,a4,-1
 44c:	99be                	add	s3,s3,a5
 44e:	37fd                	addiw	a5,a5,-1
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 458:	fff4c583          	lbu	a1,-1(s1)
 45c:	854a                	mv	a0,s2
 45e:	f67ff0ef          	jal	3c4 <putc>
  while (--i >= 0)
 462:	14fd                	addi	s1,s1,-1
 464:	ff349ae3          	bne	s1,s3,458 <printint+0x76>
 468:	74e2                	ld	s1,56(sp)
 46a:	79a2                	ld	s3,40(sp)
}
 46c:	60a6                	ld	ra,72(sp)
 46e:	6406                	ld	s0,64(sp)
 470:	7942                	ld	s2,48(sp)
 472:	6161                	addi	sp,sp,80
 474:	8082                	ret
    x = -xx;
 476:	40b005b3          	neg	a1,a1
    neg = 1;
 47a:	4885                	li	a7,1
    x = -xx;
 47c:	bfad                	j	3f6 <printint+0x14>

000000000000047e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47e:	711d                	addi	sp,sp,-96
 480:	ec86                	sd	ra,88(sp)
 482:	e8a2                	sd	s0,80(sp)
 484:	e0ca                	sd	s2,64(sp)
 486:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 488:	0005c903          	lbu	s2,0(a1)
 48c:	28090663          	beqz	s2,718 <vprintf+0x29a>
 490:	e4a6                	sd	s1,72(sp)
 492:	fc4e                	sd	s3,56(sp)
 494:	f852                	sd	s4,48(sp)
 496:	f456                	sd	s5,40(sp)
 498:	f05a                	sd	s6,32(sp)
 49a:	ec5e                	sd	s7,24(sp)
 49c:	e862                	sd	s8,16(sp)
 49e:	e466                	sd	s9,8(sp)
 4a0:	8b2a                	mv	s6,a0
 4a2:	8a2e                	mv	s4,a1
 4a4:	8bb2                	mv	s7,a2
  state = 0;
 4a6:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 4a8:	4481                	li	s1,0
 4aa:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 4ac:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 4b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4b4:	06c00c93          	li	s9,108
 4b8:	a005                	j	4d8 <vprintf+0x5a>
        putc(fd, c0);
 4ba:	85ca                	mv	a1,s2
 4bc:	855a                	mv	a0,s6
 4be:	f07ff0ef          	jal	3c4 <putc>
 4c2:	a019                	j	4c8 <vprintf+0x4a>
    } else if (state == '%') {
 4c4:	03598263          	beq	s3,s5,4e8 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 4c8:	2485                	addiw	s1,s1,1
 4ca:	8726                	mv	a4,s1
 4cc:	009a07b3          	add	a5,s4,s1
 4d0:	0007c903          	lbu	s2,0(a5)
 4d4:	22090a63          	beqz	s2,708 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4d8:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 4dc:	fe0994e3          	bnez	s3,4c4 <vprintf+0x46>
      if (c0 == '%') {
 4e0:	fd579de3          	bne	a5,s5,4ba <vprintf+0x3c>
        state = '%';
 4e4:	89be                	mv	s3,a5
 4e6:	b7cd                	j	4c8 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 4e8:	00ea06b3          	add	a3,s4,a4
 4ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f0:	8636                	mv	a2,a3
      if (c1)
 4f2:	c681                	beqz	a3,4fa <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 4f4:	9752                	add	a4,a4,s4
 4f6:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 4fa:	05878363          	beq	a5,s8,540 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 4fe:	05978d63          	beq	a5,s9,558 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 502:	07500713          	li	a4,117
 506:	0ee78763          	beq	a5,a4,5f4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 50a:	07800713          	li	a4,120
 50e:	12e78963          	beq	a5,a4,640 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 512:	07000713          	li	a4,112
 516:	14e78e63          	beq	a5,a4,672 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 51a:	06300713          	li	a4,99
 51e:	18e78e63          	beq	a5,a4,6ba <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 522:	07300713          	li	a4,115
 526:	1ae78463          	beq	a5,a4,6ce <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 52a:	02500713          	li	a4,37
 52e:	04e79563          	bne	a5,a4,578 <vprintf+0xfa>
        putc(fd, '%');
 532:	02500593          	li	a1,37
 536:	855a                	mv	a0,s6
 538:	e8dff0ef          	jal	3c4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 53c:	4981                	li	s3,0
 53e:	b769                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 540:	008b8913          	addi	s2,s7,8
 544:	4685                	li	a3,1
 546:	4629                	li	a2,10
 548:	000ba583          	lw	a1,0(s7)
 54c:	855a                	mv	a0,s6
 54e:	e95ff0ef          	jal	3e2 <printint>
 552:	8bca                	mv	s7,s2
      state = 0;
 554:	4981                	li	s3,0
 556:	bf8d                	j	4c8 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 558:	06400793          	li	a5,100
 55c:	02f68963          	beq	a3,a5,58e <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 560:	06c00793          	li	a5,108
 564:	04f68263          	beq	a3,a5,5a8 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 568:	07500793          	li	a5,117
 56c:	0af68063          	beq	a3,a5,60c <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 570:	07800793          	li	a5,120
 574:	0ef68263          	beq	a3,a5,658 <vprintf+0x1da>
        putc(fd, '%');
 578:	02500593          	li	a1,37
 57c:	855a                	mv	a0,s6
 57e:	e47ff0ef          	jal	3c4 <putc>
        putc(fd, c0);
 582:	85ca                	mv	a1,s2
 584:	855a                	mv	a0,s6
 586:	e3fff0ef          	jal	3c4 <putc>
      state = 0;
 58a:	4981                	li	s3,0
 58c:	bf35                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58e:	008b8913          	addi	s2,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000bb583          	ld	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	e47ff0ef          	jal	3e2 <printint>
        i += 1;
 5a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
        i += 1;
 5a6:	b70d                	j	4c8 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5a8:	06400793          	li	a5,100
 5ac:	02f60763          	beq	a2,a5,5da <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 5b0:	07500793          	li	a5,117
 5b4:	06f60963          	beq	a2,a5,626 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 5b8:	07800793          	li	a5,120
 5bc:	faf61ee3          	bne	a2,a5,578 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4681                	li	a3,0
 5c6:	4641                	li	a2,16
 5c8:	000bb583          	ld	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e15ff0ef          	jal	3e2 <printint>
        i += 2;
 5d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
        i += 2;
 5d8:	bdc5                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000bb583          	ld	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	dfbff0ef          	jal	3e2 <printint>
        i += 2;
 5ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	8bca                	mv	s7,s2
      state = 0;
 5f0:	4981                	li	s3,0
        i += 2;
 5f2:	bdd9                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000be583          	lwu	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	de1ff0ef          	jal	3e2 <printint>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	bd7d                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000bb583          	ld	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	dc9ff0ef          	jal	3e2 <printint>
        i += 1;
 61e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
        i += 1;
 624:	b555                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 626:	008b8913          	addi	s2,s7,8
 62a:	4681                	li	a3,0
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	dafff0ef          	jal	3e2 <printint>
        i += 2;
 638:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
        i += 2;
 63e:	b569                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000be583          	lwu	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	d95ff0ef          	jal	3e2 <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bd8d                	j	4c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	d7dff0ef          	jal	3e2 <printint>
        i += 1;
 66a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 1;
 670:	bda1                	j	4c8 <vprintf+0x4a>
 672:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 674:	008b8d13          	addi	s10,s7,8
 678:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 67c:	03000593          	li	a1,48
 680:	855a                	mv	a0,s6
 682:	d43ff0ef          	jal	3c4 <putc>
  putc(fd, 'x');
 686:	07800593          	li	a1,120
 68a:	855a                	mv	a0,s6
 68c:	d39ff0ef          	jal	3c4 <putc>
 690:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 692:	00000b97          	auipc	s7,0x0
 696:	2d6b8b93          	addi	s7,s7,726 # 968 <digits>
 69a:	03c9d793          	srli	a5,s3,0x3c
 69e:	97de                	add	a5,a5,s7
 6a0:	0007c583          	lbu	a1,0(a5)
 6a4:	855a                	mv	a0,s6
 6a6:	d1fff0ef          	jal	3c4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6aa:	0992                	slli	s3,s3,0x4
 6ac:	397d                	addiw	s2,s2,-1
 6ae:	fe0916e3          	bnez	s2,69a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6b2:	8bea                	mv	s7,s10
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	6d02                	ld	s10,0(sp)
 6b8:	bd01                	j	4c8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6ba:	008b8913          	addi	s2,s7,8
 6be:	000bc583          	lbu	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	d01ff0ef          	jal	3c4 <putc>
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bbf5                	j	4c8 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 6ce:	008b8993          	addi	s3,s7,8
 6d2:	000bb903          	ld	s2,0(s7)
 6d6:	00090f63          	beqz	s2,6f4 <vprintf+0x276>
        for (; *s; s++)
 6da:	00094583          	lbu	a1,0(s2)
 6de:	c195                	beqz	a1,702 <vprintf+0x284>
          putc(fd, *s);
 6e0:	855a                	mv	a0,s6
 6e2:	ce3ff0ef          	jal	3c4 <putc>
        for (; *s; s++)
 6e6:	0905                	addi	s2,s2,1
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	f9f5                	bnez	a1,6e0 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 6ee:	8bce                	mv	s7,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bbd9                	j	4c8 <vprintf+0x4a>
          s = "(null)";
 6f4:	00000917          	auipc	s2,0x0
 6f8:	26c90913          	addi	s2,s2,620 # 960 <malloc+0x160>
        for (; *s; s++)
 6fc:	02800593          	li	a1,40
 700:	b7c5                	j	6e0 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 702:	8bce                	mv	s7,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b3c9                	j	4c8 <vprintf+0x4a>
 708:	64a6                	ld	s1,72(sp)
 70a:	79e2                	ld	s3,56(sp)
 70c:	7a42                	ld	s4,48(sp)
 70e:	7aa2                	ld	s5,40(sp)
 710:	7b02                	ld	s6,32(sp)
 712:	6be2                	ld	s7,24(sp)
 714:	6c42                	ld	s8,16(sp)
 716:	6ca2                	ld	s9,8(sp)
    }
  }
}
 718:	60e6                	ld	ra,88(sp)
 71a:	6446                	ld	s0,80(sp)
 71c:	6906                	ld	s2,64(sp)
 71e:	6125                	addi	sp,sp,96
 720:	8082                	ret

0000000000000722 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 722:	715d                	addi	sp,sp,-80
 724:	ec06                	sd	ra,24(sp)
 726:	e822                	sd	s0,16(sp)
 728:	1000                	addi	s0,sp,32
 72a:	e010                	sd	a2,0(s0)
 72c:	e414                	sd	a3,8(s0)
 72e:	e818                	sd	a4,16(s0)
 730:	ec1c                	sd	a5,24(s0)
 732:	03043023          	sd	a6,32(s0)
 736:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73e:	8622                	mv	a2,s0
 740:	d3fff0ef          	jal	47e <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6161                	addi	sp,sp,80
 74a:	8082                	ret

000000000000074c <printf>:

void
printf(const char *fmt, ...)
{
 74c:	711d                	addi	sp,sp,-96
 74e:	ec06                	sd	ra,24(sp)
 750:	e822                	sd	s0,16(sp)
 752:	1000                	addi	s0,sp,32
 754:	e40c                	sd	a1,8(s0)
 756:	e810                	sd	a2,16(s0)
 758:	ec14                	sd	a3,24(s0)
 75a:	f018                	sd	a4,32(s0)
 75c:	f41c                	sd	a5,40(s0)
 75e:	03043823          	sd	a6,48(s0)
 762:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	00840613          	addi	a2,s0,8
 76a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76e:	85aa                	mv	a1,a0
 770:	4505                	li	a0,1
 772:	d0dff0ef          	jal	47e <vprintf>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret

000000000000077e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	1141                	addi	sp,sp,-16
 780:	e422                	sd	s0,8(sp)
 782:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 784:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00001797          	auipc	a5,0x1
 78c:	8787b783          	ld	a5,-1928(a5) # 1000 <freep>
 790:	a02d                	j	7ba <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 792:	4618                	lw	a4,8(a2)
 794:	9f2d                	addw	a4,a4,a1
 796:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	6310                	ld	a2,0(a4)
 79e:	a83d                	j	7dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9f31                	addw	a4,a4,a2
 7a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053683          	ld	a3,-16(a0)
 7ac:	a091                	j	7f0 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e7e463          	bltu	a5,a4,7b8 <free+0x3a>
 7b4:	00e6ea63          	bltu	a3,a4,7c8 <free+0x4a>
{
 7b8:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	fed7fae3          	bgeu	a5,a3,7ae <free+0x30>
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e6e463          	bltu	a3,a4,7c8 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	fee7eae3          	bltu	a5,a4,7b8 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 7c8:	ff852583          	lw	a1,-8(a0)
 7cc:	6390                	ld	a2,0(a5)
 7ce:	02059813          	slli	a6,a1,0x20
 7d2:	01c85713          	srli	a4,a6,0x1c
 7d6:	9736                	add	a4,a4,a3
 7d8:	fae60de3          	beq	a2,a4,792 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 7e0:	4790                	lw	a2,8(a5)
 7e2:	02061593          	slli	a1,a2,0x20
 7e6:	01c5d713          	srli	a4,a1,0x1c
 7ea:	973e                	add	a4,a4,a5
 7ec:	fae68ae3          	beq	a3,a4,7a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f2:	00001717          	auipc	a4,0x1
 7f6:	80f73723          	sd	a5,-2034(a4) # 1000 <freep>
}
 7fa:	6422                	ld	s0,8(sp)
 7fc:	0141                	addi	sp,sp,16
 7fe:	8082                	ret

0000000000000800 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 800:	7139                	addi	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f426                	sd	s1,40(sp)
 808:	ec4e                	sd	s3,24(sp)
 80a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 80c:	02051493          	slli	s1,a0,0x20
 810:	9081                	srli	s1,s1,0x20
 812:	04bd                	addi	s1,s1,15
 814:	8091                	srli	s1,s1,0x4
 816:	0014899b          	addiw	s3,s1,1
 81a:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 81c:	00000517          	auipc	a0,0x0
 820:	7e453503          	ld	a0,2020(a0) # 1000 <freep>
 824:	c915                	beqz	a0,858 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 826:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 828:	4798                	lw	a4,8(a5)
 82a:	08977a63          	bgeu	a4,s1,8be <malloc+0xbe>
 82e:	f04a                	sd	s2,32(sp)
 830:	e852                	sd	s4,16(sp)
 832:	e456                	sd	s5,8(sp)
 834:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 836:	8a4e                	mv	s4,s3
 838:	0009871b          	sext.w	a4,s3
 83c:	6685                	lui	a3,0x1
 83e:	00d77363          	bgeu	a4,a3,844 <malloc+0x44>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 84c:	00000917          	auipc	s2,0x0
 850:	7b490913          	addi	s2,s2,1972 # 1000 <freep>
  if (p == SBRK_ERROR)
 854:	5afd                	li	s5,-1
 856:	a081                	j	896 <malloc+0x96>
 858:	f04a                	sd	s2,32(sp)
 85a:	e852                	sd	s4,16(sp)
 85c:	e456                	sd	s5,8(sp)
 85e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 860:	00000797          	auipc	a5,0x0
 864:	7b078793          	addi	a5,a5,1968 # 1010 <base>
 868:	00000717          	auipc	a4,0x0
 86c:	78f73c23          	sd	a5,1944(a4) # 1000 <freep>
 870:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 872:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 876:	b7c1                	j	836 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	e118                	sd	a4,0(a0)
 87c:	a8a9                	j	8d6 <malloc+0xd6>
  hp->s.size = nu;
 87e:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 882:	0541                	addi	a0,a0,16
 884:	efbff0ef          	jal	77e <free>
  return freep;
 888:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 88c:	c12d                	beqz	a0,8ee <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 88e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 890:	4798                	lw	a4,8(a5)
 892:	02977263          	bgeu	a4,s1,8b6 <malloc+0xb6>
    if (p == freep)
 896:	00093703          	ld	a4,0(s2)
 89a:	853e                	mv	a0,a5
 89c:	fef719e3          	bne	a4,a5,88e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8a0:	8552                	mv	a0,s4
 8a2:	a27ff0ef          	jal	2c8 <sbrk>
  if (p == SBRK_ERROR)
 8a6:	fd551ce3          	bne	a0,s5,87e <malloc+0x7e>
        return 0;
 8aa:	4501                	li	a0,0
 8ac:	7902                	ld	s2,32(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	a03d                	j	8e2 <malloc+0xe2>
 8b6:	7902                	ld	s2,32(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 8be:	fae48de3          	beq	s1,a4,878 <malloc+0x78>
        p->s.size -= nunits;
 8c2:	4137073b          	subw	a4,a4,s3
 8c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c8:	02071693          	slli	a3,a4,0x20
 8cc:	01c6d713          	srli	a4,a3,0x1c
 8d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d6:	00000717          	auipc	a4,0x0
 8da:	72a73523          	sd	a0,1834(a4) # 1000 <freep>
      return (void *)(p + 1);
 8de:	01078513          	addi	a0,a5,16
  }
}
 8e2:	70e2                	ld	ra,56(sp)
 8e4:	7442                	ld	s0,48(sp)
 8e6:	74a2                	ld	s1,40(sp)
 8e8:	69e2                	ld	s3,24(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
 8ee:	7902                	ld	s2,32(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
 8f6:	b7f5                	j	8e2 <malloc+0xe2>
