/*
 * console.c
 *
 *  Created on: 3 Apr 2010
 *      Author: mike
 */

#include <stdio.h>
#include <string.h>

#include "spectrum.h"
#include "console.h"

// Current cursor position relative to top-left
static int xpos;
static int ypos;
// Current text drawing attributes
static unsigned char attr;
// Whether or not the cursor is being shown
static int cursor;
// Whether or not an escape sequence is in progress
static int escape;

#include "font_pearl_8x8.c"

static void console_handle_attribute(int code)
{
	// Handle attribute changes
	switch (code) {
	case 0:
		// Reset
		attr = PAPER(WHITE) | INK(BLACK);
		break;
	case 1:
		// Bright
		attr |= BRIGHT;
		break;
	case 2:
		// Dim
		attr &= ~BRIGHT;
		break;
	case 5:
		// Flash
		attr |= FLASH;
		break;
	case 25:
		// Steady
		attr &= ~FLASH;
		break;

	case 30:
	case 39:
		// FG Black
		attr &= ~INK(WHITE);
		attr |= INK(BLACK);
		break;
	case 31:
		// FG Red
		attr &= ~INK(WHITE);
		attr |= INK(RED);
		break;
	case 32:
		// FG Green
		attr &= ~INK(WHITE);
		attr |= INK(GREEN);
		break;
	case 33:
		// FG Yellow
		attr &= ~INK(WHITE);
		attr |= INK(YELLOW);
		break;
	case 34:
		// FG Blue
		attr &= ~INK(WHITE);
		attr |= INK(BLUE);
		break;
	case 35:
		// FG Magenta
		attr &= ~INK(WHITE);
		attr |= INK(MAGENTA);
		break;
	case 36:
		// FG Cyan
		attr &= ~INK(WHITE);
		attr |= INK(CYAN);
		break;
	case 37:
		// FG White
		attr &= ~INK(WHITE);
		attr |= INK(WHITE);
		break;

	case 40:
	case 49:
		// BG Black
		attr &= ~PAPER(WHITE);
		attr |= PAPER(BLACK);
		break;
	case 41:
		// BG Red
		attr &= ~PAPER(WHITE);
		attr |= PAPER(RED);
		break;
	case 42:
		// BG Green
		attr &= ~PAPER(WHITE);
		attr |= PAPER(GREEN);
		break;
	case 43:
		// BG Yellow
		attr &= ~PAPER(WHITE);
		attr |= PAPER(YELLOW);
		break;
	case 44:
		// BG Blue
		attr &= ~PAPER(WHITE);
		attr |= PAPER(BLUE);
		break;
	case 45:
		// BG Magenta
		attr &= ~PAPER(WHITE);
		attr |= PAPER(MAGENTA);
		break;
	case 46:
		// BG Cyan
		attr &= ~PAPER(WHITE);
		attr |= PAPER(CYAN);
		break;
	case 47:
		// BG White
		attr &= ~PAPER(WHITE);
		attr |= PAPER(WHITE);
		break;
	}
}

static void console_handle_escape(char c)
{
	static int code;

	switch (escape) {
	case 1:
		// Sequence must start ESC-[
		if (c != '[')
			escape = 0;
		else {
			escape++;
			code = 0;
		}
		break;
	case 2:
		// Attribute sequences are an integer followed by 'm'
		if (c == 'm') {
			console_handle_attribute(code);
			escape = 0;
		} else if ((c >= '0') && (c <= '9')) {
			// Convert integer string to numerical value
			code *= 10;
			code += (int)c - '0';
		} else
			// Invalid command sequence
			escape = 0;
	}
}

static void console_render_char(char c,int x,int y)
{
	const unsigned char *fontptr = &fontdata_pearl8x8[c << 3];
	unsigned char *scrptr = CHAR_ADDR(x,y);
	int n;

	for (n = 0; n < 8; n++) {
		*scrptr = *fontptr++;
		// Next row is 256 bytes away because of the way the screen is scanned
		scrptr += 256;
	}
}

// Call to clear the screen and set the cursor back
// to the home position.  Attributes are cleared to their default
// values and the cursor is enabled.
void console_cls(void)
{
	// Clear screen to paper and set attributes to
	// white on black
	memset(pSCREEN,0,sizeofSCREEN);
	memset(pATTR,PAPER(WHITE) | INK(BLACK),sizeofATTR);

	// Defaults
	xpos = ypos = 0;
	attr = PAPER(WHITE) | INK(BLACK);
	cursor = 1;
	escape = 0;

	// Display cursor at location 0,0
	*ATTR_ADDR(0,0) = attr | FLASH;
}

// Define stdio putchar function.  We can use printf now
void putchar(char c)
{
	if (escape) {
		// Route escape codes to the handler - do not display
		console_handle_escape(c);
		return;
	}

	// Clear the cursor at the current location in case we move
	*ATTR_ADDR(xpos,ypos) = attr;

	switch (c) {
	// Handle special characters
	case '\n':
		// Newline
		ypos++;
		// fall through
	case '\r':
		// Carriage return
		xpos = 0;
		break;
	case '\033':
		// Enter escape handler
		escape = 1;
		break;
	default:
		// Assume remaining characters are printable
		console_render_char(c,xpos++,ypos);
	}

	// Handle cursor movement
	if (xpos == CONSOLE_WIDTH) {
		xpos = 0;
		ypos++;
	}
	if (ypos == CONSOLE_HEIGHT) {
		// Scroll display
		memcpy(pSCREEN,pSCREEN + CONSOLE_WIDTH * 8,sizeofSCREEN - CONSOLE_WIDTH * 8);
		memcpy(pATTR,pATTR + CONSOLE_WIDTH,sizeofATTR - CONSOLE_WIDTH);
		ypos--; // Stay on bottom row
	}

	// Display cursor if enabled
	if (cursor)
		*ATTR_ADDR(xpos,ypos) = attr | FLASH;
}
