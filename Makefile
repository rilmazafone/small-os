# Makefile for assembling and running boot.asm

# Variables
ASM = nasm
ASMFLAGS = -f bin
BOOTFILE = boot.bin
SRC = boot.asm
QEMU = qemu-system-x86_64

# Default target
all: run

# Assemble boot.asm into boot.bin
$(BOOTFILE): $(SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

# Run boot.bin in QEMU
run: $(BOOTFILE)
	$(QEMU) $(BOOTFILE)

# Clean generated files
clean:
	rm -f $(BOOTFILE)