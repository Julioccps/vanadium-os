[BITS 16]
[ORG 0x1000]

_start:
    mov cx, 15
    mov di, name
    call clear_buffer

    mov si, entry_msg
    call print_string
    mov di, name
    mov cx, 15
    call read_line
    
    jmp main_loop

main_loop:
    mov si, name
    call print_string
    mov si, prompt
    call print_string

    mov cx, 127
    mov di, input_buffer
    call clear_buffer
    mov cx, 127          
    mov di, input_buffer
    call read_line
    
    mov si, cmd_exec
    call parse_command
    jmp main_loop

;   ========== FUNCTIONS ==========
read_line:
    xor bx, bx 

.key_loop:
    mov ah, 0x00
    int 0x16    

    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace

    cmp bx, cx
    jge .key_loop

    mov [di + bx], al
    inc bx
    call print_char
    jmp .key_loop

.backspace:
    test bx, bx
    jz .key_loop
    dec bx
    call print_backspace
    jmp .key_loop

.done:
    mov byte [di + bx], 0
    call new_line
    ret

new_line:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    ret

print_backspace:
    mov al, 0x08
    call print_char
    mov al, ' '
    call print_char
    mov al, 0x08
    call print_char
    ret

print_string:
    lodsb
    or al, al
    jz .done
    call print_char
    jmp print_string
.done:
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    ret

clear_buffer:
    xor al, al
    rep stosb
    ret

parse_command:
    mov si, input_buffer
    mov di, cmd_exec
    call compare_string
    je load_shell

    mov si, command_not_found
    call print_string
    call new_line
    ret

load_shell:
    cmp word [0x2000], 0
    je .no_shell
    jmp 0x0000:0x2000
.no_shell:
    mov si, no_shell_msg
    call print_string
    call new_line
    ret

compare_string:
.compare_loop:
    mov al, [si]
    cmp bl, [di]
    cmp al, bl
    jne .not_equal
    test al, al
    jnz .equal
    inc si
    inc di
    jmp .compare_loop
.equal:
    xor ax, ax
    inc ax
    ret
.not_equal:
    xor ax, ax
    ret

;   ========== DATA ==========
entry_msg db "Kernel Working! Please enter your name: ", 0
name times 16 db 0
prompt db "> ", 0
cmd_exec db "exec", 0
command_not_found db "Command not found", 0
no_shell_msg db "No shell loaded", 0

input_buffer times 128 db 0


times 512 - ($ - $$) db 0
