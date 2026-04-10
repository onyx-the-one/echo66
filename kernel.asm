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
 mov ah, 0x0E
 mov si, welcome_str
.print_welcome:
 lodsb
 cmp al, 0
 je shell_prompt
 int 0x10
 jmp .print_welcome

; SHELL
shell_prompt:
 mov ah, 0x0E
 mov di, command_buffer
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
 mov ah, 0x0E
 int 0x10
 stosb
 jmp input_loop
.newline:
 mov ah, 0x0E
 mov al, 13
 int 0x10
 mov al, 10
 int 0x10
 mov al, 0
 stosb
 jmp check_commands
.backspace:
 cmp di, command_buffer
 je input_loop
 mov ah, 0x0E
 mov al, 8
 int 0x10
 mov al, 32
 int 0x10
 mov al, 8
 int 0x10
 dec di
 jmp input_loop
check_commands:
 mov si, cmd_help
 mov di, command_buffer
.compare_loop:
 lodsb
 mov bl, [di]
 inc di
 cmp al, bl
 jne .bad_command
 cmp al, 0
 je .help
 jmp .compare_loop
.bad_command:
 mov ah, 0x0E
 mov si, bad_command_str
.print_bad_command:
 lodsb
 cmp al, 0
 je shell_prompt
 int 0x10
 jmp .print_bad_command
.help:
 mov ah, 0x0E
 mov si, help_msg
.print_help:
 lodsb
 cmp al, 0
 je shell_prompt
 int 0x10
 jmp .print_help

; DATA
welcome_str db 'Welcome to Ring 0 of ECHO66', 13, 10, 0
prompt db 'OS> ', 0
bad_command_str db 'Unrecognized command. Execute HELP for help.', 13, 10, 0

cmd_help db 'HELP', 0
help_msg db 'ECHO66 shell interface. Version 0.0', 13, 10, 'Common commands:', 13, 10, 'HELP - This help page.', 13, 10, 'More coming later...', 13, 10, 0

command_buffer rb 64
