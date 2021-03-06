;set 1st drive and table pointers
onedrv	lda f2cnt
	sta f1cnt
	lda #1
	sta f2cnt
	sta f2ptr
;set up all drives from f2cnt
alldrs	ldy lstdrv      ;set up drive #'s...
	ldx #0          ;...into file entry table... 
ad10	stx f1ptr       ;...on sector ptr byte
	lda filtbl,x
	jsr setdrv
	ldx f1ptr
	sta filtbl,x    ;incr ptr past ":"
	tya             ;bits rep drives
	sta fildrv,x    ;bit7: default
	inx             ;bit0: drive #
	cpx f2cnt
	bcc ad10
	rts
;set drive number
;  determines drive # from text or
;  uses default (-d)
;  a: in,out: index, cmdbuf
;  y: in: default drive!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;    out: drive number, - if default
setdrv	tax             ;x= cmdbuf index
	ldy #0          ;set default drive to zero!!!!!!!!!!!!!!!!!!!!!
	lda #':
	cmp cmdbuf+1,x  ;for xxx:file
	beq sd40        ;      ^ 
	cmp cmdbuf,x    ;for xxx:file
	bne sd50        ;       ^
	inx             ;found ":", so...
sd20	tya             ;drive= default
sd22	and #1          ;convert to numeric
sd24	tay             ;restore drive
	txa             ;a=index & xxxxfile
	rts             ;              ^
sd40	lda cmdbuf,x
	inx             ; xxx:file
	inx             ;   --^
	cmp #'0         ;for xx0:file
	beq sd22        ;        ^
	cmp #'1         ;for xx1:file
	beq sd22        ;        ^
	bne sd20        ;cmd:file or xx,:file
sd50	=* ;    ^           ^
	tya             ;for xxx,file or xx=file
	ora #$80        ;        ^          ^
	and #$81        ;drive= -default
	bne sd24        ;finish testing
;set drive from any config.
setany	lda #0
	sta image
	ldy filtbl
sa05	lda (cb),y
	jsr tst0v1
	bpl sa20
	iny
	cpy cmdsiz
	bcs sa10
	ldy cmdsiz
	dey
	bne sa05
sa10	dec image
	lda #0          ;default to zero!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sa20	and #1
	sta drvnum
	jmp setlds
;toggle drvnum
togdrv	lda drvnum
	eor #1
	and #1
	sta drvnum
	rts
;set ptrs to one file stream & chk type
fs1set	ldy #0
	lda f1cnt
	cmp f2cnt
	beq fs15
	dec f2cnt
	ldy f2cnt
	lda filtbl,y
	tay
	lda (cb),y
	ldy #ntypes-1
fs10	cmp typlst,y
	beq fs15
	dey
	bne fs10
fs15	tya
	sta typflg
	rts
;test char in accum for "0" or "1"
tst0v1	cmp #'0
	beq t0v1
	cmp #'1
	beq t0v1
	ora #$80
t0v1	and #$81
	rts
