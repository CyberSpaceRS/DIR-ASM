.386
.model flat,stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib

.data
maChaine     db "combien de lettres ici ?", 0         ; chaîne à analyser (logiquement 24)
fmtAffiche   db "Longueur : %d", 10, 0                ; format printf pour afficher la longueur

.code

; Sous-programme compte
compte proc
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]        ; on récupère l'adresse de la chaîne passée par la pile
    xor ecx, ecx              ; compteur = 0

compte_boucle:
    cmp byte ptr [esi], 0     ; fin de chaîne ?
    je compte_fin
    inc esi                   ; caractère suivant
    inc ecx                   ; on incrémente le compteur
    jmp compte_boucle

compte_fin:
    mov eax, ecx              ; on met le résultat dans eax pour le retour
    pop ebp
    ret
compte endp
; Fin de compte
start:
    push offset maChaine      ; on passe l'adresse de la chaîne par la pile
    call compte               ; appel du sous-programme
    ; EAX contient la longueur

    push eax                  ; printf attend la valeur en paramètre
    push offset fmtAffiche
    call crt_printf
    add esp, 8                ; nettoyage de la pile après printf

    invoke ExitProcess, 0     ; fin du programme
end start
