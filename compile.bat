C:\masm32\bin\ml.exe -c -coff -Zd masm5.asm

C:\masm32\bin\Link.exe -SUBSYSTEM:CONSOLE -entry:_start -out:masm5.exe masm5.obj _string1.obj _string2.obj ..\macros\convutil201604.obj ..\macros\utility201609.obj ..\macros\io.obj
masm5.exe