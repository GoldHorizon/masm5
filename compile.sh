#!/bin/bash
# Compile Script

    sudo wine /home/bliss/.wine/drive_c/masm32/bin/ml.exe -c -Zd -coff masm5.asm
    sudo wine /home/bliss/.wine/drive_c/masm32/bin/link.exe /SUBSYSTEM:CONSOLE /ENTRY:_start masm5.obj _string1.obj _string2.obj ../macros/*
    echo ""
