/*
 * console.h
 *
 *  Created on: 3 Apr 2010
 *      Author: mike
 */

#ifndef CONSOLE_H_
#define CONSOLE_H_

// Width of the console in characters
#define CONSOLE_WIDTH	32
// Height of the console in characters
#define CONSOLE_HEIGHT	24

// Determine first byte of the screen data for the
// specified character coordinates
#define CHAR_ADDR(x,y)	(&pSCREEN[2048 * (y >> 3) + 32 * (y & 7) + x])
// Determine attribute address for specified character coordinates
#define ATTR_ADDR(x,y)	(&pATTR[32 * y + x])

void console_cls(void);

#endif /* CONSOLE_H_ */
