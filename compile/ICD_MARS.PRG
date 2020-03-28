*	DIAGNSTC\SOURCE\MD\SOURCE
*****************************************************************
*	MARS Initial & Security ( Cartridge Mode Only )
*
*	Copyright SEGA ENTERPRISES,LTD. 1994
*
*		SEGA ENTERPRISES,LTD.
*		CS Hardware R&D Dept.
*			T.Okawa
*
*---------------------------------------------------------------*
*	Version 0.5	3/31/94	Version 0.0 Board
*	Version 1.0	4/12/94	Version 1.0 Board
*	Version 1.1	4/19/94	Custom IC
*	Version 1.1a	5/12/94	Custom IC Bug Fix
*	Version 1.1b	6/02/94	a4 register clear miss
*	Version 1.1c	7/13/94	Check SUM compare miss
*****************************************************************

BankSet	equ	$c0
AllBankSet	equ	$d4

*	      Normal Mode	Mars Mode
* StartMarsInit	000400H	 880400H
* CopyrightData 	000510H	 880510H
* VdpRegInit	0005AAH	 8805AAH
* VramClear	0005D2H	 8805D2H
* FrameClear	000658H	 880658H
* PaletteClear	000696H	 880696H
* RestartPrg	0006BEH	 8806BEH
* Hot_Start	0007ECH	 8807ECH
* MarsError	0007FCH	 8807FCH
* IcdAllEnd	000800H	 880800H

