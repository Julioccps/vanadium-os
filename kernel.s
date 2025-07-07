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
    
    call syscall_setup
    call fs_init
    
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
    mov al, 0x20
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
    test ax, 1
    jz load_shell

    mov si, command_not_found
    call print_string
    call new_line
    ret

load_shell:
    cmp word [0x2000], 0
    je .no_shell
    mov si, name        
    jmp 0x0000:0x2000
.no_shell:
    mov si, no_shell_msg
    call print_string
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
    inc si
    inc di
    jmp .loop
.equal:
    mov ax, 1
    ret
.not_equal:
    xor ax, ax
    ret

;   ========== SYSCALLS ==========
syscall_setup:
    xor ax, ax
    mov es, ax
    mov word [es:0x80*4], syscall_handler
    mov word [es:0x80*4+2], cs
    ret
syscall_handler:
    cmp ah, 0x00
    je sys_read
    cmp ah, 0x01
    je sys_write
    cmp ah, 0x02
    je sys_exit
    cmp ah, 0x03
    je sys_open
    cmp ah, 0x04
    je sys_close
    iret
sys_read:
    mov ah, 0x00
    int 0x16
    iret

sys_write:
    call print_string
    iret

sys_exit:
    jmp main_loop

sys_open:
;   =========== TODO ===========
;   Handle File with file system
;   ============================

sys_close:
;   ========== TODO ============
;   Handle File with file system
;   ============================


;   ========= FILE SYSTEM =========
fs_init:
    mov cx, MAX_OPEN_FILES
    mov di, file_descriptor_table
.loop:
    mov byte [di + FdInUseOffset], 0 
    add di, FD_STRUCT_SIZE
    loop .loop
    ret

;   ========== DATA ==========
MAX_OPEN_FILES equ 8
FD_STRUCT_SIZE equ 10

FdInUseOffset   equ 0 
FdStartSector   equ 1 
FdFileSize      equ 5 
FdSeekPos       equ 9 

entry_msg db "Kernel Working! Please enter your name: ", 0
name times 16 db 0
prompt db "> ", 0
cmd_exec db "exec", 0
command_not_found db "Command not found", 0
no_shell_msg db "No shell loaded", 0

input_buffer times 128 db 0

file_descriptor_table:
    times MAX_OPEN_FILES * FD_STRUCT_SIZE db 0
    

times 1024 - ($ - $$) db 0
