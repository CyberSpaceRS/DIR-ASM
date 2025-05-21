.386
.model flat,stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib

.data
fmtInput    db "%d", 0
fmtOutput   db "%d ", 0
msgPrompt   db "Entrez un entier strictement positif : ", 0
msgErreur   db "Erreur : entree invalide.", 10, 0
newline     db 10, 0

.data?
n    dd ?
i    dd ?

.code

start:
    ; Demande de saisie
    push offset msgPrompt
    call crt_printf
    add esp, 4

    ; Lecture (scanf retourne 1 si conversion OK)
    push offset n
    push offset fmtInput
    call crt_scanf
    add esp, 8

    ; Vérification : scanf a bien lu 1 argument ?
    cmp eax, 1
    jne erreur

    ; Vérifie si n <= 0
    mov eax, n
    cmp eax, 0
    jle erreur

    ; Sinon boucle normale
    mov i, 1

boucle:
    mov eax, i
    cmp eax, n
    ja fin

    ; evite division par zéro
    cmp i, 0
    je increment

    mov eax, n
    xor edx, edx
    mov ecx, i
    div ecx           ; EDX = reste
    cmp edx, 0
    jne increment

    ; Affiche le diviseur
    mov eax, i
    push eax
    push offset fmtOutput
    call crt_printf
    add esp, 8

increment:
    inc i
    jmp boucle

fin:
    push offset newline
    call crt_printf
    add esp, 4

    invoke ExitProcess, 0

erreur:
    push offset msgErreur
    call crt_printf
    add esp, 4

    invoke ExitProcess, 1

end start
