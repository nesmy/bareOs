[BITS 16]
[ORG 0x7c00]

_start:	
	;; mov ax, 0x07c0
	cli
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov sp, 0x7C00

	mov si, msg
	call print

	mov [BOOT_DRIVE], dl

	;;  Load kernel (20 sectors starting at LBA 2 into 0x100000)
	mov ax, 0x1000
	mov es, ax
	xor bx, bx
	
	mov ah, 0x02		; BIOS read sector
	mov al, 32		; number of sectors
	mov ch, 0		; cylinder
	mov cl, 2		; sector (start at 2)
	mov dh, 0		; head
	mov dl, [BOOT_DRIVE]

	int 0x13
	jc disk_error

	call enable_a20

	lgdt [gdt_desc]

	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:protected_mode

disk_error:
	mov si, error_msg
	call print
	jmp $


[BITS 32]
protected_mode:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x90000

	;; jump to kernel (loaded a 1MB)
	;; call 0x00100000
	jmp CODE_SEG:0x00010000
	;; jmp CODE_SEG:0x00100000

hang:
	jmp hang

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

enable_a20:
	in al, 0x92
	or al, 2
	out 0x92, al
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;; GDT
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gdt_start:
	dq 0x0000000000000000
	dq 0x00CF9A000000FFFF
	dq 0x00CF92000000FFFF
gdt_end:

gdt_desc:
	dw gdt_end - gdt_start - 1
	dd gdt_start

	CODE_SEG equ 0x08
	DATA_SEG equ 0x10

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	%include 'print.asm'

	msg db 'Welcome to bareOS!', 0

	BOOT_DRIVE db 0
	error_msg db "Disk Error!", 0	

	times 510-($-$$) db 0
	db 0x55
	db 0xAA
