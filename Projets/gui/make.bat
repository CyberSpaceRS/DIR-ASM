@echo off
\masm32\bin\ml /c /coff projet.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE projet.obj
pause
