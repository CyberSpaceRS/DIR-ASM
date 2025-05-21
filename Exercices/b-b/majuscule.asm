.386
.model flat,stdcall
option casemap:none

include \masm32\include\msvcrt.inc
include \masm32\include\kernel32.inc

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib

.data
maChaine   db "Bonjour tristan et ROMAIN", 0           ; chaine à mettre en majuscule
fmtAffiche db "Retour : %s", 10, 0            ; format d'affichage avec saut de ligne

.code
; Début de la procédure majuscule
majuscule proc
    push ebp                  ; sauvegarde de la base de pile (convention d'appel stdcall)
    mov ebp, esp              ; ebp devient base pour accéder aux arguments

    mov esi, [ebp + 8]        ; récupération de l'adresse de la chaîne passée par la pile

boucle:
    mov al, [esi]             ; lecture du caractère courant
    cmp al, 0                 ; fin de chaîne ?
    je fin                    ; si nul, on sort de la boucle

    cmp al, 'a'               ; est-ce une lettre minuscule ?
    jl suite                  ; si < 'a', ce n'est pas une lettre → on ignore
    cmp al, 'z'
    jg suite                  ; si > 'z', pareil → on ignore

    sub al, 32                ; conversion ASCII minuscule → majuscule
    mov [esi], al             ; on remplace le caractère dans la chaîne

suite:
    inc esi                   ; passage au caractère suivant
    jmp boucle                ; boucle continue

fin:
    pop ebp                   ; restauration de la base de pile
    ret                       ; retour à l'appelant
majuscule endp

;Point d'entrée du programme
start:
    push offset maChaine      ; Passage de l'adresse de la chaîne via la pile (exigé par b-b)
    call majuscule            ; Appel de la routine majuscule

    ; Affichage du résultat avec printf
    push offset maChaine      ; deuxième argument : la chaîne modifiée
    push offset fmtAffiche    ; premier argument : format %s
    call crt_printf           ; appel de printf
    add esp, 8                ; nettoyage de la pile après appel C

    invoke ExitProcess, 0     ; fin du programme proprement
end start
