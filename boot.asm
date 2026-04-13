format binary
use16
org 0x7C00

; BTB FAT12
; JUMP SEQUENCE
start:
 jmp main
 nop
; DISK SETUP
oem_name db 'ECHO66  '
bytes_per_setup dw 512
sectors_per_cluster db 1
reserved_sectors dw 1
fat_copies db 2
root_dir_entries dw 224
total_sectors dw 2880
media_descriptor db 0xF0
sectors_per_fat dw 9
sectors_per_track dw 18
heads_per_cylinder dw 2
hidden_sectors dd 0
total_sectors_large dd 0
drive_number db 0
reserved db 0
extended_signature db 0x29
volume_serial_id dd 0x01230123
volume_label db 'ECHO66BOOTL'
file_system_type db 'FAT12   '

main:
 ; STACK
 cli
 mov ax, 0
 mov ds, ax
 mov es, ax
 mov ss, ax
 mov sp, 0x7C00
 sti
 ; KERNEL
 mov [boot_drive], dl
 mov bx, 0x8000
 mov ah, 0x02
 mov al, 5
 mov ch, 0
 mov dh, 0
 mov cl, 2
 int 0x13
 jc error
 mov dl, [boot_drive]
 jmp 0x8000 ; Inshallah


; ERROR
error:
 mov ah, 0x0E
 mov si, err_msg
.print_loop:
 lodsb
 cmp al, 0
 je .done
 int 0x10
 jmp .print_loop
.done:
 cli
 hlt

; DATA
boot_drive db 0
err_msg db 'DISKERROR', 0

; PAD AND SIG
times 510-($-$$) db 0
dw 0xAA55
