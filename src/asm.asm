section .data

                 counter: db "%i", 10, 0
           table_64_info: db "           table_64_info: %p", 10, 0
          bs_ptr_64_info: db "          bs_ptr_64_info: %p", 10, 0
start_by_copying_64_info: db "start_by_copying_64_info: %zu", 10, 0
     bs_cur_data_64_info: db "     bs_cur_data_64_info: %lx", 10, 0
     bs_body_end_64_info: db "     bs_body_end_64_info: %p", 10, 0
   bs_actual_end_64_info: db "   bs_actual_end_64_info: %p", 10, 0

       next_code_32_info: db "       next_code_32_info: %i", 10, 0
     code_length_32_info: db "     code_length_32_info: %i", 10, 0
        old_code_32_info: db "        old_code_32_info: %i", 10, 0
            code_32_info: db "            code_32_info: %i", 10, 0
          result_32_info: db "          result_32_info: %i", 10, 0

     bs_bits_left_8_info: db "     bs_bits_left_8_info: %hhu", 10, 0

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
;      uint64_t           bs_ptr_64
;        size_t           start_by_copying_64
;      uint64_t           bs_cur_data_64
;      uint8_t*           bs_body_end_64
;      uint8_t*           bs_actual_end_64
;
;           int           next_code_32
;           int           code_length_32
;           int           old_code_32
;           int           code_32
;           int           result_32
;
;       uint8_t           bs_bits_left_8
;

    sub rsp, 65536          ; table_64            = rbp - 8 * 5 - (4096 * 16) = rbp - 65576

    
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
    push rax                ; bs_ptr_64           =            table_64 - 8   = rbp - 65584
    
    push rax                ; start_by_copying_64 =           bs_ptr_64 - 8   = rbp - 65592
    push rax                ; bs_cur_data_64      = start_by_copying_64 - 8   = rbp - 65600
    push rax                ; bs_body_end_64      =      bs_cur_data_64 - 8   = rbp - 65608
    push rax                ; bs_actual_end_64    =      bs_body_end_64 - 8   = rbp - 65616

    sub  rsp, 4             ; next_code_32        =    bs_actual_end_64 - 4   = rbp - 65620
    sub  rsp, 4             ; code_length_32      =        next_code_32 - 4   = rbp - 65624
    sub  rsp, 4             ; old_code_32         =      code_length_32 - 4   = rbp - 65628
    sub  rsp, 4             ; code_32             =         old_code_32 - 4   = rbp - 65632
    sub  rsp, 4             ; result_32           =             code_32 - 4   = rbp - 65636
    sub  rsp, 4             ; bs_bits_left_8      =           result_32 - 4   = rbp - 65640
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
; rax(bs_ptr_64 - in), rcx(in_size), rdx(?), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jbe         .fi1
    mov         rax, rcx
.fi1:
; rax(?start_by_copying_64), rcx(in_size), rdx(?), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         rdx, rax
    mov         [rbp - 65592], rax

; rax(start_by_copying_64), rcx(in_size), rdx(start_by_copying_64), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    push        rdx
    mov         r10, 8
    mul         r10
    pop         rdx
    mov         [rbp - 65640], al       ; bs_bits_left = start_by_copying * 8;

; rax(bs_bits_left_8), rcx(in_size), rdx(start_by_copying_64), rbx(in), rsi(in), rdi(?), r10(?), r11(?), r12(?), r13(?)
    xor         eax, eax
    xor         ecx, ecx
loop1:
    cmp         rcx, rdx
    jae         .lend1

    shl         rax, 8
    or          rax, [rsi + rcx]              ; bs_cur_data_64 << 8 | in[b];

    inc         rcx
    jmp         loop1
