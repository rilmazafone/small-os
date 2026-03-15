# Detect all C files
C_SOURCES := $(wildcard kernel/*.c drivers/*.c cpu/*.c)
HEADERS := $(wildcard kernel/*.h drivers/*.h cpu/*.h)

# Replace .c with .o
OBJ := $(C_SOURCES:.c=.o) cpu/interrupt.o

# Cross compiler tools
CC := i386-elf-gcc
LD := i386-elf-ld
GDB := i386-elf-gdb

# Compiler flags
CFLAGS := -g -ffreestanding -Wall -Wextra -m32

# Default target
all: os-image.bin

# Build OS image
os-image.bin: boot/bootsect.bin kernel.bin
	cat $^ > os-image.bin

# Link kernel
kernel.bin: boot/kernel_entry.o $(OBJ)
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

# Kernel ELF (for debugging)
kernel.elf: boot/kernel_entry.o $(OBJ)
	$(LD) -o $@ -Ttext 0x1000 $^

# Run in QEMU
run: os-image.bin
	qemu-system-i386 -fda os-image.bin

# Debug with GDB
debug: os-image.bin kernel.elf
	qemu-system-i386 -s -S -fda os-image.bin &
	$(GDB) -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

# Compile C files
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble ELF object files
%.o: %.asm
	nasm $< -f elf -o $@

# Assemble raw binary (boot sector)
%.bin: %.asm
	nasm $< -f bin -o $@

# Clean build files
clean:
	rm -rf *.bin *.elf *.o os-image.bin
	rm -rf kernel/*.o drivers/*.o cpu/*.o boot/*.o boot/*.bin