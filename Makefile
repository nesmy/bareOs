all: qemu

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.o: kernel.c
	i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

kernel.elf: kernel.o
	i686-elf-gcc -T linker.ld -ffreestanding -m32 -nostdlib kernel.o -o kernel.elf

kernel.bin: kernel.elf
	objcopy -O binary kernel.elf kernel.bin

os-image.bin: kernel.bin boot.bin
	dd if=/dev/zero of=os-image.bin bs=512 count=2880
	dd if=boot.bin of=os-image.bin conv=notrunc
	dd if=kernel.bin of=os-image.bin bs=512 seek=1 conv=notrunc

qemu: os-image.bin
	qemu-system-i386 -fda os-image.bin

clean:
	rm *.bin *.o *.elf
