.386
.model flat,stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib

.data
chaine     db "tristan en assembleur", 0
fmtAffiche db "Resultat : %s", 10, 0

.code

majuscule proc
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]

loop_maj:
    mov al, [esi]
    cmp al, 0
    je fin_maj
    cmp al, 'a'
    jl next_maj
    cmp al, 'z'
    jg next_maj
    sub al, 32
    mov [esi], al

next_maj:
    inc esi
    jmp loop_maj

fin_maj:
    pop ebp
    ret
majuscule endp

start:
    push offset chaine
    call majuscule

    push offset chaine
    push offset fmtAffiche
    call crt_printf
    add esp, 8

    invoke ExitProcess, 0
end start
