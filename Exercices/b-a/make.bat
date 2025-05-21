@echo off
c:\masm32\bin\ml /c /Zd /coff majuscule.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE majuscule.obj
pause