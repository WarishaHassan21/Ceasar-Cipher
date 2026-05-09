; ==========================================================
; Project: Caesar Cipher Master Tool (8086 Assembly)
; Features: Menu, Manual Input, Multi-digit Key, File Save
; ==========================================================

org 100h



main_menu:
    ; Display Menu
    mov dx, msg_menu
    mov ah, 09h
    int 21h

    ; Get Choice
    mov ah, 01h
    int 21h
    mov [choice], al

    cmp al, '3'         ; Exit
    je exit_program
    cmp al, '1'
    je start_process
    cmp al, '2'
    je start_process

    ; Invalid input handling
    mov dx, msg_error
    mov ah, 09h
    int 21h
    jmp main_menu

start_process:
    ; 1. Get String
    mov dx, msg_prompt
    mov ah, 09h
    int 21h
    mov dx, buffer
    mov ah, 0Ah
    int 21h

    ; 2. Get Key
    call GetKey

    ; 3. Decide Encrypt or Decrypt
    cmp byte [choice], '2'
    jne do_cipher
    neg byte [shift_key]  

do_cipher:
    call ProcessCipher

    ; 4. Show Result
    mov dx, res_label
    mov ah, 09h
    int 21h
    call PrintResult

    ; 5. Ask to Save
    mov dx, msg_ask_save
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'y'
    je save_logic
    cmp al, 'Y'
    je save_logic
    
    
    jmp main_menu

save_logic:
    call SaveToFile
    jmp main_menu

exit_program:
    mov ax, 4C00h
    int 21h

; --- FUNCTIONS ---

GetKey:
    mov dx, key_prompt
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    sub al, '0'
    mov cl, 10
    mul cl
    mov [shift_key], al
    mov ah, 01h
    int 21h
    sub al, '0'
    add [shift_key], al
    ret

ProcessCipher:
    mov si, buffer + 2
    mov cl, [buffer + 1]
    xor ch, ch
    jcxz done_proc
c_loop:
    mov al, [si]
    ; Upper Case
    cmp al, 'A'
    jb skip_c
    cmp al, 'Z'
    ja check_l
    add al, [shift_key]
u_w: cmp al, 'Z'
    jbe u_m
    sub al, 26
    jmp u_w
u_m: cmp al, 'A'
    jae st_c
    add al, 26
    jmp u_m
check_l:
    cmp al, 'a'
    jb skip_c
    cmp al, 'z'
    ja skip_c
    add al, [shift_key]
l_w: cmp al, 'z'
    jbe l_m
    sub al, 26
    jmp l_w
l_m: cmp al, 'a'
    jae st_c
    add al, 26
    jmp l_m
st_c: mov [si], al
skip_c: inc si
    loop c_loop
done_proc: ret

PrintResult:
    mov bl, [buffer+1]
    xor bh, bh
    mov byte [buffer+2+bx], '$'
    mov dx, buffer+2
    mov ah, 09h
    int 21h
    ret

SaveToFile:
    mov dx, filename
    mov cx, 0
    mov ah, 3Ch
    int 21h
    mov [f_handle], ax
    mov bx, ax
    mov cl, [buffer+1]
    xor ch, ch
    mov dx, buffer+2
    mov ah, 40h
    int 21h
    mov bx, [f_handle]
    mov ah, 3Eh
    int 21h
    mov dx, msg_success
    mov ah, 09h
    int 21h
    ret


    msg_menu     db 0Dh, 0Ah, '--- CAESAR MASTER MENU ---'
                 db 0Dh, 0Ah, '1. Encrypt Message'
                 db 0Dh, 0Ah, '2. Decrypt Message'
                 db 0Dh, 0Ah, '3. Exit'
                 db 0Dh, 0Ah, 'Choice: $'
    msg_prompt   db 0Dh, 0Ah, 'Enter Message: $'
    key_prompt   db 0Dh, 0Ah, 'Enter 2-digit Key (00-25): $'
    res_label    db 0Dh, 0Ah, 'Result: $'
    msg_ask_save db 0Dh, 0Ah, 'Save to result.txt? (Y/N): $'
    msg_success  db 0Dh, 0Ah, 'Saved successfully!$'
    msg_error    db 0Dh, 0Ah, 'Invalid Choice!$'
    filename     db 'result.txt', 0
    
    buffer       db 100, 0
    res_space    times 105 db '$'
    shift_key    db 0
    choice       db 0
    f_handle     dw 0