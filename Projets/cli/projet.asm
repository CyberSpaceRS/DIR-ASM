.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
; Chaînes de caractères constantes
pathSuffix   db  "\*", 0
dot          db  ".", 0
ddot         db  "..", 0
pathFormat   db  "%s\%s", 0
errStr       db  "Error, stopping program...", 13,10, 0
pauseStr     db  "pause", 13,10, 0
clearStr     db  "cls", 13,10, 0
scanfStr     db  "%s", 0
promtStr     db  "Path:", 13,10, ">>>", 0
printFormat  db  "%s", 13,10, 0

; Chaînes d'affichage
tabIndent    db  "    ", 0
fileStr      db 0F0h,09Fh,093h,084h,0        ; 📄 UTF-8
dirStr       db 0F0h,09Fh,093h,081h,0        ; 📁 UTF-8
formatStr    db  "%s %s",13,10,0

; Chemins de test
defaultPath  db ".", 0
projectPath  db "C:\Users\trist\Desktop\Projet", 0

.DATA?
depth        DWORD ?

.CODE

list PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 842

	inc		depth

	push 	MAX_PATH
	push 	[ebp + 8]
	lea 	ebx, [ebp - 578]
	push	ebx
	call	crt_strncpy

	push	MAX_PATH
	push	offset pathSuffix
	push	ebx
	call	crt_strncat

	lea		ebx, [ebp - 318]
	push 	ebx
	sub		ebx, MAX_PATH
	push	ebx
	call	FindFirstFile
	mov		[ebp - 582], eax
	cmp 	eax, INVALID_HANDLE_VALUE
	jne		no_error

	push	offset errStr
	call	crt_printf
	jmp 	error

no_error:
do:
	lea		ebx, [ebp - 318]
	add 	ebx, 44
	push	ebx
	push 	offset dot
	call 	crt_strcmp
	add		esp, 8
	cmp 	eax, NULL
	je		skip

	push	ebx
	push	offset ddot
	call 	crt_strcmp
	add		esp, 8
	cmp 	eax, NULL
	je		skip

	push 	[ebp - 318]
	lea		ebx, [ebp - 318]
	add 	ebx, 44
	push	ebx
	call	print
	add		esp, 8

	lea		ebx, [ebp - 318]
	cmp 	DWORD PTR [ebx], FILE_ATTRIBUTE_DIRECTORY
	jne 	nodir

	lea		ebx, [ebp - 318]
	add 	ebx, 44
	push	ebx
	push	[ebp + 8]
	push 	offset pathFormat
	lea		ebx, [ebp - 842]
	push	ebx
	call	crt_sprintf
	add		esp, 16

	push 	ebx
	call	list

nodir:
skip:
	lea		ebx, [ebp - 318]
	push 	ebx
	push 	[ebp - 582]
	call	FindNextFile
	cmp 	eax, NULL
	jne		do

error:
	dec		depth
	mov		esp, ebp
	pop		ebp
	ret
list ENDP

print PROC
	push	ebp
	mov		ebp, esp

	mov		ecx, depth
next:
	push 	ecx
	push 	offset tabIndent
	call 	crt_printf
	add 	esp, 4
	pop 	ecx
	loop 	next

	mov 	edx, offset fileStr
	cmp 	DWORD PTR [ebp + 12], FILE_ATTRIBUTE_DIRECTORY
	jne 	file
	mov 	edx, offset dirStr
file:

	push	[ebp + 8]
	push	edx
	push	offset formatStr
	call	crt_printf

	mov		esp, ebp
	pop		ebp
	ret
print ENDP

start:
	sub		esp, MAX_PATH
	mov 	depth, 0

	; Force la console en UTF-8 pour afficher les emojis
	push	65001
	call	SetConsoleOutputCP

	push	offset promtStr
	call	crt_printf

	lea 	ebx, [ebp - MAX_PATH]
	push	ebx
	push	offset scanfStr
	call	crt_scanf
	add		esp, 8

	push	offset clearStr
	call	crt_system

	push	ebx
	push	offset printFormat
	call	crt_printf

	push	ebx
	call	list

	push	offset pauseStr
	call	crt_system

	xor		eax, eax
	push	eax
	call	ExitProcess
end start

