[BITS 16]
[ORG 0x2000]

_start:
    mov si, shell_msg
    call print_string
    jmp $

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

shell_msg db "Shell Working!", 0

times 512 - ($ - $$) db 0