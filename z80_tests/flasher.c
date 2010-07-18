__sfr __at (0x00) leds;

void delay(void);

int main(void)
{
	unsigned char n = 1;

#if 0
	__asm
	ld	a,#0x55
	ld	(0x8000),a
	ld	a,(0x8000)
	ld	(0x8001),a
	__endasm;	
#endif

	while (1) {
		leds = n;
		if (n == 128)
			n=1;
		else
			n<<=1;
		delay();
	}
}

void delay(void)
{
	unsigned int n = 0;

	/* This becomes
	nop	(4)
        inc     bc (6)
        ld      a,c (4)
        or      a,b (4)
        jr      NZ,00101$ (12)
	
	Which should take (4+6+4+4+12)*65536 / 28 MHz
	(about 70 ms)
	*/

	do {
		__asm
		nop
		__endasm;
	} while(++n);
}

