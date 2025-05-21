.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc
includelib c:\masm32\lib\msvcrt.lib

includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\user32.lib

RGB macro red,green,blue
    xor eax,eax
    mov ah,blue
    shl eax,8
    mov ah,green
    mov al,red
endm

.DATA
ClassName        db "SimpleWinClass",0
AppName          db "DIR /s GUI",0
EditTextLabel    db "Chemin:", 0
ButtonText       db "Lister", 0
ResultText       db 260 dup(0)
ClassNameStatic  db "STATIC", 0
ClassNameEdit    db "EDIT", 0
ClassNameButton  db "BUTTON", 0

pathSuffix db "\\*", 0
errStr     db "Erreur: chemin invalide",13,10,0
dot  db ".", 0
ddot db "..", 0

star        db "\\*", 0
pathFormat  db "%s\\%s", 0
fileStr     db "<FILE> %s", 13, 10, 0
dirStr      db "<DIR> %s", 13, 10, 0

; Texte test pour verification de l'affichage multi-ligne
newText db "<FILE> fichierA.txt",13,10,"<FILE> fichierB.txt",13,10,"<DIR> Dossier1/",13,10,"<FILE> fichierC.txt",13,10,0

combinedBuffer   db 2048 dup(0)

.DATA?
hInstance       HINSTANCE ?
hEditPath       HWND ?
hEditResult     HWND ?
findData WIN32_FIND_DATA <>
depth DWORD ?

.CODE
start:
    push 0
    call GetModuleHandleA
    mov hInstance,eax
    
    push hInstance
    call WinMain

    push eax
    call ExitProcess


; -------------------------------------------------------
;  Fonction d affichage dans hEditResult avec concat
; -------------------------------------------------------
DisplayText PROC
    LOCAL textLength:DWORD
    LOCAL currentText[2048]:BYTE

    ; GetWindowTextLengthA(hEditResult)
    push    hEditResult
    call    GetWindowTextLengthA
    mov     textLength, eax

    ; GetWindowTextA(hEditResult, &currentText, 2048)
    push    2048
    lea     eax, currentText
    push    eax
    push    hEditResult
    call    GetWindowTextA

    ; lstrcatA(&currentText, combinedBuffer)
    push    offset combinedBuffer
    lea     eax, currentText
    push    eax
    call    lstrcatA

    ; SetWindowTextA(hEditResult, &currentText)
    lea     eax, currentText
    push    eax
    push    hEditResult
    call    SetWindowTextA

    ret
DisplayText ENDP


print PROC
    push    ebp
    mov     ebp, esp

    ; Réinitialiser le buffer
    mov     edi, offset combinedBuffer
    mov     ecx, 2048
    mov     al, 0
    rep stosb

    ; Indentation : depth * 4 espaces
    mov     ecx, depth
    shl     ecx, 2                ; 4 espaces par niveau
    mov     edi, offset combinedBuffer
    mov     al, ' '
    rep stosb

    ; EAX = offset dans le buffer juste après les espaces
    mov     eax, offset combinedBuffer
    mov     ecx, depth
    shl     ecx, 2
    add     eax, ecx

    ; Choix du format : fichier ou dossier
    mov     edx, offset fileStr
    cmp     DWORD PTR [ebp + 12], FILE_ATTRIBUTE_DIRECTORY
    jne     is_file
    mov     edx, offset dirStr

is_file:
    push    [ebp + 8]        ; Nom du fichier
    push    edx              ; "<FILE>" ou "<DIR>"
    push    eax              ; Pointeur après indentation
    call    crt_sprintf
    add     esp, 12

    push    offset combinedBuffer
    call    DisplayText

    mov     esp, ebp
    pop     ebp
    ret
print ENDP

ListFilesRecursive PROC
    push    ebp
    mov     ebp, esp
    sub     esp, 1800                 ; Allocation de l'espace necessaire

    inc     depth                    ; Incremente la profondeur

    ; Preparation du chemin de recherche
    push    MAX_PATH
    push    [ebp + 8]                ; Chemin (path)
    lea     ebx, [ebp - 578]         ; Buffer temporaire
    push    ebx
    call    crt_strncpy
    add     esp, 12                  ; strncpy is cdecl, caller cleans stack (3 DWORDs)

    push    MAX_PATH
    push    offset pathSuffix        ; "\*"
    push    ebx                      ; Path buffer
    call    crt_strncat
    add     esp, 12                  ; strncat is cdecl, caller cleans stack (3 DWORDs)

    lea     ebx, [ebp - 318]         ; Buffer pour la structure de recherche (findData)
    push    ebx                      ; pFindData
    lea     ebx, [ebp - 578]         ; Path with \*
    push    ebx                      ; pFileName
    call    FindFirstFile            ; Appel a l'API FindFirstFile
    mov     [ebp - 582], eax         ; Handle de recherche
    cmp     eax, INVALID_HANDLE_VALUE
    je      error

