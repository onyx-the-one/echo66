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
 mov si, welcome_str
 call print_tt

; SHELL
shell_prompt:
 mov di, command_buffer
 mov si, prompt
 call print_tt
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
 mov di, command_buffer
 mov si, cmd_help
 call strcmp
 jc .help
 mov si, cmd_clear
 call strcmp
 jc .clear
 mov si, cmd_reboot
 call strcmp
 jc .reboot
 jmp .bad_command

; COMMANDS
.bad_command:
 mov si, bad_command_str
 call print_tt
 jmp shell_prompt
.help:
 mov si, help_msg
 call print_tt
 jmp shell_prompt
.clear:
 mov ah, 0x00
 mov al, 0x03
 int 0x10
 jmp shell_prompt
.reboot:
 jmp 0xFFFF:0x0000

; FUNCTIONS
print_tt:
 mov ah, 0x0E
.loop:
 lodsb
 cmp al, 0
 je .done
 int 0x10
 jmp .loop
.done:
 ret
strcmp:
 push si
 push di
.compare_loop:
 lodsb
 mov bl, [di]
 inc di
 cmp al, bl
 jne .nomatch
 cmp al, 0
 jne .compare_loop
 stc
 pop di
 pop si
 ret
.nomatch:
 clc
 pop di
 pop si
 ret

; DATA
welcome_str db 'Welcome to Ring 0 of ECHO66', 13, 10, 0
prompt db 'OS> ', 0
bad_command_str db 'Unrecognized command. Execute HELP for help.', 13, 10, 0
help_msg db 'ECHO66 shell interface. Version 0.0', 13, 10, 'Common commands:', 13, 10, 'HELP - This help page.', 13, 10, 'CLEAR - Clear the screen.', 13, 10, 'REBOOT - Reboot the computer.', 13, 10, 0

cmd_help db 'HELP', 0
cmd_clear db 'CLEAR', 0
cmd_reboot db 'REBOOT', 0

command_buffer rb 64
