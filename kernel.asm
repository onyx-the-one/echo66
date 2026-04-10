format binary
use16
org 0x8000

start:
 ; SEG INIT
 cli
 mov ax, 0
 mov ds, ax
 mov es, ax
 mov ss, ax
 mov sp, 0x7C00
 sti

; WELCOME
welcome:
 mov ah, 0x09
 mob bl, 0x0B
 mov si, welcome_str
.print_welcome:
 lodsb
 cmp al, 0
 je shell_prompt
 int 0x10
 jmp .print_welcome

; SHELL
shell_prompt:
 mov ah, 0x09
 mov bl, 0x0A
 mov si, prompt
.print_shell:
 lodsb
 cmp al, 0
 je input_loop
 int 0x10
 jmp .print_shell
input_loop:
 mov ah, 0x00
 int 0x16
 cmp al, 13
 je .newline
 cmp al, 8
 je .backspace
 mov ah, 0x09
 mov bl, 0x0F
 int 0x10
 jmp input_loop
.newline:
 mov ah, 0x09
 mov bl, 0x0F
 mov al, 13
 int 0x10
 mov al, 10
 int 0x10
 jmp shell_prompt
.backspace:
 mov ah, 0x09
 mov bl, 0x0F
 mov al, 8
 int 0x10
 mov al, 32
 int 0x10
 mov al, 32
 int 0x10
 jmp input_loop

; DATA
welcome_str db 'Welcome to Ring 0 of ECHO66', 13, 10, 0
prompt db 'OS> ', 0
