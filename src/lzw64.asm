section .data

section .text

global lzw_decode

extern printf

lzw_decode:

    push        rbp
    mov         rbp, rsp

    mov         [rbp + 16], rcx
    mov         [rbp + 24], rdx
    mov         [rbp + 32], r8
    mov         [rbp + 40], r9
    push        rbx
    push        rsi
    push        rdi
    push        r12
    push        r13

    sub         rsp, 65536

    mov         ecx, [rsp + 4096 * 16]
    mov         ecx, [rsp + 4096 * 15]
    mov         ecx, [rsp + 4096 * 14]
    mov         ecx, [rsp + 4096 * 13]
    mov         ecx, [rsp + 4096 * 12]
    mov         ecx, [rsp + 4096 * 11]
    mov         ecx, [rsp + 4096 * 10]
    mov         ecx, [rsp + 4096 *  9]
    mov         ecx, [rsp + 4096 *  8]
    mov         ecx, [rsp + 4096 *  7]
    mov         ecx, [rsp + 4096 *  6]
    mov         ecx, [rsp + 4096 *  5]
    mov         ecx, [rsp + 4096 *  4]
    mov         ecx, [rsp + 4096 *  3]
    mov         ecx, [rsp + 4096 *  2]
    mov         ecx, [rsp + 4096 *  1]
    mov         ecx, [rsp]

    xor         eax, eax
    push        rax
    push        rax
    push        rax
    push        rax
    push        rax

    sub         rsp, 4
    sub         rsp, 4
    sub         rsp, 4
    sub         rsp, 4
    sub         rsp, 4
    sub         rsp, 4

    mov         rax, [rbp + 16] ; hehe
    mov         rbx, rax
    add         rax, 3
    mov         ecx, 3
    not         rcx
    and         rax, rcx
    mov         [rbp - 65584], rax

    mov         rsi, rbx
    sub         rax, rbx

    mov         rcx, [rbp + 24]
    cmp         rax, rcx

    jbe         .fi1
    mov         rax, rcx
.fi1:

    mov         rdx, rax
    mov         [rbp - 65592], rax

    push        rdx
    mov         r10, 8
    mul         r10
    pop         rdx
    mov         [rbp - 65640], al

    xor         eax, eax
    xor         ecx, ecx
loop1:
    cmp         rcx, rdx
    jge         .lend1

    shl         rax, 8
    or          rax, [rsi + rcx]

    inc         rcx
    jmp         loop1
.lend1:
    mov         [rbp - 65600], rax

    add         rsi, [rbp + 24]
    mov         rcx, rsi
    mov         eax, 3
    not         rax
    and         rsi, rax
    mov         [rbp - 65608], rsi

    mov         [rbp - 65616], rcx

    mov         dword [rbp - 65620], 258
    mov         dword [rbp - 65624], 9
    mov         dword [rbp - 65628], -2
    mov         dword [rbp - 65636], 0

    lea         rax, [rbp - 65576]
    xor         ecx, ecx
.loop2:
    mov         word [rax + 14], 1
    mov         [rax], cl

    add         rax, 16
    inc         rcx

    cmp         rcx, 256
    jl          .loop2

.mainloop:

    movzx       eax, byte [rbp - 65640]
    cmp         eax, dword [rbp - 65624]

    jge         .fi3

    mov         rsi, [rbp - 65584]
    mov         rdx, [rbp - 65600]
    movbe       ecx, [rsi]
    add         rsi, 4
    shl         rdx, 32
    or          rdx, rcx
    add         al, 32
    mov         [rbp - 65640], al
    mov         [rbp - 65584], rsi
    mov         [rbp - 65600], rdx
.fi3:

    mov         ecx, [rbp - 65624]
    mov         rdx, [rbp - 65600]
    mov         ebx, ecx
    neg         ecx
    add         ecx, eax
    shr         rdx, cl
    mov         ecx, ebx
    mov         esi, 1
    shl         esi, cl
    dec         esi
    and         rdx, rsi

    mov         [rbp - 65632], edx

    sub         eax, ebx

    mov         [rbp - 65640], al

    mov         rdi, [rbp - 65608]
    mov         rsi, [rbp - 65584]
    cmp         rsi, rdi

    jne         .fi4

    mov         rcx, rsi
    mov         rdx, [rbp - 65616]
    mov         rbx, [rbp - 65600]

.loop3:

    cmp         rcx, rdx

    jae         .lend3

    shl         rbx, 8
    or          bl, byte [rcx]
    inc         rcx
    add         rax, 8

    jmp         .loop3
.lend3:
    mov         [rbp - 65600], rbx
    mov         [rbp - 65584], rcx
    mov         [rbp - 65640], al

.fi4:

    mov         edx, [rbp - 65632]

    cmp         edx, 256

    jne         .fi5
    mov         dword [rbp - 65620], 258
    mov         dword [rbp - 65624], 9
    mov         dword [rbp - 65628], -1

    mov         rbx, [rbp + 16]
    mov         rcx, 256
    mov         rsi, [rbp - 65608]
    mov         rdx, [rbp - 65592]

    jmp         .mainloop

.fi5:
    cmp         edx, 257

    je          .mlend
