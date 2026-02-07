all: qemu

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

floopy: boot.bin
	sudo dd if=boot.bin of=/dev/fd0

qemu: floopy
	sudo qemu-system-x86_64 -fda /dev/fd0

clean:
	rm *.bin
