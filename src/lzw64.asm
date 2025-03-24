section .data

                   counter: db "%i", 10, 0
             table_64_info: db "              table_64_info: %p", 10, 0
        bit_stream_64_info: db "         bit_stream_64_info: %p", 10, 0
           shifter_64_info: db "            shifter_64_info: %zu", 10, 0
           current_64_info: db "            current_64_info: %lx", 10, 0
    bit_stream_end_64_info: db "     bit_stream_end_64_info: %p", 10, 0
bit_stream_act_end_64_info: db " bit_stream_act_end_64_info: %p", 10, 0

             ncode_32_info: db "              ncode_32_info: %i", 10, 0
       code_length_32_info: db "        code_length_32_info: %i", 10, 0
          old_code_32_info: db "           old_code_32_info: %i", 10, 0
              code_32_info: db "               code_32_info: %i", 10, 0
            return_32_info: db "             return_32_info: %i", 10, 0

          left_bits_8_info: db "           left_bits_8_info: %hhu", 10, 0

               delimiter: db "===================", 10, 0

section .text
; size_t lzw_decode(const uint8_t* in, size_t in_size, uint8_t* restrict out, size_t out_size);
global lzw_decode

extern printf

lzw_decode:
; >>>>>>> Аргументы
;  const uint_t*          in
;        size_t           in_size
;  const uint_t* restrict out
;        size_t           out_size
; <<<<<<<
    push rbp
    mov rbp, rsp

    mov  [rbp + 16], rcx    ; in
    mov  [rbp + 24], rdx    ; in_size
    mov  [rbp + 32], r8     ; out
    mov  [rbp + 40], r9     ; out_size
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    ; push r15

; >>>
; Переменные
;   entry[4096]           table_64
;      uint64_t           bit_stream_64
;        size_t           shifter_64
;      uint64_t           current_64
;      uint8_t*           bit_stream_end_64
;      uint8_t*           bit_stream_act_end_64
;
;           int           ncode_32
;           int           code_length_32
;           int           old_code_32
;           int           code_32
;           int           return_32
;
;       uint8_t           left_bits_8
;

    sub rsp, 65536          ; table_64              = rbp - 8 * 5 - (4096 * 16) = rbp - 65576

    
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

; rax(0), rcx(?), rdx(?), rbx(?), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)

    xor eax, eax
    push rax                ; bit_stream_64         =              table_64 - 8 = rbp - 65584
    push rax                ; shifter_64            =         bit_stream_64 - 8 = rbp - 65592
    push rax                ; current_64            =            shifter_64 - 8 = rbp - 65600
    push rax                ; bit_stream_end_64     =            current_64 - 8 = rbp - 65608
    push rax                ; bit_stream_act_end_64 =     bit_stream_end_64 - 8 = rbp - 65616

    sub  rsp, 4             ; ncode_32              = bit_stream_act_end_64 - 4 = rbp - 65620
    sub  rsp, 4             ; code_length_32        =              ncode_32 - 4 = rbp - 65624
    sub  rsp, 4             ; old_code_32           =        code_length_32 - 4 = rbp - 65628
    sub  rsp, 4             ; code_32               =           old_code_32 - 4 = rbp - 65632
    sub  rsp, 4             ; return_32             =               code_32 - 4 = rbp - 65636
    sub  rsp, 4             ; left_bits_8           =             return_32 - 4 = rbp - 65640
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    
    mov         rax, [rbp + 16]
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
; rax(bit_stream_64 - in), rcx(in_size), rdx(?), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jbe         .fi1
    mov         rax, rcx
.fi1:
; rax(?shifter_64), rcx(in_size), rdx(?), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         rdx, rax
    mov         [rbp - 65592], rax

; rax(shifter_64), rcx(in_size), rdx(shifter_64), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    push        rdx
    mov         r10, 8
    mul         r10
    pop         rdx
    mov         [rbp - 65640], al

; rax(left_bits_8), rcx(in_size), rdx(shifter_64), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    xor         eax, eax
    xor         ecx, ecx
loop1:
    cmp         rcx, rdx
    jae         .lend1

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
    jb          .loop2

    ; mov         r15, -1
.mainloop:
                                        ; rax(table_64 + 16 * 256), rbx(in), rcx(256), rsi(bit_stream_end_64), rdx(shifter_64)
