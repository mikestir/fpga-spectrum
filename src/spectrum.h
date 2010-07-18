/*
 * spectrum.h
 *
 *  Created on: 3 Apr 2010
 *      Author: mike
 */

#ifndef SPECTRUM_H_
#define SPECTRUM_H_

/*
 * ULA output
 *
 * D7 -
 * D6 -
 * D5 -
 * D4 - EAR (high-level output)
 * D3 - MIC (low-level output)
 * D2 - BORDER GREEN
 * D1 - BORDER RED
 * D0 - BORDER BLUE
 *
 * ULA input
 *
 * D7 -
 * D6 - EAR input
 * D5 -
 * D4-D0 Keyboard
 */
__sfr __at(0xfffe)	ULA_REG;

/*
 * ULA keyboard registers
 */

// D4, D3, D2, D1,        D0
// B,  N,  M,  SYM SHIFT, SPACE
__sfr __at(0x7ffe)	ULA_KEYB1;

// D4, D3, D2, D1, D0
// H,  J,  K,  L,  ENTER
__sfr __at(0xbffe)	ULA_KEYB2;

// D4, D3, D2, D1, D0
// Y,  U,  I,  O,  P
__sfr __at(0xdffe)	ULA_KEYB3;

// D4, D3, D2, D1, D0
// 6,  7,  8,  9,  0
__sfr __at(0xeffe)	ULA_KEYB4;

// D4, D3, D2, D1, D0
// 5,  4,  3,  2,  1
__sfr __at(0xf7fe)	ULA_KEYB5;

// D4, D3, D2, D1, D0
// T,  R,  E,  W,  Q
__sfr __at(0xfbfe)	ULA_KEYB6;

// D4, D3, D2, D1, D0
// G,  F,  D,  S,  A
__sfr __at(0xfdfe)	ULA_KEYB7;

// D4, D3, D2, D1, D0
// V,  C,  X,  Z,  CAPS SHIFT
__sfr __at(0xfefe)	ULA_KEYB8;

/* Various macros */

#define BLACK		0
#define BLUE		1
#define RED			2
#define MAGENTA		3
#define GREEN		4
#define CYAN		5
#define YELLOW		6
#define WHITE		7

// The following macro generates code that changes the
// border colour to the specified value immediately
#define BORDER(a)	(ULA_REG = (a & 7))
// The following macros generate byte values that may be
// ORed together and applied to the attribute area to
// change the attributes of an 8x8 square
#define INK(a)		(a & 7)
#define PAPER(a)	((a & 7) << 3)
#define BRIGHT		(1 << 6)
#define FLASH		(1 << 7)

// Screen area
static volatile unsigned char *pSCREEN = (unsigned char*)0x4000;
#define sizeofSCREEN	(6144)
// Attribute area
static volatile unsigned char *pATTR = (unsigned char*)0x5800;
#define sizeofATTR		(768)

#endif /* SPECTRUM_H_ */
