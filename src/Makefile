TARGET=zxloader
CPU=z80

# Leave space for SDCC's standard C startup - we should probably
# write our own
ROM_BASE=0x0200
# Memory below here and above 0x4000 is video RAM
RAM_BASE=0x5b00

# Size to pack binary image to
ROM_SIZE=0x4000

CC=sdcc
CFLAGS=-m$(CPU) -DDEBUG=3
LDFLAGS=-m$(CPU) --code-loc $(ROM_BASE) --data-loc $(RAM_BASE)

# Must be listed first
OBJS=$(TARGET).o console.o
# Other objects in any order
#OBJS+=

all: $(TARGET).hex

$(TARGET).hex: $(OBJS)
	$(CC) $(LDFLAGS) $^
	packihx <$(TARGET).ihx >$(TARGET).hex
	z80-unknown-coff-objcopy -I ihex -O binary --pad-to=$(ROM_SIZE) $(TARGET).hex $(TARGET).bin
	z80dasm -g 0 -a -l -t $(TARGET).bin > $(TARGET).z80
	
%.o: %.c
	$(CC) -c $(CFLAGS) $<


clean:
	rm *.asm *.ihx *.lnk *.lst *.map *.o *.sym *.bin *.z80

