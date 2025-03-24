default rel

;--------------------------------------------------------------------------
; Constants
;--------------------------------------------------------------------------
%define UINT8_MAX     256
%define PAGE_SIZE     4096
%define PAGE_COUNT    16
%define TABLE_SIZE    65536
%define CLEAR_CODE    UINT8_MAX
%define EOF_CODE      UINT8_MAX + 1
%define MIN_BIT_COUNT 9
%define MAX_BIT_COUNT 12

section .text
    global lzw_decode

;--------------------------------------------------------------------------
;   lzw_decode (rcx = in, rdx = in_size, r8 = out, r9 = out_size)
;--------------------------------------------------------------------------
lzw_decode:
    push rbx
    push rbp
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

; rax(?), rcx(in), rdx(in_size), rbx(?), rsi(?), rdi(?), r8(out), r9(out_size), r10(?), r11(?), r12(?), r13(?), r14(?), r15(?)
    mov rsi, rcx
    mov rdi, r8

    mov r8, rdx
    mov r15, r9
; rax(?), rcx(in), rdx(in_size), rbx(?), rsi(in), rdi(out), r8(in_size), r9(out_size), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)

    test r8, r8
    jz .L28                       ; обработка ошибок

    push rdi
    mov r9, MIN_BIT_COUNT
    mov ebx, 0x1FF
; rax(?), rcx(in), rdx(in_size), rbx(0x1FF), rsi(in), rdi(out), r8(in_size), r9(MIN_BIT_COUNT), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)
; [rdi]

    sub rsp, 8

._touch_pages:
    sub rsp, PAGE_SIZE * PAGE_COUNT
; rax(?), rcx(in), rdx(in_size), rbx(0x1FF), rsi(in), rdi(out), r8(in_size), r9(MIN_BIT_COUNT), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)
; [rdi], [?], [?] * 65536
    mov eax, [rsp + PAGE_SIZE * 15]
    mov eax, [rsp + PAGE_SIZE * 14]
    mov eax, [rsp + PAGE_SIZE * 13]
    mov eax, [rsp + PAGE_SIZE * 12]
    mov eax, [rsp + PAGE_SIZE * 11]
    mov eax, [rsp + PAGE_SIZE * 10]
    mov eax, [rsp + PAGE_SIZE * 9]
    mov eax, [rsp + PAGE_SIZE * 8]
    mov eax, [rsp + PAGE_SIZE * 7]
    mov eax, [rsp + PAGE_SIZE * 6]
    mov eax, [rsp + PAGE_SIZE * 5]
    mov eax, [rsp + PAGE_SIZE * 4]
    mov eax, [rsp + PAGE_SIZE * 3]
    mov eax, [rsp + PAGE_SIZE * 2]
    mov eax, [rsp + PAGE_SIZE * 1]
    mov eax, [rsp + PAGE_SIZE]
    mov ecx, PAGE_COUNT
; rax(?), rcx(PAGE_COUNT), rdx(in_size), rbx(0x1FF), rsi(in), rdi(out), r8(in_size), r9(MIN_BIT_COUNT), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)
; [rdi], [?], [?] * 65536
.L1:
    xor ecx, ecx
    mov rbp, rsp
; rax(?), rcx(0), rdx(in_size), rbx(0x1FF), rsi(in), rdi(out), r8(in_size), r9(MIN_BIT_COUNT), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)
; [rdi], [?], [?] * 65536 ~ (rbp)
.L2:
; rax(?), rcx(0), rdx(in_size), rbx(0x1FF), rsi(in), rdi(out), r8(in_size), r9(MIN_BIT_COUNT), r10(?), r11(?), r12(?), r13(?), r14(?), r15(out_size)
; [rdi], [?], [?] * 65536 ~ (rbp)
    mov [rbp], word 1
    mov [rbp + 8], rcx
    mov [rbp + 2], cl
    lea rbp, [rbp + 16]
    inc ecx
    cmp ecx, CLEAR_CODE
    jb .L2
    xor r10, r10
    xor r11, r11
    mov eax, esi
    neg eax
    and eax, 7
    jz .L5
    mov ecx, eax
.L3:
    test r8, r8
    jz .L26
    cmp r8, 4
    cmovb rcx, r8
    cmp r8, rcx
    cmovb rcx, r8
    sub r8, rcx
.L4:
    movzx edx, byte [rsi]
    inc rsi
    shl r11, 8
    or  r11, rdx
    lea r10, [r10 + 8]
    loop .L4
.L5:
    cmp r10, r9
    jnb .L6
    cmp r8, 4
    jb .L3
    lea r8, [r8 - 4]
    mov edx, dword [rsi]
    bswap edx
    lea rsi, [rsi + 4]
    shl r11, 32
    or  r11, rdx
    lea r10, [r10 + 32]
.L6:
    mov rax, r11
    sub r10, r9
    mov rcx, r10
    shr rax, cl
    and eax, ebx

    cmp eax, EOF_CODE
    je  .L27
    cmp eax, CLEAR_CODE
    je  .L22

    shl eax, 4
    lea rax, [rsp + rax]
    movzx ecx, word [r12]
    cmp ecx, 8
    jae .L7
    inc ecx
    mov [rbp], cx
    mov r14, [r12 + 8]
    mov r12, rax
    cmp r12, rbp
    jnb .L8
    movzx rax, byte [r12 + 2]
    lea ecx, [ecx * 8 - 8]
    shl rax, cl
    or  rax, r14
    mov [rbp + 8], rax
    mov [rbp + 2], al
    jmp .L9
.L8:
    movzx rax, r14b
    mov [rbp + 2], al
    lea ecx, [ecx * 8 - 8]
    shl rax, cl
    or rax, r14
    mov [rbp + 8], rax
    jmp .L9
.L7:
    movzx edx, byte [r12 + 2]
    mov [rbp + 2], dl
    mov rdx, rdi
    sub rdx, rcx
    mov [rbp + 8], rdx
    mov r12, rax
    inc ecx
    mov [rbp], cx
.L9:
    lea rbp, [rbp + 16]
    cmp rbp, r13
    jne .L10
    inc r9
    cmp r9, MAX_BIT_COUNT
    ja .L26
    cmp r9d, 9
    je .L9bit9
    cmp r9d, 10
    je .L9bit10
    cmp r9d, 11
    je .L9bit11
    jmp .L9bit12
.L9bit9:
    mov ebx, 0x1FF
    mov edx, -1
    jmp .L9bitsDone
.L9bit10:
    mov ebx, 0x3FF
    mov edx, 8192
    jmp .L9bitsDone
.L9bit11:
    mov ebx, 0x7FF
    mov edx, 16384
    jmp .L9bitsDone
.L9bit12:
    mov ebx, 0xFFF
    mov edx, 32768
.L9bitsDone:
    add r13, rdx