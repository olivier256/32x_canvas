ROM_SIZE	equ	$00020000
GFX_CTRL	equ	$00C00004
GFX_DATA	equ	$00C00000
vTimer		equ	$00FF0000
wPos		equ	$00FF0002

* +--------+----------------+----------+----------+----------+---------------------+
* + Header | MARSInitHeader | ICD_MARS | Gen Code | SH2 Code |       GFX DATA      |
* +--------+----------------+----------+----------+----------+---------------------+
* 0        $3C0             $3F0       $800       CANVAS_START
*                                                                  GLIDE_END               *ROM_SIZE

*		+-------+-------+
* $FF0000	|    vTimer	|
*		+-------+-------+


* Genesis header
	dc.l	$01000000		; Initial SP
	dc.l	$000003F0		; Initial PC

	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0
	dc.l	$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0,$3F0

	dc.b	'SEGA GENESIS    '	; Console Name (16)
	dc.b	'(C)SEGA 2018.MAY'	; Copyright Information (16)
	dc.b	'32X CANVAS      '	; Domestic Name (48)
	dc.b	'                '
	dc.b	'                '
	dc.b	'32X CANVAS      '	; Overseas Name (48)
	dc.b	'                '
	dc.b	'                '
	dc.b	'GM MK-0000 -00'	; Serial Number (14)
	dc.w	0			; Checksum (2) - Leave it at #0 when using 32x
	dc.b	'J6              '	; I/O Support (16)
	dc.l	0,ROM_SIZE		; ROM area (2x4)
	dc.l	$FF0000,$FFFFFF		; RAM area (2x4)
	dc.b	'                '	; Modem Support (24)
	dc.b	'                '	; Memo (40)
	dc.b	'                '
	dc.b	'                '
	dc.b	'EUJ             '	; Country Support (16)

* Exception Jump Table
	jmp	$880000+INT		; Bus error
	jmp	$880000+INT		; Address Error
	jmp	$880000+INT		; Illegal Instruction
	jmp	$880000+INT		; Divide by 0
	jmp	$880000+INT		; CHK Instruction
	jmp	$880000+INT		; TRAPV Instruction
	jmp	$880000+INT		; Privilege Violation
	jmp	$880000+INT		; Trace
	jmp	$880000+INT		; Line 1010 Emulator
	jmp	$880000+INT		; Line 1111 Emulator

	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved
	jmp	$880000+INT		; Reserved

	jmp	$880000+INT		; Spurious Interrupt
	jmp	$880000+INT		; Level 1 Interrupt
	jmp	$880000+INT		; Level 2 Interrupt
	jmp	$880000+INT		; Level 3 Interrupt
	jmp	$880000+H_INT		; HBL
	jmp	$880000+INT		; Level 5 Interrupt
	jmp	$880000+V_INT		; VBL
	jmp	$880000+INT		; Level 7 Interrupt
	jmp	$880000+INT		; Trap 0
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT
	jmp	$880000+INT		; Trap 15

	ds.b	$A6			; Padder

* $3C0 - MARS Init Header
	dc.b	'MARS CHECK MODE '	; Module Name, 16 bytes
	dc.l	0			; Version
	dc.l	CANVAS_START		; Source (ROM)
	dc.l	0			; Destination (SDRAM offset)
	dc.l	CANVAS_END-CANVAS_START	; Size
	dc.l	$06000240		; Master SH2 Start Address
	dc.l	$06000240		; Slave SH2 Start Address
	dc.l	$06000000		; Master SH2 VBR
	dc.l	$06000120		; Slave SH2 VBR

* $3F0 - MARS Initial Program and Security (ICD), 1040 bytes
	incbin	icd_mars.bin

* $800 - Genesis code
	bcs	$800			; Mars error ?

	bra	CANVAS_END

CANVAS_START:

	incbin	canvas_sh2.bin

CANVAS_END:

	move.w	#$8174,GFX_CTRL		; 224 lines
	move.w	#$929B,GFX_CTRL		; Window from bottom to cell 27

	BSR	loadTiles

	move.l	#$40000003,GFX_CTRL
	move.w	#128,d0
loop:
*	move.w	#$21,GFX_DATA
	dbra	d0,loop

	move.l	#$FFFFF0,a7		; Set SP
	move	#$2300,SR		; V_INT


	bset.b	#7,$A15100		; Set FM. 32X will start


waitForMasterCleared:
	bsr	displayCommPort
	cmpi.l	#0,$A15120
	bne	waitForMasterCleared

	bsr	vSync

main:

	bsr	displayCommPort

	bsr	vSync

	bra	main

loadTiles:
	move.l	#$C0000000,GFX_CTRL	; Write to CRAM $00
	move.w	#$000,GFX_DATA
	move.w	#$EEE,GFX_DATA
	move.l	#$44000000,GFX_CTRL	; Write to VRAM $0400
	lea	TILES68K,a0
	add.l	#$880000,a0		; a0 = source
	move.l	#GFX_DATA,a1		; a1 = destination
	move.w	#$3AF,d0		; d0 = counter
loopTiles:
	move.w	(a0)+,(a1)
	dbra	d0,loopTiles
	RTS
TILES68K:
	incbin	FONT_68K.DAT





displayCommPort:
*	FB = 0;
*	for (int i=0;i<8;i++) {
*		int value = CommPort[i];
*		for (int j=0;j<4;j++) {
*			int hex = value & 0xF;
*			*FB++ = CORRES[hex];
*			value = value >> 4;
*		}
*		*FB++ = ' ';
*	}

	moveq	#0,d2
	moveq	#0,d4

	move.l	#$C00000,a1		; GFX_DATA
	move.l	#$7D800003,GFX_CTRL	; Write to VRAM $FD80
	move.l	#$A15120,a2		; a2 = CommPort
	lea	CORRES,a3
	add.l	#$880000,a3		; a3 = &CORRES


	moveq	#7,d1			; d1 = i
loopI:
	move.w	(a2)+,d2		; d2 = value

	moveq	#3,d3			; d3 = j
loopJ:
	rol.w	#4,d2			; Put CommPort[0] into LSB
	move.b	d2,d0			; d0 = hex
	AND.W	#$000F,d0
	move.b	(a3,d0),d0		; d0 = CORRES[hex]
	move.w	d0,(a1)			; *FB++ = d0

	dbra	d3,loopJ

	move.w	' ',(a1)

	dbra	d1,loopI

	rts


CORRES:
	DC.B	$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46




vSync:
	move.w	vTimer,d0
vSyncLoop:
	cmp.w	vTimer,d0
	beq	vSyncLoop
	rts




INT:
	rte

H_INT:
	rte

V_INT:
	addq	#1,vTimer
	addq	#1,$A15128
	
	rte



	ds.b	ROM_SIZE-*
