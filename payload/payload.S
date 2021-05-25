// To compile:
// arm-none-eabi-as payload.S -march=armv7e-m -o payload.elf
// arm-none-eabi-objcopy -O binary payload.elf payload.bin

.syntax unified

.section .text
.global _start

_start:
.code 16


foo:
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;
	nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;

// __disable_interrupt();
CPSID    I

// LTDC_Layer1->CR = 0; // disable layer
// LTDC_Layer1->DCCR = 0xFF0000FF; // blue
LDR      R0, =0x50001084
MOVS     R1, #0
STR      R1, [R0, #0x00]
LDR      R1, =0xFF0000FF
STR      R1, [R0, #0x18]

// LTDC_Layer2->CR = 0; // disable layer
LDR      R0, =0x50001104
MOVS     R1, #0
STR      R1, [R0, #0x00]

// LTDC->SRCR = 1; // reload shadow registers now
// LTDC->BCCR = 0x000000; // black
LDR      R0, =0x50001000
MOVS     R1, #1
STR      R1, [R0, #0x24]
MOVS     R1, #0
STR      R1, [R0, #0x2C]

// DAC1->DHR12R1 = 0xAD2;
// DAC1->DHR12R2 = 0xAD2;
// DAC2->DHR12R1 = 0xAD2;
LDR      R0, =0x40007400
MOV      R1, #0xAD2
STR      R1, [R0, #0x08]
STR      R1, [R0, #0x14]
LDR      R0, =0x58003400
STR      R1, [R0, #0x08]

// uint32_t *src = (uint32_t*)0x08000000;
// uint32_t *dst = (uint32_t*)0x24000000;
// for (int len = 0; len < 0x20000 / 4; len++)
// {
// 	*dst++ = *src++;
// }
MOV      R0, #0x08000000
MOV      R1, #0x24000000
MOV      R2, #0x8000
loop1:
LDR      R3, [R0], #4
STR      R3, [R1], #4
SUBS     R2, R2, #1
BNE      loop1

// while (1)
// {
//   WWDG1->CR = 0x69;
// }
LDR      R0, =0x50003000
MOVS     R1, #0x69
loop2:
STR      R1, [R0, #0x00]
B        loop2
