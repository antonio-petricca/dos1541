;
; dskcpy check for type
; and parses special case
;
dskcpy
	lda #$e0        ;kill bam buffer
	sta bufuse
	jsr clnbam      ;clr tbam
	jsr bam2x       ;get bam lindx in .x
	lda #$ff
	sta buf0,x      ;mark bam out-of-memory
	lda #$0f
	sta linuse      ;free all lindxs
	jsr prscln      ;find ":"
	bne dx0000
	jmp duplct      ;bad command error, cx=x not allowed
;
;jsr prseq
;
;lda #'* ;cpy all
;ldx #39 ;put at buffer end
;stx filtbl+1
;sta cmdbuf,x ;place *
;inx
;stx cmdsiz
;ldx #1 ;set up cnt's
;stx f1cnt
;inx
;stx f2cnt
;jmp movlp2 ;enter routine
;
dx0000	jsr tc30        ;normal parse
dx0005	jsr alldrs      ;put drv's in filtbl
	lda image       ;get parse image
	and #%01010101  ;val for patt copy
	bne dx0020      ;must be concat or normal
	ldx filtbl      ;chk for *
	lda cmdbuf,x
	cmp #'*
	bne dx0020
;ldx #1 ;set cnt's
;  no pattern matching allowed
;stx f1cnt
;inx
;stx f2cnt
;jmp cpydtd ;go copy
dx0010	lda #badsyn     ;syntax error
	jmp cmderr
dx0020	lda image       ;chk for normal
	and #%11011001
	bne dx0010
	jmp copy
.if 0
prseq
	lda #'=         ;special case
	jsr parse
	bne x0020
x0015	lda #badsyn
	jmp cmderr
x0020	lda cmdbuf,y
	jsr tst0v1
	bmi x0015
	sta fildrv+1    ;src drv
	dey
	dey
	lda cmdbuf,y
	jsr tst0v1
	bmi x0015
	cmp fildrv+1    ;cannot be equal
	beq x0015
	sta fildrv      ;dest drv
	rts
.endif
