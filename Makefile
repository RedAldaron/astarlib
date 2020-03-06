PORT=/dev/ttyACM0

MCU=atmega32u4
CFLAGS=-g -Wall -mcall-prologues -mmcu=$(MCU) -Os
LDFLAGS=-Wl,-gc-sections -Wl,-relax
CC=avr-gcc
TARGET=out/main.hex
TARGET_WCET=out/wcet.hex
OBJECT_FILES=src/buttons.o src/leds.o src/main.o src/timer.o src/gpio.o\
 src/scheduler.o src/motor.o src/encoder.o src/adc.o

ifndef VIRTUAL_SERIAL_PATH
 $(error VIRTUAL_SERIAL_PATH must be set to use usb virtual serial)
else
 CFLAGS+=-I$(VIRTUAL_SERIAL_PATH) -DVIRTUAL_SERIAL
 LDFLAGS+=-L$(VIRTUAL_SERIAL_PATH) -lVirtualSerial
endif

all: $(TARGET)

clean:
	rm -f *.o *.hex *.obj *.hex

%.hex: %.obj
	avr-objcopy -R .eeprom -O ihex $< $@

%.obj: $(OBJECT_FILES)
	$(CC) $(CFLAGS) $(OBJECT_FILES) $(LDFLAGS) -o $@

program: $(TARGET)
	avrdude -p $(MCU) -c avr109 -P $(PORT) -U flash:w:$(TARGET)

screen:
	screen /dev/ttyACM0 -f 9600 -h

wcet:
	$(CC) $(CFLAGS) bench/wcet.c $(LDFLAGS) -o $(TARGET_WCET)

wcet_program: wcet
	avrdude -p $(MCU) -c avr109 -P $(PORT) -U flash:w:$(TARGET_WCET)

