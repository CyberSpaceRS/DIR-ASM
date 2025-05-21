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
titre db "Les goats de l'assembleur", 0
message db "Tristan & Romain", 0

.DATA?
; variables non-initialisees (bss)

.CODE
start:
	push MB_OK
	push offset message
	push offset titre
	push 0

	call MessageBoxA

	invoke	ExitProcess,eax

end start