; rax(table_64 + 16 * 256), rcx(256), rdx(shifter_64), rbx(in), rsi(bit_stream_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
; rax(?),                   rcx(256), rdx(shifter_64), rbx(in), rsi(bit_stream_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    movzx       eax, byte [rbp - 65640]
    cmp         eax, dword [rbp - 65624]

    jae         .fi3

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
; rax(left_bits_8), rcx(?), rdx(?), rbx(in), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)

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
; rax(left_bits_8), rcx(code_length_32), rdx(current_64 >> (left_bits_8 - code_length_32) & ((1 << code_length_32) - 1)), rbx(code_length_32), rsi((1 << code_length_32) - 1), rdi(?), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(left_bits_8), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi((1 << code_length_32) - 1)

    sub         eax, ebx
                                        ; rax(left_bits_8 - code_length_32), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi((1 << code_length_32) - 1)
    mov         [rbp - 65640], al

    mov         rdi, [rbp - 65608]
    mov         rsi, [rbp - 65584]
    cmp         rsi, rdi
; rax(left_bits_8), rcx(code_length_32), rdx(current_64 >> (left_bits_8 - code_length_32) & ((1 << code_length_32) - 1)), rbx(code_length_32), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(left_bits_8), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi(bit_stream_64), rdi(bit_stream_end_64)
    jne         .fi4

    mov         rcx, rsi
    mov         rdx, [rbp - 65616]
    mov         rbx, [rbp - 65600]

.loop3:
; rax(left_bits_8), rcx(bit_stream_64), rdx(bit_stream_act_end_64), rbx(current_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    cmp         rcx, rdx
                                        ; rax(left_bits_8), rcx(bit_stream_64), rdx(bit_stream_act_end_64), rbx(current_64), rsi(bit_stream_64), rdi(bit_stream_end_64)
    jae         .lend3

    shl         rbx, 8
    or          bl, byte [rcx]
    inc         rcx
    add         rax, 8
                                        ; rax(left_bits_8 + 8), rcx(bit_stream_64 + 1), rdx(bit_stream_act_end_64), rbx((current_64 << 8) | *bit_stream_64), rsi(bit_stream_64), rdi(bit_stream_end_64)
    jmp         .loop3
.lend3:
    mov         [rbp - 65600], rbx
    mov         [rbp - 65584], rcx
    mov         [rbp - 65640], al
; rax(left_bits_8), rcx(bit_stream_64), rdx(bit_stream_act_end_64), rbx(current_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(left_bits_8), rcx(bit_stream_64), rdx(bit_stream_act_end_64), rbx(current_64), rsi(bit_stream_64), rdi(bit_stream_end_64)

.fi4:
;     inc         r15

;     cmp         dword [rbp - 65636], 29990
;     jb          .skip_log

;     push        rax
;     push        rbx
;     push        rcx
;     push        rsi
;     push        rdx
;     push        r15

; ;   printf(counter)
;     lea         rdi, [rel counter]
;     mov         rsi, r15
;     call        printf WRT ..plt

; ;   printf(table_64_info)
;     lea         rdi, [rel table_64_info]
;     lea         rsi, [rbp - 65576]
;     call        printf WRT ..plt

; ;   printf(bit_stream_64_info)
;     lea         rdi, [rel bit_stream_64_info]
;     mov         rsi, [rbp - 65584]
;     call        printf WRT ..plt

; ;   printf(shifter_64_info)
;     lea         rdi, [rel shifter_64_info]
;     mov         rsi, [rbp - 65592]
;     call        printf WRT ..plt

; ;   printf(current_64_info)
;     lea         rdi, [rel current_64_info]
;     mov         rsi, [rbp - 65600]
;     call        printf WRT ..plt

; ;   printf(bit_stream_end_64_info)
;     lea         rdi, [rel bit_stream_end_64_info]
;     mov         rsi, [rbp - 65608]
;     call        printf WRT ..plt

; ;   printf(bit_stream_act_end_64_info)
;     lea         rdi, [rel bit_stream_act_end_64_info]
;     mov         rsi, [rbp - 65616]
;     call        printf WRT ..plt


; ;   printf(ncode_32_info)
;     lea         rdi, [rel ncode_32_info]
;     mov         esi, [rbp - 65620]
;     call        printf WRT ..plt

; ;   printf(code_length_32_info)
;     lea         rdi, [rel code_length_32_info]
;     mov         esi, [rbp - 65624]
;     call        printf WRT ..plt

; ;   printf(old_code_32_info)
;     lea         rdi, [rel old_code_32_info]
;     mov         esi, [rbp - 65628]
;     call        printf WRT ..plt

; ;   printf(code_32_info)
;     lea         rdi, [rel code_32_info]
;     mov         esi, [rbp - 65632]
;     call        printf WRT ..plt

; ;   printf(return_32_info)
;     lea         rdi, [rel return_32_info]
;     mov         esi, [rbp - 65636]
;     call        printf WRT ..plt

; ;   printf(left_bits_8_info)
;     lea         rdi, [rel left_bits_8_info]
;     movzx       esi, byte [rbp - 65640]
;     call        printf WRT ..plt

; ;   printf(delimiter)
;     lea         rdi, [rel delimiter]
;     call        printf WRT ..plt

;     pop         r15
;     pop         rdx
;     pop         rsi
;     pop         rcx
;     pop         rbx
;     pop         rax
;     int3
; .skip_log:
; rax(left_bits_8), rcx(?), rdx(?), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(left_bits_8), rsi(bit_stream_64), rdi(bit_stream_end_64)
    mov         edx, [rbp - 65632]

    cmp         edx, 256
                                        ; rax(left_bits_8), rdx(code_32), rsi(bit_stream_64), rdi(bit_stream_end_64)
; rax(left_bits_8), rcx(?), rdx(code_32), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    jne         .fi5
    mov         dword [rbp - 65620], 258
    mov         dword [rbp - 65624], 9
    mov         dword [rbp - 65628], -1
                                        ; rax(left_bits_8), rdx(code_32), rsi(bit_stream_64), rdi(bit_stream_end_64)
; rax(?), rcx(?), rdx(?), rbx(?), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         rbx, [rbp + 16]
    mov         rcx, 256
    mov         rsi, [rbp - 65608]
    mov         rdx, [rbp - 65592]
; rax(?), rcx(256), rdx(shifter_64), rbx(in), rsi(bit_stream_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jmp         .mainloop

.fi5:
    cmp         edx, 257
                                        ; rax(left_bits_8), rdx(code_32), rsi(bit_stream_64), rdi(bit_stream_end_64)
    je          .mlend
.else:
    cmp         dword [rbp - 65628], -1
                                        ; rax(left_bits_8), rdx(code_32), rsi(bit_stream_64), rdi(bit_stream_end_64)
; rax(left_bits_8), rcx(?), rdx(code_32), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    jne         .fi6
    lea         rbx, [rbp - 65576]
    mov         rcx, rdx

    xchg        rax, rcx
; rax(code_32), rcx(left_bits_8), rdx(code_32), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    push        rdx
    mov         r10, 16
    mul         r10
    pop         rdx
    xchg        rax, rcx
; rax(left_bits_8), rcx(code_32 * 16), rdx(code_32), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)

    lea         rsi, [rbx + rcx]
    movzx       ecx, word [rsi + 14]

    cmp         ecx, 14

; rax(left_bits_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(&table_64[code_32]), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    jbe         .fi_not_small_obj
    mov         rsi, [rsi]
                                        ; rax(left_bits_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(*(uint8_t**)table_64[code_32]), rdi(bit_stream_end_64)
.fi_not_small_obj:
                                        ; rax(left_bits_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(bit_stream_end_64)
    mov         rax, [rbp + 32]
    lea         rdi, [rsi + rcx]
                                        ; rax(out), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(src + len)
.loop4:
; rax(out), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(src + len_16), r10(?), r11(?), r12(?), r13(?)
    movzx       ebx, byte [rsi]
    mov         [rax], rbx
    inc         rax
    inc         rsi
    cmp         rsi, rdi
    jb          .loop4

    mov         [rbp + 32], rax
    add         [rbp - 65636], ecx
; rax(out), rcx(len_16), rdx(code_32), rbx(*src), rsi(src + len_16), rdi(src + len_16), r10(?), r11(?), r12(?), r13(?)
    jmp         .fiend
                                        ; rax(out), rcx(len), rdx(code_32), rbx(src[len]), rsi(src + len), rdi(src + len)

.fi6:
    cmp         edx, [rbp - 65620]
; rax(left_bits_8), rcx(?), rdx(code_32), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    jae         .fi7
    mov         r10d, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    mov         eax, r10d
; rax(old_code_32), rcx(?), rdx(code_32), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(old_code_32), r11(?), r12(?), r13(?)
    push        rdx
    mov         r11, 16
    mul         r11
    add         rax, rbx
    movzx       r11d, word [rax + 14]
; rax(&table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    mov         eax, [rbp - 65620]
    mov         rcx, 16
    mul         rcx
    pop         rdx
; rax(ncode_32 * 16), rcx(?), rdx(code_32), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    add         rax, rbx

    cmp         r11w, 14
; rax(&table_64[ncode_32]), rcx(?), rdx(code_32), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    jae         .else1

    mov         ecx, 16
    mov         r13, rdx
    mov         rdi, rax
    mov         rax, r10
    mov         r12, 16
    mul         r12
    add         rax, rbx
    mov         rsi, rax
; rax(&table_64[old_code_32]), rcx(16), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&table_64[ncode_32]), r10(old_code_32), r11(table_64[old_code_32].len), r12(16), r13(code_32)
    rep movsb
    sub         rdi, 16
    sub         rsi, 16
    add         word [rdi + 14], 1
                                        ; rax(?), rcx(16), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
; rax(&table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
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
                                        ; rax(out - old_code_len_16), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)

.fi8:
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         rax, r13
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    movzx       r12, word [rax + 14]
    cmp         r12, 14
    jbe         .fi9
    mov         rax, [rax]
.fi9:
; rax(src), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)

    xor         ecx, ecx
    mov         rsi, rax
    mov         rax, [rbp + 32]
.loop5:
; rax(out), rcx(0), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         dl, [rsi + rcx]
    mov         [rax], dl
    inc         rcx
    inc         rax
    cmp         rcx, r12
; rax(out + 1), rcx(0 + 1), dl(src[i]), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jb          .loop5
; rax(out + len_16), rcx(len_16), dl(src[len_16]), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         [rbp + 32], rax
    add         [rbp - 65636], r12d
; rax(out), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    cmp         r11, 14
; rax(out), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jae         .fi10
    movzx       eax, byte [rsi]
    mov         [rdi + r11], al
; rax(*src), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
.fi10:
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      rcx, rax
    cmp         rcx, 1
; rax(ncode_32 + 2), rcx(popcnt(ncode_32 + 2)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jne         .fi11
    add         dword [rbp - 65624], 1
.fi11:
; rax(ncode_32 + 2), rcx(popcnt(ncode_32 + 2)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    dec         rax
    mov         [rbp - 65620], eax
; rax(ncode_32), rcx(popcnt(ncode_32 + 1)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jmp         .fiend
.fi7:
; rax(left_bits_8), rcx(?), rdx(code_32), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    mov         eax, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    mov         r13, rdx
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    movzx       r11d, word [rax + 14]
    mov         eax, [rbp - 65620]
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
; rax(&next), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(old_code_len_16), r12(?), r13(code_32)

    mov         rdi, rax
    mov         r10d, [rbp - 65628]
    cmp         r11w, 14
; rax(&next_64), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
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
; al(next_64[0]), rcx(?), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jmp         .fi12
.else2:
; rax(&next_64), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         eax, r11d
    inc         eax
    mov         word [rdi + 14], ax
    dec         eax
    neg         rax
    add         rax, [rbp + 32]
    mov         [rdi], rax
; rax(out - old_code_len_16), rcx(?), rdx(?), rbx(table_64), rsi(bit_stream_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
.fi12:
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)

    mov         eax, r10d
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
                                        ; rax(& table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(src), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         rsi, rax
    movzx       eax, word [rsi + 14]

    cmp         eax, 14
; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jbe         .fi13
    mov         rsi, [rsi]
.fi13:
; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         r12, rax
    mov         rax, [rbp + 32]
    xor         ecx, ecx
.loop6:
; rax(out), rcx(0), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         dl, [rsi + rcx]
    mov         [rax], dl
    inc         ecx
    inc         rax
    cmp         rcx, r12
; rax(out + 1), rcx(0 + 1), dl(src[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jb          .loop6

    mov         dl, [rsi]
    mov         [rax], dl
    inc         rax
    mov         [rbp + 32], rax
    lea         rax, [r12 + 1]
; rax(len_16 + 1), rcx(len_16), dl(src[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    add         [rbp - 65636], eax
    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      ecx, eax
    cmp         ecx, 1
; rax(ncode_32 + 2), rcx(popcnt(ncode_32 + 2)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jne         .fi14
    add         dword [rbp - 65624], 1
.fi14:
; rax(ncode_32 + 2), rcx(popcnt(ncode_32 + 2)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    dec         rax
    mov         [rbp - 65620], eax
; rax(ncode_32), rcx(popcnt(ncode_32 + 1)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
.fiend:
; rax(?), rcx(?), rdx(?), rbx(?), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         eax, [rbp - 65632]
    mov         [rbp - 65628], eax
    mov         ecx, 256
    mov         rdx, [rbp - 65592]
    mov         rbx, [rbp + 16]
    mov         rsi, [rbp - 65608]
; rax(?), rcx(256), rdx(shifter_64), rbx(in), rsi(bit_stream_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jmp         .mainloop
.mlend:
    ; rax(left_bits_8), rcx(?), rdx(code_32), rbx(?), rsi(bit_stream_64), rdi(bit_stream_end_64), r10(?), r11(?), r12(?), r13(?)
    mov         r13d, [rbp - 65636]


    add  rsp, 4
    add  rsp, 4
    add  rsp, 4
    add  rsp, 4
    add  rsp, 4
    add  rsp, 4

    pop  rax
    pop  rax
    pop  rax
    pop  rax
    pop  rax

    add rsp, 65536
; >>>

    mov eax, r13d

    ; pop r15
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx


    pop rbp
    ret