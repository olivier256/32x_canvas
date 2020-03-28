	dc.l	$01000000,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0

	dc.b	'SEGA GENESIS    '	; Console Name (16)
	dc.b	'(C)SEGA 2000.DEC'	; Copyright Information (16)
	dc.b	'32X GAME        '	; Domestic Name (48)
	dc.b	'                '
	dc.b	'                '
	dc.b	'32X GAME        '	; Overseas Name (48)
	dc.b	'                '
	dc.b	'                '
	dc.b	'GM MK-0000 -00'	; Serial Number (14)
	dc.w	0			; Checksum (2) - Leave it at #0 when using 32x
	dc.b	'J6              '	; I/O Support (16)
	dc.l	$00000000,ROM_SIZE	; ROM area (2x4)
	dc.l	$00FF0000,$00FFFFFF	; RAM area (2x4)
	dc.b	'                '	; Modem Support (24)
	dc.b	'                '	; Memo (40)
	dc.b	'                '
	dc.b	'                '
	dc.b	'JUE             '	; Country Support (16)

ExceptionTable:
	jmp	$3F0
	dc.l	$0
	dc.w	$4E73,$0,$0		; Bus error
	dc.w	$4E73,$0,$0		; Address Error
	dc.w	$4E73,$0,$0		; Illegal Instruction
	dc.w	$4E73,$0,$0		; Divide by 0
	dc.w	$4E73,$0,$0		; CHK Instruction
	dc.w	$4E73,$0,$0		; TRAPV Instruction
	dc.w	$4E73,$0,$0		; Privilege Violation
	dc.w	$4E73,$0,$0		; Trace
	dc.w	$4E73,$0,$0		; Line 1010 Emulator
	dc.w	$4E73,$0,$0		; Line 1111 Emulator
	dc.w	$4E73,$0,$0		; Spurious Interrupt
	dc.w	$4E73,$0,$0		; Level 1 Interrupt
	dc.w	$4E73,$0,$0		; Level 2 Interrupt
	dc.w	$4E73,$0,$0		; Level 3 Interrupt
	dc.w	$4E73,$0,$0		; HBL
	dc.w	$4E73,$0,$0		; Level 5 Interrupt
	dc.w	$4E73,$0,$0		; VBL
	dc.w	$4E73,$0,$0		; Level 7 Interrupt
	dc.w	$4E73,$0,$0		; Trap 0
	dc.w	$4E73,$0,$0		; Trap 1
	dc.w	$4E73,$0,$0		; Trap 2
	dc.w	$4E73,$0,$0		; Trap 3
	dc.w	$4E73,$0,$0		; Trap 4
	dc.w	$4E73,$0,$0		; Trap 5
	dc.w	$4E73,$0,$0		; Trap 6
	dc.w	$4E73,$0,$0		; Trap 7
	dc.w	$4E73,$0,$0		; Trap 8
	dc.w	$4E73,$0,$0		; Trap 9
	dc.w	$4E73,$0,$0		; Trap 10
	dc.w	$4E73,$0,$0		; Trap 11
	dc.w	$4E73,$0,$0		; Trap 12
	dc.w	$4E73,$0,$0		; Trap 13
	dc.w	$4E73,$0,$0		; Trap 14
	dc.w	$4E73,$0,$0		; Trap 15
EndExceptionTable:

	ds.b	$3C0-EndExceptionTable	; Padder