.else:
    cmp         dword [rbp - 65628], -1

    jne         .fi6
    lea         rbx, [rbp - 65576]
    mov         rcx, rdx

    xchg        rax, rcx

    push        rdx
    mov         r10, 16
    mul         r10
    pop         rdx
    xchg        rax, rcx

    lea         rsi, [rbx + rcx]
    movzx       ecx, word [rsi + 14]

    cmp         ecx, 14

    jbe         .fi_not_small_obj
    mov         rsi, [rsi]

.fi_not_small_obj:

    mov         rax, [rbp + 32]
    lea         rdi, [rsi + rcx]

.loop4:

    movzx       ebx, byte [rsi]
    mov         [rax], rbx
    inc         rax
    inc         rsi
    cmp         rsi, rdi
    jb          .loop4

    mov         [rbp + 32], rax
    add         [rbp - 65636], ecx

    jmp         .fiend

.fi6:
    cmp         edx, [rbp - 65620]

    jge         .fi7
    mov         r10d, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    mov         eax, r10d

    push        rdx
    mov         r11, 16
    mul         r11
    add         rax, rbx
    movzx       r11d, word [rax + 14]

    mov         eax, [rbp - 65620]
    mov         rcx, 16
    mul         rcx
    pop         rdx

    add         rax, rbx

    cmp         r11w, 14

    jae         .else1

    mov         ecx, 16
    mov         r13, rdx
    mov         rdi, rax
    mov         rax, r10
    mov         r12, 16
    mul         r12
    add         rax, rbx
    mov         rsi, rax

    rep movsb
    sub         rdi, 16
    sub         rsi, 16
    add         word [rdi + 14], 1

    jmp         .fi8
.else1:
    mov         r13, rdx
    mov         rdi, rax
    inc         r11
    mov         [rdi + 14], r11w
    dec         r11
    mov         eax, r11d
    neg         rax
    add         rax, [rbp + 32]
    mov         [rdi], rax

.fi8:

    mov         rax, r13
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    movzx       r12, word [rax + 14]
    cmp         r12, 14
    jbe         .fi9
    mov         rax, [rax]
.fi9:

    xor         ecx, ecx
    mov         rsi, rax
    mov         rax, [rbp + 32]
.loop5:

    mov         dl, [rsi + rcx]
    mov         [rax], dl
    inc         rcx
    inc         rax
    cmp         rcx, r12

    jb          .loop5

    mov         [rbp + 32], rax
    add         [rbp - 65636], r12d

    cmp         r11, 14

    jae         .fi10
    movzx       eax, byte [rsi]
    mov         [rdi + r11], al

.fi10:

    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      rcx, rax
    cmp         rcx, 1

    jne         .fi11
    add         dword [rbp - 65624], 1
.fi11:

    dec         rax
    mov         [rbp - 65620], eax

    jmp         .fiend
.fi7:

    mov         eax, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    cmp         eax, 0
    jge         .skipo
    cmp         eax, 4096
    jl          .skipo
    int3
.skipo:
    mov         r13, rdx
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    movzx       r11d, word [rax + 14]
    mov         eax, [rbp - 65620]
    mov         rdx, 16
    mul         rdx
    add         rax, rbx

    mov         rdi, rax
    mov         r10d, [rbp - 65628]
    cmp         r11w, 14

    jae         .else2
    mov         ecx, 16
    mov         rax, r10
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    mov         rsi, rax
    rep movsb
    sub         rdi, 16
    sub         rsi, 16
    add         word [rdi + 14], 1
    mov         al, [rdi]
    mov         [rdi + r11], al

    jmp         .fi12
.else2:

    mov         eax, r11d
    inc         eax
    mov         word [rdi + 14], ax
    dec         eax
    neg         rax
    add         rax, [rbp + 32]
    mov         [rdi], rax

.fi12:

    mov         eax, r10d
    mov         rdx, 16
    mul         rdx
    add         rax, rbx

    mov         rsi, rax
    movzx       eax, word [rsi + 14]

    cmp         eax, 14

    jbe         .fi13
    mov         rsi, [rsi]
.fi13:

    mov         r12, rax
    mov         rax, [rbp + 32]
    xor         ecx, ecx
.loop6:

    mov         dl, [rsi + rcx]
    mov         [rax], dl
    inc         ecx
    inc         rax
    cmp         rcx, r12

    jb          .loop6

    mov         dl, [rsi]
    mov         [rax], dl
    inc         rax
    mov         [rbp + 32], rax
    lea         rax, [r12 + 1]

    add         [rbp - 65636], eax
    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      ecx, eax
    cmp         ecx, 1

    jne         .fi14
    add         dword [rbp - 65624], 1
.fi14:

    dec         rax
    mov         [rbp - 65620], eax

.fiend:

    mov         eax, [rbp - 65632]
    mov         [rbp - 65628], eax
    mov         ecx, 256
    mov         rdx, [rbp - 65592]
    mov         rbx, [rbp + 16]
    mov         rsi, [rbp - 65608]

    jmp         .mainloop
.mlend:

    mov         r13d, [rbp - 65636]

    add         rsp, 4
    add         rsp, 4
    add         rsp, 4
    add         rsp, 4
    add         rsp, 4
    add         rsp, 4

    pop         rax
    pop         rax
    pop         rax
    pop         rax
    pop         rax

    add         rsp, 65536

    mov         eax, r13d

    pop         r13
    pop         r12
    pop         rdi
    pop         rsi
    pop         rbx

    pop         rbp
    ret