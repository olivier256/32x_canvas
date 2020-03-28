..\asmsh %1.sh2,%1.as > sboub.txt 
@if errorlevel 1 goto fin
@..\asmshfix %1.as %1_sh2.bin
@del %1.as
..\asm %1.asm %1.32x
@if errorlevel 1 goto fin
@type sboub.txt
:fin
@del sboub.txt
