[BITS 16]
[ORG 0x1000]

;===============TODO===============
;   Criar uma funcao read_line para
;   evitar repeticao de codigo nas
;   funcoes .initial_read_loop e
;   read_loop.
;===================================


_start:
    mov cx, 16
    mov di, name
    xor al, al
    rep stosb

    mov si, entry_msg
    call print_string

    xor bx, bx
.initial_read_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace

    cmp bx, 15
    jge .initial_read_loop

    mov [name + bx], al
    inc bx
    call print_char
    jmp .initial_read_loop

.done:
    mov byte [name + bx], 0
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    jmp main_loop

.backspace:
    test bx, bx
    jz .initial_read_loop
    dec bx
    call print_backspace
    jmp .initial_read_loop

main_loop:
    mov si, name
    call print_string
    mov si, prompt
    call print_string

    mov cx, 128
    mov di, input_buffer
    xor al, al
    rep stosb

    xor bx, bx
read_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D
    je .new_line
    cmp al, 0x08
    je .backspace
    
    cmp bx, 127
    jge read_loop
    
    mov [input_buffer + bx], al
    inc bx
    call print_char
    jmp read_loop

.new_line:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    jmp main_loop

.backspace:
    test bx, bx
    jz read_loop
    dec bx
    call print_backspace
    jmp read_loop

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

entry_msg db "Kernel Working! Please enter your name: ", 0
name times 16 db 0
prompt db "> ", 0
input_buffer times 128 db 0