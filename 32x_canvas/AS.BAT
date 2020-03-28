..\compile\asmsh canvas.sh2,canvas_sh2.fixme
@if errorlevel 1 goto fin
@..\compile\asmshfix canvas_sh2.fixme canvas_sh2.bin
@del canvas_sh2.fixme
..\compile\asm68k /p canvas.asm,canvas.32x
@del canvas_sh2.bin
@if errorlevel 1 goto fin
:fin
