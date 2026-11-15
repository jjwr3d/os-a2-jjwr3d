
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (argc != 2) {
   8:	4789                	li	a5,2
   a:	04f51063          	bne	a0,a5,4a <main+0x4a>
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }

    char *s = argv[1];
   e:	6588                	ld	a0,8(a1)
    // Check if the argument is negative, empty, or contains non-digits
    if (s[0] == '\0') {
  10:	00054783          	lbu	a5,0(a0)
  14:	c7a9                	beqz	a5,5e <main+0x5e>
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }
    
    int start = 0;
    if (s[0] == '-') { // Catch explicit negatives upfront
  16:	02d00713          	li	a4,45
  1a:	04e78c63          	beq	a5,a4,72 <main+0x72>
        fprintf(2, "usage: sleep <ticks>\n");
        exit(1);
    }

    for (int i = start; s[i] != '\0'; i++) {
  1e:	00150713          	addi	a4,a0,1
        if (s[i] < '0' || s[i] > '9') {
  22:	46a5                	li	a3,9
  24:	fd07879b          	addiw	a5,a5,-48
  28:	0ff7f793          	zext.b	a5,a5
  2c:	04f6ed63          	bltu	a3,a5,86 <main+0x86>
    for (int i = start; s[i] != '\0'; i++) {
  30:	0705                	addi	a4,a4,1
  32:	fff74783          	lbu	a5,-1(a4)
  36:	f7fd                	bnez	a5,24 <main+0x24>
            fprintf(2, "usage: sleep <ticks>\n");
            exit(1);
        }
    }

    int ticks = atoi(argv[1]);
  38:	1da000ef          	jal	212 <atoi>
    if (pause(ticks) < 0) { // Using pause() per instructions
  3c:	388000ef          	jal	3c4 <pause>
  40:	04054d63          	bltz	a0,9a <main+0x9a>
        exit(1);
    }

    exit(0);
  44:	4501                	li	a0,0
  46:	2ee000ef          	jal	334 <exit>
        fprintf(2, "usage: sleep <ticks>\n");
  4a:	00001597          	auipc	a1,0x1
  4e:	8e658593          	addi	a1,a1,-1818 # 930 <malloc+0xf8>
  52:	4509                	li	a0,2
  54:	706000ef          	jal	75a <fprintf>
        exit(1);
  58:	4505                	li	a0,1
  5a:	2da000ef          	jal	334 <exit>
        fprintf(2, "usage: sleep <ticks>\n");
  5e:	00001597          	auipc	a1,0x1
  62:	8d258593          	addi	a1,a1,-1838 # 930 <malloc+0xf8>
  66:	4509                	li	a0,2
  68:	6f2000ef          	jal	75a <fprintf>
        exit(1);
  6c:	4505                	li	a0,1
  6e:	2c6000ef          	jal	334 <exit>
        fprintf(2, "usage: sleep <ticks>\n");
  72:	00001597          	auipc	a1,0x1
  76:	8be58593          	addi	a1,a1,-1858 # 930 <malloc+0xf8>
  7a:	4509                	li	a0,2
  7c:	6de000ef          	jal	75a <fprintf>
        exit(1);
  80:	4505                	li	a0,1
  82:	2b2000ef          	jal	334 <exit>
            fprintf(2, "usage: sleep <ticks>\n");
  86:	00001597          	auipc	a1,0x1
  8a:	8aa58593          	addi	a1,a1,-1878 # 930 <malloc+0xf8>
  8e:	4509                	li	a0,2
  90:	6ca000ef          	jal	75a <fprintf>
            exit(1);
  94:	4505                	li	a0,1
  96:	29e000ef          	jal	334 <exit>
        exit(1);
  9a:	4505                	li	a0,1
  9c:	298000ef          	jal	334 <exit>

00000000000000a0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  a8:	f59ff0ef          	jal	0 <main>
  exit(r);
  ac:	288000ef          	jal	334 <exit>

00000000000000b0 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  b6:	87aa                	mv	a5,a0
  b8:	0585                	addi	a1,a1,1
  ba:	0785                	addi	a5,a5,1
  bc:	fff5c703          	lbu	a4,-1(a1)
  c0:	fee78fa3          	sb	a4,-1(a5)
  c4:	fb75                	bnez	a4,b8 <strcpy+0x8>
    ;
  return os;
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cb91                	beqz	a5,ea <strcmp+0x1e>
  d8:	0005c703          	lbu	a4,0(a1)
  dc:	00f71763          	bne	a4,a5,ea <strcmp+0x1e>
    p++, q++;
  e0:	0505                	addi	a0,a0,1
  e2:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	fbe5                	bnez	a5,d8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ea:	0005c503          	lbu	a0,0(a1)
}
  ee:	40a7853b          	subw	a0,a5,a0
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strlen>:

