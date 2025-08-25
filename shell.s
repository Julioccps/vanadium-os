[BITS 16]
[ORG 0x2000]

_start:
    mov bp, si      

    mov si, welcome_msg
    call sys_write
    
    mov si, bp      
    call sys_write

    call new_line

    mov si, shell_msg
    call sys_write
    call new_line

main_loop:
    mov di, input_buffer
    call clear_buffer
    mov di, input_buffer
    mov cx, 127
    mov si, bp
    call sys_write
    mov si, prompt
    call sys_write
    call read_line
    call parse_command
;   =========== TODO ==============
;     Complete the command parser    
;   ===============================
    jmp main_loop

;   ========== FUNCTIONS ==========

read_line:
    xor bx, bx 

.key_loop:
    call sys_read
    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace

    cmp bx, cx
    jge .key_loop

    mov [di + bx], al
    inc bx
    mov [char_buffer], al
    mov si, char_buffer
    call sys_write
    jmp .key_loop

.done:
    mov byte [di + bx], 0
    call new_line
    ret

.backspace:
    test bx, bx
    jz .key_loop
    dec bx
    call print_backspace
    jmp .key_loop

clear_buffer:
    xor al, al
    rep stosb
    ret

sys_write:
    mov ah, 0x01
    int 0x80
    ret

sys_read:
    mov ah, 0x00
    int 0x80
    ret

sys_exit:
    mov ah, 0x02
    int 0x80
    ret

sys_open:
    mov ah, 0x03
    int 0x80
    ret

sys_close:
    mov ah, 0x04
    int 0x80
    ret

new_line:
    mov si, nl
    call sys_write
    ret

print_backspace:
    mov si, char_backspace
    call sys_write
    mov si, char_space
    call sys_write
    mov si, char_backspace
    call sys_write
    ret

parse_command:
    mov si, input_buffer
    mov di, cmd_buffer
.copy_command_loop:
    lodsb
    ;cmp al, 0x20
    ;je .command_copied
    cmp al, 0
    je .command_copied
    stosb
    jmp .copy_command_loop
.command_copied:
    mov byte [di], 0

    mov di, cmd_help
    mov si, cmd_buffer
    call strcmp
    test ax, ax
    jz .show_general_help
    
    mov di, cmd_help_help
    mov si, cmd_buffer
    call strcmp
    test ax, ax
    jz .show_help_help

    mov di, cmd_clear
    mov si, cmd_buffer
    call strcmp
    test ax, ax
    jz .do_clear
    
    mov di, cmd_exec
    mov si, cmd_buffer
    call strcmp
    test ax, ax
    jz .do_exec

    mov si, command_not_found
    call sys_write
    call new_line
    ret
.do_help:
    mov si, input_buffer
    mov di, cmd_buffer
    call strlen
    add si, ax
.skip_spaces:
    lodsb
    cmp byte [si], 0x20
    je .skip_spaces 
    cmp byte [si], 0
   je .show_general_help
.skip_next:
    inc si
    jmp .skip_spaces


.check_argument:
    mov di, cmd_help
    call strcmp_after_space
    jz .show_help_help

.show_general_help:
    mov si, help_msg
    call sys_write
    call new_line
    ret

.show_help_help:
    mov si, help_msg_help
    call sys_write
    call new_line
    ret

.do_clear:
    call clear_screen
    ret

.do_exec:
    mov si, exec_place_holder
    call sys_write
    call new_line
    ret

strcmp:
    push si
    push di
.loop:
    mov al, byte [si]
    mov bl, byte [di]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.equal:
    xor ax, ax
    jmp .done
.not_equal:
    mov ax, 1
.done:
    pop di
    pop si
    ret

strcmp_after_space:
    push si
    push di
.loop:
    mov al, byte [si]
    mov bl, byte [di]
    cmp bl, 0
    je .equal
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.equal:
    xor ax, ax
    jmp .done
.not_equal:
    mov ax, 1
.done:
    pop di
    pop si
    ret

clear_screen:
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x1874
    int 0x10
    mov ah, 0x02
    mov bh, 0
    mov dx, 0
    int 0x10
    ret
help:
    mov si, help_msg
    call sys_write
    call new_line
    ret

strlen:
    push si
    xor ax, ax
.loop:
    lodsb
    cmp al, 0
    je .done
    inc ax
    jmp .loop
.done:
    pop si
    ret

;   =========== DATA ==========
welcome_msg db "Welcome, ", 0
shell_msg db "Shell Working!", 0
nl db 0x0D, 0x0A, 0 
prompt db "> ", 0
cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_help_help db "help help", 0
cmd_exec db "exec", 0
exec_place_holder db "Exec is still not implemented", 0
command_not_found db "Command not found", 0
help_msg db "help -- Shows this message", 0x0D, 0x0A, "help <arg> -- shows a message for a specific command", 0x0D, 0x0A, "clear -- clears the screen", 0x0D, 0x0A, "exec -- executes a file", 0
help_msg_help db "help -- shows a message stating all the commands avaiable", 0xD, 0x0A, "help <arg> -- shows a message for a specific command", 0
input_buffer times 128 db 0
char_buffer db 0, 0 
cmd_buffer times 64 db 0
char_backspace db 0x08, 0
char_space db ' ', 0

times 1024 - ($ - $$) db 0