do:
    lea     ebx, [ebp - 318]         ; findData
    add     ebx, 44                  ; findData.cFileName

    push    ebx                      ; findData.cFileName
    push    offset dot               ; Comparaison avec "."
    call    crt_strcmp
    add     esp, 8                   ; Clean up for strcmp
    cmp     eax, NULL
    je      skip

    push    ebx                      ; findData.cFileName
    push    offset ddot              ; Comparaison avec ".."
    call    crt_strcmp
    add     esp, 8                   ; Clean up for strcmp
    cmp     eax, NULL
    je      skip

    ; Affichage du nom de fichier/dossier
    push    [ebp - 318]               ; findData.dwFileAttributes
    lea     ebx, [ebp - 318]
    add     ebx, 44                  ; findData.cFileName
    push    ebx
    call    print
    add     esp, 8                   ; Clean up for print call

    lea     ebx, [ebp - 318]         ; findData
    cmp     DWORD PTR [ebx], FILE_ATTRIBUTE_DIRECTORY ; Check dwFileAttributes
    jne     nodir

    ; Si c'est un repertoire, on affiche et on appelle recursivement
    lea     ebx, [ebp - 318]
    add     ebx, 44                  ; findData.cFileName
    push    ebx                      ; Arg3 for sprintf: dir name
    push    [ebp + 8]                ; Arg2 for sprintf: current path
    push    offset pathFormat
    lea     ebx, [ebp - 842]         ; Buffer pour chemin complet
    push    ebx                      ; Arg0 for sprintf: output buffer
    call    crt_sprintf
    add     esp, 16                  ; Clean up for crt_sprintf

    push    ebx                      ; Path for recursive call
    call    ListFilesRecursive       ; Appel recursif pour les sous-dossiers
    add     esp, 4                   ; Nettoie l'argument (path) poussé pour l'appel récursif
    jmp     skip                     ; After recursion, go to FindNextFile

nodir:
skip:
    lea     ebx, [ebp - 318]         ; pFindData
    push    ebx
    push    [ebp - 582]              ; hFindFile
    call    FindNextFile             ; Recherche suivante
    cmp     eax, NULL
    jne     do

error:
    ; Fermer le handle de recherche s'il est valide
    mov     eax, [ebp - 582]
    cmp     eax, INVALID_HANDLE_VALUE
    je      skip_close_handle
    push    eax
    call    FindClose
    ; FindClose is stdcall, cleans its own stack

skip_close_handle:
    dec     depth                    ; Decremente la profondeur

    mov     esp, ebp
    pop     ebp
    ret
ListFilesRecursive ENDP

; -------------------------------------------------------
; MAIN
; -------------------------------------------------------

WinMain proc hInst:HINSTANCE
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra,NULL
    mov wc.cbWndExtra,NULL
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,NULL
    mov wc.lpszClassName,OFFSET ClassName

    push IDI_APPLICATION
    push 0
    call LoadIconA

    mov wc.hIcon,eax
    mov wc.hIconSm,eax

    push IDC_ARROW
    push 0
    call LoadCursorA

    mov wc.hCursor,eax
    lea eax, wc
    push eax
    call RegisterClassExA

    push 0         ; lpParam
    push hInst     ; hInstance
    push 0         ; hMenu
    push 0         ; hWndParent
    push 400       ; nHeight
    push 500       ; nWidth
    push CW_USEDEFAULT  ; Y
    push CW_USEDEFAULT  ; X
    push WS_OVERLAPPEDWINDOW
    push OFFSET AppName
    push OFFSET ClassName
    push 0         ; dwExStyle
    call CreateWindowExA

    mov hwnd,eax

    push SW_SHOWNORMAL
    push hwnd
    call ShowWindow

    push hwnd
    call UpdateWindow


main_loop:
    push 0
    push 0
    push 0
    lea eax, msg
    push eax
    call GetMessageA

    cmp eax, 0
    je end_loop

    lea eax, msg
    push eax
    call TranslateMessage

    lea eax, msg
    push eax
    call DispatchMessageA

    jmp main_loop
end_loop:
    mov eax, msg.wParam
    ret
WinMain endp

; -------------------------------------------------------
; CALLBACK WndProc
; -------------------------------------------------------

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL buffer[260]:BYTE

    cmp uMsg, WM_CREATE
    je on_create
    cmp uMsg, WM_COMMAND
    je on_command
    cmp uMsg, WM_DESTROY
    je on_destroy
    jmp def_proc

on_create:
    push 0
    push hInstance
    push 0
    push hWnd
    push 20
    push 60
    push 20
    push 20
    push WS_CHILD or WS_VISIBLE
    push OFFSET EditTextLabel
    push OFFSET ClassNameStatic
    push 0
    call CreateWindowExA


    push 0
    push hInstance
    push 1001
    push hWnd
    push 20
    push 300
    push 20
    push 80
    push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL
    push 0
    push OFFSET ClassNameEdit
    push 0
    call CreateWindowExA
    mov hEditPath, eax

    push 0
    push hInstance
    push 1002
    push hWnd
    push 20
    push 70
    push 20
    push 400
    push WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
    push OFFSET ButtonText
    push OFFSET ClassNameButton
    push 0
    call CreateWindowExA


    push 0
    push hInstance
    push 1003
    push hWnd
    push 280
    push 450
    push 60
    push 20
    push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_MULTILINE or ES_AUTOVSCROLL or ES_READONLY or WS_VSCROLL
    push 0
    push OFFSET ClassNameEdit
    push 0
    call CreateWindowExA
    mov hEditResult, eax

    ret

on_command:
    mov eax, wParam
    and eax, 0FFFFh
    cmp eax, 1002
    jne def_proc

    ; Recupere le chemin dans ResultText
    push 260
    push OFFSET ResultText
    push hEditPath
    call GetWindowTextA


    ; Efface le contenu de hEditResult
    push 0
    push hEditResult
    call SetWindowTextA

    ; Appelle la recursion reelle
    push OFFSET ResultText
    call ListFilesRecursive
    ret

on_destroy:
    push 0
    call PostQuitMessage

    xor eax, eax
    ret

def_proc:
    push lParam
    push wParam
    push uMsg
    push hWnd
    call DefWindowProcA
    ret
WndProc endp

end start