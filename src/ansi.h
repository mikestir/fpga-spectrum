/*!
 * \file ansi.h
 * \brief ANSI escape sequences
 * 
 * Various escape sequences for use with serial terminals.
 * Allows enhanced formatting of text including the use of
 * positioning and colour.
 * 
 * \author	(C) 2007 Mike Stirling 
 * 			($Author: mike $)
 * \version	$Revision: 24 $
 * \date	$Date$
 */

#ifndef ANSI_H_
#define ANSI_H_

//! Move the cursor up one row
#define CURSOR_UP		"\033[A"
//! Move the cursor up n rows
#define CURSOR_UPn		"\033[%dA"
//! Move the cursor down one row
#define CURSOR_DOWN		"\033[B"
//! Move the cursor down n rows
#define CURSOR_DOWNn	"\033[%dB"
//! Move the cursor forward one column
#define CURSOR_RIGHT	"\033[C"
//! Move the cursor forward n column
#define CURSOR_RIGHTn	"\033[%dC"
//! Move the cursor back one column
#define CURSOR_LEFT		"\033[D"
//! Move the cursor back n columns
#define CURSOR_LEFTn	"\033[%dD"

//! Move the cursor to the start of the next row
#define CURSOR_NL		"\033[E"
//! Move the cursor to the start of the previous row
#define CURSOR_PL		"\033[F"

//! Move the cursor to the specified column (1 based)
#define CURSOR_COL		"\033[%dG"
//! Move the cursor to the specified row,column (1 based)
#define CURSOR_MOVE		"\033[%d;%dH"

//! Save the current cursor position
#define CURSOR_SAVE		"\033[s"
//! Move the cursor to the last saved position
#define CURSOR_RESTORE	"\033[u"

//! Clear from the cursor to the end of the screen
#define CLEAR_AFTER		"\033[0J"
//! Clear from the cursor to the start of the screen
#define CLEAR_BEFORE	"\033[1J"
//! Clear the entire screen
#define CLEAR_SCREEN	"\033[2J"

//! Clear from the cursor to the end of the line
#define CLEAR_EOL		"\033[0K"
//! Clear from the cursor to the start of the line
#define CLEAR_SOL		"\033[1K"
//! Clear the current line
#define CLEAR_LINE		"\033[2K"

//! Scroll the page up one line, adding a blank line at the bottom
#define SCROLL_UP		"\033[S"
//! Scroll the page up n lines, adding blanks at the bottom
#define SCROLL_UPn		"\033[%dS"
//! Scroll the page down one line, adding a blank line at the top
#define SCROLL_DOWN		"\033[T"
//! Scroll the page down n lines, adding blanks at the bottom
#define SCROLL_DOWNn	"\033[%dT"

//! Reset all attributes to defaults
#define ATTR_RESET		"\033[0m"
//! Select normal character weight
#define ATTR_NORMAL		"\033[22m"
//! Select bright text (sometimes rendered as bold)
#define ATTR_BRIGHT		"\033[1m"
//! Select dim text (not necessarily supported)
#define ATTR_DIM		"\033[2m"
//! Select italic text
#define ATTR_ITALIC		"\033[3m"
//! Select underlining
#define ATTR_UNDERLINE	"\033[4m"
//! Enable slow blink
#define ATTR_BLINK		"\033[5m"
//! Enable fast blink
#define ATTR_FASTBLINK	"\033[6m"
//! Cancel blinking
#define ATTR_STEADY		"\033[25m"
//! Select inverse polarity text
#define ATTR_INVERSE	"\033[7m"
//! Select normal polarity text
#define ATTR_POSITIVE	"\033[27m"

//! Set foreground colour: black
#define FG_BLACK		"\033[30m"
//! Set foreground colour: red
#define FG_RED			"\033[31m"
//! Set foreground colour: green
#define FG_GREEN		"\033[32m"
//! Set foreground colour: yellow
#define FG_YELLOW		"\033[33m"
//! Set foreground colour: blue
#define FG_BLUE			"\033[34m"
//! Set foreground colour: magenta
#define FG_MAGENTA		"\033[35m"
//! Set foreground colour: cyan
#define FG_CYAN			"\033[36m"
//! Set foreground colour: white
#define FG_WHITE		"\033[37m"
//! Set foreground colour: reset to default
#define FG_RESET		"\033[39m"

//! Set background colour: black
#define BG_BLACK		"\033[40m"
//! Set background colour: red
#define BG_RED			"\033[41m"
//! Set background colour: green
#define BG_GREEN		"\033[42m"
//! Set background colour: yellow
#define BG_YELLOW		"\033[43m"
//! Set background colour: blue
#define BG_BLUE			"\033[44m"
//! Set background colour: magenta
#define BG_MAGENTA		"\033[45m"
//! Set background colour: cyan
#define BG_CYAN			"\033[46m"
//! Set background colour: white
#define BG_WHITE		"\033[47m"
//! Set background colour: reset to default
#define BG_RESET		"\033[49m"

#endif /*ANSI_H_*/