*---------------------------------------------------------------------------------------------------
*		ÇuÇÖÇÉÇîÇèÇíÇqÇnÇlì‡ÉãÅ[É`Éì
*---------------------------------------------------------------------------------------------------
*
*                                	;-----------------------------------------------------------
*                                	;	Bank Set
*                                	;
*                                	; IN	a1.l	Bank Register Address ($a130f1-$a130ff)
*                                	;	d0.b	Bank Data ($00-$3f)
*                                	;-----------------------------------------------------------
* 000000C0                       	BankSet:
* 000000C0   08F9 0000 00A1 5107 		bset.b	#0,$a15107	; RV = 1
* 000000C8   1280                		move.b	d0,(a1)
* 000000CA   08B9 0000 00A1 5107 		bclr.b	#0,$a15107	; RV = 0
* 000000D2   4E75                		rts
*
*                                	;-----------------------------------------------------------
*                                	;	All Bank Set
*                                	;
*                                	; IN	a0.l	Bank Register Data Table Address
*                                	;-----------------------------------------------------------
* 000000D4                       	AllBankSet:
* 000000D4   48E7 0140           		movem.l	d7/a1,-(sp)
* 000000D8   08F9 0000 00A1 5107 		bset.b	#0,$a15107	; RV = 1
* 000000E0   43F9 00A1 30F1      		lea	$a130f1,a1
* 000000E6   7E07                		moveq	#8-1,d7
* 000000E8                       	l0:
* 000000E8   1298                		move.b	(a0)+,(a1)
* 000000EA   D0FC 0002           		adda	#2,a1
* 000000EE   51CF FFF8           		dbra	d7,l0
* 000000F2   08B9 0000 00A1 5107 		bclr.b	#0,$a15107	; RV = 0
* 000000FA   4CDF 0280           		movem.l	(sp)+,d7/a1
* 000000FE   4E75                		rts
*---------------------------------------------------------------------------------------------------

*
*	Mega Drive / Genesis Initialize
*	MARS System Register Initialize
*	MARS VDP Register Initialize
*	MARS Frame Buffer Clear
*	SH2 SDRAM Clear & Program Loading
*	Check TV Mode
*	Check SUM Compare
*
*
*
* OUT	cc/cs	"MARS ID" and "Self Check" Complete / Error
*
*	d0.w	Error status
*	 bit 0	MARS ID Error
*	 bit 1	TV Mode Error
*	 bit 2	Not used
*	 bit 3	Not used
*	 bit 4	Not used
*	 bit 5	Check Sum Error
*	 bit 6	Security Error
*	 bit 7	SDRAM Self Check Error
*	   |
*	 bit 15	0: Cold Start / 1: Hot Start
*
*	d1.w	TV Mode Status
*	|    bit 15   | bit 14-8 |  bit 7  |   bit 6   | bit 5 |   bit 4  | bit 3-0 |
*	| MARS TVmode | Not used | Country | MD TVmode |  DISK | Not used | Version |
*
*	d2.w	Check Sum Data
*
*
*	$A15120.l	"SQER"	: Security Error
*	$A15120.l	"SDER"	: SDRAM Self Check Error
*
*	$A15120.l	"M_OK"	: SH Master Setup OK
*	$A15124.l	"S_OK"	: SH Slave Setup OK
*
*	Å¶íçà”éñçÄÅ¶
*
*	ÅõÅ?ÇrÇgÇQÇ™ÉZÉbÉgÉAÉbÉvèIóπÇµÇΩÇ±Ç∆ÇïKÇ∏ämîFÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB
*	ÅõÅ?Ç±ÇÃÉvÉçÉOÉâÉÄÇ™ê≥èÌèIóπÇµÇ»Ç¢èÍçáÇÕÅAÉÜÅ[ÉUÅ[Ç…ê⁄ë±ìôÇ
*	Å?ämîFÇ∑ÇÈÇÊÇ§ÉÅÉbÉZÅ[ÉWÇï\é¶ÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB
*	ÅõÅ?ÇUÇWÇjÇ∆ÇrÇgÇQÇÃë¨ìxç∑Ç™Ç©Ç»ÇËÇ†ÇÈÇΩÇﬂìØä˙ÇïKÇ∏Ç∆ÇÈÇÊÇ§Ç…
*	Å?ÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB
*
*---------------------------------------------------------------------------------------------------

*program start
	org	$000003f0

	move.l	#-64,a4
	move.l	#0,$a15128
StartMarsInit:
	move.w	#$2700,sr	; Interrupt disenable

	lea	$a10000,a5

	moveq	#1,d0
	cmp.l	#'MARS',$30ec(a5)	; check MARS ID
	bne	MarsError

sh_wait:
	btst.b	#7,$5101(a5)	; adapter control reg. REN=1 ?
	beq.b	sh_wait

* ----	Check Cold Start / Hot Start
	tst.l	$8(a5)		; power on check cntl_A,cntl_B
	beq.b	cold_start	; reset hot_start
	tst.w	$c(a5)		; power on check cntl_C
	beq.b	cold_start	; reset hot_start
	btst.b	#0,$5101(a5)	; check adapter mode
	bne	Hot_Start
* power on (cold_start)
cold_start:

* ----	Security
	move.b	1(a5),d0	; read Version No.
	andi.b	#$000f,d0	; Ver.No check
	beq.b	japan
	move.l	$55a,$4000(a5)	;security part move "SEGA"
japan:
	moveq	#0,d1		; D1 set   0
	move.l	d1,a6		; A6 $00000000
	move.l	a6,usp		; User Stack Pointer

	lea	vreg_dt,a0
	bsr	VdpRegInit	; VDP Register Initial
	bsr	VramClear	; VRAM,VSRAM,CRAM Clear

	lea	z80_prg,a3
	lea	$a00000,a1
	lea	$c00011,a2
	move.w	#$100,d7
	moveq	#0,d0
* Z80 self_initial
z80_clr:
	move.w	d7,$1100(a5)	; Z80_BUSREQ ON
	move.w	d7,$1200(a5)	; Z80_RESET  OFF
z801:
	btst	d0,$1100(a5)	; Z80_BGACK  CHECK ?
	bne.b	z801
	moveq	#37,d2		; D2 is Z80_program's size
z802:
	move.b	(a3)+,(a1)+	; move.B (z80_prg)+,($a00000)+
	dbra	d2,z802
	move	d0,$1200(a5)	; Z80_RESET  ON
	move	d0,$1100(a5)	; Z80_BUSREQ OFF
	move	d7,$1200(a5)	; Z80_RESET  OFF(Z80 start)

	move.b	(a3)+,(a2)	; clear PSG
	move.b	(a3)+,(a2)
	move.b	(a3)+,(a2)
	move.b	(a3)+,(a2)

	lea	l0,a0		; copy from ROM to WRAM
	lea	$ff0000,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	lea	$ff0000,a0
	jmp	(a0)

l0:
	move.b	#1,$5101(a5)	; MARS mode
* SH2 reset - wait 10ms -
	lea	RestartPrg,a0
	adda.l	#$880000,a0
	jmp	(a0)

vreg_dt:
	dc.b	$04,$04,$30,$3c,$07,$6c,$00,$00		;VDP REG #0-7
	dc.b	$00,$00,$ff,$00,$81,$37,$00,$02		;VDP_REG #8-15
	dc.b	$01,$00,$00				;VDP REG #16-18
	dc.b	$00					; Rajout OB1.

z80_prg:
	dc.b	$AF		;XOR	A
	dc.b	$01,$D9,$1F	;LD	BC,1FD9H
	dc.b	$11,$27,$00	;LD	DE,0027H
	dc.b	$21,$26,$00	;LD	HL,0026H
	dc.b	$F9		;LD	SP,HL
	dc.b	$77		;LD	(HL),A
	dc.b	$ED,$B0		;LDIR
	dc.b	$DD,$E1		;POP	IX
	dc.b	$FD,$E1		;POP	IY
	dc.b	$ED,$47		;LD	I,A
	dc.b	$ED,$4F		;LD	R,A
	dc.b	$D1		;POP	DE
	dc.b	$E1		;POP	HL
	dc.b	$F1		;POP	AF
	dc.b	$08		;EX	AF,AF'
	dc.b	$D9		;EXX
	dc.b	$C1		;POP	BC
	dc.b	$D1		;POP	DE
	dc.b	$E1		;POP	HL
	dc.b	$F1		;POP	AF
	dc.b	$F9		;LD	SP,HL
	dc.b	$F3		;DI
	dc.b	$ED,$56		;IM1
	dc.b	$36,$E9		;LD	(HL),$E9='JP (HL)'
	dc.b	$E9		;JP	(HL)
psg_dat:
	dc.b	$9F,$BF,$DF,$FF	;PSG initial data

*-----------------------------------------------
*	Copyright
*-----------------------------------------------
CopyrightData:
	dc.b	'MARS Initial & Security Program'
	dc.b	'          Cartridge Version    '
	dc.b	'Copyright SEGA ENTERPRISES,LTD.'
	dc.b	' 1994                    '
	dc.b	'              ROM Version 1.0'
	dc.b	0		; Rajout OB1.


*-----------------------------------------------
*	VDP Register & VRAM Initial
*
* IN	a0.l	Register Data Table Address
*-----------------------------------------------

VdpRegInit:
	movem.l	d0/d1/a1,-(a7)
*	dc.l	$48e7c040

	lea	$c00004,a1
	move.w	(a1),d0		; VDP Dummy Read
	move.w	#$8000,d0	; Register No.
	move.w	#$100,d1	; Increment Value
	move.w	#19-1,d7	; Register 0-18
l02:
	move.b	(a0)+,d0
	move.w	d0,(a1)
	add.w	d1,d0
	dbra	d7,l02

	movem.l	(a7)+,d0/d1/a1
*	dc.l	$4cdf0203
	rts


*-----------------------------------------------
*	VRAM,VSRAM,CRAM Clear
*-----------------------------------------------

VramClear:
	movem.l	d0/d7/a0/a1,-(a7)
*	dc.l	$48e781c0

	lea	fill_data,a0
	lea	$c00004,a1

	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)
	move.l	(a0)+,(a1)	;dma fill(VDP_VRAM CLEAR)
	move.w	d1,-4(a1)	;fill data set $0
chk_vdp:
	move.w	(a1),d0
	btst	#1,d0
	bne.b	chk_vdp	; DMA end/H

	move.w	(a0)+,(a1)
	move.w	(a0)+,(a1)

	moveq	#0,d0
	move.l	#$c0000000,(a1)	; clear ColorRAM
	moveq	#$80/2/4-1,d7
cclr:
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	dbra	d7,cclr

	move.l	#$40000010,(a1)	; clear VscrollRAM
	moveq	#$50/2/4-1,d7
vsclr:
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	move.w	d0,-4(a1)
	dbra	d7,vsclr

	movem.l	(a7)+,d0/d7/a0/a1
*	dc.l	$4cdf0381
	rts

fill_data:
	dc.w	$8114,$8f01
	dc.w	$93ff,$94ff,$9500,$9600,$9780	;VDP_REG #19-23
	dc.l	$40000080		;dma fill(VDP_VRAM clear)
	dc.w	$8104,$8f02


*-----------------------------------------------
*	Frame Buffer Clear
*-----------------------------------------------

FrameClear:
	movem.l	d0/d1/d7/a1,-(a7)
*	dc.l	$48e7c140	

	lea	$a15180,a1
fm:
	bclr.b	#7,-$80(a1)	; MD access
	bne.b	fm

	move.w	#$20000/$200-1,d7
	moveq	#0,d0
	moveq	#0,d1
	move.w	#$ff,$4(a1)	; Fill Length Reg.
fill0:
	move.w	d1,$6(a1)	; Fill Start Address Reg.
	move.w	d0,$8(a1)	; Fill Data Reg.
	nop
fen0:
	btst.b	#1,$b(a1)	; FEN = 0 ?
	bne.b	fen0
	add.w	#$100,d1	; Address = +200H
	dbra	d7,fill0

	movem.l	(a7)+,d0/d1/d7/a1
*	dc.l	$4cdf0283	
	rts


*-----------------------------------------------
*	Palette RAM Clear
*-----------------------------------------------

PaletteClear:
	movem.l	d0/d7/a0,-(a7)
*	dc.l	$48e78180

	lea	$a15200,a0
fm2:
	bclr.b	#7,-$100(a0)	; MD access
	bne.b	fm2

	move.w	#256/2/4-1,d7
pl:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,pl

	movem.l	(a7)+,d0/d7/a0
*	dc.l	$4cdf0181
	rts


*-----------------------------------------------
*	PC = +$880000
*-----------------------------------------------

RestartPrg:
	lea.l	$ff0000,a0	; clear WorkRAM
	move.w	#$10000/4/8-1,d7
	moveq	#0,d0
wclr:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,wclr

	move.w	#0,$1200(a5)	; Z80 RESET

	moveq	#10,d7			; 8
res_wait:
	dbra	d7,res_wait			; 12*d7+10

* ----	Mars Register Initialize

	lea	$a15100,a1

* ----	Communication Reg. Clear
	moveq	#0,d0
	move.l	d0,$20(a1)	; clear "M_OK"
	move.l	d0,$24(a1)	; clear "S_OK"

	move.b	#3,$5101(a5)	; SH2 start
	move.l	$880000,a7	; set stack pointer
fm3:
	bclr.b	#7,(a1)		; MD access
	bne.b	fm3
	moveq	#0,d0
	move.w	d0,2(a1)	; Interrupt Reg.
	move.w	d0,4(a1)	; Bank Reg.
	move.w	d0,6(a1)	; DREQ Control Reg.
	move.l	d0,8(a1)	; DREQ Source Address Reg.
	move.l	d0,$c(a1)	; DREQ Destination Address Reg.
	move.w	d0,$10(a1)	; DREQ Length Reg.
	move.w	d0,$30(a1)	; PWM Control
	move.w	d0,$32(a1)	; PWM fs Reg.
	move.w	d0,$38(a1)	; PWM Mono Reg.

	move.w	d0,$80(a1)	; Bitmap Mode Reg.
	move.w	d0,$82(a1)	; Shift Reg.

* ----	Mars Frame Buffer Clear
fs0:
	bclr.b	#0,$8b(a1)	; FS = 0
	bne.b	fs0

	bsr	FrameClear

fs1:
	bset.b	#0,$8b(a1)	; FS = 1
	beq.b	fs1

	bsr	FrameClear

	bclr.b	#0,$8b(a1)	; FS = 0

* ----	Palette RAM Clear
	bsr	PaletteClear

* ----	SH2 Check
	move	#$40,d0
	move.l	$20(a1),d1	; Security Check
	cmp.l	#'SQER',d1
	beq	MarsError

	move	#$80,d0
	move.l	$20(a1),d1	; SDRAM Self Check
	cmp.l	#'SDER',d1
	beq	MarsError

*	move.l	#$880200+6*27,$70
	move.l	#$8802A2,$70	; Set H Interrupt Vector

* ----  TV Mode Check
	move	#2,d0
	moveq	#0,d1
	move.b	$1(a5),d1
	move.b	$80(a1),d2
	lsl.w	#8,d2
	or.w	d2,d1
	btst	#15,d1
	bne.b	NTSC
PAL:
	btst	#6,d1
	beq	MarsError
	bra.b	tvmodeok
NTSC:
	btst	#6,d1
	bne	MarsError
tvmodeok:

* ----  CheckSum Compare
	moveq	#$20,d0
	lea	$880000,a0	; MARS Bank Image Address
	move.w	$18e(a0),d6	; CheckSum Data
	tst.w	d6
	beq	cksumend	; if CheckSum = 0 then No check
cksum:
	move.w	$28(a1),d2
	cmp.w	#0,d2
	beq.b	cksum

	cmp.w	d6,d2		; CheckSum Compare
	bne.b	MarsError
cksumend:

complete:

* ----	Communication Reg. Clear
	moveq	#0,d0
	move.l	d0,$28(a1)	; 8
	move.l	d0,$2c(a1)	; 12

	move.w	(a4),d7
	movea.l	#-64,a6
	movem.l	(a6),d0/d3-d7/a0-a6
*	dc.l	$4cd67ff9
	move	#0,ccr		; Complete
	bra.b	IcdAllEnd
Hot_Start:
	lea	$a15100,a1
	move.w	d0,6(a1)	; DREQ Control Reg.

	move.w	#$8000,d0
	bra.b	IcdAllEnd
MarsError:
	move	#1,ccr		; Error
IcdAllEnd:


*****************************************************************
*	end of file
*****************************************************************
