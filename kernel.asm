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
 mov ah, 0x00
 mov al, 0x03
 int 0x10

; WELCOME
welcome:
 mov si, welcome_str
 call print_vga

; SHELL
shell_prompt:
 mov si, prompt
 call print_vga
 mov di, command_buffer
input_loop:
 mov ah, 0x00
 int 0x16
 cmp al, 13
 je .newline
 cmp al, 8
 je .backspace
 push ax
 push es
 mov cx, 0xB800
 mov es, cx
 mov bx, [cursor_pos]
 mov byte [es:bx], al
 mov byte [es:bx+1], 0x0F
 add bx, 2
 mov [cursor_pos], bx
 call update_cursor
 pop es
 pop ax
 stosb
 jmp input_loop
.newline:
 mov al, 0
 stosb
 mov si, newline_str
 call print_vga
 jmp check_commands
.backspace:
 cmp di, command_buffer
 je input_loop
 dec di
 push es
 mov cx, 0xb800
 mov es, cx
 mov bx, [cursor_pos]
 sub bx, 2
 mov byte [es:bx], 32
 mov byte [es:bx+1], 0x07
 mov [cursor_pos], bx
 call update_cursor
 pop es
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
 call print_vga
 jmp shell_prompt
.help:
 mov si, help_msg
 call print_vga
 jmp shell_prompt
.clear:
 mov ah, 0x00
 mov al, 0x03
 int 0x10
 mov [cursor_pos], 0
 jmp shell_prompt
.reboot:
 jmp 0xFFFF:0x0000

; FUNCTIONS
print_vga:
 push es
 mov ax, 0xB800
 mov es, ax
 mov di, [cursor_pos]
.loop_vga:
 lodsb
 cmp al, 0
 je .done_vga
 cmp al, 13
 je .loop_vga
 cmp al, 10
 je .crlf
 mov byte [es:di], al
 mov byte [es:di+1], 0x0A ; green for now
 add di, 2
 jmp .loop_vga
.crlf:
 mov ax, di
 mov bl, 160
 div bl
 inc al
 mov ah, 0
 mul bl
 mov di, ax
 cmp di, 4000
 jge .scroll_vga
 jmp .loop_vga
.scroll_vga:
 mov di, 0
 jmp .loop_vga
.done_vga:
 mov [cursor_pos], di
 mov ax, [cursor_pos]
 shr ax, 1
 mov bl, 80
 div bl
 mov dh, al
 mov dl, ah
 mov bh, 0
 mov ah, 0x02
 int 0x10
 call update_cursor
 pop es
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

update_cursor:
 push ax
 push bx
 push dx

 mov ax,[cursor_pos]
 shr ax, 1
 mov bx, ax

 mov dx, 0x03D4
 mov al, 0x0E
 out dx, al

 mov dx, 0x03D5
 mov al, bh
 out dx, al

 mov dx, 0x03D4
 mov al, 0x0F
 out dx, al

 mov dx, 0x03D5
 mov al, bl
 out dx, al

 pop dx
 pop bx
 pop ax
 ret

; DATA
welcome_str db 'Welcome to Ring 0 of ECHO66', 13, 10, 0
prompt db 'OS> ', 0
bad_command_str db 'Unrecognized command. Execute HELP for help.', 13, 10, 0
help_msg db 'ECHO66 shell interface. Version 0.0', 13, 10, 'Common commands:', 13, 10, 'HELP - This help page.', 13, 10, 'CLEAR - Clear the screen.', 13, 10, 'REBOOT - Reboot the computer.', 13, 10, 0
cursor_pos dw 0
newline_str db 13, 10, 0

cmd_help db 'HELP', 0
cmd_clear db 'CLEAR', 0
cmd_reboot db 'REBOOT', 0

command_buffer rb 64
