all:
	sdcc -mz80 -c flasher.c
	# Startup code has space for a vector table at 0x0000 and then
	# the init code proper at 0x0100.  We need to go somewhere
	# above this.  We should probably do our own startup
	sdcc -mz80 --code-loc 0x0200 --data-loc 0x8000 flasher.o


	packihx <flasher.ihx >flasher.hex
	z80-unknown-coff-objcopy -I ihex -O binary flasher.hex flasher.bin
	z80dasm -g 0 -a -l -t flasher.bin > flasher.z80

clean:
	rm *.asm *.ihx *.lnk *.lst *.map *.o *.sym *.bin *.z80


