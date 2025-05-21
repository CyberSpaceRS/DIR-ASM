@echo off
\masm32\bin\ml /c /coff factorielle.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE factorielle.obj
pause
