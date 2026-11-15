
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	96010113          	addi	sp,sp,-1696
   4:	68113c23          	sd	ra,1688(sp)
   8:	68813823          	sd	s0,1680(sp)
   c:	68913423          	sd	s1,1672(sp)
  10:	69213023          	sd	s2,1664(sp)
  14:	67313c23          	sd	s3,1656(sp)
  18:	6a010413          	addi	s0,sp,1696
  1c:	84ae                	mv	s1,a1
    int n_limit = -1;
    int cmd_idx = 1;

    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  1e:	4785                	li	a5,1
  20:	00a7c963          	blt	a5,a0,32 <main+0x32>
            exit(1);
        }
        cmd_idx = 3;
    }

    char *cmd = argv[cmd_idx];
  24:	659c                	ld	a5,8(a1)
  26:	96f43023          	sd	a5,-1696(s0)
    int n_limit = -1;
  2a:	597d                	li	s2,-1
    char *xargv[MAXARG];
    int base_argc = 0;
  2c:	96043423          	sd	zero,-1688(s0)
  30:	a475                	j	2dc <main+0x2dc>
  32:	89aa                	mv	s3,a0
    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  34:	00001597          	auipc	a1,0x1
  38:	b7c58593          	addi	a1,a1,-1156 # bb0 <malloc+0xf8>
  3c:	6488                	ld	a0,8(s1)
  3e:	30e000ef          	jal	34c <strcmp>
  42:	26051163          	bnez	a0,2a4 <main+0x2a4>
        if (argc < 4) {
  46:	478d                	li	a5,3
  48:	0337cc63          	blt	a5,s3,80 <main+0x80>
  4c:	67413823          	sd	s4,1648(sp)
  50:	67513423          	sd	s5,1640(sp)
  54:	67613023          	sd	s6,1632(sp)
  58:	65713c23          	sd	s7,1624(sp)
  5c:	65813823          	sd	s8,1616(sp)
  60:	65913423          	sd	s9,1608(sp)
  64:	65a13023          	sd	s10,1600(sp)
  68:	63b13c23          	sd	s11,1592(sp)
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
  6c:	00001597          	auipc	a1,0x1
  70:	b4c58593          	addi	a1,a1,-1204 # bb8 <malloc+0x100>
  74:	4509                	li	a0,2
  76:	165000ef          	jal	9da <fprintf>
            exit(1);
  7a:	4505                	li	a0,1
  7c:	538000ef          	jal	5b4 <exit>
        n_limit = atoi(argv[2]);
  80:	6888                	ld	a0,16(s1)
  82:	410000ef          	jal	492 <atoi>
  86:	892a                	mv	s2,a0
        cmd_idx = 3;
  88:	468d                	li	a3,3
        if (n_limit < 1) {
  8a:	20a04f63          	bgtz	a0,2a8 <main+0x2a8>
  8e:	67413823          	sd	s4,1648(sp)
  92:	67513423          	sd	s5,1640(sp)
  96:	67613023          	sd	s6,1632(sp)
  9a:	65713c23          	sd	s7,1624(sp)
  9e:	65813823          	sd	s8,1616(sp)
  a2:	65913423          	sd	s9,1608(sp)
  a6:	65a13023          	sd	s10,1600(sp)
  aa:	63b13c23          	sd	s11,1592(sp)
            fprintf(2, "usage: xargs [-n N] cmd [args...]\n");
  ae:	00001597          	auipc	a1,0x1
  b2:	b0a58593          	addi	a1,a1,-1270 # bb8 <malloc+0x100>
  b6:	4509                	li	a0,2
  b8:	123000ef          	jal	9da <fprintf>
            exit(1);
  bc:	4505                	li	a0,1
  be:	4f6000ef          	jal	5b4 <exit>
        char *last_processed = buf;

        while (*p) {
            // Check if character is a delimiter
            if (*p == ' ' || *p == '\t' || *p == '\n') {
                if (word_start) {
  c2:	ce9d                	beqz	a3,100 <main+0x100>
                    *p = '\0';
  c4:	00048023          	sb	zero,0(s1)
                    words[word_count++] = word_start;
  c8:	0017079b          	addiw	a5,a4,1
  cc:	070e                	slli	a4,a4,0x3
  ce:	f9070713          	addi	a4,a4,-112
  d2:	9722                	add	a4,a4,s0
  d4:	a0d73023          	sd	a3,-1536(a4)
  d8:	873e                	mv	a4,a5
                    word_start = 0;
                }
                
                // Trigger condition
                int should_run = 0;
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
  da:	0b590363          	beq	s2,s5,180 <main+0x180>
                    should_run = 1; // Run once per non-empty line
                } else if (n_limit > 0 && word_count == n_limit) {
  de:	86d2                	mv	a3,s4
  e0:	02e90863          	beq	s2,a4,110 <main+0x110>
                    last_processed = p + 1;
                }
            } else {
                if (!word_start) word_start = p;
            }
            p++;
  e4:	0485                	addi	s1,s1,1
        while (*p) {
  e6:	0004c783          	lbu	a5,0(s1)
  ea:	cfc9                	beqz	a5,184 <main+0x184>
            if (*p == ' ' || *p == '\t' || *p == '\n') {
  ec:	fd378be3          	beq	a5,s3,c2 <main+0xc2>
  f0:	37dd                	addiw	a5,a5,-9
  f2:	0ff7f793          	zext.b	a5,a5
  f6:	fcfb76e3          	bgeu	s6,a5,c2 <main+0xc2>
                if (!word_start) word_start = p;
  fa:	f6ed                	bnez	a3,e4 <main+0xe4>
  fc:	86a6                	mv	a3,s1
  fe:	b7dd                	j	e4 <main+0xe4>
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 100:	fd591fe3          	bne	s2,s5,de <main+0xde>
 104:	0004c783          	lbu	a5,0(s1)
 108:	fda79ee3          	bne	a5,s10,e4 <main+0xe4>
 10c:	fce05ce3          	blez	a4,e4 <main+0xe4>
 110:	99040613          	addi	a2,s0,-1648
                    words[word_count++] = word_start;
 114:	97843683          	ld	a3,-1672(s0)
 118:	87d2                	mv	a5,s4
                        xargv[curr_argc++] = words[i];
 11a:	620c                	ld	a1,0(a2)
 11c:	e28c                	sd	a1,0(a3)
                    for (int i = 0; i < word_count; i++) {
 11e:	2785                	addiw	a5,a5,1
 120:	0621                	addi	a2,a2,8
 122:	06a1                	addi	a3,a3,8
 124:	fee7cbe3          	blt	a5,a4,11a <main+0x11a>
                    xargv[curr_argc] = 0;
 128:	fff7079b          	addiw	a5,a4,-1
 12c:	00fd87bb          	addw	a5,s11,a5
 130:	078e                	slli	a5,a5,0x3
 132:	f9078793          	addi	a5,a5,-112
 136:	97a2                	add	a5,a5,s0
 138:	f007b023          	sd	zero,-256(a5)
                    int pid = fork();
 13c:	470000ef          	jal	5ac <fork>
                    if (pid == 0) {
 140:	c105                	beqz	a0,160 <main+0x160>
                        wait(&status);
 142:	98c40513          	addi	a0,s0,-1652
 146:	476000ef          	jal	5bc <wait>
                        if (status != 0) global_status = 1;
 14a:	98c42783          	lw	a5,-1652(s0)
 14e:	c781                	beqz	a5,156 <main+0x156>
 150:	4785                	li	a5,1
 152:	96f43823          	sd	a5,-1680(s0)
                    last_processed = p + 1;
 156:	00148593          	addi	a1,s1,1
 15a:	86d2                	mv	a3,s4
                    word_count = 0;
 15c:	8752                	mv	a4,s4
 15e:	b759                	j	e4 <main+0xe4>
                        exec(cmd, xargv);
 160:	e9040593          	addi	a1,s0,-368
 164:	96043503          	ld	a0,-1696(s0)
 168:	484000ef          	jal	5ec <exec>
                        fprintf(2, "xargs: exec failed\n");
 16c:	00001597          	auipc	a1,0x1
 170:	a7458593          	addi	a1,a1,-1420 # be0 <malloc+0x128>
 174:	4509                	li	a0,2
 176:	065000ef          	jal	9da <fprintf>
                        exit(1);
 17a:	4505                	li	a0,1
 17c:	438000ef          	jal	5b4 <exit>
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 180:	86d2                	mv	a3,s4
 182:	b78d                	j	e4 <main+0xe4>
        }

        // Shift unprocessed partial chunks back to buffer head
        int processed_bytes = last_processed - buf;
 184:	419587bb          	subw	a5,a1,s9
        if (processed_bytes > 0) {
 188:	04f04463          	bgtz	a5,1d0 <main+0x1d0>
    while ((n = read(0, buf + buf_len, sizeof(buf) - buf_len - 1)) > 0) {
 18c:	018c84b3          	add	s1,s9,s8
 190:	3ff00793          	li	a5,1023
 194:	4187863b          	subw	a2,a5,s8
 198:	85a6                	mv	a1,s1
 19a:	4501                	li	a0,0
 19c:	430000ef          	jal	5cc <read>
 1a0:	02a05f63          	blez	a0,1de <main+0x1de>
        buf_len += n;
 1a4:	00ac0bbb          	addw	s7,s8,a0
 1a8:	000b8c1b          	sext.w	s8,s7
        buf[buf_len] = '\0';
 1ac:	f90c0793          	addi	a5,s8,-112
 1b0:	97a2                	add	a5,a5,s0
 1b2:	b0078023          	sb	zero,-1280(a5)
        while (*p) {
 1b6:	a9044783          	lbu	a5,-1392(s0)
 1ba:	dbe9                	beqz	a5,18c <main+0x18c>
        char *last_processed = buf;
 1bc:	85e6                	mv	a1,s9
        char *word_start = 0;
 1be:	4681                	li	a3,0
        char *p = buf;
 1c0:	84e6                	mv	s1,s9
        int word_count = 0;
 1c2:	4701                	li	a4,0
            if (*p == ' ' || *p == '\t' || *p == '\n') {
 1c4:	02000993          	li	s3,32
                    words[word_count++] = word_start;
 1c8:	4a01                	li	s4,0
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 1ca:	4d29                	li	s10,10
            if (*p == ' ' || *p == '\t' || *p == '\n') {
 1cc:	4b05                	li	s6,1
 1ce:	bf39                	j	ec <main+0xec>
            memmove(buf, last_processed, buf_len - processed_bytes);
 1d0:	40fb8c3b          	subw	s8,s7,a5
 1d4:	8662                	mv	a2,s8
 1d6:	8566                	mv	a0,s9
 1d8:	302000ef          	jal	4da <memmove>
            buf_len -= processed_bytes;
 1dc:	bf45                	j	18c <main+0x18c>
        }
    }

    // Handle any trailing words if -n N was used and stdin ended without filling a final batch
    if (n_limit > 0 && buf_len > 0) {
 1de:	0b205f63          	blez	s2,29c <main+0x29c>
 1e2:	0b805d63          	blez	s8,29c <main+0x29c>
        char *words[MAXARG];
        int word_count = 0;
        char *p = buf;
        char *word_start = 0;
        while (p < buf + buf_len) {
 1e6:	a9040793          	addi	a5,s0,-1392
 1ea:	0a97f963          	bgeu	a5,s1,29c <main+0x29c>
        char *word_start = 0;
 1ee:	4601                	li	a2,0
        char *p = buf;
 1f0:	873e                	mv	a4,a5
        int word_count = 0;
 1f2:	4681                	li	a3,0
 1f4:	02000513          	li	a0,32
 1f8:	4585                	li	a1,1
 1fa:	1582                	slli	a1,a1,0x20
 1fc:	60158593          	addi	a1,a1,1537
            if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\0') {
                if (word_start) {
                    *p = '\0';
                    words[word_count++] = word_start;
                    word_start = 0;
 200:	4801                	li	a6,0
 202:	a029                	j	20c <main+0x20c>
                }
            } else {
                if (!word_start) word_start = p;
 204:	ca0d                	beqz	a2,236 <main+0x236>
            }
            p++;
 206:	0705                	addi	a4,a4,1
        while (p < buf + buf_len) {
 208:	02e48963          	beq	s1,a4,23a <main+0x23a>
            if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\0') {
 20c:	00074783          	lbu	a5,0(a4)
 210:	fef56ae3          	bltu	a0,a5,204 <main+0x204>
 214:	00f5d7b3          	srl	a5,a1,a5
 218:	8b85                	andi	a5,a5,1
 21a:	d7ed                	beqz	a5,204 <main+0x204>
                if (word_start) {
 21c:	d66d                	beqz	a2,206 <main+0x206>
                    *p = '\0';
 21e:	00070023          	sb	zero,0(a4)
                    words[word_count++] = word_start;
 222:	00369793          	slli	a5,a3,0x3
 226:	f9078793          	addi	a5,a5,-112
 22a:	97a2                	add	a5,a5,s0
 22c:	a0c7b023          	sd	a2,-1536(a5)
 230:	2685                	addiw	a3,a3,1
                    word_start = 0;
 232:	8642                	mv	a2,a6
 234:	bfc9                	j	206 <main+0x206>
                if (!word_start) word_start = p;
 236:	863a                	mv	a2,a4
 238:	b7f9                	j	206 <main+0x206>
        }
        if (word_count > 0) {
 23a:	06d05163          	blez	a3,29c <main+0x29c>
 23e:	99040793          	addi	a5,s0,-1648
 242:	00369613          	slli	a2,a3,0x3
 246:	963e                	add	a2,a2,a5
            int curr_argc = base_argc;
            for (int i = 0; i < word_count; i++) {
                xargv[curr_argc++] = words[i];
 248:	6398                	ld	a4,0(a5)
 24a:	97843583          	ld	a1,-1672(s0)
 24e:	e198                	sd	a4,0(a1)
            for (int i = 0; i < word_count; i++) {
 250:	07a1                	addi	a5,a5,8
 252:	00858713          	addi	a4,a1,8
 256:	96e43c23          	sd	a4,-1672(s0)
 25a:	fec797e3          	bne	a5,a2,248 <main+0x248>
            }
            xargv[curr_argc] = 0;
 25e:	96843783          	ld	a5,-1688(s0)
 262:	9fb5                	addw	a5,a5,a3
 264:	078e                	slli	a5,a5,0x3
 266:	f9078793          	addi	a5,a5,-112
 26a:	97a2                	add	a5,a5,s0
 26c:	f007b023          	sd	zero,-256(a5)
            int pid = fork();
 270:	33c000ef          	jal	5ac <fork>
            if (pid == 0) {
 274:	e911                	bnez	a0,288 <main+0x288>
                exec(cmd, xargv);
 276:	e9040593          	addi	a1,s0,-368
 27a:	96043503          	ld	a0,-1696(s0)
 27e:	36e000ef          	jal	5ec <exec>
                exit(1);
 282:	4505                	li	a0,1
 284:	330000ef          	jal	5b4 <exit>
            } else {
                int status;
                wait(&status);
 288:	98c40513          	addi	a0,s0,-1652
 28c:	330000ef          	jal	5bc <wait>
                if (status != 0) global_status = 1;
 290:	98c42783          	lw	a5,-1652(s0)
 294:	c781                	beqz	a5,29c <main+0x29c>
 296:	4785                	li	a5,1
 298:	96f43823          	sd	a5,-1680(s0)
            }
        }
    }

    exit(global_status);
 29c:	97043503          	ld	a0,-1680(s0)
 2a0:	314000ef          	jal	5b4 <exit>
    int cmd_idx = 1;
 2a4:	4685                	li	a3,1
    int n_limit = -1;
 2a6:	597d                	li	s2,-1
    char *cmd = argv[cmd_idx];
 2a8:	00369793          	slli	a5,a3,0x3
 2ac:	00f48733          	add	a4,s1,a5
 2b0:	631c                	ld	a5,0(a4)
 2b2:	96f43023          	sd	a5,-1696(s0)
    for (int i = cmd_idx; i < argc; i++) {
 2b6:	e9040793          	addi	a5,s0,-368
 2ba:	40d989bb          	subw	s3,s3,a3
 2be:	02099693          	slli	a3,s3,0x20
 2c2:	01d6d613          	srli	a2,a3,0x1d
 2c6:	963e                	add	a2,a2,a5
        xargv[base_argc++] = argv[i];
 2c8:	6314                	ld	a3,0(a4)
 2ca:	e394                	sd	a3,0(a5)
    for (int i = cmd_idx; i < argc; i++) {
 2cc:	0721                	addi	a4,a4,8
 2ce:	07a1                	addi	a5,a5,8
 2d0:	fec79ce3          	bne	a5,a2,2c8 <main+0x2c8>
 2d4:	0009879b          	sext.w	a5,s3
 2d8:	96f43423          	sd	a5,-1688(s0)
 2dc:	67413823          	sd	s4,1648(sp)
 2e0:	67513423          	sd	s5,1640(sp)
 2e4:	67613023          	sd	s6,1632(sp)
 2e8:	65713c23          	sd	s7,1624(sp)
 2ec:	65813823          	sd	s8,1616(sp)
 2f0:	65913423          	sd	s9,1608(sp)
 2f4:	65a13023          	sd	s10,1600(sp)
 2f8:	63b13c23          	sd	s11,1592(sp)
 2fc:	96843703          	ld	a4,-1688(s0)
 300:	00371793          	slli	a5,a4,0x3
 304:	e9040693          	addi	a3,s0,-368
 308:	97b6                	add	a5,a5,a3
 30a:	96f43c23          	sd	a5,-1672(s0)
    int global_status = 0;
 30e:	96043823          	sd	zero,-1680(s0)
    int n, buf_len = 0;
 312:	4c01                	li	s8,0
    while ((n = read(0, buf + buf_len, sizeof(buf) - buf_len - 1)) > 0) {
 314:	a9040c93          	addi	s9,s0,-1392
                    xargv[curr_argc] = 0;
 318:	00170d9b          	addiw	s11,a4,1
                if (n_limit == -1 && *p == '\n' && word_count > 0) {
 31c:	5afd                	li	s5,-1
 31e:	b5bd                	j	18c <main+0x18c>

0000000000000320 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 328:	cd9ff0ef          	jal	0 <main>
  exit(r);
 32c:	288000ef          	jal	5b4 <exit>

0000000000000330 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
 330:	1141                	addi	sp,sp,-16
 332:	e422                	sd	s0,8(sp)
 334:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
 336:	87aa                	mv	a5,a0
 338:	0585                	addi	a1,a1,1
 33a:	0785                	addi	a5,a5,1
 33c:	fff5c703          	lbu	a4,-1(a1)
 340:	fee78fa3          	sb	a4,-1(a5)
 344:	fb75                	bnez	a4,338 <strcpy+0x8>
    ;
  return os;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 352:	00054783          	lbu	a5,0(a0)
 356:	cb91                	beqz	a5,36a <strcmp+0x1e>
 358:	0005c703          	lbu	a4,0(a1)
 35c:	00f71763          	bne	a4,a5,36a <strcmp+0x1e>
    p++, q++;
 360:	0505                	addi	a0,a0,1
 362:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 364:	00054783          	lbu	a5,0(a0)
 368:	fbe5                	bnez	a5,358 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 36a:	0005c503          	lbu	a0,0(a1)
}
 36e:	40a7853b          	subw	a0,a5,a0
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <strlen>:

uint
strlen(const char *s)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 37e:	00054783          	lbu	a5,0(a0)
 382:	cf91                	beqz	a5,39e <strlen+0x26>
 384:	0505                	addi	a0,a0,1
 386:	87aa                	mv	a5,a0
 388:	86be                	mv	a3,a5
 38a:	0785                	addi	a5,a5,1
 38c:	fff7c703          	lbu	a4,-1(a5)
 390:	ff65                	bnez	a4,388 <strlen+0x10>
 392:	40a6853b          	subw	a0,a3,a0
 396:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  for (n = 0; s[n]; n++)
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <strlen+0x20>

00000000000003a2 <memset>:

void *
memset(void *dst, int c, uint n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 3a8:	ca19                	beqz	a2,3be <memset+0x1c>
 3aa:	87aa                	mv	a5,a0
 3ac:	1602                	slli	a2,a2,0x20
 3ae:	9201                	srli	a2,a2,0x20
 3b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3b4:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 3b8:	0785                	addi	a5,a5,1
 3ba:	fee79de3          	bne	a5,a4,3b4 <memset+0x12>
  }
  return dst;
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <strchr>:

char *
strchr(const char *s, char c)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e422                	sd	s0,8(sp)
 3c8:	0800                	addi	s0,sp,16
  for (; *s; s++)
 3ca:	00054783          	lbu	a5,0(a0)
 3ce:	cb99                	beqz	a5,3e4 <strchr+0x20>
    if (*s == c)
 3d0:	00f58763          	beq	a1,a5,3de <strchr+0x1a>
  for (; *s; s++)
 3d4:	0505                	addi	a0,a0,1
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	fbfd                	bnez	a5,3d0 <strchr+0xc>
      return (char *)s;
  return 0;
 3dc:	4501                	li	a0,0
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	bfe5                	j	3de <strchr+0x1a>

00000000000003e8 <gets>:

char *
gets(char *buf, int max)
{
 3e8:	711d                	addi	sp,sp,-96
 3ea:	ec86                	sd	ra,88(sp)
 3ec:	e8a2                	sd	s0,80(sp)
 3ee:	e4a6                	sd	s1,72(sp)
 3f0:	e0ca                	sd	s2,64(sp)
 3f2:	fc4e                	sd	s3,56(sp)
 3f4:	f852                	sd	s4,48(sp)
 3f6:	f456                	sd	s5,40(sp)
 3f8:	f05a                	sd	s6,32(sp)
 3fa:	ec5e                	sd	s7,24(sp)
 3fc:	1080                	addi	s0,sp,96
 3fe:	8baa                	mv	s7,a0
 400:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 402:	892a                	mv	s2,a0
 404:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 406:	4aa9                	li	s5,10
 408:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 40a:	89a6                	mv	s3,s1
 40c:	2485                	addiw	s1,s1,1
 40e:	0344d663          	bge	s1,s4,43a <gets+0x52>
    cc = read(0, &c, 1);
 412:	4605                	li	a2,1
 414:	faf40593          	addi	a1,s0,-81
 418:	4501                	li	a0,0
 41a:	1b2000ef          	jal	5cc <read>
    if (cc < 1)
 41e:	00a05e63          	blez	a0,43a <gets+0x52>
    buf[i++] = c;
 422:	faf44783          	lbu	a5,-81(s0)
 426:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 42a:	01578763          	beq	a5,s5,438 <gets+0x50>
 42e:	0905                	addi	s2,s2,1
 430:	fd679de3          	bne	a5,s6,40a <gets+0x22>
    buf[i++] = c;
 434:	89a6                	mv	s3,s1
 436:	a011                	j	43a <gets+0x52>
 438:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 43a:	99de                	add	s3,s3,s7
 43c:	00098023          	sb	zero,0(s3)
  return buf;
}
 440:	855e                	mv	a0,s7
 442:	60e6                	ld	ra,88(sp)
 444:	6446                	ld	s0,80(sp)
 446:	64a6                	ld	s1,72(sp)
 448:	6906                	ld	s2,64(sp)
 44a:	79e2                	ld	s3,56(sp)
 44c:	7a42                	ld	s4,48(sp)
 44e:	7aa2                	ld	s5,40(sp)
 450:	7b02                	ld	s6,32(sp)
 452:	6be2                	ld	s7,24(sp)
 454:	6125                	addi	sp,sp,96
 456:	8082                	ret

0000000000000458 <stat>:

int
stat(const char *n, struct stat *st)
{
 458:	1101                	addi	sp,sp,-32
 45a:	ec06                	sd	ra,24(sp)
 45c:	e822                	sd	s0,16(sp)
 45e:	e04a                	sd	s2,0(sp)
 460:	1000                	addi	s0,sp,32
 462:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 464:	4581                	li	a1,0
 466:	18e000ef          	jal	5f4 <open>
  if (fd < 0)
 46a:	02054263          	bltz	a0,48e <stat+0x36>
 46e:	e426                	sd	s1,8(sp)
 470:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 472:	85ca                	mv	a1,s2
 474:	198000ef          	jal	60c <fstat>
 478:	892a                	mv	s2,a0
  close(fd);
 47a:	8526                	mv	a0,s1
 47c:	160000ef          	jal	5dc <close>
  return r;
 480:	64a2                	ld	s1,8(sp)
}
 482:	854a                	mv	a0,s2
 484:	60e2                	ld	ra,24(sp)
 486:	6442                	ld	s0,16(sp)
 488:	6902                	ld	s2,0(sp)
 48a:	6105                	addi	sp,sp,32
 48c:	8082                	ret
    return -1;
 48e:	597d                	li	s2,-1
 490:	bfcd                	j	482 <stat+0x2a>

0000000000000492 <atoi>:

int
atoi(const char *s)
{
 492:	1141                	addi	sp,sp,-16
 494:	e422                	sd	s0,8(sp)
 496:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 498:	00054683          	lbu	a3,0(a0)
 49c:	fd06879b          	addiw	a5,a3,-48
 4a0:	0ff7f793          	zext.b	a5,a5
 4a4:	4625                	li	a2,9
 4a6:	02f66863          	bltu	a2,a5,4d6 <atoi+0x44>
 4aa:	872a                	mv	a4,a0
  n = 0;
 4ac:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 4ae:	0705                	addi	a4,a4,1
 4b0:	0025179b          	slliw	a5,a0,0x2
 4b4:	9fa9                	addw	a5,a5,a0
 4b6:	0017979b          	slliw	a5,a5,0x1
 4ba:	9fb5                	addw	a5,a5,a3
 4bc:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 4c0:	00074683          	lbu	a3,0(a4)
 4c4:	fd06879b          	addiw	a5,a3,-48
 4c8:	0ff7f793          	zext.b	a5,a5
 4cc:	fef671e3          	bgeu	a2,a5,4ae <atoi+0x1c>
  return n;
}
 4d0:	6422                	ld	s0,8(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret
  n = 0;
 4d6:	4501                	li	a0,0
 4d8:	bfe5                	j	4d0 <atoi+0x3e>

00000000000004da <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e422                	sd	s0,8(sp)
 4de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4e0:	02b57463          	bgeu	a0,a1,508 <memmove+0x2e>
    while (n-- > 0)
 4e4:	00c05f63          	blez	a2,502 <memmove+0x28>
 4e8:	1602                	slli	a2,a2,0x20
 4ea:	9201                	srli	a2,a2,0x20
 4ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 4f2:	0585                	addi	a1,a1,1
 4f4:	0705                	addi	a4,a4,1
 4f6:	fff5c683          	lbu	a3,-1(a1)
 4fa:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 4fe:	fef71ae3          	bne	a4,a5,4f2 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret
    dst += n;
 508:	00c50733          	add	a4,a0,a2
    src += n;
 50c:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 50e:	fec05ae3          	blez	a2,502 <memmove+0x28>
 512:	fff6079b          	addiw	a5,a2,-1
 516:	1782                	slli	a5,a5,0x20
 518:	9381                	srli	a5,a5,0x20
 51a:	fff7c793          	not	a5,a5
 51e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 520:	15fd                	addi	a1,a1,-1
 522:	177d                	addi	a4,a4,-1
 524:	0005c683          	lbu	a3,0(a1)
 528:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 52c:	fee79ae3          	bne	a5,a4,520 <memmove+0x46>
 530:	bfc9                	j	502 <memmove+0x28>

0000000000000532 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 538:	ca05                	beqz	a2,568 <memcmp+0x36>
 53a:	fff6069b          	addiw	a3,a2,-1
 53e:	1682                	slli	a3,a3,0x20
 540:	9281                	srli	a3,a3,0x20
 542:	0685                	addi	a3,a3,1
 544:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 546:	00054783          	lbu	a5,0(a0)
 54a:	0005c703          	lbu	a4,0(a1)
 54e:	00e79863          	bne	a5,a4,55e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 552:	0505                	addi	a0,a0,1
    p2++;
 554:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 556:	fed518e3          	bne	a0,a3,546 <memcmp+0x14>
  }
  return 0;
 55a:	4501                	li	a0,0
 55c:	a019                	j	562 <memcmp+0x30>
      return *p1 - *p2;
 55e:	40e7853b          	subw	a0,a5,a4
}
 562:	6422                	ld	s0,8(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret
  return 0;
 568:	4501                	li	a0,0
 56a:	bfe5                	j	562 <memcmp+0x30>

000000000000056c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 56c:	1141                	addi	sp,sp,-16
 56e:	e406                	sd	ra,8(sp)
 570:	e022                	sd	s0,0(sp)
 572:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 574:	f67ff0ef          	jal	4da <memmove>
}
 578:	60a2                	ld	ra,8(sp)
 57a:	6402                	ld	s0,0(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret

0000000000000580 <sbrk>:

char *
sbrk(int n)
{
 580:	1141                	addi	sp,sp,-16
 582:	e406                	sd	ra,8(sp)
 584:	e022                	sd	s0,0(sp)
 586:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 588:	4585                	li	a1,1
 58a:	0b2000ef          	jal	63c <sys_sbrk>
}
 58e:	60a2                	ld	ra,8(sp)
 590:	6402                	ld	s0,0(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret

0000000000000596 <sbrklazy>:

char *
sbrklazy(int n)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 59e:	4589                	li	a1,2
 5a0:	09c000ef          	jal	63c <sys_sbrk>
}
 5a4:	60a2                	ld	ra,8(sp)
 5a6:	6402                	ld	s0,0(sp)
 5a8:	0141                	addi	sp,sp,16
 5aa:	8082                	ret

00000000000005ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ac:	4885                	li	a7,1
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b4:	4889                	li	a7,2
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 5bc:	488d                	li	a7,3
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c4:	4891                	li	a7,4
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <read>:
.global read
read:
 li a7, SYS_read
 5cc:	4895                	li	a7,5
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <write>:
.global write
write:
 li a7, SYS_write
 5d4:	48c1                	li	a7,16
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <close>:
.global close
close:
 li a7, SYS_close
 5dc:	48d5                	li	a7,21
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e4:	4899                	li	a7,6
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ec:	489d                	li	a7,7
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <open>:
.global open
open:
 li a7, SYS_open
 5f4:	48bd                	li	a7,15
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5fc:	48c5                	li	a7,17
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 604:	48c9                	li	a7,18
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 60c:	48a1                	li	a7,8
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <link>:
.global link
link:
 li a7, SYS_link
 614:	48cd                	li	a7,19
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 61c:	48d1                	li	a7,20
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 624:	48a5                	li	a7,9
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <dup>:
.global dup
dup:
 li a7, SYS_dup
 62c:	48a9                	li	a7,10
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 634:	48ad                	li	a7,11
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 63c:	48b1                	li	a7,12
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <pause>:
.global pause
pause:
 li a7, SYS_pause
 644:	48b5                	li	a7,13
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 64c:	48b9                	li	a7,14
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <sync>:
.global sync
sync:
 li a7, SYS_sync
 654:	48d9                	li	a7,22
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 65c:	48dd                	li	a7,23
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <trace>:
.global trace
trace:
 li a7, SYS_trace
 664:	48e1                	li	a7,24
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 66c:	48e5                	li	a7,25
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 674:	48e9                	li	a7,26
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 67c:	1101                	addi	sp,sp,-32
 67e:	ec06                	sd	ra,24(sp)
 680:	e822                	sd	s0,16(sp)
 682:	1000                	addi	s0,sp,32
 684:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 688:	4605                	li	a2,1
 68a:	fef40593          	addi	a1,s0,-17
 68e:	f47ff0ef          	jal	5d4 <write>
}
 692:	60e2                	ld	ra,24(sp)
 694:	6442                	ld	s0,16(sp)
 696:	6105                	addi	sp,sp,32
 698:	8082                	ret

000000000000069a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 69a:	715d                	addi	sp,sp,-80
 69c:	e486                	sd	ra,72(sp)
 69e:	e0a2                	sd	s0,64(sp)
 6a0:	f84a                	sd	s2,48(sp)
 6a2:	0880                	addi	s0,sp,80
 6a4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 6a6:	c299                	beqz	a3,6ac <printint+0x12>
 6a8:	0805c363          	bltz	a1,72e <printint+0x94>
  neg = 0;
 6ac:	4881                	li	a7,0
 6ae:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6b2:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 6b4:	00000517          	auipc	a0,0x0
 6b8:	54c50513          	addi	a0,a0,1356 # c00 <digits>
 6bc:	883e                	mv	a6,a5
 6be:	2785                	addiw	a5,a5,1
 6c0:	02c5f733          	remu	a4,a1,a2
 6c4:	972a                	add	a4,a4,a0
 6c6:	00074703          	lbu	a4,0(a4)
 6ca:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 6ce:	872e                	mv	a4,a1
 6d0:	02c5d5b3          	divu	a1,a1,a2
 6d4:	0685                	addi	a3,a3,1
 6d6:	fec773e3          	bgeu	a4,a2,6bc <printint+0x22>
  if (neg)
 6da:	00088b63          	beqz	a7,6f0 <printint+0x56>
    buf[i++] = '-';
 6de:	fd078793          	addi	a5,a5,-48
 6e2:	97a2                	add	a5,a5,s0
 6e4:	02d00713          	li	a4,45
 6e8:	fee78423          	sb	a4,-24(a5)
 6ec:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 6f0:	02f05a63          	blez	a5,724 <printint+0x8a>
 6f4:	fc26                	sd	s1,56(sp)
 6f6:	f44e                	sd	s3,40(sp)
 6f8:	fb840713          	addi	a4,s0,-72
 6fc:	00f704b3          	add	s1,a4,a5
 700:	fff70993          	addi	s3,a4,-1
 704:	99be                	add	s3,s3,a5
 706:	37fd                	addiw	a5,a5,-1
 708:	1782                	slli	a5,a5,0x20
 70a:	9381                	srli	a5,a5,0x20
 70c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 710:	fff4c583          	lbu	a1,-1(s1)
 714:	854a                	mv	a0,s2
 716:	f67ff0ef          	jal	67c <putc>
  while (--i >= 0)
 71a:	14fd                	addi	s1,s1,-1
 71c:	ff349ae3          	bne	s1,s3,710 <printint+0x76>
 720:	74e2                	ld	s1,56(sp)
 722:	79a2                	ld	s3,40(sp)
}
 724:	60a6                	ld	ra,72(sp)
 726:	6406                	ld	s0,64(sp)
 728:	7942                	ld	s2,48(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret
    x = -xx;
 72e:	40b005b3          	neg	a1,a1
    neg = 1;
 732:	4885                	li	a7,1
    x = -xx;
 734:	bfad                	j	6ae <printint+0x14>

0000000000000736 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 736:	711d                	addi	sp,sp,-96
 738:	ec86                	sd	ra,88(sp)
 73a:	e8a2                	sd	s0,80(sp)
 73c:	e0ca                	sd	s2,64(sp)
 73e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 740:	0005c903          	lbu	s2,0(a1)
 744:	28090663          	beqz	s2,9d0 <vprintf+0x29a>
 748:	e4a6                	sd	s1,72(sp)
 74a:	fc4e                	sd	s3,56(sp)
 74c:	f852                	sd	s4,48(sp)
 74e:	f456                	sd	s5,40(sp)
 750:	f05a                	sd	s6,32(sp)
 752:	ec5e                	sd	s7,24(sp)
 754:	e862                	sd	s8,16(sp)
 756:	e466                	sd	s9,8(sp)
 758:	8b2a                	mv	s6,a0
 75a:	8a2e                	mv	s4,a1
 75c:	8bb2                	mv	s7,a2
  state = 0;
 75e:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 760:	4481                	li	s1,0
 762:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 764:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 768:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 76c:	06c00c93          	li	s9,108
 770:	a005                	j	790 <vprintf+0x5a>
        putc(fd, c0);
 772:	85ca                	mv	a1,s2
 774:	855a                	mv	a0,s6
 776:	f07ff0ef          	jal	67c <putc>
 77a:	a019                	j	780 <vprintf+0x4a>
    } else if (state == '%') {
 77c:	03598263          	beq	s3,s5,7a0 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 780:	2485                	addiw	s1,s1,1
 782:	8726                	mv	a4,s1
 784:	009a07b3          	add	a5,s4,s1
 788:	0007c903          	lbu	s2,0(a5)
 78c:	22090a63          	beqz	s2,9c0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 790:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 794:	fe0994e3          	bnez	s3,77c <vprintf+0x46>
      if (c0 == '%') {
 798:	fd579de3          	bne	a5,s5,772 <vprintf+0x3c>
        state = '%';
 79c:	89be                	mv	s3,a5
 79e:	b7cd                	j	780 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 7a0:	00ea06b3          	add	a3,s4,a4
 7a4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7a8:	8636                	mv	a2,a3
      if (c1)
 7aa:	c681                	beqz	a3,7b2 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 7ac:	9752                	add	a4,a4,s4
 7ae:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 7b2:	05878363          	beq	a5,s8,7f8 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 7b6:	05978d63          	beq	a5,s9,810 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 7ba:	07500713          	li	a4,117
 7be:	0ee78763          	beq	a5,a4,8ac <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 7c2:	07800713          	li	a4,120
 7c6:	12e78963          	beq	a5,a4,8f8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 7ca:	07000713          	li	a4,112
 7ce:	14e78e63          	beq	a5,a4,92a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 7d2:	06300713          	li	a4,99
 7d6:	18e78e63          	beq	a5,a4,972 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 7da:	07300713          	li	a4,115
 7de:	1ae78463          	beq	a5,a4,986 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 7e2:	02500713          	li	a4,37
 7e6:	04e79563          	bne	a5,a4,830 <vprintf+0xfa>
        putc(fd, '%');
 7ea:	02500593          	li	a1,37
 7ee:	855a                	mv	a0,s6
 7f0:	e8dff0ef          	jal	67c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	b769                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7f8:	008b8913          	addi	s2,s7,8
 7fc:	4685                	li	a3,1
 7fe:	4629                	li	a2,10
 800:	000ba583          	lw	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	e95ff0ef          	jal	69a <printint>
 80a:	8bca                	mv	s7,s2
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bf8d                	j	780 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 810:	06400793          	li	a5,100
 814:	02f68963          	beq	a3,a5,846 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 818:	06c00793          	li	a5,108
 81c:	04f68263          	beq	a3,a5,860 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 820:	07500793          	li	a5,117
 824:	0af68063          	beq	a3,a5,8c4 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 828:	07800793          	li	a5,120
 82c:	0ef68263          	beq	a3,a5,910 <vprintf+0x1da>
        putc(fd, '%');
 830:	02500593          	li	a1,37
 834:	855a                	mv	a0,s6
 836:	e47ff0ef          	jal	67c <putc>
        putc(fd, c0);
 83a:	85ca                	mv	a1,s2
 83c:	855a                	mv	a0,s6
 83e:	e3fff0ef          	jal	67c <putc>
      state = 0;
 842:	4981                	li	s3,0
 844:	bf35                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 846:	008b8913          	addi	s2,s7,8
 84a:	4685                	li	a3,1
 84c:	4629                	li	a2,10
 84e:	000bb583          	ld	a1,0(s7)
 852:	855a                	mv	a0,s6
 854:	e47ff0ef          	jal	69a <printint>
        i += 1;
 858:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 85a:	8bca                	mv	s7,s2
      state = 0;
 85c:	4981                	li	s3,0
        i += 1;
 85e:	b70d                	j	780 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 860:	06400793          	li	a5,100
 864:	02f60763          	beq	a2,a5,892 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 868:	07500793          	li	a5,117
 86c:	06f60963          	beq	a2,a5,8de <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 870:	07800793          	li	a5,120
 874:	faf61ee3          	bne	a2,a5,830 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 878:	008b8913          	addi	s2,s7,8
 87c:	4681                	li	a3,0
 87e:	4641                	li	a2,16
 880:	000bb583          	ld	a1,0(s7)
 884:	855a                	mv	a0,s6
 886:	e15ff0ef          	jal	69a <printint>
        i += 2;
 88a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 88c:	8bca                	mv	s7,s2
      state = 0;
 88e:	4981                	li	s3,0
        i += 2;
 890:	bdc5                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 892:	008b8913          	addi	s2,s7,8
 896:	4685                	li	a3,1
 898:	4629                	li	a2,10
 89a:	000bb583          	ld	a1,0(s7)
 89e:	855a                	mv	a0,s6
 8a0:	dfbff0ef          	jal	69a <printint>
        i += 2;
 8a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8a6:	8bca                	mv	s7,s2
      state = 0;
 8a8:	4981                	li	s3,0
        i += 2;
 8aa:	bdd9                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8ac:	008b8913          	addi	s2,s7,8
 8b0:	4681                	li	a3,0
 8b2:	4629                	li	a2,10
 8b4:	000be583          	lwu	a1,0(s7)
 8b8:	855a                	mv	a0,s6
 8ba:	de1ff0ef          	jal	69a <printint>
 8be:	8bca                	mv	s7,s2
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bd7d                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8c4:	008b8913          	addi	s2,s7,8
 8c8:	4681                	li	a3,0
 8ca:	4629                	li	a2,10
 8cc:	000bb583          	ld	a1,0(s7)
 8d0:	855a                	mv	a0,s6
 8d2:	dc9ff0ef          	jal	69a <printint>
        i += 1;
 8d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d8:	8bca                	mv	s7,s2
      state = 0;
 8da:	4981                	li	s3,0
        i += 1;
 8dc:	b555                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8de:	008b8913          	addi	s2,s7,8
 8e2:	4681                	li	a3,0
 8e4:	4629                	li	a2,10
 8e6:	000bb583          	ld	a1,0(s7)
 8ea:	855a                	mv	a0,s6
 8ec:	dafff0ef          	jal	69a <printint>
        i += 2;
 8f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8f2:	8bca                	mv	s7,s2
      state = 0;
 8f4:	4981                	li	s3,0
        i += 2;
 8f6:	b569                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8f8:	008b8913          	addi	s2,s7,8
 8fc:	4681                	li	a3,0
 8fe:	4641                	li	a2,16
 900:	000be583          	lwu	a1,0(s7)
 904:	855a                	mv	a0,s6
 906:	d95ff0ef          	jal	69a <printint>
 90a:	8bca                	mv	s7,s2
      state = 0;
 90c:	4981                	li	s3,0
 90e:	bd8d                	j	780 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 910:	008b8913          	addi	s2,s7,8
 914:	4681                	li	a3,0
 916:	4641                	li	a2,16
 918:	000bb583          	ld	a1,0(s7)
 91c:	855a                	mv	a0,s6
 91e:	d7dff0ef          	jal	69a <printint>
        i += 1;
 922:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 924:	8bca                	mv	s7,s2
      state = 0;
 926:	4981                	li	s3,0
        i += 1;
 928:	bda1                	j	780 <vprintf+0x4a>
 92a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 92c:	008b8d13          	addi	s10,s7,8
 930:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 934:	03000593          	li	a1,48
 938:	855a                	mv	a0,s6
 93a:	d43ff0ef          	jal	67c <putc>
  putc(fd, 'x');
 93e:	07800593          	li	a1,120
 942:	855a                	mv	a0,s6
 944:	d39ff0ef          	jal	67c <putc>
 948:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 94a:	00000b97          	auipc	s7,0x0
 94e:	2b6b8b93          	addi	s7,s7,694 # c00 <digits>
 952:	03c9d793          	srli	a5,s3,0x3c
 956:	97de                	add	a5,a5,s7
 958:	0007c583          	lbu	a1,0(a5)
 95c:	855a                	mv	a0,s6
 95e:	d1fff0ef          	jal	67c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 962:	0992                	slli	s3,s3,0x4
 964:	397d                	addiw	s2,s2,-1
 966:	fe0916e3          	bnez	s2,952 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 96a:	8bea                	mv	s7,s10
      state = 0;
 96c:	4981                	li	s3,0
 96e:	6d02                	ld	s10,0(sp)
 970:	bd01                	j	780 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 972:	008b8913          	addi	s2,s7,8
 976:	000bc583          	lbu	a1,0(s7)
 97a:	855a                	mv	a0,s6
 97c:	d01ff0ef          	jal	67c <putc>
 980:	8bca                	mv	s7,s2
      state = 0;
 982:	4981                	li	s3,0
 984:	bbf5                	j	780 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 986:	008b8993          	addi	s3,s7,8
 98a:	000bb903          	ld	s2,0(s7)
 98e:	00090f63          	beqz	s2,9ac <vprintf+0x276>
        for (; *s; s++)
 992:	00094583          	lbu	a1,0(s2)
 996:	c195                	beqz	a1,9ba <vprintf+0x284>
          putc(fd, *s);
 998:	855a                	mv	a0,s6
 99a:	ce3ff0ef          	jal	67c <putc>
        for (; *s; s++)
 99e:	0905                	addi	s2,s2,1
 9a0:	00094583          	lbu	a1,0(s2)
 9a4:	f9f5                	bnez	a1,998 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 9a6:	8bce                	mv	s7,s3
      state = 0;
 9a8:	4981                	li	s3,0
 9aa:	bbd9                	j	780 <vprintf+0x4a>
          s = "(null)";
 9ac:	00000917          	auipc	s2,0x0
 9b0:	24c90913          	addi	s2,s2,588 # bf8 <malloc+0x140>
        for (; *s; s++)
 9b4:	02800593          	li	a1,40
 9b8:	b7c5                	j	998 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 9ba:	8bce                	mv	s7,s3
      state = 0;
 9bc:	4981                	li	s3,0
 9be:	b3c9                	j	780 <vprintf+0x4a>
 9c0:	64a6                	ld	s1,72(sp)
 9c2:	79e2                	ld	s3,56(sp)
 9c4:	7a42                	ld	s4,48(sp)
 9c6:	7aa2                	ld	s5,40(sp)
 9c8:	7b02                	ld	s6,32(sp)
 9ca:	6be2                	ld	s7,24(sp)
 9cc:	6c42                	ld	s8,16(sp)
 9ce:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9d0:	60e6                	ld	ra,88(sp)
 9d2:	6446                	ld	s0,80(sp)
 9d4:	6906                	ld	s2,64(sp)
 9d6:	6125                	addi	sp,sp,96
 9d8:	8082                	ret

00000000000009da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9da:	715d                	addi	sp,sp,-80
 9dc:	ec06                	sd	ra,24(sp)
 9de:	e822                	sd	s0,16(sp)
 9e0:	1000                	addi	s0,sp,32
 9e2:	e010                	sd	a2,0(s0)
 9e4:	e414                	sd	a3,8(s0)
 9e6:	e818                	sd	a4,16(s0)
 9e8:	ec1c                	sd	a5,24(s0)
 9ea:	03043023          	sd	a6,32(s0)
 9ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9f6:	8622                	mv	a2,s0
 9f8:	d3fff0ef          	jal	736 <vprintf>
}
 9fc:	60e2                	ld	ra,24(sp)
 9fe:	6442                	ld	s0,16(sp)
 a00:	6161                	addi	sp,sp,80
 a02:	8082                	ret

0000000000000a04 <printf>:

void
printf(const char *fmt, ...)
{
 a04:	711d                	addi	sp,sp,-96
 a06:	ec06                	sd	ra,24(sp)
 a08:	e822                	sd	s0,16(sp)
 a0a:	1000                	addi	s0,sp,32
 a0c:	e40c                	sd	a1,8(s0)
 a0e:	e810                	sd	a2,16(s0)
 a10:	ec14                	sd	a3,24(s0)
 a12:	f018                	sd	a4,32(s0)
 a14:	f41c                	sd	a5,40(s0)
 a16:	03043823          	sd	a6,48(s0)
 a1a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a1e:	00840613          	addi	a2,s0,8
 a22:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a26:	85aa                	mv	a1,a0
 a28:	4505                	li	a0,1
 a2a:	d0dff0ef          	jal	736 <vprintf>
}
 a2e:	60e2                	ld	ra,24(sp)
 a30:	6442                	ld	s0,16(sp)
 a32:	6125                	addi	sp,sp,96
 a34:	8082                	ret

0000000000000a36 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a36:	1141                	addi	sp,sp,-16
 a38:	e422                	sd	s0,8(sp)
 a3a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 a3c:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a40:	00001797          	auipc	a5,0x1
 a44:	5c07b783          	ld	a5,1472(a5) # 2000 <freep>
 a48:	a02d                	j	a72 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 a4a:	4618                	lw	a4,8(a2)
 a4c:	9f2d                	addw	a4,a4,a1
 a4e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a52:	6398                	ld	a4,0(a5)
 a54:	6310                	ld	a2,0(a4)
 a56:	a83d                	j	a94 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 a58:	ff852703          	lw	a4,-8(a0)
 a5c:	9f31                	addw	a4,a4,a2
 a5e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a60:	ff053683          	ld	a3,-16(a0)
 a64:	a091                	j	aa8 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a66:	6398                	ld	a4,0(a5)
 a68:	00e7e463          	bltu	a5,a4,a70 <free+0x3a>
 a6c:	00e6ea63          	bltu	a3,a4,a80 <free+0x4a>
{
 a70:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a72:	fed7fae3          	bgeu	a5,a3,a66 <free+0x30>
 a76:	6398                	ld	a4,0(a5)
 a78:	00e6e463          	bltu	a3,a4,a80 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a7c:	fee7eae3          	bltu	a5,a4,a70 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 a80:	ff852583          	lw	a1,-8(a0)
 a84:	6390                	ld	a2,0(a5)
 a86:	02059813          	slli	a6,a1,0x20
 a8a:	01c85713          	srli	a4,a6,0x1c
 a8e:	9736                	add	a4,a4,a3
 a90:	fae60de3          	beq	a2,a4,a4a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a94:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 a98:	4790                	lw	a2,8(a5)
 a9a:	02061593          	slli	a1,a2,0x20
 a9e:	01c5d713          	srli	a4,a1,0x1c
 aa2:	973e                	add	a4,a4,a5
 aa4:	fae68ae3          	beq	a3,a4,a58 <free+0x22>
    p->s.ptr = bp->s.ptr;
 aa8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 aaa:	00001717          	auipc	a4,0x1
 aae:	54f73b23          	sd	a5,1366(a4) # 2000 <freep>
}
 ab2:	6422                	ld	s0,8(sp)
 ab4:	0141                	addi	sp,sp,16
 ab6:	8082                	ret

0000000000000ab8 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 ab8:	7139                	addi	sp,sp,-64
 aba:	fc06                	sd	ra,56(sp)
 abc:	f822                	sd	s0,48(sp)
 abe:	f426                	sd	s1,40(sp)
 ac0:	ec4e                	sd	s3,24(sp)
 ac2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 ac4:	02051493          	slli	s1,a0,0x20
 ac8:	9081                	srli	s1,s1,0x20
 aca:	04bd                	addi	s1,s1,15
 acc:	8091                	srli	s1,s1,0x4
 ace:	0014899b          	addiw	s3,s1,1
 ad2:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 ad4:	00001517          	auipc	a0,0x1
 ad8:	52c53503          	ld	a0,1324(a0) # 2000 <freep>
 adc:	c915                	beqz	a0,b10 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 ade:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 ae0:	4798                	lw	a4,8(a5)
 ae2:	08977a63          	bgeu	a4,s1,b76 <malloc+0xbe>
 ae6:	f04a                	sd	s2,32(sp)
 ae8:	e852                	sd	s4,16(sp)
 aea:	e456                	sd	s5,8(sp)
 aec:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 aee:	8a4e                	mv	s4,s3
 af0:	0009871b          	sext.w	a4,s3
 af4:	6685                	lui	a3,0x1
 af6:	00d77363          	bgeu	a4,a3,afc <malloc+0x44>
 afa:	6a05                	lui	s4,0x1
 afc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b00:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 b04:	00001917          	auipc	s2,0x1
 b08:	4fc90913          	addi	s2,s2,1276 # 2000 <freep>
  if (p == SBRK_ERROR)
 b0c:	5afd                	li	s5,-1
 b0e:	a081                	j	b4e <malloc+0x96>
 b10:	f04a                	sd	s2,32(sp)
 b12:	e852                	sd	s4,16(sp)
 b14:	e456                	sd	s5,8(sp)
 b16:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b18:	00001797          	auipc	a5,0x1
 b1c:	4f878793          	addi	a5,a5,1272 # 2010 <base>
 b20:	00001717          	auipc	a4,0x1
 b24:	4ef73023          	sd	a5,1248(a4) # 2000 <freep>
 b28:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b2a:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 b2e:	b7c1                	j	aee <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b30:	6398                	ld	a4,0(a5)
 b32:	e118                	sd	a4,0(a0)
 b34:	a8a9                	j	b8e <malloc+0xd6>
  hp->s.size = nu;
 b36:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 b3a:	0541                	addi	a0,a0,16
 b3c:	efbff0ef          	jal	a36 <free>
  return freep;
 b40:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 b44:	c12d                	beqz	a0,ba6 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 b46:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 b48:	4798                	lw	a4,8(a5)
 b4a:	02977263          	bgeu	a4,s1,b6e <malloc+0xb6>
    if (p == freep)
 b4e:	00093703          	ld	a4,0(s2)
 b52:	853e                	mv	a0,a5
 b54:	fef719e3          	bne	a4,a5,b46 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b58:	8552                	mv	a0,s4
 b5a:	a27ff0ef          	jal	580 <sbrk>
  if (p == SBRK_ERROR)
 b5e:	fd551ce3          	bne	a0,s5,b36 <malloc+0x7e>
        return 0;
 b62:	4501                	li	a0,0
 b64:	7902                	ld	s2,32(sp)
 b66:	6a42                	ld	s4,16(sp)
 b68:	6aa2                	ld	s5,8(sp)
 b6a:	6b02                	ld	s6,0(sp)
 b6c:	a03d                	j	b9a <malloc+0xe2>
 b6e:	7902                	ld	s2,32(sp)
 b70:	6a42                	ld	s4,16(sp)
 b72:	6aa2                	ld	s5,8(sp)
 b74:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 b76:	fae48de3          	beq	s1,a4,b30 <malloc+0x78>
        p->s.size -= nunits;
 b7a:	4137073b          	subw	a4,a4,s3
 b7e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b80:	02071693          	slli	a3,a4,0x20
 b84:	01c6d713          	srli	a4,a3,0x1c
 b88:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b8a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b8e:	00001717          	auipc	a4,0x1
 b92:	46a73923          	sd	a0,1138(a4) # 2000 <freep>
      return (void *)(p + 1);
 b96:	01078513          	addi	a0,a5,16
  }
}
 b9a:	70e2                	ld	ra,56(sp)
 b9c:	7442                	ld	s0,48(sp)
 b9e:	74a2                	ld	s1,40(sp)
 ba0:	69e2                	ld	s3,24(sp)
 ba2:	6121                	addi	sp,sp,64
 ba4:	8082                	ret
 ba6:	7902                	ld	s2,32(sp)
 ba8:	6a42                	ld	s4,16(sp)
 baa:	6aa2                	ld	s5,8(sp)
 bac:	6b02                	ld	s6,0(sp)
 bae:	b7f5                	j	b9a <malloc+0xe2>
