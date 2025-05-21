.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib

.DATA
; variables initialisees
inputString db "abcbacacbca", 0 

.DATA?
; variables non-initialisees (bss)

.CODE
start:
	; on reserve dans la pile (local) la place pour stocker les variables

	push ebp
	mov ebp, esp
	; 3 variables locales : countA, countB, countC, donc 3*4
	sub esp, 12 

	mov dword ptr [ebp-4], 0    ; countA
    mov dword ptr [ebp-8], 0    ; countB
    mov dword ptr [ebp-12], 0   ; countC

	lea esi, inputString

	next_char:
    mov al, [esi]           ; lire caractère courant
    cmp al, 0               ; fin de chaîne ?
    je fin

    cmp al, 'a'
    jne check_b
    ; c'est un 'a'
    mov eax, [ebp-4]
    inc eax
    mov [ebp-4], eax
    jmp advance

    check_b:
        cmp al, 'b'
        jne check_c
        ; c'est un 'b'
        mov eax, [ebp-8]
        inc eax
        mov [ebp-8], eax
        jmp advance

    check_c:
        cmp al, 'c'
        jne advance
        ; c'est un 'c'
        mov eax, [ebp-12]
        inc eax
        mov [ebp-12], eax

    advance:
        inc esi
        jmp next_char

    fin:
        ; copier les résultats dans eax, ebx, ecx
        mov eax, [ebp-4]     ; nombre de 'a'
        mov ebx, [ebp-8]     ; nombre de 'b'
        mov ecx, [ebp-12]    ; nombre de 'c'

	mov esp, ebp
	pop ebp

	invoke	ExitProcess,eax

end start