uint
strlen(const char *s)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cf91                	beqz	a5,11e <strlen+0x26>
 104:	0505                	addi	a0,a0,1
 106:	87aa                	mv	a5,a0
 108:	86be                	mv	a3,a5
 10a:	0785                	addi	a5,a5,1
 10c:	fff7c703          	lbu	a4,-1(a5)
 110:	ff65                	bnez	a4,108 <strlen+0x10>
 112:	40a6853b          	subw	a0,a3,a0
 116:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret
  for (n = 0; s[n]; n++)
 11e:	4501                	li	a0,0
 120:	bfe5                	j	118 <strlen+0x20>

0000000000000122 <memset>:

void *
memset(void *dst, int c, uint n)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 128:	ca19                	beqz	a2,13e <memset+0x1c>
 12a:	87aa                	mv	a5,a0
 12c:	1602                	slli	a2,a2,0x20
 12e:	9201                	srli	a2,a2,0x20
 130:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 134:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 138:	0785                	addi	a5,a5,1
 13a:	fee79de3          	bne	a5,a4,134 <memset+0x12>
  }
  return dst;
}
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strchr>:

char *
strchr(const char *s, char c)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  for (; *s; s++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cb99                	beqz	a5,164 <strchr+0x20>
    if (*s == c)
 150:	00f58763          	beq	a1,a5,15e <strchr+0x1a>
  for (; *s; s++)
 154:	0505                	addi	a0,a0,1
 156:	00054783          	lbu	a5,0(a0)
 15a:	fbfd                	bnez	a5,150 <strchr+0xc>
      return (char *)s;
  return 0;
 15c:	4501                	li	a0,0
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  return 0;
 164:	4501                	li	a0,0
 166:	bfe5                	j	15e <strchr+0x1a>

0000000000000168 <gets>:

char *
gets(char *buf, int max)
{
 168:	711d                	addi	sp,sp,-96
 16a:	ec86                	sd	ra,88(sp)
 16c:	e8a2                	sd	s0,80(sp)
 16e:	e4a6                	sd	s1,72(sp)
 170:	e0ca                	sd	s2,64(sp)
 172:	fc4e                	sd	s3,56(sp)
 174:	f852                	sd	s4,48(sp)
 176:	f456                	sd	s5,40(sp)
 178:	f05a                	sd	s6,32(sp)
 17a:	ec5e                	sd	s7,24(sp)
 17c:	1080                	addi	s0,sp,96
 17e:	8baa                	mv	s7,a0
 180:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 182:	892a                	mv	s2,a0
 184:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 186:	4aa9                	li	s5,10
 188:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 18a:	89a6                	mv	s3,s1
 18c:	2485                	addiw	s1,s1,1
 18e:	0344d663          	bge	s1,s4,1ba <gets+0x52>
    cc = read(0, &c, 1);
 192:	4605                	li	a2,1
 194:	faf40593          	addi	a1,s0,-81
 198:	4501                	li	a0,0
 19a:	1b2000ef          	jal	34c <read>
    if (cc < 1)
 19e:	00a05e63          	blez	a0,1ba <gets+0x52>
    buf[i++] = c;
 1a2:	faf44783          	lbu	a5,-81(s0)
 1a6:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1aa:	01578763          	beq	a5,s5,1b8 <gets+0x50>
 1ae:	0905                	addi	s2,s2,1
 1b0:	fd679de3          	bne	a5,s6,18a <gets+0x22>
    buf[i++] = c;
 1b4:	89a6                	mv	s3,s1
 1b6:	a011                	j	1ba <gets+0x52>
 1b8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ba:	99de                	add	s3,s3,s7
 1bc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c0:	855e                	mv	a0,s7
 1c2:	60e6                	ld	ra,88(sp)
 1c4:	6446                	ld	s0,80(sp)
 1c6:	64a6                	ld	s1,72(sp)
 1c8:	6906                	ld	s2,64(sp)
 1ca:	79e2                	ld	s3,56(sp)
 1cc:	7a42                	ld	s4,48(sp)
 1ce:	7aa2                	ld	s5,40(sp)
 1d0:	7b02                	ld	s6,32(sp)
 1d2:	6be2                	ld	s7,24(sp)
 1d4:	6125                	addi	sp,sp,96
 1d6:	8082                	ret

00000000000001d8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d8:	1101                	addi	sp,sp,-32
 1da:	ec06                	sd	ra,24(sp)
 1dc:	e822                	sd	s0,16(sp)
 1de:	e04a                	sd	s2,0(sp)
 1e0:	1000                	addi	s0,sp,32
 1e2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e4:	4581                	li	a1,0
 1e6:	18e000ef          	jal	374 <open>
  if (fd < 0)
 1ea:	02054263          	bltz	a0,20e <stat+0x36>
 1ee:	e426                	sd	s1,8(sp)
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	198000ef          	jal	38c <fstat>
 1f8:	892a                	mv	s2,a0
  close(fd);
 1fa:	8526                	mv	a0,s1
 1fc:	160000ef          	jal	35c <close>
  return r;
 200:	64a2                	ld	s1,8(sp)
}
 202:	854a                	mv	a0,s2
 204:	60e2                	ld	ra,24(sp)
 206:	6442                	ld	s0,16(sp)
 208:	6902                	ld	s2,0(sp)
 20a:	6105                	addi	sp,sp,32
 20c:	8082                	ret
    return -1;
 20e:	597d                	li	s2,-1
 210:	bfcd                	j	202 <stat+0x2a>

0000000000000212 <atoi>:

int
atoi(const char *s)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 218:	00054683          	lbu	a3,0(a0)
 21c:	fd06879b          	addiw	a5,a3,-48
 220:	0ff7f793          	zext.b	a5,a5
 224:	4625                	li	a2,9
 226:	02f66863          	bltu	a2,a5,256 <atoi+0x44>
 22a:	872a                	mv	a4,a0
  n = 0;
 22c:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 22e:	0705                	addi	a4,a4,1
 230:	0025179b          	slliw	a5,a0,0x2
 234:	9fa9                	addw	a5,a5,a0
 236:	0017979b          	slliw	a5,a5,0x1
 23a:	9fb5                	addw	a5,a5,a3
 23c:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 240:	00074683          	lbu	a3,0(a4)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	fef671e3          	bgeu	a2,a5,22e <atoi+0x1c>
  return n;
}
 250:	6422                	ld	s0,8(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  n = 0;
 256:	4501                	li	a0,0
 258:	bfe5                	j	250 <atoi+0x3e>

000000000000025a <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 260:	02b57463          	bgeu	a0,a1,288 <memmove+0x2e>
    while (n-- > 0)
 264:	00c05f63          	blez	a2,282 <memmove+0x28>
 268:	1602                	slli	a2,a2,0x20
 26a:	9201                	srli	a2,a2,0x20
 26c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 270:	872a                	mv	a4,a0
      *dst++ = *src++;
 272:	0585                	addi	a1,a1,1
 274:	0705                	addi	a4,a4,1
 276:	fff5c683          	lbu	a3,-1(a1)
 27a:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 27e:	fef71ae3          	bne	a4,a5,272 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
    dst += n;
 288:	00c50733          	add	a4,a0,a2
    src += n;
 28c:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 28e:	fec05ae3          	blez	a2,282 <memmove+0x28>
 292:	fff6079b          	addiw	a5,a2,-1
 296:	1782                	slli	a5,a5,0x20
 298:	9381                	srli	a5,a5,0x20
 29a:	fff7c793          	not	a5,a5
 29e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a0:	15fd                	addi	a1,a1,-1
 2a2:	177d                	addi	a4,a4,-1
 2a4:	0005c683          	lbu	a3,0(a1)
 2a8:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 2ac:	fee79ae3          	bne	a5,a4,2a0 <memmove+0x46>
 2b0:	bfc9                	j	282 <memmove+0x28>

00000000000002b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b8:	ca05                	beqz	a2,2e8 <memcmp+0x36>
 2ba:	fff6069b          	addiw	a3,a2,-1
 2be:	1682                	slli	a3,a3,0x20
 2c0:	9281                	srli	a3,a3,0x20
 2c2:	0685                	addi	a3,a3,1
 2c4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	0005c703          	lbu	a4,0(a1)
 2ce:	00e79863          	bne	a5,a4,2de <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d2:	0505                	addi	a0,a0,1
    p2++;
 2d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d6:	fed518e3          	bne	a0,a3,2c6 <memcmp+0x14>
  }
  return 0;
 2da:	4501                	li	a0,0
 2dc:	a019                	j	2e2 <memcmp+0x30>
      return *p1 - *p2;
 2de:	40e7853b          	subw	a0,a5,a4
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	bfe5                	j	2e2 <memcmp+0x30>

