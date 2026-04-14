format binary
use16
org 0x7C00

; BTB FAT12
; JUMP SEQUENCE
jmp short start
nop
; DISK SETUP
OEMLabel            db "ECHO66  "
BytesPerSector      dw 512
SectorsPerCluster   db 1
ReservedSectors     dw 1
NumberOfFATs        db 2
RootEntries         dw 224
TotalSectors        dw 2880
Media               db 0xF0
SectorsPerFAT       dw 9
SectorsPerTrack     dw 18
HeadsPerCylinder    dw 2
HiddenSectors       dd 0
LargeSectors        dd 0
DriveNumber         db 0
Flags               db 0
Signature           db 0x29
VolumeID            dd 0xFFFFFFFF
VolumeLabel         db "ECHO66BOOTL"
SystemID            db "FAT12   "

start:
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
 mov al, 1
 mov ch, 0
 mov dh, 1
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
