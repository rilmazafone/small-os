int my_function(){
    return 0xbaba;
}

//compile with x86_64-elf-gcc -m32 -ffreestanding -c function.c -o function.o
//Linker: x86_64-elf-gcc -m32 -ffreestanding -nostdlib -Ttext 0x0 -o function.bin function.o