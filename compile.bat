C:\masm32\bin\ml.exe -c -coff -Zd masm4.asm

C:\masm32\bin\Link.exe -SUBSYSTEM:CONSOLE -entry:_start -out:masm4.exe masm4.obj _string1.obj _string2.obj ..\macros\convutil201604.obj ..\macros\utility201609.obj ..\macros\io.obj
masm4.exe