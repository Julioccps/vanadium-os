[BITS 16]
[ORG 0x2000]

_start:
    mov si, shell_msg
    call print_string
    call new_line
    jmp $

;   ========== FUNCTIONS ==========
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

new_line:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    ret

backspace:
    mov al, 0x08
    call print_char
    mov al, 0x20
    call print_char
    mov al, 0x08
    call print_char
    ret

;   ========== DATA ==========
shell_msg db "Shell Working!", 0
times 512 - ($ - $$) db 0