00000000000002ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e406                	sd	ra,8(sp)
 2f0:	e022                	sd	s0,0(sp)
 2f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f4:	f67ff0ef          	jal	25a <memmove>
}
 2f8:	60a2                	ld	ra,8(sp)
 2fa:	6402                	ld	s0,0(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret

0000000000000300 <sbrk>:

char *
sbrk(int n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 308:	4585                	li	a1,1
 30a:	0b2000ef          	jal	3bc <sys_sbrk>
}
 30e:	60a2                	ld	ra,8(sp)
 310:	6402                	ld	s0,0(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret

0000000000000316 <sbrklazy>:

char *
sbrklazy(int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 31e:	4589                	li	a1,2
 320:	09c000ef          	jal	3bc <sys_sbrk>
}
 324:	60a2                	ld	ra,8(sp)
 326:	6402                	ld	s0,0(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret

000000000000032c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32c:	4885                	li	a7,1
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exit>:
.global exit
exit:
 li a7, SYS_exit
 334:	4889                	li	a7,2
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <wait>:
.global wait
wait:
 li a7, SYS_wait
 33c:	488d                	li	a7,3
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 344:	4891                	li	a7,4
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <read>:
.global read
read:
 li a7, SYS_read
 34c:	4895                	li	a7,5
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <write>:
.global write
write:
 li a7, SYS_write
 354:	48c1                	li	a7,16
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <close>:
.global close
close:
 li a7, SYS_close
 35c:	48d5                	li	a7,21
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <kill>:
.global kill
kill:
 li a7, SYS_kill
 364:	4899                	li	a7,6
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exec>:
.global exec
exec:
 li a7, SYS_exec
 36c:	489d                	li	a7,7
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <open>:
.global open
open:
 li a7, SYS_open
 374:	48bd                	li	a7,15
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37c:	48c5                	li	a7,17
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 384:	48c9                	li	a7,18
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38c:	48a1                	li	a7,8
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <link>:
.global link
link:
 li a7, SYS_link
 394:	48cd                	li	a7,19
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39c:	48d1                	li	a7,20
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a4:	48a5                	li	a7,9
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ac:	48a9                	li	a7,10
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b4:	48ad                	li	a7,11
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3bc:	48b1                	li	a7,12
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3c4:	48b5                	li	a7,13
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3cc:	48b9                	li	a7,14
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sync>:
.global sync
sync:
 li a7, SYS_sync
 3d4:	48d9                	li	a7,22
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3dc:	48dd                	li	a7,23
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3e4:	48e1                	li	a7,24
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3ec:	48e5                	li	a7,25
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 3f4:	48e9                	li	a7,26
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	1000                	addi	s0,sp,32
 404:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 408:	4605                	li	a2,1
 40a:	fef40593          	addi	a1,s0,-17
 40e:	f47ff0ef          	jal	354 <write>
}
 412:	60e2                	ld	ra,24(sp)
 414:	6442                	ld	s0,16(sp)
 416:	6105                	addi	sp,sp,32
 418:	8082                	ret

000000000000041a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 41a:	715d                	addi	sp,sp,-80
 41c:	e486                	sd	ra,72(sp)
 41e:	e0a2                	sd	s0,64(sp)
 420:	f84a                	sd	s2,48(sp)
 422:	0880                	addi	s0,sp,80
 424:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 426:	c299                	beqz	a3,42c <printint+0x12>
 428:	0805c363          	bltz	a1,4ae <printint+0x94>
  neg = 0;
 42c:	4881                	li	a7,0
 42e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 432:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 434:	00000517          	auipc	a0,0x0
 438:	51c50513          	addi	a0,a0,1308 # 950 <digits>
 43c:	883e                	mv	a6,a5
 43e:	2785                	addiw	a5,a5,1
 440:	02c5f733          	remu	a4,a1,a2
 444:	972a                	add	a4,a4,a0
 446:	00074703          	lbu	a4,0(a4)
 44a:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 44e:	872e                	mv	a4,a1
 450:	02c5d5b3          	divu	a1,a1,a2
 454:	0685                	addi	a3,a3,1
 456:	fec773e3          	bgeu	a4,a2,43c <printint+0x22>
  if (neg)
 45a:	00088b63          	beqz	a7,470 <printint+0x56>
    buf[i++] = '-';
 45e:	fd078793          	addi	a5,a5,-48
 462:	97a2                	add	a5,a5,s0
 464:	02d00713          	li	a4,45
 468:	fee78423          	sb	a4,-24(a5)
 46c:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 470:	02f05a63          	blez	a5,4a4 <printint+0x8a>
 474:	fc26                	sd	s1,56(sp)
 476:	f44e                	sd	s3,40(sp)
 478:	fb840713          	addi	a4,s0,-72
 47c:	00f704b3          	add	s1,a4,a5
 480:	fff70993          	addi	s3,a4,-1
 484:	99be                	add	s3,s3,a5
 486:	37fd                	addiw	a5,a5,-1
 488:	1782                	slli	a5,a5,0x20
 48a:	9381                	srli	a5,a5,0x20
 48c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 490:	fff4c583          	lbu	a1,-1(s1)
 494:	854a                	mv	a0,s2
 496:	f67ff0ef          	jal	3fc <putc>
  while (--i >= 0)
 49a:	14fd                	addi	s1,s1,-1
 49c:	ff349ae3          	bne	s1,s3,490 <printint+0x76>
 4a0:	74e2                	ld	s1,56(sp)
 4a2:	79a2                	ld	s3,40(sp)
}
 4a4:	60a6                	ld	ra,72(sp)
 4a6:	6406                	ld	s0,64(sp)
 4a8:	7942                	ld	s2,48(sp)
 4aa:	6161                	addi	sp,sp,80
 4ac:	8082                	ret
    x = -xx;
 4ae:	40b005b3          	neg	a1,a1
    neg = 1;
 4b2:	4885                	li	a7,1
    x = -xx;
 4b4:	bfad                	j	42e <printint+0x14>

00000000000004b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b6:	711d                	addi	sp,sp,-96
 4b8:	ec86                	sd	ra,88(sp)
 4ba:	e8a2                	sd	s0,80(sp)
 4bc:	e0ca                	sd	s2,64(sp)
 4be:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 4c0:	0005c903          	lbu	s2,0(a1)
 4c4:	28090663          	beqz	s2,750 <vprintf+0x29a>
 4c8:	e4a6                	sd	s1,72(sp)
 4ca:	fc4e                	sd	s3,56(sp)
 4cc:	f852                	sd	s4,48(sp)
 4ce:	f456                	sd	s5,40(sp)
 4d0:	f05a                	sd	s6,32(sp)
 4d2:	ec5e                	sd	s7,24(sp)
 4d4:	e862                	sd	s8,16(sp)
 4d6:	e466                	sd	s9,8(sp)
 4d8:	8b2a                	mv	s6,a0
 4da:	8a2e                	mv	s4,a1
 4dc:	8bb2                	mv	s7,a2
  state = 0;
 4de:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 4e0:	4481                	li	s1,0
 4e2:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 4e4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 4e8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4ec:	06c00c93          	li	s9,108
 4f0:	a005                	j	510 <vprintf+0x5a>
        putc(fd, c0);
 4f2:	85ca                	mv	a1,s2
 4f4:	855a                	mv	a0,s6
 4f6:	f07ff0ef          	jal	3fc <putc>
 4fa:	a019                	j	500 <vprintf+0x4a>
    } else if (state == '%') {
 4fc:	03598263          	beq	s3,s5,520 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 500:	2485                	addiw	s1,s1,1
 502:	8726                	mv	a4,s1
 504:	009a07b3          	add	a5,s4,s1
 508:	0007c903          	lbu	s2,0(a5)
 50c:	22090a63          	beqz	s2,740 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 510:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 514:	fe0994e3          	bnez	s3,4fc <vprintf+0x46>
      if (c0 == '%') {
 518:	fd579de3          	bne	a5,s5,4f2 <vprintf+0x3c>
        state = '%';
 51c:	89be                	mv	s3,a5
 51e:	b7cd                	j	500 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 520:	00ea06b3          	add	a3,s4,a4
 524:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 528:	8636                	mv	a2,a3
      if (c1)
 52a:	c681                	beqz	a3,532 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 52c:	9752                	add	a4,a4,s4
 52e:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 532:	05878363          	beq	a5,s8,578 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 536:	05978d63          	beq	a5,s9,590 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 53a:	07500713          	li	a4,117
 53e:	0ee78763          	beq	a5,a4,62c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 542:	07800713          	li	a4,120
 546:	12e78963          	beq	a5,a4,678 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 54a:	07000713          	li	a4,112
 54e:	14e78e63          	beq	a5,a4,6aa <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 552:	06300713          	li	a4,99
 556:	18e78e63          	beq	a5,a4,6f2 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 55a:	07300713          	li	a4,115
 55e:	1ae78463          	beq	a5,a4,706 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 562:	02500713          	li	a4,37
 566:	04e79563          	bne	a5,a4,5b0 <vprintf+0xfa>
        putc(fd, '%');
 56a:	02500593          	li	a1,37
 56e:	855a                	mv	a0,s6
 570:	e8dff0ef          	jal	3fc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 574:	4981                	li	s3,0
 576:	b769                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 578:	008b8913          	addi	s2,s7,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000ba583          	lw	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	e95ff0ef          	jal	41a <printint>
 58a:	8bca                	mv	s7,s2
      state = 0;
 58c:	4981                	li	s3,0
 58e:	bf8d                	j	500 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 590:	06400793          	li	a5,100
 594:	02f68963          	beq	a3,a5,5c6 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 598:	06c00793          	li	a5,108
 59c:	04f68263          	beq	a3,a5,5e0 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 5a0:	07500793          	li	a5,117
 5a4:	0af68063          	beq	a3,a5,644 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 5a8:	07800793          	li	a5,120
 5ac:	0ef68263          	beq	a3,a5,690 <vprintf+0x1da>
        putc(fd, '%');
 5b0:	02500593          	li	a1,37
 5b4:	855a                	mv	a0,s6
 5b6:	e47ff0ef          	jal	3fc <putc>
        putc(fd, c0);
 5ba:	85ca                	mv	a1,s2
 5bc:	855a                	mv	a0,s6
 5be:	e3fff0ef          	jal	3fc <putc>
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bf35                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c6:	008b8913          	addi	s2,s7,8
 5ca:	4685                	li	a3,1
 5cc:	4629                	li	a2,10
 5ce:	000bb583          	ld	a1,0(s7)
 5d2:	855a                	mv	a0,s6
 5d4:	e47ff0ef          	jal	41a <printint>
        i += 1;
 5d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5da:	8bca                	mv	s7,s2
      state = 0;
 5dc:	4981                	li	s3,0
        i += 1;
 5de:	b70d                	j	500 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5e0:	06400793          	li	a5,100
 5e4:	02f60763          	beq	a2,a5,612 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 5e8:	07500793          	li	a5,117
 5ec:	06f60963          	beq	a2,a5,65e <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 5f0:	07800793          	li	a5,120
 5f4:	faf61ee3          	bne	a2,a5,5b0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4681                	li	a3,0
 5fe:	4641                	li	a2,16
 600:	000bb583          	ld	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e15ff0ef          	jal	41a <printint>
        i += 2;
 60a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
        i += 2;
 610:	bdc5                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 612:	008b8913          	addi	s2,s7,8
 616:	4685                	li	a3,1
 618:	4629                	li	a2,10
 61a:	000bb583          	ld	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	dfbff0ef          	jal	41a <printint>
        i += 2;
 624:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
        i += 2;
 62a:	bdd9                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 62c:	008b8913          	addi	s2,s7,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000be583          	lwu	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	de1ff0ef          	jal	41a <printint>
 63e:	8bca                	mv	s7,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bd7d                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	dc9ff0ef          	jal	41a <printint>
        i += 1;
 656:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 1;
 65c:	b555                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	008b8913          	addi	s2,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	dafff0ef          	jal	41a <printint>
        i += 2;
 670:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	b569                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000be583          	lwu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	d95ff0ef          	jal	41a <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bd8d                	j	500 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	d7dff0ef          	jal	41a <printint>
        i += 1;
 6a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 1;
 6a8:	bda1                	j	500 <vprintf+0x4a>
 6aa:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6ac:	008b8d13          	addi	s10,s7,8
 6b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6b4:	03000593          	li	a1,48
 6b8:	855a                	mv	a0,s6
 6ba:	d43ff0ef          	jal	3fc <putc>
  putc(fd, 'x');
 6be:	07800593          	li	a1,120
 6c2:	855a                	mv	a0,s6
 6c4:	d39ff0ef          	jal	3fc <putc>
 6c8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ca:	00000b97          	auipc	s7,0x0
 6ce:	286b8b93          	addi	s7,s7,646 # 950 <digits>
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97de                	add	a5,a5,s7
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	855a                	mv	a0,s6
 6de:	d1fff0ef          	jal	3fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e2:	0992                	slli	s3,s3,0x4
 6e4:	397d                	addiw	s2,s2,-1
 6e6:	fe0916e3          	bnez	s2,6d2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6ea:	8bea                	mv	s7,s10
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	6d02                	ld	s10,0(sp)
 6f0:	bd01                	j	500 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	000bc583          	lbu	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	d01ff0ef          	jal	3fc <putc>
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bbf5                	j	500 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 706:	008b8993          	addi	s3,s7,8
 70a:	000bb903          	ld	s2,0(s7)
 70e:	00090f63          	beqz	s2,72c <vprintf+0x276>
        for (; *s; s++)
 712:	00094583          	lbu	a1,0(s2)
 716:	c195                	beqz	a1,73a <vprintf+0x284>
          putc(fd, *s);
 718:	855a                	mv	a0,s6
 71a:	ce3ff0ef          	jal	3fc <putc>
        for (; *s; s++)
 71e:	0905                	addi	s2,s2,1
 720:	00094583          	lbu	a1,0(s2)
 724:	f9f5                	bnez	a1,718 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 726:	8bce                	mv	s7,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	bbd9                	j	500 <vprintf+0x4a>
          s = "(null)";
 72c:	00000917          	auipc	s2,0x0
 730:	21c90913          	addi	s2,s2,540 # 948 <malloc+0x110>
        for (; *s; s++)
 734:	02800593          	li	a1,40
 738:	b7c5                	j	718 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 73a:	8bce                	mv	s7,s3
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b3c9                	j	500 <vprintf+0x4a>
 740:	64a6                	ld	s1,72(sp)
 742:	79e2                	ld	s3,56(sp)
 744:	7a42                	ld	s4,48(sp)
 746:	7aa2                	ld	s5,40(sp)
 748:	7b02                	ld	s6,32(sp)
 74a:	6be2                	ld	s7,24(sp)
 74c:	6c42                	ld	s8,16(sp)
 74e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 750:	60e6                	ld	ra,88(sp)
 752:	6446                	ld	s0,80(sp)
 754:	6906                	ld	s2,64(sp)
 756:	6125                	addi	sp,sp,96
 758:	8082                	ret

000000000000075a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75a:	715d                	addi	sp,sp,-80
 75c:	ec06                	sd	ra,24(sp)
 75e:	e822                	sd	s0,16(sp)
 760:	1000                	addi	s0,sp,32
 762:	e010                	sd	a2,0(s0)
 764:	e414                	sd	a3,8(s0)
 766:	e818                	sd	a4,16(s0)
 768:	ec1c                	sd	a5,24(s0)
 76a:	03043023          	sd	a6,32(s0)
 76e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 772:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 776:	8622                	mv	a2,s0
 778:	d3fff0ef          	jal	4b6 <vprintf>
}
 77c:	60e2                	ld	ra,24(sp)
 77e:	6442                	ld	s0,16(sp)
 780:	6161                	addi	sp,sp,80
 782:	8082                	ret

0000000000000784 <printf>:

void
printf(const char *fmt, ...)
{
 784:	711d                	addi	sp,sp,-96
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	e40c                	sd	a1,8(s0)
 78e:	e810                	sd	a2,16(s0)
 790:	ec14                	sd	a3,24(s0)
 792:	f018                	sd	a4,32(s0)
 794:	f41c                	sd	a5,40(s0)
 796:	03043823          	sd	a6,48(s0)
 79a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	00840613          	addi	a2,s0,8
 7a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a6:	85aa                	mv	a1,a0
 7a8:	4505                	li	a0,1
 7aa:	d0dff0ef          	jal	4b6 <vprintf>
}
 7ae:	60e2                	ld	ra,24(sp)
 7b0:	6442                	ld	s0,16(sp)
 7b2:	6125                	addi	sp,sp,96
 7b4:	8082                	ret

00000000000007b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b6:	1141                	addi	sp,sp,-16
 7b8:	e422                	sd	s0,8(sp)
 7ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 7bc:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	00001797          	auipc	a5,0x1
 7c4:	8407b783          	ld	a5,-1984(a5) # 1000 <freep>
 7c8:	a02d                	j	7f2 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 7ca:	4618                	lw	a4,8(a2)
 7cc:	9f2d                	addw	a4,a4,a1
 7ce:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	6310                	ld	a2,0(a4)
 7d6:	a83d                	j	814 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 7d8:	ff852703          	lw	a4,-8(a0)
 7dc:	9f31                	addw	a4,a4,a2
 7de:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e0:	ff053683          	ld	a3,-16(a0)
 7e4:	a091                	j	828 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e7e463          	bltu	a5,a4,7f0 <free+0x3a>
 7ec:	00e6ea63          	bltu	a3,a4,800 <free+0x4a>
{
 7f0:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	fed7fae3          	bgeu	a5,a3,7e6 <free+0x30>
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e6e463          	bltu	a3,a4,800 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	fee7eae3          	bltu	a5,a4,7f0 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 800:	ff852583          	lw	a1,-8(a0)
 804:	6390                	ld	a2,0(a5)
 806:	02059813          	slli	a6,a1,0x20
 80a:	01c85713          	srli	a4,a6,0x1c
 80e:	9736                	add	a4,a4,a3
 810:	fae60de3          	beq	a2,a4,7ca <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 818:	4790                	lw	a2,8(a5)
 81a:	02061593          	slli	a1,a2,0x20
 81e:	01c5d713          	srli	a4,a1,0x1c
 822:	973e                	add	a4,a4,a5
 824:	fae68ae3          	beq	a3,a4,7d8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 828:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
}
 832:	6422                	ld	s0,8(sp)
 834:	0141                	addi	sp,sp,16
 836:	8082                	ret

0000000000000838 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 838:	7139                	addi	sp,sp,-64
 83a:	fc06                	sd	ra,56(sp)
 83c:	f822                	sd	s0,48(sp)
 83e:	f426                	sd	s1,40(sp)
 840:	ec4e                	sd	s3,24(sp)
 842:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 844:	02051493          	slli	s1,a0,0x20
 848:	9081                	srli	s1,s1,0x20
 84a:	04bd                	addi	s1,s1,15
 84c:	8091                	srli	s1,s1,0x4
 84e:	0014899b          	addiw	s3,s1,1
 852:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 854:	00000517          	auipc	a0,0x0
 858:	7ac53503          	ld	a0,1964(a0) # 1000 <freep>
 85c:	c915                	beqz	a0,890 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 85e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 860:	4798                	lw	a4,8(a5)
 862:	08977a63          	bgeu	a4,s1,8f6 <malloc+0xbe>
 866:	f04a                	sd	s2,32(sp)
 868:	e852                	sd	s4,16(sp)
 86a:	e456                	sd	s5,8(sp)
 86c:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 86e:	8a4e                	mv	s4,s3
 870:	0009871b          	sext.w	a4,s3
 874:	6685                	lui	a3,0x1
 876:	00d77363          	bgeu	a4,a3,87c <malloc+0x44>
 87a:	6a05                	lui	s4,0x1
 87c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 880:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 884:	00000917          	auipc	s2,0x0
 888:	77c90913          	addi	s2,s2,1916 # 1000 <freep>
  if (p == SBRK_ERROR)
 88c:	5afd                	li	s5,-1
 88e:	a081                	j	8ce <malloc+0x96>
 890:	f04a                	sd	s2,32(sp)
 892:	e852                	sd	s4,16(sp)
 894:	e456                	sd	s5,8(sp)
 896:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 898:	00000797          	auipc	a5,0x0
 89c:	77878793          	addi	a5,a5,1912 # 1010 <base>
 8a0:	00000717          	auipc	a4,0x0
 8a4:	76f73023          	sd	a5,1888(a4) # 1000 <freep>
 8a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8aa:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 8ae:	b7c1                	j	86e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8b0:	6398                	ld	a4,0(a5)
 8b2:	e118                	sd	a4,0(a0)
 8b4:	a8a9                	j	90e <malloc+0xd6>
  hp->s.size = nu;
 8b6:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 8ba:	0541                	addi	a0,a0,16
 8bc:	efbff0ef          	jal	7b6 <free>
  return freep;
 8c0:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 8c4:	c12d                	beqz	a0,926 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8c6:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8c8:	4798                	lw	a4,8(a5)
 8ca:	02977263          	bgeu	a4,s1,8ee <malloc+0xb6>
    if (p == freep)
 8ce:	00093703          	ld	a4,0(s2)
 8d2:	853e                	mv	a0,a5
 8d4:	fef719e3          	bne	a4,a5,8c6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8d8:	8552                	mv	a0,s4
 8da:	a27ff0ef          	jal	300 <sbrk>
  if (p == SBRK_ERROR)
 8de:	fd551ce3          	bne	a0,s5,8b6 <malloc+0x7e>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	7902                	ld	s2,32(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
 8ec:	a03d                	j	91a <malloc+0xe2>
 8ee:	7902                	ld	s2,32(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 8f6:	fae48de3          	beq	s1,a4,8b0 <malloc+0x78>
        p->s.size -= nunits;
 8fa:	4137073b          	subw	a4,a4,s3
 8fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 900:	02071693          	slli	a3,a4,0x20
 904:	01c6d713          	srli	a4,a3,0x1c
 908:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90e:	00000717          	auipc	a4,0x0
 912:	6ea73923          	sd	a0,1778(a4) # 1000 <freep>
      return (void *)(p + 1);
 916:	01078513          	addi	a0,a5,16
  }
}
 91a:	70e2                	ld	ra,56(sp)
 91c:	7442                	ld	s0,48(sp)
 91e:	74a2                	ld	s1,40(sp)
 920:	69e2                	ld	s3,24(sp)
 922:	6121                	addi	sp,sp,64
 924:	8082                	ret
 926:	7902                	ld	s2,32(sp)
 928:	6a42                	ld	s4,16(sp)
 92a:	6aa2                	ld	s5,8(sp)
 92c:	6b02                	ld	s6,0(sp)
 92e:	b7f5                	j	91a <malloc+0xe2>
