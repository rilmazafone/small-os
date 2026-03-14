# ================================
# Project sources
# ================================
C_SOURCES := $(wildcard kernel/*.c drivers/*.c)
HEADERS   := $(wildcard kernel/*.h drivers/*.h)
OBJ       := $(C_SOURCES:.c=.o) boot/kernel_entry.o

# ================================
# Tools (auto-detect if possible)
# ================================
CC := $(shell which i386-elf-gcc || echo /usr/local/i386elfgcc/bin/i386-elf-gcc)
LD := $(shell which i386-elf-ld || echo /usr/local/i386elfgcc/bin/i386-elf-ld)
GDB := $(shell which i386-elf-gdb || echo /usr/local/i386elfgcc/bin/i386-elf-gdb)
NASM := $(shell which nasm)

# Compiler flags
CFLAGS := -g -ffreestanding -O2 -Wall

# ================================
# Build rules
# ================================

# Default target
all: os-image.bin

# Combine boot sector + kernel
os-image.bin: boot/bootsect.bin kernel.bin
	cat $^ > $@

# Link kernel into a flat binary
kernel.bin: $(OBJ)
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

# Link kernel with symbols for debugging
kernel.elf: $(OBJ)
	$(LD) -o $@ -Ttext 0x1000 $^

# ================================
# Run & debug
# ================================
run: os-image.bin
	qemu-system-i386 -fda $<

debug: os-image.bin kernel.elf
	qemu-system-i386 -s -fda os-image.bin &
	$(GDB) -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

# ================================
# Compile C and assembly
# ================================
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

boot/%.o: boot/%.asm
	$(NASM) $< -f elf -o $@

boot/%.bin: boot/%.asm
	$(NASM) $< -f bin -o $@

# ================================
# Clean build artifacts
# ================================
clean:
	rm -rf *.bin *.elf *.dis $(OBJ) boot/*.bin boot/*.o kernel/*.o drivers/*.o
