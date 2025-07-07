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
    ; TODO: Adicionar aqui a lógica para interpretar o comando em 'input_buffer'
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

;   ========== DATA ==========
welcome_msg db "Welcome, ", 0
shell_msg db "Shell Working!", 0
nl db 0x0D, 0x0A, 0 
prompt db "> ", 0
input_buffer times 128 db 0
char_buffer db 0, 0 

char_backspace db 0x08, 0
char_space db ' ', 0

times 512 - ($ - $$) db 0