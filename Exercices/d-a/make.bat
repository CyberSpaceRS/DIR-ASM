@echo off
\masm32\bin\ml /c /coff diviseur.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE diviseur.obj
pause
