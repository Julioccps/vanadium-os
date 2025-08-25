[BITS 16]
[ORG 0x7c00]

_start:
    xor ax, ax
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00

    mov bx, 0x1000
    mov ah, 0x02
    mov al, 2
    mov ch, 0
    mov cl, 2
    mov dh, 0
    int 0x13
    jc disk_error

    mov bx, 0x2000
    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 5
    mov dh, 0
    int 0x13
    jc disk_error

    jmp 0x0000:0x1000

disk_error:
    mov si, error_msg
    call print
    jmp $

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print
.done:
    ret

error_msg db "Disk Error", 0
times 510-($-$$) db 0
dw 0xAA55