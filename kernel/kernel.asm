
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	71813103          	ld	sp,1816(sp) # 8000b718 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	03e000ef          	jal	80000054 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd976f>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	dbc78793          	addi	a5,a5,-580 # 80000e30 <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	24c020ef          	jal	80002360 <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	00013517          	auipc	a0,0x13
    80000192:	5d250513          	addi	a0,a0,1490 # 80013760 <cons>
    80000196:	23d000ef          	jal	80000bd2 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	00013497          	auipc	s1,0x13
    8000019e:	5c648493          	addi	s1,s1,1478 # 80013760 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	00013917          	auipc	s2,0x13
    800001a6:	65690913          	addi	s2,s2,1622 # 800137f8 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	72a010ef          	jal	800018e4 <myproc>
    800001be:	01c020ef          	jal	800021da <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	5bb010ef          	jal	80001f80 <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	293000ef          	jal	80000c5e <release>
      sleep();
    800001d0:	5ed010ef          	jal	80001fbc <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	1fd000ef          	jal	80000bd2 <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	57870713          	addi	a4,a4,1400 # 80013760 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	0fa020ef          	jal	80002314 <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	00013517          	auipc	a0,0x13
    80000236:	52e50513          	addi	a0,a0,1326 # 80013760 <cons>
    8000023a:	225000ef          	jal	80000c5e <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	00013717          	auipc	a4,0x13
    80000260:	58f72e23          	sw	a5,1436(a4) # 800137f8 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	00013517          	auipc	a0,0x13
    80000276:	4ee50513          	addi	a0,a0,1262 # 80013760 <cons>
    8000027a:	1e5000ef          	jal	80000c5e <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00013517          	auipc	a0,0x13
    800002ca:	49a50513          	addi	a0,a0,1178 # 80013760 <cons>
    800002ce:	105000ef          	jal	80000bd2 <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	0c4020ef          	jal	800023ac <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	00013517          	auipc	a0,0x13
    800002f0:	47450513          	addi	a0,a0,1140 # 80013760 <cons>
    800002f4:	16b000ef          	jal	80000c5e <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	00013717          	auipc	a4,0x13
    8000030e:	45670713          	addi	a4,a4,1110 # 80013760 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	00013797          	auipc	a5,0x13
    80000334:	43078793          	addi	a5,a5,1072 # 80013760 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	00013797          	auipc	a5,0x13
    80000362:	49a7a783          	lw	a5,1178(a5) # 800137f8 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	00013717          	auipc	a4,0x13
    80000378:	3ec70713          	addi	a4,a4,1004 # 80013760 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	00013497          	auipc	s1,0x13
    80000388:	3dc48493          	addi	s1,s1,988 # 80013760 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	00013717          	auipc	a4,0x13
    800003ca:	39a70713          	addi	a4,a4,922 # 80013760 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00013717          	auipc	a4,0x13
    800003e0:	42f72223          	sw	a5,1060(a4) # 80013800 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	00013797          	auipc	a5,0x13
    800003fe:	36678793          	addi	a5,a5,870 # 80013760 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	00013797          	auipc	a5,0x13
    80000422:	3cc7af23          	sw	a2,990(a5) # 800137fc <cons+0x9c>
        wakeup(&cons.r);
    80000426:	00013517          	auipc	a0,0x13
    8000042a:	3d250513          	addi	a0,a0,978 # 800137f8 <cons+0x98>
    8000042e:	3bf010ef          	jal	80001fec <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00008597          	auipc	a1,0x8
    80000440:	bc458593          	addi	a1,a1,-1084 # 80008000 <etext>
    80000444:	00013517          	auipc	a0,0x13
    80000448:	31c50513          	addi	a0,a0,796 # 80013760 <cons>
    8000044c:	710000ef          	jal	80000b5c <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	00024797          	auipc	a5,0x24
    80000458:	aa478793          	addi	a5,a5,-1372 # 80023ef8 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00008617          	auipc	a2,0x8
    80000492:	3d260613          	addi	a2,a2,978 # 80008860 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000b797          	auipc	a5,0xb
    8000052c:	20c7a783          	lw	a5,524(a5) # 8000b734 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	00013517          	auipc	a0,0x13
    80000574:	29850513          	addi	a0,a0,664 # 80013808 <pr>
    80000578:	65a000ef          	jal	80000bd2 <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00008b97          	auipc	s7,0x8
    8000073c:	128b8b93          	addi	s7,s7,296 # 80008860 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00008917          	auipc	s2,0x8
    8000079c:	87090913          	addi	s2,s2,-1936 # 80008008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	0000b797          	auipc	a5,0xb
    800007d0:	f687a783          	lw	a5,-152(a5) # 8000b734 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	00013517          	auipc	a0,0x13
    800007e6:	02650513          	addi	a0,a0,38 # 80013808 <pr>
    800007ea:	474000ef          	jal	80000c5e <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	0000b797          	auipc	a5,0xb
    80000804:	f327aa23          	sw	s2,-204(a5) # 8000b734 <panicking>
  printk("panic: ");
    80000808:	00008517          	auipc	a0,0x8
    8000080c:	80850513          	addi	a0,a0,-2040 # 80008010 <etext+0x10>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00008517          	auipc	a0,0x8
    8000081a:	80250513          	addi	a0,a0,-2046 # 80008018 <etext+0x18>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	0000b797          	auipc	a5,0xb
    80000826:	f127a723          	sw	s2,-242(a5) # 8000b730 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00007597          	auipc	a1,0x7
    80000838:	7ec58593          	addi	a1,a1,2028 # 80008020 <etext+0x20>
    8000083c:	00013517          	auipc	a0,0x13
    80000840:	fcc50513          	addi	a0,a0,-52 # 80013808 <pr>
    80000844:	318000ef          	jal	80000b5c <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00007597          	auipc	a1,0x7
    80000890:	79c58593          	addi	a1,a1,1948 # 80008028 <etext+0x28>
    80000894:	00013517          	auipc	a0,0x13
    80000898:	f8c50513          	addi	a0,a0,-116 # 80013820 <tx_lock>
    8000089c:	52b030ef          	jal	800045c6 <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	00013517          	auipc	a0,0x13
    800008bc:	f6850513          	addi	a0,a0,-152 # 80013820 <tx_lock>
    800008c0:	53d030ef          	jal	800045fc <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	0000ba17          	auipc	s4,0xb
    800008d6:	e66a0a13          	addi	s4,s4,-410 # 8000b738 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	686010ef          	jal	80001f80 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	6b4010ef          	jal	80001fbc <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	00013517          	auipc	a0,0x13
    8000091a:	f0a50513          	addi	a0,a0,-246 # 80013820 <tx_lock>
    8000091e:	533030ef          	jal	80004650 <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	0000b797          	auipc	a5,0xb
    8000093e:	dfa7a783          	lw	a5,-518(a5) # 8000b734 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	0000b797          	auipc	a5,0xb
    80000948:	dec7a783          	lw	a5,-532(a5) # 8000b730 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	0000b797          	auipc	a5,0xb
    8000096e:	dca7a783          	lw	a5,-566(a5) # 8000b734 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	21e000ef          	jal	80000b9c <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	28c000ef          	jal	80000c12 <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	0000b517          	auipc	a0,0xb
    800009d2:	d6a50513          	addi	a0,a0,-662 # 8000b738 <tx_chan>
    800009d6:	616010ef          	jal	80001fec <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00024797          	auipc	a5,0x24
    80000a00:	69478793          	addi	a5,a5,1684 # 80025090 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	282000ef          	jal	80000c96 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	00013917          	auipc	s2,0x13
    80000a1c:	e3890913          	addi	s2,s2,-456 # 80013850 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	1b0000ef          	jal	80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	22c000ef          	jal	80000c5e <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00007517          	auipc	a0,0x7
    80000a46:	5ee50513          	addi	a0,a0,1518 # 80008030 <etext+0x30>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	59a58593          	addi	a1,a1,1434 # 80008038 <etext+0x38>
    80000aa6:	00013517          	auipc	a0,0x13
    80000aaa:	daa50513          	addi	a0,a0,-598 # 80013850 <kmem>
    80000aae:	0ae000ef          	jal	80000b5c <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00024517          	auipc	a0,0x24
    80000aba:	5da50513          	addi	a0,a0,1498 # 80025090 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	00013497          	auipc	s1,0x13
    80000ad8:	d7c48493          	addi	s1,s1,-644 # 80013850 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0f4000ef          	jal	80000bd2 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	00013517          	auipc	a0,0x13
    80000aec:	d6850513          	addi	a0,a0,-664 # 80013850 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	16c000ef          	jal	80000c5e <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	19a000ef          	jal	80000c96 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	00013517          	auipc	a0,0x13
    80000b10:	d4450513          	addi	a0,a0,-700 # 80013850 <kmem>
    80000b14:	14a000ef          	jal	80000c5e <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <count_free_mem>:

uint64
count_free_mem(void)
{
    80000b1a:	1101                	addi	sp,sp,-32
    80000b1c:	ec06                	sd	ra,24(sp)
    80000b1e:	e822                	sd	s0,16(sp)
    80000b20:	e426                	sd	s1,8(sp)
    80000b22:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 free_pages = 0;

  acquire(&kmem.lock);
    80000b24:	00013497          	auipc	s1,0x13
    80000b28:	d2c48493          	addi	s1,s1,-724 # 80013850 <kmem>
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	0a4000ef          	jal	80000bd2 <acquire>
  r = kmem.freelist;
    80000b32:	6c9c                	ld	a5,24(s1)
  while(r){
    80000b34:	c395                	beqz	a5,80000b58 <count_free_mem+0x3e>
  uint64 free_pages = 0;
    80000b36:	4481                	li	s1,0
    free_pages++;
    80000b38:	0485                	addi	s1,s1,1
    r = r->next;
    80000b3a:	639c                	ld	a5,0(a5)
  while(r){
    80000b3c:	fff5                	bnez	a5,80000b38 <count_free_mem+0x1e>
  }
  release(&kmem.lock);
    80000b3e:	00013517          	auipc	a0,0x13
    80000b42:	d1250513          	addi	a0,a0,-750 # 80013850 <kmem>
    80000b46:	118000ef          	jal	80000c5e <release>

  // Each page is 4096 bytes
  return free_pages * 4096; 
}
    80000b4a:	00c49513          	slli	a0,s1,0xc
    80000b4e:	60e2                	ld	ra,24(sp)
    80000b50:	6442                	ld	s0,16(sp)
    80000b52:	64a2                	ld	s1,8(sp)
    80000b54:	6105                	addi	sp,sp,32
    80000b56:	8082                	ret
  uint64 free_pages = 0;
    80000b58:	4481                	li	s1,0
    80000b5a:	b7d5                	j	80000b3e <count_free_mem+0x24>

0000000080000b5c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5c:	1141                	addi	sp,sp,-16
    80000b5e:	e422                	sd	s0,8(sp)
    80000b60:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b62:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b64:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b68:	00053823          	sd	zero,16(a0)
}
    80000b6c:	6422                	ld	s0,8(sp)
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b72:	411c                	lw	a5,0(a0)
    80000b74:	e399                	bnez	a5,80000b7a <holding+0x8>
    80000b76:	4501                	li	a0,0
  return r;
}
    80000b78:	8082                	ret
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b84:	6904                	ld	s1,16(a0)
    80000b86:	543000ef          	jal	800018c8 <mycpu>
    80000b8a:	40a48533          	sub	a0,s1,a0
    80000b8e:	00153513          	seqz	a0,a0
}
    80000b92:	60e2                	ld	ra,24(sp)
    80000b94:	6442                	ld	s0,16(sp)
    80000b96:	64a2                	ld	s1,8(sp)
    80000b98:	6105                	addi	sp,sp,32
    80000b9a:	8082                	ret

0000000080000b9c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000ba6:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000baa:	51f000ef          	jal	800018c8 <mycpu>
    80000bae:	5d3c                	lw	a5,120(a0)
    80000bb0:	cb99                	beqz	a5,80000bc6 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bb2:	517000ef          	jal	800018c8 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	503000ef          	jal	800018c8 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	b7cd                	j	80000bb2 <push_off+0x16>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	fbfff0ef          	jal	80000b9c <push_off>
  if (holding(lk))
    80000be2:	8526                	mv	a0,s1
    80000be4:	f8fff0ef          	jal	80000b72 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000be8:	4705                	li	a4,1
  if (holding(lk))
    80000bea:	ed11                	bnez	a0,80000c06 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000bec:	87ba                	mv	a5,a4
    80000bee:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf2:	2781                	sext.w	a5,a5
    80000bf4:	ffe5                	bnez	a5,80000bec <acquire+0x1a>
  lk->cpu = mycpu();
    80000bf6:	4d3000ef          	jal	800018c8 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	43a50513          	addi	a0,a0,1082 # 80008040 <etext+0x40>
    80000c0e:	be3ff0ef          	jal	800007f0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	4af000ef          	jal	800018c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c24:	e38d                	bnez	a5,80000c46 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05563          	blez	a5,80000c52 <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c34:	e709                	bnez	a4,80000c3e <pop_off+0x2c>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c399                	beqz	a5,80000c3e <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c3a:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c3e:	60a2                	ld	ra,8(sp)
    80000c40:	6402                	ld	s0,0(sp)
    80000c42:	0141                	addi	sp,sp,16
    80000c44:	8082                	ret
    panic("pop_off - interruptible");
    80000c46:	00007517          	auipc	a0,0x7
    80000c4a:	40250513          	addi	a0,a0,1026 # 80008048 <etext+0x48>
    80000c4e:	ba3ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000c52:	00007517          	auipc	a0,0x7
    80000c56:	40e50513          	addi	a0,a0,1038 # 80008060 <etext+0x60>
    80000c5a:	b97ff0ef          	jal	800007f0 <panic>

0000000080000c5e <release>:
{
    80000c5e:	1101                	addi	sp,sp,-32
    80000c60:	ec06                	sd	ra,24(sp)
    80000c62:	e822                	sd	s0,16(sp)
    80000c64:	e426                	sd	s1,8(sp)
    80000c66:	1000                	addi	s0,sp,32
    80000c68:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c6a:	f09ff0ef          	jal	80000b72 <holding>
    80000c6e:	cd11                	beqz	a0,80000c8a <release+0x2c>
  lk->cpu = 0;
    80000c70:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c74:	0310000f          	fence	rw,w
    80000c78:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c7c:	f97ff0ef          	jal	80000c12 <pop_off>
}
    80000c80:	60e2                	ld	ra,24(sp)
    80000c82:	6442                	ld	s0,16(sp)
    80000c84:	64a2                	ld	s1,8(sp)
    80000c86:	6105                	addi	sp,sp,32
    80000c88:	8082                	ret
    panic("release");
    80000c8a:	00007517          	auipc	a0,0x7
    80000c8e:	3de50513          	addi	a0,a0,990 # 80008068 <etext+0x68>
    80000c92:	b5fff0ef          	jal	800007f0 <panic>

0000000080000c96 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c96:	1141                	addi	sp,sp,-16
    80000c98:	e422                	sd	s0,8(sp)
    80000c9a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c9c:	ca19                	beqz	a2,80000cb2 <memset+0x1c>
    80000c9e:	87aa                	mv	a5,a0
    80000ca0:	1602                	slli	a2,a2,0x20
    80000ca2:	9201                	srli	a2,a2,0x20
    80000ca4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ca8:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cac:	0785                	addi	a5,a5,1
    80000cae:	fee79de3          	bne	a5,a4,80000ca8 <memset+0x12>
  }
  return dst;
}
    80000cb2:	6422                	ld	s0,8(sp)
    80000cb4:	0141                	addi	sp,sp,16
    80000cb6:	8082                	ret

0000000080000cb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cb8:	1141                	addi	sp,sp,-16
    80000cba:	e422                	sd	s0,8(sp)
    80000cbc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000cbe:	ca05                	beqz	a2,80000cee <memcmp+0x36>
    80000cc0:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cc4:	1682                	slli	a3,a3,0x20
    80000cc6:	9281                	srli	a3,a3,0x20
    80000cc8:	0685                	addi	a3,a3,1
    80000cca:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000ccc:	00054783          	lbu	a5,0(a0)
    80000cd0:	0005c703          	lbu	a4,0(a1)
    80000cd4:	00e79863          	bne	a5,a4,80000ce4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000cd8:	0505                	addi	a0,a0,1
    80000cda:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000cdc:	fed518e3          	bne	a0,a3,80000ccc <memcmp+0x14>
  }

  return 0;
    80000ce0:	4501                	li	a0,0
    80000ce2:	a019                	j	80000ce8 <memcmp+0x30>
      return *s1 - *s2;
    80000ce4:	40e7853b          	subw	a0,a5,a4
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret
  return 0;
    80000cee:	4501                	li	a0,0
    80000cf0:	bfe5                	j	80000ce8 <memcmp+0x30>

0000000080000cf2 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e422                	sd	s0,8(sp)
    80000cf6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cf8:	c205                	beqz	a2,80000d18 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cfa:	02a5e263          	bltu	a1,a0,80000d1e <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cfe:	1602                	slli	a2,a2,0x20
    80000d00:	9201                	srli	a2,a2,0x20
    80000d02:	00c587b3          	add	a5,a1,a2
{
    80000d06:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d08:	0585                	addi	a1,a1,1
    80000d0a:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9f71>
    80000d0c:	fff5c683          	lbu	a3,-1(a1)
    80000d10:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d14:	feb79ae3          	bne	a5,a1,80000d08 <memmove+0x16>

  return dst;
}
    80000d18:	6422                	ld	s0,8(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret
  if (s < d && s + n > d) {
    80000d1e:	02061693          	slli	a3,a2,0x20
    80000d22:	9281                	srli	a3,a3,0x20
    80000d24:	00d58733          	add	a4,a1,a3
    80000d28:	fce57be3          	bgeu	a0,a4,80000cfe <memmove+0xc>
    d += n;
    80000d2c:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d2e:	fff6079b          	addiw	a5,a2,-1
    80000d32:	1782                	slli	a5,a5,0x20
    80000d34:	9381                	srli	a5,a5,0x20
    80000d36:	fff7c793          	not	a5,a5
    80000d3a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d3c:	177d                	addi	a4,a4,-1
    80000d3e:	16fd                	addi	a3,a3,-1
    80000d40:	00074603          	lbu	a2,0(a4)
    80000d44:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d48:	fef71ae3          	bne	a4,a5,80000d3c <memmove+0x4a>
    80000d4c:	b7f1                	j	80000d18 <memmove+0x26>

0000000080000d4e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d4e:	1141                	addi	sp,sp,-16
    80000d50:	e406                	sd	ra,8(sp)
    80000d52:	e022                	sd	s0,0(sp)
    80000d54:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d56:	f9dff0ef          	jal	80000cf2 <memmove>
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret

0000000080000d62 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d62:	1141                	addi	sp,sp,-16
    80000d64:	e422                	sd	s0,8(sp)
    80000d66:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d68:	ce11                	beqz	a2,80000d84 <strncmp+0x22>
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	cf89                	beqz	a5,80000d88 <strncmp+0x26>
    80000d70:	0005c703          	lbu	a4,0(a1)
    80000d74:	00f71a63          	bne	a4,a5,80000d88 <strncmp+0x26>
    n--, p++, q++;
    80000d78:	367d                	addiw	a2,a2,-1
    80000d7a:	0505                	addi	a0,a0,1
    80000d7c:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d7e:	f675                	bnez	a2,80000d6a <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d80:	4501                	li	a0,0
    80000d82:	a801                	j	80000d92 <strncmp+0x30>
    80000d84:	4501                	li	a0,0
    80000d86:	a031                	j	80000d92 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d88:	00054503          	lbu	a0,0(a0)
    80000d8c:	0005c783          	lbu	a5,0(a1)
    80000d90:	9d1d                	subw	a0,a0,a5
}
    80000d92:	6422                	ld	s0,8(sp)
    80000d94:	0141                	addi	sp,sp,16
    80000d96:	8082                	ret

0000000080000d98 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d98:	1141                	addi	sp,sp,-16
    80000d9a:	e422                	sd	s0,8(sp)
    80000d9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d9e:	87aa                	mv	a5,a0
    80000da0:	86b2                	mv	a3,a2
    80000da2:	367d                	addiw	a2,a2,-1
    80000da4:	02d05563          	blez	a3,80000dce <strncpy+0x36>
    80000da8:	0785                	addi	a5,a5,1
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	fee78fa3          	sb	a4,-1(a5)
    80000db2:	0585                	addi	a1,a1,1
    80000db4:	f775                	bnez	a4,80000da0 <strncpy+0x8>
    ;
  while (n-- > 0)
    80000db6:	873e                	mv	a4,a5
    80000db8:	9fb5                	addw	a5,a5,a3
    80000dba:	37fd                	addiw	a5,a5,-1
    80000dbc:	00c05963          	blez	a2,80000dce <strncpy+0x36>
    *s++ = 0;
    80000dc0:	0705                	addi	a4,a4,1
    80000dc2:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000dc6:	40e786bb          	subw	a3,a5,a4
    80000dca:	fed04be3          	bgtz	a3,80000dc0 <strncpy+0x28>
  return os;
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret

0000000080000dd4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000dd4:	1141                	addi	sp,sp,-16
    80000dd6:	e422                	sd	s0,8(sp)
    80000dd8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000dda:	02c05363          	blez	a2,80000e00 <safestrcpy+0x2c>
    80000dde:	fff6069b          	addiw	a3,a2,-1
    80000de2:	1682                	slli	a3,a3,0x20
    80000de4:	9281                	srli	a3,a3,0x20
    80000de6:	96ae                	add	a3,a3,a1
    80000de8:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000dea:	00d58963          	beq	a1,a3,80000dfc <safestrcpy+0x28>
    80000dee:	0585                	addi	a1,a1,1
    80000df0:	0785                	addi	a5,a5,1
    80000df2:	fff5c703          	lbu	a4,-1(a1)
    80000df6:	fee78fa3          	sb	a4,-1(a5)
    80000dfa:	fb65                	bnez	a4,80000dea <safestrcpy+0x16>
    ;
  *s = 0;
    80000dfc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strlen>:

int
strlen(const char *s)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf91                	beqz	a5,80000e2c <strlen+0x26>
    80000e12:	0505                	addi	a0,a0,1
    80000e14:	87aa                	mv	a5,a0
    80000e16:	86be                	mv	a3,a5
    80000e18:	0785                	addi	a5,a5,1
    80000e1a:	fff7c703          	lbu	a4,-1(a5)
    80000e1e:	ff65                	bnez	a4,80000e16 <strlen+0x10>
    80000e20:	40a6853b          	subw	a0,a3,a0
    80000e24:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e26:	6422                	ld	s0,8(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e2c:	4501                	li	a0,0
    80000e2e:	bfe5                	j	80000e26 <strlen+0x20>

0000000080000e30 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e30:	1141                	addi	sp,sp,-16
    80000e32:	e406                	sd	ra,8(sp)
    80000e34:	e022                	sd	s0,0(sp)
    80000e36:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e38:	281000ef          	jal	800018b8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e3c:	0000b717          	auipc	a4,0xb
    80000e40:	90070713          	addi	a4,a4,-1792 # 8000b73c <started>
  if (cpuid() == 0) {
    80000e44:	c51d                	beqz	a0,80000e72 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e46:	431c                	lw	a5,0(a4)
    80000e48:	0230000f          	fence	r,rw
    80000e4c:	2781                	sext.w	a5,a5
    80000e4e:	dfe5                	beqz	a5,80000e46 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e50:	269000ef          	jal	800018b8 <cpuid>
    80000e54:	85aa                	mv	a1,a0
    80000e56:	00007517          	auipc	a0,0x7
    80000e5a:	23250513          	addi	a0,a0,562 # 80008088 <etext+0x88>
    80000e5e:	eacff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e62:	082000ef          	jal	80000ee4 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e66:	1bd010ef          	jal	80002822 <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e6a:	63f040ef          	jal	80005ca8 <plicinithart>
  }

  scheduler();
    80000e6e:	709000ef          	jal	80001d76 <scheduler>
    consoleinit();
    80000e72:	dc2ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000e76:	9b7ff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000e7a:	00007517          	auipc	a0,0x7
    80000e7e:	21e50513          	addi	a0,a0,542 # 80008098 <etext+0x98>
    80000e82:	e88ff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e86:	00007517          	auipc	a0,0x7
    80000e8a:	1ea50513          	addi	a0,a0,490 # 80008070 <etext+0x70>
    80000e8e:	e7cff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e92:	00007517          	auipc	a0,0x7
    80000e96:	20650513          	addi	a0,a0,518 # 80008098 <etext+0x98>
    80000e9a:	e70ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e9e:	bf9ff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000ea2:	2cc000ef          	jal	8000116e <kvminit>
    kvminithart();      // turn on paging
    80000ea6:	03e000ef          	jal	80000ee4 <kvminithart>
    procinit();         // process table
    80000eaa:	159000ef          	jal	80001802 <procinit>
    trapinit();         // trap vectors
    80000eae:	151010ef          	jal	800027fe <trapinit>
    trapinithart();     // install kernel trap vector
    80000eb2:	171010ef          	jal	80002822 <trapinithart>
    plicinit();         // set up interrupt controller
    80000eb6:	5d9040ef          	jal	80005c8e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000eba:	5ef040ef          	jal	80005ca8 <plicinithart>
    binit();            // buffer cache
    80000ebe:	296020ef          	jal	80003154 <binit>
    iinit();            // inode table
    80000ec2:	01d020ef          	jal	800036de <iinit>
    fileinit();         // file table
    80000ec6:	00d030ef          	jal	800046d2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000eca:	6cf040ef          	jal	80005d98 <virtio_disk_init>
    userinit();         // first user process
    80000ece:	4f5000ef          	jal	80001bc2 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000ed2:	0000b797          	auipc	a5,0xb
    80000ed6:	86a78793          	addi	a5,a5,-1942 # 8000b73c <started>
    80000eda:	4705                	li	a4,1
    80000edc:	0310000f          	fence	rw,w
    80000ee0:	c398                	sw	a4,0(a5)
    80000ee2:	b771                	j	80000e6e <main+0x3e>

0000000080000ee4 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000eea:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eee:	0000b797          	auipc	a5,0xb
    80000ef2:	8527b783          	ld	a5,-1966(a5) # 8000b740 <kernel_pagetable>
    80000ef6:	83b1                	srli	a5,a5,0xc
    80000ef8:	577d                	li	a4,-1
    80000efa:	177e                	slli	a4,a4,0x3f
    80000efc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000efe:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f02:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f06:	6422                	ld	s0,8(sp)
    80000f08:	0141                	addi	sp,sp,16
    80000f0a:	8082                	ret

0000000080000f0c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f0c:	7139                	addi	sp,sp,-64
    80000f0e:	fc06                	sd	ra,56(sp)
    80000f10:	f822                	sd	s0,48(sp)
    80000f12:	f426                	sd	s1,40(sp)
    80000f14:	f04a                	sd	s2,32(sp)
    80000f16:	ec4e                	sd	s3,24(sp)
    80000f18:	e852                	sd	s4,16(sp)
    80000f1a:	e456                	sd	s5,8(sp)
    80000f1c:	e05a                	sd	s6,0(sp)
    80000f1e:	0080                	addi	s0,sp,64
    80000f20:	84aa                	mv	s1,a0
    80000f22:	89ae                	mv	s3,a1
    80000f24:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000f26:	57fd                	li	a5,-1
    80000f28:	83e9                	srli	a5,a5,0x1a
    80000f2a:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f2c:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000f2e:	02b7fc63          	bgeu	a5,a1,80000f66 <walk+0x5a>
    panic("walk");
    80000f32:	00007517          	auipc	a0,0x7
    80000f36:	16e50513          	addi	a0,a0,366 # 800080a0 <etext+0xa0>
    80000f3a:	8b7ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000f3e:	060a8263          	beqz	s5,80000fa2 <walk+0x96>
    80000f42:	b89ff0ef          	jal	80000aca <kalloc>
    80000f46:	84aa                	mv	s1,a0
    80000f48:	c139                	beqz	a0,80000f8e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f4a:	6605                	lui	a2,0x1
    80000f4c:	4581                	li	a1,0
    80000f4e:	d49ff0ef          	jal	80000c96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f52:	00c4d793          	srli	a5,s1,0xc
    80000f56:	07aa                	slli	a5,a5,0xa
    80000f58:	0017e793          	ori	a5,a5,1
    80000f5c:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f60:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd9f67>
    80000f62:	036a0063          	beq	s4,s6,80000f82 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f66:	0149d933          	srl	s2,s3,s4
    80000f6a:	1ff97913          	andi	s2,s2,511
    80000f6e:	090e                	slli	s2,s2,0x3
    80000f70:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f72:	00093483          	ld	s1,0(s2)
    80000f76:	0014f793          	andi	a5,s1,1
    80000f7a:	d3f1                	beqz	a5,80000f3e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f7c:	80a9                	srli	s1,s1,0xa
    80000f7e:	04b2                	slli	s1,s1,0xc
    80000f80:	b7c5                	j	80000f60 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f82:	00c9d513          	srli	a0,s3,0xc
    80000f86:	1ff57513          	andi	a0,a0,511
    80000f8a:	050e                	slli	a0,a0,0x3
    80000f8c:	9526                	add	a0,a0,s1
}
    80000f8e:	70e2                	ld	ra,56(sp)
    80000f90:	7442                	ld	s0,48(sp)
    80000f92:	74a2                	ld	s1,40(sp)
    80000f94:	7902                	ld	s2,32(sp)
    80000f96:	69e2                	ld	s3,24(sp)
    80000f98:	6a42                	ld	s4,16(sp)
    80000f9a:	6aa2                	ld	s5,8(sp)
    80000f9c:	6b02                	ld	s6,0(sp)
    80000f9e:	6121                	addi	sp,sp,64
    80000fa0:	8082                	ret
        return 0;
    80000fa2:	4501                	li	a0,0
    80000fa4:	b7ed                	j	80000f8e <walk+0x82>

0000000080000fa6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	00b7f463          	bgeu	a5,a1,80000fb2 <walkaddr+0xc>
    return 0;
    80000fae:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fb0:	8082                	ret
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e406                	sd	ra,8(sp)
    80000fb6:	e022                	sd	s0,0(sp)
    80000fb8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fba:	4601                	li	a2,0
    80000fbc:	f51ff0ef          	jal	80000f0c <walk>
  if (pte == 0)
    80000fc0:	c105                	beqz	a0,80000fe0 <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000fc2:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000fc4:	0117f693          	andi	a3,a5,17
    80000fc8:	4745                	li	a4,17
    return 0;
    80000fca:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000fcc:	00e68663          	beq	a3,a4,80000fd8 <walkaddr+0x32>
}
    80000fd0:	60a2                	ld	ra,8(sp)
    80000fd2:	6402                	ld	s0,0(sp)
    80000fd4:	0141                	addi	sp,sp,16
    80000fd6:	8082                	ret
  pa = PTE2PA(*pte);
    80000fd8:	83a9                	srli	a5,a5,0xa
    80000fda:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fde:	bfcd                	j	80000fd0 <walkaddr+0x2a>
    return 0;
    80000fe0:	4501                	li	a0,0
    80000fe2:	b7fd                	j	80000fd0 <walkaddr+0x2a>

0000000080000fe4 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fe4:	715d                	addi	sp,sp,-80
    80000fe6:	e486                	sd	ra,72(sp)
    80000fe8:	e0a2                	sd	s0,64(sp)
    80000fea:	fc26                	sd	s1,56(sp)
    80000fec:	f84a                	sd	s2,48(sp)
    80000fee:	f44e                	sd	s3,40(sp)
    80000ff0:	f052                	sd	s4,32(sp)
    80000ff2:	ec56                	sd	s5,24(sp)
    80000ff4:	e85a                	sd	s6,16(sp)
    80000ff6:	e45e                	sd	s7,8(sp)
    80000ff8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000ffa:	03459793          	slli	a5,a1,0x34
    80000ffe:	e7a9                	bnez	a5,80001048 <mappages+0x64>
    80001000:	8aaa                	mv	s5,a0
    80001002:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001004:	03461793          	slli	a5,a2,0x34
    80001008:	e7b1                	bnez	a5,80001054 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    8000100a:	ca39                	beqz	a2,80001060 <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000100c:	77fd                	lui	a5,0xfffff
    8000100e:	963e                	add	a2,a2,a5
    80001010:	00b609b3          	add	s3,a2,a1
  a = va;
    80001014:	892e                	mv	s2,a1
    80001016:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000101a:	6b85                	lui	s7,0x1
    8000101c:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001020:	4605                	li	a2,1
    80001022:	85ca                	mv	a1,s2
    80001024:	8556                	mv	a0,s5
    80001026:	ee7ff0ef          	jal	80000f0c <walk>
    8000102a:	c539                	beqz	a0,80001078 <mappages+0x94>
    if (*pte & PTE_V)
    8000102c:	611c                	ld	a5,0(a0)
    8000102e:	8b85                	andi	a5,a5,1
    80001030:	ef95                	bnez	a5,8000106c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001032:	80b1                	srli	s1,s1,0xc
    80001034:	04aa                	slli	s1,s1,0xa
    80001036:	0164e4b3          	or	s1,s1,s6
    8000103a:	0014e493          	ori	s1,s1,1
    8000103e:	e104                	sd	s1,0(a0)
    if (a == last)
    80001040:	05390863          	beq	s2,s3,80001090 <mappages+0xac>
    a += PGSIZE;
    80001044:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001046:	bfd9                	j	8000101c <mappages+0x38>
    panic("mappages: va not aligned");
    80001048:	00007517          	auipc	a0,0x7
    8000104c:	06050513          	addi	a0,a0,96 # 800080a8 <etext+0xa8>
    80001050:	fa0ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    80001054:	00007517          	auipc	a0,0x7
    80001058:	07450513          	addi	a0,a0,116 # 800080c8 <etext+0xc8>
    8000105c:	f94ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    80001060:	00007517          	auipc	a0,0x7
    80001064:	08850513          	addi	a0,a0,136 # 800080e8 <etext+0xe8>
    80001068:	f88ff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    8000106c:	00007517          	auipc	a0,0x7
    80001070:	08c50513          	addi	a0,a0,140 # 800080f8 <etext+0xf8>
    80001074:	f7cff0ef          	jal	800007f0 <panic>
      return -1;
    80001078:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000107a:	60a6                	ld	ra,72(sp)
    8000107c:	6406                	ld	s0,64(sp)
    8000107e:	74e2                	ld	s1,56(sp)
    80001080:	7942                	ld	s2,48(sp)
    80001082:	79a2                	ld	s3,40(sp)
    80001084:	7a02                	ld	s4,32(sp)
    80001086:	6ae2                	ld	s5,24(sp)
    80001088:	6b42                	ld	s6,16(sp)
    8000108a:	6ba2                	ld	s7,8(sp)
    8000108c:	6161                	addi	sp,sp,80
    8000108e:	8082                	ret
  return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7e5                	j	8000107a <mappages+0x96>

0000000080001094 <kvmmap>:
{
    80001094:	1141                	addi	sp,sp,-16
    80001096:	e406                	sd	ra,8(sp)
    80001098:	e022                	sd	s0,0(sp)
    8000109a:	0800                	addi	s0,sp,16
    8000109c:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000109e:	86b2                	mv	a3,a2
    800010a0:	863e                	mv	a2,a5
    800010a2:	f43ff0ef          	jal	80000fe4 <mappages>
    800010a6:	e509                	bnez	a0,800010b0 <kvmmap+0x1c>
}
    800010a8:	60a2                	ld	ra,8(sp)
    800010aa:	6402                	ld	s0,0(sp)
    800010ac:	0141                	addi	sp,sp,16
    800010ae:	8082                	ret
    panic("kvmmap");
    800010b0:	00007517          	auipc	a0,0x7
    800010b4:	05850513          	addi	a0,a0,88 # 80008108 <etext+0x108>
    800010b8:	f38ff0ef          	jal	800007f0 <panic>

00000000800010bc <kvmmake>:
{
    800010bc:	1101                	addi	sp,sp,-32
    800010be:	ec06                	sd	ra,24(sp)
    800010c0:	e822                	sd	s0,16(sp)
    800010c2:	e426                	sd	s1,8(sp)
    800010c4:	e04a                	sd	s2,0(sp)
    800010c6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    800010c8:	a03ff0ef          	jal	80000aca <kalloc>
    800010cc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010ce:	6605                	lui	a2,0x1
    800010d0:	4581                	li	a1,0
    800010d2:	bc5ff0ef          	jal	80000c96 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010d6:	4719                	li	a4,6
    800010d8:	6685                	lui	a3,0x1
    800010da:	10000637          	lui	a2,0x10000
    800010de:	100005b7          	lui	a1,0x10000
    800010e2:	8526                	mv	a0,s1
    800010e4:	fb1ff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010e8:	4719                	li	a4,6
    800010ea:	6685                	lui	a3,0x1
    800010ec:	10001637          	lui	a2,0x10001
    800010f0:	100015b7          	lui	a1,0x10001
    800010f4:	8526                	mv	a0,s1
    800010f6:	f9fff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010fa:	4719                	li	a4,6
    800010fc:	040006b7          	lui	a3,0x4000
    80001100:	0c000637          	lui	a2,0xc000
    80001104:	0c0005b7          	lui	a1,0xc000
    80001108:	8526                	mv	a0,s1
    8000110a:	f8bff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000110e:	00007917          	auipc	s2,0x7
    80001112:	ef290913          	addi	s2,s2,-270 # 80008000 <etext>
    80001116:	4729                	li	a4,10
    80001118:	80007697          	auipc	a3,0x80007
    8000111c:	ee868693          	addi	a3,a3,-280 # 8000 <_entry-0x7fff8000>
    80001120:	4605                	li	a2,1
    80001122:	067e                	slli	a2,a2,0x1f
    80001124:	85b2                	mv	a1,a2
    80001126:	8526                	mv	a0,s1
    80001128:	f6dff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    8000112c:	46c5                	li	a3,17
    8000112e:	06ee                	slli	a3,a3,0x1b
    80001130:	4719                	li	a4,6
    80001132:	412686b3          	sub	a3,a3,s2
    80001136:	864a                	mv	a2,s2
    80001138:	85ca                	mv	a1,s2
    8000113a:	8526                	mv	a0,s1
    8000113c:	f59ff0ef          	jal	80001094 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001140:	4729                	li	a4,10
    80001142:	6685                	lui	a3,0x1
    80001144:	00006617          	auipc	a2,0x6
    80001148:	ebc60613          	addi	a2,a2,-324 # 80007000 <_trampoline>
    8000114c:	040005b7          	lui	a1,0x4000
    80001150:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001152:	05b2                	slli	a1,a1,0xc
    80001154:	8526                	mv	a0,s1
    80001156:	f3fff0ef          	jal	80001094 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000115a:	8526                	mv	a0,s1
    8000115c:	60e000ef          	jal	8000176a <proc_mapstacks>
}
    80001160:	8526                	mv	a0,s1
    80001162:	60e2                	ld	ra,24(sp)
    80001164:	6442                	ld	s0,16(sp)
    80001166:	64a2                	ld	s1,8(sp)
    80001168:	6902                	ld	s2,0(sp)
    8000116a:	6105                	addi	sp,sp,32
    8000116c:	8082                	ret

000000008000116e <kvminit>:
{
    8000116e:	1141                	addi	sp,sp,-16
    80001170:	e406                	sd	ra,8(sp)
    80001172:	e022                	sd	s0,0(sp)
    80001174:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001176:	f47ff0ef          	jal	800010bc <kvmmake>
    8000117a:	0000a797          	auipc	a5,0xa
    8000117e:	5ca7b323          	sd	a0,1478(a5) # 8000b740 <kernel_pagetable>
}
    80001182:	60a2                	ld	ra,8(sp)
    80001184:	6402                	ld	s0,0(sp)
    80001186:	0141                	addi	sp,sp,16
    80001188:	8082                	ret

000000008000118a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001194:	937ff0ef          	jal	80000aca <kalloc>
    80001198:	84aa                	mv	s1,a0
  if (pagetable == 0)
    8000119a:	c509                	beqz	a0,800011a4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000119c:	6605                	lui	a2,0x1
    8000119e:	4581                	li	a1,0
    800011a0:	af7ff0ef          	jal	80000c96 <memset>
  return pagetable;
}
    800011a4:	8526                	mv	a0,s1
    800011a6:	60e2                	ld	ra,24(sp)
    800011a8:	6442                	ld	s0,16(sp)
    800011aa:	64a2                	ld	s1,8(sp)
    800011ac:	6105                	addi	sp,sp,32
    800011ae:	8082                	ret

00000000800011b0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011b0:	7139                	addi	sp,sp,-64
    800011b2:	fc06                	sd	ra,56(sp)
    800011b4:	f822                	sd	s0,48(sp)
    800011b6:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    800011b8:	03459793          	slli	a5,a1,0x34
    800011bc:	e38d                	bnez	a5,800011de <uvmunmap+0x2e>
    800011be:	f04a                	sd	s2,32(sp)
    800011c0:	ec4e                	sd	s3,24(sp)
    800011c2:	e852                	sd	s4,16(sp)
    800011c4:	e456                	sd	s5,8(sp)
    800011c6:	e05a                	sd	s6,0(sp)
    800011c8:	8a2a                	mv	s4,a0
    800011ca:	892e                	mv	s2,a1
    800011cc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011ce:	0632                	slli	a2,a2,0xc
    800011d0:	00b609b3          	add	s3,a2,a1
    800011d4:	6b05                	lui	s6,0x1
    800011d6:	0535f963          	bgeu	a1,s3,80001228 <uvmunmap+0x78>
    800011da:	f426                	sd	s1,40(sp)
    800011dc:	a015                	j	80001200 <uvmunmap+0x50>
    800011de:	f426                	sd	s1,40(sp)
    800011e0:	f04a                	sd	s2,32(sp)
    800011e2:	ec4e                	sd	s3,24(sp)
    800011e4:	e852                	sd	s4,16(sp)
    800011e6:	e456                	sd	s5,8(sp)
    800011e8:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011ea:	00007517          	auipc	a0,0x7
    800011ee:	f2650513          	addi	a0,a0,-218 # 80008110 <etext+0x110>
    800011f2:	dfeff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011f6:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011fa:	995a                	add	s2,s2,s6
    800011fc:	03397563          	bgeu	s2,s3,80001226 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001200:	4601                	li	a2,0
    80001202:	85ca                	mv	a1,s2
    80001204:	8552                	mv	a0,s4
    80001206:	d07ff0ef          	jal	80000f0c <walk>
    8000120a:	84aa                	mv	s1,a0
    8000120c:	d57d                	beqz	a0,800011fa <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000120e:	611c                	ld	a5,0(a0)
    80001210:	0017f713          	andi	a4,a5,1
    80001214:	d37d                	beqz	a4,800011fa <uvmunmap+0x4a>
    if (do_free) {
    80001216:	fe0a80e3          	beqz	s5,800011f6 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000121a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000121c:	00c79513          	slli	a0,a5,0xc
    80001220:	fc8ff0ef          	jal	800009e8 <kfree>
    80001224:	bfc9                	j	800011f6 <uvmunmap+0x46>
    80001226:	74a2                	ld	s1,40(sp)
    80001228:	7902                	ld	s2,32(sp)
    8000122a:	69e2                	ld	s3,24(sp)
    8000122c:	6a42                	ld	s4,16(sp)
    8000122e:	6aa2                	ld	s5,8(sp)
    80001230:	6b02                	ld	s6,0(sp)
  }
}
    80001232:	70e2                	ld	ra,56(sp)
    80001234:	7442                	ld	s0,48(sp)
    80001236:	6121                	addi	sp,sp,64
    80001238:	8082                	ret

000000008000123a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000123a:	1101                	addi	sp,sp,-32
    8000123c:	ec06                	sd	ra,24(sp)
    8000123e:	e822                	sd	s0,16(sp)
    80001240:	e426                	sd	s1,8(sp)
    80001242:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001244:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001246:	00b67d63          	bgeu	a2,a1,80001260 <uvmdealloc+0x26>
    8000124a:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000124c:	6785                	lui	a5,0x1
    8000124e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001250:	00f60733          	add	a4,a2,a5
    80001254:	76fd                	lui	a3,0xfffff
    80001256:	8f75                	and	a4,a4,a3
    80001258:	97ae                	add	a5,a5,a1
    8000125a:	8ff5                	and	a5,a5,a3
    8000125c:	00f76863          	bltu	a4,a5,8000126c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001260:	8526                	mv	a0,s1
    80001262:	60e2                	ld	ra,24(sp)
    80001264:	6442                	ld	s0,16(sp)
    80001266:	64a2                	ld	s1,8(sp)
    80001268:	6105                	addi	sp,sp,32
    8000126a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000126c:	8f99                	sub	a5,a5,a4
    8000126e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001270:	4685                	li	a3,1
    80001272:	0007861b          	sext.w	a2,a5
    80001276:	85ba                	mv	a1,a4
    80001278:	f39ff0ef          	jal	800011b0 <uvmunmap>
    8000127c:	b7d5                	j	80001260 <uvmdealloc+0x26>

000000008000127e <uvmalloc>:
  if (newsz < oldsz)
    8000127e:	08b66f63          	bltu	a2,a1,8000131c <uvmalloc+0x9e>
{
    80001282:	7139                	addi	sp,sp,-64
    80001284:	fc06                	sd	ra,56(sp)
    80001286:	f822                	sd	s0,48(sp)
    80001288:	ec4e                	sd	s3,24(sp)
    8000128a:	e852                	sd	s4,16(sp)
    8000128c:	e456                	sd	s5,8(sp)
    8000128e:	0080                	addi	s0,sp,64
    80001290:	8aaa                	mv	s5,a0
    80001292:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001294:	6785                	lui	a5,0x1
    80001296:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001298:	95be                	add	a1,a1,a5
    8000129a:	77fd                	lui	a5,0xfffff
    8000129c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012a0:	08c9f063          	bgeu	s3,a2,80001320 <uvmalloc+0xa2>
    800012a4:	f426                	sd	s1,40(sp)
    800012a6:	f04a                	sd	s2,32(sp)
    800012a8:	e05a                	sd	s6,0(sp)
    800012aa:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012ac:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012b0:	81bff0ef          	jal	80000aca <kalloc>
    800012b4:	84aa                	mv	s1,a0
    if (mem == 0) {
    800012b6:	c515                	beqz	a0,800012e2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012b8:	6605                	lui	a2,0x1
    800012ba:	4581                	li	a1,0
    800012bc:	9dbff0ef          	jal	80000c96 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    800012c0:	875a                	mv	a4,s6
    800012c2:	86a6                	mv	a3,s1
    800012c4:	6605                	lui	a2,0x1
    800012c6:	85ca                	mv	a1,s2
    800012c8:	8556                	mv	a0,s5
    800012ca:	d1bff0ef          	jal	80000fe4 <mappages>
    800012ce:	e915                	bnez	a0,80001302 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    800012d0:	6785                	lui	a5,0x1
    800012d2:	993e                	add	s2,s2,a5
    800012d4:	fd496ee3          	bltu	s2,s4,800012b0 <uvmalloc+0x32>
  return newsz;
    800012d8:	8552                	mv	a0,s4
    800012da:	74a2                	ld	s1,40(sp)
    800012dc:	7902                	ld	s2,32(sp)
    800012de:	6b02                	ld	s6,0(sp)
    800012e0:	a811                	j	800012f4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012e2:	864e                	mv	a2,s3
    800012e4:	85ca                	mv	a1,s2
    800012e6:	8556                	mv	a0,s5
    800012e8:	f53ff0ef          	jal	8000123a <uvmdealloc>
      return 0;
    800012ec:	4501                	li	a0,0
    800012ee:	74a2                	ld	s1,40(sp)
    800012f0:	7902                	ld	s2,32(sp)
    800012f2:	6b02                	ld	s6,0(sp)
}
    800012f4:	70e2                	ld	ra,56(sp)
    800012f6:	7442                	ld	s0,48(sp)
    800012f8:	69e2                	ld	s3,24(sp)
    800012fa:	6a42                	ld	s4,16(sp)
    800012fc:	6aa2                	ld	s5,8(sp)
    800012fe:	6121                	addi	sp,sp,64
    80001300:	8082                	ret
      kfree(mem);
    80001302:	8526                	mv	a0,s1
    80001304:	ee4ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001308:	864e                	mv	a2,s3
    8000130a:	85ca                	mv	a1,s2
    8000130c:	8556                	mv	a0,s5
    8000130e:	f2dff0ef          	jal	8000123a <uvmdealloc>
      return 0;
    80001312:	4501                	li	a0,0
    80001314:	74a2                	ld	s1,40(sp)
    80001316:	7902                	ld	s2,32(sp)
    80001318:	6b02                	ld	s6,0(sp)
    8000131a:	bfe9                	j	800012f4 <uvmalloc+0x76>
    return oldsz;
    8000131c:	852e                	mv	a0,a1
}
    8000131e:	8082                	ret
  return newsz;
    80001320:	8532                	mv	a0,a2
    80001322:	bfc9                	j	800012f4 <uvmalloc+0x76>

0000000080001324 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001324:	7179                	addi	sp,sp,-48
    80001326:	f406                	sd	ra,40(sp)
    80001328:	f022                	sd	s0,32(sp)
    8000132a:	ec26                	sd	s1,24(sp)
    8000132c:	e84a                	sd	s2,16(sp)
    8000132e:	e44e                	sd	s3,8(sp)
    80001330:	e052                	sd	s4,0(sp)
    80001332:	1800                	addi	s0,sp,48
    80001334:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001336:	84aa                	mv	s1,a0
    80001338:	6905                	lui	s2,0x1
    8000133a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    8000133c:	4985                	li	s3,1
    8000133e:	a819                	j	80001354 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001340:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001342:	00c79513          	slli	a0,a5,0xc
    80001346:	fdfff0ef          	jal	80001324 <freewalk>
      pagetable[i] = 0;
    8000134a:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000134e:	04a1                	addi	s1,s1,8
    80001350:	01248f63          	beq	s1,s2,8000136e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001354:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001356:	00f7f713          	andi	a4,a5,15
    8000135a:	ff3703e3          	beq	a4,s3,80001340 <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000135e:	8b85                	andi	a5,a5,1
    80001360:	d7fd                	beqz	a5,8000134e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001362:	00007517          	auipc	a0,0x7
    80001366:	dc650513          	addi	a0,a0,-570 # 80008128 <etext+0x128>
    8000136a:	c86ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    8000136e:	8552                	mv	a0,s4
    80001370:	e78ff0ef          	jal	800009e8 <kfree>
}
    80001374:	70a2                	ld	ra,40(sp)
    80001376:	7402                	ld	s0,32(sp)
    80001378:	64e2                	ld	s1,24(sp)
    8000137a:	6942                	ld	s2,16(sp)
    8000137c:	69a2                	ld	s3,8(sp)
    8000137e:	6a02                	ld	s4,0(sp)
    80001380:	6145                	addi	sp,sp,48
    80001382:	8082                	ret

0000000080001384 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001384:	1101                	addi	sp,sp,-32
    80001386:	ec06                	sd	ra,24(sp)
    80001388:	e822                	sd	s0,16(sp)
    8000138a:	e426                	sd	s1,8(sp)
    8000138c:	1000                	addi	s0,sp,32
    8000138e:	84aa                	mv	s1,a0
  if (sz > 0)
    80001390:	e989                	bnez	a1,800013a2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001392:	8526                	mv	a0,s1
    80001394:	f91ff0ef          	jal	80001324 <freewalk>
}
    80001398:	60e2                	ld	ra,24(sp)
    8000139a:	6442                	ld	s0,16(sp)
    8000139c:	64a2                	ld	s1,8(sp)
    8000139e:	6105                	addi	sp,sp,32
    800013a0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    800013a2:	6785                	lui	a5,0x1
    800013a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013a6:	95be                	add	a1,a1,a5
    800013a8:	4685                	li	a3,1
    800013aa:	00c5d613          	srli	a2,a1,0xc
    800013ae:	4581                	li	a1,0
    800013b0:	e01ff0ef          	jal	800011b0 <uvmunmap>
    800013b4:	bff9                	j	80001392 <uvmfree+0xe>

00000000800013b6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    800013b6:	ce49                	beqz	a2,80001450 <uvmcopy+0x9a>
{
    800013b8:	715d                	addi	sp,sp,-80
    800013ba:	e486                	sd	ra,72(sp)
    800013bc:	e0a2                	sd	s0,64(sp)
    800013be:	fc26                	sd	s1,56(sp)
    800013c0:	f84a                	sd	s2,48(sp)
    800013c2:	f44e                	sd	s3,40(sp)
    800013c4:	f052                	sd	s4,32(sp)
    800013c6:	ec56                	sd	s5,24(sp)
    800013c8:	e85a                	sd	s6,16(sp)
    800013ca:	e45e                	sd	s7,8(sp)
    800013cc:	0880                	addi	s0,sp,80
    800013ce:	8aaa                	mv	s5,a0
    800013d0:	8b2e                	mv	s6,a1
    800013d2:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    800013d4:	4481                	li	s1,0
    800013d6:	a029                	j	800013e0 <uvmcopy+0x2a>
    800013d8:	6785                	lui	a5,0x1
    800013da:	94be                	add	s1,s1,a5
    800013dc:	0544fe63          	bgeu	s1,s4,80001438 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    800013e0:	4601                	li	a2,0
    800013e2:	85a6                	mv	a1,s1
    800013e4:	8556                	mv	a0,s5
    800013e6:	b27ff0ef          	jal	80000f0c <walk>
    800013ea:	d57d                	beqz	a0,800013d8 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013ec:	6118                	ld	a4,0(a0)
    800013ee:	00177793          	andi	a5,a4,1
    800013f2:	d3fd                	beqz	a5,800013d8 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013f4:	00a75593          	srli	a1,a4,0xa
    800013f8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013fc:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    80001400:	ecaff0ef          	jal	80000aca <kalloc>
    80001404:	89aa                	mv	s3,a0
    80001406:	c105                	beqz	a0,80001426 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	85de                	mv	a1,s7
    8000140c:	8e7ff0ef          	jal	80000cf2 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    80001410:	874a                	mv	a4,s2
    80001412:	86ce                	mv	a3,s3
    80001414:	6605                	lui	a2,0x1
    80001416:	85a6                	mv	a1,s1
    80001418:	855a                	mv	a0,s6
    8000141a:	bcbff0ef          	jal	80000fe4 <mappages>
    8000141e:	dd4d                	beqz	a0,800013d8 <uvmcopy+0x22>
      kfree(mem);
    80001420:	854e                	mv	a0,s3
    80001422:	dc6ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001426:	4685                	li	a3,1
    80001428:	00c4d613          	srli	a2,s1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	855a                	mv	a0,s6
    80001430:	d81ff0ef          	jal	800011b0 <uvmunmap>
  return -1;
    80001434:	557d                	li	a0,-1
    80001436:	a011                	j	8000143a <uvmcopy+0x84>
  return 0;
    80001438:	4501                	li	a0,0
}
    8000143a:	60a6                	ld	ra,72(sp)
    8000143c:	6406                	ld	s0,64(sp)
    8000143e:	74e2                	ld	s1,56(sp)
    80001440:	7942                	ld	s2,48(sp)
    80001442:	79a2                	ld	s3,40(sp)
    80001444:	7a02                	ld	s4,32(sp)
    80001446:	6ae2                	ld	s5,24(sp)
    80001448:	6b42                	ld	s6,16(sp)
    8000144a:	6ba2                	ld	s7,8(sp)
    8000144c:	6161                	addi	sp,sp,80
    8000144e:	8082                	ret
  return 0;
    80001450:	4501                	li	a0,0
}
    80001452:	8082                	ret

0000000080001454 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001454:	1141                	addi	sp,sp,-16
    80001456:	e406                	sd	ra,8(sp)
    80001458:	e022                	sd	s0,0(sp)
    8000145a:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000145c:	4601                	li	a2,0
    8000145e:	aafff0ef          	jal	80000f0c <walk>
  if (pte == 0)
    80001462:	c901                	beqz	a0,80001472 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001464:	611c                	ld	a5,0(a0)
    80001466:	9bbd                	andi	a5,a5,-17
    80001468:	e11c                	sd	a5,0(a0)
}
    8000146a:	60a2                	ld	ra,8(sp)
    8000146c:	6402                	ld	s0,0(sp)
    8000146e:	0141                	addi	sp,sp,16
    80001470:	8082                	ret
    panic("uvmclear");
    80001472:	00007517          	auipc	a0,0x7
    80001476:	cc650513          	addi	a0,a0,-826 # 80008138 <etext+0x138>
    8000147a:	b76ff0ef          	jal	800007f0 <panic>

000000008000147e <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000147e:	1141                	addi	sp,sp,-16
    80001480:	e406                	sd	ra,8(sp)
    80001482:	e022                	sd	s0,0(sp)
    80001484:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001486:	4601                	li	a2,0
    80001488:	a85ff0ef          	jal	80000f0c <walk>
  if (pte == 0) {
    8000148c:	c519                	beqz	a0,8000149a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    8000148e:	6108                	ld	a0,0(a0)
    80001490:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001492:	60a2                	ld	ra,8(sp)
    80001494:	6402                	ld	s0,0(sp)
    80001496:	0141                	addi	sp,sp,16
    80001498:	8082                	ret
    return 0;
    8000149a:	4501                	li	a0,0
    8000149c:	bfdd                	j	80001492 <ismapped+0x14>

000000008000149e <vmfault>:
{
    8000149e:	7179                	addi	sp,sp,-48
    800014a0:	f406                	sd	ra,40(sp)
    800014a2:	f022                	sd	s0,32(sp)
    800014a4:	e44e                	sd	s3,8(sp)
    800014a6:	1800                	addi	s0,sp,48
    return 0;
    800014a8:	4981                	li	s3,0
  if (va >= psz)
    800014aa:	00b66863          	bltu	a2,a1,800014ba <vmfault+0x1c>
}
    800014ae:	854e                	mv	a0,s3
    800014b0:	70a2                	ld	ra,40(sp)
    800014b2:	7402                	ld	s0,32(sp)
    800014b4:	69a2                	ld	s3,8(sp)
    800014b6:	6145                	addi	sp,sp,48
    800014b8:	8082                	ret
    800014ba:	ec26                	sd	s1,24(sp)
    800014bc:	e84a                	sd	s2,16(sp)
    800014be:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800014c0:	77fd                	lui	a5,0xfffff
    800014c2:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    800014c6:	85a6                	mv	a1,s1
    800014c8:	fb7ff0ef          	jal	8000147e <ismapped>
    return 0;
    800014cc:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    800014ce:	c501                	beqz	a0,800014d6 <vmfault+0x38>
    800014d0:	64e2                	ld	s1,24(sp)
    800014d2:	6942                	ld	s2,16(sp)
    800014d4:	bfe9                	j	800014ae <vmfault+0x10>
    800014d6:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    800014d8:	df2ff0ef          	jal	80000aca <kalloc>
    800014dc:	8a2a                	mv	s4,a0
  if (mem == 0)
    800014de:	c915                	beqz	a0,80001512 <vmfault+0x74>
  mem = (uint64)kalloc();
    800014e0:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800014e2:	6605                	lui	a2,0x1
    800014e4:	4581                	li	a1,0
    800014e6:	fb0ff0ef          	jal	80000c96 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800014ea:	4759                	li	a4,22
    800014ec:	86d2                	mv	a3,s4
    800014ee:	6605                	lui	a2,0x1
    800014f0:	85a6                	mv	a1,s1
    800014f2:	854a                	mv	a0,s2
    800014f4:	af1ff0ef          	jal	80000fe4 <mappages>
    800014f8:	e509                	bnez	a0,80001502 <vmfault+0x64>
    800014fa:	64e2                	ld	s1,24(sp)
    800014fc:	6942                	ld	s2,16(sp)
    800014fe:	6a02                	ld	s4,0(sp)
    80001500:	b77d                	j	800014ae <vmfault+0x10>
    kfree((void *)mem);
    80001502:	8552                	mv	a0,s4
    80001504:	ce4ff0ef          	jal	800009e8 <kfree>
    return 0;
    80001508:	4981                	li	s3,0
    8000150a:	64e2                	ld	s1,24(sp)
    8000150c:	6942                	ld	s2,16(sp)
    8000150e:	6a02                	ld	s4,0(sp)
    80001510:	bf79                	j	800014ae <vmfault+0x10>
    80001512:	64e2                	ld	s1,24(sp)
    80001514:	6942                	ld	s2,16(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	bf59                	j	800014ae <vmfault+0x10>

000000008000151a <copyout>:
  while (len > 0) {
    8000151a:	c745                	beqz	a4,800015c2 <copyout+0xa8>
{
    8000151c:	7159                	addi	sp,sp,-112
    8000151e:	f486                	sd	ra,104(sp)
    80001520:	f0a2                	sd	s0,96(sp)
    80001522:	eca6                	sd	s1,88(sp)
    80001524:	e0d2                	sd	s4,64(sp)
    80001526:	f85a                	sd	s6,48(sp)
    80001528:	f45e                	sd	s7,40(sp)
    8000152a:	f062                	sd	s8,32(sp)
    8000152c:	e46e                	sd	s11,8(sp)
    8000152e:	1880                	addi	s0,sp,112
    80001530:	8c2a                	mv	s8,a0
    80001532:	8dae                	mv	s11,a1
    80001534:	8b32                	mv	s6,a2
    80001536:	8bb6                	mv	s7,a3
    80001538:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    8000153a:	74fd                	lui	s1,0xfffff
    8000153c:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    8000153e:	57fd                	li	a5,-1
    80001540:	83e9                	srli	a5,a5,0x1a
    80001542:	0897e263          	bltu	a5,s1,800015c6 <copyout+0xac>
    80001546:	e8ca                	sd	s2,80(sp)
    80001548:	e4ce                	sd	s3,72(sp)
    8000154a:	fc56                	sd	s5,56(sp)
    8000154c:	ec66                	sd	s9,24(sp)
    8000154e:	e86a                	sd	s10,16(sp)
    80001550:	6d05                	lui	s10,0x1
    80001552:	8cbe                	mv	s9,a5
    80001554:	a015                	j	80001578 <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001556:	409b0533          	sub	a0,s6,s1
    8000155a:	0009861b          	sext.w	a2,s3
    8000155e:	85de                	mv	a1,s7
    80001560:	954a                	add	a0,a0,s2
    80001562:	f90ff0ef          	jal	80000cf2 <memmove>
    len -= n;
    80001566:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000156a:	9bce                	add	s7,s7,s3
  while (len > 0) {
    8000156c:	040a0463          	beqz	s4,800015b4 <copyout+0x9a>
    if (va0 >= MAXVA)
    80001570:	055ced63          	bltu	s9,s5,800015ca <copyout+0xb0>
    80001574:	84d6                	mv	s1,s5
    80001576:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001578:	85a6                	mv	a1,s1
    8000157a:	8562                	mv	a0,s8
    8000157c:	a2bff0ef          	jal	80000fa6 <walkaddr>
    80001580:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001582:	e909                	bnez	a0,80001594 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001584:	4681                	li	a3,0
    80001586:	8626                	mv	a2,s1
    80001588:	85ee                	mv	a1,s11
    8000158a:	8562                	mv	a0,s8
    8000158c:	f13ff0ef          	jal	8000149e <vmfault>
    80001590:	892a                	mv	s2,a0
    80001592:	c139                	beqz	a0,800015d8 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001594:	4601                	li	a2,0
    80001596:	85a6                	mv	a1,s1
    80001598:	8562                	mv	a0,s8
    8000159a:	973ff0ef          	jal	80000f0c <walk>
    if ((*pte & PTE_W) == 0)
    8000159e:	611c                	ld	a5,0(a0)
    800015a0:	8b91                	andi	a5,a5,4
    800015a2:	c3b1                	beqz	a5,800015e6 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    800015a4:	01a48ab3          	add	s5,s1,s10
    800015a8:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    800015ac:	fb3a75e3          	bgeu	s4,s3,80001556 <copyout+0x3c>
    800015b0:	89d2                	mv	s3,s4
    800015b2:	b755                	j	80001556 <copyout+0x3c>
  return 0;
    800015b4:	4501                	li	a0,0
    800015b6:	6946                	ld	s2,80(sp)
    800015b8:	69a6                	ld	s3,72(sp)
    800015ba:	7ae2                	ld	s5,56(sp)
    800015bc:	6ce2                	ld	s9,24(sp)
    800015be:	6d42                	ld	s10,16(sp)
    800015c0:	a80d                	j	800015f2 <copyout+0xd8>
    800015c2:	4501                	li	a0,0
}
    800015c4:	8082                	ret
      return -1;
    800015c6:	557d                	li	a0,-1
    800015c8:	a02d                	j	800015f2 <copyout+0xd8>
    800015ca:	557d                	li	a0,-1
    800015cc:	6946                	ld	s2,80(sp)
    800015ce:	69a6                	ld	s3,72(sp)
    800015d0:	7ae2                	ld	s5,56(sp)
    800015d2:	6ce2                	ld	s9,24(sp)
    800015d4:	6d42                	ld	s10,16(sp)
    800015d6:	a831                	j	800015f2 <copyout+0xd8>
        return -1;
    800015d8:	557d                	li	a0,-1
    800015da:	6946                	ld	s2,80(sp)
    800015dc:	69a6                	ld	s3,72(sp)
    800015de:	7ae2                	ld	s5,56(sp)
    800015e0:	6ce2                	ld	s9,24(sp)
    800015e2:	6d42                	ld	s10,16(sp)
    800015e4:	a039                	j	800015f2 <copyout+0xd8>
      return -1;
    800015e6:	557d                	li	a0,-1
    800015e8:	6946                	ld	s2,80(sp)
    800015ea:	69a6                	ld	s3,72(sp)
    800015ec:	7ae2                	ld	s5,56(sp)
    800015ee:	6ce2                	ld	s9,24(sp)
    800015f0:	6d42                	ld	s10,16(sp)
}
    800015f2:	70a6                	ld	ra,104(sp)
    800015f4:	7406                	ld	s0,96(sp)
    800015f6:	64e6                	ld	s1,88(sp)
    800015f8:	6a06                	ld	s4,64(sp)
    800015fa:	7b42                	ld	s6,48(sp)
    800015fc:	7ba2                	ld	s7,40(sp)
    800015fe:	7c02                	ld	s8,32(sp)
    80001600:	6da2                	ld	s11,8(sp)
    80001602:	6165                	addi	sp,sp,112
    80001604:	8082                	ret

0000000080001606 <copyin>:
  while (len > 0) {
    80001606:	cb49                	beqz	a4,80001698 <copyin+0x92>
{
    80001608:	711d                	addi	sp,sp,-96
    8000160a:	ec86                	sd	ra,88(sp)
    8000160c:	e8a2                	sd	s0,80(sp)
    8000160e:	e4a6                	sd	s1,72(sp)
    80001610:	e0ca                	sd	s2,64(sp)
    80001612:	fc4e                	sd	s3,56(sp)
    80001614:	f852                	sd	s4,48(sp)
    80001616:	f456                	sd	s5,40(sp)
    80001618:	f05a                	sd	s6,32(sp)
    8000161a:	ec5e                	sd	s7,24(sp)
    8000161c:	e862                	sd	s8,16(sp)
    8000161e:	e466                	sd	s9,8(sp)
    80001620:	1080                	addi	s0,sp,96
    80001622:	8baa                	mv	s7,a0
    80001624:	8cae                	mv	s9,a1
    80001626:	8ab2                	mv	s5,a2
    80001628:	8936                	mv	s2,a3
    8000162a:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    8000162c:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000162e:	6b05                	lui	s6,0x1
    80001630:	a035                	j	8000165c <copyin+0x56>
    80001632:	412984b3          	sub	s1,s3,s2
    80001636:	94da                	add	s1,s1,s6
    if (n > len)
    80001638:	009a7363          	bgeu	s4,s1,8000163e <copyin+0x38>
    8000163c:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000163e:	413905b3          	sub	a1,s2,s3
    80001642:	0004861b          	sext.w	a2,s1
    80001646:	95aa                	add	a1,a1,a0
    80001648:	8556                	mv	a0,s5
    8000164a:	ea8ff0ef          	jal	80000cf2 <memmove>
    len -= n;
    8000164e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001652:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001654:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001658:	020a0263          	beqz	s4,8000167c <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    8000165c:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001660:	85ce                	mv	a1,s3
    80001662:	855e                	mv	a0,s7
    80001664:	943ff0ef          	jal	80000fa6 <walkaddr>
    if (pa0 == 0) {
    80001668:	f569                	bnez	a0,80001632 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    8000166a:	4685                	li	a3,1
    8000166c:	864e                	mv	a2,s3
    8000166e:	85e6                	mv	a1,s9
    80001670:	855e                	mv	a0,s7
    80001672:	e2dff0ef          	jal	8000149e <vmfault>
    80001676:	fd55                	bnez	a0,80001632 <copyin+0x2c>
        return -1;
    80001678:	557d                	li	a0,-1
    8000167a:	a011                	j	8000167e <copyin+0x78>
  return 0;
    8000167c:	4501                	li	a0,0
}
    8000167e:	60e6                	ld	ra,88(sp)
    80001680:	6446                	ld	s0,80(sp)
    80001682:	64a6                	ld	s1,72(sp)
    80001684:	6906                	ld	s2,64(sp)
    80001686:	79e2                	ld	s3,56(sp)
    80001688:	7a42                	ld	s4,48(sp)
    8000168a:	7aa2                	ld	s5,40(sp)
    8000168c:	7b02                	ld	s6,32(sp)
    8000168e:	6be2                	ld	s7,24(sp)
    80001690:	6c42                	ld	s8,16(sp)
    80001692:	6ca2                	ld	s9,8(sp)
    80001694:	6125                	addi	sp,sp,96
    80001696:	8082                	ret
  return 0;
    80001698:	4501                	li	a0,0
}
    8000169a:	8082                	ret

000000008000169c <copyinstr>:
  while (got_null == 0 && max > 0) {
    8000169c:	c371                	beqz	a4,80001760 <copyinstr+0xc4>
{
    8000169e:	715d                	addi	sp,sp,-80
    800016a0:	e486                	sd	ra,72(sp)
    800016a2:	e0a2                	sd	s0,64(sp)
    800016a4:	fc26                	sd	s1,56(sp)
    800016a6:	f84a                	sd	s2,48(sp)
    800016a8:	f44e                	sd	s3,40(sp)
    800016aa:	f052                	sd	s4,32(sp)
    800016ac:	ec56                	sd	s5,24(sp)
    800016ae:	e85a                	sd	s6,16(sp)
    800016b0:	e45e                	sd	s7,8(sp)
    800016b2:	e062                	sd	s8,0(sp)
    800016b4:	0880                	addi	s0,sp,80
    800016b6:	8a2a                	mv	s4,a0
    800016b8:	8b2e                	mv	s6,a1
    800016ba:	8bb2                	mv	s7,a2
    800016bc:	8c36                	mv	s8,a3
    800016be:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    800016c0:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    800016c2:	6985                	lui	s3,0x1
    800016c4:	a0b1                	j	80001710 <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016c6:	4685                	li	a3,1
    800016c8:	8626                	mv	a2,s1
    800016ca:	85da                	mv	a1,s6
    800016cc:	8552                	mv	a0,s4
    800016ce:	dd1ff0ef          	jal	8000149e <vmfault>
    800016d2:	e531                	bnez	a0,8000171e <copyinstr+0x82>
        return -1;
    800016d4:	557d                	li	a0,-1
    800016d6:	a039                	j	800016e4 <copyinstr+0x48>
        *dst = '\0';
    800016d8:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9f70>
    800016dc:	4785                	li	a5,1
  if (got_null) {
    800016de:	37fd                	addiw	a5,a5,-1
    800016e0:	0007851b          	sext.w	a0,a5
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6c02                	ld	s8,0(sp)
    800016f8:	6161                	addi	sp,sp,80
    800016fa:	8082                	ret
    800016fc:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001700:	972a                	add	a4,a4,a0
      --max;
    80001702:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001706:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    8000170a:	04e58563          	beq	a1,a4,80001754 <copyinstr+0xb8>
{
    8000170e:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    80001710:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    80001714:	85a6                	mv	a1,s1
    80001716:	8552                	mv	a0,s4
    80001718:	88fff0ef          	jal	80000fa6 <walkaddr>
    if (pa0 == 0) {
    8000171c:	d54d                	beqz	a0,800016c6 <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    8000171e:	41848633          	sub	a2,s1,s8
    80001722:	964e                	add	a2,a2,s3
    if (n > max)
    80001724:	00c97363          	bgeu	s2,a2,8000172a <copyinstr+0x8e>
    80001728:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    8000172a:	409c0c33          	sub	s8,s8,s1
    8000172e:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    80001730:	c605                	beqz	a2,80001758 <copyinstr+0xbc>
    80001732:	87de                	mv	a5,s7
    80001734:	855e                	mv	a0,s7
      if (*p == '\0') {
    80001736:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    8000173a:	965e                	add	a2,a2,s7
    8000173c:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000173e:	00f706b3          	add	a3,a4,a5
    80001742:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffd9f70>
    80001746:	dac9                	beqz	a3,800016d8 <copyinstr+0x3c>
        *dst = *p;
    80001748:	00d78023          	sb	a3,0(a5)
      dst++;
    8000174c:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000174e:	fec797e3          	bne	a5,a2,8000173c <copyinstr+0xa0>
    80001752:	b76d                	j	800016fc <copyinstr+0x60>
    80001754:	4781                	li	a5,0
    80001756:	b761                	j	800016de <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    80001758:	6c05                	lui	s8,0x1
    8000175a:	9c26                	add	s8,s8,s1
    8000175c:	87de                	mv	a5,s7
    8000175e:	bf45                	j	8000170e <copyinstr+0x72>
  int got_null = 0;
    80001760:	4781                	li	a5,0
  if (got_null) {
    80001762:	37fd                	addiw	a5,a5,-1
    80001764:	0007851b          	sext.w	a0,a5
}
    80001768:	8082                	ret

000000008000176a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000176a:	7139                	addi	sp,sp,-64
    8000176c:	fc06                	sd	ra,56(sp)
    8000176e:	f822                	sd	s0,48(sp)
    80001770:	f426                	sd	s1,40(sp)
    80001772:	f04a                	sd	s2,32(sp)
    80001774:	ec4e                	sd	s3,24(sp)
    80001776:	e852                	sd	s4,16(sp)
    80001778:	e456                	sd	s5,8(sp)
    8000177a:	e05a                	sd	s6,0(sp)
    8000177c:	0080                	addi	s0,sp,64
    8000177e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001780:	00012497          	auipc	s1,0x12
    80001784:	53048493          	addi	s1,s1,1328 # 80013cb0 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001788:	8b26                	mv	s6,s1
    8000178a:	faaab937          	lui	s2,0xfaaab
    8000178e:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa85a1b>
    80001792:	0932                	slli	s2,s2,0xc
    80001794:	aab90913          	addi	s2,s2,-1365
    80001798:	0932                	slli	s2,s2,0xc
    8000179a:	aab90913          	addi	s2,s2,-1365
    8000179e:	0932                	slli	s2,s2,0xc
    800017a0:	aab90913          	addi	s2,s2,-1365
    800017a4:	040009b7          	lui	s3,0x4000
    800017a8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017aa:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800017ac:	00018a97          	auipc	s5,0x18
    800017b0:	504a8a93          	addi	s5,s5,1284 # 80019cb0 <tickslock>
    char *pa = kalloc();
    800017b4:	b16ff0ef          	jal	80000aca <kalloc>
    800017b8:	862a                	mv	a2,a0
    if (pa == 0)
    800017ba:	cd15                	beqz	a0,800017f6 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    800017bc:	416485b3          	sub	a1,s1,s6
    800017c0:	859d                	srai	a1,a1,0x7
    800017c2:	032585b3          	mul	a1,a1,s2
    800017c6:	2585                	addiw	a1,a1,1
    800017c8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017cc:	4719                	li	a4,6
    800017ce:	6685                	lui	a3,0x1
    800017d0:	40b985b3          	sub	a1,s3,a1
    800017d4:	8552                	mv	a0,s4
    800017d6:	8bfff0ef          	jal	80001094 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017da:	18048493          	addi	s1,s1,384
    800017de:	fd549be3          	bne	s1,s5,800017b4 <proc_mapstacks+0x4a>
  }
}
    800017e2:	70e2                	ld	ra,56(sp)
    800017e4:	7442                	ld	s0,48(sp)
    800017e6:	74a2                	ld	s1,40(sp)
    800017e8:	7902                	ld	s2,32(sp)
    800017ea:	69e2                	ld	s3,24(sp)
    800017ec:	6a42                	ld	s4,16(sp)
    800017ee:	6aa2                	ld	s5,8(sp)
    800017f0:	6b02                	ld	s6,0(sp)
    800017f2:	6121                	addi	sp,sp,64
    800017f4:	8082                	ret
      panic("kalloc");
    800017f6:	00007517          	auipc	a0,0x7
    800017fa:	95250513          	addi	a0,a0,-1710 # 80008148 <etext+0x148>
    800017fe:	ff3fe0ef          	jal	800007f0 <panic>

0000000080001802 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001802:	7139                	addi	sp,sp,-64
    80001804:	fc06                	sd	ra,56(sp)
    80001806:	f822                	sd	s0,48(sp)
    80001808:	f426                	sd	s1,40(sp)
    8000180a:	f04a                	sd	s2,32(sp)
    8000180c:	ec4e                	sd	s3,24(sp)
    8000180e:	e852                	sd	s4,16(sp)
    80001810:	e456                	sd	s5,8(sp)
    80001812:	e05a                	sd	s6,0(sp)
    80001814:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001816:	00007597          	auipc	a1,0x7
    8000181a:	93a58593          	addi	a1,a1,-1734 # 80008150 <etext+0x150>
    8000181e:	00012517          	auipc	a0,0x12
    80001822:	05250513          	addi	a0,a0,82 # 80013870 <pid_lock>
    80001826:	b36ff0ef          	jal	80000b5c <initlock>
  initlock(&wait_lock, "wait_lock");
    8000182a:	00007597          	auipc	a1,0x7
    8000182e:	92e58593          	addi	a1,a1,-1746 # 80008158 <etext+0x158>
    80001832:	00012517          	auipc	a0,0x12
    80001836:	05650513          	addi	a0,a0,86 # 80013888 <wait_lock>
    8000183a:	b22ff0ef          	jal	80000b5c <initlock>
  //initlock(&mlfq_lock, "mlfq_lock");
  for (p = proc; p < &proc[NPROC]; p++) {
    8000183e:	00012497          	auipc	s1,0x12
    80001842:	47248493          	addi	s1,s1,1138 # 80013cb0 <proc>
    initlock(&p->lock, "proc");
    80001846:	00007b17          	auipc	s6,0x7
    8000184a:	922b0b13          	addi	s6,s6,-1758 # 80008168 <etext+0x168>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000184e:	8aa6                	mv	s5,s1
    80001850:	faaab937          	lui	s2,0xfaaab
    80001854:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa85a1b>
    80001858:	0932                	slli	s2,s2,0xc
    8000185a:	aab90913          	addi	s2,s2,-1365
    8000185e:	0932                	slli	s2,s2,0xc
    80001860:	aab90913          	addi	s2,s2,-1365
    80001864:	0932                	slli	s2,s2,0xc
    80001866:	aab90913          	addi	s2,s2,-1365
    8000186a:	040009b7          	lui	s3,0x4000
    8000186e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001870:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001872:	00018a17          	auipc	s4,0x18
    80001876:	43ea0a13          	addi	s4,s4,1086 # 80019cb0 <tickslock>
    initlock(&p->lock, "proc");
    8000187a:	85da                	mv	a1,s6
    8000187c:	8526                	mv	a0,s1
    8000187e:	adeff0ef          	jal	80000b5c <initlock>
    p->state = UNUSED;
    80001882:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001886:	415487b3          	sub	a5,s1,s5
    8000188a:	879d                	srai	a5,a5,0x7
    8000188c:	032787b3          	mul	a5,a5,s2
    80001890:	2785                	addiw	a5,a5,1
    80001892:	00d7979b          	slliw	a5,a5,0xd
    80001896:	40f987b3          	sub	a5,s3,a5
    8000189a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000189c:	18048493          	addi	s1,s1,384
    800018a0:	fd449de3          	bne	s1,s4,8000187a <procinit+0x78>
  }
}
    800018a4:	70e2                	ld	ra,56(sp)
    800018a6:	7442                	ld	s0,48(sp)
    800018a8:	74a2                	ld	s1,40(sp)
    800018aa:	7902                	ld	s2,32(sp)
    800018ac:	69e2                	ld	s3,24(sp)
    800018ae:	6a42                	ld	s4,16(sp)
    800018b0:	6aa2                	ld	s5,8(sp)
    800018b2:	6b02                	ld	s6,0(sp)
    800018b4:	6121                	addi	sp,sp,64
    800018b6:	8082                	ret

00000000800018b8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b8:	1141                	addi	sp,sp,-16
    800018ba:	e422                	sd	s0,8(sp)
    800018bc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    800018be:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018c0:	2501                	sext.w	a0,a0
    800018c2:	6422                	ld	s0,8(sp)
    800018c4:	0141                	addi	sp,sp,16
    800018c6:	8082                	ret

00000000800018c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018c8:	1141                	addi	sp,sp,-16
    800018ca:	e422                	sd	s0,8(sp)
    800018cc:	0800                	addi	s0,sp,16
    800018ce:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018d0:	2781                	sext.w	a5,a5
    800018d2:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d4:	00012517          	auipc	a0,0x12
    800018d8:	fcc50513          	addi	a0,a0,-52 # 800138a0 <cpus>
    800018dc:	953e                	add	a0,a0,a5
    800018de:	6422                	ld	s0,8(sp)
    800018e0:	0141                	addi	sp,sp,16
    800018e2:	8082                	ret

00000000800018e4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018e4:	1101                	addi	sp,sp,-32
    800018e6:	ec06                	sd	ra,24(sp)
    800018e8:	e822                	sd	s0,16(sp)
    800018ea:	e426                	sd	s1,8(sp)
    800018ec:	1000                	addi	s0,sp,32
  push_off();
    800018ee:	aaeff0ef          	jal	80000b9c <push_off>
    800018f2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	079e                	slli	a5,a5,0x7
    800018f8:	00012717          	auipc	a4,0x12
    800018fc:	f7870713          	addi	a4,a4,-136 # 80013870 <pid_lock>
    80001900:	97ba                	add	a5,a5,a4
    80001902:	7b84                	ld	s1,48(a5)
  pop_off();
    80001904:	b0eff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001908:	8526                	mv	a0,s1
    8000190a:	60e2                	ld	ra,24(sp)
    8000190c:	6442                	ld	s0,16(sp)
    8000190e:	64a2                	ld	s1,8(sp)
    80001910:	6105                	addi	sp,sp,32
    80001912:	8082                	ret

0000000080001914 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001914:	7179                	addi	sp,sp,-48
    80001916:	f406                	sd	ra,40(sp)
    80001918:	f022                	sd	s0,32(sp)
    8000191a:	ec26                	sd	s1,24(sp)
    8000191c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000191e:	fc7ff0ef          	jal	800018e4 <myproc>
    80001922:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001924:	b3aff0ef          	jal	80000c5e <release>

  if (first) {
    80001928:	0000a797          	auipc	a5,0xa
    8000192c:	dd87a783          	lw	a5,-552(a5) # 8000b700 <first.1>
    80001930:	cb9d                	beqz	a5,80001966 <forkret+0x52>
    first = 0;
    80001932:	0000a797          	auipc	a5,0xa
    80001936:	dc07a723          	sw	zero,-562(a5) # 8000b700 <first.1>

    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000193a:	4505                	li	a0,1
    8000193c:	2a6020ef          	jal	80003be2 <fsinit>

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001940:	00007517          	auipc	a0,0x7
    80001944:	83050513          	addi	a0,a0,-2000 # 80008170 <etext+0x170>
    80001948:	fca43823          	sd	a0,-48(s0)
    8000194c:	fc043c23          	sd	zero,-40(s0)
    80001950:	fd040593          	addi	a1,s0,-48
    80001954:	4e6030ef          	jal	80004e3a <kexec>
    80001958:	6cbc                	ld	a5,88(s1)
    8000195a:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000195c:	6cbc                	ld	a5,88(s1)
    8000195e:	7bb8                	ld	a4,112(a5)
    80001960:	57fd                	li	a5,-1
    80001962:	02f70d63          	beq	a4,a5,8000199c <forkret+0x88>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001966:	6d5000ef          	jal	8000283a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000196a:	68a8                	ld	a0,80(s1)
    8000196c:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000196e:	04000737          	lui	a4,0x4000
    80001972:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001974:	0732                	slli	a4,a4,0xc
    80001976:	00005797          	auipc	a5,0x5
    8000197a:	72678793          	addi	a5,a5,1830 # 8000709c <userret>
    8000197e:	00005697          	auipc	a3,0x5
    80001982:	68268693          	addi	a3,a3,1666 # 80007000 <_trampoline>
    80001986:	8f95                	sub	a5,a5,a3
    80001988:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000198a:	577d                	li	a4,-1
    8000198c:	177e                	slli	a4,a4,0x3f
    8000198e:	8d59                	or	a0,a0,a4
    80001990:	9782                	jalr	a5
}
    80001992:	70a2                	ld	ra,40(sp)
    80001994:	7402                	ld	s0,32(sp)
    80001996:	64e2                	ld	s1,24(sp)
    80001998:	6145                	addi	sp,sp,48
    8000199a:	8082                	ret
      panic("exec");
    8000199c:	00006517          	auipc	a0,0x6
    800019a0:	7dc50513          	addi	a0,a0,2012 # 80008178 <etext+0x178>
    800019a4:	e4dfe0ef          	jal	800007f0 <panic>

00000000800019a8 <allocpid>:
{
    800019a8:	1101                	addi	sp,sp,-32
    800019aa:	ec06                	sd	ra,24(sp)
    800019ac:	e822                	sd	s0,16(sp)
    800019ae:	e426                	sd	s1,8(sp)
    800019b0:	e04a                	sd	s2,0(sp)
    800019b2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019b4:	00012917          	auipc	s2,0x12
    800019b8:	ebc90913          	addi	s2,s2,-324 # 80013870 <pid_lock>
    800019bc:	854a                	mv	a0,s2
    800019be:	a14ff0ef          	jal	80000bd2 <acquire>
  pid = nextpid;
    800019c2:	0000a797          	auipc	a5,0xa
    800019c6:	d4278793          	addi	a5,a5,-702 # 8000b704 <nextpid>
    800019ca:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019cc:	0014871b          	addiw	a4,s1,1
    800019d0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019d2:	854a                	mv	a0,s2
    800019d4:	a8aff0ef          	jal	80000c5e <release>
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6902                	ld	s2,0(sp)
    800019e2:	6105                	addi	sp,sp,32
    800019e4:	8082                	ret

00000000800019e6 <proc_pagetable>:
{
    800019e6:	1101                	addi	sp,sp,-32
    800019e8:	ec06                	sd	ra,24(sp)
    800019ea:	e822                	sd	s0,16(sp)
    800019ec:	e426                	sd	s1,8(sp)
    800019ee:	e04a                	sd	s2,0(sp)
    800019f0:	1000                	addi	s0,sp,32
    800019f2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019f4:	f96ff0ef          	jal	8000118a <uvmcreate>
    800019f8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019fa:	cd05                	beqz	a0,80001a32 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019fc:	4729                	li	a4,10
    800019fe:	00005697          	auipc	a3,0x5
    80001a02:	60268693          	addi	a3,a3,1538 # 80007000 <_trampoline>
    80001a06:	6605                	lui	a2,0x1
    80001a08:	040005b7          	lui	a1,0x4000
    80001a0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a0e:	05b2                	slli	a1,a1,0xc
    80001a10:	dd4ff0ef          	jal	80000fe4 <mappages>
    80001a14:	02054663          	bltz	a0,80001a40 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a18:	4719                	li	a4,6
    80001a1a:	05893683          	ld	a3,88(s2)
    80001a1e:	6605                	lui	a2,0x1
    80001a20:	020005b7          	lui	a1,0x2000
    80001a24:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a26:	05b6                	slli	a1,a1,0xd
    80001a28:	8526                	mv	a0,s1
    80001a2a:	dbaff0ef          	jal	80000fe4 <mappages>
    80001a2e:	00054f63          	bltz	a0,80001a4c <proc_pagetable+0x66>
}
    80001a32:	8526                	mv	a0,s1
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6902                	ld	s2,0(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret
    uvmfree(pagetable, 0);
    80001a40:	4581                	li	a1,0
    80001a42:	8526                	mv	a0,s1
    80001a44:	941ff0ef          	jal	80001384 <uvmfree>
    return 0;
    80001a48:	4481                	li	s1,0
    80001a4a:	b7e5                	j	80001a32 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a4c:	4681                	li	a3,0
    80001a4e:	4605                	li	a2,1
    80001a50:	040005b7          	lui	a1,0x4000
    80001a54:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a56:	05b2                	slli	a1,a1,0xc
    80001a58:	8526                	mv	a0,s1
    80001a5a:	f56ff0ef          	jal	800011b0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a5e:	4581                	li	a1,0
    80001a60:	8526                	mv	a0,s1
    80001a62:	923ff0ef          	jal	80001384 <uvmfree>
    return 0;
    80001a66:	4481                	li	s1,0
    80001a68:	b7e9                	j	80001a32 <proc_pagetable+0x4c>

0000000080001a6a <proc_freepagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	84aa                	mv	s1,a0
    80001a78:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a7a:	4681                	li	a3,0
    80001a7c:	4605                	li	a2,1
    80001a7e:	040005b7          	lui	a1,0x4000
    80001a82:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a84:	05b2                	slli	a1,a1,0xc
    80001a86:	f2aff0ef          	jal	800011b0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a8a:	4681                	li	a3,0
    80001a8c:	4605                	li	a2,1
    80001a8e:	020005b7          	lui	a1,0x2000
    80001a92:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a94:	05b6                	slli	a1,a1,0xd
    80001a96:	8526                	mv	a0,s1
    80001a98:	f18ff0ef          	jal	800011b0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a9c:	85ca                	mv	a1,s2
    80001a9e:	8526                	mv	a0,s1
    80001aa0:	8e5ff0ef          	jal	80001384 <uvmfree>
}
    80001aa4:	60e2                	ld	ra,24(sp)
    80001aa6:	6442                	ld	s0,16(sp)
    80001aa8:	64a2                	ld	s1,8(sp)
    80001aaa:	6902                	ld	s2,0(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret

0000000080001ab0 <freeproc>:
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	1000                	addi	s0,sp,32
    80001aba:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001abc:	6d28                	ld	a0,88(a0)
    80001abe:	c119                	beqz	a0,80001ac4 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001ac0:	f29fe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001ac4:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001ac8:	68a8                	ld	a0,80(s1)
    80001aca:	c501                	beqz	a0,80001ad2 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001acc:	64ac                	ld	a1,72(s1)
    80001ace:	f9dff0ef          	jal	80001a6a <proc_freepagetable>
  p->pagetable = 0;
    80001ad2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ad6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ada:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001ade:	16048823          	sb	zero,368(s1)
  p->chan = 0;
    80001ae2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ae6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001aea:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001aee:	0004ac23          	sw	zero,24(s1)
}
    80001af2:	60e2                	ld	ra,24(sp)
    80001af4:	6442                	ld	s0,16(sp)
    80001af6:	64a2                	ld	s1,8(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret

0000000080001afc <allocproc>:
{
    80001afc:	1101                	addi	sp,sp,-32
    80001afe:	ec06                	sd	ra,24(sp)
    80001b00:	e822                	sd	s0,16(sp)
    80001b02:	e426                	sd	s1,8(sp)
    80001b04:	e04a                	sd	s2,0(sp)
    80001b06:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b08:	00012497          	auipc	s1,0x12
    80001b0c:	1a848493          	addi	s1,s1,424 # 80013cb0 <proc>
    80001b10:	00018917          	auipc	s2,0x18
    80001b14:	1a090913          	addi	s2,s2,416 # 80019cb0 <tickslock>
    acquire(&p->lock);
    80001b18:	8526                	mv	a0,s1
    80001b1a:	8b8ff0ef          	jal	80000bd2 <acquire>
    if (p->state == UNUSED) {
    80001b1e:	4c9c                	lw	a5,24(s1)
    80001b20:	cb91                	beqz	a5,80001b34 <allocproc+0x38>
      release(&p->lock);
    80001b22:	8526                	mv	a0,s1
    80001b24:	93aff0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b28:	18048493          	addi	s1,s1,384
    80001b2c:	ff2496e3          	bne	s1,s2,80001b18 <allocproc+0x1c>
  return 0;
    80001b30:	4481                	li	s1,0
    80001b32:	a08d                	j	80001b94 <allocproc+0x98>
  p->pid = allocpid();
    80001b34:	e75ff0ef          	jal	800019a8 <allocpid>
    80001b38:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b3a:	4785                	li	a5,1
    80001b3c:	cc9c                	sw	a5,24(s1)
  p->trace_mask = 0;
    80001b3e:	1404ac23          	sw	zero,344(s1)
  p->level = 0;
    80001b42:	1404ae23          	sw	zero,348(s1)
  p->ticks_used = 0;
    80001b46:	1604a023          	sw	zero,352(s1)
  p->runticks = 0;
    80001b4a:	1604a223          	sw	zero,356(s1)
  p->nsched = 0;
    80001b4e:	1604a423          	sw	zero,360(s1)
  p->ctime = ticks;
    80001b52:	0000a797          	auipc	a5,0xa
    80001b56:	bfe7a783          	lw	a5,-1026(a5) # 8000b750 <ticks>
    80001b5a:	16f4a623          	sw	a5,364(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b5e:	f6dfe0ef          	jal	80000aca <kalloc>
    80001b62:	892a                	mv	s2,a0
    80001b64:	eca8                	sd	a0,88(s1)
    80001b66:	cd15                	beqz	a0,80001ba2 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001b68:	8526                	mv	a0,s1
    80001b6a:	e7dff0ef          	jal	800019e6 <proc_pagetable>
    80001b6e:	892a                	mv	s2,a0
    80001b70:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b72:	c121                	beqz	a0,80001bb2 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001b74:	07000613          	li	a2,112
    80001b78:	4581                	li	a1,0
    80001b7a:	06048513          	addi	a0,s1,96
    80001b7e:	918ff0ef          	jal	80000c96 <memset>
  p->context.ra = (uint64)forkret;
    80001b82:	00000797          	auipc	a5,0x0
    80001b86:	d9278793          	addi	a5,a5,-622 # 80001914 <forkret>
    80001b8a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b8c:	60bc                	ld	a5,64(s1)
    80001b8e:	6705                	lui	a4,0x1
    80001b90:	97ba                	add	a5,a5,a4
    80001b92:	f4bc                	sd	a5,104(s1)
}
    80001b94:	8526                	mv	a0,s1
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6902                	ld	s2,0(sp)
    80001b9e:	6105                	addi	sp,sp,32
    80001ba0:	8082                	ret
    freeproc(p);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	f0dff0ef          	jal	80001ab0 <freeproc>
    release(&p->lock);
    80001ba8:	8526                	mv	a0,s1
    80001baa:	8b4ff0ef          	jal	80000c5e <release>
    return 0;
    80001bae:	84ca                	mv	s1,s2
    80001bb0:	b7d5                	j	80001b94 <allocproc+0x98>
    freeproc(p);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	efdff0ef          	jal	80001ab0 <freeproc>
    release(&p->lock);
    80001bb8:	8526                	mv	a0,s1
    80001bba:	8a4ff0ef          	jal	80000c5e <release>
    return 0;
    80001bbe:	84ca                	mv	s1,s2
    80001bc0:	bfd1                	j	80001b94 <allocproc+0x98>

0000000080001bc2 <userinit>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bcc:	f31ff0ef          	jal	80001afc <allocproc>
    80001bd0:	84aa                	mv	s1,a0
  initproc = p;
    80001bd2:	0000a797          	auipc	a5,0xa
    80001bd6:	b6a7bb23          	sd	a0,-1162(a5) # 8000b748 <initproc>
  p->cwd = namei("/");
    80001bda:	00006517          	auipc	a0,0x6
    80001bde:	5a650513          	addi	a0,a0,1446 # 80008180 <etext+0x180>
    80001be2:	538020ef          	jal	8000411a <namei>
    80001be6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bea:	478d                	li	a5,3
    80001bec:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	86eff0ef          	jal	80000c5e <release>
}
    80001bf4:	60e2                	ld	ra,24(sp)
    80001bf6:	6442                	ld	s0,16(sp)
    80001bf8:	64a2                	ld	s1,8(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret

0000000080001bfe <growproc>:
{
    80001bfe:	1101                	addi	sp,sp,-32
    80001c00:	ec06                	sd	ra,24(sp)
    80001c02:	e822                	sd	s0,16(sp)
    80001c04:	e426                	sd	s1,8(sp)
    80001c06:	e04a                	sd	s2,0(sp)
    80001c08:	1000                	addi	s0,sp,32
    80001c0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c0c:	cd9ff0ef          	jal	800018e4 <myproc>
    80001c10:	892a                	mv	s2,a0
  sz = p->sz;
    80001c12:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c14:	02905963          	blez	s1,80001c46 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c18:	00b48633          	add	a2,s1,a1
    80001c1c:	020007b7          	lui	a5,0x2000
    80001c20:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c22:	07b6                	slli	a5,a5,0xd
    80001c24:	02c7ea63          	bltu	a5,a2,80001c58 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c28:	4691                	li	a3,4
    80001c2a:	6928                	ld	a0,80(a0)
    80001c2c:	e52ff0ef          	jal	8000127e <uvmalloc>
    80001c30:	85aa                	mv	a1,a0
    80001c32:	c50d                	beqz	a0,80001c5c <growproc+0x5e>
  p->sz = sz;
    80001c34:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c38:	4501                	li	a0,0
}
    80001c3a:	60e2                	ld	ra,24(sp)
    80001c3c:	6442                	ld	s0,16(sp)
    80001c3e:	64a2                	ld	s1,8(sp)
    80001c40:	6902                	ld	s2,0(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret
  } else if (n < 0) {
    80001c46:	fe04d7e3          	bgez	s1,80001c34 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c4a:	00b48633          	add	a2,s1,a1
    80001c4e:	6928                	ld	a0,80(a0)
    80001c50:	deaff0ef          	jal	8000123a <uvmdealloc>
    80001c54:	85aa                	mv	a1,a0
    80001c56:	bff9                	j	80001c34 <growproc+0x36>
      return -1;
    80001c58:	557d                	li	a0,-1
    80001c5a:	b7c5                	j	80001c3a <growproc+0x3c>
      return -1;
    80001c5c:	557d                	li	a0,-1
    80001c5e:	bff1                	j	80001c3a <growproc+0x3c>

0000000080001c60 <kfork>:
{
    80001c60:	7139                	addi	sp,sp,-64
    80001c62:	fc06                	sd	ra,56(sp)
    80001c64:	f822                	sd	s0,48(sp)
    80001c66:	f04a                	sd	s2,32(sp)
    80001c68:	e456                	sd	s5,8(sp)
    80001c6a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c6c:	c79ff0ef          	jal	800018e4 <myproc>
    80001c70:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c72:	e8bff0ef          	jal	80001afc <allocproc>
    80001c76:	0e050e63          	beqz	a0,80001d72 <kfork+0x112>
    80001c7a:	ec4e                	sd	s3,24(sp)
    80001c7c:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c7e:	048ab603          	ld	a2,72(s5)
    80001c82:	692c                	ld	a1,80(a0)
    80001c84:	050ab503          	ld	a0,80(s5)
    80001c88:	f2eff0ef          	jal	800013b6 <uvmcopy>
    80001c8c:	04054e63          	bltz	a0,80001ce8 <kfork+0x88>
    80001c90:	f426                	sd	s1,40(sp)
    80001c92:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c94:	048ab783          	ld	a5,72(s5)
    80001c98:	04f9b423          	sd	a5,72(s3)
  np->trace_mask = p->trace_mask; //inherit tracking
    80001c9c:	158aa783          	lw	a5,344(s5)
    80001ca0:	14f9ac23          	sw	a5,344(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ca4:	058ab683          	ld	a3,88(s5)
    80001ca8:	87b6                	mv	a5,a3
    80001caa:	0589b703          	ld	a4,88(s3)
    80001cae:	12068693          	addi	a3,a3,288
    80001cb2:	0007b803          	ld	a6,0(a5)
    80001cb6:	6788                	ld	a0,8(a5)
    80001cb8:	6b8c                	ld	a1,16(a5)
    80001cba:	6f90                	ld	a2,24(a5)
    80001cbc:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001cc0:	e708                	sd	a0,8(a4)
    80001cc2:	eb0c                	sd	a1,16(a4)
    80001cc4:	ef10                	sd	a2,24(a4)
    80001cc6:	02078793          	addi	a5,a5,32
    80001cca:	02070713          	addi	a4,a4,32
    80001cce:	fed792e3          	bne	a5,a3,80001cb2 <kfork+0x52>
  np->trapframe->a0 = 0;
    80001cd2:	0589b783          	ld	a5,88(s3)
    80001cd6:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001cda:	0d0a8493          	addi	s1,s5,208
    80001cde:	0d098913          	addi	s2,s3,208
    80001ce2:	150a8a13          	addi	s4,s5,336
    80001ce6:	a831                	j	80001d02 <kfork+0xa2>
    freeproc(np);
    80001ce8:	854e                	mv	a0,s3
    80001cea:	dc7ff0ef          	jal	80001ab0 <freeproc>
    release(&np->lock);
    80001cee:	854e                	mv	a0,s3
    80001cf0:	f6ffe0ef          	jal	80000c5e <release>
    return -1;
    80001cf4:	597d                	li	s2,-1
    80001cf6:	69e2                	ld	s3,24(sp)
    80001cf8:	a0b5                	j	80001d64 <kfork+0x104>
  for (i = 0; i < NOFILE; i++)
    80001cfa:	04a1                	addi	s1,s1,8
    80001cfc:	0921                	addi	s2,s2,8
    80001cfe:	01448963          	beq	s1,s4,80001d10 <kfork+0xb0>
    if (p->ofile[i])
    80001d02:	6088                	ld	a0,0(s1)
    80001d04:	d97d                	beqz	a0,80001cfa <kfork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d06:	24f020ef          	jal	80004754 <filedup>
    80001d0a:	00a93023          	sd	a0,0(s2)
    80001d0e:	b7f5                	j	80001cfa <kfork+0x9a>
  np->cwd = idup(p->cwd);
    80001d10:	150ab503          	ld	a0,336(s5)
    80001d14:	35d010ef          	jal	80003870 <idup>
    80001d18:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d1c:	4641                	li	a2,16
    80001d1e:	170a8593          	addi	a1,s5,368
    80001d22:	17098513          	addi	a0,s3,368
    80001d26:	8aeff0ef          	jal	80000dd4 <safestrcpy>
  pid = np->pid;
    80001d2a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001d2e:	854e                	mv	a0,s3
    80001d30:	f2ffe0ef          	jal	80000c5e <release>
  acquire(&wait_lock);
    80001d34:	00012497          	auipc	s1,0x12
    80001d38:	b5448493          	addi	s1,s1,-1196 # 80013888 <wait_lock>
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	e95fe0ef          	jal	80000bd2 <acquire>
  np->parent = p;
    80001d42:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	f17fe0ef          	jal	80000c5e <release>
  acquire(&np->lock);
    80001d4c:	854e                	mv	a0,s3
    80001d4e:	e85fe0ef          	jal	80000bd2 <acquire>
  np->state = RUNNABLE;
    80001d52:	478d                	li	a5,3
    80001d54:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d58:	854e                	mv	a0,s3
    80001d5a:	f05fe0ef          	jal	80000c5e <release>
  return pid;
    80001d5e:	74a2                	ld	s1,40(sp)
    80001d60:	69e2                	ld	s3,24(sp)
    80001d62:	6a42                	ld	s4,16(sp)
}
    80001d64:	854a                	mv	a0,s2
    80001d66:	70e2                	ld	ra,56(sp)
    80001d68:	7442                	ld	s0,48(sp)
    80001d6a:	7902                	ld	s2,32(sp)
    80001d6c:	6aa2                	ld	s5,8(sp)
    80001d6e:	6121                	addi	sp,sp,64
    80001d70:	8082                	ret
    return -1;
    80001d72:	597d                	li	s2,-1
    80001d74:	bfc5                	j	80001d64 <kfork+0x104>

0000000080001d76 <scheduler>:
{
    80001d76:	7119                	addi	sp,sp,-128
    80001d78:	fc86                	sd	ra,120(sp)
    80001d7a:	f8a2                	sd	s0,112(sp)
    80001d7c:	f4a6                	sd	s1,104(sp)
    80001d7e:	f0ca                	sd	s2,96(sp)
    80001d80:	ecce                	sd	s3,88(sp)
    80001d82:	e8d2                	sd	s4,80(sp)
    80001d84:	e4d6                	sd	s5,72(sp)
    80001d86:	e0da                	sd	s6,64(sp)
    80001d88:	fc5e                	sd	s7,56(sp)
    80001d8a:	f862                	sd	s8,48(sp)
    80001d8c:	f466                	sd	s9,40(sp)
    80001d8e:	f06a                	sd	s10,32(sp)
    80001d90:	ec6e                	sd	s11,24(sp)
    80001d92:	0100                	addi	s0,sp,128
    80001d94:	8792                	mv	a5,tp
  int id = r_tp();
    80001d96:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d98:	00779693          	slli	a3,a5,0x7
    80001d9c:	00012717          	auipc	a4,0x12
    80001da0:	ad470713          	addi	a4,a4,-1324 # 80013870 <pid_lock>
    80001da4:	9736                	add	a4,a4,a3
    80001da6:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001daa:	00012717          	auipc	a4,0x12
    80001dae:	afe70713          	addi	a4,a4,-1282 # 800138a8 <cpus+0x8>
    80001db2:	9736                	add	a4,a4,a3
    80001db4:	f8e43423          	sd	a4,-120(s0)
        p = &proc[idx];
    80001db8:	00012b17          	auipc	s6,0x12
    80001dbc:	ef8b0b13          	addi	s6,s6,-264 # 80013cb0 <proc>
        if (p->state == RUNNABLE && p->level == lvl) {
    80001dc0:	4c0d                	li	s8,3
          mlfq_cursor[lvl] = (idx + 1) % NPROC;
    80001dc2:	00012d97          	auipc	s11,0x12
    80001dc6:	aaed8d93          	addi	s11,s11,-1362 # 80013870 <pid_lock>
          c->proc = p;
    80001dca:	00dd87b3          	add	a5,s11,a3
    80001dce:	f8f43023          	sd	a5,-128(s0)
    80001dd2:	a871                	j	80001e6e <scheduler+0xf8>
        release(&p->lock);
    80001dd4:	8556                	mv	a0,s5
    80001dd6:	e89fe0ef          	jal	80000c5e <release>
      for (int i = 0; i < NPROC; i++) {
    80001dda:	2985                	addiw	s3,s3,1
    80001ddc:	0b798763          	beq	s3,s7,80001e8a <scheduler+0x114>
        int idx = (start + i) % NPROC;
    80001de0:	41f9d79b          	sraiw	a5,s3,0x1f
    80001de4:	01a7d79b          	srliw	a5,a5,0x1a
    80001de8:	013784bb          	addw	s1,a5,s3
    80001dec:	03f4f493          	andi	s1,s1,63
    80001df0:	9c9d                	subw	s1,s1,a5
    80001df2:	00048a1b          	sext.w	s4,s1
        p = &proc[idx];
    80001df6:	001a1913          	slli	s2,s4,0x1
    80001dfa:	9952                	add	s2,s2,s4
    80001dfc:	091e                	slli	s2,s2,0x7
    80001dfe:	012b0ab3          	add	s5,s6,s2
        acquire(&p->lock);
    80001e02:	8556                	mv	a0,s5
    80001e04:	dcffe0ef          	jal	80000bd2 <acquire>
        if (p->state == RUNNABLE && p->level == lvl) {
    80001e08:	018aa783          	lw	a5,24(s5)
    80001e0c:	fd8794e3          	bne	a5,s8,80001dd4 <scheduler+0x5e>
    80001e10:	15caa783          	lw	a5,348(s5)
    80001e14:	fd9790e3          	bne	a5,s9,80001dd4 <scheduler+0x5e>
          mlfq_cursor[lvl] = (idx + 1) % NPROC;
    80001e18:	0c8a                	slli	s9,s9,0x2
    80001e1a:	9cee                	add	s9,s9,s11
    80001e1c:	2485                	addiw	s1,s1,1
    80001e1e:	41f4d71b          	sraiw	a4,s1,0x1f
    80001e22:	01a7571b          	srliw	a4,a4,0x1a
    80001e26:	9cb9                	addw	s1,s1,a4
    80001e28:	03f4f793          	andi	a5,s1,63
    80001e2c:	9f99                	subw	a5,a5,a4
    80001e2e:	42fca823          	sw	a5,1072(s9)
          p->state = RUNNING;
    80001e32:	4691                	li	a3,4
    80001e34:	00daac23          	sw	a3,24(s5)
          p->nsched++;
    80001e38:	168aa783          	lw	a5,360(s5)
    80001e3c:	2785                	addiw	a5,a5,1
    80001e3e:	16faa423          	sw	a5,360(s5)
          c->proc = p;
    80001e42:	f8043483          	ld	s1,-128(s0)
    80001e46:	0354b823          	sd	s5,48(s1)
          swtch(&c->context, &p->context);
    80001e4a:	06090593          	addi	a1,s2,96
    80001e4e:	95da                	add	a1,a1,s6
    80001e50:	f8843503          	ld	a0,-120(s0)
    80001e54:	141000ef          	jal	80002794 <swtch>
    80001e58:	8792                	mv	a5,tp
          mycpu()->intena = 0;
    80001e5a:	2781                	sext.w	a5,a5
    80001e5c:	079e                	slli	a5,a5,0x7
    80001e5e:	97ee                	add	a5,a5,s11
    80001e60:	0a07a623          	sw	zero,172(a5)
          c->proc = 0;
    80001e64:	0204b823          	sd	zero,48(s1)
          release(&p->lock);
    80001e68:	8556                	mv	a0,s5
    80001e6a:	df5fe0ef          	jal	80000c5e <release>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001e6e:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001e72:	10017073          	csrci	sstatus,2
    for (int lvl = 0; lvl < 4; lvl++) {
    80001e76:	00012d17          	auipc	s10,0x12
    80001e7a:	e2ad0d13          	addi	s10,s10,-470 # 80013ca0 <mlfq_cursor>
    80001e7e:	4c81                	li	s9,0
      for (int i = 0; i < NPROC; i++) {
    80001e80:	000d2983          	lw	s3,0(s10)
    80001e84:	04098b9b          	addiw	s7,s3,64
    80001e88:	bfa1                	j	80001de0 <scheduler+0x6a>
    for (int lvl = 0; lvl < 4; lvl++) {
    80001e8a:	2c85                	addiw	s9,s9,1
    80001e8c:	0d11                	addi	s10,s10,4
    80001e8e:	4791                	li	a5,4
    80001e90:	fefc98e3          	bne	s9,a5,80001e80 <scheduler+0x10a>
    { asm volatile("wfi"); }
    80001e94:	10500073          	wfi
    80001e98:	bfd9                	j	80001e6e <scheduler+0xf8>

0000000080001e9a <sched>:
{
    80001e9a:	7179                	addi	sp,sp,-48
    80001e9c:	f406                	sd	ra,40(sp)
    80001e9e:	f022                	sd	s0,32(sp)
    80001ea0:	ec26                	sd	s1,24(sp)
    80001ea2:	e84a                	sd	s2,16(sp)
    80001ea4:	e44e                	sd	s3,8(sp)
    80001ea6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ea8:	a3dff0ef          	jal	800018e4 <myproc>
    80001eac:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001eae:	cc5fe0ef          	jal	80000b72 <holding>
    80001eb2:	c92d                	beqz	a0,80001f24 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001eb4:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eb6:	2781                	sext.w	a5,a5
    80001eb8:	079e                	slli	a5,a5,0x7
    80001eba:	00012717          	auipc	a4,0x12
    80001ebe:	9b670713          	addi	a4,a4,-1610 # 80013870 <pid_lock>
    80001ec2:	97ba                	add	a5,a5,a4
    80001ec4:	0a87a703          	lw	a4,168(a5)
    80001ec8:	4785                	li	a5,1
    80001eca:	06f71363          	bne	a4,a5,80001f30 <sched+0x96>
  if (p->state == RUNNING)
    80001ece:	4c98                	lw	a4,24(s1)
    80001ed0:	4791                	li	a5,4
    80001ed2:	06f70563          	beq	a4,a5,80001f3c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001ed6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eda:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001edc:	e7b5                	bnez	a5,80001f48 <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001ede:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ee0:	00012917          	auipc	s2,0x12
    80001ee4:	99090913          	addi	s2,s2,-1648 # 80013870 <pid_lock>
    80001ee8:	2781                	sext.w	a5,a5
    80001eea:	079e                	slli	a5,a5,0x7
    80001eec:	97ca                	add	a5,a5,s2
    80001eee:	0ac7a983          	lw	s3,172(a5)
    80001ef2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ef4:	2781                	sext.w	a5,a5
    80001ef6:	079e                	slli	a5,a5,0x7
    80001ef8:	00012597          	auipc	a1,0x12
    80001efc:	9b058593          	addi	a1,a1,-1616 # 800138a8 <cpus+0x8>
    80001f00:	95be                	add	a1,a1,a5
    80001f02:	06048513          	addi	a0,s1,96
    80001f06:	08f000ef          	jal	80002794 <swtch>
    80001f0a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f0c:	2781                	sext.w	a5,a5
    80001f0e:	079e                	slli	a5,a5,0x7
    80001f10:	993e                	add	s2,s2,a5
    80001f12:	0b392623          	sw	s3,172(s2)
}
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret
    panic("sched p->lock");
    80001f24:	00006517          	auipc	a0,0x6
    80001f28:	26450513          	addi	a0,a0,612 # 80008188 <etext+0x188>
    80001f2c:	8c5fe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001f30:	00006517          	auipc	a0,0x6
    80001f34:	26850513          	addi	a0,a0,616 # 80008198 <etext+0x198>
    80001f38:	8b9fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001f3c:	00006517          	auipc	a0,0x6
    80001f40:	26c50513          	addi	a0,a0,620 # 800081a8 <etext+0x1a8>
    80001f44:	8adfe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001f48:	00006517          	auipc	a0,0x6
    80001f4c:	27050513          	addi	a0,a0,624 # 800081b8 <etext+0x1b8>
    80001f50:	8a1fe0ef          	jal	800007f0 <panic>

0000000080001f54 <yield>:
{
    80001f54:	1101                	addi	sp,sp,-32
    80001f56:	ec06                	sd	ra,24(sp)
    80001f58:	e822                	sd	s0,16(sp)
    80001f5a:	e426                	sd	s1,8(sp)
    80001f5c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f5e:	987ff0ef          	jal	800018e4 <myproc>
    80001f62:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f64:	c6ffe0ef          	jal	80000bd2 <acquire>
  p->state = RUNNABLE;
    80001f68:	478d                	li	a5,3
    80001f6a:	cc9c                	sw	a5,24(s1)
  sched();
    80001f6c:	f2fff0ef          	jal	80001e9a <sched>
  release(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	cedfe0ef          	jal	80000c5e <release>
}
    80001f76:	60e2                	ld	ra,24(sp)
    80001f78:	6442                	ld	s0,16(sp)
    80001f7a:	64a2                	ld	s1,8(sp)
    80001f7c:	6105                	addi	sp,sp,32
    80001f7e:	8082                	ret

0000000080001f80 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001f80:	1101                	addi	sp,sp,-32
    80001f82:	ec06                	sd	ra,24(sp)
    80001f84:	e822                	sd	s0,16(sp)
    80001f86:	e426                	sd	s1,8(sp)
    80001f88:	e04a                	sd	s2,0(sp)
    80001f8a:	1000                	addi	s0,sp,32
    80001f8c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f8e:	957ff0ef          	jal	800018e4 <myproc>
    80001f92:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001f94:	c3ffe0ef          	jal	80000bd2 <acquire>
  if (chan == 0)
    80001f98:	cc81                	beqz	s1,80001fb0 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001f9a:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	cbffe0ef          	jal	80000c5e <release>
}
    80001fa4:	60e2                	ld	ra,24(sp)
    80001fa6:	6442                	ld	s0,16(sp)
    80001fa8:	64a2                	ld	s1,8(sp)
    80001faa:	6902                	ld	s2,0(sp)
    80001fac:	6105                	addi	sp,sp,32
    80001fae:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001fb0:	00006517          	auipc	a0,0x6
    80001fb4:	22050513          	addi	a0,a0,544 # 800081d0 <etext+0x1d0>
    80001fb8:	839fe0ef          	jal	800007f0 <panic>

0000000080001fbc <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001fbc:	1101                	addi	sp,sp,-32
    80001fbe:	ec06                	sd	ra,24(sp)
    80001fc0:	e822                	sd	s0,16(sp)
    80001fc2:	e426                	sd	s1,8(sp)
    80001fc4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fc6:	91fff0ef          	jal	800018e4 <myproc>
    80001fca:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001fcc:	c07fe0ef          	jal	80000bd2 <acquire>
  if (p->chan != 0) {
    80001fd0:	709c                	ld	a5,32(s1)
    80001fd2:	c789                	beqz	a5,80001fdc <sleep+0x20>
    p->state = SLEEPING;
    80001fd4:	4789                	li	a5,2
    80001fd6:	cc9c                	sw	a5,24(s1)
    sched();
    80001fd8:	ec3ff0ef          	jal	80001e9a <sched>
  }
  release(&p->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	c81fe0ef          	jal	80000c5e <release>
}
    80001fe2:	60e2                	ld	ra,24(sp)
    80001fe4:	6442                	ld	s0,16(sp)
    80001fe6:	64a2                	ld	s1,8(sp)
    80001fe8:	6105                	addi	sp,sp,32
    80001fea:	8082                	ret

0000000080001fec <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001fec:	7139                	addi	sp,sp,-64
    80001fee:	fc06                	sd	ra,56(sp)
    80001ff0:	f822                	sd	s0,48(sp)
    80001ff2:	f426                	sd	s1,40(sp)
    80001ff4:	f04a                	sd	s2,32(sp)
    80001ff6:	ec4e                	sd	s3,24(sp)
    80001ff8:	e852                	sd	s4,16(sp)
    80001ffa:	e456                	sd	s5,8(sp)
    80001ffc:	0080                	addi	s0,sp,64
    80001ffe:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002000:	00012497          	auipc	s1,0x12
    80002004:	cb048493          	addi	s1,s1,-848 # 80013cb0 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80002008:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000200a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000200c:	00018997          	auipc	s3,0x18
    80002010:	ca498993          	addi	s3,s3,-860 # 80019cb0 <tickslock>
    80002014:	a801                	j	80002024 <wakeup+0x38>
      }
    }
    release(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	c47fe0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000201c:	18048493          	addi	s1,s1,384
    80002020:	03348063          	beq	s1,s3,80002040 <wakeup+0x54>
    acquire(&p->lock);
    80002024:	8526                	mv	a0,s1
    80002026:	badfe0ef          	jal	80000bd2 <acquire>
    if (p->chan == chan) {
    8000202a:	709c                	ld	a5,32(s1)
    8000202c:	ff2795e3          	bne	a5,s2,80002016 <wakeup+0x2a>
      p->chan = 0;
    80002030:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80002034:	4c9c                	lw	a5,24(s1)
    80002036:	ff4790e3          	bne	a5,s4,80002016 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000203a:	0154ac23          	sw	s5,24(s1)
    8000203e:	bfe1                	j	80002016 <wakeup+0x2a>
  }
}
    80002040:	70e2                	ld	ra,56(sp)
    80002042:	7442                	ld	s0,48(sp)
    80002044:	74a2                	ld	s1,40(sp)
    80002046:	7902                	ld	s2,32(sp)
    80002048:	69e2                	ld	s3,24(sp)
    8000204a:	6a42                	ld	s4,16(sp)
    8000204c:	6aa2                	ld	s5,8(sp)
    8000204e:	6121                	addi	sp,sp,64
    80002050:	8082                	ret

0000000080002052 <reparent>:
{
    80002052:	7179                	addi	sp,sp,-48
    80002054:	f406                	sd	ra,40(sp)
    80002056:	f022                	sd	s0,32(sp)
    80002058:	ec26                	sd	s1,24(sp)
    8000205a:	e84a                	sd	s2,16(sp)
    8000205c:	e44e                	sd	s3,8(sp)
    8000205e:	e052                	sd	s4,0(sp)
    80002060:	1800                	addi	s0,sp,48
    80002062:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002064:	00012497          	auipc	s1,0x12
    80002068:	c4c48493          	addi	s1,s1,-948 # 80013cb0 <proc>
      pp->parent = initproc;
    8000206c:	00009a17          	auipc	s4,0x9
    80002070:	6dca0a13          	addi	s4,s4,1756 # 8000b748 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002074:	00018997          	auipc	s3,0x18
    80002078:	c3c98993          	addi	s3,s3,-964 # 80019cb0 <tickslock>
    8000207c:	a029                	j	80002086 <reparent+0x34>
    8000207e:	18048493          	addi	s1,s1,384
    80002082:	01348b63          	beq	s1,s3,80002098 <reparent+0x46>
    if (pp->parent == p) {
    80002086:	7c9c                	ld	a5,56(s1)
    80002088:	ff279be3          	bne	a5,s2,8000207e <reparent+0x2c>
      pp->parent = initproc;
    8000208c:	000a3503          	ld	a0,0(s4)
    80002090:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002092:	f5bff0ef          	jal	80001fec <wakeup>
    80002096:	b7e5                	j	8000207e <reparent+0x2c>
}
    80002098:	70a2                	ld	ra,40(sp)
    8000209a:	7402                	ld	s0,32(sp)
    8000209c:	64e2                	ld	s1,24(sp)
    8000209e:	6942                	ld	s2,16(sp)
    800020a0:	69a2                	ld	s3,8(sp)
    800020a2:	6a02                	ld	s4,0(sp)
    800020a4:	6145                	addi	sp,sp,48
    800020a6:	8082                	ret

00000000800020a8 <kexit>:
{
    800020a8:	7179                	addi	sp,sp,-48
    800020aa:	f406                	sd	ra,40(sp)
    800020ac:	f022                	sd	s0,32(sp)
    800020ae:	ec26                	sd	s1,24(sp)
    800020b0:	e84a                	sd	s2,16(sp)
    800020b2:	e44e                	sd	s3,8(sp)
    800020b4:	e052                	sd	s4,0(sp)
    800020b6:	1800                	addi	s0,sp,48
    800020b8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020ba:	82bff0ef          	jal	800018e4 <myproc>
    800020be:	89aa                	mv	s3,a0
  if (p == initproc)
    800020c0:	00009797          	auipc	a5,0x9
    800020c4:	6887b783          	ld	a5,1672(a5) # 8000b748 <initproc>
    800020c8:	0d050493          	addi	s1,a0,208
    800020cc:	15050913          	addi	s2,a0,336
    800020d0:	00a79f63          	bne	a5,a0,800020ee <kexit+0x46>
    panic("init exiting");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	11c50513          	addi	a0,a0,284 # 800081f0 <etext+0x1f0>
    800020dc:	f14fe0ef          	jal	800007f0 <panic>
      fileclose(f);
    800020e0:	6ba020ef          	jal	8000479a <fileclose>
      p->ofile[fd] = 0;
    800020e4:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    800020e8:	04a1                	addi	s1,s1,8
    800020ea:	01248563          	beq	s1,s2,800020f4 <kexit+0x4c>
    if (p->ofile[fd]) {
    800020ee:	6088                	ld	a0,0(s1)
    800020f0:	f965                	bnez	a0,800020e0 <kexit+0x38>
    800020f2:	bfdd                	j	800020e8 <kexit+0x40>
  begin_op();
    800020f4:	1fa020ef          	jal	800042ee <begin_op>
  iput(p->cwd);
    800020f8:	1509b503          	ld	a0,336(s3)
    800020fc:	12d010ef          	jal	80003a28 <iput>
  end_op();
    80002100:	274020ef          	jal	80004374 <end_op>
  p->cwd = 0;
    80002104:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002108:	00011497          	auipc	s1,0x11
    8000210c:	78048493          	addi	s1,s1,1920 # 80013888 <wait_lock>
    80002110:	8526                	mv	a0,s1
    80002112:	ac1fe0ef          	jal	80000bd2 <acquire>
  reparent(p);
    80002116:	854e                	mv	a0,s3
    80002118:	f3bff0ef          	jal	80002052 <reparent>
  wakeup(p->parent);
    8000211c:	0389b503          	ld	a0,56(s3)
    80002120:	ecdff0ef          	jal	80001fec <wakeup>
  acquire(&p->lock);
    80002124:	854e                	mv	a0,s3
    80002126:	aadfe0ef          	jal	80000bd2 <acquire>
  p->xstate = status;
    8000212a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000212e:	4795                	li	a5,5
    80002130:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002134:	8526                	mv	a0,s1
    80002136:	b29fe0ef          	jal	80000c5e <release>
  sched();
    8000213a:	d61ff0ef          	jal	80001e9a <sched>
  panic("zombie exit");
    8000213e:	00006517          	auipc	a0,0x6
    80002142:	0c250513          	addi	a0,a0,194 # 80008200 <etext+0x200>
    80002146:	eaafe0ef          	jal	800007f0 <panic>

000000008000214a <kkill>:
int
kkill(int pid)
{
  struct proc *p;

  if (pid == 0)
    8000214a:	c525                	beqz	a0,800021b2 <kkill+0x68>
{
    8000214c:	7179                	addi	sp,sp,-48
    8000214e:	f406                	sd	ra,40(sp)
    80002150:	f022                	sd	s0,32(sp)
    80002152:	ec26                	sd	s1,24(sp)
    80002154:	e84a                	sd	s2,16(sp)
    80002156:	e44e                	sd	s3,8(sp)
    80002158:	1800                	addi	s0,sp,48
    8000215a:	892a                	mv	s2,a0
    return -1;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000215c:	00012497          	auipc	s1,0x12
    80002160:	b5448493          	addi	s1,s1,-1196 # 80013cb0 <proc>
    80002164:	00018997          	auipc	s3,0x18
    80002168:	b4c98993          	addi	s3,s3,-1204 # 80019cb0 <tickslock>
    acquire(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	a65fe0ef          	jal	80000bd2 <acquire>
    if (p->pid == pid) {
    80002172:	589c                	lw	a5,48(s1)
    80002174:	01278b63          	beq	a5,s2,8000218a <kkill+0x40>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	ae5fe0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000217e:	18048493          	addi	s1,s1,384
    80002182:	ff3495e3          	bne	s1,s3,8000216c <kkill+0x22>
  }
  return -1;
    80002186:	557d                	li	a0,-1
    80002188:	a819                	j	8000219e <kkill+0x54>
      p->killed = 1;
    8000218a:	4785                	li	a5,1
    8000218c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000218e:	4c98                	lw	a4,24(s1)
    80002190:	4789                	li	a5,2
    80002192:	00f70d63          	beq	a4,a5,800021ac <kkill+0x62>
      release(&p->lock);
    80002196:	8526                	mv	a0,s1
    80002198:	ac7fe0ef          	jal	80000c5e <release>
      return 0;
    8000219c:	4501                	li	a0,0
}
    8000219e:	70a2                	ld	ra,40(sp)
    800021a0:	7402                	ld	s0,32(sp)
    800021a2:	64e2                	ld	s1,24(sp)
    800021a4:	6942                	ld	s2,16(sp)
    800021a6:	69a2                	ld	s3,8(sp)
    800021a8:	6145                	addi	sp,sp,48
    800021aa:	8082                	ret
        p->state = RUNNABLE;
    800021ac:	478d                	li	a5,3
    800021ae:	cc9c                	sw	a5,24(s1)
    800021b0:	b7dd                	j	80002196 <kkill+0x4c>
    return -1;
    800021b2:	557d                	li	a0,-1
}
    800021b4:	8082                	ret

00000000800021b6 <setkilled>:

void
setkilled(struct proc *p)
{
    800021b6:	1101                	addi	sp,sp,-32
    800021b8:	ec06                	sd	ra,24(sp)
    800021ba:	e822                	sd	s0,16(sp)
    800021bc:	e426                	sd	s1,8(sp)
    800021be:	1000                	addi	s0,sp,32
    800021c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021c2:	a11fe0ef          	jal	80000bd2 <acquire>
  p->killed = 1;
    800021c6:	4785                	li	a5,1
    800021c8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	a93fe0ef          	jal	80000c5e <release>
}
    800021d0:	60e2                	ld	ra,24(sp)
    800021d2:	6442                	ld	s0,16(sp)
    800021d4:	64a2                	ld	s1,8(sp)
    800021d6:	6105                	addi	sp,sp,32
    800021d8:	8082                	ret

00000000800021da <killed>:

int
killed(struct proc *p)
{
    800021da:	1101                	addi	sp,sp,-32
    800021dc:	ec06                	sd	ra,24(sp)
    800021de:	e822                	sd	s0,16(sp)
    800021e0:	e426                	sd	s1,8(sp)
    800021e2:	e04a                	sd	s2,0(sp)
    800021e4:	1000                	addi	s0,sp,32
    800021e6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021e8:	9ebfe0ef          	jal	80000bd2 <acquire>
  k = p->killed;
    800021ec:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	a6dfe0ef          	jal	80000c5e <release>
  return k;
}
    800021f6:	854a                	mv	a0,s2
    800021f8:	60e2                	ld	ra,24(sp)
    800021fa:	6442                	ld	s0,16(sp)
    800021fc:	64a2                	ld	s1,8(sp)
    800021fe:	6902                	ld	s2,0(sp)
    80002200:	6105                	addi	sp,sp,32
    80002202:	8082                	ret

0000000080002204 <kwait>:
{
    80002204:	715d                	addi	sp,sp,-80
    80002206:	e486                	sd	ra,72(sp)
    80002208:	e0a2                	sd	s0,64(sp)
    8000220a:	fc26                	sd	s1,56(sp)
    8000220c:	f84a                	sd	s2,48(sp)
    8000220e:	f44e                	sd	s3,40(sp)
    80002210:	f052                	sd	s4,32(sp)
    80002212:	ec56                	sd	s5,24(sp)
    80002214:	e85a                	sd	s6,16(sp)
    80002216:	e45e                	sd	s7,8(sp)
    80002218:	e062                	sd	s8,0(sp)
    8000221a:	0880                	addi	s0,sp,80
    8000221c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000221e:	ec6ff0ef          	jal	800018e4 <myproc>
    80002222:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002224:	00011517          	auipc	a0,0x11
    80002228:	66450513          	addi	a0,a0,1636 # 80013888 <wait_lock>
    8000222c:	9a7fe0ef          	jal	80000bd2 <acquire>
    havekids = 0;
    80002230:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    80002232:	4a15                	li	s4,5
        havekids = 1;
    80002234:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002236:	00018997          	auipc	s3,0x18
    8000223a:	a7a98993          	addi	s3,s3,-1414 # 80019cb0 <tickslock>
    release(&wait_lock);
    8000223e:	00011b97          	auipc	s7,0x11
    80002242:	64ab8b93          	addi	s7,s7,1610 # 80013888 <wait_lock>
    80002246:	a84d                	j	800022f8 <kwait+0xf4>
          pid = pp->pid;
    80002248:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000224c:	000b0e63          	beqz	s6,80002268 <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002250:	4711                	li	a4,4
    80002252:	02c48693          	addi	a3,s1,44
    80002256:	865a                	mv	a2,s6
    80002258:	04893583          	ld	a1,72(s2)
    8000225c:	05093503          	ld	a0,80(s2)
    80002260:	abaff0ef          	jal	8000151a <copyout>
          if (addr != 0 &&
    80002264:	02054d63          	bltz	a0,8000229e <kwait+0x9a>
          pp->parent = 0;
    80002268:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000226c:	8526                	mv	a0,s1
    8000226e:	843ff0ef          	jal	80001ab0 <freeproc>
          release(&pp->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	9ebfe0ef          	jal	80000c5e <release>
          release(&wait_lock);
    80002278:	00011517          	auipc	a0,0x11
    8000227c:	61050513          	addi	a0,a0,1552 # 80013888 <wait_lock>
    80002280:	9dffe0ef          	jal	80000c5e <release>
}
    80002284:	854e                	mv	a0,s3
    80002286:	60a6                	ld	ra,72(sp)
    80002288:	6406                	ld	s0,64(sp)
    8000228a:	74e2                	ld	s1,56(sp)
    8000228c:	7942                	ld	s2,48(sp)
    8000228e:	79a2                	ld	s3,40(sp)
    80002290:	7a02                	ld	s4,32(sp)
    80002292:	6ae2                	ld	s5,24(sp)
    80002294:	6b42                	ld	s6,16(sp)
    80002296:	6ba2                	ld	s7,8(sp)
    80002298:	6c02                	ld	s8,0(sp)
    8000229a:	6161                	addi	sp,sp,80
    8000229c:	8082                	ret
            release(&pp->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	9bffe0ef          	jal	80000c5e <release>
            release(&wait_lock);
    800022a4:	00011517          	auipc	a0,0x11
    800022a8:	5e450513          	addi	a0,a0,1508 # 80013888 <wait_lock>
    800022ac:	9b3fe0ef          	jal	80000c5e <release>
            return -1;
    800022b0:	59fd                	li	s3,-1
    800022b2:	bfc9                	j	80002284 <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022b4:	18048493          	addi	s1,s1,384
    800022b8:	03348063          	beq	s1,s3,800022d8 <kwait+0xd4>
      if (pp->parent == p) {
    800022bc:	7c9c                	ld	a5,56(s1)
    800022be:	ff279be3          	bne	a5,s2,800022b4 <kwait+0xb0>
        acquire(&pp->lock);
    800022c2:	8526                	mv	a0,s1
    800022c4:	90ffe0ef          	jal	80000bd2 <acquire>
        if (pp->state == ZOMBIE) {
    800022c8:	4c9c                	lw	a5,24(s1)
    800022ca:	f7478fe3          	beq	a5,s4,80002248 <kwait+0x44>
        release(&pp->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	98ffe0ef          	jal	80000c5e <release>
        havekids = 1;
    800022d4:	8756                	mv	a4,s5
    800022d6:	bff9                	j	800022b4 <kwait+0xb0>
    if (!havekids || killed(p)) {
    800022d8:	c715                	beqz	a4,80002304 <kwait+0x100>
    800022da:	854a                	mv	a0,s2
    800022dc:	effff0ef          	jal	800021da <killed>
    800022e0:	e115                	bnez	a0,80002304 <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    800022e2:	854a                	mv	a0,s2
    800022e4:	c9dff0ef          	jal	80001f80 <sleep_prepare>
    release(&wait_lock);
    800022e8:	855e                	mv	a0,s7
    800022ea:	975fe0ef          	jal	80000c5e <release>
    sleep();
    800022ee:	ccfff0ef          	jal	80001fbc <sleep>
    acquire(&wait_lock);
    800022f2:	855e                	mv	a0,s7
    800022f4:	8dffe0ef          	jal	80000bd2 <acquire>
    havekids = 0;
    800022f8:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022fa:	00012497          	auipc	s1,0x12
    800022fe:	9b648493          	addi	s1,s1,-1610 # 80013cb0 <proc>
    80002302:	bf6d                	j	800022bc <kwait+0xb8>
      release(&wait_lock);
    80002304:	00011517          	auipc	a0,0x11
    80002308:	58450513          	addi	a0,a0,1412 # 80013888 <wait_lock>
    8000230c:	953fe0ef          	jal	80000c5e <release>
      return -1;
    80002310:	59fd                	li	s3,-1
    80002312:	bf8d                	j	80002284 <kwait+0x80>

0000000080002314 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002314:	7179                	addi	sp,sp,-48
    80002316:	f406                	sd	ra,40(sp)
    80002318:	f022                	sd	s0,32(sp)
    8000231a:	ec26                	sd	s1,24(sp)
    8000231c:	e84a                	sd	s2,16(sp)
    8000231e:	e44e                	sd	s3,8(sp)
    80002320:	e052                	sd	s4,0(sp)
    80002322:	1800                	addi	s0,sp,48
    80002324:	84aa                	mv	s1,a0
    80002326:	892e                	mv	s2,a1
    80002328:	89b2                	mv	s3,a2
    8000232a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000232c:	db8ff0ef          	jal	800018e4 <myproc>
  if (user_dst) {
    80002330:	c085                	beqz	s1,80002350 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002332:	8752                	mv	a4,s4
    80002334:	86ce                	mv	a3,s3
    80002336:	864a                	mv	a2,s2
    80002338:	652c                	ld	a1,72(a0)
    8000233a:	6928                	ld	a0,80(a0)
    8000233c:	9deff0ef          	jal	8000151a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002340:	70a2                	ld	ra,40(sp)
    80002342:	7402                	ld	s0,32(sp)
    80002344:	64e2                	ld	s1,24(sp)
    80002346:	6942                	ld	s2,16(sp)
    80002348:	69a2                	ld	s3,8(sp)
    8000234a:	6a02                	ld	s4,0(sp)
    8000234c:	6145                	addi	sp,sp,48
    8000234e:	8082                	ret
    memmove((char *)dst, src, len);
    80002350:	000a061b          	sext.w	a2,s4
    80002354:	85ce                	mv	a1,s3
    80002356:	854a                	mv	a0,s2
    80002358:	99bfe0ef          	jal	80000cf2 <memmove>
    return 0;
    8000235c:	8526                	mv	a0,s1
    8000235e:	b7cd                	j	80002340 <either_copyout+0x2c>

0000000080002360 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002360:	7179                	addi	sp,sp,-48
    80002362:	f406                	sd	ra,40(sp)
    80002364:	f022                	sd	s0,32(sp)
    80002366:	ec26                	sd	s1,24(sp)
    80002368:	e84a                	sd	s2,16(sp)
    8000236a:	e44e                	sd	s3,8(sp)
    8000236c:	e052                	sd	s4,0(sp)
    8000236e:	1800                	addi	s0,sp,48
    80002370:	892a                	mv	s2,a0
    80002372:	84ae                	mv	s1,a1
    80002374:	89b2                	mv	s3,a2
    80002376:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002378:	d6cff0ef          	jal	800018e4 <myproc>
  if (user_src) {
    8000237c:	c085                	beqz	s1,8000239c <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000237e:	8752                	mv	a4,s4
    80002380:	86ce                	mv	a3,s3
    80002382:	864a                	mv	a2,s2
    80002384:	652c                	ld	a1,72(a0)
    80002386:	6928                	ld	a0,80(a0)
    80002388:	a7eff0ef          	jal	80001606 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000238c:	70a2                	ld	ra,40(sp)
    8000238e:	7402                	ld	s0,32(sp)
    80002390:	64e2                	ld	s1,24(sp)
    80002392:	6942                	ld	s2,16(sp)
    80002394:	69a2                	ld	s3,8(sp)
    80002396:	6a02                	ld	s4,0(sp)
    80002398:	6145                	addi	sp,sp,48
    8000239a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000239c:	000a061b          	sext.w	a2,s4
    800023a0:	85ce                	mv	a1,s3
    800023a2:	854a                	mv	a0,s2
    800023a4:	94ffe0ef          	jal	80000cf2 <memmove>
    return 0;
    800023a8:	8526                	mv	a0,s1
    800023aa:	b7cd                	j	8000238c <either_copyin+0x2c>

00000000800023ac <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023ac:	715d                	addi	sp,sp,-80
    800023ae:	e486                	sd	ra,72(sp)
    800023b0:	e0a2                	sd	s0,64(sp)
    800023b2:	fc26                	sd	s1,56(sp)
    800023b4:	f84a                	sd	s2,48(sp)
    800023b6:	f44e                	sd	s3,40(sp)
    800023b8:	f052                	sd	s4,32(sp)
    800023ba:	ec56                	sd	s5,24(sp)
    800023bc:	e85a                	sd	s6,16(sp)
    800023be:	e45e                	sd	s7,8(sp)
    800023c0:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800023c2:	00006517          	auipc	a0,0x6
    800023c6:	cd650513          	addi	a0,a0,-810 # 80008098 <etext+0x98>
    800023ca:	940fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023ce:	00012497          	auipc	s1,0x12
    800023d2:	a5248493          	addi	s1,s1,-1454 # 80013e20 <proc+0x170>
    800023d6:	00018917          	auipc	s2,0x18
    800023da:	a4a90913          	addi	s2,s2,-1462 # 80019e20 <bcache+0x158>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023e0:	00006997          	auipc	s3,0x6
    800023e4:	e3098993          	addi	s3,s3,-464 # 80008210 <etext+0x210>
    printk("%d %s %s", p->pid, state, p->name);
    800023e8:	00006a97          	auipc	s5,0x6
    800023ec:	e30a8a93          	addi	s5,s5,-464 # 80008218 <etext+0x218>
    printk("\n");
    800023f0:	00006a17          	auipc	s4,0x6
    800023f4:	ca8a0a13          	addi	s4,s4,-856 # 80008098 <etext+0x98>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f8:	00006b97          	auipc	s7,0x6
    800023fc:	480b8b93          	addi	s7,s7,1152 # 80008878 <states.0>
    80002400:	a829                	j	8000241a <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002402:	ec06a583          	lw	a1,-320(a3)
    80002406:	8556                	mv	a0,s5
    80002408:	902fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000240c:	8552                	mv	a0,s4
    8000240e:	8fcfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002412:	18048493          	addi	s1,s1,384
    80002416:	03248263          	beq	s1,s2,8000243a <procdump+0x8e>
    if (p->state == UNUSED)
    8000241a:	86a6                	mv	a3,s1
    8000241c:	ea84a783          	lw	a5,-344(s1)
    80002420:	dbed                	beqz	a5,80002412 <procdump+0x66>
      state = "???";
    80002422:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002424:	fcfb6fe3          	bltu	s6,a5,80002402 <procdump+0x56>
    80002428:	02079713          	slli	a4,a5,0x20
    8000242c:	01d75793          	srli	a5,a4,0x1d
    80002430:	97de                	add	a5,a5,s7
    80002432:	6390                	ld	a2,0(a5)
    80002434:	f679                	bnez	a2,80002402 <procdump+0x56>
      state = "???";
    80002436:	864e                	mv	a2,s3
    80002438:	b7e9                	j	80002402 <procdump+0x56>
  }
}
    8000243a:	60a6                	ld	ra,72(sp)
    8000243c:	6406                	ld	s0,64(sp)
    8000243e:	74e2                	ld	s1,56(sp)
    80002440:	7942                	ld	s2,48(sp)
    80002442:	79a2                	ld	s3,40(sp)
    80002444:	7a02                	ld	s4,32(sp)
    80002446:	6ae2                	ld	s5,24(sp)
    80002448:	6b42                	ld	s6,16(sp)
    8000244a:	6ba2                	ld	s7,8(sp)
    8000244c:	6161                	addi	sp,sp,80
    8000244e:	8082                	ret

0000000080002450 <count_active_procs>:

uint64
count_active_procs(void)
{
    80002450:	1141                	addi	sp,sp,-16
    80002452:	e422                	sd	s0,8(sp)
    80002454:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    80002456:	4501                	li	a0,0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002458:	00012797          	auipc	a5,0x12
    8000245c:	85878793          	addi	a5,a5,-1960 # 80013cb0 <proc>
    80002460:	00018697          	auipc	a3,0x18
    80002464:	85068693          	addi	a3,a3,-1968 # 80019cb0 <tickslock>
    // No lock is strictly required for an approximate active count here,
    // but we check if the state is not UNUSED.
    if(p->state != UNUSED) {
    80002468:	4f98                	lw	a4,24(a5)
      count++;
    8000246a:	00e03733          	snez	a4,a4
    8000246e:	953a                	add	a0,a0,a4
  for(p = proc; p < &proc[NPROC]; p++) {
    80002470:	18078793          	addi	a5,a5,384
    80002474:	fed79ae3          	bne	a5,a3,80002468 <count_active_procs+0x18>
    }
  }
  return count;
}
    80002478:	6422                	ld	s0,8(sp)
    8000247a:	0141                	addi	sp,sp,16
    8000247c:	8082                	ret

000000008000247e <get_uprocs>:

int
get_uprocs(uint64 buf_addr, int max)
{
    8000247e:	7119                	addi	sp,sp,-128
    80002480:	fc86                	sd	ra,120(sp)
    80002482:	f8a2                	sd	s0,112(sp)
    80002484:	f0ca                	sd	s2,96(sp)
    80002486:	ecce                	sd	s3,88(sp)
    80002488:	e4d6                	sd	s5,72(sp)
    8000248a:	0100                	addi	s0,sp,128
    8000248c:	8aaa                	mv	s5,a0
    8000248e:	89ae                	mv	s3,a1
  struct proc *p;
  struct proc *my_p = myproc();
    80002490:	c54ff0ef          	jal	800018e4 <myproc>
  struct uproc uptr;
  int count = 0;

  if (max < 0) return -1;
    80002494:	0e09c863          	bltz	s3,80002584 <get_uprocs+0x106>
    80002498:	f4a6                	sd	s1,104(sp)
    8000249a:	e8d2                	sd	s4,80(sp)
    8000249c:	e0da                	sd	s6,64(sp)
    8000249e:	fc5e                	sd	s7,56(sp)
    800024a0:	f862                	sd	s8,48(sp)
    800024a2:	8a2a                	mv	s4,a0

  // 1. Acquire wait_lock first per instructions
  acquire(&wait_lock);
    800024a4:	00011517          	auipc	a0,0x11
    800024a8:	3e450513          	addi	a0,a0,996 # 80013888 <wait_lock>
    800024ac:	f26fe0ef          	jal	80000bd2 <acquire>
  int count = 0;
    800024b0:	4901                	li	s2,0

  for(p = proc; p < &proc[NPROC]; p++) {
    800024b2:	00011497          	auipc	s1,0x11
    800024b6:	7fe48493          	addi	s1,s1,2046 # 80013cb0 <proc>
    // 2. Lock the individual process state
    acquire(&p->lock);

    if(p->state != UNUSED) {
      uptr.pid = p->pid;
      uptr.ppid = p->parent ? p->parent->pid : 0;
    800024ba:	4b81                	li	s7,0
      uptr.sz = p->sz;
      safestrcpy(uptr.name, p->name, sizeof(p->name));

      // Release locks before copying data to user space
      release(&p->lock);
      release(&wait_lock);
    800024bc:	00011b17          	auipc	s6,0x11
    800024c0:	3ccb0b13          	addi	s6,s6,972 # 80013888 <wait_lock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024c4:	00017c17          	auipc	s8,0x17
    800024c8:	7ecc0c13          	addi	s8,s8,2028 # 80019cb0 <tickslock>
    800024cc:	a839                	j	800024ea <get_uprocs+0x6c>
      if(count >= max) {
        return count; 
      }

      // Re-acquire locks to safely inspect the next process entry in the table
      acquire(&wait_lock);
    800024ce:	00011517          	auipc	a0,0x11
    800024d2:	3ba50513          	addi	a0,a0,954 # 80013888 <wait_lock>
    800024d6:	efcfe0ef          	jal	80000bd2 <acquire>
      continue;
    800024da:	a021                	j	800024e2 <get_uprocs+0x64>
    }
    release(&p->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	f80fe0ef          	jal	80000c5e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800024e2:	18048493          	addi	s1,s1,384
    800024e6:	09848363          	beq	s1,s8,8000256c <get_uprocs+0xee>
    acquire(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ee6fe0ef          	jal	80000bd2 <acquire>
    if(p->state != UNUSED) {
    800024f0:	4c9c                	lw	a5,24(s1)
    800024f2:	d7ed                	beqz	a5,800024dc <get_uprocs+0x5e>
      uptr.pid = p->pid;
    800024f4:	5898                	lw	a4,48(s1)
    800024f6:	f8e42423          	sw	a4,-120(s0)
      uptr.ppid = p->parent ? p->parent->pid : 0;
    800024fa:	7c94                	ld	a3,56(s1)
    800024fc:	875e                	mv	a4,s7
    800024fe:	c291                	beqz	a3,80002502 <get_uprocs+0x84>
    80002500:	5a98                	lw	a4,48(a3)
    80002502:	f8e42623          	sw	a4,-116(s0)
      uptr.state = p->state;
    80002506:	f8f42823          	sw	a5,-112(s0)
      uptr.sz = p->sz;
    8000250a:	64bc                	ld	a5,72(s1)
    8000250c:	f8f43c23          	sd	a5,-104(s0)
      safestrcpy(uptr.name, p->name, sizeof(p->name));
    80002510:	4641                	li	a2,16
    80002512:	17048593          	addi	a1,s1,368
    80002516:	fa040513          	addi	a0,s0,-96
    8000251a:	8bbfe0ef          	jal	80000dd4 <safestrcpy>
      release(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	f3efe0ef          	jal	80000c5e <release>
      release(&wait_lock);
    80002524:	855a                	mv	a0,s6
    80002526:	f38fe0ef          	jal	80000c5e <release>
      uint64 dst_element_addr = buf_addr + (count * sizeof(struct uproc));
    8000252a:	00291613          	slli	a2,s2,0x2
    8000252e:	964a                	add	a2,a2,s2
    80002530:	060e                	slli	a2,a2,0x3
    80002532:	015605b3          	add	a1,a2,s5
      if(copyout(my_p->pagetable, dst_element_addr, dst_element_addr, (char *)&uptr, sizeof(struct uproc)) < 0) {
    80002536:	02800713          	li	a4,40
    8000253a:	f8840693          	addi	a3,s0,-120
    8000253e:	862e                	mv	a2,a1
    80002540:	050a3503          	ld	a0,80(s4)
    80002544:	fd7fe0ef          	jal	8000151a <copyout>
    80002548:	04054063          	bltz	a0,80002588 <get_uprocs+0x10a>
      count++;
    8000254c:	2905                	addiw	s2,s2,1
      if(count >= max) {
    8000254e:	f93940e3          	blt	s2,s3,800024ce <get_uprocs+0x50>
    80002552:	74a6                	ld	s1,104(sp)
    80002554:	6a46                	ld	s4,80(sp)
    80002556:	6b06                	ld	s6,64(sp)
    80002558:	7be2                	ld	s7,56(sp)
    8000255a:	7c42                	ld	s8,48(sp)
  }
  
  release(&wait_lock);
  return count;
}
    8000255c:	854a                	mv	a0,s2
    8000255e:	70e6                	ld	ra,120(sp)
    80002560:	7446                	ld	s0,112(sp)
    80002562:	7906                	ld	s2,96(sp)
    80002564:	69e6                	ld	s3,88(sp)
    80002566:	6aa6                	ld	s5,72(sp)
    80002568:	6109                	addi	sp,sp,128
    8000256a:	8082                	ret
  release(&wait_lock);
    8000256c:	00011517          	auipc	a0,0x11
    80002570:	31c50513          	addi	a0,a0,796 # 80013888 <wait_lock>
    80002574:	eeafe0ef          	jal	80000c5e <release>
  return count;
    80002578:	74a6                	ld	s1,104(sp)
    8000257a:	6a46                	ld	s4,80(sp)
    8000257c:	6b06                	ld	s6,64(sp)
    8000257e:	7be2                	ld	s7,56(sp)
    80002580:	7c42                	ld	s8,48(sp)
    80002582:	bfe9                	j	8000255c <get_uprocs+0xde>
  if (max < 0) return -1;
    80002584:	597d                	li	s2,-1
    80002586:	bfd9                	j	8000255c <get_uprocs+0xde>
        return -1;
    80002588:	597d                	li	s2,-1
    8000258a:	74a6                	ld	s1,104(sp)
    8000258c:	6a46                	ld	s4,80(sp)
    8000258e:	6b06                	ld	s6,64(sp)
    80002590:	7be2                	ld	s7,56(sp)
    80002592:	7c42                	ld	s8,48(sp)
    80002594:	b7e1                	j	8000255c <get_uprocs+0xde>

0000000080002596 <get_pinfos>:

int
get_pinfos(uint64 buf_addr, int max)
{
    80002596:	7159                	addi	sp,sp,-112
    80002598:	f486                	sd	ra,104(sp)
    8000259a:	f0a2                	sd	s0,96(sp)
    8000259c:	e8ca                	sd	s2,80(sp)
    8000259e:	e4ce                	sd	s3,72(sp)
    800025a0:	fc56                	sd	s5,56(sp)
    800025a2:	1880                	addi	s0,sp,112
    800025a4:	8aaa                	mv	s5,a0
    800025a6:	89ae                	mv	s3,a1
  struct proc *p;
  struct proc *my_p = myproc();
    800025a8:	b3cff0ef          	jal	800018e4 <myproc>
  struct pinfo info;
  int count = 0;

  if (max < 0)
    800025ac:	0a09ce63          	bltz	s3,80002668 <get_pinfos+0xd2>
    800025b0:	eca6                	sd	s1,88(sp)
    800025b2:	e0d2                	sd	s4,64(sp)
    800025b4:	f85a                	sd	s6,48(sp)
    800025b6:	8a2a                	mv	s4,a0
  int count = 0;
    800025b8:	4901                	li	s2,0
    return -1;

  for(p = proc; p < &proc[NPROC]; p++) {
    800025ba:	00011497          	auipc	s1,0x11
    800025be:	6f648493          	addi	s1,s1,1782 # 80013cb0 <proc>
    800025c2:	00017b17          	auipc	s6,0x17
    800025c6:	6eeb0b13          	addi	s6,s6,1774 # 80019cb0 <tickslock>
    800025ca:	a801                	j	800025da <get_pinfos+0x44>
      if(count >= max) {
        return count;
      }
      continue;
    }
    release(&p->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	e90fe0ef          	jal	80000c5e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025d2:	18048493          	addi	s1,s1,384
    800025d6:	09648563          	beq	s1,s6,80002660 <get_pinfos+0xca>
    acquire(&p->lock);
    800025da:	8526                	mv	a0,s1
    800025dc:	df6fe0ef          	jal	80000bd2 <acquire>
    if(p->state != UNUSED) {
    800025e0:	4c9c                	lw	a5,24(s1)
    800025e2:	d7ed                	beqz	a5,800025cc <get_pinfos+0x36>
      info.pid = p->pid;
    800025e4:	5898                	lw	a4,48(s1)
    800025e6:	f8e42c23          	sw	a4,-104(s0)
      info.state = p->state;
    800025ea:	f8f42e23          	sw	a5,-100(s0)
      info.level = p->level;
    800025ee:	15c4a783          	lw	a5,348(s1)
    800025f2:	faf42023          	sw	a5,-96(s0)
      info.runticks = p->runticks;
    800025f6:	1644a783          	lw	a5,356(s1)
    800025fa:	faf42223          	sw	a5,-92(s0)
      info.nsched = p->nsched;
    800025fe:	1684a783          	lw	a5,360(s1)
    80002602:	faf42423          	sw	a5,-88(s0)
      info.ctime = p->ctime;
    80002606:	16c4a783          	lw	a5,364(s1)
    8000260a:	faf42623          	sw	a5,-84(s0)
      safestrcpy(info.name, p->name, sizeof(info.name));
    8000260e:	4641                	li	a2,16
    80002610:	17048593          	addi	a1,s1,368
    80002614:	fb040513          	addi	a0,s0,-80
    80002618:	fbcfe0ef          	jal	80000dd4 <safestrcpy>
      release(&p->lock);
    8000261c:	8526                	mv	a0,s1
    8000261e:	e40fe0ef          	jal	80000c5e <release>
      uint64 dst_addr = buf_addr + (count * sizeof(struct pinfo));
    80002622:	00291613          	slli	a2,s2,0x2
    80002626:	964a                	add	a2,a2,s2
    80002628:	060e                	slli	a2,a2,0x3
    8000262a:	015605b3          	add	a1,a2,s5
      if(copyout(my_p->pagetable, dst_addr, dst_addr, (char *)&info, sizeof(struct pinfo)) < 0) {
    8000262e:	02800713          	li	a4,40
    80002632:	f9840693          	addi	a3,s0,-104
    80002636:	862e                	mv	a2,a1
    80002638:	050a3503          	ld	a0,80(s4)
    8000263c:	edffe0ef          	jal	8000151a <copyout>
    80002640:	02054663          	bltz	a0,8000266c <get_pinfos+0xd6>
      count++;
    80002644:	2905                	addiw	s2,s2,1
      if(count >= max) {
    80002646:	f93946e3          	blt	s2,s3,800025d2 <get_pinfos+0x3c>
    8000264a:	64e6                	ld	s1,88(sp)
    8000264c:	6a06                	ld	s4,64(sp)
    8000264e:	7b42                	ld	s6,48(sp)
  }

  return count;
}
    80002650:	854a                	mv	a0,s2
    80002652:	70a6                	ld	ra,104(sp)
    80002654:	7406                	ld	s0,96(sp)
    80002656:	6946                	ld	s2,80(sp)
    80002658:	69a6                	ld	s3,72(sp)
    8000265a:	7ae2                	ld	s5,56(sp)
    8000265c:	6165                	addi	sp,sp,112
    8000265e:	8082                	ret
    80002660:	64e6                	ld	s1,88(sp)
    80002662:	6a06                	ld	s4,64(sp)
    80002664:	7b42                	ld	s6,48(sp)
    80002666:	b7ed                	j	80002650 <get_pinfos+0xba>
    return -1;
    80002668:	597d                	li	s2,-1
    8000266a:	b7dd                	j	80002650 <get_pinfos+0xba>
        return -1;
    8000266c:	597d                	li	s2,-1
    8000266e:	64e6                	ld	s1,88(sp)
    80002670:	6a06                	ld	s4,64(sp)
    80002672:	7b42                	ld	s6,48(sp)
    80002674:	bff1                	j	80002650 <get_pinfos+0xba>

0000000080002676 <mlfq_tick>:

// Called on each timer tick while p is RUNNING.
// Returns 1 if p should yield the CPU, 0 if it should keep running.
int
mlfq_tick(struct proc *p)
{
    80002676:	7139                	addi	sp,sp,-64
    80002678:	fc06                	sd	ra,56(sp)
    8000267a:	f822                	sd	s0,48(sp)
    8000267c:	f04a                	sd	s2,32(sp)
    8000267e:	e852                	sd	s4,16(sp)
    80002680:	0080                	addi	s0,sp,64
    80002682:	892a                	mv	s2,a0
  int should_yield = 0;
  int current_level;

  acquire(&p->lock);
    80002684:	d4efe0ef          	jal	80000bd2 <acquire>
  p->runticks++;
    80002688:	16492783          	lw	a5,356(s2)
    8000268c:	2785                	addiw	a5,a5,1
    8000268e:	16f92223          	sw	a5,356(s2)
  p->ticks_used++;
    80002692:	16092783          	lw	a5,352(s2)
    80002696:	2785                	addiw	a5,a5,1
    80002698:	0007871b          	sext.w	a4,a5
    8000269c:	16f92023          	sw	a5,352(s2)

  int slice = mlfq_slices[p->level];
    800026a0:	15c92a03          	lw	s4,348(s2)
    800026a4:	002a1693          	slli	a3,s4,0x2
    800026a8:	00006797          	auipc	a5,0x6
    800026ac:	1d078793          	addi	a5,a5,464 # 80008878 <states.0>
    800026b0:	97b6                	add	a5,a5,a3
  if (p->ticks_used >= slice) {
    800026b2:	5b9c                	lw	a5,48(a5)
    800026b4:	06f74463          	blt	a4,a5,8000271c <mlfq_tick+0xa6>
    // Time slice used up: demote (up to level 3), reset used time, and yield
    if (p->level < 3) {
    800026b8:	4789                	li	a5,2
    800026ba:	0147c563          	blt	a5,s4,800026c4 <mlfq_tick+0x4e>
      p->level++;
    800026be:	2a05                	addiw	s4,s4,1
    800026c0:	15492e23          	sw	s4,348(s2)
    }
    p->ticks_used = 0;
    800026c4:	16092023          	sw	zero,352(s2)
    should_yield = 1;
  }
  current_level = p->level;
  release(&p->lock);
    800026c8:	854a                	mv	a0,s2
    800026ca:	d94fe0ef          	jal	80000c5e <release>
    800026ce:	4505                	li	a0,1
      release(&q->lock);
    }
  }

  return should_yield;
}
    800026d0:	70e2                	ld	ra,56(sp)
    800026d2:	7442                	ld	s0,48(sp)
    800026d4:	7902                	ld	s2,32(sp)
    800026d6:	6a42                	ld	s4,16(sp)
    800026d8:	6121                	addi	sp,sp,64
    800026da:	8082                	ret
      release(&q->lock);
    800026dc:	8526                	mv	a0,s1
    800026de:	d80fe0ef          	jal	80000c5e <release>
    for (q = proc; q < &proc[NPROC]; q++) {
    800026e2:	18048493          	addi	s1,s1,384
    800026e6:	03348663          	beq	s1,s3,80002712 <mlfq_tick+0x9c>
      if (q == p) continue;
    800026ea:	fe990ce3          	beq	s2,s1,800026e2 <mlfq_tick+0x6c>
      acquire(&q->lock);
    800026ee:	8526                	mv	a0,s1
    800026f0:	ce2fe0ef          	jal	80000bd2 <acquire>
      if (q->state == RUNNABLE && q->level < current_level) {
    800026f4:	4c9c                	lw	a5,24(s1)
    800026f6:	ff5793e3          	bne	a5,s5,800026dc <mlfq_tick+0x66>
    800026fa:	15c4a783          	lw	a5,348(s1)
    800026fe:	fd47dfe3          	bge	a5,s4,800026dc <mlfq_tick+0x66>
        release(&q->lock);
    80002702:	8526                	mv	a0,s1
    80002704:	d5afe0ef          	jal	80000c5e <release>
        should_yield = 1; // Preempt without resetting p->ticks_used
    80002708:	4505                	li	a0,1
        break;
    8000270a:	74a2                	ld	s1,40(sp)
    8000270c:	69e2                	ld	s3,24(sp)
    8000270e:	6aa2                	ld	s5,8(sp)
    80002710:	b7c1                	j	800026d0 <mlfq_tick+0x5a>
    80002712:	4501                	li	a0,0
    80002714:	74a2                	ld	s1,40(sp)
    80002716:	69e2                	ld	s3,24(sp)
    80002718:	6aa2                	ld	s5,8(sp)
    8000271a:	bf5d                	j	800026d0 <mlfq_tick+0x5a>
    8000271c:	f426                	sd	s1,40(sp)
    8000271e:	ec4e                	sd	s3,24(sp)
    80002720:	e456                	sd	s5,8(sp)
  release(&p->lock);
    80002722:	854a                	mv	a0,s2
    80002724:	d3afe0ef          	jal	80000c5e <release>
    for (q = proc; q < &proc[NPROC]; q++) {
    80002728:	00011497          	auipc	s1,0x11
    8000272c:	58848493          	addi	s1,s1,1416 # 80013cb0 <proc>
      if (q->state == RUNNABLE && q->level < current_level) {
    80002730:	4a8d                	li	s5,3
    for (q = proc; q < &proc[NPROC]; q++) {
    80002732:	00017997          	auipc	s3,0x17
    80002736:	57e98993          	addi	s3,s3,1406 # 80019cb0 <tickslock>
  if (!should_yield && current_level > 0) {
    8000273a:	fb4048e3          	bgtz	s4,800026ea <mlfq_tick+0x74>
    8000273e:	4501                	li	a0,0
  return should_yield;
    80002740:	74a2                	ld	s1,40(sp)
    80002742:	69e2                	ld	s3,24(sp)
    80002744:	6aa2                	ld	s5,8(sp)
    80002746:	b769                	j	800026d0 <mlfq_tick+0x5a>

0000000080002748 <mlfq_boost>:

// Boost all processes to level 0 every 64 global ticks.
// Called from clockintr() where tickslock is already held (matches lock order).
void
mlfq_boost(void)
{
    80002748:	1101                	addi	sp,sp,-32
    8000274a:	ec06                	sd	ra,24(sp)
    8000274c:	e822                	sd	s0,16(sp)
    8000274e:	e426                	sd	s1,8(sp)
    80002750:	e04a                	sd	s2,0(sp)
    80002752:	1000                	addi	s0,sp,32
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++) {
    80002754:	00011497          	auipc	s1,0x11
    80002758:	55c48493          	addi	s1,s1,1372 # 80013cb0 <proc>
    8000275c:	00017917          	auipc	s2,0x17
    80002760:	55490913          	addi	s2,s2,1364 # 80019cb0 <tickslock>
    80002764:	a801                	j	80002774 <mlfq_boost+0x2c>
    acquire(&p->lock);
    if (p->state != UNUSED) {
      p->level = 0;
      p->ticks_used = 0;
    }
    release(&p->lock);
    80002766:	8526                	mv	a0,s1
    80002768:	cf6fe0ef          	jal	80000c5e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000276c:	18048493          	addi	s1,s1,384
    80002770:	01248c63          	beq	s1,s2,80002788 <mlfq_boost+0x40>
    acquire(&p->lock);
    80002774:	8526                	mv	a0,s1
    80002776:	c5cfe0ef          	jal	80000bd2 <acquire>
    if (p->state != UNUSED) {
    8000277a:	4c9c                	lw	a5,24(s1)
    8000277c:	d7ed                	beqz	a5,80002766 <mlfq_boost+0x1e>
      p->level = 0;
    8000277e:	1404ae23          	sw	zero,348(s1)
      p->ticks_used = 0;
    80002782:	1604a023          	sw	zero,352(s1)
    80002786:	b7c5                	j	80002766 <mlfq_boost+0x1e>
  }
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6902                	ld	s2,0(sp)
    80002790:	6105                	addi	sp,sp,32
    80002792:	8082                	ret

0000000080002794 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002794:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002798:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000279c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000279e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800027a0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800027a4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800027a8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800027ac:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800027b0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800027b4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800027b8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800027bc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800027c0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800027c4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800027c8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800027cc:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800027d0:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800027d2:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800027d4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800027d8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800027dc:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800027e0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800027e4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800027e8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800027ec:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800027f0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800027f4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800027f8:	0685bd83          	ld	s11,104(a1)
        
        ret
    800027fc:	8082                	ret

00000000800027fe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800027fe:	1141                	addi	sp,sp,-16
    80002800:	e406                	sd	ra,8(sp)
    80002802:	e022                	sd	s0,0(sp)
    80002804:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002806:	00006597          	auipc	a1,0x6
    8000280a:	a5258593          	addi	a1,a1,-1454 # 80008258 <etext+0x258>
    8000280e:	00017517          	auipc	a0,0x17
    80002812:	4a250513          	addi	a0,a0,1186 # 80019cb0 <tickslock>
    80002816:	b46fe0ef          	jal	80000b5c <initlock>
}
    8000281a:	60a2                	ld	ra,8(sp)
    8000281c:	6402                	ld	s0,0(sp)
    8000281e:	0141                	addi	sp,sp,16
    80002820:	8082                	ret

0000000080002822 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002822:	1141                	addi	sp,sp,-16
    80002824:	e422                	sd	s0,8(sp)
    80002826:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002828:	00003797          	auipc	a5,0x3
    8000282c:	40878793          	addi	a5,a5,1032 # 80005c30 <kernelvec>
    80002830:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002834:	6422                	ld	s0,8(sp)
    80002836:	0141                	addi	sp,sp,16
    80002838:	8082                	ret

000000008000283a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000283a:	1141                	addi	sp,sp,-16
    8000283c:	e406                	sd	ra,8(sp)
    8000283e:	e022                	sd	s0,0(sp)
    80002840:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002842:	8a2ff0ef          	jal	800018e4 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002846:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000284a:	04000737          	lui	a4,0x4000
    8000284e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002850:	0732                	slli	a4,a4,0xc
    80002852:	00004797          	auipc	a5,0x4
    80002856:	7ae78793          	addi	a5,a5,1966 # 80007000 <_trampoline>
    8000285a:	00004697          	auipc	a3,0x4
    8000285e:	7a668693          	addi	a3,a3,1958 # 80007000 <_trampoline>
    80002862:	8f95                	sub	a5,a5,a3
    80002864:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002866:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000286a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    8000286c:	18002773          	csrr	a4,satp
    80002870:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002872:	6d38                	ld	a4,88(a0)
    80002874:	613c                	ld	a5,64(a0)
    80002876:	6685                	lui	a3,0x1
    80002878:	97b6                	add	a5,a5,a3
    8000287a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000287c:	6d3c                	ld	a5,88(a0)
    8000287e:	00000717          	auipc	a4,0x0
    80002882:	10c70713          	addi	a4,a4,268 # 8000298a <usertrap>
    80002886:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002888:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    8000288a:	8712                	mv	a4,tp
    8000288c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000288e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002892:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002896:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000289a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000289e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800028a0:	6f9c                	ld	a5,24(a5)
    800028a2:	14179073          	csrw	sepc,a5
}
    800028a6:	60a2                	ld	ra,8(sp)
    800028a8:	6402                	ld	s0,0(sp)
    800028aa:	0141                	addi	sp,sp,16
    800028ac:	8082                	ret

00000000800028ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028ae:	1141                	addi	sp,sp,-16
    800028b0:	e406                	sd	ra,8(sp)
    800028b2:	e022                	sd	s0,0(sp)
    800028b4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800028b6:	802ff0ef          	jal	800018b8 <cpuid>
    800028ba:	cd11                	beqz	a0,800028d6 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800028bc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800028c0:	000f4737          	lui	a4,0xf4
    800028c4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800028c8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800028ca:	14d79073          	csrw	stimecmp,a5
}
    800028ce:	60a2                	ld	ra,8(sp)
    800028d0:	6402                	ld	s0,0(sp)
    800028d2:	0141                	addi	sp,sp,16
    800028d4:	8082                	ret
    acquire(&tickslock);
    800028d6:	00017517          	auipc	a0,0x17
    800028da:	3da50513          	addi	a0,a0,986 # 80019cb0 <tickslock>
    800028de:	af4fe0ef          	jal	80000bd2 <acquire>
    ticks++;
    800028e2:	00009717          	auipc	a4,0x9
    800028e6:	e6e70713          	addi	a4,a4,-402 # 8000b750 <ticks>
    800028ea:	431c                	lw	a5,0(a4)
    800028ec:	2785                	addiw	a5,a5,1
    800028ee:	c31c                	sw	a5,0(a4)
    if (ticks % 64 == 0) {
    800028f0:	03f7f793          	andi	a5,a5,63
    800028f4:	cf91                	beqz	a5,80002910 <clockintr+0x62>
    wakeup(&ticks);
    800028f6:	00009517          	auipc	a0,0x9
    800028fa:	e5a50513          	addi	a0,a0,-422 # 8000b750 <ticks>
    800028fe:	eeeff0ef          	jal	80001fec <wakeup>
    release(&tickslock);
    80002902:	00017517          	auipc	a0,0x17
    80002906:	3ae50513          	addi	a0,a0,942 # 80019cb0 <tickslock>
    8000290a:	b54fe0ef          	jal	80000c5e <release>
    8000290e:	b77d                	j	800028bc <clockintr+0xe>
      mlfq_boost();
    80002910:	e39ff0ef          	jal	80002748 <mlfq_boost>
    80002914:	b7cd                	j	800028f6 <clockintr+0x48>

0000000080002916 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002916:	1101                	addi	sp,sp,-32
    80002918:	ec06                	sd	ra,24(sp)
    8000291a:	e822                	sd	s0,16(sp)
    8000291c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000291e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    80002922:	57fd                	li	a5,-1
    80002924:	17fe                	slli	a5,a5,0x3f
    80002926:	07a5                	addi	a5,a5,9
    80002928:	00f70c63          	beq	a4,a5,80002940 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    8000292c:	57fd                	li	a5,-1
    8000292e:	17fe                	slli	a5,a5,0x3f
    80002930:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002932:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002934:	04f70763          	beq	a4,a5,80002982 <devintr+0x6c>
  }
}
    80002938:	60e2                	ld	ra,24(sp)
    8000293a:	6442                	ld	s0,16(sp)
    8000293c:	6105                	addi	sp,sp,32
    8000293e:	8082                	ret
    80002940:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002942:	39a030ef          	jal	80005cdc <plic_claim>
    80002946:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002948:	47a9                	li	a5,10
    8000294a:	00f50963          	beq	a0,a5,8000295c <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    8000294e:	4785                	li	a5,1
    80002950:	00f50963          	beq	a0,a5,80002962 <devintr+0x4c>
    return 1;
    80002954:	4505                	li	a0,1
    } else if (irq) {
    80002956:	e889                	bnez	s1,80002968 <devintr+0x52>
    80002958:	64a2                	ld	s1,8(sp)
    8000295a:	bff9                	j	80002938 <devintr+0x22>
      uartintr();
    8000295c:	830fe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002960:	a819                	j	80002976 <devintr+0x60>
      virtio_disk_intr();
    80002962:	05f030ef          	jal	800061c0 <virtio_disk_intr>
    if (irq)
    80002966:	a801                	j	80002976 <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    80002968:	85a6                	mv	a1,s1
    8000296a:	00006517          	auipc	a0,0x6
    8000296e:	8f650513          	addi	a0,a0,-1802 # 80008260 <etext+0x260>
    80002972:	b99fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    80002976:	8526                	mv	a0,s1
    80002978:	384030ef          	jal	80005cfc <plic_complete>
    return 1;
    8000297c:	4505                	li	a0,1
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	bf65                	j	80002938 <devintr+0x22>
    clockintr();
    80002982:	f2dff0ef          	jal	800028ae <clockintr>
    return 2;
    80002986:	4509                	li	a0,2
    80002988:	bf45                	j	80002938 <devintr+0x22>

000000008000298a <usertrap>:
{
    8000298a:	1101                	addi	sp,sp,-32
    8000298c:	ec06                	sd	ra,24(sp)
    8000298e:	e822                	sd	s0,16(sp)
    80002990:	e426                	sd	s1,8(sp)
    80002992:	e04a                	sd	s2,0(sp)
    80002994:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002996:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000299a:	1007f793          	andi	a5,a5,256
    8000299e:	eba5                	bnez	a5,80002a0e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800029a0:	00003797          	auipc	a5,0x3
    800029a4:	29078793          	addi	a5,a5,656 # 80005c30 <kernelvec>
    800029a8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029ac:	f39fe0ef          	jal	800018e4 <myproc>
    800029b0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029b2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800029b4:	14102773          	csrr	a4,sepc
    800029b8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800029ba:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800029be:	47a1                	li	a5,8
    800029c0:	04f70d63          	beq	a4,a5,80002a1a <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    800029c4:	f53ff0ef          	jal	80002916 <devintr>
    800029c8:	892a                	mv	s2,a0
    800029ca:	e54d                	bnez	a0,80002a74 <usertrap+0xea>
    800029cc:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800029d0:	47bd                	li	a5,15
    800029d2:	08f70463          	beq	a4,a5,80002a5a <usertrap+0xd0>
    800029d6:	14202773          	csrr	a4,scause
    800029da:	47b5                	li	a5,13
    800029dc:	06f70f63          	beq	a4,a5,80002a5a <usertrap+0xd0>
    800029e0:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800029e4:	5890                	lw	a2,48(s1)
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	8ba50513          	addi	a0,a0,-1862 # 800082a0 <etext+0x2a0>
    800029ee:	b1dfd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800029f2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800029f6:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800029fa:	00006517          	auipc	a0,0x6
    800029fe:	8d650513          	addi	a0,a0,-1834 # 800082d0 <etext+0x2d0>
    80002a02:	b09fd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002a06:	8526                	mv	a0,s1
    80002a08:	faeff0ef          	jal	800021b6 <setkilled>
    80002a0c:	a015                	j	80002a30 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	87250513          	addi	a0,a0,-1934 # 80008280 <etext+0x280>
    80002a16:	ddbfd0ef          	jal	800007f0 <panic>
    if (killed(p))
    80002a1a:	fc0ff0ef          	jal	800021da <killed>
    80002a1e:	e915                	bnez	a0,80002a52 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002a20:	6cb8                	ld	a4,88(s1)
    80002a22:	6f1c                	ld	a5,24(a4)
    80002a24:	0791                	addi	a5,a5,4
    80002a26:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002a28:	10016073          	csrsi	sstatus,2
    syscall();
    80002a2c:	268000ef          	jal	80002c94 <syscall>
  if (killed(p))
    80002a30:	8526                	mv	a0,s1
    80002a32:	fa8ff0ef          	jal	800021da <killed>
    80002a36:	e521                	bnez	a0,80002a7e <usertrap+0xf4>
  prepare_return();
    80002a38:	e03ff0ef          	jal	8000283a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a3c:	68a8                	ld	a0,80(s1)
    80002a3e:	8131                	srli	a0,a0,0xc
    80002a40:	57fd                	li	a5,-1
    80002a42:	17fe                	slli	a5,a5,0x3f
    80002a44:	8d5d                	or	a0,a0,a5
}
    80002a46:	60e2                	ld	ra,24(sp)
    80002a48:	6442                	ld	s0,16(sp)
    80002a4a:	64a2                	ld	s1,8(sp)
    80002a4c:	6902                	ld	s2,0(sp)
    80002a4e:	6105                	addi	sp,sp,32
    80002a50:	8082                	ret
      kexit(-1);
    80002a52:	557d                	li	a0,-1
    80002a54:	e54ff0ef          	jal	800020a8 <kexit>
    80002a58:	b7e1                	j	80002a20 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002a5a:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002a5e:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    80002a62:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    80002a64:	0016b693          	seqz	a3,a3
    80002a68:	64ac                	ld	a1,72(s1)
    80002a6a:	68a8                	ld	a0,80(s1)
    80002a6c:	a33fe0ef          	jal	8000149e <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002a70:	f161                	bnez	a0,80002a30 <usertrap+0xa6>
    80002a72:	b7bd                	j	800029e0 <usertrap+0x56>
  if (killed(p))
    80002a74:	8526                	mv	a0,s1
    80002a76:	f64ff0ef          	jal	800021da <killed>
    80002a7a:	c511                	beqz	a0,80002a86 <usertrap+0xfc>
    80002a7c:	a011                	j	80002a80 <usertrap+0xf6>
    80002a7e:	4901                	li	s2,0
    kexit(-1);
    80002a80:	557d                	li	a0,-1
    80002a82:	e26ff0ef          	jal	800020a8 <kexit>
  if(which_dev == 2) {
    80002a86:	4789                	li	a5,2
    80002a88:	faf918e3          	bne	s2,a5,80002a38 <usertrap+0xae>
    if(mlfq_tick(p)) {
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	be9ff0ef          	jal	80002676 <mlfq_tick>
    80002a92:	d15d                	beqz	a0,80002a38 <usertrap+0xae>
    yield();
    80002a94:	cc0ff0ef          	jal	80001f54 <yield>
    80002a98:	b745                	j	80002a38 <usertrap+0xae>

0000000080002a9a <kerneltrap>:
{
    80002a9a:	7179                	addi	sp,sp,-48
    80002a9c:	f406                	sd	ra,40(sp)
    80002a9e:	f022                	sd	s0,32(sp)
    80002aa0:	ec26                	sd	s1,24(sp)
    80002aa2:	e84a                	sd	s2,16(sp)
    80002aa4:	e44e                	sd	s3,8(sp)
    80002aa6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002aa8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002aac:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002ab0:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002ab4:	1004f793          	andi	a5,s1,256
    80002ab8:	c795                	beqz	a5,80002ae4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80002aba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002abe:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002ac0:	eb85                	bnez	a5,80002af0 <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    80002ac2:	e55ff0ef          	jal	80002916 <devintr>
    80002ac6:	c91d                	beqz	a0,80002afc <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002ac8:	4789                	li	a5,2
    80002aca:	04f50a63          	beq	a0,a5,80002b1e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002ace:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002ad2:	10049073          	csrw	sstatus,s1
}
    80002ad6:	70a2                	ld	ra,40(sp)
    80002ad8:	7402                	ld	s0,32(sp)
    80002ada:	64e2                	ld	s1,24(sp)
    80002adc:	6942                	ld	s2,16(sp)
    80002ade:	69a2                	ld	s3,8(sp)
    80002ae0:	6145                	addi	sp,sp,48
    80002ae2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ae4:	00006517          	auipc	a0,0x6
    80002ae8:	81450513          	addi	a0,a0,-2028 # 800082f8 <etext+0x2f8>
    80002aec:	d05fd0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	83050513          	addi	a0,a0,-2000 # 80008320 <etext+0x320>
    80002af8:	cf9fd0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002afc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002b00:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    80002b04:	85ce                	mv	a1,s3
    80002b06:	00006517          	auipc	a0,0x6
    80002b0a:	83a50513          	addi	a0,a0,-1990 # 80008340 <etext+0x340>
    80002b0e:	9fdfd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	85650513          	addi	a0,a0,-1962 # 80008368 <etext+0x368>
    80002b1a:	cd7fd0ef          	jal	800007f0 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002b1e:	dc7fe0ef          	jal	800018e4 <myproc>
    80002b22:	d555                	beqz	a0,80002ace <kerneltrap+0x34>
    80002b24:	dc1fe0ef          	jal	800018e4 <myproc>
    80002b28:	4d18                	lw	a4,24(a0)
    80002b2a:	4791                	li	a5,4
    80002b2c:	faf711e3          	bne	a4,a5,80002ace <kerneltrap+0x34>
    if(mlfq_tick(myproc())) {
    80002b30:	db5fe0ef          	jal	800018e4 <myproc>
    80002b34:	b43ff0ef          	jal	80002676 <mlfq_tick>
    80002b38:	d959                	beqz	a0,80002ace <kerneltrap+0x34>
      yield();
    80002b3a:	c1aff0ef          	jal	80001f54 <yield>
    80002b3e:	bf41                	j	80002ace <kerneltrap+0x34>

0000000080002b40 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	1000                	addi	s0,sp,32
    80002b4a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b4c:	d99fe0ef          	jal	800018e4 <myproc>
  switch (n) {
    80002b50:	4795                	li	a5,5
    80002b52:	0497e163          	bltu	a5,s1,80002b94 <argraw+0x54>
    80002b56:	048a                	slli	s1,s1,0x2
    80002b58:	00006717          	auipc	a4,0x6
    80002b5c:	d6070713          	addi	a4,a4,-672 # 800088b8 <mlfq_slices+0x10>
    80002b60:	94ba                	add	s1,s1,a4
    80002b62:	409c                	lw	a5,0(s1)
    80002b64:	97ba                	add	a5,a5,a4
    80002b66:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b68:	6d3c                	ld	a5,88(a0)
    80002b6a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret
    return p->trapframe->a1;
    80002b76:	6d3c                	ld	a5,88(a0)
    80002b78:	7fa8                	ld	a0,120(a5)
    80002b7a:	bfcd                	j	80002b6c <argraw+0x2c>
    return p->trapframe->a2;
    80002b7c:	6d3c                	ld	a5,88(a0)
    80002b7e:	63c8                	ld	a0,128(a5)
    80002b80:	b7f5                	j	80002b6c <argraw+0x2c>
    return p->trapframe->a3;
    80002b82:	6d3c                	ld	a5,88(a0)
    80002b84:	67c8                	ld	a0,136(a5)
    80002b86:	b7dd                	j	80002b6c <argraw+0x2c>
    return p->trapframe->a4;
    80002b88:	6d3c                	ld	a5,88(a0)
    80002b8a:	6bc8                	ld	a0,144(a5)
    80002b8c:	b7c5                	j	80002b6c <argraw+0x2c>
    return p->trapframe->a5;
    80002b8e:	6d3c                	ld	a5,88(a0)
    80002b90:	6fc8                	ld	a0,152(a5)
    80002b92:	bfe9                	j	80002b6c <argraw+0x2c>
  panic("argraw");
    80002b94:	00005517          	auipc	a0,0x5
    80002b98:	7e450513          	addi	a0,a0,2020 # 80008378 <etext+0x378>
    80002b9c:	c55fd0ef          	jal	800007f0 <panic>

0000000080002ba0 <fetchaddr>:
{
    80002ba0:	1101                	addi	sp,sp,-32
    80002ba2:	ec06                	sd	ra,24(sp)
    80002ba4:	e822                	sd	s0,16(sp)
    80002ba6:	e426                	sd	s1,8(sp)
    80002ba8:	e04a                	sd	s2,0(sp)
    80002baa:	1000                	addi	s0,sp,32
    80002bac:	84aa                	mv	s1,a0
    80002bae:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bb0:	d35fe0ef          	jal	800018e4 <myproc>
  if (addr >= p->sz ||
    80002bb4:	652c                	ld	a1,72(a0)
    80002bb6:	02b4f663          	bgeu	s1,a1,80002be2 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002bba:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002bbe:	02f5e463          	bltu	a1,a5,80002be6 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bc2:	4721                	li	a4,8
    80002bc4:	86a6                	mv	a3,s1
    80002bc6:	864a                	mv	a2,s2
    80002bc8:	6928                	ld	a0,80(a0)
    80002bca:	a3dfe0ef          	jal	80001606 <copyin>
    80002bce:	00a03533          	snez	a0,a0
    80002bd2:	40a00533          	neg	a0,a0
}
    80002bd6:	60e2                	ld	ra,24(sp)
    80002bd8:	6442                	ld	s0,16(sp)
    80002bda:	64a2                	ld	s1,8(sp)
    80002bdc:	6902                	ld	s2,0(sp)
    80002bde:	6105                	addi	sp,sp,32
    80002be0:	8082                	ret
    return -1;
    80002be2:	557d                	li	a0,-1
    80002be4:	bfcd                	j	80002bd6 <fetchaddr+0x36>
    80002be6:	557d                	li	a0,-1
    80002be8:	b7fd                	j	80002bd6 <fetchaddr+0x36>

0000000080002bea <fetchstr>:
{
    80002bea:	7179                	addi	sp,sp,-48
    80002bec:	f406                	sd	ra,40(sp)
    80002bee:	f022                	sd	s0,32(sp)
    80002bf0:	ec26                	sd	s1,24(sp)
    80002bf2:	e84a                	sd	s2,16(sp)
    80002bf4:	e44e                	sd	s3,8(sp)
    80002bf6:	1800                	addi	s0,sp,48
    80002bf8:	892a                	mv	s2,a0
    80002bfa:	84ae                	mv	s1,a1
    80002bfc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bfe:	ce7fe0ef          	jal	800018e4 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002c02:	874e                	mv	a4,s3
    80002c04:	86ca                	mv	a3,s2
    80002c06:	8626                	mv	a2,s1
    80002c08:	652c                	ld	a1,72(a0)
    80002c0a:	6928                	ld	a0,80(a0)
    80002c0c:	a91fe0ef          	jal	8000169c <copyinstr>
    80002c10:	00054c63          	bltz	a0,80002c28 <fetchstr+0x3e>
  return strlen(buf);
    80002c14:	8526                	mv	a0,s1
    80002c16:	9f0fe0ef          	jal	80000e06 <strlen>
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
    return -1;
    80002c28:	557d                	li	a0,-1
    80002c2a:	bfc5                	j	80002c1a <fetchstr+0x30>

0000000080002c2c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c2c:	1101                	addi	sp,sp,-32
    80002c2e:	ec06                	sd	ra,24(sp)
    80002c30:	e822                	sd	s0,16(sp)
    80002c32:	e426                	sd	s1,8(sp)
    80002c34:	1000                	addi	s0,sp,32
    80002c36:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c38:	f09ff0ef          	jal	80002b40 <argraw>
    80002c3c:	c088                	sw	a0,0(s1)
}
    80002c3e:	60e2                	ld	ra,24(sp)
    80002c40:	6442                	ld	s0,16(sp)
    80002c42:	64a2                	ld	s1,8(sp)
    80002c44:	6105                	addi	sp,sp,32
    80002c46:	8082                	ret

0000000080002c48 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	1000                	addi	s0,sp,32
    80002c52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c54:	eedff0ef          	jal	80002b40 <argraw>
    80002c58:	e088                	sd	a0,0(s1)
}
    80002c5a:	60e2                	ld	ra,24(sp)
    80002c5c:	6442                	ld	s0,16(sp)
    80002c5e:	64a2                	ld	s1,8(sp)
    80002c60:	6105                	addi	sp,sp,32
    80002c62:	8082                	ret

0000000080002c64 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c64:	7179                	addi	sp,sp,-48
    80002c66:	f406                	sd	ra,40(sp)
    80002c68:	f022                	sd	s0,32(sp)
    80002c6a:	ec26                	sd	s1,24(sp)
    80002c6c:	e84a                	sd	s2,16(sp)
    80002c6e:	1800                	addi	s0,sp,48
    80002c70:	84ae                	mv	s1,a1
    80002c72:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c74:	fd840593          	addi	a1,s0,-40
    80002c78:	fd1ff0ef          	jal	80002c48 <argaddr>
  return fetchstr(addr, buf, max);
    80002c7c:	864a                	mv	a2,s2
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	fd843503          	ld	a0,-40(s0)
    80002c84:	f67ff0ef          	jal	80002bea <fetchstr>
}
    80002c88:	70a2                	ld	ra,40(sp)
    80002c8a:	7402                	ld	s0,32(sp)
    80002c8c:	64e2                	ld	s1,24(sp)
    80002c8e:	6942                	ld	s2,16(sp)
    80002c90:	6145                	addi	sp,sp,48
    80002c92:	8082                	ret

0000000080002c94 <syscall>:
};


void
syscall(void)
{
    80002c94:	7119                	addi	sp,sp,-128
    80002c96:	fc86                	sd	ra,120(sp)
    80002c98:	f8a2                	sd	s0,112(sp)
    80002c9a:	f4a6                	sd	s1,104(sp)
    80002c9c:	f0ca                	sd	s2,96(sp)
    80002c9e:	ecce                	sd	s3,88(sp)
    80002ca0:	e8d2                	sd	s4,80(sp)
    80002ca2:	0100                	addi	s0,sp,128
  int num;
  struct proc *p = myproc();
    80002ca4:	c41fe0ef          	jal	800018e4 <myproc>
    80002ca8:	84aa                	mv	s1,a0

  num = p->trapframe->a7; // System call number is in register a7
    80002caa:	05853a03          	ld	s4,88(a0)
    80002cae:	0a8a3983          	ld	s3,168(s4)
    80002cb2:	0009891b          	sext.w	s2,s3
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cb6:	fff9871b          	addiw	a4,s3,-1
    80002cba:	47e5                	li	a5,25
    80002cbc:	0ce7e863          	bltu	a5,a4,80002d8c <syscall+0xf8>
    80002cc0:	e4d6                	sd	s5,72(sp)
    80002cc2:	00391713          	slli	a4,s2,0x3
    80002cc6:	00006797          	auipc	a5,0x6
    80002cca:	c0a78793          	addi	a5,a5,-1014 # 800088d0 <syscalls>
    80002cce:	97ba                	add	a5,a5,a4
    80002cd0:	0007ba83          	ld	s5,0(a5)
    80002cd4:	0a0a8b63          	beqz	s5,80002d8a <syscall+0xf6>
    80002cd8:	e0da                	sd	s6,64(sp)

    // 1. Core Constraint: Fetch string arguments BEFORE the handler overwrites them
    uint64 arg0 = p->trapframe->a0; 
    80002cda:	070a3b03          	ld	s6,112(s4)
    char strarg[64];
    int has_str = 0;

    if ((p->trace_mask & (1 << num))) {
    80002cde:	15852783          	lw	a5,344(a0)
    80002ce2:	4127d7bb          	sraw	a5,a5,s2
    80002ce6:	8b85                	andi	a5,a5,1
    80002ce8:	10078a63          	beqz	a5,80002dfc <syscall+0x168>
      // Check if this system call takes a string as its first argument
      if (num == SYS_open || num == SYS_exec || num == 4 || // chdir
    80002cec:	47d1                	li	a5,20
    80002cee:	0127ea63          	bltu	a5,s2,80002d02 <syscall+0x6e>
    80002cf2:	001e87b7          	lui	a5,0x1e8
    80002cf6:	09078793          	addi	a5,a5,144 # 1e8090 <_entry-0x7fe17f70>
    80002cfa:	0127d7b3          	srl	a5,a5,s2
    80002cfe:	8b85                	andi	a5,a5,1
    80002d00:	ef89                	bnez	a5,80002d1a <syscall+0x86>
        has_str = 1;
      }
    }

    // 2. Fire the underlying system call handler
    p->trapframe->a0 = syscalls[num]();
    80002d02:	9a82                	jalr	s5
    80002d04:	06aa3823          	sd	a0,112(s4)

    // 3. Print out the dynamic tracing output if tracked
    if(p->trace_mask & (1 << num)) {
    80002d08:	1584a783          	lw	a5,344(s1)
    80002d0c:	4127d7bb          	sraw	a5,a5,s2
    80002d10:	8b85                	andi	a5,a5,1
    80002d12:	e7b1                	bnez	a5,80002d5e <syscall+0xca>
    80002d14:	6aa6                	ld	s5,72(sp)
    80002d16:	6b06                	ld	s6,64(sp)
    80002d18:	a079                	j	80002da6 <syscall+0x112>
        if (fetchstr(arg0, strarg, sizeof(strarg)) < 0) {
    80002d1a:	04000613          	li	a2,64
    80002d1e:	f8040593          	addi	a1,s0,-128
    80002d22:	855a                	mv	a0,s6
    80002d24:	ec7ff0ef          	jal	80002bea <fetchstr>
    80002d28:	02054063          	bltz	a0,80002d48 <syscall+0xb4>
    p->trapframe->a0 = syscalls[num]();
    80002d2c:	0584b983          	ld	s3,88(s1)
    80002d30:	9a82                	jalr	s5
    80002d32:	06a9b823          	sd	a0,112(s3)
    if(p->trace_mask & (1 << num)) {
    80002d36:	1584a783          	lw	a5,344(s1)
    80002d3a:	4127d7bb          	sraw	a5,a5,s2
    80002d3e:	8b85                	andi	a5,a5,1
    80002d40:	ebf1                	bnez	a5,80002e14 <syscall+0x180>
    80002d42:	6aa6                	ld	s5,72(sp)
    80002d44:	6b06                	ld	s6,64(sp)
    80002d46:	a085                	j	80002da6 <syscall+0x112>
          safestrcpy(strarg, "?", sizeof(strarg));
    80002d48:	04000613          	li	a2,64
    80002d4c:	00005597          	auipc	a1,0x5
    80002d50:	63458593          	addi	a1,a1,1588 # 80008380 <etext+0x380>
    80002d54:	f8040513          	addi	a0,s0,-128
    80002d58:	87cfe0ef          	jal	80000dd4 <safestrcpy>
    80002d5c:	bfc1                	j	80002d2c <syscall+0x98>
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002d5e:	090e                	slli	s2,s2,0x3
    80002d60:	00006797          	auipc	a5,0x6
    80002d64:	b7078793          	addi	a5,a5,-1168 # 800088d0 <syscalls>
    80002d68:	97ca                	add	a5,a5,s2
    80002d6a:	6ff0                	ld	a2,216(a5)
    80002d6c:	588c                	lw	a1,48(s1)
    80002d6e:	00005517          	auipc	a0,0x5
    80002d72:	61a50513          	addi	a0,a0,1562 # 80008388 <etext+0x388>
    80002d76:	f94fd0ef          	jal	8000050a <printk>

      // Custom argument format rules matching assignment spec
      if (has_str) {
    80002d7a:	a8a1                	j	80002dd2 <syscall+0x13e>
        if (strarg[0] == '?' && strarg[1] == '\0') {
          printk("?");
    80002d7c:	00005517          	auipc	a0,0x5
    80002d80:	60450513          	addi	a0,a0,1540 # 80008380 <etext+0x380>
    80002d84:	f86fd0ef          	jal	8000050a <printk>
    80002d88:	a0e9                	j	80002e52 <syscall+0x1be>
    80002d8a:	6aa6                	ld	s5,72(sp)
      }

      printk(") -> %d\n", (int)p->trapframe->a0);
    }
  } else {
    printk("%d %s: unknown sys call %d\n",
    80002d8c:	86ca                	mv	a3,s2
    80002d8e:	17048613          	addi	a2,s1,368
    80002d92:	588c                	lw	a1,48(s1)
    80002d94:	00005517          	auipc	a0,0x5
    80002d98:	62450513          	addi	a0,a0,1572 # 800083b8 <etext+0x3b8>
    80002d9c:	f6efd0ef          	jal	8000050a <printk>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002da0:	6cbc                	ld	a5,88(s1)
    80002da2:	577d                	li	a4,-1
    80002da4:	fbb8                	sd	a4,112(a5)
  }
}
    80002da6:	70e6                	ld	ra,120(sp)
    80002da8:	7446                	ld	s0,112(sp)
    80002daa:	74a6                	ld	s1,104(sp)
    80002dac:	7906                	ld	s2,96(sp)
    80002dae:	69e6                	ld	s3,88(sp)
    80002db0:	6a46                	ld	s4,80(sp)
    80002db2:	6109                	addi	sp,sp,128
    80002db4:	8082                	ret
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002db6:	090e                	slli	s2,s2,0x3
    80002db8:	00006797          	auipc	a5,0x6
    80002dbc:	b1878793          	addi	a5,a5,-1256 # 800088d0 <syscalls>
    80002dc0:	97ca                	add	a5,a5,s2
    80002dc2:	6ff0                	ld	a2,216(a5)
    80002dc4:	588c                	lw	a1,48(s1)
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	5c250513          	addi	a0,a0,1474 # 80008388 <etext+0x388>
    80002dce:	f3cfd0ef          	jal	8000050a <printk>
      } else if (num == 1 || num == 11 || num == 14 || num == 21) { // fork/kfork, getpid, uptime, sync
    80002dd2:	2981                	sext.w	s3,s3
    80002dd4:	47d5                	li	a5,21
    80002dd6:	0137ea63          	bltu	a5,s3,80002dea <syscall+0x156>
    80002dda:	002057b7          	lui	a5,0x205
    80002dde:	80278793          	addi	a5,a5,-2046 # 204802 <_entry-0x7fdfb7fe>
    80002de2:	0137d7b3          	srl	a5,a5,s3
    80002de6:	8b85                	andi	a5,a5,1
    80002de8:	e7ad                	bnez	a5,80002e52 <syscall+0x1be>
        printk("%d", (int)arg0);
    80002dea:	000b059b          	sext.w	a1,s6
    80002dee:	00005517          	auipc	a0,0x5
    80002df2:	5b250513          	addi	a0,a0,1458 # 800083a0 <etext+0x3a0>
    80002df6:	f14fd0ef          	jal	8000050a <printk>
    80002dfa:	a8a1                	j	80002e52 <syscall+0x1be>
    p->trapframe->a0 = syscalls[num]();
    80002dfc:	9a82                	jalr	s5
    80002dfe:	06aa3823          	sd	a0,112(s4)
    if(p->trace_mask & (1 << num)) {
    80002e02:	1584a783          	lw	a5,344(s1)
    80002e06:	4127d7bb          	sraw	a5,a5,s2
    80002e0a:	8b85                	andi	a5,a5,1
    80002e0c:	f7cd                	bnez	a5,80002db6 <syscall+0x122>
    80002e0e:	6aa6                	ld	s5,72(sp)
    80002e10:	6b06                	ld	s6,64(sp)
    80002e12:	bf51                	j	80002da6 <syscall+0x112>
      printk("[%d] %s(", p->pid, syscall_names[num]);
    80002e14:	090e                	slli	s2,s2,0x3
    80002e16:	00006797          	auipc	a5,0x6
    80002e1a:	aba78793          	addi	a5,a5,-1350 # 800088d0 <syscalls>
    80002e1e:	97ca                	add	a5,a5,s2
    80002e20:	6ff0                	ld	a2,216(a5)
    80002e22:	588c                	lw	a1,48(s1)
    80002e24:	00005517          	auipc	a0,0x5
    80002e28:	56450513          	addi	a0,a0,1380 # 80008388 <etext+0x388>
    80002e2c:	edefd0ef          	jal	8000050a <printk>
        if (strarg[0] == '?' && strarg[1] == '\0') {
    80002e30:	f8044703          	lbu	a4,-128(s0)
    80002e34:	03f00793          	li	a5,63
    80002e38:	00f71563          	bne	a4,a5,80002e42 <syscall+0x1ae>
    80002e3c:	f8144783          	lbu	a5,-127(s0)
    80002e40:	df95                	beqz	a5,80002d7c <syscall+0xe8>
          printk("\"%s\"", strarg);
    80002e42:	f8040593          	addi	a1,s0,-128
    80002e46:	00005517          	auipc	a0,0x5
    80002e4a:	55250513          	addi	a0,a0,1362 # 80008398 <etext+0x398>
    80002e4e:	ebcfd0ef          	jal	8000050a <printk>
      printk(") -> %d\n", (int)p->trapframe->a0);
    80002e52:	6cbc                	ld	a5,88(s1)
    80002e54:	5bac                	lw	a1,112(a5)
    80002e56:	00005517          	auipc	a0,0x5
    80002e5a:	55250513          	addi	a0,a0,1362 # 800083a8 <etext+0x3a8>
    80002e5e:	eacfd0ef          	jal	8000050a <printk>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e62:	6aa6                	ld	s5,72(sp)
    80002e64:	6b06                	ld	s6,64(sp)
    80002e66:	b781                	j	80002da6 <syscall+0x112>

0000000080002e68 <sys_exit>:
#include "vm.h"
#include "kernel/sysinfo.h"

uint64
sys_exit(void)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e70:	fec40593          	addi	a1,s0,-20
    80002e74:	4501                	li	a0,0
    80002e76:	db7ff0ef          	jal	80002c2c <argint>
  kexit(n);
    80002e7a:	fec42503          	lw	a0,-20(s0)
    80002e7e:	a2aff0ef          	jal	800020a8 <kexit>
  return 0; // not reached
}
    80002e82:	4501                	li	a0,0
    80002e84:	60e2                	ld	ra,24(sp)
    80002e86:	6442                	ld	s0,16(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret

0000000080002e8c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e8c:	1141                	addi	sp,sp,-16
    80002e8e:	e406                	sd	ra,8(sp)
    80002e90:	e022                	sd	s0,0(sp)
    80002e92:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e94:	a51fe0ef          	jal	800018e4 <myproc>
}
    80002e98:	5908                	lw	a0,48(a0)
    80002e9a:	60a2                	ld	ra,8(sp)
    80002e9c:	6402                	ld	s0,0(sp)
    80002e9e:	0141                	addi	sp,sp,16
    80002ea0:	8082                	ret

0000000080002ea2 <sys_fork>:

uint64
sys_fork(void)
{
    80002ea2:	1141                	addi	sp,sp,-16
    80002ea4:	e406                	sd	ra,8(sp)
    80002ea6:	e022                	sd	s0,0(sp)
    80002ea8:	0800                	addi	s0,sp,16
  return kfork();
    80002eaa:	db7fe0ef          	jal	80001c60 <kfork>
}
    80002eae:	60a2                	ld	ra,8(sp)
    80002eb0:	6402                	ld	s0,0(sp)
    80002eb2:	0141                	addi	sp,sp,16
    80002eb4:	8082                	ret

0000000080002eb6 <sys_wait>:

uint64
sys_wait(void)
{
    80002eb6:	1101                	addi	sp,sp,-32
    80002eb8:	ec06                	sd	ra,24(sp)
    80002eba:	e822                	sd	s0,16(sp)
    80002ebc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ebe:	fe840593          	addi	a1,s0,-24
    80002ec2:	4501                	li	a0,0
    80002ec4:	d85ff0ef          	jal	80002c48 <argaddr>
  return kwait(p);
    80002ec8:	fe843503          	ld	a0,-24(s0)
    80002ecc:	b38ff0ef          	jal	80002204 <kwait>
}
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	6105                	addi	sp,sp,32
    80002ed6:	8082                	ret

0000000080002ed8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ed8:	7179                	addi	sp,sp,-48
    80002eda:	f406                	sd	ra,40(sp)
    80002edc:	f022                	sd	s0,32(sp)
    80002ede:	ec26                	sd	s1,24(sp)
    80002ee0:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ee2:	fd840593          	addi	a1,s0,-40
    80002ee6:	4501                	li	a0,0
    80002ee8:	d45ff0ef          	jal	80002c2c <argint>
  argint(1, &t);
    80002eec:	fdc40593          	addi	a1,s0,-36
    80002ef0:	4505                	li	a0,1
    80002ef2:	d3bff0ef          	jal	80002c2c <argint>
  addr = myproc()->sz;
    80002ef6:	9effe0ef          	jal	800018e4 <myproc>
    80002efa:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002efc:	fdc42703          	lw	a4,-36(s0)
    80002f00:	4785                	li	a5,1
    80002f02:	02f70763          	beq	a4,a5,80002f30 <sys_sbrk+0x58>
    80002f06:	fd842783          	lw	a5,-40(s0)
    80002f0a:	0207c363          	bltz	a5,80002f30 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002f0e:	97a6                	add	a5,a5,s1
    80002f10:	0297ee63          	bltu	a5,s1,80002f4c <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    80002f14:	02000737          	lui	a4,0x2000
    80002f18:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002f1a:	0736                	slli	a4,a4,0xd
    80002f1c:	02f76a63          	bltu	a4,a5,80002f50 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002f20:	9c5fe0ef          	jal	800018e4 <myproc>
    80002f24:	fd842703          	lw	a4,-40(s0)
    80002f28:	653c                	ld	a5,72(a0)
    80002f2a:	97ba                	add	a5,a5,a4
    80002f2c:	e53c                	sd	a5,72(a0)
    80002f2e:	a039                	j	80002f3c <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002f30:	fd842503          	lw	a0,-40(s0)
    80002f34:	ccbfe0ef          	jal	80001bfe <growproc>
    80002f38:	00054863          	bltz	a0,80002f48 <sys_sbrk+0x70>
  }
  return addr;
}
    80002f3c:	8526                	mv	a0,s1
    80002f3e:	70a2                	ld	ra,40(sp)
    80002f40:	7402                	ld	s0,32(sp)
    80002f42:	64e2                	ld	s1,24(sp)
    80002f44:	6145                	addi	sp,sp,48
    80002f46:	8082                	ret
      return -1;
    80002f48:	54fd                	li	s1,-1
    80002f4a:	bfcd                	j	80002f3c <sys_sbrk+0x64>
      return -1;
    80002f4c:	54fd                	li	s1,-1
    80002f4e:	b7fd                	j	80002f3c <sys_sbrk+0x64>
      return -1;
    80002f50:	54fd                	li	s1,-1
    80002f52:	b7ed                	j	80002f3c <sys_sbrk+0x64>

0000000080002f54 <sys_pause>:

uint64
sys_pause(void)
{
    80002f54:	7139                	addi	sp,sp,-64
    80002f56:	fc06                	sd	ra,56(sp)
    80002f58:	f822                	sd	s0,48(sp)
    80002f5a:	ec4e                	sd	s3,24(sp)
    80002f5c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f5e:	fcc40593          	addi	a1,s0,-52
    80002f62:	4501                	li	a0,0
    80002f64:	cc9ff0ef          	jal	80002c2c <argint>
  if (n < 0)
    80002f68:	fcc42783          	lw	a5,-52(s0)
    80002f6c:	0607cf63          	bltz	a5,80002fea <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002f70:	00017517          	auipc	a0,0x17
    80002f74:	d4050513          	addi	a0,a0,-704 # 80019cb0 <tickslock>
    80002f78:	c5bfd0ef          	jal	80000bd2 <acquire>
  ticks0 = ticks;
    80002f7c:	00008997          	auipc	s3,0x8
    80002f80:	7d49a983          	lw	s3,2004(s3) # 8000b750 <ticks>
  while (ticks - ticks0 < n) {
    80002f84:	fcc42783          	lw	a5,-52(s0)
    80002f88:	c7a9                	beqz	a5,80002fd2 <sys_pause+0x7e>
    80002f8a:	f426                	sd	s1,40(sp)
    80002f8c:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002f8e:	00008917          	auipc	s2,0x8
    80002f92:	7c290913          	addi	s2,s2,1986 # 8000b750 <ticks>
    release(&tickslock);
    80002f96:	00017497          	auipc	s1,0x17
    80002f9a:	d1a48493          	addi	s1,s1,-742 # 80019cb0 <tickslock>
    if (killed(myproc())) {
    80002f9e:	947fe0ef          	jal	800018e4 <myproc>
    80002fa2:	a38ff0ef          	jal	800021da <killed>
    80002fa6:	e529                	bnez	a0,80002ff0 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002fa8:	854a                	mv	a0,s2
    80002faa:	fd7fe0ef          	jal	80001f80 <sleep_prepare>
    release(&tickslock);
    80002fae:	8526                	mv	a0,s1
    80002fb0:	caffd0ef          	jal	80000c5e <release>
    sleep();
    80002fb4:	808ff0ef          	jal	80001fbc <sleep>
    acquire(&tickslock);
    80002fb8:	8526                	mv	a0,s1
    80002fba:	c19fd0ef          	jal	80000bd2 <acquire>
  while (ticks - ticks0 < n) {
    80002fbe:	00092783          	lw	a5,0(s2)
    80002fc2:	413787bb          	subw	a5,a5,s3
    80002fc6:	fcc42703          	lw	a4,-52(s0)
    80002fca:	fce7eae3          	bltu	a5,a4,80002f9e <sys_pause+0x4a>
    80002fce:	74a2                	ld	s1,40(sp)
    80002fd0:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002fd2:	00017517          	auipc	a0,0x17
    80002fd6:	cde50513          	addi	a0,a0,-802 # 80019cb0 <tickslock>
    80002fda:	c85fd0ef          	jal	80000c5e <release>
  return 0;
    80002fde:	4501                	li	a0,0
}
    80002fe0:	70e2                	ld	ra,56(sp)
    80002fe2:	7442                	ld	s0,48(sp)
    80002fe4:	69e2                	ld	s3,24(sp)
    80002fe6:	6121                	addi	sp,sp,64
    80002fe8:	8082                	ret
    n = 0;
    80002fea:	fc042623          	sw	zero,-52(s0)
    80002fee:	b749                	j	80002f70 <sys_pause+0x1c>
      release(&tickslock);
    80002ff0:	00017517          	auipc	a0,0x17
    80002ff4:	cc050513          	addi	a0,a0,-832 # 80019cb0 <tickslock>
    80002ff8:	c67fd0ef          	jal	80000c5e <release>
      return -1;
    80002ffc:	557d                	li	a0,-1
    80002ffe:	74a2                	ld	s1,40(sp)
    80003000:	7902                	ld	s2,32(sp)
    80003002:	bff9                	j	80002fe0 <sys_pause+0x8c>

0000000080003004 <sys_kill>:

uint64
sys_kill(void)
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000300c:	fec40593          	addi	a1,s0,-20
    80003010:	4501                	li	a0,0
    80003012:	c1bff0ef          	jal	80002c2c <argint>
  return kkill(pid);
    80003016:	fec42503          	lw	a0,-20(s0)
    8000301a:	930ff0ef          	jal	8000214a <kkill>
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003030:	00017517          	auipc	a0,0x17
    80003034:	c8050513          	addi	a0,a0,-896 # 80019cb0 <tickslock>
    80003038:	b9bfd0ef          	jal	80000bd2 <acquire>
  xticks = ticks;
    8000303c:	00008497          	auipc	s1,0x8
    80003040:	7144a483          	lw	s1,1812(s1) # 8000b750 <ticks>
  release(&tickslock);
    80003044:	00017517          	auipc	a0,0x17
    80003048:	c6c50513          	addi	a0,a0,-916 # 80019cb0 <tickslock>
    8000304c:	c13fd0ef          	jal	80000c5e <release>
  return xticks;
}
    80003050:	02049513          	slli	a0,s1,0x20
    80003054:	9101                	srli	a0,a0,0x20
    80003056:	60e2                	ld	ra,24(sp)
    80003058:	6442                	ld	s0,16(sp)
    8000305a:	64a2                	ld	s1,8(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret

0000000080003060 <sys_trace>:

uint64
sys_trace(void)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	1000                	addi	s0,sp,32
  int mask;

  //Grab first integer argument from register a0
  argint(0, &mask);
    80003068:	fec40593          	addi	a1,s0,-20
    8000306c:	4501                	li	a0,0
    8000306e:	bbfff0ef          	jal	80002c2c <argint>

  myproc()->trace_mask = mask;
    80003072:	873fe0ef          	jal	800018e4 <myproc>
    80003076:	fec42783          	lw	a5,-20(s0)
    8000307a:	14f52c23          	sw	a5,344(a0)
  return 0;
}
    8000307e:	4501                	li	a0,0
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	6105                	addi	sp,sp,32
    80003086:	8082                	ret

0000000080003088 <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80003088:	7139                	addi	sp,sp,-64
    8000308a:	fc06                	sd	ra,56(sp)
    8000308c:	f822                	sd	s0,48(sp)
    8000308e:	f426                	sd	s1,40(sp)
    80003090:	0080                	addi	s0,sp,64
  uint64 addr;
  struct sysinfo info;
  struct proc *p = myproc();
    80003092:	853fe0ef          	jal	800018e4 <myproc>
    80003096:	84aa                	mv	s1,a0

  // Fetch the user space pointer address passed as an argument
  argaddr(0, &addr);
    80003098:	fd840593          	addi	a1,s0,-40
    8000309c:	4501                	li	a0,0
    8000309e:	babff0ef          	jal	80002c48 <argaddr>

  // Populate our structure fields
  info.freemem = count_free_mem();
    800030a2:	a79fd0ef          	jal	80000b1a <count_free_mem>
    800030a6:	fca43023          	sd	a0,-64(s0)
  info.nproc = count_active_procs();
    800030aa:	ba6ff0ef          	jal	80002450 <count_active_procs>
    800030ae:	fca43423          	sd	a0,-56(s0)
  info.nopenfile = count_open_files();
    800030b2:	209010ef          	jal	80004aba <count_open_files>
    800030b6:	fca43823          	sd	a0,-48(s0)

  // Pass all 5 arguments to match your kernel's copyout signature:
if(copyout(p->pagetable, addr, addr, (char *)&info, sizeof(info)) < 0){
    800030ba:	fd843583          	ld	a1,-40(s0)
    800030be:	4761                	li	a4,24
    800030c0:	fc040693          	addi	a3,s0,-64
    800030c4:	862e                	mv	a2,a1
    800030c6:	68a8                	ld	a0,80(s1)
    800030c8:	c52fe0ef          	jal	8000151a <copyout>
    // If it fails, print a kernel log to console to pinpoint exactly why
    printk("sysinfo kernel alert: copyout failed for pid %d at addr 0x%lx\n", p->pid, addr);
    return -1;
  }

  return 0;
    800030cc:	4781                	li	a5,0
if(copyout(p->pagetable, addr, addr, (char *)&info, sizeof(info)) < 0){
    800030ce:	00054863          	bltz	a0,800030de <sys_sysinfo+0x56>
}
    800030d2:	853e                	mv	a0,a5
    800030d4:	70e2                	ld	ra,56(sp)
    800030d6:	7442                	ld	s0,48(sp)
    800030d8:	74a2                	ld	s1,40(sp)
    800030da:	6121                	addi	sp,sp,64
    800030dc:	8082                	ret
    printk("sysinfo kernel alert: copyout failed for pid %d at addr 0x%lx\n", p->pid, addr);
    800030de:	fd843603          	ld	a2,-40(s0)
    800030e2:	588c                	lw	a1,48(s1)
    800030e4:	00005517          	auipc	a0,0x5
    800030e8:	3c450513          	addi	a0,a0,964 # 800084a8 <etext+0x4a8>
    800030ec:	c1efd0ef          	jal	8000050a <printk>
    return -1;
    800030f0:	57fd                	li	a5,-1
    800030f2:	b7c5                	j	800030d2 <sys_sysinfo+0x4a>

00000000800030f4 <sys_getprocs>:

uint64
sys_getprocs(void)
{
    800030f4:	1101                	addi	sp,sp,-32
    800030f6:	ec06                	sd	ra,24(sp)
    800030f8:	e822                	sd	s0,16(sp)
    800030fa:	1000                	addi	s0,sp,32
  uint64 buf;
  int max;

  argaddr(0, &buf);
    800030fc:	fe840593          	addi	a1,s0,-24
    80003100:	4501                	li	a0,0
    80003102:	b47ff0ef          	jal	80002c48 <argaddr>
  argint(1, &max);
    80003106:	fe440593          	addi	a1,s0,-28
    8000310a:	4505                	li	a0,1
    8000310c:	b21ff0ef          	jal	80002c2c <argint>

  return get_uprocs(buf, max);
    80003110:	fe442583          	lw	a1,-28(s0)
    80003114:	fe843503          	ld	a0,-24(s0)
    80003118:	b66ff0ef          	jal	8000247e <get_uprocs>
}
    8000311c:	60e2                	ld	ra,24(sp)
    8000311e:	6442                	ld	s0,16(sp)
    80003120:	6105                	addi	sp,sp,32
    80003122:	8082                	ret

0000000080003124 <sys_getpinfo>:

uint64
sys_getpinfo(void)
{
    80003124:	1101                	addi	sp,sp,-32
    80003126:	ec06                	sd	ra,24(sp)
    80003128:	e822                	sd	s0,16(sp)
    8000312a:	1000                	addi	s0,sp,32
  uint64 buf;
  int max;

  argaddr(0, &buf);
    8000312c:	fe840593          	addi	a1,s0,-24
    80003130:	4501                	li	a0,0
    80003132:	b17ff0ef          	jal	80002c48 <argaddr>
  argint(1, &max);
    80003136:	fe440593          	addi	a1,s0,-28
    8000313a:	4505                	li	a0,1
    8000313c:	af1ff0ef          	jal	80002c2c <argint>

  return get_pinfos(buf, max);
    80003140:	fe442583          	lw	a1,-28(s0)
    80003144:	fe843503          	ld	a0,-24(s0)
    80003148:	c4eff0ef          	jal	80002596 <get_pinfos>
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	6105                	addi	sp,sp,32
    80003152:	8082                	ret

0000000080003154 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003154:	7179                	addi	sp,sp,-48
    80003156:	f406                	sd	ra,40(sp)
    80003158:	f022                	sd	s0,32(sp)
    8000315a:	ec26                	sd	s1,24(sp)
    8000315c:	e84a                	sd	s2,16(sp)
    8000315e:	e44e                	sd	s3,8(sp)
    80003160:	e052                	sd	s4,0(sp)
    80003162:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003164:	00005597          	auipc	a1,0x5
    80003168:	38458593          	addi	a1,a1,900 # 800084e8 <etext+0x4e8>
    8000316c:	00017517          	auipc	a0,0x17
    80003170:	b5c50513          	addi	a0,a0,-1188 # 80019cc8 <bcache>
    80003174:	9e9fd0ef          	jal	80000b5c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003178:	0001f797          	auipc	a5,0x1f
    8000317c:	b5078793          	addi	a5,a5,-1200 # 80021cc8 <bcache+0x8000>
    80003180:	0001f717          	auipc	a4,0x1f
    80003184:	db070713          	addi	a4,a4,-592 # 80021f30 <bcache+0x8268>
    80003188:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000318c:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80003190:	00017497          	auipc	s1,0x17
    80003194:	b5048493          	addi	s1,s1,-1200 # 80019ce0 <bcache+0x18>
    b->next = bcache.head.next;
    80003198:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000319a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000319c:	00005a17          	auipc	s4,0x5
    800031a0:	354a0a13          	addi	s4,s4,852 # 800084f0 <etext+0x4f0>
    b->next = bcache.head.next;
    800031a4:	2b893783          	ld	a5,696(s2)
    800031a8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031aa:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031ae:	85d2                	mv	a1,s4
    800031b0:	01048513          	addi	a0,s1,16
    800031b4:	412010ef          	jal	800045c6 <initsleeplock>
    bcache.head.next->prev = b;
    800031b8:	2b893783          	ld	a5,696(s2)
    800031bc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031be:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    800031c2:	45848493          	addi	s1,s1,1112
    800031c6:	fd349fe3          	bne	s1,s3,800031a4 <binit+0x50>
  }
}
    800031ca:	70a2                	ld	ra,40(sp)
    800031cc:	7402                	ld	s0,32(sp)
    800031ce:	64e2                	ld	s1,24(sp)
    800031d0:	6942                	ld	s2,16(sp)
    800031d2:	69a2                	ld	s3,8(sp)
    800031d4:	6a02                	ld	s4,0(sp)
    800031d6:	6145                	addi	sp,sp,48
    800031d8:	8082                	ret

00000000800031da <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    800031da:	7179                	addi	sp,sp,-48
    800031dc:	f406                	sd	ra,40(sp)
    800031de:	f022                	sd	s0,32(sp)
    800031e0:	ec26                	sd	s1,24(sp)
    800031e2:	e84a                	sd	s2,16(sp)
    800031e4:	e44e                	sd	s3,8(sp)
    800031e6:	1800                	addi	s0,sp,48
    800031e8:	892a                	mv	s2,a0
    800031ea:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031ec:	00017517          	auipc	a0,0x17
    800031f0:	adc50513          	addi	a0,a0,-1316 # 80019cc8 <bcache>
    800031f4:	9dffd0ef          	jal	80000bd2 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    800031f8:	0001f497          	auipc	s1,0x1f
    800031fc:	d884b483          	ld	s1,-632(s1) # 80021f80 <bcache+0x82b8>
    80003200:	0001f797          	auipc	a5,0x1f
    80003204:	d3078793          	addi	a5,a5,-720 # 80021f30 <bcache+0x8268>
    80003208:	02f48b63          	beq	s1,a5,8000323e <bread+0x64>
    8000320c:	873e                	mv	a4,a5
    8000320e:	a021                	j	80003216 <bread+0x3c>
    80003210:	68a4                	ld	s1,80(s1)
    80003212:	02e48663          	beq	s1,a4,8000323e <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80003216:	449c                	lw	a5,8(s1)
    80003218:	ff279ce3          	bne	a5,s2,80003210 <bread+0x36>
    8000321c:	44dc                	lw	a5,12(s1)
    8000321e:	ff3799e3          	bne	a5,s3,80003210 <bread+0x36>
      b->refcnt++;
    80003222:	40bc                	lw	a5,64(s1)
    80003224:	2785                	addiw	a5,a5,1
    80003226:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003228:	00017517          	auipc	a0,0x17
    8000322c:	aa050513          	addi	a0,a0,-1376 # 80019cc8 <bcache>
    80003230:	a2ffd0ef          	jal	80000c5e <release>
      acquiresleep(&b->lock);
    80003234:	01048513          	addi	a0,s1,16
    80003238:	3c4010ef          	jal	800045fc <acquiresleep>
      return b;
    8000323c:	a889                	j	8000328e <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    8000323e:	0001f497          	auipc	s1,0x1f
    80003242:	d3a4b483          	ld	s1,-710(s1) # 80021f78 <bcache+0x82b0>
    80003246:	0001f797          	auipc	a5,0x1f
    8000324a:	cea78793          	addi	a5,a5,-790 # 80021f30 <bcache+0x8268>
    8000324e:	00f48863          	beq	s1,a5,8000325e <bread+0x84>
    80003252:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80003254:	40bc                	lw	a5,64(s1)
    80003256:	cb91                	beqz	a5,8000326a <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80003258:	64a4                	ld	s1,72(s1)
    8000325a:	fee49de3          	bne	s1,a4,80003254 <bread+0x7a>
  panic("bget: no buffers");
    8000325e:	00005517          	auipc	a0,0x5
    80003262:	29a50513          	addi	a0,a0,666 # 800084f8 <etext+0x4f8>
    80003266:	d8afd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    8000326a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000326e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003272:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003276:	4785                	li	a5,1
    80003278:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000327a:	00017517          	auipc	a0,0x17
    8000327e:	a4e50513          	addi	a0,a0,-1458 # 80019cc8 <bcache>
    80003282:	9ddfd0ef          	jal	80000c5e <release>
      acquiresleep(&b->lock);
    80003286:	01048513          	addi	a0,s1,16
    8000328a:	372010ef          	jal	800045fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    8000328e:	409c                	lw	a5,0(s1)
    80003290:	cb89                	beqz	a5,800032a2 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003292:	8526                	mv	a0,s1
    80003294:	70a2                	ld	ra,40(sp)
    80003296:	7402                	ld	s0,32(sp)
    80003298:	64e2                	ld	s1,24(sp)
    8000329a:	6942                	ld	s2,16(sp)
    8000329c:	69a2                	ld	s3,8(sp)
    8000329e:	6145                	addi	sp,sp,48
    800032a0:	8082                	ret
    virtio_disk_rw(b, 0);
    800032a2:	4581                	li	a1,0
    800032a4:	8526                	mv	a0,s1
    800032a6:	4eb020ef          	jal	80005f90 <virtio_disk_rw>
    b->valid = 1;
    800032aa:	4785                	li	a5,1
    800032ac:	c09c                	sw	a5,0(s1)
  return b;
    800032ae:	b7d5                	j	80003292 <bread+0xb8>

00000000800032b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
    800032ba:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800032bc:	0541                	addi	a0,a0,16
    800032be:	3ca010ef          	jal	80004688 <holdingsleep>
    800032c2:	c911                	beqz	a0,800032d6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032c4:	4585                	li	a1,1
    800032c6:	8526                	mv	a0,s1
    800032c8:	4c9020ef          	jal	80005f90 <virtio_disk_rw>
}
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    panic("bwrite");
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	23a50513          	addi	a0,a0,570 # 80008510 <etext+0x510>
    800032de:	d12fd0ef          	jal	800007f0 <panic>

00000000800032e2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032e2:	1101                	addi	sp,sp,-32
    800032e4:	ec06                	sd	ra,24(sp)
    800032e6:	e822                	sd	s0,16(sp)
    800032e8:	e426                	sd	s1,8(sp)
    800032ea:	e04a                	sd	s2,0(sp)
    800032ec:	1000                	addi	s0,sp,32
    800032ee:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    800032f0:	01050913          	addi	s2,a0,16
    800032f4:	854a                	mv	a0,s2
    800032f6:	392010ef          	jal	80004688 <holdingsleep>
    800032fa:	c135                	beqz	a0,8000335e <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800032fc:	854a                	mv	a0,s2
    800032fe:	352010ef          	jal	80004650 <releasesleep>

  acquire(&bcache.lock);
    80003302:	00017517          	auipc	a0,0x17
    80003306:	9c650513          	addi	a0,a0,-1594 # 80019cc8 <bcache>
    8000330a:	8c9fd0ef          	jal	80000bd2 <acquire>
  b->refcnt--;
    8000330e:	40bc                	lw	a5,64(s1)
    80003310:	37fd                	addiw	a5,a5,-1
    80003312:	0007871b          	sext.w	a4,a5
    80003316:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003318:	e71d                	bnez	a4,80003346 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000331a:	68b8                	ld	a4,80(s1)
    8000331c:	64bc                	ld	a5,72(s1)
    8000331e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003320:	68b8                	ld	a4,80(s1)
    80003322:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003324:	0001f797          	auipc	a5,0x1f
    80003328:	9a478793          	addi	a5,a5,-1628 # 80021cc8 <bcache+0x8000>
    8000332c:	2b87b703          	ld	a4,696(a5)
    80003330:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003332:	0001f717          	auipc	a4,0x1f
    80003336:	bfe70713          	addi	a4,a4,-1026 # 80021f30 <bcache+0x8268>
    8000333a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000333c:	2b87b703          	ld	a4,696(a5)
    80003340:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003342:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80003346:	00017517          	auipc	a0,0x17
    8000334a:	98250513          	addi	a0,a0,-1662 # 80019cc8 <bcache>
    8000334e:	911fd0ef          	jal	80000c5e <release>
}
    80003352:	60e2                	ld	ra,24(sp)
    80003354:	6442                	ld	s0,16(sp)
    80003356:	64a2                	ld	s1,8(sp)
    80003358:	6902                	ld	s2,0(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret
    panic("brelse");
    8000335e:	00005517          	auipc	a0,0x5
    80003362:	1ba50513          	addi	a0,a0,442 # 80008518 <etext+0x518>
    80003366:	c8afd0ef          	jal	800007f0 <panic>

000000008000336a <bpin>:

void
bpin(struct buf *b)
{
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	e426                	sd	s1,8(sp)
    80003372:	1000                	addi	s0,sp,32
    80003374:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003376:	00017517          	auipc	a0,0x17
    8000337a:	95250513          	addi	a0,a0,-1710 # 80019cc8 <bcache>
    8000337e:	855fd0ef          	jal	80000bd2 <acquire>
  b->refcnt++;
    80003382:	40bc                	lw	a5,64(s1)
    80003384:	2785                	addiw	a5,a5,1
    80003386:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003388:	00017517          	auipc	a0,0x17
    8000338c:	94050513          	addi	a0,a0,-1728 # 80019cc8 <bcache>
    80003390:	8cffd0ef          	jal	80000c5e <release>
}
    80003394:	60e2                	ld	ra,24(sp)
    80003396:	6442                	ld	s0,16(sp)
    80003398:	64a2                	ld	s1,8(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <bunpin>:

void
bunpin(struct buf *b)
{
    8000339e:	1101                	addi	sp,sp,-32
    800033a0:	ec06                	sd	ra,24(sp)
    800033a2:	e822                	sd	s0,16(sp)
    800033a4:	e426                	sd	s1,8(sp)
    800033a6:	1000                	addi	s0,sp,32
    800033a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033aa:	00017517          	auipc	a0,0x17
    800033ae:	91e50513          	addi	a0,a0,-1762 # 80019cc8 <bcache>
    800033b2:	821fd0ef          	jal	80000bd2 <acquire>
  b->refcnt--;
    800033b6:	40bc                	lw	a5,64(s1)
    800033b8:	37fd                	addiw	a5,a5,-1
    800033ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033bc:	00017517          	auipc	a0,0x17
    800033c0:	90c50513          	addi	a0,a0,-1780 # 80019cc8 <bcache>
    800033c4:	89bfd0ef          	jal	80000c5e <release>
}
    800033c8:	60e2                	ld	ra,24(sp)
    800033ca:	6442                	ld	s0,16(sp)
    800033cc:	64a2                	ld	s1,8(sp)
    800033ce:	6105                	addi	sp,sp,32
    800033d0:	8082                	ret

00000000800033d2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033d2:	1101                	addi	sp,sp,-32
    800033d4:	ec06                	sd	ra,24(sp)
    800033d6:	e822                	sd	s0,16(sp)
    800033d8:	e426                	sd	s1,8(sp)
    800033da:	e04a                	sd	s2,0(sp)
    800033dc:	1000                	addi	s0,sp,32
    800033de:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033e0:	00d5d59b          	srliw	a1,a1,0xd
    800033e4:	0001f797          	auipc	a5,0x1f
    800033e8:	fc07a783          	lw	a5,-64(a5) # 800223a4 <sb+0x1c>
    800033ec:	9dbd                	addw	a1,a1,a5
    800033ee:	dedff0ef          	jal	800031da <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033f2:	0074f713          	andi	a4,s1,7
    800033f6:	4785                	li	a5,1
    800033f8:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    800033fc:	14ce                	slli	s1,s1,0x33
    800033fe:	90d9                	srli	s1,s1,0x36
    80003400:	00950733          	add	a4,a0,s1
    80003404:	05874703          	lbu	a4,88(a4)
    80003408:	00e7f6b3          	and	a3,a5,a4
    8000340c:	c29d                	beqz	a3,80003432 <bfree+0x60>
    8000340e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80003410:	94aa                	add	s1,s1,a0
    80003412:	fff7c793          	not	a5,a5
    80003416:	8f7d                	and	a4,a4,a5
    80003418:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000341c:	078010ef          	jal	80004494 <log_write>
  brelse(bp);
    80003420:	854a                	mv	a0,s2
    80003422:	ec1ff0ef          	jal	800032e2 <brelse>
}
    80003426:	60e2                	ld	ra,24(sp)
    80003428:	6442                	ld	s0,16(sp)
    8000342a:	64a2                	ld	s1,8(sp)
    8000342c:	6902                	ld	s2,0(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret
    panic("freeing free block");
    80003432:	00005517          	auipc	a0,0x5
    80003436:	0ee50513          	addi	a0,a0,238 # 80008520 <etext+0x520>
    8000343a:	bb6fd0ef          	jal	800007f0 <panic>

000000008000343e <balloc>:
{
    8000343e:	711d                	addi	sp,sp,-96
    80003440:	ec86                	sd	ra,88(sp)
    80003442:	e8a2                	sd	s0,80(sp)
    80003444:	e4a6                	sd	s1,72(sp)
    80003446:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80003448:	0001f797          	auipc	a5,0x1f
    8000344c:	f447a783          	lw	a5,-188(a5) # 8002238c <sb+0x4>
    80003450:	0e078f63          	beqz	a5,8000354e <balloc+0x110>
    80003454:	e0ca                	sd	s2,64(sp)
    80003456:	fc4e                	sd	s3,56(sp)
    80003458:	f852                	sd	s4,48(sp)
    8000345a:	f456                	sd	s5,40(sp)
    8000345c:	f05a                	sd	s6,32(sp)
    8000345e:	ec5e                	sd	s7,24(sp)
    80003460:	e862                	sd	s8,16(sp)
    80003462:	e466                	sd	s9,8(sp)
    80003464:	8baa                	mv	s7,a0
    80003466:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003468:	0001fb17          	auipc	s6,0x1f
    8000346c:	f20b0b13          	addi	s6,s6,-224 # 80022388 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003470:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003472:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003474:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80003476:	6c89                	lui	s9,0x2
    80003478:	a0b5                	j	800034e4 <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    8000347a:	97ca                	add	a5,a5,s2
    8000347c:	8e55                	or	a2,a2,a3
    8000347e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	010010ef          	jal	80004494 <log_write>
        brelse(bp);
    80003488:	854a                	mv	a0,s2
    8000348a:	e59ff0ef          	jal	800032e2 <brelse>
  bp = bread(dev, bno);
    8000348e:	85a6                	mv	a1,s1
    80003490:	855e                	mv	a0,s7
    80003492:	d49ff0ef          	jal	800031da <bread>
    80003496:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003498:	40000613          	li	a2,1024
    8000349c:	4581                	li	a1,0
    8000349e:	05850513          	addi	a0,a0,88
    800034a2:	ff4fd0ef          	jal	80000c96 <memset>
  log_write(bp);
    800034a6:	854a                	mv	a0,s2
    800034a8:	7ed000ef          	jal	80004494 <log_write>
  brelse(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	e35ff0ef          	jal	800032e2 <brelse>
}
    800034b2:	6906                	ld	s2,64(sp)
    800034b4:	79e2                	ld	s3,56(sp)
    800034b6:	7a42                	ld	s4,48(sp)
    800034b8:	7aa2                	ld	s5,40(sp)
    800034ba:	7b02                	ld	s6,32(sp)
    800034bc:	6be2                	ld	s7,24(sp)
    800034be:	6c42                	ld	s8,16(sp)
    800034c0:	6ca2                	ld	s9,8(sp)
}
    800034c2:	8526                	mv	a0,s1
    800034c4:	60e6                	ld	ra,88(sp)
    800034c6:	6446                	ld	s0,80(sp)
    800034c8:	64a6                	ld	s1,72(sp)
    800034ca:	6125                	addi	sp,sp,96
    800034cc:	8082                	ret
    brelse(bp);
    800034ce:	854a                	mv	a0,s2
    800034d0:	e13ff0ef          	jal	800032e2 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    800034d4:	015c87bb          	addw	a5,s9,s5
    800034d8:	00078a9b          	sext.w	s5,a5
    800034dc:	004b2703          	lw	a4,4(s6)
    800034e0:	04eaff63          	bgeu	s5,a4,8000353e <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800034e4:	41fad79b          	sraiw	a5,s5,0x1f
    800034e8:	0137d79b          	srliw	a5,a5,0x13
    800034ec:	015787bb          	addw	a5,a5,s5
    800034f0:	40d7d79b          	sraiw	a5,a5,0xd
    800034f4:	01cb2583          	lw	a1,28(s6)
    800034f8:	9dbd                	addw	a1,a1,a5
    800034fa:	855e                	mv	a0,s7
    800034fc:	cdfff0ef          	jal	800031da <bread>
    80003500:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003502:	004b2503          	lw	a0,4(s6)
    80003506:	000a849b          	sext.w	s1,s5
    8000350a:	8762                	mv	a4,s8
    8000350c:	fca4f1e3          	bgeu	s1,a0,800034ce <balloc+0x90>
      m = 1 << (bi % 8);
    80003510:	00777693          	andi	a3,a4,7
    80003514:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003518:	41f7579b          	sraiw	a5,a4,0x1f
    8000351c:	01d7d79b          	srliw	a5,a5,0x1d
    80003520:	9fb9                	addw	a5,a5,a4
    80003522:	4037d79b          	sraiw	a5,a5,0x3
    80003526:	00f90633          	add	a2,s2,a5
    8000352a:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000352e:	00c6f5b3          	and	a1,a3,a2
    80003532:	d5a1                	beqz	a1,8000347a <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80003534:	2705                	addiw	a4,a4,1
    80003536:	2485                	addiw	s1,s1,1
    80003538:	fd471ae3          	bne	a4,s4,8000350c <balloc+0xce>
    8000353c:	bf49                	j	800034ce <balloc+0x90>
    8000353e:	6906                	ld	s2,64(sp)
    80003540:	79e2                	ld	s3,56(sp)
    80003542:	7a42                	ld	s4,48(sp)
    80003544:	7aa2                	ld	s5,40(sp)
    80003546:	7b02                	ld	s6,32(sp)
    80003548:	6be2                	ld	s7,24(sp)
    8000354a:	6c42                	ld	s8,16(sp)
    8000354c:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    8000354e:	00005517          	auipc	a0,0x5
    80003552:	fea50513          	addi	a0,a0,-22 # 80008538 <etext+0x538>
    80003556:	fb5fc0ef          	jal	8000050a <printk>
  return 0;
    8000355a:	4481                	li	s1,0
    8000355c:	b79d                	j	800034c2 <balloc+0x84>

000000008000355e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000355e:	7179                	addi	sp,sp,-48
    80003560:	f406                	sd	ra,40(sp)
    80003562:	f022                	sd	s0,32(sp)
    80003564:	ec26                	sd	s1,24(sp)
    80003566:	e84a                	sd	s2,16(sp)
    80003568:	e44e                	sd	s3,8(sp)
    8000356a:	1800                	addi	s0,sp,48
    8000356c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    8000356e:	47ad                	li	a5,11
    80003570:	02b7e663          	bltu	a5,a1,8000359c <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80003574:	02059793          	slli	a5,a1,0x20
    80003578:	01e7d593          	srli	a1,a5,0x1e
    8000357c:	00b504b3          	add	s1,a0,a1
    80003580:	0504a903          	lw	s2,80(s1)
    80003584:	06091a63          	bnez	s2,800035f8 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003588:	4108                	lw	a0,0(a0)
    8000358a:	eb5ff0ef          	jal	8000343e <balloc>
    8000358e:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80003592:	06090363          	beqz	s2,800035f8 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003596:	0524a823          	sw	s2,80(s1)
    8000359a:	a8b9                	j	800035f8 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000359c:	ff45849b          	addiw	s1,a1,-12
    800035a0:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    800035a4:	0ff00793          	li	a5,255
    800035a8:	06e7ee63          	bltu	a5,a4,80003624 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    800035ac:	08052903          	lw	s2,128(a0)
    800035b0:	00091d63          	bnez	s2,800035ca <bmap+0x6c>
      addr = balloc(ip->dev);
    800035b4:	4108                	lw	a0,0(a0)
    800035b6:	e89ff0ef          	jal	8000343e <balloc>
    800035ba:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    800035be:	02090d63          	beqz	s2,800035f8 <bmap+0x9a>
    800035c2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035c4:	0929a023          	sw	s2,128(s3)
    800035c8:	a011                	j	800035cc <bmap+0x6e>
    800035ca:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800035cc:	85ca                	mv	a1,s2
    800035ce:	0009a503          	lw	a0,0(s3)
    800035d2:	c09ff0ef          	jal	800031da <bread>
    800035d6:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800035d8:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800035dc:	02049713          	slli	a4,s1,0x20
    800035e0:	01e75593          	srli	a1,a4,0x1e
    800035e4:	00b784b3          	add	s1,a5,a1
    800035e8:	0004a903          	lw	s2,0(s1)
    800035ec:	00090e63          	beqz	s2,80003608 <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035f0:	8552                	mv	a0,s4
    800035f2:	cf1ff0ef          	jal	800032e2 <brelse>
    return addr;
    800035f6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800035f8:	854a                	mv	a0,s2
    800035fa:	70a2                	ld	ra,40(sp)
    800035fc:	7402                	ld	s0,32(sp)
    800035fe:	64e2                	ld	s1,24(sp)
    80003600:	6942                	ld	s2,16(sp)
    80003602:	69a2                	ld	s3,8(sp)
    80003604:	6145                	addi	sp,sp,48
    80003606:	8082                	ret
      addr = balloc(ip->dev);
    80003608:	0009a503          	lw	a0,0(s3)
    8000360c:	e33ff0ef          	jal	8000343e <balloc>
    80003610:	0005091b          	sext.w	s2,a0
      if (addr) {
    80003614:	fc090ee3          	beqz	s2,800035f0 <bmap+0x92>
        a[bn] = addr;
    80003618:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000361c:	8552                	mv	a0,s4
    8000361e:	677000ef          	jal	80004494 <log_write>
    80003622:	b7f9                	j	800035f0 <bmap+0x92>
    80003624:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003626:	00005517          	auipc	a0,0x5
    8000362a:	f2a50513          	addi	a0,a0,-214 # 80008550 <etext+0x550>
    8000362e:	9c2fd0ef          	jal	800007f0 <panic>

0000000080003632 <iget>:
{
    80003632:	7179                	addi	sp,sp,-48
    80003634:	f406                	sd	ra,40(sp)
    80003636:	f022                	sd	s0,32(sp)
    80003638:	ec26                	sd	s1,24(sp)
    8000363a:	e84a                	sd	s2,16(sp)
    8000363c:	e44e                	sd	s3,8(sp)
    8000363e:	e052                	sd	s4,0(sp)
    80003640:	1800                	addi	s0,sp,48
    80003642:	89aa                	mv	s3,a0
    80003644:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003646:	0001f517          	auipc	a0,0x1f
    8000364a:	d6250513          	addi	a0,a0,-670 # 800223a8 <itable>
    8000364e:	d84fd0ef          	jal	80000bd2 <acquire>
  empty = 0;
    80003652:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003654:	0001f497          	auipc	s1,0x1f
    80003658:	d6c48493          	addi	s1,s1,-660 # 800223c0 <itable+0x18>
    8000365c:	00020697          	auipc	a3,0x20
    80003660:	7f468693          	addi	a3,a3,2036 # 80023e50 <log>
    80003664:	a039                	j	80003672 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003666:	02090963          	beqz	s2,80003698 <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    8000366a:	08848493          	addi	s1,s1,136
    8000366e:	02d48863          	beq	s1,a3,8000369e <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003672:	449c                	lw	a5,8(s1)
    80003674:	fef059e3          	blez	a5,80003666 <iget+0x34>
    80003678:	4098                	lw	a4,0(s1)
    8000367a:	ff3716e3          	bne	a4,s3,80003666 <iget+0x34>
    8000367e:	40d8                	lw	a4,4(s1)
    80003680:	ff4713e3          	bne	a4,s4,80003666 <iget+0x34>
      ip->ref++;
    80003684:	2785                	addiw	a5,a5,1
    80003686:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003688:	0001f517          	auipc	a0,0x1f
    8000368c:	d2050513          	addi	a0,a0,-736 # 800223a8 <itable>
    80003690:	dcefd0ef          	jal	80000c5e <release>
      return ip;
    80003694:	8926                	mv	s2,s1
    80003696:	a02d                	j	800036c0 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003698:	fbe9                	bnez	a5,8000366a <iget+0x38>
      empty = ip;
    8000369a:	8926                	mv	s2,s1
    8000369c:	b7f9                	j	8000366a <iget+0x38>
  if (empty == 0)
    8000369e:	02090a63          	beqz	s2,800036d2 <iget+0xa0>
  ip->dev = dev;
    800036a2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036a6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036aa:	4785                	li	a5,1
    800036ac:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036b0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036b4:	0001f517          	auipc	a0,0x1f
    800036b8:	cf450513          	addi	a0,a0,-780 # 800223a8 <itable>
    800036bc:	da2fd0ef          	jal	80000c5e <release>
}
    800036c0:	854a                	mv	a0,s2
    800036c2:	70a2                	ld	ra,40(sp)
    800036c4:	7402                	ld	s0,32(sp)
    800036c6:	64e2                	ld	s1,24(sp)
    800036c8:	6942                	ld	s2,16(sp)
    800036ca:	69a2                	ld	s3,8(sp)
    800036cc:	6a02                	ld	s4,0(sp)
    800036ce:	6145                	addi	sp,sp,48
    800036d0:	8082                	ret
    panic("iget: no inodes");
    800036d2:	00005517          	auipc	a0,0x5
    800036d6:	e9650513          	addi	a0,a0,-362 # 80008568 <etext+0x568>
    800036da:	916fd0ef          	jal	800007f0 <panic>

00000000800036de <iinit>:
{
    800036de:	7179                	addi	sp,sp,-48
    800036e0:	f406                	sd	ra,40(sp)
    800036e2:	f022                	sd	s0,32(sp)
    800036e4:	ec26                	sd	s1,24(sp)
    800036e6:	e84a                	sd	s2,16(sp)
    800036e8:	e44e                	sd	s3,8(sp)
    800036ea:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036ec:	00005597          	auipc	a1,0x5
    800036f0:	e8c58593          	addi	a1,a1,-372 # 80008578 <etext+0x578>
    800036f4:	0001f517          	auipc	a0,0x1f
    800036f8:	cb450513          	addi	a0,a0,-844 # 800223a8 <itable>
    800036fc:	c60fd0ef          	jal	80000b5c <initlock>
  for (i = 0; i < NINODE; i++) {
    80003700:	0001f497          	auipc	s1,0x1f
    80003704:	cd048493          	addi	s1,s1,-816 # 800223d0 <itable+0x28>
    80003708:	00020997          	auipc	s3,0x20
    8000370c:	75898993          	addi	s3,s3,1880 # 80023e60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003710:	00005917          	auipc	s2,0x5
    80003714:	e7090913          	addi	s2,s2,-400 # 80008580 <etext+0x580>
    80003718:	85ca                	mv	a1,s2
    8000371a:	8526                	mv	a0,s1
    8000371c:	6ab000ef          	jal	800045c6 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003720:	08848493          	addi	s1,s1,136
    80003724:	ff349ae3          	bne	s1,s3,80003718 <iinit+0x3a>
}
    80003728:	70a2                	ld	ra,40(sp)
    8000372a:	7402                	ld	s0,32(sp)
    8000372c:	64e2                	ld	s1,24(sp)
    8000372e:	6942                	ld	s2,16(sp)
    80003730:	69a2                	ld	s3,8(sp)
    80003732:	6145                	addi	sp,sp,48
    80003734:	8082                	ret

0000000080003736 <ialloc>:
{
    80003736:	7139                	addi	sp,sp,-64
    80003738:	fc06                	sd	ra,56(sp)
    8000373a:	f822                	sd	s0,48(sp)
    8000373c:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000373e:	0001f717          	auipc	a4,0x1f
    80003742:	c5672703          	lw	a4,-938(a4) # 80022394 <sb+0xc>
    80003746:	4785                	li	a5,1
    80003748:	06e7f063          	bgeu	a5,a4,800037a8 <ialloc+0x72>
    8000374c:	f426                	sd	s1,40(sp)
    8000374e:	f04a                	sd	s2,32(sp)
    80003750:	ec4e                	sd	s3,24(sp)
    80003752:	e852                	sd	s4,16(sp)
    80003754:	e456                	sd	s5,8(sp)
    80003756:	e05a                	sd	s6,0(sp)
    80003758:	8aaa                	mv	s5,a0
    8000375a:	8b2e                	mv	s6,a1
    8000375c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000375e:	0001fa17          	auipc	s4,0x1f
    80003762:	c2aa0a13          	addi	s4,s4,-982 # 80022388 <sb>
    80003766:	00495593          	srli	a1,s2,0x4
    8000376a:	018a2783          	lw	a5,24(s4)
    8000376e:	9dbd                	addw	a1,a1,a5
    80003770:	8556                	mv	a0,s5
    80003772:	a69ff0ef          	jal	800031da <bread>
    80003776:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003778:	05850993          	addi	s3,a0,88
    8000377c:	00f97793          	andi	a5,s2,15
    80003780:	079a                	slli	a5,a5,0x6
    80003782:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003784:	00099783          	lh	a5,0(s3)
    80003788:	cb9d                	beqz	a5,800037be <ialloc+0x88>
    brelse(bp);
    8000378a:	b59ff0ef          	jal	800032e2 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000378e:	0905                	addi	s2,s2,1
    80003790:	00ca2703          	lw	a4,12(s4)
    80003794:	0009079b          	sext.w	a5,s2
    80003798:	fce7e7e3          	bltu	a5,a4,80003766 <ialloc+0x30>
    8000379c:	74a2                	ld	s1,40(sp)
    8000379e:	7902                	ld	s2,32(sp)
    800037a0:	69e2                	ld	s3,24(sp)
    800037a2:	6a42                	ld	s4,16(sp)
    800037a4:	6aa2                	ld	s5,8(sp)
    800037a6:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800037a8:	00005517          	auipc	a0,0x5
    800037ac:	de050513          	addi	a0,a0,-544 # 80008588 <etext+0x588>
    800037b0:	d5bfc0ef          	jal	8000050a <printk>
  return 0;
    800037b4:	4501                	li	a0,0
}
    800037b6:	70e2                	ld	ra,56(sp)
    800037b8:	7442                	ld	s0,48(sp)
    800037ba:	6121                	addi	sp,sp,64
    800037bc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037be:	04000613          	li	a2,64
    800037c2:	4581                	li	a1,0
    800037c4:	854e                	mv	a0,s3
    800037c6:	cd0fd0ef          	jal	80000c96 <memset>
      dip->type = type;
    800037ca:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800037ce:	8526                	mv	a0,s1
    800037d0:	4c5000ef          	jal	80004494 <log_write>
      brelse(bp);
    800037d4:	8526                	mv	a0,s1
    800037d6:	b0dff0ef          	jal	800032e2 <brelse>
      return iget(dev, inum);
    800037da:	0009059b          	sext.w	a1,s2
    800037de:	8556                	mv	a0,s5
    800037e0:	e53ff0ef          	jal	80003632 <iget>
    800037e4:	74a2                	ld	s1,40(sp)
    800037e6:	7902                	ld	s2,32(sp)
    800037e8:	69e2                	ld	s3,24(sp)
    800037ea:	6a42                	ld	s4,16(sp)
    800037ec:	6aa2                	ld	s5,8(sp)
    800037ee:	6b02                	ld	s6,0(sp)
    800037f0:	b7d9                	j	800037b6 <ialloc+0x80>

00000000800037f2 <iupdate>:
{
    800037f2:	1101                	addi	sp,sp,-32
    800037f4:	ec06                	sd	ra,24(sp)
    800037f6:	e822                	sd	s0,16(sp)
    800037f8:	e426                	sd	s1,8(sp)
    800037fa:	e04a                	sd	s2,0(sp)
    800037fc:	1000                	addi	s0,sp,32
    800037fe:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003800:	415c                	lw	a5,4(a0)
    80003802:	0047d79b          	srliw	a5,a5,0x4
    80003806:	0001f597          	auipc	a1,0x1f
    8000380a:	b9a5a583          	lw	a1,-1126(a1) # 800223a0 <sb+0x18>
    8000380e:	9dbd                	addw	a1,a1,a5
    80003810:	4108                	lw	a0,0(a0)
    80003812:	9c9ff0ef          	jal	800031da <bread>
    80003816:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    80003818:	05850793          	addi	a5,a0,88
    8000381c:	40d8                	lw	a4,4(s1)
    8000381e:	8b3d                	andi	a4,a4,15
    80003820:	071a                	slli	a4,a4,0x6
    80003822:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003824:	04449703          	lh	a4,68(s1)
    80003828:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000382c:	04649703          	lh	a4,70(s1)
    80003830:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003834:	04849703          	lh	a4,72(s1)
    80003838:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000383c:	04a49703          	lh	a4,74(s1)
    80003840:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003844:	44f8                	lw	a4,76(s1)
    80003846:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003848:	03400613          	li	a2,52
    8000384c:	05048593          	addi	a1,s1,80
    80003850:	00c78513          	addi	a0,a5,12
    80003854:	c9efd0ef          	jal	80000cf2 <memmove>
  log_write(bp);
    80003858:	854a                	mv	a0,s2
    8000385a:	43b000ef          	jal	80004494 <log_write>
  brelse(bp);
    8000385e:	854a                	mv	a0,s2
    80003860:	a83ff0ef          	jal	800032e2 <brelse>
}
    80003864:	60e2                	ld	ra,24(sp)
    80003866:	6442                	ld	s0,16(sp)
    80003868:	64a2                	ld	s1,8(sp)
    8000386a:	6902                	ld	s2,0(sp)
    8000386c:	6105                	addi	sp,sp,32
    8000386e:	8082                	ret

0000000080003870 <idup>:
{
    80003870:	1101                	addi	sp,sp,-32
    80003872:	ec06                	sd	ra,24(sp)
    80003874:	e822                	sd	s0,16(sp)
    80003876:	e426                	sd	s1,8(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000387c:	0001f517          	auipc	a0,0x1f
    80003880:	b2c50513          	addi	a0,a0,-1236 # 800223a8 <itable>
    80003884:	b4efd0ef          	jal	80000bd2 <acquire>
  ip->ref++;
    80003888:	449c                	lw	a5,8(s1)
    8000388a:	2785                	addiw	a5,a5,1
    8000388c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000388e:	0001f517          	auipc	a0,0x1f
    80003892:	b1a50513          	addi	a0,a0,-1254 # 800223a8 <itable>
    80003896:	bc8fd0ef          	jal	80000c5e <release>
}
    8000389a:	8526                	mv	a0,s1
    8000389c:	60e2                	ld	ra,24(sp)
    8000389e:	6442                	ld	s0,16(sp)
    800038a0:	64a2                	ld	s1,8(sp)
    800038a2:	6105                	addi	sp,sp,32
    800038a4:	8082                	ret

00000000800038a6 <ilock>:
{
    800038a6:	1101                	addi	sp,sp,-32
    800038a8:	ec06                	sd	ra,24(sp)
    800038aa:	e822                	sd	s0,16(sp)
    800038ac:	e426                	sd	s1,8(sp)
    800038ae:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    800038b0:	cd19                	beqz	a0,800038ce <ilock+0x28>
    800038b2:	84aa                	mv	s1,a0
    800038b4:	451c                	lw	a5,8(a0)
    800038b6:	00f05c63          	blez	a5,800038ce <ilock+0x28>
  acquiresleep(&ip->lock);
    800038ba:	0541                	addi	a0,a0,16
    800038bc:	541000ef          	jal	800045fc <acquiresleep>
  if (ip->valid == 0) {
    800038c0:	40bc                	lw	a5,64(s1)
    800038c2:	cf89                	beqz	a5,800038dc <ilock+0x36>
}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6105                	addi	sp,sp,32
    800038cc:	8082                	ret
    800038ce:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800038d0:	00005517          	auipc	a0,0x5
    800038d4:	cd050513          	addi	a0,a0,-816 # 800085a0 <etext+0x5a0>
    800038d8:	f19fc0ef          	jal	800007f0 <panic>
    800038dc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038de:	40dc                	lw	a5,4(s1)
    800038e0:	0047d79b          	srliw	a5,a5,0x4
    800038e4:	0001f597          	auipc	a1,0x1f
    800038e8:	abc5a583          	lw	a1,-1348(a1) # 800223a0 <sb+0x18>
    800038ec:	9dbd                	addw	a1,a1,a5
    800038ee:	4088                	lw	a0,0(s1)
    800038f0:	8ebff0ef          	jal	800031da <bread>
    800038f4:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800038f6:	05850593          	addi	a1,a0,88
    800038fa:	40dc                	lw	a5,4(s1)
    800038fc:	8bbd                	andi	a5,a5,15
    800038fe:	079a                	slli	a5,a5,0x6
    80003900:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003902:	00059783          	lh	a5,0(a1)
    80003906:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000390a:	00259783          	lh	a5,2(a1)
    8000390e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003912:	00459783          	lh	a5,4(a1)
    80003916:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000391a:	00659783          	lh	a5,6(a1)
    8000391e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003922:	459c                	lw	a5,8(a1)
    80003924:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003926:	03400613          	li	a2,52
    8000392a:	05b1                	addi	a1,a1,12
    8000392c:	05048513          	addi	a0,s1,80
    80003930:	bc2fd0ef          	jal	80000cf2 <memmove>
    brelse(bp);
    80003934:	854a                	mv	a0,s2
    80003936:	9adff0ef          	jal	800032e2 <brelse>
    ip->valid = 1;
    8000393a:	4785                	li	a5,1
    8000393c:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000393e:	04449783          	lh	a5,68(s1)
    80003942:	c399                	beqz	a5,80003948 <ilock+0xa2>
    80003944:	6902                	ld	s2,0(sp)
    80003946:	bfbd                	j	800038c4 <ilock+0x1e>
      panic("ilock: no type");
    80003948:	00005517          	auipc	a0,0x5
    8000394c:	c6050513          	addi	a0,a0,-928 # 800085a8 <etext+0x5a8>
    80003950:	ea1fc0ef          	jal	800007f0 <panic>

0000000080003954 <iunlock>:
{
    80003954:	1101                	addi	sp,sp,-32
    80003956:	ec06                	sd	ra,24(sp)
    80003958:	e822                	sd	s0,16(sp)
    8000395a:	e426                	sd	s1,8(sp)
    8000395c:	e04a                	sd	s2,0(sp)
    8000395e:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003960:	c505                	beqz	a0,80003988 <iunlock+0x34>
    80003962:	84aa                	mv	s1,a0
    80003964:	01050913          	addi	s2,a0,16
    80003968:	854a                	mv	a0,s2
    8000396a:	51f000ef          	jal	80004688 <holdingsleep>
    8000396e:	cd09                	beqz	a0,80003988 <iunlock+0x34>
    80003970:	449c                	lw	a5,8(s1)
    80003972:	00f05b63          	blez	a5,80003988 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003976:	854a                	mv	a0,s2
    80003978:	4d9000ef          	jal	80004650 <releasesleep>
}
    8000397c:	60e2                	ld	ra,24(sp)
    8000397e:	6442                	ld	s0,16(sp)
    80003980:	64a2                	ld	s1,8(sp)
    80003982:	6902                	ld	s2,0(sp)
    80003984:	6105                	addi	sp,sp,32
    80003986:	8082                	ret
    panic("iunlock");
    80003988:	00005517          	auipc	a0,0x5
    8000398c:	c3050513          	addi	a0,a0,-976 # 800085b8 <etext+0x5b8>
    80003990:	e61fc0ef          	jal	800007f0 <panic>

0000000080003994 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003994:	7179                	addi	sp,sp,-48
    80003996:	f406                	sd	ra,40(sp)
    80003998:	f022                	sd	s0,32(sp)
    8000399a:	ec26                	sd	s1,24(sp)
    8000399c:	e84a                	sd	s2,16(sp)
    8000399e:	e44e                	sd	s3,8(sp)
    800039a0:	1800                	addi	s0,sp,48
    800039a2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800039a4:	05050493          	addi	s1,a0,80
    800039a8:	08050913          	addi	s2,a0,128
    800039ac:	a021                	j	800039b4 <itrunc+0x20>
    800039ae:	0491                	addi	s1,s1,4
    800039b0:	01248b63          	beq	s1,s2,800039c6 <itrunc+0x32>
    if (ip->addrs[i]) {
    800039b4:	408c                	lw	a1,0(s1)
    800039b6:	dde5                	beqz	a1,800039ae <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800039b8:	0009a503          	lw	a0,0(s3)
    800039bc:	a17ff0ef          	jal	800033d2 <bfree>
      ip->addrs[i] = 0;
    800039c0:	0004a023          	sw	zero,0(s1)
    800039c4:	b7ed                	j	800039ae <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800039c6:	0809a583          	lw	a1,128(s3)
    800039ca:	ed89                	bnez	a1,800039e4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039cc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039d0:	854e                	mv	a0,s3
    800039d2:	e21ff0ef          	jal	800037f2 <iupdate>
}
    800039d6:	70a2                	ld	ra,40(sp)
    800039d8:	7402                	ld	s0,32(sp)
    800039da:	64e2                	ld	s1,24(sp)
    800039dc:	6942                	ld	s2,16(sp)
    800039de:	69a2                	ld	s3,8(sp)
    800039e0:	6145                	addi	sp,sp,48
    800039e2:	8082                	ret
    800039e4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039e6:	0009a503          	lw	a0,0(s3)
    800039ea:	ff0ff0ef          	jal	800031da <bread>
    800039ee:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800039f0:	05850493          	addi	s1,a0,88
    800039f4:	45850913          	addi	s2,a0,1112
    800039f8:	a021                	j	80003a00 <itrunc+0x6c>
    800039fa:	0491                	addi	s1,s1,4
    800039fc:	01248963          	beq	s1,s2,80003a0e <itrunc+0x7a>
      if (a[j])
    80003a00:	408c                	lw	a1,0(s1)
    80003a02:	dde5                	beqz	a1,800039fa <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003a04:	0009a503          	lw	a0,0(s3)
    80003a08:	9cbff0ef          	jal	800033d2 <bfree>
    80003a0c:	b7fd                	j	800039fa <itrunc+0x66>
    brelse(bp);
    80003a0e:	8552                	mv	a0,s4
    80003a10:	8d3ff0ef          	jal	800032e2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a14:	0809a583          	lw	a1,128(s3)
    80003a18:	0009a503          	lw	a0,0(s3)
    80003a1c:	9b7ff0ef          	jal	800033d2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a20:	0809a023          	sw	zero,128(s3)
    80003a24:	6a02                	ld	s4,0(sp)
    80003a26:	b75d                	j	800039cc <itrunc+0x38>

0000000080003a28 <iput>:
{
    80003a28:	7179                	addi	sp,sp,-48
    80003a2a:	f406                	sd	ra,40(sp)
    80003a2c:	f022                	sd	s0,32(sp)
    80003a2e:	ec26                	sd	s1,24(sp)
    80003a30:	1800                	addi	s0,sp,48
    80003a32:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a34:	0001f517          	auipc	a0,0x1f
    80003a38:	97450513          	addi	a0,a0,-1676 # 800223a8 <itable>
    80003a3c:	996fd0ef          	jal	80000bd2 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003a40:	449c                	lw	a5,8(s1)
    80003a42:	4705                	li	a4,1
    80003a44:	00e78f63          	beq	a5,a4,80003a62 <iput+0x3a>
  ip->ref--;
    80003a48:	37fd                	addiw	a5,a5,-1
    80003a4a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a4c:	0001f517          	auipc	a0,0x1f
    80003a50:	95c50513          	addi	a0,a0,-1700 # 800223a8 <itable>
    80003a54:	a0afd0ef          	jal	80000c5e <release>
}
    80003a58:	70a2                	ld	ra,40(sp)
    80003a5a:	7402                	ld	s0,32(sp)
    80003a5c:	64e2                	ld	s1,24(sp)
    80003a5e:	6145                	addi	sp,sp,48
    80003a60:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003a62:	40b8                	lw	a4,64(s1)
    80003a64:	d375                	beqz	a4,80003a48 <iput+0x20>
    80003a66:	e84a                	sd	s2,16(sp)
    80003a68:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    80003a6a:	0004aa03          	lw	s4,0(s1)
    80003a6e:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003a72:	04a49703          	lh	a4,74(s1)
    80003a76:	ef35                	bnez	a4,80003af2 <iput+0xca>
    80003a78:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    80003a7a:	01048993          	addi	s3,s1,16
    80003a7e:	854e                	mv	a0,s3
    80003a80:	37d000ef          	jal	800045fc <acquiresleep>
    release(&itable.lock);
    80003a84:	0001f517          	auipc	a0,0x1f
    80003a88:	92450513          	addi	a0,a0,-1756 # 800223a8 <itable>
    80003a8c:	9d2fd0ef          	jal	80000c5e <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003a90:	8526                	mv	a0,s1
    80003a92:	f03ff0ef          	jal	80003994 <itrunc>
    ip->valid = 0;
    80003a96:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a9a:	854e                	mv	a0,s3
    80003a9c:	3b5000ef          	jal	80004650 <releasesleep>
    acquire(&itable.lock);
    80003aa0:	0001f517          	auipc	a0,0x1f
    80003aa4:	90850513          	addi	a0,a0,-1784 # 800223a8 <itable>
    80003aa8:	92afd0ef          	jal	80000bd2 <acquire>
  ip->ref--;
    80003aac:	449c                	lw	a5,8(s1)
    80003aae:	37fd                	addiw	a5,a5,-1
    80003ab0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ab2:	0001f517          	auipc	a0,0x1f
    80003ab6:	8f650513          	addi	a0,a0,-1802 # 800223a8 <itable>
    80003aba:	9a4fd0ef          	jal	80000c5e <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003abe:	0049559b          	srliw	a1,s2,0x4
    80003ac2:	0001f797          	auipc	a5,0x1f
    80003ac6:	8de7a783          	lw	a5,-1826(a5) # 800223a0 <sb+0x18>
    80003aca:	9dbd                	addw	a1,a1,a5
    80003acc:	8552                	mv	a0,s4
    80003ace:	f0cff0ef          	jal	800031da <bread>
    80003ad2:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ad4:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    80003ad8:	091a                	slli	s2,s2,0x6
    80003ada:	992a                	add	s2,s2,a0
    80003adc:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    80003ae0:	1b5000ef          	jal	80004494 <log_write>
  brelse(bp);
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	ffcff0ef          	jal	800032e2 <brelse>
}
    80003aea:	6942                	ld	s2,16(sp)
    80003aec:	69a2                	ld	s3,8(sp)
    80003aee:	6a02                	ld	s4,0(sp)
    80003af0:	b7a5                	j	80003a58 <iput+0x30>
    80003af2:	6942                	ld	s2,16(sp)
    80003af4:	6a02                	ld	s4,0(sp)
    80003af6:	bf89                	j	80003a48 <iput+0x20>

0000000080003af8 <iunlockput>:
{
    80003af8:	1101                	addi	sp,sp,-32
    80003afa:	ec06                	sd	ra,24(sp)
    80003afc:	e822                	sd	s0,16(sp)
    80003afe:	e426                	sd	s1,8(sp)
    80003b00:	1000                	addi	s0,sp,32
    80003b02:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b04:	e51ff0ef          	jal	80003954 <iunlock>
  iput(ip);
    80003b08:	8526                	mv	a0,s1
    80003b0a:	f1fff0ef          	jal	80003a28 <iput>
}
    80003b0e:	60e2                	ld	ra,24(sp)
    80003b10:	6442                	ld	s0,16(sp)
    80003b12:	64a2                	ld	s1,8(sp)
    80003b14:	6105                	addi	sp,sp,32
    80003b16:	8082                	ret

0000000080003b18 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b18:	0001f717          	auipc	a4,0x1f
    80003b1c:	87c72703          	lw	a4,-1924(a4) # 80022394 <sb+0xc>
    80003b20:	4785                	li	a5,1
    80003b22:	0ae7ff63          	bgeu	a5,a4,80003be0 <ireclaim+0xc8>
{
    80003b26:	7139                	addi	sp,sp,-64
    80003b28:	fc06                	sd	ra,56(sp)
    80003b2a:	f822                	sd	s0,48(sp)
    80003b2c:	f426                	sd	s1,40(sp)
    80003b2e:	f04a                	sd	s2,32(sp)
    80003b30:	ec4e                	sd	s3,24(sp)
    80003b32:	e852                	sd	s4,16(sp)
    80003b34:	e456                	sd	s5,8(sp)
    80003b36:	e05a                	sd	s6,0(sp)
    80003b38:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b3a:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b3c:	00050a1b          	sext.w	s4,a0
    80003b40:	0001fa97          	auipc	s5,0x1f
    80003b44:	848a8a93          	addi	s5,s5,-1976 # 80022388 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003b48:	00005b17          	auipc	s6,0x5
    80003b4c:	a78b0b13          	addi	s6,s6,-1416 # 800085c0 <etext+0x5c0>
    80003b50:	a099                	j	80003b96 <ireclaim+0x7e>
    80003b52:	85ce                	mv	a1,s3
    80003b54:	855a                	mv	a0,s6
    80003b56:	9b5fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    80003b5a:	85ce                	mv	a1,s3
    80003b5c:	8552                	mv	a0,s4
    80003b5e:	ad5ff0ef          	jal	80003632 <iget>
    80003b62:	89aa                	mv	s3,a0
    brelse(bp);
    80003b64:	854a                	mv	a0,s2
    80003b66:	f7cff0ef          	jal	800032e2 <brelse>
    if (ip) {
    80003b6a:	00098f63          	beqz	s3,80003b88 <ireclaim+0x70>
      begin_op();
    80003b6e:	780000ef          	jal	800042ee <begin_op>
      ilock(ip);
    80003b72:	854e                	mv	a0,s3
    80003b74:	d33ff0ef          	jal	800038a6 <ilock>
      iunlock(ip);
    80003b78:	854e                	mv	a0,s3
    80003b7a:	ddbff0ef          	jal	80003954 <iunlock>
      iput(ip);
    80003b7e:	854e                	mv	a0,s3
    80003b80:	ea9ff0ef          	jal	80003a28 <iput>
      end_op();
    80003b84:	7f0000ef          	jal	80004374 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b88:	0485                	addi	s1,s1,1
    80003b8a:	00caa703          	lw	a4,12(s5)
    80003b8e:	0004879b          	sext.w	a5,s1
    80003b92:	02e7fd63          	bgeu	a5,a4,80003bcc <ireclaim+0xb4>
    80003b96:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b9a:	0044d593          	srli	a1,s1,0x4
    80003b9e:	018aa783          	lw	a5,24(s5)
    80003ba2:	9dbd                	addw	a1,a1,a5
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	e34ff0ef          	jal	800031da <bread>
    80003baa:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003bac:	05850793          	addi	a5,a0,88
    80003bb0:	00f9f713          	andi	a4,s3,15
    80003bb4:	071a                	slli	a4,a4,0x6
    80003bb6:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003bb8:	00079703          	lh	a4,0(a5)
    80003bbc:	c701                	beqz	a4,80003bc4 <ireclaim+0xac>
    80003bbe:	00679783          	lh	a5,6(a5)
    80003bc2:	dbc1                	beqz	a5,80003b52 <ireclaim+0x3a>
    brelse(bp);
    80003bc4:	854a                	mv	a0,s2
    80003bc6:	f1cff0ef          	jal	800032e2 <brelse>
    if (ip) {
    80003bca:	bf7d                	j	80003b88 <ireclaim+0x70>
}
    80003bcc:	70e2                	ld	ra,56(sp)
    80003bce:	7442                	ld	s0,48(sp)
    80003bd0:	74a2                	ld	s1,40(sp)
    80003bd2:	7902                	ld	s2,32(sp)
    80003bd4:	69e2                	ld	s3,24(sp)
    80003bd6:	6a42                	ld	s4,16(sp)
    80003bd8:	6aa2                	ld	s5,8(sp)
    80003bda:	6b02                	ld	s6,0(sp)
    80003bdc:	6121                	addi	sp,sp,64
    80003bde:	8082                	ret
    80003be0:	8082                	ret

0000000080003be2 <fsinit>:
{
    80003be2:	7179                	addi	sp,sp,-48
    80003be4:	f406                	sd	ra,40(sp)
    80003be6:	f022                	sd	s0,32(sp)
    80003be8:	ec26                	sd	s1,24(sp)
    80003bea:	e84a                	sd	s2,16(sp)
    80003bec:	e44e                	sd	s3,8(sp)
    80003bee:	1800                	addi	s0,sp,48
    80003bf0:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003bf2:	4585                	li	a1,1
    80003bf4:	de6ff0ef          	jal	800031da <bread>
    80003bf8:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003bfa:	0001e997          	auipc	s3,0x1e
    80003bfe:	78e98993          	addi	s3,s3,1934 # 80022388 <sb>
    80003c02:	02000613          	li	a2,32
    80003c06:	05850593          	addi	a1,a0,88
    80003c0a:	854e                	mv	a0,s3
    80003c0c:	8e6fd0ef          	jal	80000cf2 <memmove>
  brelse(bp);
    80003c10:	854a                	mv	a0,s2
    80003c12:	ed0ff0ef          	jal	800032e2 <brelse>
  if (sb.magic != FSMAGIC)
    80003c16:	0009a703          	lw	a4,0(s3)
    80003c1a:	102037b7          	lui	a5,0x10203
    80003c1e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c22:	02f71363          	bne	a4,a5,80003c48 <fsinit+0x66>
  initlog(dev, &sb);
    80003c26:	0001e597          	auipc	a1,0x1e
    80003c2a:	76258593          	addi	a1,a1,1890 # 80022388 <sb>
    80003c2e:	8526                	mv	a0,s1
    80003c30:	640000ef          	jal	80004270 <initlog>
  ireclaim(dev);
    80003c34:	8526                	mv	a0,s1
    80003c36:	ee3ff0ef          	jal	80003b18 <ireclaim>
}
    80003c3a:	70a2                	ld	ra,40(sp)
    80003c3c:	7402                	ld	s0,32(sp)
    80003c3e:	64e2                	ld	s1,24(sp)
    80003c40:	6942                	ld	s2,16(sp)
    80003c42:	69a2                	ld	s3,8(sp)
    80003c44:	6145                	addi	sp,sp,48
    80003c46:	8082                	ret
    panic("invalid file system");
    80003c48:	00005517          	auipc	a0,0x5
    80003c4c:	99850513          	addi	a0,a0,-1640 # 800085e0 <etext+0x5e0>
    80003c50:	ba1fc0ef          	jal	800007f0 <panic>

0000000080003c54 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c54:	1141                	addi	sp,sp,-16
    80003c56:	e422                	sd	s0,8(sp)
    80003c58:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c5a:	411c                	lw	a5,0(a0)
    80003c5c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c5e:	415c                	lw	a5,4(a0)
    80003c60:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c62:	04451783          	lh	a5,68(a0)
    80003c66:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c6a:	04a51783          	lh	a5,74(a0)
    80003c6e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c72:	04c56783          	lwu	a5,76(a0)
    80003c76:	e99c                	sd	a5,16(a1)
}
    80003c78:	6422                	ld	s0,8(sp)
    80003c7a:	0141                	addi	sp,sp,16
    80003c7c:	8082                	ret

0000000080003c7e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003c7e:	457c                	lw	a5,76(a0)
    80003c80:	0ed7eb63          	bltu	a5,a3,80003d76 <readi+0xf8>
{
    80003c84:	7159                	addi	sp,sp,-112
    80003c86:	f486                	sd	ra,104(sp)
    80003c88:	f0a2                	sd	s0,96(sp)
    80003c8a:	eca6                	sd	s1,88(sp)
    80003c8c:	e0d2                	sd	s4,64(sp)
    80003c8e:	fc56                	sd	s5,56(sp)
    80003c90:	f85a                	sd	s6,48(sp)
    80003c92:	f45e                	sd	s7,40(sp)
    80003c94:	1880                	addi	s0,sp,112
    80003c96:	8b2a                	mv	s6,a0
    80003c98:	8bae                	mv	s7,a1
    80003c9a:	8a32                	mv	s4,a2
    80003c9c:	84b6                	mv	s1,a3
    80003c9e:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003ca0:	9f35                	addw	a4,a4,a3
    return 0;
    80003ca2:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003ca4:	0cd76063          	bltu	a4,a3,80003d64 <readi+0xe6>
    80003ca8:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003caa:	00e7f463          	bgeu	a5,a4,80003cb2 <readi+0x34>
    n = ip->size - off;
    80003cae:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003cb2:	080a8f63          	beqz	s5,80003d50 <readi+0xd2>
    80003cb6:	e8ca                	sd	s2,80(sp)
    80003cb8:	f062                	sd	s8,32(sp)
    80003cba:	ec66                	sd	s9,24(sp)
    80003cbc:	e86a                	sd	s10,16(sp)
    80003cbe:	e46e                	sd	s11,8(sp)
    80003cc0:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003cc2:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cc6:	5c7d                	li	s8,-1
    80003cc8:	a80d                	j	80003cfa <readi+0x7c>
    80003cca:	020d1d93          	slli	s11,s10,0x20
    80003cce:	020ddd93          	srli	s11,s11,0x20
    80003cd2:	05890613          	addi	a2,s2,88
    80003cd6:	86ee                	mv	a3,s11
    80003cd8:	963a                	add	a2,a2,a4
    80003cda:	85d2                	mv	a1,s4
    80003cdc:	855e                	mv	a0,s7
    80003cde:	e36fe0ef          	jal	80002314 <either_copyout>
    80003ce2:	05850763          	beq	a0,s8,80003d30 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	dfaff0ef          	jal	800032e2 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003cec:	013d09bb          	addw	s3,s10,s3
    80003cf0:	009d04bb          	addw	s1,s10,s1
    80003cf4:	9a6e                	add	s4,s4,s11
    80003cf6:	0559f763          	bgeu	s3,s5,80003d44 <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    80003cfa:	00a4d59b          	srliw	a1,s1,0xa
    80003cfe:	855a                	mv	a0,s6
    80003d00:	85fff0ef          	jal	8000355e <bmap>
    80003d04:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003d08:	c5b1                	beqz	a1,80003d54 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003d0a:	000b2503          	lw	a0,0(s6)
    80003d0e:	cccff0ef          	jal	800031da <bread>
    80003d12:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003d14:	3ff4f713          	andi	a4,s1,1023
    80003d18:	40ec87bb          	subw	a5,s9,a4
    80003d1c:	413a86bb          	subw	a3,s5,s3
    80003d20:	8d3e                	mv	s10,a5
    80003d22:	2781                	sext.w	a5,a5
    80003d24:	0006861b          	sext.w	a2,a3
    80003d28:	faf671e3          	bgeu	a2,a5,80003cca <readi+0x4c>
    80003d2c:	8d36                	mv	s10,a3
    80003d2e:	bf71                	j	80003cca <readi+0x4c>
      brelse(bp);
    80003d30:	854a                	mv	a0,s2
    80003d32:	db0ff0ef          	jal	800032e2 <brelse>
      tot = -1;
    80003d36:	59fd                	li	s3,-1
      break;
    80003d38:	6946                	ld	s2,80(sp)
    80003d3a:	7c02                	ld	s8,32(sp)
    80003d3c:	6ce2                	ld	s9,24(sp)
    80003d3e:	6d42                	ld	s10,16(sp)
    80003d40:	6da2                	ld	s11,8(sp)
    80003d42:	a831                	j	80003d5e <readi+0xe0>
    80003d44:	6946                	ld	s2,80(sp)
    80003d46:	7c02                	ld	s8,32(sp)
    80003d48:	6ce2                	ld	s9,24(sp)
    80003d4a:	6d42                	ld	s10,16(sp)
    80003d4c:	6da2                	ld	s11,8(sp)
    80003d4e:	a801                	j	80003d5e <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003d50:	89d6                	mv	s3,s5
    80003d52:	a031                	j	80003d5e <readi+0xe0>
    80003d54:	6946                	ld	s2,80(sp)
    80003d56:	7c02                	ld	s8,32(sp)
    80003d58:	6ce2                	ld	s9,24(sp)
    80003d5a:	6d42                	ld	s10,16(sp)
    80003d5c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003d5e:	0009851b          	sext.w	a0,s3
    80003d62:	69a6                	ld	s3,72(sp)
}
    80003d64:	70a6                	ld	ra,104(sp)
    80003d66:	7406                	ld	s0,96(sp)
    80003d68:	64e6                	ld	s1,88(sp)
    80003d6a:	6a06                	ld	s4,64(sp)
    80003d6c:	7ae2                	ld	s5,56(sp)
    80003d6e:	7b42                	ld	s6,48(sp)
    80003d70:	7ba2                	ld	s7,40(sp)
    80003d72:	6165                	addi	sp,sp,112
    80003d74:	8082                	ret
    return 0;
    80003d76:	4501                	li	a0,0
}
    80003d78:	8082                	ret

0000000080003d7a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003d7a:	457c                	lw	a5,76(a0)
    80003d7c:	10d7e363          	bltu	a5,a3,80003e82 <writei+0x108>
{
    80003d80:	7159                	addi	sp,sp,-112
    80003d82:	f486                	sd	ra,104(sp)
    80003d84:	f0a2                	sd	s0,96(sp)
    80003d86:	e8ca                	sd	s2,80(sp)
    80003d88:	e0d2                	sd	s4,64(sp)
    80003d8a:	fc56                	sd	s5,56(sp)
    80003d8c:	f85a                	sd	s6,48(sp)
    80003d8e:	f45e                	sd	s7,40(sp)
    80003d90:	1880                	addi	s0,sp,112
    80003d92:	8aaa                	mv	s5,a0
    80003d94:	8bae                	mv	s7,a1
    80003d96:	8a32                	mv	s4,a2
    80003d98:	8936                	mv	s2,a3
    80003d9a:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003d9c:	00e687bb          	addw	a5,a3,a4
    80003da0:	0ed7e363          	bltu	a5,a3,80003e86 <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003da4:	00043737          	lui	a4,0x43
    80003da8:	0ef76163          	bltu	a4,a5,80003e8a <writei+0x110>
    80003dac:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003dae:	0c0b0263          	beqz	s6,80003e72 <writei+0xf8>
    80003db2:	eca6                	sd	s1,88(sp)
    80003db4:	f062                	sd	s8,32(sp)
    80003db6:	ec66                	sd	s9,24(sp)
    80003db8:	e86a                	sd	s10,16(sp)
    80003dba:	e46e                	sd	s11,8(sp)
    80003dbc:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003dbe:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dc2:	5c7d                	li	s8,-1
    80003dc4:	a825                	j	80003dfc <writei+0x82>
    80003dc6:	020d1d93          	slli	s11,s10,0x20
    80003dca:	020ddd93          	srli	s11,s11,0x20
    80003dce:	05848513          	addi	a0,s1,88
    80003dd2:	86ee                	mv	a3,s11
    80003dd4:	8652                	mv	a2,s4
    80003dd6:	85de                	mv	a1,s7
    80003dd8:	953a                	add	a0,a0,a4
    80003dda:	d86fe0ef          	jal	80002360 <either_copyin>
    80003dde:	05850a63          	beq	a0,s8,80003e32 <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003de2:	8526                	mv	a0,s1
    80003de4:	6b0000ef          	jal	80004494 <log_write>
    brelse(bp);
    80003de8:	8526                	mv	a0,s1
    80003dea:	cf8ff0ef          	jal	800032e2 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003dee:	013d09bb          	addw	s3,s10,s3
    80003df2:	012d093b          	addw	s2,s10,s2
    80003df6:	9a6e                	add	s4,s4,s11
    80003df8:	0569f363          	bgeu	s3,s6,80003e3e <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    80003dfc:	00a9559b          	srliw	a1,s2,0xa
    80003e00:	8556                	mv	a0,s5
    80003e02:	f5cff0ef          	jal	8000355e <bmap>
    80003e06:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003e0a:	c995                	beqz	a1,80003e3e <writei+0xc4>
    bp = bread(ip->dev, addr);
    80003e0c:	000aa503          	lw	a0,0(s5)
    80003e10:	bcaff0ef          	jal	800031da <bread>
    80003e14:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    80003e16:	3ff97713          	andi	a4,s2,1023
    80003e1a:	40ec87bb          	subw	a5,s9,a4
    80003e1e:	413b06bb          	subw	a3,s6,s3
    80003e22:	8d3e                	mv	s10,a5
    80003e24:	2781                	sext.w	a5,a5
    80003e26:	0006861b          	sext.w	a2,a3
    80003e2a:	f8f67ee3          	bgeu	a2,a5,80003dc6 <writei+0x4c>
    80003e2e:	8d36                	mv	s10,a3
    80003e30:	bf59                	j	80003dc6 <writei+0x4c>
      log_write(bp);
    80003e32:	8526                	mv	a0,s1
    80003e34:	660000ef          	jal	80004494 <log_write>
      brelse(bp);
    80003e38:	8526                	mv	a0,s1
    80003e3a:	ca8ff0ef          	jal	800032e2 <brelse>
  }

  if (off > ip->size)
    80003e3e:	04caa783          	lw	a5,76(s5)
    80003e42:	0327fa63          	bgeu	a5,s2,80003e76 <writei+0xfc>
    ip->size = off;
    80003e46:	052aa623          	sw	s2,76(s5)
    80003e4a:	64e6                	ld	s1,88(sp)
    80003e4c:	7c02                	ld	s8,32(sp)
    80003e4e:	6ce2                	ld	s9,24(sp)
    80003e50:	6d42                	ld	s10,16(sp)
    80003e52:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e54:	8556                	mv	a0,s5
    80003e56:	99dff0ef          	jal	800037f2 <iupdate>

  return tot;
    80003e5a:	0009851b          	sext.w	a0,s3
    80003e5e:	69a6                	ld	s3,72(sp)
}
    80003e60:	70a6                	ld	ra,104(sp)
    80003e62:	7406                	ld	s0,96(sp)
    80003e64:	6946                	ld	s2,80(sp)
    80003e66:	6a06                	ld	s4,64(sp)
    80003e68:	7ae2                	ld	s5,56(sp)
    80003e6a:	7b42                	ld	s6,48(sp)
    80003e6c:	7ba2                	ld	s7,40(sp)
    80003e6e:	6165                	addi	sp,sp,112
    80003e70:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003e72:	89da                	mv	s3,s6
    80003e74:	b7c5                	j	80003e54 <writei+0xda>
    80003e76:	64e6                	ld	s1,88(sp)
    80003e78:	7c02                	ld	s8,32(sp)
    80003e7a:	6ce2                	ld	s9,24(sp)
    80003e7c:	6d42                	ld	s10,16(sp)
    80003e7e:	6da2                	ld	s11,8(sp)
    80003e80:	bfd1                	j	80003e54 <writei+0xda>
    return -1;
    80003e82:	557d                	li	a0,-1
}
    80003e84:	8082                	ret
    return -1;
    80003e86:	557d                	li	a0,-1
    80003e88:	bfe1                	j	80003e60 <writei+0xe6>
    return -1;
    80003e8a:	557d                	li	a0,-1
    80003e8c:	bfd1                	j	80003e60 <writei+0xe6>

0000000080003e8e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e8e:	1141                	addi	sp,sp,-16
    80003e90:	e406                	sd	ra,8(sp)
    80003e92:	e022                	sd	s0,0(sp)
    80003e94:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e96:	4639                	li	a2,14
    80003e98:	ecbfc0ef          	jal	80000d62 <strncmp>
}
    80003e9c:	60a2                	ld	ra,8(sp)
    80003e9e:	6402                	ld	s0,0(sp)
    80003ea0:	0141                	addi	sp,sp,16
    80003ea2:	8082                	ret

0000000080003ea4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ea4:	7139                	addi	sp,sp,-64
    80003ea6:	fc06                	sd	ra,56(sp)
    80003ea8:	f822                	sd	s0,48(sp)
    80003eaa:	f426                	sd	s1,40(sp)
    80003eac:	f04a                	sd	s2,32(sp)
    80003eae:	ec4e                	sd	s3,24(sp)
    80003eb0:	e852                	sd	s4,16(sp)
    80003eb2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003eb4:	04451703          	lh	a4,68(a0)
    80003eb8:	4785                	li	a5,1
    80003eba:	00f71a63          	bne	a4,a5,80003ece <dirlookup+0x2a>
    80003ebe:	892a                	mv	s2,a0
    80003ec0:	89ae                	mv	s3,a1
    80003ec2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ec4:	457c                	lw	a5,76(a0)
    80003ec6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ec8:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003eca:	e39d                	bnez	a5,80003ef0 <dirlookup+0x4c>
    80003ecc:	a095                	j	80003f30 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003ece:	00004517          	auipc	a0,0x4
    80003ed2:	72a50513          	addi	a0,a0,1834 # 800085f8 <etext+0x5f8>
    80003ed6:	91bfc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    80003eda:	00004517          	auipc	a0,0x4
    80003ede:	73650513          	addi	a0,a0,1846 # 80008610 <etext+0x610>
    80003ee2:	90ffc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003ee6:	24c1                	addiw	s1,s1,16
    80003ee8:	04c92783          	lw	a5,76(s2)
    80003eec:	04f4f163          	bgeu	s1,a5,80003f2e <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ef0:	4741                	li	a4,16
    80003ef2:	86a6                	mv	a3,s1
    80003ef4:	fc040613          	addi	a2,s0,-64
    80003ef8:	4581                	li	a1,0
    80003efa:	854a                	mv	a0,s2
    80003efc:	d83ff0ef          	jal	80003c7e <readi>
    80003f00:	47c1                	li	a5,16
    80003f02:	fcf51ce3          	bne	a0,a5,80003eda <dirlookup+0x36>
    if (de.inum == 0)
    80003f06:	fc045783          	lhu	a5,-64(s0)
    80003f0a:	dff1                	beqz	a5,80003ee6 <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    80003f0c:	fc240593          	addi	a1,s0,-62
    80003f10:	854e                	mv	a0,s3
    80003f12:	f7dff0ef          	jal	80003e8e <namecmp>
    80003f16:	f961                	bnez	a0,80003ee6 <dirlookup+0x42>
      if (poff)
    80003f18:	000a0463          	beqz	s4,80003f20 <dirlookup+0x7c>
        *poff = off;
    80003f1c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f20:	fc045583          	lhu	a1,-64(s0)
    80003f24:	00092503          	lw	a0,0(s2)
    80003f28:	f0aff0ef          	jal	80003632 <iget>
    80003f2c:	a011                	j	80003f30 <dirlookup+0x8c>
  return 0;
    80003f2e:	4501                	li	a0,0
}
    80003f30:	70e2                	ld	ra,56(sp)
    80003f32:	7442                	ld	s0,48(sp)
    80003f34:	74a2                	ld	s1,40(sp)
    80003f36:	7902                	ld	s2,32(sp)
    80003f38:	69e2                	ld	s3,24(sp)
    80003f3a:	6a42                	ld	s4,16(sp)
    80003f3c:	6121                	addi	sp,sp,64
    80003f3e:	8082                	ret

0000000080003f40 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003f40:	711d                	addi	sp,sp,-96
    80003f42:	ec86                	sd	ra,88(sp)
    80003f44:	e8a2                	sd	s0,80(sp)
    80003f46:	e4a6                	sd	s1,72(sp)
    80003f48:	e0ca                	sd	s2,64(sp)
    80003f4a:	fc4e                	sd	s3,56(sp)
    80003f4c:	f852                	sd	s4,48(sp)
    80003f4e:	f456                	sd	s5,40(sp)
    80003f50:	f05a                	sd	s6,32(sp)
    80003f52:	ec5e                	sd	s7,24(sp)
    80003f54:	e862                	sd	s8,16(sp)
    80003f56:	e466                	sd	s9,8(sp)
    80003f58:	1080                	addi	s0,sp,96
    80003f5a:	84aa                	mv	s1,a0
    80003f5c:	8b2e                	mv	s6,a1
    80003f5e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003f60:	00054703          	lbu	a4,0(a0)
    80003f64:	02f00793          	li	a5,47
    80003f68:	00f70e63          	beq	a4,a5,80003f84 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f6c:	979fd0ef          	jal	800018e4 <myproc>
    80003f70:	15053503          	ld	a0,336(a0)
    80003f74:	8fdff0ef          	jal	80003870 <idup>
    80003f78:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003f7a:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    80003f7e:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003f80:	4b85                	li	s7,1
    80003f82:	a075                	j	8000402e <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    80003f84:	4585                	li	a1,1
    80003f86:	4505                	li	a0,1
    80003f88:	eaaff0ef          	jal	80003632 <iget>
    80003f8c:	8a2a                	mv	s4,a0
    80003f8e:	b7f5                	j	80003f7a <namex+0x3a>
      iunlockput(ip);
    80003f90:	8552                	mv	a0,s4
    80003f92:	b67ff0ef          	jal	80003af8 <iunlockput>
      return 0;
    80003f96:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f98:	8552                	mv	a0,s4
    80003f9a:	60e6                	ld	ra,88(sp)
    80003f9c:	6446                	ld	s0,80(sp)
    80003f9e:	64a6                	ld	s1,72(sp)
    80003fa0:	6906                	ld	s2,64(sp)
    80003fa2:	79e2                	ld	s3,56(sp)
    80003fa4:	7a42                	ld	s4,48(sp)
    80003fa6:	7aa2                	ld	s5,40(sp)
    80003fa8:	7b02                	ld	s6,32(sp)
    80003faa:	6be2                	ld	s7,24(sp)
    80003fac:	6c42                	ld	s8,16(sp)
    80003fae:	6ca2                	ld	s9,8(sp)
    80003fb0:	6125                	addi	sp,sp,96
    80003fb2:	8082                	ret
      iunlockput(ip);
    80003fb4:	8552                	mv	a0,s4
    80003fb6:	b43ff0ef          	jal	80003af8 <iunlockput>
      return 0;
    80003fba:	4a01                	li	s4,0
    80003fbc:	bff1                	j	80003f98 <namex+0x58>
      iunlock(ip);
    80003fbe:	8552                	mv	a0,s4
    80003fc0:	995ff0ef          	jal	80003954 <iunlock>
      return ip;
    80003fc4:	bfd1                	j	80003f98 <namex+0x58>
      iunlockput(ip);
    80003fc6:	8552                	mv	a0,s4
    80003fc8:	b31ff0ef          	jal	80003af8 <iunlockput>
      return 0;
    80003fcc:	8a4e                	mv	s4,s3
    80003fce:	b7e9                	j	80003f98 <namex+0x58>
  len = path - s;
    80003fd0:	40998633          	sub	a2,s3,s1
    80003fd4:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    80003fd8:	099c5363          	bge	s8,s9,8000405e <namex+0x11e>
    memmove(name, s, DIRSIZ);
    80003fdc:	4639                	li	a2,14
    80003fde:	85a6                	mv	a1,s1
    80003fe0:	8556                	mv	a0,s5
    80003fe2:	d11fc0ef          	jal	80000cf2 <memmove>
    80003fe6:	84ce                	mv	s1,s3
  while (*path == '/')
    80003fe8:	0004c783          	lbu	a5,0(s1)
    80003fec:	01279763          	bne	a5,s2,80003ffa <namex+0xba>
    path++;
    80003ff0:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ff2:	0004c783          	lbu	a5,0(s1)
    80003ff6:	ff278de3          	beq	a5,s2,80003ff0 <namex+0xb0>
    ilock(ip);
    80003ffa:	8552                	mv	a0,s4
    80003ffc:	8abff0ef          	jal	800038a6 <ilock>
    if (ip->type != T_DIR) {
    80004000:	044a1783          	lh	a5,68(s4)
    80004004:	f97796e3          	bne	a5,s7,80003f90 <namex+0x50>
    if (ip->nlink == 0) {
    80004008:	04aa1783          	lh	a5,74(s4)
    8000400c:	d7c5                	beqz	a5,80003fb4 <namex+0x74>
    if (nameiparent && *path == '\0') {
    8000400e:	000b0563          	beqz	s6,80004018 <namex+0xd8>
    80004012:	0004c783          	lbu	a5,0(s1)
    80004016:	d7c5                	beqz	a5,80003fbe <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80004018:	4601                	li	a2,0
    8000401a:	85d6                	mv	a1,s5
    8000401c:	8552                	mv	a0,s4
    8000401e:	e87ff0ef          	jal	80003ea4 <dirlookup>
    80004022:	89aa                	mv	s3,a0
    80004024:	d14d                	beqz	a0,80003fc6 <namex+0x86>
    iunlockput(ip);
    80004026:	8552                	mv	a0,s4
    80004028:	ad1ff0ef          	jal	80003af8 <iunlockput>
    ip = next;
    8000402c:	8a4e                	mv	s4,s3
  while (*path == '/')
    8000402e:	0004c783          	lbu	a5,0(s1)
    80004032:	01279763          	bne	a5,s2,80004040 <namex+0x100>
    path++;
    80004036:	0485                	addi	s1,s1,1
  while (*path == '/')
    80004038:	0004c783          	lbu	a5,0(s1)
    8000403c:	ff278de3          	beq	a5,s2,80004036 <namex+0xf6>
  if (*path == 0)
    80004040:	cb8d                	beqz	a5,80004072 <namex+0x132>
  while (*path != '/' && *path != 0)
    80004042:	0004c783          	lbu	a5,0(s1)
    80004046:	89a6                	mv	s3,s1
  len = path - s;
    80004048:	4c81                	li	s9,0
    8000404a:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    8000404c:	01278963          	beq	a5,s2,8000405e <namex+0x11e>
    80004050:	d3c1                	beqz	a5,80003fd0 <namex+0x90>
    path++;
    80004052:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    80004054:	0009c783          	lbu	a5,0(s3)
    80004058:	ff279ce3          	bne	a5,s2,80004050 <namex+0x110>
    8000405c:	bf95                	j	80003fd0 <namex+0x90>
    memmove(name, s, len);
    8000405e:	2601                	sext.w	a2,a2
    80004060:	85a6                	mv	a1,s1
    80004062:	8556                	mv	a0,s5
    80004064:	c8ffc0ef          	jal	80000cf2 <memmove>
    name[len] = 0;
    80004068:	9cd6                	add	s9,s9,s5
    8000406a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000406e:	84ce                	mv	s1,s3
    80004070:	bfa5                	j	80003fe8 <namex+0xa8>
  if (nameiparent) {
    80004072:	f20b03e3          	beqz	s6,80003f98 <namex+0x58>
    iput(ip);
    80004076:	8552                	mv	a0,s4
    80004078:	9b1ff0ef          	jal	80003a28 <iput>
    return 0;
    8000407c:	4a01                	li	s4,0
    8000407e:	bf29                	j	80003f98 <namex+0x58>

0000000080004080 <dirlink>:
{
    80004080:	7139                	addi	sp,sp,-64
    80004082:	fc06                	sd	ra,56(sp)
    80004084:	f822                	sd	s0,48(sp)
    80004086:	f04a                	sd	s2,32(sp)
    80004088:	ec4e                	sd	s3,24(sp)
    8000408a:	e852                	sd	s4,16(sp)
    8000408c:	0080                	addi	s0,sp,64
    8000408e:	892a                	mv	s2,a0
    80004090:	8a2e                	mv	s4,a1
    80004092:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004094:	4601                	li	a2,0
    80004096:	e0fff0ef          	jal	80003ea4 <dirlookup>
    8000409a:	e535                	bnez	a0,80004106 <dirlink+0x86>
    8000409c:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000409e:	04c92483          	lw	s1,76(s2)
    800040a2:	c48d                	beqz	s1,800040cc <dirlink+0x4c>
    800040a4:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a6:	4741                	li	a4,16
    800040a8:	86a6                	mv	a3,s1
    800040aa:	fc040613          	addi	a2,s0,-64
    800040ae:	4581                	li	a1,0
    800040b0:	854a                	mv	a0,s2
    800040b2:	bcdff0ef          	jal	80003c7e <readi>
    800040b6:	47c1                	li	a5,16
    800040b8:	04f51b63          	bne	a0,a5,8000410e <dirlink+0x8e>
    if (de.inum == 0)
    800040bc:	fc045783          	lhu	a5,-64(s0)
    800040c0:	c791                	beqz	a5,800040cc <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800040c2:	24c1                	addiw	s1,s1,16
    800040c4:	04c92783          	lw	a5,76(s2)
    800040c8:	fcf4efe3          	bltu	s1,a5,800040a6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800040cc:	4639                	li	a2,14
    800040ce:	85d2                	mv	a1,s4
    800040d0:	fc240513          	addi	a0,s0,-62
    800040d4:	cc5fc0ef          	jal	80000d98 <strncpy>
  de.inum = inum;
    800040d8:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040dc:	4741                	li	a4,16
    800040de:	86a6                	mv	a3,s1
    800040e0:	fc040613          	addi	a2,s0,-64
    800040e4:	4581                	li	a1,0
    800040e6:	854a                	mv	a0,s2
    800040e8:	c93ff0ef          	jal	80003d7a <writei>
    800040ec:	1541                	addi	a0,a0,-16
    800040ee:	00a03533          	snez	a0,a0
    800040f2:	40a00533          	neg	a0,a0
    800040f6:	74a2                	ld	s1,40(sp)
}
    800040f8:	70e2                	ld	ra,56(sp)
    800040fa:	7442                	ld	s0,48(sp)
    800040fc:	7902                	ld	s2,32(sp)
    800040fe:	69e2                	ld	s3,24(sp)
    80004100:	6a42                	ld	s4,16(sp)
    80004102:	6121                	addi	sp,sp,64
    80004104:	8082                	ret
    iput(ip);
    80004106:	923ff0ef          	jal	80003a28 <iput>
    return -1;
    8000410a:	557d                	li	a0,-1
    8000410c:	b7f5                	j	800040f8 <dirlink+0x78>
      panic("dirlink read");
    8000410e:	00004517          	auipc	a0,0x4
    80004112:	51250513          	addi	a0,a0,1298 # 80008620 <etext+0x620>
    80004116:	edafc0ef          	jal	800007f0 <panic>

000000008000411a <namei>:

struct inode *
namei(char *path)
{
    8000411a:	1101                	addi	sp,sp,-32
    8000411c:	ec06                	sd	ra,24(sp)
    8000411e:	e822                	sd	s0,16(sp)
    80004120:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004122:	fe040613          	addi	a2,s0,-32
    80004126:	4581                	li	a1,0
    80004128:	e19ff0ef          	jal	80003f40 <namex>
}
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	6105                	addi	sp,sp,32
    80004132:	8082                	ret

0000000080004134 <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80004134:	1141                	addi	sp,sp,-16
    80004136:	e406                	sd	ra,8(sp)
    80004138:	e022                	sd	s0,0(sp)
    8000413a:	0800                	addi	s0,sp,16
    8000413c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000413e:	4585                	li	a1,1
    80004140:	e01ff0ef          	jal	80003f40 <namex>
}
    80004144:	60a2                	ld	ra,8(sp)
    80004146:	6402                	ld	s0,0(sp)
    80004148:	0141                	addi	sp,sp,16
    8000414a:	8082                	ret

000000008000414c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	e426                	sd	s1,8(sp)
    80004154:	e04a                	sd	s2,0(sp)
    80004156:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004158:	00020917          	auipc	s2,0x20
    8000415c:	cf890913          	addi	s2,s2,-776 # 80023e50 <log>
    80004160:	01892583          	lw	a1,24(s2)
    80004164:	02492503          	lw	a0,36(s2)
    80004168:	872ff0ef          	jal	800031da <bread>
    8000416c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    8000416e:	02c92603          	lw	a2,44(s2)
    80004172:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004174:	00c05f63          	blez	a2,80004192 <write_head+0x46>
    80004178:	00020717          	auipc	a4,0x20
    8000417c:	d0870713          	addi	a4,a4,-760 # 80023e80 <log+0x30>
    80004180:	87aa                	mv	a5,a0
    80004182:	060a                	slli	a2,a2,0x2
    80004184:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004186:	4314                	lw	a3,0(a4)
    80004188:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000418a:	0711                	addi	a4,a4,4
    8000418c:	0791                	addi	a5,a5,4
    8000418e:	fec79ce3          	bne	a5,a2,80004186 <write_head+0x3a>
  }
  bwrite(buf);
    80004192:	8526                	mv	a0,s1
    80004194:	91cff0ef          	jal	800032b0 <bwrite>
  brelse(buf);
    80004198:	8526                	mv	a0,s1
    8000419a:	948ff0ef          	jal	800032e2 <brelse>
}
    8000419e:	60e2                	ld	ra,24(sp)
    800041a0:	6442                	ld	s0,16(sp)
    800041a2:	64a2                	ld	s1,8(sp)
    800041a4:	6902                	ld	s2,0(sp)
    800041a6:	6105                	addi	sp,sp,32
    800041a8:	8082                	ret

00000000800041aa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041aa:	00020797          	auipc	a5,0x20
    800041ae:	cd27a783          	lw	a5,-814(a5) # 80023e7c <log+0x2c>
    800041b2:	0af05e63          	blez	a5,8000426e <install_trans+0xc4>
{
    800041b6:	715d                	addi	sp,sp,-80
    800041b8:	e486                	sd	ra,72(sp)
    800041ba:	e0a2                	sd	s0,64(sp)
    800041bc:	fc26                	sd	s1,56(sp)
    800041be:	f84a                	sd	s2,48(sp)
    800041c0:	f44e                	sd	s3,40(sp)
    800041c2:	f052                	sd	s4,32(sp)
    800041c4:	ec56                	sd	s5,24(sp)
    800041c6:	e85a                	sd	s6,16(sp)
    800041c8:	e45e                	sd	s7,8(sp)
    800041ca:	0880                	addi	s0,sp,80
    800041cc:	8b2a                	mv	s6,a0
    800041ce:	00020a97          	auipc	s5,0x20
    800041d2:	cb2a8a93          	addi	s5,s5,-846 # 80023e80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d6:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800041d8:	00004b97          	auipc	s7,0x4
    800041dc:	458b8b93          	addi	s7,s7,1112 # 80008630 <etext+0x630>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    800041e0:	00020a17          	auipc	s4,0x20
    800041e4:	c70a0a13          	addi	s4,s4,-912 # 80023e50 <log>
    800041e8:	a025                	j	80004210 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800041ea:	000aa603          	lw	a2,0(s5)
    800041ee:	85ce                	mv	a1,s3
    800041f0:	855e                	mv	a0,s7
    800041f2:	b18fc0ef          	jal	8000050a <printk>
    800041f6:	a839                	j	80004214 <install_trans+0x6a>
    brelse(lbuf);
    800041f8:	854a                	mv	a0,s2
    800041fa:	8e8ff0ef          	jal	800032e2 <brelse>
    brelse(dbuf);
    800041fe:	8526                	mv	a0,s1
    80004200:	8e2ff0ef          	jal	800032e2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004204:	2985                	addiw	s3,s3,1
    80004206:	0a91                	addi	s5,s5,4
    80004208:	02ca2783          	lw	a5,44(s4)
    8000420c:	04f9d663          	bge	s3,a5,80004258 <install_trans+0xae>
    if (recovering) {
    80004210:	fc0b1de3          	bnez	s6,800041ea <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80004214:	018a2583          	lw	a1,24(s4)
    80004218:	013585bb          	addw	a1,a1,s3
    8000421c:	2585                	addiw	a1,a1,1
    8000421e:	024a2503          	lw	a0,36(s4)
    80004222:	fb9fe0ef          	jal	800031da <bread>
    80004226:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80004228:	000aa583          	lw	a1,0(s5)
    8000422c:	024a2503          	lw	a0,36(s4)
    80004230:	fabfe0ef          	jal	800031da <bread>
    80004234:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80004236:	40000613          	li	a2,1024
    8000423a:	05890593          	addi	a1,s2,88
    8000423e:	05850513          	addi	a0,a0,88
    80004242:	ab1fc0ef          	jal	80000cf2 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80004246:	8526                	mv	a0,s1
    80004248:	868ff0ef          	jal	800032b0 <bwrite>
    if (recovering == 0)
    8000424c:	fa0b16e3          	bnez	s6,800041f8 <install_trans+0x4e>
      bunpin(dbuf);
    80004250:	8526                	mv	a0,s1
    80004252:	94cff0ef          	jal	8000339e <bunpin>
    80004256:	b74d                	j	800041f8 <install_trans+0x4e>
}
    80004258:	60a6                	ld	ra,72(sp)
    8000425a:	6406                	ld	s0,64(sp)
    8000425c:	74e2                	ld	s1,56(sp)
    8000425e:	7942                	ld	s2,48(sp)
    80004260:	79a2                	ld	s3,40(sp)
    80004262:	7a02                	ld	s4,32(sp)
    80004264:	6ae2                	ld	s5,24(sp)
    80004266:	6b42                	ld	s6,16(sp)
    80004268:	6ba2                	ld	s7,8(sp)
    8000426a:	6161                	addi	sp,sp,80
    8000426c:	8082                	ret
    8000426e:	8082                	ret

0000000080004270 <initlog>:
{
    80004270:	7179                	addi	sp,sp,-48
    80004272:	f406                	sd	ra,40(sp)
    80004274:	f022                	sd	s0,32(sp)
    80004276:	ec26                	sd	s1,24(sp)
    80004278:	e84a                	sd	s2,16(sp)
    8000427a:	e44e                	sd	s3,8(sp)
    8000427c:	1800                	addi	s0,sp,48
    8000427e:	892a                	mv	s2,a0
    80004280:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004282:	00020497          	auipc	s1,0x20
    80004286:	bce48493          	addi	s1,s1,-1074 # 80023e50 <log>
    8000428a:	00004597          	auipc	a1,0x4
    8000428e:	3c658593          	addi	a1,a1,966 # 80008650 <etext+0x650>
    80004292:	8526                	mv	a0,s1
    80004294:	8c9fc0ef          	jal	80000b5c <initlock>
  log.start = sb->logstart;
    80004298:	0149a583          	lw	a1,20(s3)
    8000429c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000429e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042a2:	854a                	mv	a0,s2
    800042a4:	f37fe0ef          	jal	800031da <bread>
  log.lh.n = lh->n;
    800042a8:	4d30                	lw	a2,88(a0)
    800042aa:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ac:	00c05f63          	blez	a2,800042ca <initlog+0x5a>
    800042b0:	87aa                	mv	a5,a0
    800042b2:	00020717          	auipc	a4,0x20
    800042b6:	bce70713          	addi	a4,a4,-1074 # 80023e80 <log+0x30>
    800042ba:	060a                	slli	a2,a2,0x2
    800042bc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800042be:	4ff4                	lw	a3,92(a5)
    800042c0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042c2:	0791                	addi	a5,a5,4
    800042c4:	0711                	addi	a4,a4,4
    800042c6:	fec79ce3          	bne	a5,a2,800042be <initlog+0x4e>
  brelse(buf);
    800042ca:	818ff0ef          	jal	800032e2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042ce:	4505                	li	a0,1
    800042d0:	edbff0ef          	jal	800041aa <install_trans>
  log.lh.n = 0;
    800042d4:	00020797          	auipc	a5,0x20
    800042d8:	ba07a423          	sw	zero,-1112(a5) # 80023e7c <log+0x2c>
  write_head(); // clear the log
    800042dc:	e71ff0ef          	jal	8000414c <write_head>
}
    800042e0:	70a2                	ld	ra,40(sp)
    800042e2:	7402                	ld	s0,32(sp)
    800042e4:	64e2                	ld	s1,24(sp)
    800042e6:	6942                	ld	s2,16(sp)
    800042e8:	69a2                	ld	s3,8(sp)
    800042ea:	6145                	addi	sp,sp,48
    800042ec:	8082                	ret

00000000800042ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	e426                	sd	s1,8(sp)
    800042f6:	e04a                	sd	s2,0(sp)
    800042f8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042fa:	00020517          	auipc	a0,0x20
    800042fe:	b5650513          	addi	a0,a0,-1194 # 80023e50 <log>
    80004302:	8d1fc0ef          	jal	80000bd2 <acquire>
  while (1) {
    if (log.committing) {
    80004306:	00020497          	auipc	s1,0x20
    8000430a:	b4a48493          	addi	s1,s1,-1206 # 80023e50 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    8000430e:	4979                	li	s2,30
    80004310:	a821                	j	80004328 <begin_op+0x3a>
      sleep_prepare(&log);
    80004312:	8526                	mv	a0,s1
    80004314:	c6dfd0ef          	jal	80001f80 <sleep_prepare>
      release(&log.lock);
    80004318:	8526                	mv	a0,s1
    8000431a:	945fc0ef          	jal	80000c5e <release>
      sleep();
    8000431e:	c9ffd0ef          	jal	80001fbc <sleep>
      acquire(&log.lock);
    80004322:	8526                	mv	a0,s1
    80004324:	8affc0ef          	jal	80000bd2 <acquire>
    if (log.committing) {
    80004328:	509c                	lw	a5,32(s1)
    8000432a:	f7e5                	bnez	a5,80004312 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    8000432c:	4cd8                	lw	a4,28(s1)
    8000432e:	2705                	addiw	a4,a4,1
    80004330:	0027179b          	slliw	a5,a4,0x2
    80004334:	9fb9                	addw	a5,a5,a4
    80004336:	0017979b          	slliw	a5,a5,0x1
    8000433a:	54d4                	lw	a3,44(s1)
    8000433c:	9fb5                	addw	a5,a5,a3
    8000433e:	00f95e63          	bge	s2,a5,8000435a <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80004342:	8526                	mv	a0,s1
    80004344:	c3dfd0ef          	jal	80001f80 <sleep_prepare>
      release(&log.lock);
    80004348:	8526                	mv	a0,s1
    8000434a:	915fc0ef          	jal	80000c5e <release>
      sleep();
    8000434e:	c6ffd0ef          	jal	80001fbc <sleep>
      acquire(&log.lock);
    80004352:	8526                	mv	a0,s1
    80004354:	87ffc0ef          	jal	80000bd2 <acquire>
    80004358:	bfc1                	j	80004328 <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    8000435a:	00020517          	auipc	a0,0x20
    8000435e:	af650513          	addi	a0,a0,-1290 # 80023e50 <log>
    80004362:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004364:	8fbfc0ef          	jal	80000c5e <release>
      break;
    }
  }
}
    80004368:	60e2                	ld	ra,24(sp)
    8000436a:	6442                	ld	s0,16(sp)
    8000436c:	64a2                	ld	s1,8(sp)
    8000436e:	6902                	ld	s2,0(sp)
    80004370:	6105                	addi	sp,sp,32
    80004372:	8082                	ret

0000000080004374 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004374:	7139                	addi	sp,sp,-64
    80004376:	fc06                	sd	ra,56(sp)
    80004378:	f822                	sd	s0,48(sp)
    8000437a:	f426                	sd	s1,40(sp)
    8000437c:	f04a                	sd	s2,32(sp)
    8000437e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004380:	00020497          	auipc	s1,0x20
    80004384:	ad048493          	addi	s1,s1,-1328 # 80023e50 <log>
    80004388:	8526                	mv	a0,s1
    8000438a:	849fc0ef          	jal	80000bd2 <acquire>
  log.outstanding -= 1;
    8000438e:	4cdc                	lw	a5,28(s1)
    80004390:	37fd                	addiw	a5,a5,-1
    80004392:	0007891b          	sext.w	s2,a5
    80004396:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80004398:	509c                	lw	a5,32(s1)
    8000439a:	e3b1                	bnez	a5,800043de <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    8000439c:	04091a63          	bnez	s2,800043f0 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    800043a0:	00020497          	auipc	s1,0x20
    800043a4:	ab048493          	addi	s1,s1,-1360 # 80023e50 <log>
    800043a8:	4785                	li	a5,1
    800043aa:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043ac:	8526                	mv	a0,s1
    800043ae:	8b1fc0ef          	jal	80000c5e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043b2:	54dc                	lw	a5,44(s1)
    800043b4:	04f04e63          	bgtz	a5,80004410 <end_op+0x9c>
    acquire(&log.lock);
    800043b8:	00020497          	auipc	s1,0x20
    800043bc:	a9848493          	addi	s1,s1,-1384 # 80023e50 <log>
    800043c0:	8526                	mv	a0,s1
    800043c2:	811fc0ef          	jal	80000bd2 <acquire>
    log.committing = 0;
    800043c6:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    800043ca:	549c                	lw	a5,40(s1)
    800043cc:	2785                	addiw	a5,a5,1
    800043ce:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    800043d0:	8526                	mv	a0,s1
    800043d2:	c1bfd0ef          	jal	80001fec <wakeup>
    release(&log.lock);
    800043d6:	8526                	mv	a0,s1
    800043d8:	887fc0ef          	jal	80000c5e <release>
}
    800043dc:	a025                	j	80004404 <end_op+0x90>
    800043de:	ec4e                	sd	s3,24(sp)
    800043e0:	e852                	sd	s4,16(sp)
    800043e2:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800043e4:	00004517          	auipc	a0,0x4
    800043e8:	27450513          	addi	a0,a0,628 # 80008658 <etext+0x658>
    800043ec:	c04fc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    800043f0:	00020497          	auipc	s1,0x20
    800043f4:	a6048493          	addi	s1,s1,-1440 # 80023e50 <log>
    800043f8:	8526                	mv	a0,s1
    800043fa:	bf3fd0ef          	jal	80001fec <wakeup>
  release(&log.lock);
    800043fe:	8526                	mv	a0,s1
    80004400:	85ffc0ef          	jal	80000c5e <release>
}
    80004404:	70e2                	ld	ra,56(sp)
    80004406:	7442                	ld	s0,48(sp)
    80004408:	74a2                	ld	s1,40(sp)
    8000440a:	7902                	ld	s2,32(sp)
    8000440c:	6121                	addi	sp,sp,64
    8000440e:	8082                	ret
    80004410:	ec4e                	sd	s3,24(sp)
    80004412:	e852                	sd	s4,16(sp)
    80004414:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004416:	00020a97          	auipc	s5,0x20
    8000441a:	a6aa8a93          	addi	s5,s5,-1430 # 80023e80 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    8000441e:	00020a17          	auipc	s4,0x20
    80004422:	a32a0a13          	addi	s4,s4,-1486 # 80023e50 <log>
    80004426:	018a2583          	lw	a1,24(s4)
    8000442a:	012585bb          	addw	a1,a1,s2
    8000442e:	2585                	addiw	a1,a1,1
    80004430:	024a2503          	lw	a0,36(s4)
    80004434:	da7fe0ef          	jal	800031da <bread>
    80004438:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000443a:	000aa583          	lw	a1,0(s5)
    8000443e:	024a2503          	lw	a0,36(s4)
    80004442:	d99fe0ef          	jal	800031da <bread>
    80004446:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004448:	40000613          	li	a2,1024
    8000444c:	05850593          	addi	a1,a0,88
    80004450:	05848513          	addi	a0,s1,88
    80004454:	89ffc0ef          	jal	80000cf2 <memmove>
    bwrite(to); // write the log
    80004458:	8526                	mv	a0,s1
    8000445a:	e57fe0ef          	jal	800032b0 <bwrite>
    brelse(from);
    8000445e:	854e                	mv	a0,s3
    80004460:	e83fe0ef          	jal	800032e2 <brelse>
    brelse(to);
    80004464:	8526                	mv	a0,s1
    80004466:	e7dfe0ef          	jal	800032e2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000446a:	2905                	addiw	s2,s2,1
    8000446c:	0a91                	addi	s5,s5,4
    8000446e:	02ca2783          	lw	a5,44(s4)
    80004472:	faf94ae3          	blt	s2,a5,80004426 <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80004476:	cd7ff0ef          	jal	8000414c <write_head>
    install_trans(0); // Now install writes to home locations
    8000447a:	4501                	li	a0,0
    8000447c:	d2fff0ef          	jal	800041aa <install_trans>
    log.lh.n = 0;
    80004480:	00020797          	auipc	a5,0x20
    80004484:	9e07ae23          	sw	zero,-1540(a5) # 80023e7c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80004488:	cc5ff0ef          	jal	8000414c <write_head>
    8000448c:	69e2                	ld	s3,24(sp)
    8000448e:	6a42                	ld	s4,16(sp)
    80004490:	6aa2                	ld	s5,8(sp)
    80004492:	b71d                	j	800043b8 <end_op+0x44>

0000000080004494 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004494:	1101                	addi	sp,sp,-32
    80004496:	ec06                	sd	ra,24(sp)
    80004498:	e822                	sd	s0,16(sp)
    8000449a:	e426                	sd	s1,8(sp)
    8000449c:	e04a                	sd	s2,0(sp)
    8000449e:	1000                	addi	s0,sp,32
    800044a0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044a2:	00020917          	auipc	s2,0x20
    800044a6:	9ae90913          	addi	s2,s2,-1618 # 80023e50 <log>
    800044aa:	854a                	mv	a0,s2
    800044ac:	f26fc0ef          	jal	80000bd2 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800044b0:	02c92603          	lw	a2,44(s2)
    800044b4:	47f5                	li	a5,29
    800044b6:	04c7cc63          	blt	a5,a2,8000450e <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ba:	00020797          	auipc	a5,0x20
    800044be:	9b27a783          	lw	a5,-1614(a5) # 80023e6c <log+0x1c>
    800044c2:	04f05c63          	blez	a5,8000451a <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044c6:	4781                	li	a5,0
    800044c8:	04c05f63          	blez	a2,80004526 <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    800044cc:	44cc                	lw	a1,12(s1)
    800044ce:	00020717          	auipc	a4,0x20
    800044d2:	9b270713          	addi	a4,a4,-1614 # 80023e80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044d6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    800044d8:	4314                	lw	a3,0(a4)
    800044da:	04b68663          	beq	a3,a1,80004526 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800044de:	2785                	addiw	a5,a5,1
    800044e0:	0711                	addi	a4,a4,4
    800044e2:	fef61be3          	bne	a2,a5,800044d8 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044e6:	0621                	addi	a2,a2,8
    800044e8:	060a                	slli	a2,a2,0x2
    800044ea:	00020797          	auipc	a5,0x20
    800044ee:	96678793          	addi	a5,a5,-1690 # 80023e50 <log>
    800044f2:	97b2                	add	a5,a5,a2
    800044f4:	44d8                	lw	a4,12(s1)
    800044f6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    800044f8:	8526                	mv	a0,s1
    800044fa:	e71fe0ef          	jal	8000336a <bpin>
    log.lh.n++;
    800044fe:	00020717          	auipc	a4,0x20
    80004502:	95270713          	addi	a4,a4,-1710 # 80023e50 <log>
    80004506:	575c                	lw	a5,44(a4)
    80004508:	2785                	addiw	a5,a5,1
    8000450a:	d75c                	sw	a5,44(a4)
    8000450c:	a80d                	j	8000453e <log_write+0xaa>
    panic("too big a transaction");
    8000450e:	00004517          	auipc	a0,0x4
    80004512:	15a50513          	addi	a0,a0,346 # 80008668 <etext+0x668>
    80004516:	adafc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    8000451a:	00004517          	auipc	a0,0x4
    8000451e:	16650513          	addi	a0,a0,358 # 80008680 <etext+0x680>
    80004522:	acefc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    80004526:	00878693          	addi	a3,a5,8
    8000452a:	068a                	slli	a3,a3,0x2
    8000452c:	00020717          	auipc	a4,0x20
    80004530:	92470713          	addi	a4,a4,-1756 # 80023e50 <log>
    80004534:	9736                	add	a4,a4,a3
    80004536:	44d4                	lw	a3,12(s1)
    80004538:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    8000453a:	faf60fe3          	beq	a2,a5,800044f8 <log_write+0x64>
  }
  release(&log.lock);
    8000453e:	00020517          	auipc	a0,0x20
    80004542:	91250513          	addi	a0,a0,-1774 # 80023e50 <log>
    80004546:	f18fc0ef          	jal	80000c5e <release>
}
    8000454a:	60e2                	ld	ra,24(sp)
    8000454c:	6442                	ld	s0,16(sp)
    8000454e:	64a2                	ld	s1,8(sp)
    80004550:	6902                	ld	s2,0(sp)
    80004552:	6105                	addi	sp,sp,32
    80004554:	8082                	ret

0000000080004556 <sys_sync>:

uint64
sys_sync(void)
{
    80004556:	1101                	addi	sp,sp,-32
    80004558:	ec06                	sd	ra,24(sp)
    8000455a:	e822                	sd	s0,16(sp)
    8000455c:	e426                	sd	s1,8(sp)
    8000455e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004560:	00020497          	auipc	s1,0x20
    80004564:	8f048493          	addi	s1,s1,-1808 # 80023e50 <log>
    80004568:	8526                	mv	a0,s1
    8000456a:	e68fc0ef          	jal	80000bd2 <acquire>
  if (log.committing || log.outstanding > 0) {
    8000456e:	509c                	lw	a5,32(s1)
    80004570:	e799                	bnez	a5,8000457e <sys_sync+0x28>
    80004572:	00020797          	auipc	a5,0x20
    80004576:	8fa7a783          	lw	a5,-1798(a5) # 80023e6c <log+0x1c>
    8000457a:	02f05a63          	blez	a5,800045ae <sys_sync+0x58>
    8000457e:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004580:	00020917          	auipc	s2,0x20
    80004584:	8f892903          	lw	s2,-1800(s2) # 80023e78 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004588:	00020497          	auipc	s1,0x20
    8000458c:	8c848493          	addi	s1,s1,-1848 # 80023e50 <log>
    80004590:	8526                	mv	a0,s1
    80004592:	9effd0ef          	jal	80001f80 <sleep_prepare>
      release(&log.lock);
    80004596:	8526                	mv	a0,s1
    80004598:	ec6fc0ef          	jal	80000c5e <release>
      sleep();
    8000459c:	a21fd0ef          	jal	80001fbc <sleep>
      acquire(&log.lock);
    800045a0:	8526                	mv	a0,s1
    800045a2:	e30fc0ef          	jal	80000bd2 <acquire>
    while (log.ncommit < n) {
    800045a6:	549c                	lw	a5,40(s1)
    800045a8:	fef954e3          	bge	s2,a5,80004590 <sys_sync+0x3a>
    800045ac:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800045ae:	00020517          	auipc	a0,0x20
    800045b2:	8a250513          	addi	a0,a0,-1886 # 80023e50 <log>
    800045b6:	ea8fc0ef          	jal	80000c5e <release>
  return 0;
}
    800045ba:	4501                	li	a0,0
    800045bc:	60e2                	ld	ra,24(sp)
    800045be:	6442                	ld	s0,16(sp)
    800045c0:	64a2                	ld	s1,8(sp)
    800045c2:	6105                	addi	sp,sp,32
    800045c4:	8082                	ret

00000000800045c6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045c6:	1101                	addi	sp,sp,-32
    800045c8:	ec06                	sd	ra,24(sp)
    800045ca:	e822                	sd	s0,16(sp)
    800045cc:	e426                	sd	s1,8(sp)
    800045ce:	e04a                	sd	s2,0(sp)
    800045d0:	1000                	addi	s0,sp,32
    800045d2:	84aa                	mv	s1,a0
    800045d4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045d6:	00004597          	auipc	a1,0x4
    800045da:	0ca58593          	addi	a1,a1,202 # 800086a0 <etext+0x6a0>
    800045de:	0521                	addi	a0,a0,8
    800045e0:	d7cfc0ef          	jal	80000b5c <initlock>
  lk->name = name;
    800045e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ec:	0204a423          	sw	zero,40(s1)
}
    800045f0:	60e2                	ld	ra,24(sp)
    800045f2:	6442                	ld	s0,16(sp)
    800045f4:	64a2                	ld	s1,8(sp)
    800045f6:	6902                	ld	s2,0(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret

00000000800045fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	e04a                	sd	s2,0(sp)
    80004606:	1000                	addi	s0,sp,32
    80004608:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000460a:	00850913          	addi	s2,a0,8
    8000460e:	854a                	mv	a0,s2
    80004610:	dc2fc0ef          	jal	80000bd2 <acquire>
  while (lk->locked) {
    80004614:	409c                	lw	a5,0(s1)
    80004616:	cf91                	beqz	a5,80004632 <acquiresleep+0x36>
    sleep_prepare(lk);
    80004618:	8526                	mv	a0,s1
    8000461a:	967fd0ef          	jal	80001f80 <sleep_prepare>
    release(&lk->lk);
    8000461e:	854a                	mv	a0,s2
    80004620:	e3efc0ef          	jal	80000c5e <release>
    sleep();
    80004624:	999fd0ef          	jal	80001fbc <sleep>
    acquire(&lk->lk);
    80004628:	854a                	mv	a0,s2
    8000462a:	da8fc0ef          	jal	80000bd2 <acquire>
  while (lk->locked) {
    8000462e:	409c                	lw	a5,0(s1)
    80004630:	f7e5                	bnez	a5,80004618 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004632:	4785                	li	a5,1
    80004634:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004636:	aaefd0ef          	jal	800018e4 <myproc>
    8000463a:	591c                	lw	a5,48(a0)
    8000463c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000463e:	854a                	mv	a0,s2
    80004640:	e1efc0ef          	jal	80000c5e <release>
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004650:	1101                	addi	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	addi	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000465e:	00850913          	addi	s2,a0,8
    80004662:	854a                	mv	a0,s2
    80004664:	d6efc0ef          	jal	80000bd2 <acquire>
  lk->locked = 0;
    80004668:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000466c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004670:	8526                	mv	a0,s1
    80004672:	97bfd0ef          	jal	80001fec <wakeup>
  release(&lk->lk);
    80004676:	854a                	mv	a0,s2
    80004678:	de6fc0ef          	jal	80000c5e <release>
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret

0000000080004688 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004688:	7179                	addi	sp,sp,-48
    8000468a:	f406                	sd	ra,40(sp)
    8000468c:	f022                	sd	s0,32(sp)
    8000468e:	ec26                	sd	s1,24(sp)
    80004690:	e84a                	sd	s2,16(sp)
    80004692:	1800                	addi	s0,sp,48
    80004694:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	d36fc0ef          	jal	80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a0:	409c                	lw	a5,0(s1)
    800046a2:	ef81                	bnez	a5,800046ba <holdingsleep+0x32>
    800046a4:	4481                	li	s1,0
  release(&lk->lk);
    800046a6:	854a                	mv	a0,s2
    800046a8:	db6fc0ef          	jal	80000c5e <release>
  return r;
}
    800046ac:	8526                	mv	a0,s1
    800046ae:	70a2                	ld	ra,40(sp)
    800046b0:	7402                	ld	s0,32(sp)
    800046b2:	64e2                	ld	s1,24(sp)
    800046b4:	6942                	ld	s2,16(sp)
    800046b6:	6145                	addi	sp,sp,48
    800046b8:	8082                	ret
    800046ba:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800046bc:	0284a983          	lw	s3,40(s1)
    800046c0:	a24fd0ef          	jal	800018e4 <myproc>
    800046c4:	5904                	lw	s1,48(a0)
    800046c6:	413484b3          	sub	s1,s1,s3
    800046ca:	0014b493          	seqz	s1,s1
    800046ce:	69a2                	ld	s3,8(sp)
    800046d0:	bfd9                	j	800046a6 <holdingsleep+0x1e>

00000000800046d2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046d2:	1141                	addi	sp,sp,-16
    800046d4:	e406                	sd	ra,8(sp)
    800046d6:	e022                	sd	s0,0(sp)
    800046d8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046da:	00004597          	auipc	a1,0x4
    800046de:	fd658593          	addi	a1,a1,-42 # 800086b0 <etext+0x6b0>
    800046e2:	00020517          	auipc	a0,0x20
    800046e6:	8b650513          	addi	a0,a0,-1866 # 80023f98 <ftable>
    800046ea:	c72fc0ef          	jal	80000b5c <initlock>
}
    800046ee:	60a2                	ld	ra,8(sp)
    800046f0:	6402                	ld	s0,0(sp)
    800046f2:	0141                	addi	sp,sp,16
    800046f4:	8082                	ret

00000000800046f6 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800046f6:	1101                	addi	sp,sp,-32
    800046f8:	ec06                	sd	ra,24(sp)
    800046fa:	e822                	sd	s0,16(sp)
    800046fc:	e426                	sd	s1,8(sp)
    800046fe:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004700:	00020517          	auipc	a0,0x20
    80004704:	89850513          	addi	a0,a0,-1896 # 80023f98 <ftable>
    80004708:	ccafc0ef          	jal	80000bd2 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000470c:	00020497          	auipc	s1,0x20
    80004710:	8a448493          	addi	s1,s1,-1884 # 80023fb0 <ftable+0x18>
    80004714:	00021717          	auipc	a4,0x21
    80004718:	83c70713          	addi	a4,a4,-1988 # 80024f50 <disk>
    if (f->ref == 0) {
    8000471c:	40dc                	lw	a5,4(s1)
    8000471e:	cf89                	beqz	a5,80004738 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004720:	02848493          	addi	s1,s1,40
    80004724:	fee49ce3          	bne	s1,a4,8000471c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004728:	00020517          	auipc	a0,0x20
    8000472c:	87050513          	addi	a0,a0,-1936 # 80023f98 <ftable>
    80004730:	d2efc0ef          	jal	80000c5e <release>
  return 0;
    80004734:	4481                	li	s1,0
    80004736:	a809                	j	80004748 <filealloc+0x52>
      f->ref = 1;
    80004738:	4785                	li	a5,1
    8000473a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000473c:	00020517          	auipc	a0,0x20
    80004740:	85c50513          	addi	a0,a0,-1956 # 80023f98 <ftable>
    80004744:	d1afc0ef          	jal	80000c5e <release>
}
    80004748:	8526                	mv	a0,s1
    8000474a:	60e2                	ld	ra,24(sp)
    8000474c:	6442                	ld	s0,16(sp)
    8000474e:	64a2                	ld	s1,8(sp)
    80004750:	6105                	addi	sp,sp,32
    80004752:	8082                	ret

0000000080004754 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004754:	1101                	addi	sp,sp,-32
    80004756:	ec06                	sd	ra,24(sp)
    80004758:	e822                	sd	s0,16(sp)
    8000475a:	e426                	sd	s1,8(sp)
    8000475c:	1000                	addi	s0,sp,32
    8000475e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004760:	00020517          	auipc	a0,0x20
    80004764:	83850513          	addi	a0,a0,-1992 # 80023f98 <ftable>
    80004768:	c6afc0ef          	jal	80000bd2 <acquire>
  if (f->ref < 1)
    8000476c:	40dc                	lw	a5,4(s1)
    8000476e:	02f05063          	blez	a5,8000478e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004772:	2785                	addiw	a5,a5,1
    80004774:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004776:	00020517          	auipc	a0,0x20
    8000477a:	82250513          	addi	a0,a0,-2014 # 80023f98 <ftable>
    8000477e:	ce0fc0ef          	jal	80000c5e <release>
  return f;
}
    80004782:	8526                	mv	a0,s1
    80004784:	60e2                	ld	ra,24(sp)
    80004786:	6442                	ld	s0,16(sp)
    80004788:	64a2                	ld	s1,8(sp)
    8000478a:	6105                	addi	sp,sp,32
    8000478c:	8082                	ret
    panic("filedup");
    8000478e:	00004517          	auipc	a0,0x4
    80004792:	f2a50513          	addi	a0,a0,-214 # 800086b8 <etext+0x6b8>
    80004796:	85afc0ef          	jal	800007f0 <panic>

000000008000479a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000479a:	7139                	addi	sp,sp,-64
    8000479c:	fc06                	sd	ra,56(sp)
    8000479e:	f822                	sd	s0,48(sp)
    800047a0:	f426                	sd	s1,40(sp)
    800047a2:	0080                	addi	s0,sp,64
    800047a4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047a6:	0001f517          	auipc	a0,0x1f
    800047aa:	7f250513          	addi	a0,a0,2034 # 80023f98 <ftable>
    800047ae:	c24fc0ef          	jal	80000bd2 <acquire>
  if (f->ref < 1)
    800047b2:	40dc                	lw	a5,4(s1)
    800047b4:	04f05a63          	blez	a5,80004808 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800047b8:	37fd                	addiw	a5,a5,-1
    800047ba:	0007871b          	sext.w	a4,a5
    800047be:	c0dc                	sw	a5,4(s1)
    800047c0:	04e04e63          	bgtz	a4,8000481c <fileclose+0x82>
    800047c4:	f04a                	sd	s2,32(sp)
    800047c6:	ec4e                	sd	s3,24(sp)
    800047c8:	e852                	sd	s4,16(sp)
    800047ca:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047cc:	0004a903          	lw	s2,0(s1)
    800047d0:	0094ca83          	lbu	s5,9(s1)
    800047d4:	0104ba03          	ld	s4,16(s1)
    800047d8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047dc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047e0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047e4:	0001f517          	auipc	a0,0x1f
    800047e8:	7b450513          	addi	a0,a0,1972 # 80023f98 <ftable>
    800047ec:	c72fc0ef          	jal	80000c5e <release>

  if (ff.type == FD_PIPE) {
    800047f0:	4785                	li	a5,1
    800047f2:	04f90063          	beq	s2,a5,80004832 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    800047f6:	3979                	addiw	s2,s2,-2
    800047f8:	4785                	li	a5,1
    800047fa:	0527f563          	bgeu	a5,s2,80004844 <fileclose+0xaa>
    800047fe:	7902                	ld	s2,32(sp)
    80004800:	69e2                	ld	s3,24(sp)
    80004802:	6a42                	ld	s4,16(sp)
    80004804:	6aa2                	ld	s5,8(sp)
    80004806:	a00d                	j	80004828 <fileclose+0x8e>
    80004808:	f04a                	sd	s2,32(sp)
    8000480a:	ec4e                	sd	s3,24(sp)
    8000480c:	e852                	sd	s4,16(sp)
    8000480e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004810:	00004517          	auipc	a0,0x4
    80004814:	eb050513          	addi	a0,a0,-336 # 800086c0 <etext+0x6c0>
    80004818:	fd9fb0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    8000481c:	0001f517          	auipc	a0,0x1f
    80004820:	77c50513          	addi	a0,a0,1916 # 80023f98 <ftable>
    80004824:	c3afc0ef          	jal	80000c5e <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004828:	70e2                	ld	ra,56(sp)
    8000482a:	7442                	ld	s0,48(sp)
    8000482c:	74a2                	ld	s1,40(sp)
    8000482e:	6121                	addi	sp,sp,64
    80004830:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004832:	85d6                	mv	a1,s5
    80004834:	8552                	mv	a0,s4
    80004836:	39c000ef          	jal	80004bd2 <pipeclose>
    8000483a:	7902                	ld	s2,32(sp)
    8000483c:	69e2                	ld	s3,24(sp)
    8000483e:	6a42                	ld	s4,16(sp)
    80004840:	6aa2                	ld	s5,8(sp)
    80004842:	b7dd                	j	80004828 <fileclose+0x8e>
    begin_op();
    80004844:	aabff0ef          	jal	800042ee <begin_op>
    iput(ff.ip);
    80004848:	854e                	mv	a0,s3
    8000484a:	9deff0ef          	jal	80003a28 <iput>
    end_op();
    8000484e:	b27ff0ef          	jal	80004374 <end_op>
    80004852:	7902                	ld	s2,32(sp)
    80004854:	69e2                	ld	s3,24(sp)
    80004856:	6a42                	ld	s4,16(sp)
    80004858:	6aa2                	ld	s5,8(sp)
    8000485a:	b7f9                	j	80004828 <fileclose+0x8e>

000000008000485c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000485c:	715d                	addi	sp,sp,-80
    8000485e:	e486                	sd	ra,72(sp)
    80004860:	e0a2                	sd	s0,64(sp)
    80004862:	fc26                	sd	s1,56(sp)
    80004864:	f44e                	sd	s3,40(sp)
    80004866:	0880                	addi	s0,sp,80
    80004868:	84aa                	mv	s1,a0
    8000486a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000486c:	878fd0ef          	jal	800018e4 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004870:	409c                	lw	a5,0(s1)
    80004872:	37f9                	addiw	a5,a5,-2
    80004874:	4705                	li	a4,1
    80004876:	04f76263          	bltu	a4,a5,800048ba <filestat+0x5e>
    8000487a:	f84a                	sd	s2,48(sp)
    8000487c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000487e:	6c88                	ld	a0,24(s1)
    80004880:	826ff0ef          	jal	800038a6 <ilock>
    stati(f->ip, &st);
    80004884:	fb840593          	addi	a1,s0,-72
    80004888:	6c88                	ld	a0,24(s1)
    8000488a:	bcaff0ef          	jal	80003c54 <stati>
    iunlock(f->ip);
    8000488e:	6c88                	ld	a0,24(s1)
    80004890:	8c4ff0ef          	jal	80003954 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    80004894:	4761                	li	a4,24
    80004896:	fb840693          	addi	a3,s0,-72
    8000489a:	864e                	mv	a2,s3
    8000489c:	04893583          	ld	a1,72(s2)
    800048a0:	05093503          	ld	a0,80(s2)
    800048a4:	c77fc0ef          	jal	8000151a <copyout>
    800048a8:	41f5551b          	sraiw	a0,a0,0x1f
    800048ac:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800048ae:	60a6                	ld	ra,72(sp)
    800048b0:	6406                	ld	s0,64(sp)
    800048b2:	74e2                	ld	s1,56(sp)
    800048b4:	79a2                	ld	s3,40(sp)
    800048b6:	6161                	addi	sp,sp,80
    800048b8:	8082                	ret
  return -1;
    800048ba:	557d                	li	a0,-1
    800048bc:	bfcd                	j	800048ae <filestat+0x52>

00000000800048be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048be:	7179                	addi	sp,sp,-48
    800048c0:	f406                	sd	ra,40(sp)
    800048c2:	f022                	sd	s0,32(sp)
    800048c4:	e84a                	sd	s2,16(sp)
    800048c6:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800048c8:	00854783          	lbu	a5,8(a0)
    800048cc:	c3c5                	beqz	a5,8000496c <fileread+0xae>
    800048ce:	ec26                	sd	s1,24(sp)
    800048d0:	e44e                	sd	s3,8(sp)
    800048d2:	84aa                	mv	s1,a0
    800048d4:	89ae                	mv	s3,a1
    800048d6:	8932                	mv	s2,a2
    800048d8:	08064c63          	bltz	a2,80004970 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    800048dc:	411c                	lw	a5,0(a0)
    800048de:	4705                	li	a4,1
    800048e0:	04e78363          	beq	a5,a4,80004926 <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800048e4:	470d                	li	a4,3
    800048e6:	04e78763          	beq	a5,a4,80004934 <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    800048ea:	4709                	li	a4,2
    800048ec:	06e79a63          	bne	a5,a4,80004960 <fileread+0xa2>
    ilock(f->ip);
    800048f0:	6d08                	ld	a0,24(a0)
    800048f2:	fb5fe0ef          	jal	800038a6 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048f6:	874a                	mv	a4,s2
    800048f8:	5094                	lw	a3,32(s1)
    800048fa:	864e                	mv	a2,s3
    800048fc:	4585                	li	a1,1
    800048fe:	6c88                	ld	a0,24(s1)
    80004900:	b7eff0ef          	jal	80003c7e <readi>
    80004904:	892a                	mv	s2,a0
    80004906:	00a05563          	blez	a0,80004910 <fileread+0x52>
      f->off += r;
    8000490a:	509c                	lw	a5,32(s1)
    8000490c:	9fa9                	addw	a5,a5,a0
    8000490e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004910:	6c88                	ld	a0,24(s1)
    80004912:	842ff0ef          	jal	80003954 <iunlock>
    80004916:	64e2                	ld	s1,24(sp)
    80004918:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000491a:	854a                	mv	a0,s2
    8000491c:	70a2                	ld	ra,40(sp)
    8000491e:	7402                	ld	s0,32(sp)
    80004920:	6942                	ld	s2,16(sp)
    80004922:	6145                	addi	sp,sp,48
    80004924:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004926:	6908                	ld	a0,16(a0)
    80004928:	406000ef          	jal	80004d2e <piperead>
    8000492c:	892a                	mv	s2,a0
    8000492e:	64e2                	ld	s1,24(sp)
    80004930:	69a2                	ld	s3,8(sp)
    80004932:	b7e5                	j	8000491a <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004934:	02451783          	lh	a5,36(a0)
    80004938:	03079693          	slli	a3,a5,0x30
    8000493c:	92c1                	srli	a3,a3,0x30
    8000493e:	4725                	li	a4,9
    80004940:	02d76c63          	bltu	a4,a3,80004978 <fileread+0xba>
    80004944:	0792                	slli	a5,a5,0x4
    80004946:	0001f717          	auipc	a4,0x1f
    8000494a:	5b270713          	addi	a4,a4,1458 # 80023ef8 <devsw>
    8000494e:	97ba                	add	a5,a5,a4
    80004950:	639c                	ld	a5,0(a5)
    80004952:	c79d                	beqz	a5,80004980 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    80004954:	4505                	li	a0,1
    80004956:	9782                	jalr	a5
    80004958:	892a                	mv	s2,a0
    8000495a:	64e2                	ld	s1,24(sp)
    8000495c:	69a2                	ld	s3,8(sp)
    8000495e:	bf75                	j	8000491a <fileread+0x5c>
    panic("fileread");
    80004960:	00004517          	auipc	a0,0x4
    80004964:	d7050513          	addi	a0,a0,-656 # 800086d0 <etext+0x6d0>
    80004968:	e89fb0ef          	jal	800007f0 <panic>
    return -1;
    8000496c:	597d                	li	s2,-1
    8000496e:	b775                	j	8000491a <fileread+0x5c>
    80004970:	597d                	li	s2,-1
    80004972:	64e2                	ld	s1,24(sp)
    80004974:	69a2                	ld	s3,8(sp)
    80004976:	b755                	j	8000491a <fileread+0x5c>
      return -1;
    80004978:	597d                	li	s2,-1
    8000497a:	64e2                	ld	s1,24(sp)
    8000497c:	69a2                	ld	s3,8(sp)
    8000497e:	bf71                	j	8000491a <fileread+0x5c>
    80004980:	597d                	li	s2,-1
    80004982:	64e2                	ld	s1,24(sp)
    80004984:	69a2                	ld	s3,8(sp)
    80004986:	bf51                	j	8000491a <fileread+0x5c>

0000000080004988 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    80004988:	00954783          	lbu	a5,9(a0)
    8000498c:	10078663          	beqz	a5,80004a98 <filewrite+0x110>
{
    80004990:	715d                	addi	sp,sp,-80
    80004992:	e486                	sd	ra,72(sp)
    80004994:	e0a2                	sd	s0,64(sp)
    80004996:	f84a                	sd	s2,48(sp)
    80004998:	f052                	sd	s4,32(sp)
    8000499a:	e85a                	sd	s6,16(sp)
    8000499c:	0880                	addi	s0,sp,80
    8000499e:	892a                	mv	s2,a0
    800049a0:	8b2e                	mv	s6,a1
    800049a2:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800049a4:	0e064c63          	bltz	a2,80004a9c <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800049a8:	411c                	lw	a5,0(a0)
    800049aa:	4705                	li	a4,1
    800049ac:	02e78763          	beq	a5,a4,800049da <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800049b0:	470d                	li	a4,3
    800049b2:	02e78863          	beq	a5,a4,800049e2 <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800049b6:	4709                	li	a4,2
    800049b8:	0ce79563          	bne	a5,a4,80004a82 <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800049bc:	0ec05663          	blez	a2,80004aa8 <filewrite+0x120>
    800049c0:	fc26                	sd	s1,56(sp)
    800049c2:	f44e                	sd	s3,40(sp)
    800049c4:	ec56                	sd	s5,24(sp)
    800049c6:	e45e                	sd	s7,8(sp)
    800049c8:	e062                	sd	s8,0(sp)
    int i = 0;
    800049ca:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    800049cc:	6b85                	lui	s7,0x1
    800049ce:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049d2:	6c05                	lui	s8,0x1
    800049d4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049d8:	a8b5                	j	80004a54 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800049da:	6908                	ld	a0,16(a0)
    800049dc:	24e000ef          	jal	80004c2a <pipewrite>
    800049e0:	a851                	j	80004a74 <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049e2:	02451783          	lh	a5,36(a0)
    800049e6:	03079693          	slli	a3,a5,0x30
    800049ea:	92c1                	srli	a3,a3,0x30
    800049ec:	4725                	li	a4,9
    800049ee:	0ad76963          	bltu	a4,a3,80004aa0 <filewrite+0x118>
    800049f2:	0792                	slli	a5,a5,0x4
    800049f4:	0001f717          	auipc	a4,0x1f
    800049f8:	50470713          	addi	a4,a4,1284 # 80023ef8 <devsw>
    800049fc:	97ba                	add	a5,a5,a4
    800049fe:	679c                	ld	a5,8(a5)
    80004a00:	c3d5                	beqz	a5,80004aa4 <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    80004a02:	4505                	li	a0,1
    80004a04:	9782                	jalr	a5
    80004a06:	a0bd                	j	80004a74 <filewrite+0xec>
      if (n1 > max)
    80004a08:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004a0c:	8e3ff0ef          	jal	800042ee <begin_op>
      ilock(f->ip);
    80004a10:	01893503          	ld	a0,24(s2)
    80004a14:	e93fe0ef          	jal	800038a6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a18:	8756                	mv	a4,s5
    80004a1a:	02092683          	lw	a3,32(s2)
    80004a1e:	01698633          	add	a2,s3,s6
    80004a22:	4585                	li	a1,1
    80004a24:	01893503          	ld	a0,24(s2)
    80004a28:	b52ff0ef          	jal	80003d7a <writei>
    80004a2c:	84aa                	mv	s1,a0
    80004a2e:	00a05763          	blez	a0,80004a3c <filewrite+0xb4>
        f->off += r;
    80004a32:	02092783          	lw	a5,32(s2)
    80004a36:	9fa9                	addw	a5,a5,a0
    80004a38:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a3c:	01893503          	ld	a0,24(s2)
    80004a40:	f15fe0ef          	jal	80003954 <iunlock>
      end_op();
    80004a44:	931ff0ef          	jal	80004374 <end_op>

      if (r != n1) {
    80004a48:	009a9e63          	bne	s5,s1,80004a64 <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    80004a4c:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    80004a50:	0149da63          	bge	s3,s4,80004a64 <filewrite+0xdc>
      int n1 = n - i;
    80004a54:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    80004a58:	0004879b          	sext.w	a5,s1
    80004a5c:	fafbd6e3          	bge	s7,a5,80004a08 <filewrite+0x80>
    80004a60:	84e2                	mv	s1,s8
    80004a62:	b75d                	j	80004a08 <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    80004a64:	053a1463          	bne	s4,s3,80004aac <filewrite+0x124>
    80004a68:	8552                	mv	a0,s4
    80004a6a:	74e2                	ld	s1,56(sp)
    80004a6c:	79a2                	ld	s3,40(sp)
    80004a6e:	6ae2                	ld	s5,24(sp)
    80004a70:	6ba2                	ld	s7,8(sp)
    80004a72:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a74:	60a6                	ld	ra,72(sp)
    80004a76:	6406                	ld	s0,64(sp)
    80004a78:	7942                	ld	s2,48(sp)
    80004a7a:	7a02                	ld	s4,32(sp)
    80004a7c:	6b42                	ld	s6,16(sp)
    80004a7e:	6161                	addi	sp,sp,80
    80004a80:	8082                	ret
    80004a82:	fc26                	sd	s1,56(sp)
    80004a84:	f44e                	sd	s3,40(sp)
    80004a86:	ec56                	sd	s5,24(sp)
    80004a88:	e45e                	sd	s7,8(sp)
    80004a8a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004a8c:	00004517          	auipc	a0,0x4
    80004a90:	c5450513          	addi	a0,a0,-940 # 800086e0 <etext+0x6e0>
    80004a94:	d5dfb0ef          	jal	800007f0 <panic>
    return -1;
    80004a98:	557d                	li	a0,-1
}
    80004a9a:	8082                	ret
    return -1;
    80004a9c:	557d                	li	a0,-1
    80004a9e:	bfd9                	j	80004a74 <filewrite+0xec>
      return -1;
    80004aa0:	557d                	li	a0,-1
    80004aa2:	bfc9                	j	80004a74 <filewrite+0xec>
    80004aa4:	557d                	li	a0,-1
    80004aa6:	b7f9                	j	80004a74 <filewrite+0xec>
    ret = (i == n ? n : -1);
    80004aa8:	8532                	mv	a0,a2
    80004aaa:	b7e9                	j	80004a74 <filewrite+0xec>
    80004aac:	557d                	li	a0,-1
    80004aae:	74e2                	ld	s1,56(sp)
    80004ab0:	79a2                	ld	s3,40(sp)
    80004ab2:	6ae2                	ld	s5,24(sp)
    80004ab4:	6ba2                	ld	s7,8(sp)
    80004ab6:	6c02                	ld	s8,0(sp)
    80004ab8:	bf75                	j	80004a74 <filewrite+0xec>

0000000080004aba <count_open_files>:

uint64
count_open_files(void)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 count = 0;

  // Read ftable.lock to securely count open entries
  acquire(&ftable.lock);
    80004ac4:	0001f517          	auipc	a0,0x1f
    80004ac8:	4d450513          	addi	a0,a0,1236 # 80023f98 <ftable>
    80004acc:	906fc0ef          	jal	80000bd2 <acquire>
  uint64 count = 0;
    80004ad0:	4481                	li	s1,0
  for(f = ftable.file; f < &ftable.file[NFILE]; f++) {
    80004ad2:	0001f797          	auipc	a5,0x1f
    80004ad6:	4de78793          	addi	a5,a5,1246 # 80023fb0 <ftable+0x18>
    80004ada:	00020697          	auipc	a3,0x20
    80004ade:	47668693          	addi	a3,a3,1142 # 80024f50 <disk>
    if(f->ref > 0) {
    80004ae2:	43d8                	lw	a4,4(a5)
      count++;
    80004ae4:	00e02733          	sgtz	a4,a4
    80004ae8:	94ba                	add	s1,s1,a4
  for(f = ftable.file; f < &ftable.file[NFILE]; f++) {
    80004aea:	02878793          	addi	a5,a5,40
    80004aee:	fed79ae3          	bne	a5,a3,80004ae2 <count_open_files+0x28>
    }
  }
  release(&ftable.lock);
    80004af2:	0001f517          	auipc	a0,0x1f
    80004af6:	4a650513          	addi	a0,a0,1190 # 80023f98 <ftable>
    80004afa:	964fc0ef          	jal	80000c5e <release>
  return count;
}
    80004afe:	8526                	mv	a0,s1
    80004b00:	60e2                	ld	ra,24(sp)
    80004b02:	6442                	ld	s0,16(sp)
    80004b04:	64a2                	ld	s1,8(sp)
    80004b06:	6105                	addi	sp,sp,32
    80004b08:	8082                	ret

0000000080004b0a <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b0a:	7179                	addi	sp,sp,-48
    80004b0c:	f406                	sd	ra,40(sp)
    80004b0e:	f022                	sd	s0,32(sp)
    80004b10:	ec26                	sd	s1,24(sp)
    80004b12:	e052                	sd	s4,0(sp)
    80004b14:	1800                	addi	s0,sp,48
    80004b16:	84aa                	mv	s1,a0
    80004b18:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b1a:	0005b023          	sd	zero,0(a1)
    80004b1e:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b22:	bd5ff0ef          	jal	800046f6 <filealloc>
    80004b26:	e088                	sd	a0,0(s1)
    80004b28:	c549                	beqz	a0,80004bb2 <pipealloc+0xa8>
    80004b2a:	bcdff0ef          	jal	800046f6 <filealloc>
    80004b2e:	00aa3023          	sd	a0,0(s4)
    80004b32:	cd25                	beqz	a0,80004baa <pipealloc+0xa0>
    80004b34:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    80004b36:	f95fb0ef          	jal	80000aca <kalloc>
    80004b3a:	892a                	mv	s2,a0
    80004b3c:	c12d                	beqz	a0,80004b9e <pipealloc+0x94>
    80004b3e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b40:	4985                	li	s3,1
    80004b42:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b46:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b4a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b4e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b52:	00004597          	auipc	a1,0x4
    80004b56:	89e58593          	addi	a1,a1,-1890 # 800083f0 <etext+0x3f0>
    80004b5a:	802fc0ef          	jal	80000b5c <initlock>
  (*f0)->type = FD_PIPE;
    80004b5e:	609c                	ld	a5,0(s1)
    80004b60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b64:	609c                	ld	a5,0(s1)
    80004b66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b6a:	609c                	ld	a5,0(s1)
    80004b6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b70:	609c                	ld	a5,0(s1)
    80004b72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b86:	000a3783          	ld	a5,0(s4)
    80004b8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b8e:	000a3783          	ld	a5,0(s4)
    80004b92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b96:	4501                	li	a0,0
    80004b98:	6942                	ld	s2,16(sp)
    80004b9a:	69a2                	ld	s3,8(sp)
    80004b9c:	a01d                	j	80004bc2 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004b9e:	6088                	ld	a0,0(s1)
    80004ba0:	c119                	beqz	a0,80004ba6 <pipealloc+0x9c>
    80004ba2:	6942                	ld	s2,16(sp)
    80004ba4:	a029                	j	80004bae <pipealloc+0xa4>
    80004ba6:	6942                	ld	s2,16(sp)
    80004ba8:	a029                	j	80004bb2 <pipealloc+0xa8>
    80004baa:	6088                	ld	a0,0(s1)
    80004bac:	c10d                	beqz	a0,80004bce <pipealloc+0xc4>
    fileclose(*f0);
    80004bae:	bedff0ef          	jal	8000479a <fileclose>
  if (*f1)
    80004bb2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bb6:	557d                	li	a0,-1
  if (*f1)
    80004bb8:	c789                	beqz	a5,80004bc2 <pipealloc+0xb8>
    fileclose(*f1);
    80004bba:	853e                	mv	a0,a5
    80004bbc:	bdfff0ef          	jal	8000479a <fileclose>
  return -1;
    80004bc0:	557d                	li	a0,-1
}
    80004bc2:	70a2                	ld	ra,40(sp)
    80004bc4:	7402                	ld	s0,32(sp)
    80004bc6:	64e2                	ld	s1,24(sp)
    80004bc8:	6a02                	ld	s4,0(sp)
    80004bca:	6145                	addi	sp,sp,48
    80004bcc:	8082                	ret
  return -1;
    80004bce:	557d                	li	a0,-1
    80004bd0:	bfcd                	j	80004bc2 <pipealloc+0xb8>

0000000080004bd2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bd2:	1101                	addi	sp,sp,-32
    80004bd4:	ec06                	sd	ra,24(sp)
    80004bd6:	e822                	sd	s0,16(sp)
    80004bd8:	e426                	sd	s1,8(sp)
    80004bda:	e04a                	sd	s2,0(sp)
    80004bdc:	1000                	addi	s0,sp,32
    80004bde:	84aa                	mv	s1,a0
    80004be0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004be2:	ff1fb0ef          	jal	80000bd2 <acquire>
  if (writable) {
    80004be6:	02090763          	beqz	s2,80004c14 <pipeclose+0x42>
    pi->writeopen = 0;
    80004bea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bee:	21848513          	addi	a0,s1,536
    80004bf2:	bfafd0ef          	jal	80001fec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    80004bf6:	2204b783          	ld	a5,544(s1)
    80004bfa:	e785                	bnez	a5,80004c22 <pipeclose+0x50>
    release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	860fc0ef          	jal	80000c5e <release>
    kfree((char *)pi);
    80004c02:	8526                	mv	a0,s1
    80004c04:	de5fb0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004c08:	60e2                	ld	ra,24(sp)
    80004c0a:	6442                	ld	s0,16(sp)
    80004c0c:	64a2                	ld	s1,8(sp)
    80004c0e:	6902                	ld	s2,0(sp)
    80004c10:	6105                	addi	sp,sp,32
    80004c12:	8082                	ret
    pi->readopen = 0;
    80004c14:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c18:	21c48513          	addi	a0,s1,540
    80004c1c:	bd0fd0ef          	jal	80001fec <wakeup>
    80004c20:	bfd9                	j	80004bf6 <pipeclose+0x24>
    release(&pi->lock);
    80004c22:	8526                	mv	a0,s1
    80004c24:	83afc0ef          	jal	80000c5e <release>
}
    80004c28:	b7c5                	j	80004c08 <pipeclose+0x36>

0000000080004c2a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c2a:	711d                	addi	sp,sp,-96
    80004c2c:	ec86                	sd	ra,88(sp)
    80004c2e:	e8a2                	sd	s0,80(sp)
    80004c30:	e4a6                	sd	s1,72(sp)
    80004c32:	e0ca                	sd	s2,64(sp)
    80004c34:	fc4e                	sd	s3,56(sp)
    80004c36:	f852                	sd	s4,48(sp)
    80004c38:	f456                	sd	s5,40(sp)
    80004c3a:	1080                	addi	s0,sp,96
    80004c3c:	84aa                	mv	s1,a0
    80004c3e:	8aae                	mv	s5,a1
    80004c40:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c42:	ca3fc0ef          	jal	800018e4 <myproc>
    80004c46:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	f89fb0ef          	jal	80000bd2 <acquire>
  while (i < n) {
    80004c4e:	0d405e63          	blez	s4,80004d2a <pipewrite+0x100>
    80004c52:	f05a                	sd	s6,32(sp)
    80004c54:	ec5e                	sd	s7,24(sp)
    80004c56:	e862                	sd	s8,16(sp)
  int i = 0;
    80004c58:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004c5a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c5c:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004c60:	21c48b93          	addi	s7,s1,540
    80004c64:	a091                	j	80004ca8 <pipewrite+0x7e>
      release(&pi->lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ff7fb0ef          	jal	80000c5e <release>
      return -1;
    80004c6c:	597d                	li	s2,-1
    80004c6e:	7b02                	ld	s6,32(sp)
    80004c70:	6be2                	ld	s7,24(sp)
    80004c72:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c74:	854a                	mv	a0,s2
    80004c76:	60e6                	ld	ra,88(sp)
    80004c78:	6446                	ld	s0,80(sp)
    80004c7a:	64a6                	ld	s1,72(sp)
    80004c7c:	6906                	ld	s2,64(sp)
    80004c7e:	79e2                	ld	s3,56(sp)
    80004c80:	7a42                	ld	s4,48(sp)
    80004c82:	7aa2                	ld	s5,40(sp)
    80004c84:	6125                	addi	sp,sp,96
    80004c86:	8082                	ret
      wakeup(&pi->nread);
    80004c88:	8562                	mv	a0,s8
    80004c8a:	b62fd0ef          	jal	80001fec <wakeup>
      sleep_prepare(&pi->nwrite);
    80004c8e:	855e                	mv	a0,s7
    80004c90:	af0fd0ef          	jal	80001f80 <sleep_prepare>
      release(&pi->lock);
    80004c94:	8526                	mv	a0,s1
    80004c96:	fc9fb0ef          	jal	80000c5e <release>
      sleep();
    80004c9a:	b22fd0ef          	jal	80001fbc <sleep>
      acquire(&pi->lock);
    80004c9e:	8526                	mv	a0,s1
    80004ca0:	f33fb0ef          	jal	80000bd2 <acquire>
  while (i < n) {
    80004ca4:	07495863          	bge	s2,s4,80004d14 <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    80004ca8:	2204a783          	lw	a5,544(s1)
    80004cac:	dfcd                	beqz	a5,80004c66 <pipewrite+0x3c>
    80004cae:	854e                	mv	a0,s3
    80004cb0:	d2afd0ef          	jal	800021da <killed>
    80004cb4:	f94d                	bnez	a0,80004c66 <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    80004cb6:	2184a783          	lw	a5,536(s1)
    80004cba:	21c4a703          	lw	a4,540(s1)
    80004cbe:	2007879b          	addiw	a5,a5,512
    80004cc2:	fcf703e3          	beq	a4,a5,80004c88 <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004cc6:	4705                	li	a4,1
    80004cc8:	015906b3          	add	a3,s2,s5
    80004ccc:	faf40613          	addi	a2,s0,-81
    80004cd0:	0489b583          	ld	a1,72(s3)
    80004cd4:	0509b503          	ld	a0,80(s3)
    80004cd8:	92ffc0ef          	jal	80001606 <copyin>
    80004cdc:	03650163          	beq	a0,s6,80004cfe <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ce0:	21c4a783          	lw	a5,540(s1)
    80004ce4:	0017871b          	addiw	a4,a5,1
    80004ce8:	20e4ae23          	sw	a4,540(s1)
    80004cec:	1ff7f793          	andi	a5,a5,511
    80004cf0:	97a6                	add	a5,a5,s1
    80004cf2:	faf44703          	lbu	a4,-81(s0)
    80004cf6:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cfa:	2905                	addiw	s2,s2,1
    80004cfc:	b765                	j	80004ca4 <pipewrite+0x7a>
        if (i == 0)
    80004cfe:	00090663          	beqz	s2,80004d0a <pipewrite+0xe0>
    80004d02:	7b02                	ld	s6,32(sp)
    80004d04:	6be2                	ld	s7,24(sp)
    80004d06:	6c42                	ld	s8,16(sp)
    80004d08:	a809                	j	80004d1a <pipewrite+0xf0>
          i = -1;
    80004d0a:	892a                	mv	s2,a0
        break;
    80004d0c:	7b02                	ld	s6,32(sp)
    80004d0e:	6be2                	ld	s7,24(sp)
    80004d10:	6c42                	ld	s8,16(sp)
    80004d12:	a021                	j	80004d1a <pipewrite+0xf0>
    80004d14:	7b02                	ld	s6,32(sp)
    80004d16:	6be2                	ld	s7,24(sp)
    80004d18:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004d1a:	21848513          	addi	a0,s1,536
    80004d1e:	acefd0ef          	jal	80001fec <wakeup>
  release(&pi->lock);
    80004d22:	8526                	mv	a0,s1
    80004d24:	f3bfb0ef          	jal	80000c5e <release>
  return i;
    80004d28:	b7b1                	j	80004c74 <pipewrite+0x4a>
  int i = 0;
    80004d2a:	4901                	li	s2,0
    80004d2c:	b7fd                	j	80004d1a <pipewrite+0xf0>

0000000080004d2e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d2e:	715d                	addi	sp,sp,-80
    80004d30:	e486                	sd	ra,72(sp)
    80004d32:	e0a2                	sd	s0,64(sp)
    80004d34:	fc26                	sd	s1,56(sp)
    80004d36:	f84a                	sd	s2,48(sp)
    80004d38:	f44e                	sd	s3,40(sp)
    80004d3a:	f052                	sd	s4,32(sp)
    80004d3c:	ec56                	sd	s5,24(sp)
    80004d3e:	0880                	addi	s0,sp,80
    80004d40:	84aa                	mv	s1,a0
    80004d42:	89ae                	mv	s3,a1
    80004d44:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d46:	b9ffc0ef          	jal	800018e4 <myproc>
    80004d4a:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004d4c:	8526                	mv	a0,s1
    80004d4e:	e85fb0ef          	jal	80000bd2 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004d52:	2184a703          	lw	a4,536(s1)
    80004d56:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004d5a:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004d5e:	02f71c63          	bne	a4,a5,80004d96 <piperead+0x68>
    80004d62:	2244a783          	lw	a5,548(s1)
    80004d66:	cf9d                	beqz	a5,80004da4 <piperead+0x76>
    if (killed(pr)) {
    80004d68:	854a                	mv	a0,s2
    80004d6a:	c70fd0ef          	jal	800021da <killed>
    80004d6e:	e515                	bnez	a0,80004d9a <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004d70:	8552                	mv	a0,s4
    80004d72:	a0efd0ef          	jal	80001f80 <sleep_prepare>
    release(&pi->lock);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ee7fb0ef          	jal	80000c5e <release>
    sleep();
    80004d7c:	a40fd0ef          	jal	80001fbc <sleep>
    acquire(&pi->lock);
    80004d80:	8526                	mv	a0,s1
    80004d82:	e51fb0ef          	jal	80000bd2 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004d86:	2184a703          	lw	a4,536(s1)
    80004d8a:	21c4a783          	lw	a5,540(s1)
    80004d8e:	fcf70ae3          	beq	a4,a5,80004d62 <piperead+0x34>
    80004d92:	e85a                	sd	s6,16(sp)
    80004d94:	a809                	j	80004da6 <piperead+0x78>
    80004d96:	e85a                	sd	s6,16(sp)
    80004d98:	a039                	j	80004da6 <piperead+0x78>
      release(&pi->lock);
    80004d9a:	8526                	mv	a0,s1
    80004d9c:	ec3fb0ef          	jal	80000c5e <release>
      return -1;
    80004da0:	5a7d                	li	s4,-1
    80004da2:	a08d                	j	80004e04 <piperead+0xd6>
    80004da4:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004da6:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004da8:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004daa:	05505563          	blez	s5,80004df4 <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    80004dae:	2184a783          	lw	a5,536(s1)
    80004db2:	21c4a703          	lw	a4,540(s1)
    80004db6:	02f70f63          	beq	a4,a5,80004df4 <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    80004dba:	1ff7f793          	andi	a5,a5,511
    80004dbe:	97a6                	add	a5,a5,s1
    80004dc0:	0187c783          	lbu	a5,24(a5)
    80004dc4:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    80004dc8:	4705                	li	a4,1
    80004dca:	fbf40693          	addi	a3,s0,-65
    80004dce:	864e                	mv	a2,s3
    80004dd0:	04893583          	ld	a1,72(s2)
    80004dd4:	05093503          	ld	a0,80(s2)
    80004dd8:	f42fc0ef          	jal	8000151a <copyout>
    80004ddc:	03650e63          	beq	a0,s6,80004e18 <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004de0:	2184a783          	lw	a5,536(s1)
    80004de4:	2785                	addiw	a5,a5,1
    80004de6:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    80004dea:	2a05                	addiw	s4,s4,1
    80004dec:	0985                	addi	s3,s3,1
    80004dee:	fd4a90e3          	bne	s5,s4,80004dae <piperead+0x80>
    80004df2:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    80004df4:	21c48513          	addi	a0,s1,540
    80004df8:	9f4fd0ef          	jal	80001fec <wakeup>
  release(&pi->lock);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	e61fb0ef          	jal	80000c5e <release>
    80004e02:	6b42                	ld	s6,16(sp)
  return i;
}
    80004e04:	8552                	mv	a0,s4
    80004e06:	60a6                	ld	ra,72(sp)
    80004e08:	6406                	ld	s0,64(sp)
    80004e0a:	74e2                	ld	s1,56(sp)
    80004e0c:	7942                	ld	s2,48(sp)
    80004e0e:	79a2                	ld	s3,40(sp)
    80004e10:	7a02                	ld	s4,32(sp)
    80004e12:	6ae2                	ld	s5,24(sp)
    80004e14:	6161                	addi	sp,sp,80
    80004e16:	8082                	ret
      if (i == 0)
    80004e18:	fc0a1ee3          	bnez	s4,80004df4 <piperead+0xc6>
        i = -1;
    80004e1c:	8a2a                	mv	s4,a0
    80004e1e:	bfd9                	j	80004df4 <piperead+0xc6>

0000000080004e20 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004e20:	1141                	addi	sp,sp,-16
    80004e22:	e422                	sd	s0,8(sp)
    80004e24:	0800                	addi	s0,sp,16
    80004e26:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    80004e28:	8905                	andi	a0,a0,1
    80004e2a:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004e2c:	8b89                	andi	a5,a5,2
    80004e2e:	c399                	beqz	a5,80004e34 <flags2perm+0x14>
    perm |= PTE_W;
    80004e30:	00456513          	ori	a0,a0,4
  return perm;
}
    80004e34:	6422                	ld	s0,8(sp)
    80004e36:	0141                	addi	sp,sp,16
    80004e38:	8082                	ret

0000000080004e3a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004e3a:	df010113          	addi	sp,sp,-528
    80004e3e:	20113423          	sd	ra,520(sp)
    80004e42:	20813023          	sd	s0,512(sp)
    80004e46:	ffa6                	sd	s1,504(sp)
    80004e48:	fbca                	sd	s2,496(sp)
    80004e4a:	0c00                	addi	s0,sp,528
    80004e4c:	892a                	mv	s2,a0
    80004e4e:	dea43c23          	sd	a0,-520(s0)
    80004e52:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e56:	a8ffc0ef          	jal	800018e4 <myproc>
    80004e5a:	84aa                	mv	s1,a0

  begin_op();
    80004e5c:	c92ff0ef          	jal	800042ee <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004e60:	854a                	mv	a0,s2
    80004e62:	ab8ff0ef          	jal	8000411a <namei>
    80004e66:	c931                	beqz	a0,80004eba <kexec+0x80>
    80004e68:	f3d2                	sd	s4,480(sp)
    80004e6a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e6c:	a3bfe0ef          	jal	800038a6 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e70:	04000713          	li	a4,64
    80004e74:	4681                	li	a3,0
    80004e76:	e5040613          	addi	a2,s0,-432
    80004e7a:	4581                	li	a1,0
    80004e7c:	8552                	mv	a0,s4
    80004e7e:	e01fe0ef          	jal	80003c7e <readi>
    80004e82:	04000793          	li	a5,64
    80004e86:	00f51a63          	bne	a0,a5,80004e9a <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004e8a:	e5042703          	lw	a4,-432(s0)
    80004e8e:	464c47b7          	lui	a5,0x464c4
    80004e92:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e96:	02f70663          	beq	a4,a5,80004ec2 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    80004e9a:	8552                	mv	a0,s4
    80004e9c:	c5dfe0ef          	jal	80003af8 <iunlockput>
    end_op();
    80004ea0:	cd4ff0ef          	jal	80004374 <end_op>
  }
  return -1;
    80004ea4:	557d                	li	a0,-1
    80004ea6:	7a1e                	ld	s4,480(sp)
}
    80004ea8:	20813083          	ld	ra,520(sp)
    80004eac:	20013403          	ld	s0,512(sp)
    80004eb0:	74fe                	ld	s1,504(sp)
    80004eb2:	795e                	ld	s2,496(sp)
    80004eb4:	21010113          	addi	sp,sp,528
    80004eb8:	8082                	ret
    end_op();
    80004eba:	cbaff0ef          	jal	80004374 <end_op>
    return -1;
    80004ebe:	557d                	li	a0,-1
    80004ec0:	b7e5                	j	80004ea8 <kexec+0x6e>
    80004ec2:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	b21fc0ef          	jal	800019e6 <proc_pagetable>
    80004eca:	8b2a                	mv	s6,a0
    80004ecc:	2c050963          	beqz	a0,8000519e <kexec+0x364>
    80004ed0:	f7ce                	sd	s3,488(sp)
    80004ed2:	efd6                	sd	s5,472(sp)
    80004ed4:	e7de                	sd	s7,456(sp)
    80004ed6:	e3e2                	sd	s8,448(sp)
    80004ed8:	ff66                	sd	s9,440(sp)
    80004eda:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004edc:	e7042d03          	lw	s10,-400(s0)
    80004ee0:	e8845783          	lhu	a5,-376(s0)
    80004ee4:	12078863          	beqz	a5,80005014 <kexec+0x1da>
    80004ee8:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eea:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004eec:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    80004eee:	6c85                	lui	s9,0x1
    80004ef0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ef4:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004ef8:	6a85                	lui	s5,0x1
    80004efa:	a085                	j	80004f5a <kexec+0x120>
      panic("loadseg: address should exist");
    80004efc:	00003517          	auipc	a0,0x3
    80004f00:	7f450513          	addi	a0,a0,2036 # 800086f0 <etext+0x6f0>
    80004f04:	8edfb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    80004f08:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004f0a:	8726                	mv	a4,s1
    80004f0c:	012c06bb          	addw	a3,s8,s2
    80004f10:	4581                	li	a1,0
    80004f12:	8552                	mv	a0,s4
    80004f14:	d6bfe0ef          	jal	80003c7e <readi>
    80004f18:	2501                	sext.w	a0,a0
    80004f1a:	24a49863          	bne	s1,a0,8000516a <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    80004f1e:	012a893b          	addw	s2,s5,s2
    80004f22:	03397363          	bgeu	s2,s3,80004f48 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004f26:	02091593          	slli	a1,s2,0x20
    80004f2a:	9181                	srli	a1,a1,0x20
    80004f2c:	95de                	add	a1,a1,s7
    80004f2e:	855a                	mv	a0,s6
    80004f30:	876fc0ef          	jal	80000fa6 <walkaddr>
    80004f34:	862a                	mv	a2,a0
    if (pa == 0)
    80004f36:	d179                	beqz	a0,80004efc <kexec+0xc2>
    if (sz - i < PGSIZE)
    80004f38:	412984bb          	subw	s1,s3,s2
    80004f3c:	0004879b          	sext.w	a5,s1
    80004f40:	fcfcf4e3          	bgeu	s9,a5,80004f08 <kexec+0xce>
    80004f44:	84d6                	mv	s1,s5
    80004f46:	b7c9                	j	80004f08 <kexec+0xce>
    sz = sz1;
    80004f48:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004f4c:	2d85                	addiw	s11,s11,1
    80004f4e:	038d0d1b          	addiw	s10,s10,56
    80004f52:	e8845783          	lhu	a5,-376(s0)
    80004f56:	08fdd063          	bge	s11,a5,80004fd6 <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f5a:	2d01                	sext.w	s10,s10
    80004f5c:	03800713          	li	a4,56
    80004f60:	86ea                	mv	a3,s10
    80004f62:	e1840613          	addi	a2,s0,-488
    80004f66:	4581                	li	a1,0
    80004f68:	8552                	mv	a0,s4
    80004f6a:	d15fe0ef          	jal	80003c7e <readi>
    80004f6e:	03800793          	li	a5,56
    80004f72:	1cf51463          	bne	a0,a5,8000513a <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    80004f76:	e1842783          	lw	a5,-488(s0)
    80004f7a:	4705                	li	a4,1
    80004f7c:	fce798e3          	bne	a5,a4,80004f4c <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004f80:	e4043483          	ld	s1,-448(s0)
    80004f84:	e3843783          	ld	a5,-456(s0)
    80004f88:	1af4ed63          	bltu	s1,a5,80005142 <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004f8c:	e2843783          	ld	a5,-472(s0)
    80004f90:	94be                	add	s1,s1,a5
    80004f92:	1af4ec63          	bltu	s1,a5,8000514a <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    80004f96:	df043703          	ld	a4,-528(s0)
    80004f9a:	8ff9                	and	a5,a5,a4
    80004f9c:	1a079b63          	bnez	a5,80005152 <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004fa0:	e1c42503          	lw	a0,-484(s0)
    80004fa4:	e7dff0ef          	jal	80004e20 <flags2perm>
    80004fa8:	86aa                	mv	a3,a0
    80004faa:	8626                	mv	a2,s1
    80004fac:	85ca                	mv	a1,s2
    80004fae:	855a                	mv	a0,s6
    80004fb0:	acefc0ef          	jal	8000127e <uvmalloc>
    80004fb4:	e0a43423          	sd	a0,-504(s0)
    80004fb8:	1a050163          	beqz	a0,8000515a <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fbc:	e2843b83          	ld	s7,-472(s0)
    80004fc0:	e2042c03          	lw	s8,-480(s0)
    80004fc4:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004fc8:	00098463          	beqz	s3,80004fd0 <kexec+0x196>
    80004fcc:	4901                	li	s2,0
    80004fce:	bfa1                	j	80004f26 <kexec+0xec>
    sz = sz1;
    80004fd0:	e0843903          	ld	s2,-504(s0)
    80004fd4:	bfa5                	j	80004f4c <kexec+0x112>
    80004fd6:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004fd8:	8552                	mv	a0,s4
    80004fda:	b1ffe0ef          	jal	80003af8 <iunlockput>
  end_op();
    80004fde:	b96ff0ef          	jal	80004374 <end_op>
  p = myproc();
    80004fe2:	903fc0ef          	jal	800018e4 <myproc>
    80004fe6:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004fe8:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    80004fec:	6b85                	lui	s7,0x1
    80004fee:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    80004ff0:	9bca                	add	s7,s7,s2
    80004ff2:	77fd                	lui	a5,0xfffff
    80004ff4:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004ff8:	4691                	li	a3,4
    80004ffa:	6609                	lui	a2,0x2
    80004ffc:	965e                	add	a2,a2,s7
    80004ffe:	85de                	mv	a1,s7
    80005000:	855a                	mv	a0,s6
    80005002:	a7cfc0ef          	jal	8000127e <uvmalloc>
    80005006:	e0a43423          	sd	a0,-504(s0)
    8000500a:	e519                	bnez	a0,80005018 <kexec+0x1de>
  if (pagetable)
    8000500c:	e1743423          	sd	s7,-504(s0)
    80005010:	4a01                	li	s4,0
    80005012:	aaa9                	j	8000516c <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005014:	4901                	li	s2,0
    80005016:	b7c9                	j	80004fd8 <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80005018:	75f9                	lui	a1,0xffffe
    8000501a:	8baa                	mv	s7,a0
    8000501c:	95aa                	add	a1,a1,a0
    8000501e:	855a                	mv	a0,s6
    80005020:	c34fc0ef          	jal	80001454 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80005024:	7afd                	lui	s5,0xfffff
    80005026:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    80005028:	e0043783          	ld	a5,-512(s0)
    8000502c:	6388                	ld	a0,0(a5)
    8000502e:	c15d                	beqz	a0,800050d4 <kexec+0x29a>
    80005030:	e9040913          	addi	s2,s0,-368
    80005034:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005036:	dd1fb0ef          	jal	80000e06 <strlen>
    8000503a:	0015079b          	addiw	a5,a0,1
    8000503e:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005042:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    80005046:	115bee63          	bltu	s7,s5,80005162 <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000504a:	e0043c83          	ld	s9,-512(s0)
    8000504e:	000cbc03          	ld	s8,0(s9)
    80005052:	8562                	mv	a0,s8
    80005054:	db3fb0ef          	jal	80000e06 <strlen>
    80005058:	0015071b          	addiw	a4,a0,1
    8000505c:	86e2                	mv	a3,s8
    8000505e:	865e                	mv	a2,s7
    80005060:	e0843583          	ld	a1,-504(s0)
    80005064:	855a                	mv	a0,s6
    80005066:	cb4fc0ef          	jal	8000151a <copyout>
    8000506a:	0e054e63          	bltz	a0,80005166 <kexec+0x32c>
    ustack[argc] = sp;
    8000506e:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80005072:	0485                	addi	s1,s1,1
    80005074:	008c8793          	addi	a5,s9,8
    80005078:	e0f43023          	sd	a5,-512(s0)
    8000507c:	008cb503          	ld	a0,8(s9)
    80005080:	0921                	addi	s2,s2,8
    80005082:	f955                	bnez	a0,80005036 <kexec+0x1fc>
  ustack[argc] = 0;
    80005084:	00349793          	slli	a5,s1,0x3
    80005088:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd9f00>
    8000508c:	97a2                	add	a5,a5,s0
    8000508e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005092:	00148713          	addi	a4,s1,1
    80005096:	070e                	slli	a4,a4,0x3
    80005098:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    8000509c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800050a0:	e0843583          	ld	a1,-504(s0)
    800050a4:	8bae                	mv	s7,a1
  if (sp < stackbase)
    800050a6:	f75963e3          	bltu	s2,s5,8000500c <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    800050aa:	e9040693          	addi	a3,s0,-368
    800050ae:	864a                	mv	a2,s2
    800050b0:	855a                	mv	a0,s6
    800050b2:	c68fc0ef          	jal	8000151a <copyout>
    800050b6:	0e054663          	bltz	a0,800051a2 <kexec+0x368>
  p->trapframe->a1 = sp;
    800050ba:	0589b783          	ld	a5,88(s3)
    800050be:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800050c2:	df843783          	ld	a5,-520(s0)
    800050c6:	0007c703          	lbu	a4,0(a5)
    800050ca:	c315                	beqz	a4,800050ee <kexec+0x2b4>
    800050cc:	0785                	addi	a5,a5,1
    if (*s == '/')
    800050ce:	02f00693          	li	a3,47
    800050d2:	a809                	j	800050e4 <kexec+0x2aa>
  sp = sz;
    800050d4:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    800050d8:	4481                	li	s1,0
    800050da:	b76d                	j	80005084 <kexec+0x24a>
  for (last = s = path; *s; s++)
    800050dc:	0785                	addi	a5,a5,1
    800050de:	fff7c703          	lbu	a4,-1(a5)
    800050e2:	c711                	beqz	a4,800050ee <kexec+0x2b4>
    if (*s == '/')
    800050e4:	fed71ce3          	bne	a4,a3,800050dc <kexec+0x2a2>
      last = s + 1;
    800050e8:	def43c23          	sd	a5,-520(s0)
    800050ec:	bfc5                	j	800050dc <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    800050ee:	4641                	li	a2,16
    800050f0:	df843583          	ld	a1,-520(s0)
    800050f4:	17098513          	addi	a0,s3,368
    800050f8:	cddfb0ef          	jal	80000dd4 <safestrcpy>
  oldpagetable = p->pagetable;
    800050fc:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80005100:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80005104:	e0843783          	ld	a5,-504(s0)
    80005108:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    8000510c:	0589b783          	ld	a5,88(s3)
    80005110:	e6843703          	ld	a4,-408(s0)
    80005114:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005116:	0589b783          	ld	a5,88(s3)
    8000511a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000511e:	85d2                	mv	a1,s4
    80005120:	94bfc0ef          	jal	80001a6a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005124:	0004851b          	sext.w	a0,s1
    80005128:	79be                	ld	s3,488(sp)
    8000512a:	7a1e                	ld	s4,480(sp)
    8000512c:	6afe                	ld	s5,472(sp)
    8000512e:	6b5e                	ld	s6,464(sp)
    80005130:	6bbe                	ld	s7,456(sp)
    80005132:	6c1e                	ld	s8,448(sp)
    80005134:	7cfa                	ld	s9,440(sp)
    80005136:	7d5a                	ld	s10,432(sp)
    80005138:	bb85                	j	80004ea8 <kexec+0x6e>
    8000513a:	e1243423          	sd	s2,-504(s0)
    8000513e:	7dba                	ld	s11,424(sp)
    80005140:	a035                	j	8000516c <kexec+0x332>
    80005142:	e1243423          	sd	s2,-504(s0)
    80005146:	7dba                	ld	s11,424(sp)
    80005148:	a015                	j	8000516c <kexec+0x332>
    8000514a:	e1243423          	sd	s2,-504(s0)
    8000514e:	7dba                	ld	s11,424(sp)
    80005150:	a831                	j	8000516c <kexec+0x332>
    80005152:	e1243423          	sd	s2,-504(s0)
    80005156:	7dba                	ld	s11,424(sp)
    80005158:	a811                	j	8000516c <kexec+0x332>
    8000515a:	e1243423          	sd	s2,-504(s0)
    8000515e:	7dba                	ld	s11,424(sp)
    80005160:	a031                	j	8000516c <kexec+0x332>
  ip = 0;
    80005162:	4a01                	li	s4,0
    80005164:	a021                	j	8000516c <kexec+0x332>
    80005166:	4a01                	li	s4,0
  if (pagetable)
    80005168:	a011                	j	8000516c <kexec+0x332>
    8000516a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000516c:	e0843583          	ld	a1,-504(s0)
    80005170:	855a                	mv	a0,s6
    80005172:	8f9fc0ef          	jal	80001a6a <proc_freepagetable>
  return -1;
    80005176:	557d                	li	a0,-1
  if (ip) {
    80005178:	000a1b63          	bnez	s4,8000518e <kexec+0x354>
    8000517c:	79be                	ld	s3,488(sp)
    8000517e:	7a1e                	ld	s4,480(sp)
    80005180:	6afe                	ld	s5,472(sp)
    80005182:	6b5e                	ld	s6,464(sp)
    80005184:	6bbe                	ld	s7,456(sp)
    80005186:	6c1e                	ld	s8,448(sp)
    80005188:	7cfa                	ld	s9,440(sp)
    8000518a:	7d5a                	ld	s10,432(sp)
    8000518c:	bb31                	j	80004ea8 <kexec+0x6e>
    8000518e:	79be                	ld	s3,488(sp)
    80005190:	6afe                	ld	s5,472(sp)
    80005192:	6b5e                	ld	s6,464(sp)
    80005194:	6bbe                	ld	s7,456(sp)
    80005196:	6c1e                	ld	s8,448(sp)
    80005198:	7cfa                	ld	s9,440(sp)
    8000519a:	7d5a                	ld	s10,432(sp)
    8000519c:	b9fd                	j	80004e9a <kexec+0x60>
    8000519e:	6b5e                	ld	s6,464(sp)
    800051a0:	b9ed                	j	80004e9a <kexec+0x60>
  sz = sz1;
    800051a2:	e0843b83          	ld	s7,-504(s0)
    800051a6:	b59d                	j	8000500c <kexec+0x1d2>

00000000800051a8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051a8:	7179                	addi	sp,sp,-48
    800051aa:	f406                	sd	ra,40(sp)
    800051ac:	f022                	sd	s0,32(sp)
    800051ae:	ec26                	sd	s1,24(sp)
    800051b0:	e84a                	sd	s2,16(sp)
    800051b2:	1800                	addi	s0,sp,48
    800051b4:	892e                	mv	s2,a1
    800051b6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051b8:	fdc40593          	addi	a1,s0,-36
    800051bc:	a71fd0ef          	jal	80002c2c <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    800051c0:	fdc42703          	lw	a4,-36(s0)
    800051c4:	47bd                	li	a5,15
    800051c6:	02e7e963          	bltu	a5,a4,800051f8 <argfd+0x50>
    800051ca:	f1afc0ef          	jal	800018e4 <myproc>
    800051ce:	fdc42703          	lw	a4,-36(s0)
    800051d2:	01a70793          	addi	a5,a4,26
    800051d6:	078e                	slli	a5,a5,0x3
    800051d8:	953e                	add	a0,a0,a5
    800051da:	611c                	ld	a5,0(a0)
    800051dc:	c385                	beqz	a5,800051fc <argfd+0x54>
    return -1;
  if (pfd)
    800051de:	00090463          	beqz	s2,800051e6 <argfd+0x3e>
    *pfd = fd;
    800051e2:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    800051e6:	4501                	li	a0,0
  if (pf)
    800051e8:	c091                	beqz	s1,800051ec <argfd+0x44>
    *pf = f;
    800051ea:	e09c                	sd	a5,0(s1)
}
    800051ec:	70a2                	ld	ra,40(sp)
    800051ee:	7402                	ld	s0,32(sp)
    800051f0:	64e2                	ld	s1,24(sp)
    800051f2:	6942                	ld	s2,16(sp)
    800051f4:	6145                	addi	sp,sp,48
    800051f6:	8082                	ret
    return -1;
    800051f8:	557d                	li	a0,-1
    800051fa:	bfcd                	j	800051ec <argfd+0x44>
    800051fc:	557d                	li	a0,-1
    800051fe:	b7fd                	j	800051ec <argfd+0x44>

0000000080005200 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005200:	1101                	addi	sp,sp,-32
    80005202:	ec06                	sd	ra,24(sp)
    80005204:	e822                	sd	s0,16(sp)
    80005206:	e426                	sd	s1,8(sp)
    80005208:	1000                	addi	s0,sp,32
    8000520a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000520c:	ed8fc0ef          	jal	800018e4 <myproc>
    80005210:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80005212:	0d050793          	addi	a5,a0,208
    80005216:	4501                	li	a0,0
    80005218:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    8000521a:	6398                	ld	a4,0(a5)
    8000521c:	cb19                	beqz	a4,80005232 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    8000521e:	2505                	addiw	a0,a0,1
    80005220:	07a1                	addi	a5,a5,8
    80005222:	fed51ce3          	bne	a0,a3,8000521a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005226:	557d                	li	a0,-1
}
    80005228:	60e2                	ld	ra,24(sp)
    8000522a:	6442                	ld	s0,16(sp)
    8000522c:	64a2                	ld	s1,8(sp)
    8000522e:	6105                	addi	sp,sp,32
    80005230:	8082                	ret
      p->ofile[fd] = f;
    80005232:	01a50793          	addi	a5,a0,26
    80005236:	078e                	slli	a5,a5,0x3
    80005238:	963e                	add	a2,a2,a5
    8000523a:	e204                	sd	s1,0(a2)
      return fd;
    8000523c:	b7f5                	j	80005228 <fdalloc+0x28>

000000008000523e <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    8000523e:	715d                	addi	sp,sp,-80
    80005240:	e486                	sd	ra,72(sp)
    80005242:	e0a2                	sd	s0,64(sp)
    80005244:	fc26                	sd	s1,56(sp)
    80005246:	f84a                	sd	s2,48(sp)
    80005248:	f44e                	sd	s3,40(sp)
    8000524a:	f052                	sd	s4,32(sp)
    8000524c:	ec56                	sd	s5,24(sp)
    8000524e:	0880                	addi	s0,sp,80
    80005250:	892e                	mv	s2,a1
    80005252:	89b2                	mv	s3,a2
    80005254:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80005256:	fb040593          	addi	a1,s0,-80
    8000525a:	edbfe0ef          	jal	80004134 <nameiparent>
    8000525e:	8aaa                	mv	s5,a0
    80005260:	cd45                	beqz	a0,80005318 <create+0xda>
    return 0;

  ilock(dp);
    80005262:	e44fe0ef          	jal	800038a6 <ilock>

  if (dp->nlink == 0) {
    80005266:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffd9fba>
    8000526a:	cf8d                	beqz	a5,800052a4 <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    8000526c:	4705                	li	a4,1
    8000526e:	04e91563          	bne	s2,a4,800052b8 <create+0x7a>
    80005272:	6721                	lui	a4,0x8
    80005274:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005276:	02e78c63          	beq	a5,a4,800052ae <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    8000527a:	4601                	li	a2,0
    8000527c:	fb040593          	addi	a1,s0,-80
    80005280:	8556                	mv	a0,s5
    80005282:	c23fe0ef          	jal	80003ea4 <dirlookup>
    80005286:	84aa                	mv	s1,a0
    80005288:	e951                	bnez	a0,8000531c <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    8000528a:	85ca                	mv	a1,s2
    8000528c:	000aa503          	lw	a0,0(s5)
    80005290:	ca6fe0ef          	jal	80003736 <ialloc>
    80005294:	84aa                	mv	s1,a0
    80005296:	0c051e63          	bnez	a0,80005372 <create+0x134>
    iunlockput(dp);
    8000529a:	8556                	mv	a0,s5
    8000529c:	85dfe0ef          	jal	80003af8 <iunlockput>
    return 0;
    800052a0:	4481                	li	s1,0
    800052a2:	a0a1                	j	800052ea <create+0xac>
    iunlockput(dp);
    800052a4:	8556                	mv	a0,s5
    800052a6:	853fe0ef          	jal	80003af8 <iunlockput>
    return 0;
    800052aa:	4481                	li	s1,0
    800052ac:	a83d                	j	800052ea <create+0xac>
    iunlockput(dp);
    800052ae:	8556                	mv	a0,s5
    800052b0:	849fe0ef          	jal	80003af8 <iunlockput>
    return 0;
    800052b4:	4481                	li	s1,0
    800052b6:	a815                	j	800052ea <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    800052b8:	4601                	li	a2,0
    800052ba:	fb040593          	addi	a1,s0,-80
    800052be:	8556                	mv	a0,s5
    800052c0:	be5fe0ef          	jal	80003ea4 <dirlookup>
    800052c4:	84aa                	mv	s1,a0
    800052c6:	c535                	beqz	a0,80005332 <create+0xf4>
    iunlockput(dp);
    800052c8:	8556                	mv	a0,s5
    800052ca:	82ffe0ef          	jal	80003af8 <iunlockput>
    ilock(ip);
    800052ce:	8526                	mv	a0,s1
    800052d0:	dd6fe0ef          	jal	800038a6 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052d4:	4789                	li	a5,2
    800052d6:	04f91963          	bne	s2,a5,80005328 <create+0xea>
    800052da:	0444d783          	lhu	a5,68(s1)
    800052de:	37f9                	addiw	a5,a5,-2
    800052e0:	17c2                	slli	a5,a5,0x30
    800052e2:	93c1                	srli	a5,a5,0x30
    800052e4:	4705                	li	a4,1
    800052e6:	04f76163          	bltu	a4,a5,80005328 <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052ea:	8526                	mv	a0,s1
    800052ec:	60a6                	ld	ra,72(sp)
    800052ee:	6406                	ld	s0,64(sp)
    800052f0:	74e2                	ld	s1,56(sp)
    800052f2:	7942                	ld	s2,48(sp)
    800052f4:	79a2                	ld	s3,40(sp)
    800052f6:	7a02                	ld	s4,32(sp)
    800052f8:	6ae2                	ld	s5,24(sp)
    800052fa:	6161                	addi	sp,sp,80
    800052fc:	8082                	ret
  ip->nlink = 0;
    800052fe:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80005302:	8526                	mv	a0,s1
    80005304:	ceefe0ef          	jal	800037f2 <iupdate>
  iunlockput(ip);
    80005308:	8526                	mv	a0,s1
    8000530a:	feefe0ef          	jal	80003af8 <iunlockput>
  iunlockput(dp);
    8000530e:	8556                	mv	a0,s5
    80005310:	fe8fe0ef          	jal	80003af8 <iunlockput>
  return 0;
    80005314:	4481                	li	s1,0
    80005316:	bfd1                	j	800052ea <create+0xac>
    return 0;
    80005318:	84aa                	mv	s1,a0
    8000531a:	bfc1                	j	800052ea <create+0xac>
    iunlockput(dp);
    8000531c:	8556                	mv	a0,s5
    8000531e:	fdafe0ef          	jal	80003af8 <iunlockput>
    ilock(ip);
    80005322:	8526                	mv	a0,s1
    80005324:	d82fe0ef          	jal	800038a6 <ilock>
    iunlockput(ip);
    80005328:	8526                	mv	a0,s1
    8000532a:	fcefe0ef          	jal	80003af8 <iunlockput>
    return 0;
    8000532e:	4481                	li	s1,0
    80005330:	bf6d                	j	800052ea <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80005332:	85ca                	mv	a1,s2
    80005334:	000aa503          	lw	a0,0(s5)
    80005338:	bfefe0ef          	jal	80003736 <ialloc>
    8000533c:	84aa                	mv	s1,a0
    8000533e:	dd31                	beqz	a0,8000529a <create+0x5c>
  ilock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	d64fe0ef          	jal	800038a6 <ilock>
  ip->major = major;
    80005346:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    8000534a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000534e:	4785                	li	a5,1
    80005350:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005354:	8526                	mv	a0,s1
    80005356:	c9cfe0ef          	jal	800037f2 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    8000535a:	40d0                	lw	a2,4(s1)
    8000535c:	fb040593          	addi	a1,s0,-80
    80005360:	8556                	mv	a0,s5
    80005362:	d1ffe0ef          	jal	80004080 <dirlink>
    80005366:	f8054ce3          	bltz	a0,800052fe <create+0xc0>
  iunlockput(dp);
    8000536a:	8556                	mv	a0,s5
    8000536c:	f8cfe0ef          	jal	80003af8 <iunlockput>
  return ip;
    80005370:	bfad                	j	800052ea <create+0xac>
  ilock(ip);
    80005372:	8526                	mv	a0,s1
    80005374:	d32fe0ef          	jal	800038a6 <ilock>
  ip->major = major;
    80005378:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    8000537c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005380:	4785                	li	a5,1
    80005382:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005386:	8526                	mv	a0,s1
    80005388:	c6afe0ef          	jal	800037f2 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000538c:	40d0                	lw	a2,4(s1)
    8000538e:	00003597          	auipc	a1,0x3
    80005392:	38a58593          	addi	a1,a1,906 # 80008718 <etext+0x718>
    80005396:	8526                	mv	a0,s1
    80005398:	ce9fe0ef          	jal	80004080 <dirlink>
    8000539c:	f60541e3          	bltz	a0,800052fe <create+0xc0>
    800053a0:	004aa603          	lw	a2,4(s5)
    800053a4:	00003597          	auipc	a1,0x3
    800053a8:	36c58593          	addi	a1,a1,876 # 80008710 <etext+0x710>
    800053ac:	8526                	mv	a0,s1
    800053ae:	cd3fe0ef          	jal	80004080 <dirlink>
    800053b2:	f40546e3          	bltz	a0,800052fe <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    800053b6:	40d0                	lw	a2,4(s1)
    800053b8:	fb040593          	addi	a1,s0,-80
    800053bc:	8556                	mv	a0,s5
    800053be:	cc3fe0ef          	jal	80004080 <dirlink>
    800053c2:	f2054ee3          	bltz	a0,800052fe <create+0xc0>
    dp->nlink++; // for ".."
    800053c6:	04aad783          	lhu	a5,74(s5)
    800053ca:	2785                	addiw	a5,a5,1
    800053cc:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    800053d0:	8556                	mv	a0,s5
    800053d2:	c20fe0ef          	jal	800037f2 <iupdate>
    800053d6:	bf51                	j	8000536a <create+0x12c>

00000000800053d8 <sys_dup>:
{
    800053d8:	7179                	addi	sp,sp,-48
    800053da:	f406                	sd	ra,40(sp)
    800053dc:	f022                	sd	s0,32(sp)
    800053de:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    800053e0:	fd840613          	addi	a2,s0,-40
    800053e4:	4581                	li	a1,0
    800053e6:	4501                	li	a0,0
    800053e8:	dc1ff0ef          	jal	800051a8 <argfd>
    return -1;
    800053ec:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    800053ee:	02054363          	bltz	a0,80005414 <sys_dup+0x3c>
    800053f2:	ec26                	sd	s1,24(sp)
    800053f4:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    800053f6:	fd843903          	ld	s2,-40(s0)
    800053fa:	854a                	mv	a0,s2
    800053fc:	e05ff0ef          	jal	80005200 <fdalloc>
    80005400:	84aa                	mv	s1,a0
    return -1;
    80005402:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80005404:	00054d63          	bltz	a0,8000541e <sys_dup+0x46>
  filedup(f);
    80005408:	854a                	mv	a0,s2
    8000540a:	b4aff0ef          	jal	80004754 <filedup>
  return fd;
    8000540e:	87a6                	mv	a5,s1
    80005410:	64e2                	ld	s1,24(sp)
    80005412:	6942                	ld	s2,16(sp)
}
    80005414:	853e                	mv	a0,a5
    80005416:	70a2                	ld	ra,40(sp)
    80005418:	7402                	ld	s0,32(sp)
    8000541a:	6145                	addi	sp,sp,48
    8000541c:	8082                	ret
    8000541e:	64e2                	ld	s1,24(sp)
    80005420:	6942                	ld	s2,16(sp)
    80005422:	bfcd                	j	80005414 <sys_dup+0x3c>

0000000080005424 <sys_read>:
{
    80005424:	7179                	addi	sp,sp,-48
    80005426:	f406                	sd	ra,40(sp)
    80005428:	f022                	sd	s0,32(sp)
    8000542a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000542c:	fd840593          	addi	a1,s0,-40
    80005430:	4505                	li	a0,1
    80005432:	817fd0ef          	jal	80002c48 <argaddr>
  argint(2, &n);
    80005436:	fe440593          	addi	a1,s0,-28
    8000543a:	4509                	li	a0,2
    8000543c:	ff0fd0ef          	jal	80002c2c <argint>
  if (argfd(0, 0, &f) < 0)
    80005440:	fe840613          	addi	a2,s0,-24
    80005444:	4581                	li	a1,0
    80005446:	4501                	li	a0,0
    80005448:	d61ff0ef          	jal	800051a8 <argfd>
    8000544c:	87aa                	mv	a5,a0
    return -1;
    8000544e:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005450:	0007ca63          	bltz	a5,80005464 <sys_read+0x40>
  return fileread(f, p, n);
    80005454:	fe442603          	lw	a2,-28(s0)
    80005458:	fd843583          	ld	a1,-40(s0)
    8000545c:	fe843503          	ld	a0,-24(s0)
    80005460:	c5eff0ef          	jal	800048be <fileread>
}
    80005464:	70a2                	ld	ra,40(sp)
    80005466:	7402                	ld	s0,32(sp)
    80005468:	6145                	addi	sp,sp,48
    8000546a:	8082                	ret

000000008000546c <sys_write>:
{
    8000546c:	7179                	addi	sp,sp,-48
    8000546e:	f406                	sd	ra,40(sp)
    80005470:	f022                	sd	s0,32(sp)
    80005472:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005474:	fd840593          	addi	a1,s0,-40
    80005478:	4505                	li	a0,1
    8000547a:	fcefd0ef          	jal	80002c48 <argaddr>
  argint(2, &n);
    8000547e:	fe440593          	addi	a1,s0,-28
    80005482:	4509                	li	a0,2
    80005484:	fa8fd0ef          	jal	80002c2c <argint>
  if (argfd(0, 0, &f) < 0)
    80005488:	fe840613          	addi	a2,s0,-24
    8000548c:	4581                	li	a1,0
    8000548e:	4501                	li	a0,0
    80005490:	d19ff0ef          	jal	800051a8 <argfd>
    80005494:	87aa                	mv	a5,a0
    return -1;
    80005496:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005498:	0007ca63          	bltz	a5,800054ac <sys_write+0x40>
  return filewrite(f, p, n);
    8000549c:	fe442603          	lw	a2,-28(s0)
    800054a0:	fd843583          	ld	a1,-40(s0)
    800054a4:	fe843503          	ld	a0,-24(s0)
    800054a8:	ce0ff0ef          	jal	80004988 <filewrite>
}
    800054ac:	70a2                	ld	ra,40(sp)
    800054ae:	7402                	ld	s0,32(sp)
    800054b0:	6145                	addi	sp,sp,48
    800054b2:	8082                	ret

00000000800054b4 <sys_close>:
{
    800054b4:	1101                	addi	sp,sp,-32
    800054b6:	ec06                	sd	ra,24(sp)
    800054b8:	e822                	sd	s0,16(sp)
    800054ba:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    800054bc:	fe040613          	addi	a2,s0,-32
    800054c0:	fec40593          	addi	a1,s0,-20
    800054c4:	4501                	li	a0,0
    800054c6:	ce3ff0ef          	jal	800051a8 <argfd>
    return -1;
    800054ca:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    800054cc:	02054063          	bltz	a0,800054ec <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800054d0:	c14fc0ef          	jal	800018e4 <myproc>
    800054d4:	fec42783          	lw	a5,-20(s0)
    800054d8:	07e9                	addi	a5,a5,26
    800054da:	078e                	slli	a5,a5,0x3
    800054dc:	953e                	add	a0,a0,a5
    800054de:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054e2:	fe043503          	ld	a0,-32(s0)
    800054e6:	ab4ff0ef          	jal	8000479a <fileclose>
  return 0;
    800054ea:	4781                	li	a5,0
}
    800054ec:	853e                	mv	a0,a5
    800054ee:	60e2                	ld	ra,24(sp)
    800054f0:	6442                	ld	s0,16(sp)
    800054f2:	6105                	addi	sp,sp,32
    800054f4:	8082                	ret

00000000800054f6 <sys_fstat>:
{
    800054f6:	1101                	addi	sp,sp,-32
    800054f8:	ec06                	sd	ra,24(sp)
    800054fa:	e822                	sd	s0,16(sp)
    800054fc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054fe:	fe040593          	addi	a1,s0,-32
    80005502:	4505                	li	a0,1
    80005504:	f44fd0ef          	jal	80002c48 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80005508:	fe840613          	addi	a2,s0,-24
    8000550c:	4581                	li	a1,0
    8000550e:	4501                	li	a0,0
    80005510:	c99ff0ef          	jal	800051a8 <argfd>
    80005514:	87aa                	mv	a5,a0
    return -1;
    80005516:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80005518:	0007c863          	bltz	a5,80005528 <sys_fstat+0x32>
  return filestat(f, st);
    8000551c:	fe043583          	ld	a1,-32(s0)
    80005520:	fe843503          	ld	a0,-24(s0)
    80005524:	b38ff0ef          	jal	8000485c <filestat>
}
    80005528:	60e2                	ld	ra,24(sp)
    8000552a:	6442                	ld	s0,16(sp)
    8000552c:	6105                	addi	sp,sp,32
    8000552e:	8082                	ret

0000000080005530 <sys_link>:
{
    80005530:	7169                	addi	sp,sp,-304
    80005532:	f606                	sd	ra,296(sp)
    80005534:	f222                	sd	s0,288(sp)
    80005536:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005538:	08000613          	li	a2,128
    8000553c:	ed040593          	addi	a1,s0,-304
    80005540:	4501                	li	a0,0
    80005542:	f22fd0ef          	jal	80002c64 <argstr>
    return -1;
    80005546:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005548:	10054163          	bltz	a0,8000564a <sys_link+0x11a>
    8000554c:	08000613          	li	a2,128
    80005550:	f5040593          	addi	a1,s0,-176
    80005554:	4505                	li	a0,1
    80005556:	f0efd0ef          	jal	80002c64 <argstr>
    return -1;
    8000555a:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000555c:	0e054763          	bltz	a0,8000564a <sys_link+0x11a>
    80005560:	ee26                	sd	s1,280(sp)
  begin_op();
    80005562:	d8dfe0ef          	jal	800042ee <begin_op>
  if ((ip = namei(old)) == 0) {
    80005566:	ed040513          	addi	a0,s0,-304
    8000556a:	bb1fe0ef          	jal	8000411a <namei>
    8000556e:	84aa                	mv	s1,a0
    80005570:	cd35                	beqz	a0,800055ec <sys_link+0xbc>
  ilock(ip);
    80005572:	b34fe0ef          	jal	800038a6 <ilock>
  if (ip->type == T_DIR) {
    80005576:	04449703          	lh	a4,68(s1)
    8000557a:	4785                	li	a5,1
    8000557c:	06f70d63          	beq	a4,a5,800055f6 <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005580:	04a49783          	lh	a5,74(s1)
    80005584:	6721                	lui	a4,0x8
    80005586:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80005588:	06e78f63          	beq	a5,a4,80005606 <sys_link+0xd6>
    8000558c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000558e:	2785                	addiw	a5,a5,1
    80005590:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005594:	8526                	mv	a0,s1
    80005596:	a5cfe0ef          	jal	800037f2 <iupdate>
  iunlock(ip);
    8000559a:	8526                	mv	a0,s1
    8000559c:	bb8fe0ef          	jal	80003954 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    800055a0:	fd040593          	addi	a1,s0,-48
    800055a4:	f5040513          	addi	a0,s0,-176
    800055a8:	b8dfe0ef          	jal	80004134 <nameiparent>
    800055ac:	892a                	mv	s2,a0
    800055ae:	c93d                	beqz	a0,80005624 <sys_link+0xf4>
  ilock(dp);
    800055b0:	af6fe0ef          	jal	800038a6 <ilock>
  if (dp->nlink == 0) {
    800055b4:	04a91783          	lh	a5,74(s2)
    800055b8:	cfb9                	beqz	a5,80005616 <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    800055ba:	00092703          	lw	a4,0(s2)
    800055be:	409c                	lw	a5,0(s1)
    800055c0:	04f71f63          	bne	a4,a5,8000561e <sys_link+0xee>
    800055c4:	40d0                	lw	a2,4(s1)
    800055c6:	fd040593          	addi	a1,s0,-48
    800055ca:	854a                	mv	a0,s2
    800055cc:	ab5fe0ef          	jal	80004080 <dirlink>
    800055d0:	04054763          	bltz	a0,8000561e <sys_link+0xee>
  iunlockput(dp);
    800055d4:	854a                	mv	a0,s2
    800055d6:	d22fe0ef          	jal	80003af8 <iunlockput>
  iput(ip);
    800055da:	8526                	mv	a0,s1
    800055dc:	c4cfe0ef          	jal	80003a28 <iput>
  end_op();
    800055e0:	d95fe0ef          	jal	80004374 <end_op>
  return 0;
    800055e4:	4781                	li	a5,0
    800055e6:	64f2                	ld	s1,280(sp)
    800055e8:	6952                	ld	s2,272(sp)
    800055ea:	a085                	j	8000564a <sys_link+0x11a>
    end_op();
    800055ec:	d89fe0ef          	jal	80004374 <end_op>
    return -1;
    800055f0:	57fd                	li	a5,-1
    800055f2:	64f2                	ld	s1,280(sp)
    800055f4:	a899                	j	8000564a <sys_link+0x11a>
    iunlockput(ip);
    800055f6:	8526                	mv	a0,s1
    800055f8:	d00fe0ef          	jal	80003af8 <iunlockput>
    end_op();
    800055fc:	d79fe0ef          	jal	80004374 <end_op>
    return -1;
    80005600:	57fd                	li	a5,-1
    80005602:	64f2                	ld	s1,280(sp)
    80005604:	a099                	j	8000564a <sys_link+0x11a>
    iunlockput(ip);
    80005606:	8526                	mv	a0,s1
    80005608:	cf0fe0ef          	jal	80003af8 <iunlockput>
    end_op();
    8000560c:	d69fe0ef          	jal	80004374 <end_op>
    return -1;
    80005610:	57fd                	li	a5,-1
    80005612:	64f2                	ld	s1,280(sp)
    80005614:	a81d                	j	8000564a <sys_link+0x11a>
    iunlockput(dp);
    80005616:	854a                	mv	a0,s2
    80005618:	ce0fe0ef          	jal	80003af8 <iunlockput>
    goto bad;
    8000561c:	a021                	j	80005624 <sys_link+0xf4>
    iunlockput(dp);
    8000561e:	854a                	mv	a0,s2
    80005620:	cd8fe0ef          	jal	80003af8 <iunlockput>
  ilock(ip);
    80005624:	8526                	mv	a0,s1
    80005626:	a80fe0ef          	jal	800038a6 <ilock>
  ip->nlink--;
    8000562a:	04a4d783          	lhu	a5,74(s1)
    8000562e:	37fd                	addiw	a5,a5,-1
    80005630:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	9bcfe0ef          	jal	800037f2 <iupdate>
  iunlockput(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	cbcfe0ef          	jal	80003af8 <iunlockput>
  end_op();
    80005640:	d35fe0ef          	jal	80004374 <end_op>
  return -1;
    80005644:	57fd                	li	a5,-1
    80005646:	64f2                	ld	s1,280(sp)
    80005648:	6952                	ld	s2,272(sp)
}
    8000564a:	853e                	mv	a0,a5
    8000564c:	70b2                	ld	ra,296(sp)
    8000564e:	7412                	ld	s0,288(sp)
    80005650:	6155                	addi	sp,sp,304
    80005652:	8082                	ret

0000000080005654 <sys_unlink>:
{
    80005654:	7151                	addi	sp,sp,-240
    80005656:	f586                	sd	ra,232(sp)
    80005658:	f1a2                	sd	s0,224(sp)
    8000565a:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    8000565c:	08000613          	li	a2,128
    80005660:	f3040593          	addi	a1,s0,-208
    80005664:	4501                	li	a0,0
    80005666:	dfefd0ef          	jal	80002c64 <argstr>
    8000566a:	16054063          	bltz	a0,800057ca <sys_unlink+0x176>
    8000566e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005670:	c7ffe0ef          	jal	800042ee <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80005674:	fb040593          	addi	a1,s0,-80
    80005678:	f3040513          	addi	a0,s0,-208
    8000567c:	ab9fe0ef          	jal	80004134 <nameiparent>
    80005680:	84aa                	mv	s1,a0
    80005682:	c945                	beqz	a0,80005732 <sys_unlink+0xde>
  ilock(dp);
    80005684:	a22fe0ef          	jal	800038a6 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005688:	00003597          	auipc	a1,0x3
    8000568c:	09058593          	addi	a1,a1,144 # 80008718 <etext+0x718>
    80005690:	fb040513          	addi	a0,s0,-80
    80005694:	ffafe0ef          	jal	80003e8e <namecmp>
    80005698:	10050e63          	beqz	a0,800057b4 <sys_unlink+0x160>
    8000569c:	00003597          	auipc	a1,0x3
    800056a0:	07458593          	addi	a1,a1,116 # 80008710 <etext+0x710>
    800056a4:	fb040513          	addi	a0,s0,-80
    800056a8:	fe6fe0ef          	jal	80003e8e <namecmp>
    800056ac:	10050463          	beqz	a0,800057b4 <sys_unlink+0x160>
    800056b0:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    800056b2:	f2c40613          	addi	a2,s0,-212
    800056b6:	fb040593          	addi	a1,s0,-80
    800056ba:	8526                	mv	a0,s1
    800056bc:	fe8fe0ef          	jal	80003ea4 <dirlookup>
    800056c0:	892a                	mv	s2,a0
    800056c2:	0e050863          	beqz	a0,800057b2 <sys_unlink+0x15e>
  ilock(ip);
    800056c6:	9e0fe0ef          	jal	800038a6 <ilock>
  if (ip->nlink < 1)
    800056ca:	04a91783          	lh	a5,74(s2)
    800056ce:	06f05763          	blez	a5,8000573c <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    800056d2:	04491703          	lh	a4,68(s2)
    800056d6:	4785                	li	a5,1
    800056d8:	06f70963          	beq	a4,a5,8000574a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800056dc:	4641                	li	a2,16
    800056de:	4581                	li	a1,0
    800056e0:	fc040513          	addi	a0,s0,-64
    800056e4:	db2fb0ef          	jal	80000c96 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056e8:	4741                	li	a4,16
    800056ea:	f2c42683          	lw	a3,-212(s0)
    800056ee:	fc040613          	addi	a2,s0,-64
    800056f2:	4581                	li	a1,0
    800056f4:	8526                	mv	a0,s1
    800056f6:	e84fe0ef          	jal	80003d7a <writei>
    800056fa:	47c1                	li	a5,16
    800056fc:	08f51b63          	bne	a0,a5,80005792 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    80005700:	04491703          	lh	a4,68(s2)
    80005704:	4785                	li	a5,1
    80005706:	08f70d63          	beq	a4,a5,800057a0 <sys_unlink+0x14c>
  iunlockput(dp);
    8000570a:	8526                	mv	a0,s1
    8000570c:	becfe0ef          	jal	80003af8 <iunlockput>
  ip->nlink--;
    80005710:	04a95783          	lhu	a5,74(s2)
    80005714:	37fd                	addiw	a5,a5,-1
    80005716:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000571a:	854a                	mv	a0,s2
    8000571c:	8d6fe0ef          	jal	800037f2 <iupdate>
  iunlockput(ip);
    80005720:	854a                	mv	a0,s2
    80005722:	bd6fe0ef          	jal	80003af8 <iunlockput>
  end_op();
    80005726:	c4ffe0ef          	jal	80004374 <end_op>
  return 0;
    8000572a:	4501                	li	a0,0
    8000572c:	64ee                	ld	s1,216(sp)
    8000572e:	694e                	ld	s2,208(sp)
    80005730:	a849                	j	800057c2 <sys_unlink+0x16e>
    end_op();
    80005732:	c43fe0ef          	jal	80004374 <end_op>
    return -1;
    80005736:	557d                	li	a0,-1
    80005738:	64ee                	ld	s1,216(sp)
    8000573a:	a061                	j	800057c2 <sys_unlink+0x16e>
    8000573c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000573e:	00003517          	auipc	a0,0x3
    80005742:	fe250513          	addi	a0,a0,-30 # 80008720 <etext+0x720>
    80005746:	8aafb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000574a:	04c92703          	lw	a4,76(s2)
    8000574e:	02000793          	li	a5,32
    80005752:	f8e7f5e3          	bgeu	a5,a4,800056dc <sys_unlink+0x88>
    80005756:	e5ce                	sd	s3,200(sp)
    80005758:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000575c:	4741                	li	a4,16
    8000575e:	86ce                	mv	a3,s3
    80005760:	f1840613          	addi	a2,s0,-232
    80005764:	4581                	li	a1,0
    80005766:	854a                	mv	a0,s2
    80005768:	d16fe0ef          	jal	80003c7e <readi>
    8000576c:	47c1                	li	a5,16
    8000576e:	00f51c63          	bne	a0,a5,80005786 <sys_unlink+0x132>
    if (de.inum != 0)
    80005772:	f1845783          	lhu	a5,-232(s0)
    80005776:	efa1                	bnez	a5,800057ce <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005778:	29c1                	addiw	s3,s3,16
    8000577a:	04c92783          	lw	a5,76(s2)
    8000577e:	fcf9efe3          	bltu	s3,a5,8000575c <sys_unlink+0x108>
    80005782:	69ae                	ld	s3,200(sp)
    80005784:	bfa1                	j	800056dc <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005786:	00003517          	auipc	a0,0x3
    8000578a:	fb250513          	addi	a0,a0,-78 # 80008738 <etext+0x738>
    8000578e:	862fb0ef          	jal	800007f0 <panic>
    80005792:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005794:	00003517          	auipc	a0,0x3
    80005798:	fbc50513          	addi	a0,a0,-68 # 80008750 <etext+0x750>
    8000579c:	854fb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    800057a0:	04a4d783          	lhu	a5,74(s1)
    800057a4:	37fd                	addiw	a5,a5,-1
    800057a6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057aa:	8526                	mv	a0,s1
    800057ac:	846fe0ef          	jal	800037f2 <iupdate>
    800057b0:	bfa9                	j	8000570a <sys_unlink+0xb6>
    800057b2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800057b4:	8526                	mv	a0,s1
    800057b6:	b42fe0ef          	jal	80003af8 <iunlockput>
  end_op();
    800057ba:	bbbfe0ef          	jal	80004374 <end_op>
  return -1;
    800057be:	557d                	li	a0,-1
    800057c0:	64ee                	ld	s1,216(sp)
}
    800057c2:	70ae                	ld	ra,232(sp)
    800057c4:	740e                	ld	s0,224(sp)
    800057c6:	616d                	addi	sp,sp,240
    800057c8:	8082                	ret
    return -1;
    800057ca:	557d                	li	a0,-1
    800057cc:	bfdd                	j	800057c2 <sys_unlink+0x16e>
    iunlockput(ip);
    800057ce:	854a                	mv	a0,s2
    800057d0:	b28fe0ef          	jal	80003af8 <iunlockput>
    goto bad;
    800057d4:	694e                	ld	s2,208(sp)
    800057d6:	69ae                	ld	s3,200(sp)
    800057d8:	bff1                	j	800057b4 <sys_unlink+0x160>

00000000800057da <sys_open>:

uint64
sys_open(void)
{
    800057da:	7131                	addi	sp,sp,-192
    800057dc:	fd06                	sd	ra,184(sp)
    800057de:	f922                	sd	s0,176(sp)
    800057e0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057e2:	f4c40593          	addi	a1,s0,-180
    800057e6:	4505                	li	a0,1
    800057e8:	c44fd0ef          	jal	80002c2c <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800057ec:	08000613          	li	a2,128
    800057f0:	f5040593          	addi	a1,s0,-176
    800057f4:	4501                	li	a0,0
    800057f6:	c6efd0ef          	jal	80002c64 <argstr>
    800057fa:	87aa                	mv	a5,a0
    return -1;
    800057fc:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800057fe:	0a07c263          	bltz	a5,800058a2 <sys_open+0xc8>
    80005802:	f526                	sd	s1,168(sp)

  begin_op();
    80005804:	aebfe0ef          	jal	800042ee <begin_op>

  if (omode & O_CREATE) {
    80005808:	f4c42783          	lw	a5,-180(s0)
    8000580c:	2007f793          	andi	a5,a5,512
    80005810:	c3d5                	beqz	a5,800058b4 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005812:	4681                	li	a3,0
    80005814:	4601                	li	a2,0
    80005816:	4589                	li	a1,2
    80005818:	f5040513          	addi	a0,s0,-176
    8000581c:	a23ff0ef          	jal	8000523e <create>
    80005820:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005822:	c541                	beqz	a0,800058aa <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    80005824:	04449703          	lh	a4,68(s1)
    80005828:	478d                	li	a5,3
    8000582a:	00f71763          	bne	a4,a5,80005838 <sys_open+0x5e>
    8000582e:	0464d703          	lhu	a4,70(s1)
    80005832:	47a5                	li	a5,9
    80005834:	0ae7ed63          	bltu	a5,a4,800058ee <sys_open+0x114>
    80005838:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    8000583a:	ebdfe0ef          	jal	800046f6 <filealloc>
    8000583e:	892a                	mv	s2,a0
    80005840:	c179                	beqz	a0,80005906 <sys_open+0x12c>
    80005842:	ed4e                	sd	s3,152(sp)
    80005844:	9bdff0ef          	jal	80005200 <fdalloc>
    80005848:	89aa                	mv	s3,a0
    8000584a:	0a054a63          	bltz	a0,800058fe <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000584e:	04449703          	lh	a4,68(s1)
    80005852:	478d                	li	a5,3
    80005854:	0cf70263          	beq	a4,a5,80005918 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005858:	4789                	li	a5,2
    8000585a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000585e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005862:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005866:	f4c42783          	lw	a5,-180(s0)
    8000586a:	0017c713          	xori	a4,a5,1
    8000586e:	8b05                	andi	a4,a4,1
    80005870:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005874:	0037f713          	andi	a4,a5,3
    80005878:	00e03733          	snez	a4,a4
    8000587c:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005880:	4007f793          	andi	a5,a5,1024
    80005884:	c791                	beqz	a5,80005890 <sys_open+0xb6>
    80005886:	04449703          	lh	a4,68(s1)
    8000588a:	4789                	li	a5,2
    8000588c:	08f70d63          	beq	a4,a5,80005926 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005890:	8526                	mv	a0,s1
    80005892:	8c2fe0ef          	jal	80003954 <iunlock>
  end_op();
    80005896:	adffe0ef          	jal	80004374 <end_op>

  return fd;
    8000589a:	854e                	mv	a0,s3
    8000589c:	74aa                	ld	s1,168(sp)
    8000589e:	790a                	ld	s2,160(sp)
    800058a0:	69ea                	ld	s3,152(sp)
}
    800058a2:	70ea                	ld	ra,184(sp)
    800058a4:	744a                	ld	s0,176(sp)
    800058a6:	6129                	addi	sp,sp,192
    800058a8:	8082                	ret
      end_op();
    800058aa:	acbfe0ef          	jal	80004374 <end_op>
      return -1;
    800058ae:	557d                	li	a0,-1
    800058b0:	74aa                	ld	s1,168(sp)
    800058b2:	bfc5                	j	800058a2 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    800058b4:	f5040513          	addi	a0,s0,-176
    800058b8:	863fe0ef          	jal	8000411a <namei>
    800058bc:	84aa                	mv	s1,a0
    800058be:	c11d                	beqz	a0,800058e4 <sys_open+0x10a>
    ilock(ip);
    800058c0:	fe7fd0ef          	jal	800038a6 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800058c4:	04449703          	lh	a4,68(s1)
    800058c8:	4785                	li	a5,1
    800058ca:	f4f71de3          	bne	a4,a5,80005824 <sys_open+0x4a>
    800058ce:	f4c42783          	lw	a5,-180(s0)
    800058d2:	d3bd                	beqz	a5,80005838 <sys_open+0x5e>
      iunlockput(ip);
    800058d4:	8526                	mv	a0,s1
    800058d6:	a22fe0ef          	jal	80003af8 <iunlockput>
      end_op();
    800058da:	a9bfe0ef          	jal	80004374 <end_op>
      return -1;
    800058de:	557d                	li	a0,-1
    800058e0:	74aa                	ld	s1,168(sp)
    800058e2:	b7c1                	j	800058a2 <sys_open+0xc8>
      end_op();
    800058e4:	a91fe0ef          	jal	80004374 <end_op>
      return -1;
    800058e8:	557d                	li	a0,-1
    800058ea:	74aa                	ld	s1,168(sp)
    800058ec:	bf5d                	j	800058a2 <sys_open+0xc8>
    iunlockput(ip);
    800058ee:	8526                	mv	a0,s1
    800058f0:	a08fe0ef          	jal	80003af8 <iunlockput>
    end_op();
    800058f4:	a81fe0ef          	jal	80004374 <end_op>
    return -1;
    800058f8:	557d                	li	a0,-1
    800058fa:	74aa                	ld	s1,168(sp)
    800058fc:	b75d                	j	800058a2 <sys_open+0xc8>
      fileclose(f);
    800058fe:	854a                	mv	a0,s2
    80005900:	e9bfe0ef          	jal	8000479a <fileclose>
    80005904:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005906:	8526                	mv	a0,s1
    80005908:	9f0fe0ef          	jal	80003af8 <iunlockput>
    end_op();
    8000590c:	a69fe0ef          	jal	80004374 <end_op>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	74aa                	ld	s1,168(sp)
    80005914:	790a                	ld	s2,160(sp)
    80005916:	b771                	j	800058a2 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005918:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000591c:	04649783          	lh	a5,70(s1)
    80005920:	02f91223          	sh	a5,36(s2)
    80005924:	bf3d                	j	80005862 <sys_open+0x88>
    itrunc(ip);
    80005926:	8526                	mv	a0,s1
    80005928:	86cfe0ef          	jal	80003994 <itrunc>
    8000592c:	b795                	j	80005890 <sys_open+0xb6>

000000008000592e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000592e:	7175                	addi	sp,sp,-144
    80005930:	e506                	sd	ra,136(sp)
    80005932:	e122                	sd	s0,128(sp)
    80005934:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005936:	9b9fe0ef          	jal	800042ee <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    8000593a:	08000613          	li	a2,128
    8000593e:	f7040593          	addi	a1,s0,-144
    80005942:	4501                	li	a0,0
    80005944:	b20fd0ef          	jal	80002c64 <argstr>
    80005948:	02054363          	bltz	a0,8000596e <sys_mkdir+0x40>
    8000594c:	4681                	li	a3,0
    8000594e:	4601                	li	a2,0
    80005950:	4585                	li	a1,1
    80005952:	f7040513          	addi	a0,s0,-144
    80005956:	8e9ff0ef          	jal	8000523e <create>
    8000595a:	c911                	beqz	a0,8000596e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000595c:	99cfe0ef          	jal	80003af8 <iunlockput>
  end_op();
    80005960:	a15fe0ef          	jal	80004374 <end_op>
  return 0;
    80005964:	4501                	li	a0,0
}
    80005966:	60aa                	ld	ra,136(sp)
    80005968:	640a                	ld	s0,128(sp)
    8000596a:	6149                	addi	sp,sp,144
    8000596c:	8082                	ret
    end_op();
    8000596e:	a07fe0ef          	jal	80004374 <end_op>
    return -1;
    80005972:	557d                	li	a0,-1
    80005974:	bfcd                	j	80005966 <sys_mkdir+0x38>

0000000080005976 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005976:	7135                	addi	sp,sp,-160
    80005978:	ed06                	sd	ra,152(sp)
    8000597a:	e922                	sd	s0,144(sp)
    8000597c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000597e:	971fe0ef          	jal	800042ee <begin_op>
  argint(1, &major);
    80005982:	f6c40593          	addi	a1,s0,-148
    80005986:	4505                	li	a0,1
    80005988:	aa4fd0ef          	jal	80002c2c <argint>
  argint(2, &minor);
    8000598c:	f6840593          	addi	a1,s0,-152
    80005990:	4509                	li	a0,2
    80005992:	a9afd0ef          	jal	80002c2c <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005996:	08000613          	li	a2,128
    8000599a:	f7040593          	addi	a1,s0,-144
    8000599e:	4501                	li	a0,0
    800059a0:	ac4fd0ef          	jal	80002c64 <argstr>
    800059a4:	02054563          	bltz	a0,800059ce <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800059a8:	f6841683          	lh	a3,-152(s0)
    800059ac:	f6c41603          	lh	a2,-148(s0)
    800059b0:	458d                	li	a1,3
    800059b2:	f7040513          	addi	a0,s0,-144
    800059b6:	889ff0ef          	jal	8000523e <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800059ba:	c911                	beqz	a0,800059ce <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059bc:	93cfe0ef          	jal	80003af8 <iunlockput>
  end_op();
    800059c0:	9b5fe0ef          	jal	80004374 <end_op>
  return 0;
    800059c4:	4501                	li	a0,0
}
    800059c6:	60ea                	ld	ra,152(sp)
    800059c8:	644a                	ld	s0,144(sp)
    800059ca:	610d                	addi	sp,sp,160
    800059cc:	8082                	ret
    end_op();
    800059ce:	9a7fe0ef          	jal	80004374 <end_op>
    return -1;
    800059d2:	557d                	li	a0,-1
    800059d4:	bfcd                	j	800059c6 <sys_mknod+0x50>

00000000800059d6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059d6:	7135                	addi	sp,sp,-160
    800059d8:	ed06                	sd	ra,152(sp)
    800059da:	e922                	sd	s0,144(sp)
    800059dc:	e14a                	sd	s2,128(sp)
    800059de:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059e0:	f05fb0ef          	jal	800018e4 <myproc>
    800059e4:	892a                	mv	s2,a0

  begin_op();
    800059e6:	909fe0ef          	jal	800042ee <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800059ea:	08000613          	li	a2,128
    800059ee:	f6040593          	addi	a1,s0,-160
    800059f2:	4501                	li	a0,0
    800059f4:	a70fd0ef          	jal	80002c64 <argstr>
    800059f8:	04054363          	bltz	a0,80005a3e <sys_chdir+0x68>
    800059fc:	e526                	sd	s1,136(sp)
    800059fe:	f6040513          	addi	a0,s0,-160
    80005a02:	f18fe0ef          	jal	8000411a <namei>
    80005a06:	84aa                	mv	s1,a0
    80005a08:	c915                	beqz	a0,80005a3c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a0a:	e9dfd0ef          	jal	800038a6 <ilock>
  if (ip->type != T_DIR) {
    80005a0e:	04449703          	lh	a4,68(s1)
    80005a12:	4785                	li	a5,1
    80005a14:	02f71963          	bne	a4,a5,80005a46 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a18:	8526                	mv	a0,s1
    80005a1a:	f3bfd0ef          	jal	80003954 <iunlock>
  iput(p->cwd);
    80005a1e:	15093503          	ld	a0,336(s2)
    80005a22:	806fe0ef          	jal	80003a28 <iput>
  end_op();
    80005a26:	94ffe0ef          	jal	80004374 <end_op>
  p->cwd = ip;
    80005a2a:	14993823          	sd	s1,336(s2)
  return 0;
    80005a2e:	4501                	li	a0,0
    80005a30:	64aa                	ld	s1,136(sp)
}
    80005a32:	60ea                	ld	ra,152(sp)
    80005a34:	644a                	ld	s0,144(sp)
    80005a36:	690a                	ld	s2,128(sp)
    80005a38:	610d                	addi	sp,sp,160
    80005a3a:	8082                	ret
    80005a3c:	64aa                	ld	s1,136(sp)
    end_op();
    80005a3e:	937fe0ef          	jal	80004374 <end_op>
    return -1;
    80005a42:	557d                	li	a0,-1
    80005a44:	b7fd                	j	80005a32 <sys_chdir+0x5c>
    iunlockput(ip);
    80005a46:	8526                	mv	a0,s1
    80005a48:	8b0fe0ef          	jal	80003af8 <iunlockput>
    end_op();
    80005a4c:	929fe0ef          	jal	80004374 <end_op>
    return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	64aa                	ld	s1,136(sp)
    80005a54:	bff9                	j	80005a32 <sys_chdir+0x5c>

0000000080005a56 <sys_exec>:

uint64
sys_exec(void)
{
    80005a56:	7121                	addi	sp,sp,-448
    80005a58:	ff06                	sd	ra,440(sp)
    80005a5a:	fb22                	sd	s0,432(sp)
    80005a5c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a5e:	e4840593          	addi	a1,s0,-440
    80005a62:	4505                	li	a0,1
    80005a64:	9e4fd0ef          	jal	80002c48 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    80005a68:	08000613          	li	a2,128
    80005a6c:	f5040593          	addi	a1,s0,-176
    80005a70:	4501                	li	a0,0
    80005a72:	9f2fd0ef          	jal	80002c64 <argstr>
    80005a76:	87aa                	mv	a5,a0
    return -1;
    80005a78:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005a7a:	0c07c463          	bltz	a5,80005b42 <sys_exec+0xec>
    80005a7e:	f726                	sd	s1,424(sp)
    80005a80:	f34a                	sd	s2,416(sp)
    80005a82:	ef4e                	sd	s3,408(sp)
    80005a84:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005a86:	10000613          	li	a2,256
    80005a8a:	4581                	li	a1,0
    80005a8c:	e5040513          	addi	a0,s0,-432
    80005a90:	a06fb0ef          	jal	80000c96 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    80005a94:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a98:	89a6                	mv	s3,s1
    80005a9a:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    80005a9c:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005aa0:	00391513          	slli	a0,s2,0x3
    80005aa4:	e4040593          	addi	a1,s0,-448
    80005aa8:	e4843783          	ld	a5,-440(s0)
    80005aac:	953e                	add	a0,a0,a5
    80005aae:	8f2fd0ef          	jal	80002ba0 <fetchaddr>
    80005ab2:	02054663          	bltz	a0,80005ade <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    80005ab6:	e4043783          	ld	a5,-448(s0)
    80005aba:	c3a9                	beqz	a5,80005afc <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005abc:	80efb0ef          	jal	80000aca <kalloc>
    80005ac0:	85aa                	mv	a1,a0
    80005ac2:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005ac6:	cd01                	beqz	a0,80005ade <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ac8:	6605                	lui	a2,0x1
    80005aca:	e4043503          	ld	a0,-448(s0)
    80005ace:	91cfd0ef          	jal	80002bea <fetchstr>
    80005ad2:	00054663          	bltz	a0,80005ade <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    80005ad6:	0905                	addi	s2,s2,1
    80005ad8:	09a1                	addi	s3,s3,8
    80005ada:	fd4913e3          	bne	s2,s4,80005aa0 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ade:	f5040913          	addi	s2,s0,-176
    80005ae2:	6088                	ld	a0,0(s1)
    80005ae4:	c931                	beqz	a0,80005b38 <sys_exec+0xe2>
    kfree(argv[i]);
    80005ae6:	f03fa0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aea:	04a1                	addi	s1,s1,8
    80005aec:	ff249be3          	bne	s1,s2,80005ae2 <sys_exec+0x8c>
  return -1;
    80005af0:	557d                	li	a0,-1
    80005af2:	74ba                	ld	s1,424(sp)
    80005af4:	791a                	ld	s2,416(sp)
    80005af6:	69fa                	ld	s3,408(sp)
    80005af8:	6a5a                	ld	s4,400(sp)
    80005afa:	a0a1                	j	80005b42 <sys_exec+0xec>
      argv[i] = 0;
    80005afc:	0009079b          	sext.w	a5,s2
    80005b00:	078e                	slli	a5,a5,0x3
    80005b02:	fd078793          	addi	a5,a5,-48
    80005b06:	97a2                	add	a5,a5,s0
    80005b08:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005b0c:	e5040593          	addi	a1,s0,-432
    80005b10:	f5040513          	addi	a0,s0,-176
    80005b14:	b26ff0ef          	jal	80004e3a <kexec>
    80005b18:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b1a:	f5040993          	addi	s3,s0,-176
    80005b1e:	6088                	ld	a0,0(s1)
    80005b20:	c511                	beqz	a0,80005b2c <sys_exec+0xd6>
    kfree(argv[i]);
    80005b22:	ec7fa0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b26:	04a1                	addi	s1,s1,8
    80005b28:	ff349be3          	bne	s1,s3,80005b1e <sys_exec+0xc8>
  return ret;
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	74ba                	ld	s1,424(sp)
    80005b30:	791a                	ld	s2,416(sp)
    80005b32:	69fa                	ld	s3,408(sp)
    80005b34:	6a5a                	ld	s4,400(sp)
    80005b36:	a031                	j	80005b42 <sys_exec+0xec>
  return -1;
    80005b38:	557d                	li	a0,-1
    80005b3a:	74ba                	ld	s1,424(sp)
    80005b3c:	791a                	ld	s2,416(sp)
    80005b3e:	69fa                	ld	s3,408(sp)
    80005b40:	6a5a                	ld	s4,400(sp)
}
    80005b42:	70fa                	ld	ra,440(sp)
    80005b44:	745a                	ld	s0,432(sp)
    80005b46:	6139                	addi	sp,sp,448
    80005b48:	8082                	ret

0000000080005b4a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b4a:	7139                	addi	sp,sp,-64
    80005b4c:	fc06                	sd	ra,56(sp)
    80005b4e:	f822                	sd	s0,48(sp)
    80005b50:	f426                	sd	s1,40(sp)
    80005b52:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b54:	d91fb0ef          	jal	800018e4 <myproc>
    80005b58:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b5a:	fd840593          	addi	a1,s0,-40
    80005b5e:	4501                	li	a0,0
    80005b60:	8e8fd0ef          	jal	80002c48 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    80005b64:	fc840593          	addi	a1,s0,-56
    80005b68:	fd040513          	addi	a0,s0,-48
    80005b6c:	f9ffe0ef          	jal	80004b0a <pipealloc>
    return -1;
    80005b70:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005b72:	0a054663          	bltz	a0,80005c1e <sys_pipe+0xd4>
  fd0 = -1;
    80005b76:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005b7a:	fd043503          	ld	a0,-48(s0)
    80005b7e:	e82ff0ef          	jal	80005200 <fdalloc>
    80005b82:	fca42223          	sw	a0,-60(s0)
    80005b86:	08054363          	bltz	a0,80005c0c <sys_pipe+0xc2>
    80005b8a:	fc843503          	ld	a0,-56(s0)
    80005b8e:	e72ff0ef          	jal	80005200 <fdalloc>
    80005b92:	fca42023          	sw	a0,-64(s0)
    80005b96:	06054263          	bltz	a0,80005bfa <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005b9a:	4711                	li	a4,4
    80005b9c:	fc440693          	addi	a3,s0,-60
    80005ba0:	fd843603          	ld	a2,-40(s0)
    80005ba4:	64ac                	ld	a1,72(s1)
    80005ba6:	68a8                	ld	a0,80(s1)
    80005ba8:	973fb0ef          	jal	8000151a <copyout>
    80005bac:	00054f63          	bltz	a0,80005bca <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    80005bb0:	4711                	li	a4,4
    80005bb2:	fc040693          	addi	a3,s0,-64
    80005bb6:	fd843603          	ld	a2,-40(s0)
    80005bba:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005bbc:	64ac                	ld	a1,72(s1)
    80005bbe:	68a8                	ld	a0,80(s1)
    80005bc0:	95bfb0ef          	jal	8000151a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bc4:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005bc6:	04055c63          	bgez	a0,80005c1e <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    80005bca:	fc442783          	lw	a5,-60(s0)
    80005bce:	07e9                	addi	a5,a5,26
    80005bd0:	078e                	slli	a5,a5,0x3
    80005bd2:	97a6                	add	a5,a5,s1
    80005bd4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bd8:	fc042783          	lw	a5,-64(s0)
    80005bdc:	07e9                	addi	a5,a5,26
    80005bde:	078e                	slli	a5,a5,0x3
    80005be0:	94be                	add	s1,s1,a5
    80005be2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005be6:	fd043503          	ld	a0,-48(s0)
    80005bea:	bb1fe0ef          	jal	8000479a <fileclose>
    fileclose(wf);
    80005bee:	fc843503          	ld	a0,-56(s0)
    80005bf2:	ba9fe0ef          	jal	8000479a <fileclose>
    return -1;
    80005bf6:	57fd                	li	a5,-1
    80005bf8:	a01d                	j	80005c1e <sys_pipe+0xd4>
    if (fd0 >= 0)
    80005bfa:	fc442783          	lw	a5,-60(s0)
    80005bfe:	0007c763          	bltz	a5,80005c0c <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    80005c02:	07e9                	addi	a5,a5,26
    80005c04:	078e                	slli	a5,a5,0x3
    80005c06:	97a6                	add	a5,a5,s1
    80005c08:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c0c:	fd043503          	ld	a0,-48(s0)
    80005c10:	b8bfe0ef          	jal	8000479a <fileclose>
    fileclose(wf);
    80005c14:	fc843503          	ld	a0,-56(s0)
    80005c18:	b83fe0ef          	jal	8000479a <fileclose>
    return -1;
    80005c1c:	57fd                	li	a5,-1
}
    80005c1e:	853e                	mv	a0,a5
    80005c20:	70e2                	ld	ra,56(sp)
    80005c22:	7442                	ld	s0,48(sp)
    80005c24:	74a2                	ld	s1,40(sp)
    80005c26:	6121                	addi	sp,sp,64
    80005c28:	8082                	ret
    80005c2a:	0000                	unimp
    80005c2c:	0000                	unimp
	...

0000000080005c30 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005c30:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005c32:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005c34:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005c36:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005c38:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005c3a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005c3c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005c3e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005c40:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005c42:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005c44:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005c46:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005c48:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005c4a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005c4c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005c4e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005c50:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005c52:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005c54:	e47fc0ef          	jal	80002a9a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005c58:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005c5a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005c5c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005c5e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005c60:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005c62:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005c64:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005c66:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005c68:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005c6a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005c6c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005c6e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005c70:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005c72:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005c74:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005c76:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005c78:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005c7a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005c7c:	10200073          	sret
	...

0000000080005c8e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c8e:	1141                	addi	sp,sp,-16
    80005c90:	e422                	sd	s0,8(sp)
    80005c92:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005c94:	0c0007b7          	lui	a5,0xc000
    80005c98:	4705                	li	a4,1
    80005c9a:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    80005c9c:	0c0007b7          	lui	a5,0xc000
    80005ca0:	c3d8                	sw	a4,4(a5)
}
    80005ca2:	6422                	ld	s0,8(sp)
    80005ca4:	0141                	addi	sp,sp,16
    80005ca6:	8082                	ret

0000000080005ca8 <plicinithart>:

void
plicinithart(void)
{
    80005ca8:	1141                	addi	sp,sp,-16
    80005caa:	e406                	sd	ra,8(sp)
    80005cac:	e022                	sd	s0,0(sp)
    80005cae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cb0:	c09fb0ef          	jal	800018b8 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cb4:	0085171b          	slliw	a4,a0,0x8
    80005cb8:	0c0027b7          	lui	a5,0xc002
    80005cbc:	97ba                	add	a5,a5,a4
    80005cbe:	40200713          	li	a4,1026
    80005cc2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    80005cc6:	00d5151b          	slliw	a0,a0,0xd
    80005cca:	0c2017b7          	lui	a5,0xc201
    80005cce:	97aa                	add	a5,a5,a0
    80005cd0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cd4:	60a2                	ld	ra,8(sp)
    80005cd6:	6402                	ld	s0,0(sp)
    80005cd8:	0141                	addi	sp,sp,16
    80005cda:	8082                	ret

0000000080005cdc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cdc:	1141                	addi	sp,sp,-16
    80005cde:	e406                	sd	ra,8(sp)
    80005ce0:	e022                	sd	s0,0(sp)
    80005ce2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce4:	bd5fb0ef          	jal	800018b8 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    80005ce8:	00d5151b          	slliw	a0,a0,0xd
    80005cec:	0c2017b7          	lui	a5,0xc201
    80005cf0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005cf2:	43c8                	lw	a0,4(a5)
    80005cf4:	60a2                	ld	ra,8(sp)
    80005cf6:	6402                	ld	s0,0(sp)
    80005cf8:	0141                	addi	sp,sp,16
    80005cfa:	8082                	ret

0000000080005cfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cfc:	1101                	addi	sp,sp,-32
    80005cfe:	ec06                	sd	ra,24(sp)
    80005d00:	e822                	sd	s0,16(sp)
    80005d02:	e426                	sd	s1,8(sp)
    80005d04:	1000                	addi	s0,sp,32
    80005d06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d08:	bb1fb0ef          	jal	800018b8 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    80005d0c:	00d5151b          	slliw	a0,a0,0xd
    80005d10:	0c2017b7          	lui	a5,0xc201
    80005d14:	97aa                	add	a5,a5,a0
    80005d16:	c3c4                	sw	s1,4(a5)
}
    80005d18:	60e2                	ld	ra,24(sp)
    80005d1a:	6442                	ld	s0,16(sp)
    80005d1c:	64a2                	ld	s1,8(sp)
    80005d1e:	6105                	addi	sp,sp,32
    80005d20:	8082                	ret

0000000080005d22 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d22:	1141                	addi	sp,sp,-16
    80005d24:	e406                	sd	ra,8(sp)
    80005d26:	e022                	sd	s0,0(sp)
    80005d28:	0800                	addi	s0,sp,16
  if (i >= NUM)
    80005d2a:	479d                	li	a5,7
    80005d2c:	04a7ca63          	blt	a5,a0,80005d80 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005d30:	0001f797          	auipc	a5,0x1f
    80005d34:	22078793          	addi	a5,a5,544 # 80024f50 <disk>
    80005d38:	97aa                	add	a5,a5,a0
    80005d3a:	0187c783          	lbu	a5,24(a5)
    80005d3e:	e7b9                	bnez	a5,80005d8c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d40:	00451693          	slli	a3,a0,0x4
    80005d44:	0001f797          	auipc	a5,0x1f
    80005d48:	20c78793          	addi	a5,a5,524 # 80024f50 <disk>
    80005d4c:	6398                	ld	a4,0(a5)
    80005d4e:	9736                	add	a4,a4,a3
    80005d50:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d54:	6398                	ld	a4,0(a5)
    80005d56:	9736                	add	a4,a4,a3
    80005d58:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d5c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d60:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d64:	97aa                	add	a5,a5,a0
    80005d66:	4705                	li	a4,1
    80005d68:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d6c:	0001f517          	auipc	a0,0x1f
    80005d70:	1fc50513          	addi	a0,a0,508 # 80024f68 <disk+0x18>
    80005d74:	a78fc0ef          	jal	80001fec <wakeup>
}
    80005d78:	60a2                	ld	ra,8(sp)
    80005d7a:	6402                	ld	s0,0(sp)
    80005d7c:	0141                	addi	sp,sp,16
    80005d7e:	8082                	ret
    panic("free_desc 1");
    80005d80:	00003517          	auipc	a0,0x3
    80005d84:	9e050513          	addi	a0,a0,-1568 # 80008760 <etext+0x760>
    80005d88:	a69fa0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    80005d8c:	00003517          	auipc	a0,0x3
    80005d90:	9e450513          	addi	a0,a0,-1564 # 80008770 <etext+0x770>
    80005d94:	a5dfa0ef          	jal	800007f0 <panic>

0000000080005d98 <virtio_disk_init>:
{
    80005d98:	1101                	addi	sp,sp,-32
    80005d9a:	ec06                	sd	ra,24(sp)
    80005d9c:	e822                	sd	s0,16(sp)
    80005d9e:	e426                	sd	s1,8(sp)
    80005da0:	e04a                	sd	s2,0(sp)
    80005da2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005da4:	00003597          	auipc	a1,0x3
    80005da8:	9dc58593          	addi	a1,a1,-1572 # 80008780 <etext+0x780>
    80005dac:	0001f517          	auipc	a0,0x1f
    80005db0:	2cc50513          	addi	a0,a0,716 # 80025078 <disk+0x128>
    80005db4:	da9fa0ef          	jal	80000b5c <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005db8:	100017b7          	lui	a5,0x10001
    80005dbc:	4398                	lw	a4,0(a5)
    80005dbe:	2701                	sext.w	a4,a4
    80005dc0:	747277b7          	lui	a5,0x74727
    80005dc4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005dc8:	18f71063          	bne	a4,a5,80005f48 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dcc:	100017b7          	lui	a5,0x10001
    80005dd0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005dd2:	439c                	lw	a5,0(a5)
    80005dd4:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dd6:	4709                	li	a4,2
    80005dd8:	16e79863          	bne	a5,a4,80005f48 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ddc:	100017b7          	lui	a5,0x10001
    80005de0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005de2:	439c                	lw	a5,0(a5)
    80005de4:	2781                	sext.w	a5,a5
    80005de6:	16e79163          	bne	a5,a4,80005f48 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80005dea:	100017b7          	lui	a5,0x10001
    80005dee:	47d8                	lw	a4,12(a5)
    80005df0:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005df2:	554d47b7          	lui	a5,0x554d4
    80005df6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dfa:	14f71763          	bne	a4,a5,80005f48 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dfe:	100017b7          	lui	a5,0x10001
    80005e02:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e06:	4705                	li	a4,1
    80005e08:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e0a:	470d                	li	a4,3
    80005e0c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e0e:	10001737          	lui	a4,0x10001
    80005e12:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e14:	c7ffe737          	lui	a4,0xc7ffe
    80005e18:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fd94cf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e1c:	8ef9                	and	a3,a3,a4
    80005e1e:	10001737          	lui	a4,0x10001
    80005e22:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e24:	472d                	li	a4,11
    80005e26:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e28:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005e2c:	439c                	lw	a5,0(a5)
    80005e2e:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e32:	8ba1                	andi	a5,a5,8
    80005e34:	12078063          	beqz	a5,80005f54 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e38:	100017b7          	lui	a5,0x10001
    80005e3c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005e40:	100017b7          	lui	a5,0x10001
    80005e44:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005e48:	439c                	lw	a5,0(a5)
    80005e4a:	2781                	sext.w	a5,a5
    80005e4c:	10079a63          	bnez	a5,80005f60 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e50:	100017b7          	lui	a5,0x10001
    80005e54:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005e58:	439c                	lw	a5,0(a5)
    80005e5a:	2781                	sext.w	a5,a5
  if (max == 0)
    80005e5c:	10078863          	beqz	a5,80005f6c <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005e60:	471d                	li	a4,7
    80005e62:	10f77b63          	bgeu	a4,a5,80005f78 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005e66:	c65fa0ef          	jal	80000aca <kalloc>
    80005e6a:	0001f497          	auipc	s1,0x1f
    80005e6e:	0e648493          	addi	s1,s1,230 # 80024f50 <disk>
    80005e72:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e74:	c57fa0ef          	jal	80000aca <kalloc>
    80005e78:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e7a:	c51fa0ef          	jal	80000aca <kalloc>
    80005e7e:	87aa                	mv	a5,a0
    80005e80:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005e82:	6088                	ld	a0,0(s1)
    80005e84:	10050063          	beqz	a0,80005f84 <virtio_disk_init+0x1ec>
    80005e88:	0001f717          	auipc	a4,0x1f
    80005e8c:	0d073703          	ld	a4,208(a4) # 80024f58 <disk+0x8>
    80005e90:	0e070a63          	beqz	a4,80005f84 <virtio_disk_init+0x1ec>
    80005e94:	0e078863          	beqz	a5,80005f84 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005e98:	6605                	lui	a2,0x1
    80005e9a:	4581                	li	a1,0
    80005e9c:	dfbfa0ef          	jal	80000c96 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ea0:	0001f497          	auipc	s1,0x1f
    80005ea4:	0b048493          	addi	s1,s1,176 # 80024f50 <disk>
    80005ea8:	6605                	lui	a2,0x1
    80005eaa:	4581                	li	a1,0
    80005eac:	6488                	ld	a0,8(s1)
    80005eae:	de9fa0ef          	jal	80000c96 <memset>
  memset(disk.used, 0, PGSIZE);
    80005eb2:	6605                	lui	a2,0x1
    80005eb4:	4581                	li	a1,0
    80005eb6:	6888                	ld	a0,16(s1)
    80005eb8:	ddffa0ef          	jal	80000c96 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ebc:	100017b7          	lui	a5,0x10001
    80005ec0:	4721                	li	a4,8
    80005ec2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ec4:	4098                	lw	a4,0(s1)
    80005ec6:	100017b7          	lui	a5,0x10001
    80005eca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ece:	40d8                	lw	a4,4(s1)
    80005ed0:	100017b7          	lui	a5,0x10001
    80005ed4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005ed8:	649c                	ld	a5,8(s1)
    80005eda:	0007869b          	sext.w	a3,a5
    80005ede:	10001737          	lui	a4,0x10001
    80005ee2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ee6:	9781                	srai	a5,a5,0x20
    80005ee8:	10001737          	lui	a4,0x10001
    80005eec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005ef0:	689c                	ld	a5,16(s1)
    80005ef2:	0007869b          	sext.w	a3,a5
    80005ef6:	10001737          	lui	a4,0x10001
    80005efa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005efe:	9781                	srai	a5,a5,0x20
    80005f00:	10001737          	lui	a4,0x10001
    80005f04:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f08:	10001737          	lui	a4,0x10001
    80005f0c:	4785                	li	a5,1
    80005f0e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005f10:	00f48c23          	sb	a5,24(s1)
    80005f14:	00f48ca3          	sb	a5,25(s1)
    80005f18:	00f48d23          	sb	a5,26(s1)
    80005f1c:	00f48da3          	sb	a5,27(s1)
    80005f20:	00f48e23          	sb	a5,28(s1)
    80005f24:	00f48ea3          	sb	a5,29(s1)
    80005f28:	00f48f23          	sb	a5,30(s1)
    80005f2c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f30:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f34:	100017b7          	lui	a5,0x10001
    80005f38:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005f3c:	60e2                	ld	ra,24(sp)
    80005f3e:	6442                	ld	s0,16(sp)
    80005f40:	64a2                	ld	s1,8(sp)
    80005f42:	6902                	ld	s2,0(sp)
    80005f44:	6105                	addi	sp,sp,32
    80005f46:	8082                	ret
    panic("could not find virtio disk");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	84850513          	addi	a0,a0,-1976 # 80008790 <etext+0x790>
    80005f50:	8a1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	85c50513          	addi	a0,a0,-1956 # 800087b0 <etext+0x7b0>
    80005f5c:	895fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005f60:	00003517          	auipc	a0,0x3
    80005f64:	87050513          	addi	a0,a0,-1936 # 800087d0 <etext+0x7d0>
    80005f68:	889fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    80005f6c:	00003517          	auipc	a0,0x3
    80005f70:	88450513          	addi	a0,a0,-1916 # 800087f0 <etext+0x7f0>
    80005f74:	87dfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005f78:	00003517          	auipc	a0,0x3
    80005f7c:	89850513          	addi	a0,a0,-1896 # 80008810 <etext+0x810>
    80005f80:	871fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005f84:	00003517          	auipc	a0,0x3
    80005f88:	8ac50513          	addi	a0,a0,-1876 # 80008830 <etext+0x830>
    80005f8c:	865fa0ef          	jal	800007f0 <panic>

0000000080005f90 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f90:	7159                	addi	sp,sp,-112
    80005f92:	f486                	sd	ra,104(sp)
    80005f94:	f0a2                	sd	s0,96(sp)
    80005f96:	eca6                	sd	s1,88(sp)
    80005f98:	e8ca                	sd	s2,80(sp)
    80005f9a:	e4ce                	sd	s3,72(sp)
    80005f9c:	e0d2                	sd	s4,64(sp)
    80005f9e:	fc56                	sd	s5,56(sp)
    80005fa0:	f85a                	sd	s6,48(sp)
    80005fa2:	f45e                	sd	s7,40(sp)
    80005fa4:	f062                	sd	s8,32(sp)
    80005fa6:	ec66                	sd	s9,24(sp)
    80005fa8:	1880                	addi	s0,sp,112
    80005faa:	8a2a                	mv	s4,a0
    80005fac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fae:	00c52c83          	lw	s9,12(a0)
    80005fb2:	001c9c9b          	slliw	s9,s9,0x1
    80005fb6:	1c82                	slli	s9,s9,0x20
    80005fb8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fbc:	0001f517          	auipc	a0,0x1f
    80005fc0:	0bc50513          	addi	a0,a0,188 # 80025078 <disk+0x128>
    80005fc4:	c0ffa0ef          	jal	80000bd2 <acquire>
  for (int i = 0; i < 3; i++) {
    80005fc8:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    80005fca:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fcc:	0001fb17          	auipc	s6,0x1f
    80005fd0:	f84b0b13          	addi	s6,s6,-124 # 80024f50 <disk>
  for (int i = 0; i < 3; i++) {
    80005fd4:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005fd6:	0001fc17          	auipc	s8,0x1f
    80005fda:	f92c0c13          	addi	s8,s8,-110 # 80024f68 <disk+0x18>
    80005fde:	a0bd                	j	8000604c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005fe0:	00fb0733          	add	a4,s6,a5
    80005fe4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005fe8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005fea:	0207c563          	bltz	a5,80006014 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    80005fee:	2905                	addiw	s2,s2,1
    80005ff0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ff2:	07590163          	beq	s2,s5,80006054 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005ff6:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005ff8:	0001f717          	auipc	a4,0x1f
    80005ffc:	f5870713          	addi	a4,a4,-168 # 80024f50 <disk>
    80006000:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80006002:	01874683          	lbu	a3,24(a4)
    80006006:	fee9                	bnez	a3,80005fe0 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80006008:	2785                	addiw	a5,a5,1
    8000600a:	0705                	addi	a4,a4,1
    8000600c:	fe979be3          	bne	a5,s1,80006002 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006010:	57fd                	li	a5,-1
    80006012:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80006014:	01205d63          	blez	s2,8000602e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006018:	f9042503          	lw	a0,-112(s0)
    8000601c:	d07ff0ef          	jal	80005d22 <free_desc>
      for (int j = 0; j < i; j++)
    80006020:	4785                	li	a5,1
    80006022:	0127d663          	bge	a5,s2,8000602e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006026:	f9442503          	lw	a0,-108(s0)
    8000602a:	cf9ff0ef          	jal	80005d22 <free_desc>
    sleep_prepare(&disk.free[0]);
    8000602e:	8562                	mv	a0,s8
    80006030:	f51fb0ef          	jal	80001f80 <sleep_prepare>
    release(&disk.vdisk_lock);
    80006034:	0001f917          	auipc	s2,0x1f
    80006038:	04490913          	addi	s2,s2,68 # 80025078 <disk+0x128>
    8000603c:	854a                	mv	a0,s2
    8000603e:	c21fa0ef          	jal	80000c5e <release>
    sleep();
    80006042:	f7bfb0ef          	jal	80001fbc <sleep>
    acquire(&disk.vdisk_lock);
    80006046:	854a                	mv	a0,s2
    80006048:	b8bfa0ef          	jal	80000bd2 <acquire>
  for (int i = 0; i < 3; i++) {
    8000604c:	f9040613          	addi	a2,s0,-112
    80006050:	894e                	mv	s2,s3
    80006052:	b755                	j	80005ff6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006054:	f9042503          	lw	a0,-112(s0)
    80006058:	00451693          	slli	a3,a0,0x4

  if (write)
    8000605c:	0001f797          	auipc	a5,0x1f
    80006060:	ef478793          	addi	a5,a5,-268 # 80024f50 <disk>
    80006064:	00a50713          	addi	a4,a0,10
    80006068:	0712                	slli	a4,a4,0x4
    8000606a:	973e                	add	a4,a4,a5
    8000606c:	01703633          	snez	a2,s7
    80006070:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006072:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006076:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000607a:	6398                	ld	a4,0(a5)
    8000607c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000607e:	0a868613          	addi	a2,a3,168
    80006082:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80006084:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006086:	6390                	ld	a2,0(a5)
    80006088:	00d605b3          	add	a1,a2,a3
    8000608c:	4741                	li	a4,16
    8000608e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006090:	4805                	li	a6,1
    80006092:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006096:	f9442703          	lw	a4,-108(s0)
    8000609a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    8000609e:	0712                	slli	a4,a4,0x4
    800060a0:	963a                	add	a2,a2,a4
    800060a2:	058a0593          	addi	a1,s4,88
    800060a6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800060a8:	0007b883          	ld	a7,0(a5)
    800060ac:	9746                	add	a4,a4,a7
    800060ae:	40000613          	li	a2,1024
    800060b2:	c710                	sw	a2,8(a4)
  if (write)
    800060b4:	001bb613          	seqz	a2,s7
    800060b8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060bc:	00166613          	ori	a2,a2,1
    800060c0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800060c4:	f9842583          	lw	a1,-104(s0)
    800060c8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060cc:	00250613          	addi	a2,a0,2
    800060d0:	0612                	slli	a2,a2,0x4
    800060d2:	963e                	add	a2,a2,a5
    800060d4:	577d                	li	a4,-1
    800060d6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800060da:	0592                	slli	a1,a1,0x4
    800060dc:	98ae                	add	a7,a7,a1
    800060de:	03068713          	addi	a4,a3,48
    800060e2:	973e                	add	a4,a4,a5
    800060e4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800060e8:	6398                	ld	a4,0(a5)
    800060ea:	972e                	add	a4,a4,a1
    800060ec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060f0:	4689                	li	a3,2
    800060f2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800060f6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060fa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800060fe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006102:	6794                	ld	a3,8(a5)
    80006104:	0026d703          	lhu	a4,2(a3)
    80006108:	8b1d                	andi	a4,a4,7
    8000610a:	0706                	slli	a4,a4,0x1
    8000610c:	96ba                	add	a3,a3,a4
    8000610e:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80006112:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006116:	6798                	ld	a4,8(a5)
    80006118:	00275783          	lhu	a5,2(a4)
    8000611c:	2785                	addiw	a5,a5,1
    8000611e:	00f71123          	sh	a5,2(a4)
    80006122:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006126:	100017b7          	lui	a5,0x10001
    8000612a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    8000612e:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80006132:	0001f497          	auipc	s1,0x1f
    80006136:	f4648493          	addi	s1,s1,-186 # 80025078 <disk+0x128>
  while (b->disk == 1) {
    8000613a:	4905                	li	s2,1
    8000613c:	03079163          	bne	a5,a6,8000615e <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80006140:	8552                	mv	a0,s4
    80006142:	e3ffb0ef          	jal	80001f80 <sleep_prepare>
    release(&disk.vdisk_lock);
    80006146:	8526                	mv	a0,s1
    80006148:	b17fa0ef          	jal	80000c5e <release>
    sleep();
    8000614c:	e71fb0ef          	jal	80001fbc <sleep>
    acquire(&disk.vdisk_lock);
    80006150:	8526                	mv	a0,s1
    80006152:	a81fa0ef          	jal	80000bd2 <acquire>
  while (b->disk == 1) {
    80006156:	004a2783          	lw	a5,4(s4)
    8000615a:	ff2783e3          	beq	a5,s2,80006140 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000615e:	f9042903          	lw	s2,-112(s0)
    80006162:	00290713          	addi	a4,s2,2
    80006166:	0712                	slli	a4,a4,0x4
    80006168:	0001f797          	auipc	a5,0x1f
    8000616c:	de878793          	addi	a5,a5,-536 # 80024f50 <disk>
    80006170:	97ba                	add	a5,a5,a4
    80006172:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006176:	0001f997          	auipc	s3,0x1f
    8000617a:	dda98993          	addi	s3,s3,-550 # 80024f50 <disk>
    8000617e:	00491713          	slli	a4,s2,0x4
    80006182:	0009b783          	ld	a5,0(s3)
    80006186:	97ba                	add	a5,a5,a4
    80006188:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000618c:	854a                	mv	a0,s2
    8000618e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006192:	b91ff0ef          	jal	80005d22 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80006196:	8885                	andi	s1,s1,1
    80006198:	f0fd                	bnez	s1,8000617e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000619a:	0001f517          	auipc	a0,0x1f
    8000619e:	ede50513          	addi	a0,a0,-290 # 80025078 <disk+0x128>
    800061a2:	abdfa0ef          	jal	80000c5e <release>
}
    800061a6:	70a6                	ld	ra,104(sp)
    800061a8:	7406                	ld	s0,96(sp)
    800061aa:	64e6                	ld	s1,88(sp)
    800061ac:	6946                	ld	s2,80(sp)
    800061ae:	69a6                	ld	s3,72(sp)
    800061b0:	6a06                	ld	s4,64(sp)
    800061b2:	7ae2                	ld	s5,56(sp)
    800061b4:	7b42                	ld	s6,48(sp)
    800061b6:	7ba2                	ld	s7,40(sp)
    800061b8:	7c02                	ld	s8,32(sp)
    800061ba:	6ce2                	ld	s9,24(sp)
    800061bc:	6165                	addi	sp,sp,112
    800061be:	8082                	ret

00000000800061c0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061c0:	1101                	addi	sp,sp,-32
    800061c2:	ec06                	sd	ra,24(sp)
    800061c4:	e822                	sd	s0,16(sp)
    800061c6:	e426                	sd	s1,8(sp)
    800061c8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061ca:	0001f497          	auipc	s1,0x1f
    800061ce:	d8648493          	addi	s1,s1,-634 # 80024f50 <disk>
    800061d2:	0001f517          	auipc	a0,0x1f
    800061d6:	ea650513          	addi	a0,a0,-346 # 80025078 <disk+0x128>
    800061da:	9f9fa0ef          	jal	80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061de:	100017b7          	lui	a5,0x10001
    800061e2:	53b8                	lw	a4,96(a5)
    800061e4:	8b0d                	andi	a4,a4,3
    800061e6:	100017b7          	lui	a5,0x10001
    800061ea:	d3f8                	sw	a4,100(a5)
    800061ec:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    800061f0:	689c                	ld	a5,16(s1)
    800061f2:	0204d703          	lhu	a4,32(s1)
    800061f6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800061fa:	04f70663          	beq	a4,a5,80006246 <virtio_disk_intr+0x86>
    800061fe:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006202:	6898                	ld	a4,16(s1)
    80006204:	0204d783          	lhu	a5,32(s1)
    80006208:	8b9d                	andi	a5,a5,7
    8000620a:	078e                	slli	a5,a5,0x3
    8000620c:	97ba                	add	a5,a5,a4
    8000620e:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80006210:	00278713          	addi	a4,a5,2
    80006214:	0712                	slli	a4,a4,0x4
    80006216:	9726                	add	a4,a4,s1
    80006218:	01074703          	lbu	a4,16(a4)
    8000621c:	e321                	bnez	a4,8000625c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000621e:	0789                	addi	a5,a5,2
    80006220:	0792                	slli	a5,a5,0x4
    80006222:	97a6                	add	a5,a5,s1
    80006224:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80006226:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000622a:	dc3fb0ef          	jal	80001fec <wakeup>

    disk.used_idx += 1;
    8000622e:	0204d783          	lhu	a5,32(s1)
    80006232:	2785                	addiw	a5,a5,1
    80006234:	17c2                	slli	a5,a5,0x30
    80006236:	93c1                	srli	a5,a5,0x30
    80006238:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    8000623c:	6898                	ld	a4,16(s1)
    8000623e:	00275703          	lhu	a4,2(a4)
    80006242:	faf71ee3          	bne	a4,a5,800061fe <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006246:	0001f517          	auipc	a0,0x1f
    8000624a:	e3250513          	addi	a0,a0,-462 # 80025078 <disk+0x128>
    8000624e:	a11fa0ef          	jal	80000c5e <release>
}
    80006252:	60e2                	ld	ra,24(sp)
    80006254:	6442                	ld	s0,16(sp)
    80006256:	64a2                	ld	s1,8(sp)
    80006258:	6105                	addi	sp,sp,32
    8000625a:	8082                	ret
      panic("virtio_disk_intr status");
    8000625c:	00002517          	auipc	a0,0x2
    80006260:	5ec50513          	addi	a0,a0,1516 # 80008848 <etext+0x848>
    80006264:	d8cfa0ef          	jal	800007f0 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	0000100f          	fence.i
    800070a0:	12000073          	sfence.vma
    800070a4:	18051073          	csrw	satp,a0
    800070a8:	12000073          	sfence.vma
    800070ac:	02000537          	lui	a0,0x2000
    800070b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070b2:	0536                	slli	a0,a0,0xd
    800070b4:	02853083          	ld	ra,40(a0)
    800070b8:	03053103          	ld	sp,48(a0)
    800070bc:	03853183          	ld	gp,56(a0)
    800070c0:	04053203          	ld	tp,64(a0)
    800070c4:	04853283          	ld	t0,72(a0)
    800070c8:	05053303          	ld	t1,80(a0)
    800070cc:	05853383          	ld	t2,88(a0)
    800070d0:	7120                	ld	s0,96(a0)
    800070d2:	7524                	ld	s1,104(a0)
    800070d4:	7d2c                	ld	a1,120(a0)
    800070d6:	6150                	ld	a2,128(a0)
    800070d8:	6554                	ld	a3,136(a0)
    800070da:	6958                	ld	a4,144(a0)
    800070dc:	6d5c                	ld	a5,152(a0)
    800070de:	0a053803          	ld	a6,160(a0)
    800070e2:	0a853883          	ld	a7,168(a0)
    800070e6:	0b053903          	ld	s2,176(a0)
    800070ea:	0b853983          	ld	s3,184(a0)
    800070ee:	0c053a03          	ld	s4,192(a0)
    800070f2:	0c853a83          	ld	s5,200(a0)
    800070f6:	0d053b03          	ld	s6,208(a0)
    800070fa:	0d853b83          	ld	s7,216(a0)
    800070fe:	0e053c03          	ld	s8,224(a0)
    80007102:	0e853c83          	ld	s9,232(a0)
    80007106:	0f053d03          	ld	s10,240(a0)
    8000710a:	0f853d83          	ld	s11,248(a0)
    8000710e:	10053e03          	ld	t3,256(a0)
    80007112:	10853e83          	ld	t4,264(a0)
    80007116:	11053f03          	ld	t5,272(a0)
    8000711a:	11853f83          	ld	t6,280(a0)
    8000711e:	7928                	ld	a0,112(a0)
    80007120:	10200073          	sret
	...
