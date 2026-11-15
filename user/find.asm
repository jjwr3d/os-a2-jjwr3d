
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <match>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// Recursive wildcard matcher matching instructions
int match(char *pattern, char *str) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e04a                	sd	s2,0(sp)
   8:	1000                	addi	s0,sp,32
   a:	892e                	mv	s2,a1
    if (*pattern == '\0' && *str == '\0') return 1;
   c:	00054783          	lbu	a5,0(a0)
  10:	eb91                	bnez	a5,24 <match+0x24>
  12:	0005c503          	lbu	a0,0(a1)
  16:	00153513          	seqz	a0,a0
        if (*str != '\0' && match(pattern, str + 1)) return 1;
        return 0;
    }
    if (*pattern == *str) return match(pattern + 1, str + 1);
    return 0;
}
  1a:	60e2                	ld	ra,24(sp)
  1c:	6442                	ld	s0,16(sp)
  1e:	6902                	ld	s2,0(sp)
  20:	6105                	addi	sp,sp,32
  22:	8082                	ret
  24:	e426                	sd	s1,8(sp)
  26:	84aa                	mv	s1,a0
    if (*pattern == '*') {
  28:	02a00713          	li	a4,42
  2c:	00e78963          	beq	a5,a4,3e <match+0x3e>
    if (*pattern == *str) return match(pattern + 1, str + 1);
  30:	0005c703          	lbu	a4,0(a1)
    return 0;
  34:	4501                	li	a0,0
    if (*pattern == *str) return match(pattern + 1, str + 1);
  36:	02f70663          	beq	a4,a5,62 <match+0x62>
  3a:	64a2                	ld	s1,8(sp)
  3c:	bff9                	j	1a <match+0x1a>
        if (match(pattern + 1, str)) return 1;
  3e:	0505                	addi	a0,a0,1
  40:	fc1ff0ef          	jal	0 <match>
  44:	e515                	bnez	a0,70 <match+0x70>
        if (*str != '\0' && match(pattern, str + 1)) return 1;
  46:	00094783          	lbu	a5,0(s2)
  4a:	e399                	bnez	a5,50 <match+0x50>
  4c:	64a2                	ld	s1,8(sp)
  4e:	b7f1                	j	1a <match+0x1a>
  50:	00190593          	addi	a1,s2,1
  54:	8526                	mv	a0,s1
  56:	fabff0ef          	jal	0 <match>
  5a:	00a03533          	snez	a0,a0
  5e:	64a2                	ld	s1,8(sp)
  60:	bf6d                	j	1a <match+0x1a>
    if (*pattern == *str) return match(pattern + 1, str + 1);
  62:	0585                	addi	a1,a1,1
  64:	00148513          	addi	a0,s1,1
  68:	f99ff0ef          	jal	0 <match>
  6c:	64a2                	ld	s1,8(sp)
  6e:	b775                	j	1a <match+0x1a>
        if (match(pattern + 1, str)) return 1;
  70:	4505                	li	a0,1
  72:	64a2                	ld	s1,8(sp)
  74:	b75d                	j	1a <match+0x1a>

0000000000000076 <find>:

void find(char *path, char *pattern, char type_filter) {
  76:	d9010113          	addi	sp,sp,-624
  7a:	26113423          	sd	ra,616(sp)
  7e:	26813023          	sd	s0,608(sp)
  82:	25213823          	sd	s2,592(sp)
  86:	25313423          	sd	s3,584(sp)
  8a:	25413023          	sd	s4,576(sp)
  8e:	1c80                	addi	s0,sp,624
  90:	892a                	mv	s2,a0
  92:	8a2e                	mv	s4,a1
  94:	89b2                	mv	s3,a2
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if ((fd = open(path, 0)) < 0) {
  96:	4581                	li	a1,0
  98:	552000ef          	jal	5ea <open>
  9c:	04054263          	bltz	a0,e0 <find+0x6a>
  a0:	24913c23          	sd	s1,600(sp)
  a4:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }

    if (fstat(fd, &st) < 0) {
  a6:	d9840593          	addi	a1,s0,-616
  aa:	558000ef          	jal	602 <fstat>
  ae:	04054a63          	bltz	a0,102 <find+0x8c>
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        exit(1);
    }

    if (st.type != T_DIR) {
  b2:	da041703          	lh	a4,-608(s0)
  b6:	4785                	li	a5,1
  b8:	06f70763          	beq	a4,a5,126 <find+0xb0>
        close(fd);
  bc:	8526                	mv	a0,s1
  be:	514000ef          	jal	5d2 <close>
        return;
  c2:	25813483          	ld	s1,600(sp)
        if (st.type == T_DIR) {
            find(buf, pattern, type_filter);
        }
    }
    close(fd);
}
  c6:	26813083          	ld	ra,616(sp)
  ca:	26013403          	ld	s0,608(sp)
  ce:	25013903          	ld	s2,592(sp)
  d2:	24813983          	ld	s3,584(sp)
  d6:	24013a03          	ld	s4,576(sp)
  da:	27010113          	addi	sp,sp,624
  de:	8082                	ret
  e0:	24913c23          	sd	s1,600(sp)
  e4:	23513c23          	sd	s5,568(sp)
  e8:	23613823          	sd	s6,560(sp)
        fprintf(2, "find: cannot open %s\n", path);
  ec:	864a                	mv	a2,s2
  ee:	00001597          	auipc	a1,0x1
  f2:	ac258593          	addi	a1,a1,-1342 # bb0 <malloc+0x102>
  f6:	4509                	li	a0,2
  f8:	0d9000ef          	jal	9d0 <fprintf>
        exit(1);
  fc:	4505                	li	a0,1
  fe:	4ac000ef          	jal	5aa <exit>
 102:	23513c23          	sd	s5,568(sp)
 106:	23613823          	sd	s6,560(sp)
        fprintf(2, "find: cannot stat %s\n", path);
 10a:	864a                	mv	a2,s2
 10c:	00001597          	auipc	a1,0x1
 110:	abc58593          	addi	a1,a1,-1348 # bc8 <malloc+0x11a>
 114:	4509                	li	a0,2
 116:	0bb000ef          	jal	9d0 <fprintf>
        close(fd);
 11a:	8526                	mv	a0,s1
 11c:	4b6000ef          	jal	5d2 <close>
        exit(1);
 120:	4505                	li	a0,1
 122:	488000ef          	jal	5aa <exit>
    if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
 126:	854a                	mv	a0,s2
 128:	246000ef          	jal	36e <strlen>
 12c:	2541                	addiw	a0,a0,16
 12e:	20000793          	li	a5,512
 132:	0aa7ee63          	bltu	a5,a0,1ee <find+0x178>
 136:	23513c23          	sd	s5,568(sp)
 13a:	23613823          	sd	s6,560(sp)
    strcpy(buf, path);
 13e:	85ca                	mv	a1,s2
 140:	dc040513          	addi	a0,s0,-576
 144:	1e2000ef          	jal	326 <strcpy>
    p = buf + strlen(buf);
 148:	dc040513          	addi	a0,s0,-576
 14c:	222000ef          	jal	36e <strlen>
 150:	1502                	slli	a0,a0,0x20
 152:	9101                	srli	a0,a0,0x20
 154:	dc040793          	addi	a5,s0,-576
 158:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 15c:	00190b13          	addi	s6,s2,1
 160:	02f00793          	li	a5,47
 164:	00f90023          	sb	a5,0(s2)
        if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;
 168:	00001a97          	auipc	s5,0x1
 16c:	a78a8a93          	addi	s5,s5,-1416 # be0 <malloc+0x132>
    while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 170:	4641                	li	a2,16
 172:	db040593          	addi	a1,s0,-592
 176:	8526                	mv	a0,s1
 178:	44a000ef          	jal	5c2 <read>
 17c:	47c1                	li	a5,16
 17e:	0af51163          	bne	a0,a5,220 <find+0x1aa>
        if (de.inum == 0) continue;
 182:	db045783          	lhu	a5,-592(s0)
 186:	d7ed                	beqz	a5,170 <find+0xfa>
        if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0) continue;
 188:	85d6                	mv	a1,s5
 18a:	db240513          	addi	a0,s0,-590
 18e:	1b4000ef          	jal	342 <strcmp>
 192:	dd79                	beqz	a0,170 <find+0xfa>
 194:	00001597          	auipc	a1,0x1
 198:	a5458593          	addi	a1,a1,-1452 # be8 <malloc+0x13a>
 19c:	db240513          	addi	a0,s0,-590
 1a0:	1a2000ef          	jal	342 <strcmp>
 1a4:	d571                	beqz	a0,170 <find+0xfa>
        memmove(p, de.name, DIRSIZ);
 1a6:	4639                	li	a2,14
 1a8:	db240593          	addi	a1,s0,-590
 1ac:	855a                	mv	a0,s6
 1ae:	322000ef          	jal	4d0 <memmove>
        p[DIRSIZ] = 0;
 1b2:	000907a3          	sb	zero,15(s2)
        if (stat(buf, &st) < 0) continue;
 1b6:	d9840593          	addi	a1,s0,-616
 1ba:	dc040513          	addi	a0,s0,-576
 1be:	290000ef          	jal	44e <stat>
 1c2:	fa0547e3          	bltz	a0,170 <find+0xfa>
        int name_matches = match(pattern, de.name);
 1c6:	db240593          	addi	a1,s0,-590
 1ca:	8552                	mv	a0,s4
 1cc:	e35ff0ef          	jal	0 <match>
        if (type_filter == 'f' && (st.type != T_FILE && st.type != T_DEVICE)) type_matches = 0;
 1d0:	06600793          	li	a5,102
 1d4:	02f98163          	beq	s3,a5,1f6 <find+0x180>
        if (type_filter == 'd' && st.type != T_DIR) type_matches = 0;
 1d8:	06400793          	li	a5,100
 1dc:	04f99a63          	bne	s3,a5,230 <find+0x1ba>
 1e0:	da041703          	lh	a4,-608(s0)
 1e4:	4785                	li	a5,1
 1e6:	f8f715e3          	bne	a4,a5,170 <find+0xfa>
        if (name_matches && type_matches) {
 1ea:	c505                	beqz	a0,212 <find+0x19c>
 1ec:	a099                	j	232 <find+0x1bc>
        close(fd);
 1ee:	8526                	mv	a0,s1
 1f0:	3e2000ef          	jal	5d2 <close>
        return;
 1f4:	b5f9                	j	c2 <find+0x4c>
        if (name_matches && type_matches) {
 1f6:	c909                	beqz	a0,208 <find+0x192>
        if (type_filter == 'f' && (st.type != T_FILE && st.type != T_DEVICE)) type_matches = 0;
 1f8:	da045783          	lhu	a5,-608(s0)
 1fc:	37f9                	addiw	a5,a5,-2
        if (name_matches && type_matches) {
 1fe:	17c2                	slli	a5,a5,0x30
 200:	93c1                	srli	a5,a5,0x30
 202:	4705                	li	a4,1
 204:	02f77763          	bgeu	a4,a5,232 <find+0x1bc>
        if (st.type == T_DIR) {
 208:	da041703          	lh	a4,-608(s0)
 20c:	4785                	li	a5,1
 20e:	f6f711e3          	bne	a4,a5,170 <find+0xfa>
            find(buf, pattern, type_filter);
 212:	864e                	mv	a2,s3
 214:	85d2                	mv	a1,s4
 216:	dc040513          	addi	a0,s0,-576
 21a:	e5dff0ef          	jal	76 <find>
 21e:	bf89                	j	170 <find+0xfa>
    close(fd);
 220:	8526                	mv	a0,s1
 222:	3b0000ef          	jal	5d2 <close>
 226:	23813a83          	ld	s5,568(sp)
 22a:	23013b03          	ld	s6,560(sp)
 22e:	bd51                	j	c2 <find+0x4c>
        if (name_matches && type_matches) {
 230:	dd61                	beqz	a0,208 <find+0x192>
            printf("%s\n", buf);
 232:	dc040593          	addi	a1,s0,-576
 236:	00001517          	auipc	a0,0x1
 23a:	9ba50513          	addi	a0,a0,-1606 # bf0 <malloc+0x142>
 23e:	7bc000ef          	jal	9fa <printf>
 242:	b7d9                	j	208 <find+0x192>

0000000000000244 <main>:

int main(int argc, char *argv[]) {
 244:	711d                	addi	sp,sp,-96
 246:	ec86                	sd	ra,88(sp)
 248:	e8a2                	sd	s0,80(sp)
 24a:	1080                	addi	s0,sp,96
    if (argc < 3) {
 24c:	4789                	li	a5,2
 24e:	04a7d263          	bge	a5,a0,292 <main+0x4e>
 252:	e4a6                	sd	s1,72(sp)
 254:	e0ca                	sd	s2,64(sp)
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
 25e:	ec5e                	sd	s7,24(sp)
 260:	e862                	sd	s8,16(sp)
 262:	e466                	sd	s9,8(sp)
 264:	e06a                	sd	s10,0(sp)
 266:	89aa                	mv	s3,a0
 268:	8a2e                	mv	s4,a1
        fprintf(2, "usage: find <dir> <pattern> [-type f|d]\n");
        exit(1);
    }

    char *dir = argv[1];
 26a:	0085bc03          	ld	s8,8(a1)
    char *pattern = argv[2];
 26e:	0105bc83          	ld	s9,16(a1)
    char type_filter = 0; // 0 means no filter

    for (int i = 3; i < argc; i++) {
 272:	478d                	li	a5,3
 274:	08a7df63          	bge	a5,a0,312 <main+0xce>
 278:	448d                	li	s1,3
    char type_filter = 0; // 0 means no filter
 27a:	4b01                	li	s6,0
        if (strcmp(argv[i], "-type") == 0 && i + 1 < argc) {
 27c:	00001a97          	auipc	s5,0x1
 280:	9aca8a93          	addi	s5,s5,-1620 # c28 <malloc+0x17a>
            if (strcmp(argv[i+1], "f") == 0) type_filter = 'f';
 284:	00001b97          	auipc	s7,0x1
 288:	9acb8b93          	addi	s7,s7,-1620 # c30 <malloc+0x182>
 28c:	06600d13          	li	s10,102
 290:	a089                	j	2d2 <main+0x8e>
 292:	e4a6                	sd	s1,72(sp)
 294:	e0ca                	sd	s2,64(sp)
 296:	fc4e                	sd	s3,56(sp)
 298:	f852                	sd	s4,48(sp)
 29a:	f456                	sd	s5,40(sp)
 29c:	f05a                	sd	s6,32(sp)
 29e:	ec5e                	sd	s7,24(sp)
 2a0:	e862                	sd	s8,16(sp)
 2a2:	e466                	sd	s9,8(sp)
 2a4:	e06a                	sd	s10,0(sp)
        fprintf(2, "usage: find <dir> <pattern> [-type f|d]\n");
 2a6:	00001597          	auipc	a1,0x1
 2aa:	95258593          	addi	a1,a1,-1710 # bf8 <malloc+0x14a>
 2ae:	4509                	li	a0,2
 2b0:	720000ef          	jal	9d0 <fprintf>
        exit(1);
 2b4:	4505                	li	a0,1
 2b6:	2f4000ef          	jal	5aa <exit>
            if (strcmp(argv[i+1], "f") == 0) type_filter = 'f';
 2ba:	0921                	addi	s2,s2,8
 2bc:	9952                	add	s2,s2,s4
 2be:	85de                	mv	a1,s7
 2c0:	00093503          	ld	a0,0(s2)
 2c4:	07e000ef          	jal	342 <strcmp>
 2c8:	e90d                	bnez	a0,2fa <main+0xb6>
 2ca:	8b6a                	mv	s6,s10
    for (int i = 3; i < argc; i++) {
 2cc:	2485                	addiw	s1,s1,1
 2ce:	0134de63          	bge	s1,s3,2ea <main+0xa6>
        if (strcmp(argv[i], "-type") == 0 && i + 1 < argc) {
 2d2:	00349913          	slli	s2,s1,0x3
 2d6:	012a07b3          	add	a5,s4,s2
 2da:	85d6                	mv	a1,s5
 2dc:	6388                	ld	a0,0(a5)
 2de:	064000ef          	jal	342 <strcmp>
 2e2:	f56d                	bnez	a0,2cc <main+0x88>
 2e4:	2485                	addiw	s1,s1,1
 2e6:	fd34cae3          	blt	s1,s3,2ba <main+0x76>
            else if (strcmp(argv[i+1], "d") == 0) type_filter = 'd';
            i++;
        }
    }

    find(dir, pattern, type_filter);
 2ea:	865a                	mv	a2,s6
 2ec:	85e6                	mv	a1,s9
 2ee:	8562                	mv	a0,s8
 2f0:	d87ff0ef          	jal	76 <find>
    exit(0);
 2f4:	4501                	li	a0,0
 2f6:	2b4000ef          	jal	5aa <exit>
            else if (strcmp(argv[i+1], "d") == 0) type_filter = 'd';
 2fa:	00001597          	auipc	a1,0x1
 2fe:	93e58593          	addi	a1,a1,-1730 # c38 <malloc+0x18a>
 302:	00093503          	ld	a0,0(s2)
 306:	03c000ef          	jal	342 <strcmp>
 30a:	f169                	bnez	a0,2cc <main+0x88>
 30c:	06400b13          	li	s6,100
 310:	bf75                	j	2cc <main+0x88>
    char type_filter = 0; // 0 means no filter
 312:	4b01                	li	s6,0
 314:	bfd9                	j	2ea <main+0xa6>

0000000000000316 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 31e:	f27ff0ef          	jal	244 <main>
  exit(r);
 322:	288000ef          	jal	5aa <exit>

0000000000000326 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 32c:	87aa                	mv	a5,a0
 32e:	0585                	addi	a1,a1,1
 330:	0785                	addi	a5,a5,1
 332:	fff5c703          	lbu	a4,-1(a1)
 336:	fee78fa3          	sb	a4,-1(a5)
 33a:	fb75                	bnez	a4,32e <strcpy+0x8>
    ;
  return os;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret

0000000000000342 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 348:	00054783          	lbu	a5,0(a0)
 34c:	cb91                	beqz	a5,360 <strcmp+0x1e>
 34e:	0005c703          	lbu	a4,0(a1)
 352:	00f71763          	bne	a4,a5,360 <strcmp+0x1e>
    p++, q++;
 356:	0505                	addi	a0,a0,1
 358:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 35a:	00054783          	lbu	a5,0(a0)
 35e:	fbe5                	bnez	a5,34e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 360:	0005c503          	lbu	a0,0(a1)
}
 364:	40a7853b          	subw	a0,a5,a0
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret

000000000000036e <strlen>:

uint
strlen(const char *s)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 374:	00054783          	lbu	a5,0(a0)
 378:	cf91                	beqz	a5,394 <strlen+0x26>
 37a:	0505                	addi	a0,a0,1
 37c:	87aa                	mv	a5,a0
 37e:	86be                	mv	a3,a5
 380:	0785                	addi	a5,a5,1
 382:	fff7c703          	lbu	a4,-1(a5)
 386:	ff65                	bnez	a4,37e <strlen+0x10>
 388:	40a6853b          	subw	a0,a3,a0
 38c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  for (n = 0; s[n]; n++)
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <strlen+0x20>

0000000000000398 <memset>:

void *
memset(void *dst, int c, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 39e:	ca19                	beqz	a2,3b4 <memset+0x1c>
 3a0:	87aa                	mv	a5,a0
 3a2:	1602                	slli	a2,a2,0x20
 3a4:	9201                	srli	a2,a2,0x20
 3a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3aa:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 3ae:	0785                	addi	a5,a5,1
 3b0:	fee79de3          	bne	a5,a4,3aa <memset+0x12>
  }
  return dst;
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <strchr>:

char *
strchr(const char *s, char c)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  for (; *s; s++)
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	cb99                	beqz	a5,3da <strchr+0x20>
    if (*s == c)
 3c6:	00f58763          	beq	a1,a5,3d4 <strchr+0x1a>
  for (; *s; s++)
 3ca:	0505                	addi	a0,a0,1
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	fbfd                	bnez	a5,3c6 <strchr+0xc>
      return (char *)s;
  return 0;
 3d2:	4501                	li	a0,0
}
 3d4:	6422                	ld	s0,8(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret
  return 0;
 3da:	4501                	li	a0,0
 3dc:	bfe5                	j	3d4 <strchr+0x1a>

00000000000003de <gets>:

char *
gets(char *buf, int max)
{
 3de:	711d                	addi	sp,sp,-96
 3e0:	ec86                	sd	ra,88(sp)
 3e2:	e8a2                	sd	s0,80(sp)
 3e4:	e4a6                	sd	s1,72(sp)
 3e6:	e0ca                	sd	s2,64(sp)
 3e8:	fc4e                	sd	s3,56(sp)
 3ea:	f852                	sd	s4,48(sp)
 3ec:	f456                	sd	s5,40(sp)
 3ee:	f05a                	sd	s6,32(sp)
 3f0:	ec5e                	sd	s7,24(sp)
 3f2:	1080                	addi	s0,sp,96
 3f4:	8baa                	mv	s7,a0
 3f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 3f8:	892a                	mv	s2,a0
 3fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 3fc:	4aa9                	li	s5,10
 3fe:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 400:	89a6                	mv	s3,s1
 402:	2485                	addiw	s1,s1,1
 404:	0344d663          	bge	s1,s4,430 <gets+0x52>
    cc = read(0, &c, 1);
 408:	4605                	li	a2,1
 40a:	faf40593          	addi	a1,s0,-81
 40e:	4501                	li	a0,0
 410:	1b2000ef          	jal	5c2 <read>
    if (cc < 1)
 414:	00a05e63          	blez	a0,430 <gets+0x52>
    buf[i++] = c;
 418:	faf44783          	lbu	a5,-81(s0)
 41c:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 420:	01578763          	beq	a5,s5,42e <gets+0x50>
 424:	0905                	addi	s2,s2,1
 426:	fd679de3          	bne	a5,s6,400 <gets+0x22>
    buf[i++] = c;
 42a:	89a6                	mv	s3,s1
 42c:	a011                	j	430 <gets+0x52>
 42e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 430:	99de                	add	s3,s3,s7
 432:	00098023          	sb	zero,0(s3)
  return buf;
}
 436:	855e                	mv	a0,s7
 438:	60e6                	ld	ra,88(sp)
 43a:	6446                	ld	s0,80(sp)
 43c:	64a6                	ld	s1,72(sp)
 43e:	6906                	ld	s2,64(sp)
 440:	79e2                	ld	s3,56(sp)
 442:	7a42                	ld	s4,48(sp)
 444:	7aa2                	ld	s5,40(sp)
 446:	7b02                	ld	s6,32(sp)
 448:	6be2                	ld	s7,24(sp)
 44a:	6125                	addi	sp,sp,96
 44c:	8082                	ret

000000000000044e <stat>:

int
stat(const char *n, struct stat *st)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	e04a                	sd	s2,0(sp)
 456:	1000                	addi	s0,sp,32
 458:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 45a:	4581                	li	a1,0
 45c:	18e000ef          	jal	5ea <open>
  if (fd < 0)
 460:	02054263          	bltz	a0,484 <stat+0x36>
 464:	e426                	sd	s1,8(sp)
 466:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 468:	85ca                	mv	a1,s2
 46a:	198000ef          	jal	602 <fstat>
 46e:	892a                	mv	s2,a0
  close(fd);
 470:	8526                	mv	a0,s1
 472:	160000ef          	jal	5d2 <close>
  return r;
 476:	64a2                	ld	s1,8(sp)
}
 478:	854a                	mv	a0,s2
 47a:	60e2                	ld	ra,24(sp)
 47c:	6442                	ld	s0,16(sp)
 47e:	6902                	ld	s2,0(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret
    return -1;
 484:	597d                	li	s2,-1
 486:	bfcd                	j	478 <stat+0x2a>

0000000000000488 <atoi>:

int
atoi(const char *s)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 48e:	00054683          	lbu	a3,0(a0)
 492:	fd06879b          	addiw	a5,a3,-48
 496:	0ff7f793          	zext.b	a5,a5
 49a:	4625                	li	a2,9
 49c:	02f66863          	bltu	a2,a5,4cc <atoi+0x44>
 4a0:	872a                	mv	a4,a0
  n = 0;
 4a2:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 4a4:	0705                	addi	a4,a4,1
 4a6:	0025179b          	slliw	a5,a0,0x2
 4aa:	9fa9                	addw	a5,a5,a0
 4ac:	0017979b          	slliw	a5,a5,0x1
 4b0:	9fb5                	addw	a5,a5,a3
 4b2:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 4b6:	00074683          	lbu	a3,0(a4)
 4ba:	fd06879b          	addiw	a5,a3,-48
 4be:	0ff7f793          	zext.b	a5,a5
 4c2:	fef671e3          	bgeu	a2,a5,4a4 <atoi+0x1c>
  return n;
}
 4c6:	6422                	ld	s0,8(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret
  n = 0;
 4cc:	4501                	li	a0,0
 4ce:	bfe5                	j	4c6 <atoi+0x3e>

00000000000004d0 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e422                	sd	s0,8(sp)
 4d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4d6:	02b57463          	bgeu	a0,a1,4fe <memmove+0x2e>
    while (n-- > 0)
 4da:	00c05f63          	blez	a2,4f8 <memmove+0x28>
 4de:	1602                	slli	a2,a2,0x20
 4e0:	9201                	srli	a2,a2,0x20
 4e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4e8:	0585                	addi	a1,a1,1
 4ea:	0705                	addi	a4,a4,1
 4ec:	fff5c683          	lbu	a3,-1(a1)
 4f0:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 4f4:	fef71ae3          	bne	a4,a5,4e8 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4f8:	6422                	ld	s0,8(sp)
 4fa:	0141                	addi	sp,sp,16
 4fc:	8082                	ret
    dst += n;
 4fe:	00c50733          	add	a4,a0,a2
    src += n;
 502:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 504:	fec05ae3          	blez	a2,4f8 <memmove+0x28>
 508:	fff6079b          	addiw	a5,a2,-1
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	fff7c793          	not	a5,a5
 514:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 516:	15fd                	addi	a1,a1,-1
 518:	177d                	addi	a4,a4,-1
 51a:	0005c683          	lbu	a3,0(a1)
 51e:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 522:	fee79ae3          	bne	a5,a4,516 <memmove+0x46>
 526:	bfc9                	j	4f8 <memmove+0x28>

0000000000000528 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e422                	sd	s0,8(sp)
 52c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 52e:	ca05                	beqz	a2,55e <memcmp+0x36>
 530:	fff6069b          	addiw	a3,a2,-1
 534:	1682                	slli	a3,a3,0x20
 536:	9281                	srli	a3,a3,0x20
 538:	0685                	addi	a3,a3,1
 53a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 53c:	00054783          	lbu	a5,0(a0)
 540:	0005c703          	lbu	a4,0(a1)
 544:	00e79863          	bne	a5,a4,554 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 548:	0505                	addi	a0,a0,1
    p2++;
 54a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 54c:	fed518e3          	bne	a0,a3,53c <memcmp+0x14>
  }
  return 0;
 550:	4501                	li	a0,0
 552:	a019                	j	558 <memcmp+0x30>
      return *p1 - *p2;
 554:	40e7853b          	subw	a0,a5,a4
}
 558:	6422                	ld	s0,8(sp)
 55a:	0141                	addi	sp,sp,16
 55c:	8082                	ret
  return 0;
 55e:	4501                	li	a0,0
 560:	bfe5                	j	558 <memcmp+0x30>

0000000000000562 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 562:	1141                	addi	sp,sp,-16
 564:	e406                	sd	ra,8(sp)
 566:	e022                	sd	s0,0(sp)
 568:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 56a:	f67ff0ef          	jal	4d0 <memmove>
}
 56e:	60a2                	ld	ra,8(sp)
 570:	6402                	ld	s0,0(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret

0000000000000576 <sbrk>:

char *
sbrk(int n)
{
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 57e:	4585                	li	a1,1
 580:	0b2000ef          	jal	632 <sys_sbrk>
}
 584:	60a2                	ld	ra,8(sp)
 586:	6402                	ld	s0,0(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret

000000000000058c <sbrklazy>:

char *
sbrklazy(int n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e406                	sd	ra,8(sp)
 590:	e022                	sd	s0,0(sp)
 592:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 594:	4589                	li	a1,2
 596:	09c000ef          	jal	632 <sys_sbrk>
}
 59a:	60a2                	ld	ra,8(sp)
 59c:	6402                	ld	s0,0(sp)
 59e:	0141                	addi	sp,sp,16
 5a0:	8082                	ret

00000000000005a2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a2:	4885                	li	a7,1
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <exit>:
.global exit
exit:
 li a7, SYS_exit
 5aa:	4889                	li	a7,2
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b2:	488d                	li	a7,3
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ba:	4891                	li	a7,4
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <read>:
.global read
read:
 li a7, SYS_read
 5c2:	4895                	li	a7,5
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <write>:
.global write
write:
 li a7, SYS_write
 5ca:	48c1                	li	a7,16
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <close>:
.global close
close:
 li a7, SYS_close
 5d2:	48d5                	li	a7,21
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <kill>:
.global kill
kill:
 li a7, SYS_kill
 5da:	4899                	li	a7,6
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e2:	489d                	li	a7,7
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <open>:
.global open
open:
 li a7, SYS_open
 5ea:	48bd                	li	a7,15
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f2:	48c5                	li	a7,17
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5fa:	48c9                	li	a7,18
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 602:	48a1                	li	a7,8
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <link>:
.global link
link:
 li a7, SYS_link
 60a:	48cd                	li	a7,19
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 612:	48d1                	li	a7,20
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 61a:	48a5                	li	a7,9
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <dup>:
.global dup
dup:
 li a7, SYS_dup
 622:	48a9                	li	a7,10
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 62a:	48ad                	li	a7,11
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 632:	48b1                	li	a7,12
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <pause>:
.global pause
pause:
 li a7, SYS_pause
 63a:	48b5                	li	a7,13
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 642:	48b9                	li	a7,14
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <sync>:
.global sync
sync:
 li a7, SYS_sync
 64a:	48d9                	li	a7,22
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 652:	48dd                	li	a7,23
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <trace>:
.global trace
trace:
 li a7, SYS_trace
 65a:	48e1                	li	a7,24
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 662:	48e5                	li	a7,25
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 66a:	48e9                	li	a7,26
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 672:	1101                	addi	sp,sp,-32
 674:	ec06                	sd	ra,24(sp)
 676:	e822                	sd	s0,16(sp)
 678:	1000                	addi	s0,sp,32
 67a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 67e:	4605                	li	a2,1
 680:	fef40593          	addi	a1,s0,-17
 684:	f47ff0ef          	jal	5ca <write>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6105                	addi	sp,sp,32
 68e:	8082                	ret

0000000000000690 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 690:	715d                	addi	sp,sp,-80
 692:	e486                	sd	ra,72(sp)
 694:	e0a2                	sd	s0,64(sp)
 696:	f84a                	sd	s2,48(sp)
 698:	0880                	addi	s0,sp,80
 69a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 69c:	c299                	beqz	a3,6a2 <printint+0x12>
 69e:	0805c363          	bltz	a1,724 <printint+0x94>
  neg = 0;
 6a2:	4881                	li	a7,0
 6a4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6a8:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 6aa:	00000517          	auipc	a0,0x0
 6ae:	59e50513          	addi	a0,a0,1438 # c48 <digits>
 6b2:	883e                	mv	a6,a5
 6b4:	2785                	addiw	a5,a5,1
 6b6:	02c5f733          	remu	a4,a1,a2
 6ba:	972a                	add	a4,a4,a0
 6bc:	00074703          	lbu	a4,0(a4)
 6c0:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 6c4:	872e                	mv	a4,a1
 6c6:	02c5d5b3          	divu	a1,a1,a2
 6ca:	0685                	addi	a3,a3,1
 6cc:	fec773e3          	bgeu	a4,a2,6b2 <printint+0x22>
  if (neg)
 6d0:	00088b63          	beqz	a7,6e6 <printint+0x56>
    buf[i++] = '-';
 6d4:	fd078793          	addi	a5,a5,-48
 6d8:	97a2                	add	a5,a5,s0
 6da:	02d00713          	li	a4,45
 6de:	fee78423          	sb	a4,-24(a5)
 6e2:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 6e6:	02f05a63          	blez	a5,71a <printint+0x8a>
 6ea:	fc26                	sd	s1,56(sp)
 6ec:	f44e                	sd	s3,40(sp)
 6ee:	fb840713          	addi	a4,s0,-72
 6f2:	00f704b3          	add	s1,a4,a5
 6f6:	fff70993          	addi	s3,a4,-1
 6fa:	99be                	add	s3,s3,a5
 6fc:	37fd                	addiw	a5,a5,-1
 6fe:	1782                	slli	a5,a5,0x20
 700:	9381                	srli	a5,a5,0x20
 702:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 706:	fff4c583          	lbu	a1,-1(s1)
 70a:	854a                	mv	a0,s2
 70c:	f67ff0ef          	jal	672 <putc>
  while (--i >= 0)
 710:	14fd                	addi	s1,s1,-1
 712:	ff349ae3          	bne	s1,s3,706 <printint+0x76>
 716:	74e2                	ld	s1,56(sp)
 718:	79a2                	ld	s3,40(sp)
}
 71a:	60a6                	ld	ra,72(sp)
 71c:	6406                	ld	s0,64(sp)
 71e:	7942                	ld	s2,48(sp)
 720:	6161                	addi	sp,sp,80
 722:	8082                	ret
    x = -xx;
 724:	40b005b3          	neg	a1,a1
    neg = 1;
 728:	4885                	li	a7,1
    x = -xx;
 72a:	bfad                	j	6a4 <printint+0x14>

000000000000072c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 72c:	711d                	addi	sp,sp,-96
 72e:	ec86                	sd	ra,88(sp)
 730:	e8a2                	sd	s0,80(sp)
 732:	e0ca                	sd	s2,64(sp)
 734:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 736:	0005c903          	lbu	s2,0(a1)
 73a:	28090663          	beqz	s2,9c6 <vprintf+0x29a>
 73e:	e4a6                	sd	s1,72(sp)
 740:	fc4e                	sd	s3,56(sp)
 742:	f852                	sd	s4,48(sp)
 744:	f456                	sd	s5,40(sp)
 746:	f05a                	sd	s6,32(sp)
 748:	ec5e                	sd	s7,24(sp)
 74a:	e862                	sd	s8,16(sp)
 74c:	e466                	sd	s9,8(sp)
 74e:	8b2a                	mv	s6,a0
 750:	8a2e                	mv	s4,a1
 752:	8bb2                	mv	s7,a2
  state = 0;
 754:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 756:	4481                	li	s1,0
 758:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 75a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 75e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 762:	06c00c93          	li	s9,108
 766:	a005                	j	786 <vprintf+0x5a>
        putc(fd, c0);
 768:	85ca                	mv	a1,s2
 76a:	855a                	mv	a0,s6
 76c:	f07ff0ef          	jal	672 <putc>
 770:	a019                	j	776 <vprintf+0x4a>
    } else if (state == '%') {
 772:	03598263          	beq	s3,s5,796 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 776:	2485                	addiw	s1,s1,1
 778:	8726                	mv	a4,s1
 77a:	009a07b3          	add	a5,s4,s1
 77e:	0007c903          	lbu	s2,0(a5)
 782:	22090a63          	beqz	s2,9b6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 786:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 78a:	fe0994e3          	bnez	s3,772 <vprintf+0x46>
      if (c0 == '%') {
 78e:	fd579de3          	bne	a5,s5,768 <vprintf+0x3c>
        state = '%';
 792:	89be                	mv	s3,a5
 794:	b7cd                	j	776 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 796:	00ea06b3          	add	a3,s4,a4
 79a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 79e:	8636                	mv	a2,a3
      if (c1)
 7a0:	c681                	beqz	a3,7a8 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 7a2:	9752                	add	a4,a4,s4
 7a4:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 7a8:	05878363          	beq	a5,s8,7ee <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 7ac:	05978d63          	beq	a5,s9,806 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 7b0:	07500713          	li	a4,117
 7b4:	0ee78763          	beq	a5,a4,8a2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 7b8:	07800713          	li	a4,120
 7bc:	12e78963          	beq	a5,a4,8ee <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 7c0:	07000713          	li	a4,112
 7c4:	14e78e63          	beq	a5,a4,920 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 7c8:	06300713          	li	a4,99
 7cc:	18e78e63          	beq	a5,a4,968 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 7d0:	07300713          	li	a4,115
 7d4:	1ae78463          	beq	a5,a4,97c <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 7d8:	02500713          	li	a4,37
 7dc:	04e79563          	bne	a5,a4,826 <vprintf+0xfa>
        putc(fd, '%');
 7e0:	02500593          	li	a1,37
 7e4:	855a                	mv	a0,s6
 7e6:	e8dff0ef          	jal	672 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b769                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7ee:	008b8913          	addi	s2,s7,8
 7f2:	4685                	li	a3,1
 7f4:	4629                	li	a2,10
 7f6:	000ba583          	lw	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	e95ff0ef          	jal	690 <printint>
 800:	8bca                	mv	s7,s2
      state = 0;
 802:	4981                	li	s3,0
 804:	bf8d                	j	776 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 806:	06400793          	li	a5,100
 80a:	02f68963          	beq	a3,a5,83c <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 80e:	06c00793          	li	a5,108
 812:	04f68263          	beq	a3,a5,856 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 816:	07500793          	li	a5,117
 81a:	0af68063          	beq	a3,a5,8ba <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 81e:	07800793          	li	a5,120
 822:	0ef68263          	beq	a3,a5,906 <vprintf+0x1da>
        putc(fd, '%');
 826:	02500593          	li	a1,37
 82a:	855a                	mv	a0,s6
 82c:	e47ff0ef          	jal	672 <putc>
        putc(fd, c0);
 830:	85ca                	mv	a1,s2
 832:	855a                	mv	a0,s6
 834:	e3fff0ef          	jal	672 <putc>
      state = 0;
 838:	4981                	li	s3,0
 83a:	bf35                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 83c:	008b8913          	addi	s2,s7,8
 840:	4685                	li	a3,1
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	e47ff0ef          	jal	690 <printint>
        i += 1;
 84e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 1;
 854:	b70d                	j	776 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 856:	06400793          	li	a5,100
 85a:	02f60763          	beq	a2,a5,888 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 85e:	07500793          	li	a5,117
 862:	06f60963          	beq	a2,a5,8d4 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 866:	07800793          	li	a5,120
 86a:	faf61ee3          	bne	a2,a5,826 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 86e:	008b8913          	addi	s2,s7,8
 872:	4681                	li	a3,0
 874:	4641                	li	a2,16
 876:	000bb583          	ld	a1,0(s7)
 87a:	855a                	mv	a0,s6
 87c:	e15ff0ef          	jal	690 <printint>
        i += 2;
 880:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
        i += 2;
 886:	bdc5                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 888:	008b8913          	addi	s2,s7,8
 88c:	4685                	li	a3,1
 88e:	4629                	li	a2,10
 890:	000bb583          	ld	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	dfbff0ef          	jal	690 <printint>
        i += 2;
 89a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 89c:	8bca                	mv	s7,s2
      state = 0;
 89e:	4981                	li	s3,0
        i += 2;
 8a0:	bdd9                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8a2:	008b8913          	addi	s2,s7,8
 8a6:	4681                	li	a3,0
 8a8:	4629                	li	a2,10
 8aa:	000be583          	lwu	a1,0(s7)
 8ae:	855a                	mv	a0,s6
 8b0:	de1ff0ef          	jal	690 <printint>
 8b4:	8bca                	mv	s7,s2
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	bd7d                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ba:	008b8913          	addi	s2,s7,8
 8be:	4681                	li	a3,0
 8c0:	4629                	li	a2,10
 8c2:	000bb583          	ld	a1,0(s7)
 8c6:	855a                	mv	a0,s6
 8c8:	dc9ff0ef          	jal	690 <printint>
        i += 1;
 8cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ce:	8bca                	mv	s7,s2
      state = 0;
 8d0:	4981                	li	s3,0
        i += 1;
 8d2:	b555                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d4:	008b8913          	addi	s2,s7,8
 8d8:	4681                	li	a3,0
 8da:	4629                	li	a2,10
 8dc:	000bb583          	ld	a1,0(s7)
 8e0:	855a                	mv	a0,s6
 8e2:	dafff0ef          	jal	690 <printint>
        i += 2;
 8e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e8:	8bca                	mv	s7,s2
      state = 0;
 8ea:	4981                	li	s3,0
        i += 2;
 8ec:	b569                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8ee:	008b8913          	addi	s2,s7,8
 8f2:	4681                	li	a3,0
 8f4:	4641                	li	a2,16
 8f6:	000be583          	lwu	a1,0(s7)
 8fa:	855a                	mv	a0,s6
 8fc:	d95ff0ef          	jal	690 <printint>
 900:	8bca                	mv	s7,s2
      state = 0;
 902:	4981                	li	s3,0
 904:	bd8d                	j	776 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 906:	008b8913          	addi	s2,s7,8
 90a:	4681                	li	a3,0
 90c:	4641                	li	a2,16
 90e:	000bb583          	ld	a1,0(s7)
 912:	855a                	mv	a0,s6
 914:	d7dff0ef          	jal	690 <printint>
        i += 1;
 918:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 91a:	8bca                	mv	s7,s2
      state = 0;
 91c:	4981                	li	s3,0
        i += 1;
 91e:	bda1                	j	776 <vprintf+0x4a>
 920:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 922:	008b8d13          	addi	s10,s7,8
 926:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 92a:	03000593          	li	a1,48
 92e:	855a                	mv	a0,s6
 930:	d43ff0ef          	jal	672 <putc>
  putc(fd, 'x');
 934:	07800593          	li	a1,120
 938:	855a                	mv	a0,s6
 93a:	d39ff0ef          	jal	672 <putc>
 93e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 940:	00000b97          	auipc	s7,0x0
 944:	308b8b93          	addi	s7,s7,776 # c48 <digits>
 948:	03c9d793          	srli	a5,s3,0x3c
 94c:	97de                	add	a5,a5,s7
 94e:	0007c583          	lbu	a1,0(a5)
 952:	855a                	mv	a0,s6
 954:	d1fff0ef          	jal	672 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 958:	0992                	slli	s3,s3,0x4
 95a:	397d                	addiw	s2,s2,-1
 95c:	fe0916e3          	bnez	s2,948 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 960:	8bea                	mv	s7,s10
      state = 0;
 962:	4981                	li	s3,0
 964:	6d02                	ld	s10,0(sp)
 966:	bd01                	j	776 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 968:	008b8913          	addi	s2,s7,8
 96c:	000bc583          	lbu	a1,0(s7)
 970:	855a                	mv	a0,s6
 972:	d01ff0ef          	jal	672 <putc>
 976:	8bca                	mv	s7,s2
      state = 0;
 978:	4981                	li	s3,0
 97a:	bbf5                	j	776 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 97c:	008b8993          	addi	s3,s7,8
 980:	000bb903          	ld	s2,0(s7)
 984:	00090f63          	beqz	s2,9a2 <vprintf+0x276>
        for (; *s; s++)
 988:	00094583          	lbu	a1,0(s2)
 98c:	c195                	beqz	a1,9b0 <vprintf+0x284>
          putc(fd, *s);
 98e:	855a                	mv	a0,s6
 990:	ce3ff0ef          	jal	672 <putc>
        for (; *s; s++)
 994:	0905                	addi	s2,s2,1
 996:	00094583          	lbu	a1,0(s2)
 99a:	f9f5                	bnez	a1,98e <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 99c:	8bce                	mv	s7,s3
      state = 0;
 99e:	4981                	li	s3,0
 9a0:	bbd9                	j	776 <vprintf+0x4a>
          s = "(null)";
 9a2:	00000917          	auipc	s2,0x0
 9a6:	29e90913          	addi	s2,s2,670 # c40 <malloc+0x192>
        for (; *s; s++)
 9aa:	02800593          	li	a1,40
 9ae:	b7c5                	j	98e <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 9b0:	8bce                	mv	s7,s3
      state = 0;
 9b2:	4981                	li	s3,0
 9b4:	b3c9                	j	776 <vprintf+0x4a>
 9b6:	64a6                	ld	s1,72(sp)
 9b8:	79e2                	ld	s3,56(sp)
 9ba:	7a42                	ld	s4,48(sp)
 9bc:	7aa2                	ld	s5,40(sp)
 9be:	7b02                	ld	s6,32(sp)
 9c0:	6be2                	ld	s7,24(sp)
 9c2:	6c42                	ld	s8,16(sp)
 9c4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9c6:	60e6                	ld	ra,88(sp)
 9c8:	6446                	ld	s0,80(sp)
 9ca:	6906                	ld	s2,64(sp)
 9cc:	6125                	addi	sp,sp,96
 9ce:	8082                	ret

00000000000009d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9d0:	715d                	addi	sp,sp,-80
 9d2:	ec06                	sd	ra,24(sp)
 9d4:	e822                	sd	s0,16(sp)
 9d6:	1000                	addi	s0,sp,32
 9d8:	e010                	sd	a2,0(s0)
 9da:	e414                	sd	a3,8(s0)
 9dc:	e818                	sd	a4,16(s0)
 9de:	ec1c                	sd	a5,24(s0)
 9e0:	03043023          	sd	a6,32(s0)
 9e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ec:	8622                	mv	a2,s0
 9ee:	d3fff0ef          	jal	72c <vprintf>
}
 9f2:	60e2                	ld	ra,24(sp)
 9f4:	6442                	ld	s0,16(sp)
 9f6:	6161                	addi	sp,sp,80
 9f8:	8082                	ret

00000000000009fa <printf>:

void
printf(const char *fmt, ...)
{
 9fa:	711d                	addi	sp,sp,-96
 9fc:	ec06                	sd	ra,24(sp)
 9fe:	e822                	sd	s0,16(sp)
 a00:	1000                	addi	s0,sp,32
 a02:	e40c                	sd	a1,8(s0)
 a04:	e810                	sd	a2,16(s0)
 a06:	ec14                	sd	a3,24(s0)
 a08:	f018                	sd	a4,32(s0)
 a0a:	f41c                	sd	a5,40(s0)
 a0c:	03043823          	sd	a6,48(s0)
 a10:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a14:	00840613          	addi	a2,s0,8
 a18:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a1c:	85aa                	mv	a1,a0
 a1e:	4505                	li	a0,1
 a20:	d0dff0ef          	jal	72c <vprintf>
}
 a24:	60e2                	ld	ra,24(sp)
 a26:	6442                	ld	s0,16(sp)
 a28:	6125                	addi	sp,sp,96
 a2a:	8082                	ret

0000000000000a2c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a2c:	1141                	addi	sp,sp,-16
 a2e:	e422                	sd	s0,8(sp)
 a30:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 a32:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a36:	00001797          	auipc	a5,0x1
 a3a:	5ca7b783          	ld	a5,1482(a5) # 2000 <freep>
 a3e:	a02d                	j	a68 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 a40:	4618                	lw	a4,8(a2)
 a42:	9f2d                	addw	a4,a4,a1
 a44:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a48:	6398                	ld	a4,0(a5)
 a4a:	6310                	ld	a2,0(a4)
 a4c:	a83d                	j	a8a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 a4e:	ff852703          	lw	a4,-8(a0)
 a52:	9f31                	addw	a4,a4,a2
 a54:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a56:	ff053683          	ld	a3,-16(a0)
 a5a:	a091                	j	a9e <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5c:	6398                	ld	a4,0(a5)
 a5e:	00e7e463          	bltu	a5,a4,a66 <free+0x3a>
 a62:	00e6ea63          	bltu	a3,a4,a76 <free+0x4a>
{
 a66:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a68:	fed7fae3          	bgeu	a5,a3,a5c <free+0x30>
 a6c:	6398                	ld	a4,0(a5)
 a6e:	00e6e463          	bltu	a3,a4,a76 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a72:	fee7eae3          	bltu	a5,a4,a66 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 a76:	ff852583          	lw	a1,-8(a0)
 a7a:	6390                	ld	a2,0(a5)
 a7c:	02059813          	slli	a6,a1,0x20
 a80:	01c85713          	srli	a4,a6,0x1c
 a84:	9736                	add	a4,a4,a3
 a86:	fae60de3          	beq	a2,a4,a40 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a8a:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 a8e:	4790                	lw	a2,8(a5)
 a90:	02061593          	slli	a1,a2,0x20
 a94:	01c5d713          	srli	a4,a1,0x1c
 a98:	973e                	add	a4,a4,a5
 a9a:	fae68ae3          	beq	a3,a4,a4e <free+0x22>
    p->s.ptr = bp->s.ptr;
 a9e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 aa0:	00001717          	auipc	a4,0x1
 aa4:	56f73023          	sd	a5,1376(a4) # 2000 <freep>
}
 aa8:	6422                	ld	s0,8(sp)
 aaa:	0141                	addi	sp,sp,16
 aac:	8082                	ret

0000000000000aae <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 aae:	7139                	addi	sp,sp,-64
 ab0:	fc06                	sd	ra,56(sp)
 ab2:	f822                	sd	s0,48(sp)
 ab4:	f426                	sd	s1,40(sp)
 ab6:	ec4e                	sd	s3,24(sp)
 ab8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 aba:	02051493          	slli	s1,a0,0x20
 abe:	9081                	srli	s1,s1,0x20
 ac0:	04bd                	addi	s1,s1,15
 ac2:	8091                	srli	s1,s1,0x4
 ac4:	0014899b          	addiw	s3,s1,1
 ac8:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 aca:	00001517          	auipc	a0,0x1
 ace:	53653503          	ld	a0,1334(a0) # 2000 <freep>
 ad2:	c915                	beqz	a0,b06 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 ad4:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 ad6:	4798                	lw	a4,8(a5)
 ad8:	08977a63          	bgeu	a4,s1,b6c <malloc+0xbe>
 adc:	f04a                	sd	s2,32(sp)
 ade:	e852                	sd	s4,16(sp)
 ae0:	e456                	sd	s5,8(sp)
 ae2:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 ae4:	8a4e                	mv	s4,s3
 ae6:	0009871b          	sext.w	a4,s3
 aea:	6685                	lui	a3,0x1
 aec:	00d77363          	bgeu	a4,a3,af2 <malloc+0x44>
 af0:	6a05                	lui	s4,0x1
 af2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 af6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 afa:	00001917          	auipc	s2,0x1
 afe:	50690913          	addi	s2,s2,1286 # 2000 <freep>
  if (p == SBRK_ERROR)
 b02:	5afd                	li	s5,-1
 b04:	a081                	j	b44 <malloc+0x96>
 b06:	f04a                	sd	s2,32(sp)
 b08:	e852                	sd	s4,16(sp)
 b0a:	e456                	sd	s5,8(sp)
 b0c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b0e:	00001797          	auipc	a5,0x1
 b12:	50278793          	addi	a5,a5,1282 # 2010 <base>
 b16:	00001717          	auipc	a4,0x1
 b1a:	4ef73523          	sd	a5,1258(a4) # 2000 <freep>
 b1e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b20:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 b24:	b7c1                	j	ae4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b26:	6398                	ld	a4,0(a5)
 b28:	e118                	sd	a4,0(a0)
 b2a:	a8a9                	j	b84 <malloc+0xd6>
  hp->s.size = nu;
 b2c:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 b30:	0541                	addi	a0,a0,16
 b32:	efbff0ef          	jal	a2c <free>
  return freep;
 b36:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 b3a:	c12d                	beqz	a0,b9c <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b3c:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b3e:	4798                	lw	a4,8(a5)
 b40:	02977263          	bgeu	a4,s1,b64 <malloc+0xb6>
    if (p == freep)
 b44:	00093703          	ld	a4,0(s2)
 b48:	853e                	mv	a0,a5
 b4a:	fef719e3          	bne	a4,a5,b3c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b4e:	8552                	mv	a0,s4
 b50:	a27ff0ef          	jal	576 <sbrk>
  if (p == SBRK_ERROR)
 b54:	fd551ce3          	bne	a0,s5,b2c <malloc+0x7e>
        return 0;
 b58:	4501                	li	a0,0
 b5a:	7902                	ld	s2,32(sp)
 b5c:	6a42                	ld	s4,16(sp)
 b5e:	6aa2                	ld	s5,8(sp)
 b60:	6b02                	ld	s6,0(sp)
 b62:	a03d                	j	b90 <malloc+0xe2>
 b64:	7902                	ld	s2,32(sp)
 b66:	6a42                	ld	s4,16(sp)
 b68:	6aa2                	ld	s5,8(sp)
 b6a:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b6c:	fae48de3          	beq	s1,a4,b26 <malloc+0x78>
        p->s.size -= nunits;
 b70:	4137073b          	subw	a4,a4,s3
 b74:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b76:	02071693          	slli	a3,a4,0x20
 b7a:	01c6d713          	srli	a4,a3,0x1c
 b7e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b80:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b84:	00001717          	auipc	a4,0x1
 b88:	46a73e23          	sd	a0,1148(a4) # 2000 <freep>
      return (void *)(p + 1);
 b8c:	01078513          	addi	a0,a5,16
  }
}
 b90:	70e2                	ld	ra,56(sp)
 b92:	7442                	ld	s0,48(sp)
 b94:	74a2                	ld	s1,40(sp)
 b96:	69e2                	ld	s3,24(sp)
 b98:	6121                	addi	sp,sp,64
 b9a:	8082                	ret
 b9c:	7902                	ld	s2,32(sp)
 b9e:	6a42                	ld	s4,16(sp)
 ba0:	6aa2                	ld	s5,8(sp)
 ba2:	6b02                	ld	s6,0(sp)
 ba4:	b7f5                	j	b90 <malloc+0xe2>
