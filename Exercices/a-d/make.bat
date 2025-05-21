@echo off
c:\masm32\bin\ml /c /Zd /coff template.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE template.obj
pause