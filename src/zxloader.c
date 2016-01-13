/*
 * main.c
 *
 *  Created on: 3 Apr 2010
 *      Author: mike
 */

#include <stdio.h>
#include <string.h>

#include "common.h"
#include "spectrum.h"
#include "ansi.h"
#include "console.h"

int main(void)
{
	int n = 0;
	volatile int m;

	console_cls();

	BORDER(WHITE);
	printf(ATTR_RESET BG_BLUE FG_YELLOW
			"                             \n"
			"  ZX Spectrum for Altera DE1 \n"
			"    (C) 2010 Mike Stirling   \n"
			"                             \n" ATTR_RESET "\n");


	TRACE("Entering main loop\n");

	while(1) {
		INFO("%d\n", n++);
		for (m = 0; m < 255; m++);
	}
	return 0;
}
