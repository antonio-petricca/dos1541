; validate files with bam
;  create new bam according to 
;  contents of files entered in dir
verdir
valdat
;validate is soft-load
	jsr simprs      ;extract drive #
	jsr initdr
	lda #$40
	sta wbam
	jsr newmpv      ;set new bam
	lda #0
	sta delind
	jsr srchst      ;search for first file
	bne vd25        ;found one
vd10	lda #0          ;set directory sectors...
	sta sector      ;...in bam
	lda dirtrk
	sta track
	jsr vmkbam
	lda #0
	sta wbam
	jsr scrbam      ;write out bams
	jmp endcmd
vd15	iny
	lda (dirbuf),y
	pha             ;save track
	iny
	lda (dirbuf),y
	pha             ;save sector
	ldy #19         ;get ss track
	lda (dirbuf),y  ;is this relative ?
	beq vd17        ;no
	sta track       ;yes - save track
	iny
	lda (dirbuf),y  ;get ss sector
	sta sector
	jsr vmkbam      ;validate ss by links
vd17	pla
	sta sector      ;now do data blocks
	pla
	sta track
	jsr vmkbam      ;set bit used in bam
vd20	jsr srre        ;search for more
	beq vd10        ;no more files
vd25
	ldy #0
	lda (dirbuf),y
	bmi vd15
	jsr deldir      ;not closed delete dir
	jmp vd20
;
vmkbam	;mark bam with file sectors
	jsr tschk
	jsr wused
	jsr opnird
mrk2	lda #0
	jsr setpnt
	jsr getbyt
	sta track
	jsr getbyt
	sta sector
	lda track
	bne mrk1
	jmp frechn
mrk1	jsr wused
	jsr nxtbuf
	jmp mrk2
;
