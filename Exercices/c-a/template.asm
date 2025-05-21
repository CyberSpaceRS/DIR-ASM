.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib

.data
n DWORD 20
i DWORD 3
fmt db "Resultat : %d", 10, 0

.code
start:
    push ebp
    mov ebp, esp
    sub esp, 12 ; j = [ebp-4], k = [ebp-8], l = [ebp-12]

    ; j = 1
    mov eax, 1
    mov [ebp - 4], eax

    ; k = 1
    mov eax, 1
    mov [ebp - 8], eax

    ; i = 3 (déjà dans .data, mais ici on la gère en mémoire)
condition:
    mov eax, i
    cmp eax, n
    ja sortie

    ; l = j + k
    mov eax, [ebp - 4]
    add eax, [ebp - 8]
    mov [ebp - 12], eax

    ; j = k
    mov ebx, [ebp - 8]
    mov [ebp - 4], ebx

    ; k = l
    mov ecx, [ebp - 12]
    mov [ebp - 8], ecx

    ; i++
    inc i
    jmp condition

sortie:
    ; eax = k
    mov eax, [ebp - 8]

    ; Affichage avec printf
    push eax
    push offset fmt
    call crt_printf
    add esp, 8

    ; Fin du programme
    mov esp, ebp
    pop ebp
    invoke ExitProcess, 0

end start
