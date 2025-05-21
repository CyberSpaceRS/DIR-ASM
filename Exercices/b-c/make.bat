@echo off
\masm32\bin\ml /c /coff majuscule.asm
\masm32\bin\Link /SUBSYSTEM:CONSOLE majuscule.obj
pause