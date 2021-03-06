;
;
;  * utiliy routines
;
;
errr	ldy jobn        ; return  job code
	sta jobs,y
;
	lda gcrflg      ; test if buffer left gcr
	beq errr10      ; no
;
	jsr wtobin      ; convert back to binary
;
errr10
	jsr trnoff      ; start timeout on drive
;
	ldx savsp
	txs             ; reset stack pointer
;
	jmp top         ; back to the top
;
;
;
turnon	lda #$a0        ; turn on drive
                ; drvst=acel and on
	sta drvst
;
;
	lda dskcnt      ; turn motor on and select drive
	ora #$04        ; turn motor on
	sta dskcnt
;
	lda #60         ; delay  1.5 sec
	sta acltim
;
	rts
;
;
;
trnoff	ldx cdrive      ; start time out of current drive
	lda drvst       ;status=timeout
	ora #$10
	sta drvst
;
	lda #255        ; 255*.025s time out
	sta acltim
;
	rts
;
;
;
