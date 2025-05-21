.386
.model flat,stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib

.data
msgEntree    db "Entrez un entier positif : ", 0
fmtEntier    db "%d", 0
fmtResultat  db "La factorielle de %d est : %d", 10, 0
msgErreur    db "Erreur : entier invalide (<= 0).", 10, 0

.data?
n     dd ?
res   dd ?

.code

factorielle proc
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]     ; Charger n
    cmp eax, 1
    jbe finBase            ; Si n <= 1, retourne 1

    dec eax
    push eax
    call factorielle
    mov ecx, eax           ; Stocker le résultat

    mov eax, [ebp + 8]     ; Recharger n
    mul ecx                ; eax = n * (n - 1)!
    jmp finRetour

finBase:
    mov eax, 1

finRetour:
    pop ebp
    ret 4
factorielle endp

start:
    ; Affichage message
    push offset msgEntree
    call crt_printf
    add esp, 4

    ; Lecture entier
    push offset n
    push offset fmtEntier
    call crt_scanf
    add esp, 8

    cmp eax, 1
    jne afficherErreur
    cmp n, 1
    jl afficherErreur

    ; Appel factorielle(n)
    mov eax, n
    push eax
    call factorielle
    mov res, eax

    ; Affichage résultat
    push res
    push n
    push offset fmtResultat
    call crt_printf
    add esp, 12

    invoke ExitProcess, 0

afficherErreur:
    push offset msgErreur
    call crt_printf
    add esp, 4
    invoke ExitProcess, 1

end start
