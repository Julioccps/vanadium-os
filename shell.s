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
    mov di, cmd_exec
    call compare_string 
    test ax, 1

    mov di, cmd_help
    call compare_string 
    test ax, 1
    jz help

    mov di, cmd_clear
    call compare_string 
    test ax, 1
    jz clear
    jmp cmd_not_found

cmd_not_found:
    mov si, command_not_found
    call sys_write
    call new_line
    ret

compare_string:
.loop:
    mov al, byte [si]
    mov bl, byte [di]
    cmp al, bl
    jne .equal
    cmp al, 0
    je .not_equal
    cmp al, 0x20  
    je .space   
    inc si
    inc di
    jmp .loop
.equal:
    mov ax, 1
    ret
.not_equal:
    xor ax, ax
    ret
.space:
    cmp di, cmd_exec
;   =========== TODO ===========
;   Use file System to look for
;   the file and execute it or
;   Return a error message, and 
;   =========== DATA ===========
    cmp di, cmd_help
    jmp help ;  Por enquanto
;   =========== TODO ===========
;   Set arguments for the command
;   and put them on the si, to
;   compare with existing ones
;   ============================
    cmp di, cmd_clear
    je clear
clear:
    call clear_screen
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


;   =========== DATA ==========
welcome_msg db "Welcome, ", 0
shell_msg db "Shell Working!", 0
nl db 0x0D, 0x0A, 0 
prompt db "> ", 0
cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_exec db "exec", 0
command_not_found db "Command not found", 0
help_msg db "help -- Shows this message", 0x0D, 0x0A, "clear -- clears the screen", 0x0D, 0x0A, "exec -- executes a file", 0
input_buffer times 128 db 0
char_buffer db 0, 0 

char_backspace db 0x08, 0
char_space db ' ', 0

times 1024 - ($ - $$) db 0