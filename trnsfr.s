;transfer filename from cmd to buffer
; a: string size
; x: starting index in cmdbuf
; y: buffer #
trname	pha
	jsr fndlmt
	jsr trcmbf
	pla
	sec
	sbc strsiz
	tax
	beq tn20
	bcc tn20
	lda #$a0
tn10	sta (dirbuf),y
	iny
	dex
	bne tn10
tn20	rts
;transfer cmd buffer to other buffer
; uses current buffer ptr
; limit: ending index+1 in cmd buf
; x: starting index in cmd buf
; y: buffer #
trcmbf	tya
	asl a
	tay
	lda buftab,y
	sta dirbuf
	lda buftab+1,y
	sta dirbuf+1
	ldy #0
;
tr10	lda cmdbuf,x
	sta (dirbuf),y
	iny
	beq tr20
	inx
	cpx limit
	bcc tr10
tr20	rts
;
;
;find the limit of the string in cmdbuf
; pointed to by x
fndlmt	lda #0
	sta strsiz
	txa
	pha
fl05
	lda cmdbuf,x
	cmp #',
	beq fl10
	cmp #'=
	beq fl10
	inc strsiz
	inx
	lda #15
	cmp strsiz
	bcc fl10
	cpx cmdsiz
	bcc fl05
fl10	stx limit
	pla
	tax
	rts
; get file entry from directory
; called by stdir, getdir
getnam	lda sa          ;save variables
	pha
	lda lindx
	pha
	jsr gnsub
	pla             ;restore variables
	sta lindx
	pla
	sta sa
	rts
gnsub	lda #irsa
	sta sa
	jsr fndrch
	jsr getpnt
	lda entfnd
	bpl gn05        ;more files
	lda drvflg
	bne gn050
	jsr msgfre      ;send blocks free
	clc             ;(c=0): end
	rts             ;terminate
gn05	lda drvflg      ;(drvflg=0):
	beq gn10        ; send file name
gn050
	dec drvflg      ;(drvflg=-1):new dir
	bne gn051
	dec drvflg      ;(drvflg=-1):
	jsr togdrv      ; send blocks free
	jsr msgfre
	sec
	jmp togdrv
gn051	lda #0
	sta nbtemp+1
	sta drvflg      ;reset flag
	jsr newdir
	sec
	rts
gn10	ldx #dirlen     ;set number blocks
	ldy #29         ; & adjust spacing
	lda (dirbuf),y
	sta nbtemp+1
	beq gn12
	ldx #dirlen-2
gn12	dey
	lda (dirbuf),y
	sta nbtemp
	cpx #dirlen-2
	beq gn14
	cmp #10
	bcc gn14
	dex
	cmp #100
	bcc gn14
	dex
gn14	jsr blknb       ;clear name buffer
	lda (dirbuf),y  ;set type chars
	pha 
	asl a           ;(used in bcs)
	bpl gn15
	lda #'<
	sta nambuf+1,x
gn15
	pla
	and #$f
	tay
	lda tp2lst,y
	sta nambuf,x
	dex
	lda tp1lst,y
	sta nambuf,x
	dex
	lda typlst,y
	sta nambuf,x
	dex
	dex
	bcs gn20        ;(from asl)
	lda #'*         ;file not closed
	sta nambuf+1,x
gn20	lda #$a0
	sta nambuf,x
	dex
	ldy #18
gn22	lda (dirbuf),y
	sta nambuf,x
	dex
	dey
	cpy #3
	bcs gn22
	lda #'"         ;send name in quotes
	sta nambuf,x
gn30	inx
	cpx #$20
	bcs gn35
	lda nambuf,x
	cmp #'"
	beq gn35
	cmp #$a0
	bne gn30
gn35	lda #'"
	sta nambuf,x
gn37	inx
	cpx #$20
	bcs gn40
	lda #$7f
	and nambuf,x
	sta nambuf,x
	bpl gn37
gn40	jsr fndfil
	sec
gn45	rts
blknb	ldy #nbsiz      ;blank nambuf
	lda #$20
blknb1	sta nambuf-1,y
	dey
	bne blknb1
	rts
;new directory in listing
newdir
	jsr bam2x
	jsr redbam
	jsr blknb
	lda #$ff
	sta temp
	ldx drvnum
	stx nbtemp
	lda #0
	sta nbtemp+1
	ldx jobnum
	lda bufind,x
	sta dirbuf+1
	lda dsknam
	sta dirbuf
	ldy #22
nd10	lda (dirbuf),y
	cmp #$a0
	bne nd20
	lda #'1         ;version # 1
	.byte $2c
nd15
	lda (dirbuf),y
	cmp #$a0
	bne nd20
;
	lda #$20
nd20
	sta nambuf+2,y
	dey
	bpl nd15
	lda #$12
	sta nambuf
	lda #'"
	sta nambuf+1
	sta nambuf+18
	lda #$20
	sta nambuf+19
	rts
msgfre	jsr blknb
	ldy #msglen-1
msg1	lda fremsg,y
	sta nambuf,y
	dey
	bpl msg1
	jmp numfre
fremsg	.byte "BLOCKS FREE."
msglen	=*-fremsg