.lend1:
    mov         [rbp - 65600], rax

    add         rsi, [rbp + 24]          ; rsi = in + in_size
    mov         rcx, rsi                ; rcx = in + in_size
    mov         eax, 3                  ; rax = 3
    not         rax                     ; rax = ~3
    and         rsi, rax                ; rsi = (in + in_size) & ~3
    mov         [rbp - 65608], rsi

    mov         [rbp - 65616], rcx

    ; End of initializing bit_stream

    mov         dword [rbp - 65620], 258
    mov         dword [rbp - 65624], 9
    mov         dword [rbp - 65628], -2
    mov         dword [rbp - 65636], 0

    lea         rax, [rbp - 65576]         ; rax = &table_64[0]
    xor         ecx, ecx                ; rcx = 0
.loop2:
    mov         word [rax + 14], 1      ; table_64[i].len = (uint16_t)1;
    mov         [rax], cl               ; table_64[i].data.str[0] = (uint8_t)i;

    add         rax, 16
    inc         rcx

    cmp         rcx, 256                ; i < 256
    jb          .loop2
    
    ; mov         r15, -1
.mainloop:
                                        ; rax(table_64 + 16 * 256), rbx(in), rcx(256), rsi(bs_body_end_64), rdx(start_by_copying_64)
; rax(table_64 + 16 * 256), rcx(256), rdx(start_by_copying_64), rbx(in), rsi(bs_body_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
; rax(?),                   rcx(256), rdx(start_by_copying_64), rbx(in), rsi(bs_body_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    movzx       eax, byte [rbp - 65640]
    cmp         eax, dword [rbp - 65624]      ; bs_bits_left_8 < code_length_32
                                        ; rax(bs_bits_left_8), rbx(in), rcx(256), rsi(bs_body_end_64), rdx(start_by_copying_64)
    jae         .fi3

    mov         rsi, [rbp - 65584]
    mov         rdx, [rbp - 65600]
    movbe       ecx, [rsi]                 ; next = __builtin_bswap32( *(uint32_t*)bs_ptr_64 );
    add         rsi, 4
    shl         rdx, 32                    ; bs_cur_data_64 << 32
    or          rdx, rcx                   ; (bs_cur_data_64 << 32) | next
    add         al, 32                  ; bs_bits_left_8 += 32;
    mov         [rbp - 65640], al       ; bs_bits_left_8 += 32;
    mov         [rbp - 65584], rsi           ; bs_ptr_64 += 4;
    mov         [rbp - 65600], rdx      ; (bs_cur_data_64 << 32) | next
.fi3:
; rax(bs_bits_left_8), rcx(?), rdx(?), rbx(in), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)

    mov         ecx, [rbp - 65624]
    mov         rdx, [rbp - 65600]
    mov         ebx, ecx
    neg         ecx
    add         ecx, eax                ; (bs_bits_left_8 - code_length_32)
    shr         rdx, cl                 ; bs_cur_data_64 >> (bs_bits_left_8 - code_length_32)
    mov         ecx, ebx
    mov         esi, 1
    shl         esi, cl                 ; (1 << code_length_32)
    dec         esi                     ; ((1 << code_length_32) - 1)
    and         rdx, rsi
                                        ; rax(bs_bits_left_8), rcx(code_length_32), rdx((bs_cur_data_64 >> (bs_bits_left_8 - code_length_32)) & ((1 << code_length_32) - 1)), rbx(code_length_32), rsi((1 << code_length_32) - 1)
    mov         [rbp - 65632], edx
; rax(bs_bits_left_8), rcx(code_length_32), rdx(bs_cur_data_64 >> (bs_bits_left_8 - code_length_32) & ((1 << code_length_32) - 1)), rbx(code_length_32), rsi((1 << code_length_32) - 1), rdi(?), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(bs_bits_left_8), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi((1 << code_length_32) - 1)

    sub         eax, ebx
                                        ; rax(bs_bits_left_8 - code_length_32), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi((1 << code_length_32) - 1)
    mov         [rbp - 65640], al    ; bs_bits_left_8 -= code_length_32;

    mov         rdi, [rbp - 65608]
    mov         rsi, [rbp - 65584]
    cmp         rsi, rdi                ; if (bs_ptr_64 == bs_body_end_64)
; rax(bs_bits_left_8), rcx(code_length_32), rdx(bs_cur_data_64 >> (bs_bits_left_8 - code_length_32) & ((1 << code_length_32) - 1)), rbx(code_length_32), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(bs_bits_left_8), rcx(code_length_32), rdx(code_32), rbx(code_length_32), rsi(bs_ptr_64), rdi(bs_body_end_64)
    jne         .fi4

    mov         rcx, rsi                ; rcx = bs_ptr_64
    mov         rdx, [rbp - 65616]
    mov         rbx, [rbp - 65600]

.loop3:
; rax(bs_bits_left_8), rcx(bs_ptr_64), rdx(bs_actual_end_64), rbx(bs_cur_data_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    cmp         rcx, rdx                ; while (bs_ptr < bs_actual_end)
                                        ; rax(bs_bits_left_8), rcx(bs_ptr_64), rdx(bs_actual_end_64), rbx(bs_cur_data_64), rsi(bs_ptr_64), rdi(bs_body_end_64)
    jae         .lend3

    shl         rbx, 8
    or          bl, byte [rcx]              ; (bs_cur_data_64 << 8) | *bs_ptr_64
    inc         rcx                     ; bs_ptr_64++
    add         rax, 8
                                        ; rax(bs_bits_left_8 + 8), rcx(bs_ptr_64 + 1), rdx(bs_actual_end_64), rbx((bs_cur_data_64 << 8) | *bs_ptr_64), rsi(bs_ptr_64), rdi(bs_body_end_64)
    jmp         .loop3
.lend3:
    mov         [rbp - 65600], rbx
    mov         [rbp - 65584], rcx
    mov         [rbp - 65640], al
; rax(bs_bits_left_8), rcx(bs_ptr_64), rdx(bs_actual_end_64), rbx(bs_cur_data_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(bs_bits_left_8), rcx(bs_ptr_64), rdx(bs_actual_end_64), rbx(bs_cur_data_64), rsi(bs_ptr_64), rdi(bs_body_end_64)

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

; ;   printf(bs_ptr_64_info)
;     lea         rdi, [rel bs_ptr_64_info]
;     mov         rsi, [rbp - 65584]
;     call        printf WRT ..plt

; ;   printf(start_by_copying_64_info)
;     lea         rdi, [rel start_by_copying_64_info]
;     mov         rsi, [rbp - 65592]
;     call        printf WRT ..plt

; ;   printf(bs_cur_data_64_info)
;     lea         rdi, [rel bs_cur_data_64_info]
;     mov         rsi, [rbp - 65600]
;     call        printf WRT ..plt

; ;   printf(bs_body_end_64_info)
;     lea         rdi, [rel bs_body_end_64_info]
;     mov         rsi, [rbp - 65608]
;     call        printf WRT ..plt

; ;   printf(bs_actual_end_64_info)
;     lea         rdi, [rel bs_actual_end_64_info]
;     mov         rsi, [rbp - 65616]
;     call        printf WRT ..plt


; ;   printf(next_code_32_info)
;     lea         rdi, [rel next_code_32_info]
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

; ;   printf(result_32_info)
;     lea         rdi, [rel result_32_info]
;     mov         esi, [rbp - 65636]
;     call        printf WRT ..plt

; ;   printf(bs_bits_left_8_info)
;     lea         rdi, [rel bs_bits_left_8_info]
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
; rax(bs_bits_left_8), rcx(?), rdx(?), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
                                        ; rax(bs_bits_left_8), rsi(bs_ptr_64), rdi(bs_body_end_64)
    mov         edx, [rbp - 65632]

    cmp         edx, 256                ; if (code == 256)
                                        ; rax(bs_bits_left_8), rdx(code_32), rsi(bs_ptr_64), rdi(bs_body_end_64)
; rax(bs_bits_left_8), rcx(?), rdx(code_32), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    jne         .fi5
    mov         dword [rbp - 65620], 258
    mov         dword [rbp - 65624], 9
    mov         dword [rbp - 65628], -1
                                        ; rax(bs_bits_left_8), rdx(code_32), rsi(bs_ptr_64), rdi(bs_body_end_64)
; rax(?), rcx(?), rdx(?), rbx(?), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         rbx, [rbp + 16]
    mov         rcx, 256
    mov         rsi, [rbp - 65608]
    mov         rdx, [rbp - 65592]
; rax(?), rcx(256), rdx(start_by_copying_64), rbx(in), rsi(bs_body_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jmp         .mainloop

.fi5:
    cmp         edx, 257
                                        ; rax(bs_bits_left_8), rdx(code_32), rsi(bs_ptr_64), rdi(bs_body_end_64)
    je          .mlend
.else:
    cmp         dword [rbp - 65628], -1       ; if (old_code == -1)
                                        ; rax(bs_bits_left_8), rdx(code_32), rsi(bs_ptr_64), rdi(bs_body_end_64)
; rax(bs_bits_left_8), rcx(?), rdx(code_32), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    jne         .fi6
    lea         rbx, [rbp - 65576]
    mov         rcx, rdx

    xchg        rax, rcx
; rax(code_32), rcx(bs_bits_left_8), rdx(code_32), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    push        rdx
    mov         r10, 16    
    mul         r10
    pop         rdx
    xchg        rax, rcx
; rax(bs_bits_left_8), rcx(code_32 * 16), rdx(code_32), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)

    lea         rsi, [rbx + rcx]        ; src = (uint8_t*)&table[code];
    movzx       ecx, word [rsi + 14]    ; len = table[code].len;

    cmp         ecx, 14                 ; if (len > 14) 

; rax(bs_bits_left_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(&table_64[code_32]), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    jbe         .fi_not_small_obj
    mov         rsi, [rsi]
                                        ; rax(bs_bits_left_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(*(uint8_t**)table_64[code_32]), rdi(bs_body_end_64)
.fi_not_small_obj:
                                        ; rax(bs_bits_left_8), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(bs_body_end_64)    
    mov         rax, [rbp + 32]
    lea         rdi, [rsi + rcx]
                                        ; rax(out), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(src + len)
.loop4:
; rax(out), rcx(len_16), rdx(code_32), rbx(table_64), rsi(src), rdi(src + len_16), r10(?), r11(?), r12(?), r13(?)
    movzx       ebx, byte [rsi]
    mov         [rax], rbx              ; *out = src[i];
    inc         rax                     ; out++;
    inc         rsi
    cmp         rsi, rdi
    jb          .loop4

    mov         [rbp + 32], rax
    add         [rbp - 65636], ecx        ; result += len;
; rax(out), rcx(len_16), rdx(code_32), rbx(*src), rsi(src + len_16), rdi(src + len_16), r10(?), r11(?), r12(?), r13(?)
    jmp         .fiend
                                        ; rax(out), rcx(len), rdx(code_32), rbx(src[len]), rsi(src + len), rdi(src + len)

.fi6: ; if (code < next_code)
    cmp         edx, [rbp - 65620]
; rax(bs_bits_left_8), rcx(?), rdx(code_32), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    jae         .fi7
    mov         r10d, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    mov         eax, r10d
; rax(old_code_32), rcx(?), rdx(code_32), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(old_code_32), r11(?), r12(?), r13(?)
    push        rdx
    mov         r11, 16
    mul         r11
    add         rax, rbx
    movzx       r11d, word [rax + 14]
; rax(&table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    mov         eax, [rbp - 65620]
    mov         rcx, 16
    mul         rcx
    pop         rdx
; rax(next_code_32 * 16), rcx(?), rdx(code_32), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    add         rax, rbx

    cmp         r11w, 14                ; if (old_code_len < 14)
; rax(&table_64[next_code_32]), rcx(?), rdx(code_32), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(old_code_32), r11(table_64[old_code_32].len), r12(?), r13(?)
    jae         .else1

    mov         ecx, 16
    mov         r13, rdx
    mov         rdi, rax
    mov         rax, r10
    mov         r12, 16
    mul         r12
    add         rax, rbx
    mov         rsi, rax
; rax(&table_64[old_code_32]), rcx(16), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&table_64[next_code_32]), r10(old_code_32), r11(table_64[old_code_32].len), r12(16), r13(code_32)
    rep movsb                           ; next = table[old_code];
    sub         rdi, 16
    sub         rsi, 16
    add         word [rdi + 14], 1      ; next.len++;
                                        ; rax(?), rcx(16), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
; rax(&table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jmp         .fi8
.else1:
    mov         r13, rdx
    mov         rdi, rax
    inc         r11
    mov         [rdi + 14], r11w   ; next.len = old_code_len + 1;
    dec         r11
    mov         eax, r11d
    neg         rax
    add         rax, [rbp + 32]
    mov         [rdi], rax              ; next.data.ptr = out - old_code_len;
                                        ; rax(out - old_code_len_16), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)

.fi8: ; write(get(code))
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         rax, r13
    mov         rdx, 16
    mul         rdx
    add         rax, rbx                ; rax = src
    movzx       r12, word [rax + 14]    ; r12 = len
    cmp         r12, 14                 ; if (len > 14)
    jbe         .fi9
    mov         rax, [rax]
.fi9:
; rax(src), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)

    xor         ecx, ecx
    mov         rsi, rax
    mov         rax, [rbp + 32]
.loop5:
; rax(out), rcx(0), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         dl, [rsi + rcx]         ; dl = src[i]
    mov         [rax], dl               ; *out = src[i];
    inc         rcx
    inc         rax
    cmp         rcx, r12
; rax(out + 1), rcx(0 + 1), dl(src[i]), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jb          .loop5
; rax(out + len_16), rcx(len_16), dl(src[len_16]), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         [rbp + 32], rax
    add         [rbp - 65636], r12d        ; result += len;    
; rax(out), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    cmp         r11, 14                ; if (old_code_len < 14)
; rax(out), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jae         .fi10
    movzx       eax, byte [rsi]
    mov         [rdi + r11], al        ; next.data.str[old_code_len] = *src;
; rax(*src), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
.fi10:
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      rcx, rax
    cmp         rcx, 1                  ; if (__builtin_popcount(next_code + 1) == 1)
; rax(next_code_32 + 2), rcx(popcnt(next_code_32 + 2)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jne         .fi11
    add         dword [rbp - 65624], 1 ; code_length++;
.fi11:
; rax(next_code_32 + 2), rcx(popcnt(next_code_32 + 2)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    dec         rax
    mov         [rbp - 65620], eax     ; next_code++;
; rax(next_code_32), rcx(popcnt(next_code_32 + 1)), rdx(?), rbx(table_64), rsi(src), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jmp         .fiend
.fi7:
; rax(bs_bits_left_8), rcx(?), rdx(code_32), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
    mov         eax, [rbp - 65628]
    lea         rbx, [rbp - 65576]
    mov         r13, rdx
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    movzx       r11d, word [rax + 14]   ; old_code_len = table[old_code].len;
    mov         eax, [rbp - 65620]
    mov         rdx, 16
    mul         rdx
    add         rax, rbx                ; entry next;
; rax(&next), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(old_code_len_16), r12(?), r13(code_32)

    mov         rdi, rax
    mov         r10d, [rbp - 65628]
    cmp         r11w, 14                ; if (old_code_len < 14)
; rax(&next_64), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jae         .else2
    mov         ecx, 16
    mov         rax, r10
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
    mov         rsi, rax
    rep movsb                           ; next = table[old_code];
    sub         rdi, 16
    sub         rsi, 16
    add         word [rdi + 14], 1      ; next.len++;
    mov         al, [rdi]
    mov         [rdi + r11], al
; al(next_64[0]), rcx(?), rdx(?), rbx(table_64), rsi(&table_64[old_code_32]), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jmp         .fi12
.else2:
; rax(&next_64), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         eax, r11d
    inc         eax
    mov         word [rdi + 14], ax     ; next.len = old_code_len + 1;
    dec         eax
    neg         rax
    add         rax, [rbp + 32]
    mov         [rdi], rax              ; next.data.ptr = out - old_code_len;
; rax(out - old_code_len_16), rcx(?), rdx(?), rbx(table_64), rsi(bs_ptr_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
.fi12:
; rax(?), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)

    mov         eax, r10d
    mov         rdx, 16
    mul         rdx
    add         rax, rbx
                                        ; rax(& table_64[old_code_32]), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(src), rcx(?), rdx(?), rbx(table_64), rsi(?), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         rsi, rax
    movzx       eax, word [rsi + 14]    ; len = table[old_code].len;

    cmp         eax, 14                 ; if (len > 14)
; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    jbe         .fi13
    mov         rsi, [rsi]              ; src = *((uint8_t**)src);
.fi13:
; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
                                        ; rax(len_16), rcx(?), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(?), r13(code_32)
    mov         r12, rax
    mov         rax, [rbp + 32]
    xor         ecx, ecx
.loop6:
; rax(out), rcx(0), rdx(?), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    mov         dl, [rsi + rcx]
    mov         [rax], dl               ; *out = src[i];
    inc         ecx
    inc         rax
    cmp         rcx, r12
; rax(out + 1), rcx(0 + 1), dl(src[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jb          .loop6
    
    mov         dl, [rsi]
    mov         [rax], dl               ; *out = src[0];
    inc         rax                     ; out++;
    mov         [rbp + 32], rax
    lea         rax, [r12 + 1]
; rax(len_16 + 1), rcx(len_16), dl(src[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    add         [rbp - 65636], eax        ; result += len + 1;
    mov         eax, [rbp - 65620]
    add         eax, 2
    popcnt      ecx, eax
    cmp         ecx, 1
; rax(next_code_32 + 2), rcx(popcnt(next_code_32 + 2)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    jne         .fi14
    add         dword [rbp - 65624], 1; if (__builtin_popcount(next_code + 1) == 1) code_length++;    
.fi14:
; rax(next_code_32 + 2), rcx(popcnt(next_code_32 + 2)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
    dec         rax
    mov         [rbp - 65620], eax
; rax(next_code_32), rcx(popcnt(next_code_32 + 1)), dl(src_64[0]), rbx(table_64), rsi(src_64), rdi(&next_64), r10(old_code_32), r11(old_code_len_16), r12(len_16), r13(code_32)
.fiend:
; rax(?), rcx(?), rdx(?), rbx(?), rsi(?), rdi(?), r10(?), r11(?), r12(?), r13(?)
    mov         eax, [rbp - 65632]
    mov         [rbp - 65628], eax      ; old_code = code;
    mov         ecx, 256
    mov         rdx, [rbp - 65592]
    mov         rbx, [rbp + 16]
    mov         rsi, [rbp - 65608]
; rax(?), rcx(256), rdx(start_by_copying_64), rbx(in), rsi(bs_body_end_64), rdi(?), r10(?), r11(?), r12(?), r13(?)
    jmp         .mainloop
.mlend:
    ; rax(bs_bits_left_8), rcx(?), rdx(code_32), rbx(?), rsi(bs_ptr_64), rdi(bs_body_end_64), r10(?), r11(?), r12(?), r13(?)
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