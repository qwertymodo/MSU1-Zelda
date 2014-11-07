//******************************************************************************
// alttp_msu.asm
// 
// Author:        qwertymodo
// Date Created:  1 Nov 2014
// Date Modified: 7 Nov 2014
// Assembler:     bass v14
//
// Implements MSU-1 audio streaming in The Legend of Zelda: A Link to the Past
// Original patch by Conn, disassembled and continued by qwertymodo.
//
// This patch is intended to be applied directly by bass.  Patch should be
// applied to an unheadered ROM.  Requires expanded ROM, but bass can expand the
// ROM if EXPAND_ROM is defined below.
//
// Unheadered ROM MD5: 608C22B8FF930C62DC2DE54BCD6EBA72
//
// Usage: bass -o [romfile] alttp_msu.asm
//
// See README.md for more information
//
//******************************************************************************

arch snes.cpu

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

// Comment out this line if applying to an already expanded ROM
define EXPAND_ROM()

if {defined EXPAND_ROM} {
    origin 0x100000
    fill 0x80000, 0xFF
}

// Header checksum
seek($FFDC)
    dw 0x5BF1 // Checksum complement
    dw 0xA40E // ROM checksum

// the following codes are hooks in the native rom – mainly when music is stored
// to the controller $012C
seek($0080D9)
    jsl $22E900
    nop
    nop

seek($0080F3)
    jsl $22E950
    nop
    nop

seek($00F40F)
    jsl $22EA80
    nop
    nop
    nop

seek($00F9C3)
    jsl fade_out
    nop

seek($028BFF)
    jsr $FFD0

seek($02934F)
    jsl $22EA80
    nop
    nop
    nop

seek($029A04)
    jsl fade_out
    nop

seek($029B14)
    jsl fade_out
    nop

// Track 0x08
seek($029D22)
    jsl $22EB30
    nop

seek($02A027)
    jsl fade_out
    nop

// Track 0x20
seek($02A0C1)
    jsl $22ED40
    nop

// Track 0x21
seek($02A141)
    jsl $22ED70
    nop

seek($02AAB1)
    jsl fade_out
    nop

seek($02AE7E)
    jsl fade_out
    nop

// Track 0x08
seek($02B225)
    jsl $22EB30
    nop

seek($02FFD0)
    jsl $22EB90
    rts

// Track 0x0A
seek($058928)
    jsl $22EB60
    nop

// Track 0x0C
seek($05CC5F)
    jsl $22EBC0
    nop

seek($06B0D8)
    jsl map_open
    nop

seek($06B112)
    jsl $22EA50
    nop

// Track 0x1B
seek($06C621)
    jsl $22EC80
    nop

// Track 0x1B
seek($06C847)
    jsl $22EC80
    nop

seek($07AA9C)
    jsl map_open
    nop

seek($07EB90)
    jsl $22EA50
    nop

seek($08C606)
    jml $22EDD7
    nop

// Track 0x1A
seek($08C60B)
    jsl $22EC50
    nop

seek($08CD07)
    jsl fade_out
    nop

seek($08D05C)
    jsl $22EA50
    nop

seek($098D2C)
    jsl map_open
    nop

// Track 0x15
seek($09A234)
    jsl $22EAB0
    nop

// Track 0x13
seek($09EE44)
    jsl $22EC20
    nop

seek($09F2B2)
    jsl fade_out
    nop

// Track 0x0B
seek($09F4A6)
    jsl $22EAD0
    nop

seek($09F50F)
    jsl fade_out
    nop

seek($0AB940)
    jsl $22EB00
    nop
    nop
    nop

seek($0ABA1E)
    jsl map_open
    nop

seek($0ABC90)
    jsl $22EA50
    nop

seek($0AEFB5)
    jsl $22EA50
    nop

// Track 0x0B
seek($0CCDA7)
    jsl $22EAD0
    nop

seek($0CCF7A)
    jsl fade_out
    nop

seek($0CF105)
    jsl fade_out
    nop

// Track 0x22
seek($0EBD16)
    jsl $22EDA0
    nop

seek($0EDA31)
    jsl map_open
    nop

// Track 0x1E
seek($1D8D39)
    jsl $22ECE0
    nop

// Track 0x1F
seek($1D92F1)
    jsl $22ED10
    nop

// Track 0x0E
seek($1DFCCC)
    jsl $22EBF0
    nop

// Track 0x1D
seek($1ED3FA)
    jsl $22ECB0
    nop

// this code selects whether the current theme is repeated or played one
// time (store to $2007)
seek($22E880)
    lda $0129   // $0129 was free ram, it is a mirror of the current played theme
    cmp #$01    // compares now with the themes 01,08,... which do not repeat
    bne +
    lda #$01    // if match, load #$01 (not repeat) then return
    rts
+;  cmp #$08
    bne +
    lda #$01
    rts
+;  cmp #$0A
    bne +
    lda #$01
    rts
+;  cmp #$0F
    bne +
    lda #$01
    rts
+;  cmp #$13
    bne +
    lda #$01
    rts
+;  cmp #$1D
    bne +
    lda #$01
    rts
+;  cmp #$21
    bne +
    lda #$01
    rts
+;  cmp #$22
    bne +
    lda #$01
    rts
+;  lda #$03    // if no match it is a theme that repeats (#$03)
    rts

seek($22E900)
    lda $4210   // native code overwritten by hook
    jsr $E910   // main MSU load code
    jsr $EE30   // play msu routine whin stream ready
    lda $012c   // native code overwritten by hook
    rtl

seek($22E910)
    lda $0133
    bne +       // if $0133 is #$0 return
    rts
+;  cmp #$F1    // if $0133 is #$F1 go to music fade out
    beq +
    jsr $E990   // load new track routine if no fade out
    rts
+;  lda $7EE004 // intermediate state (free ram) for fade-out
    bne +
    rts
+;  dec         // fade out decrease volume
    dec         // fade out decrease volume
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    cmp #$20    // check if fade out volume is below #$20
    bcc +
    sta $7EE004 // store fade out volume until next routine run
    sta $2006   // store to msu volume register
    rts
+;  lda #$00    // mute sound if volume level is below #$20
    sta $7EE004
    sta $2006
    stz $2005
    stz $0129
    rts

// this routine checks whether music register has to be muted -> this is the case
// when MSU is enabled
seek($22E950)
    sta $0133   // native code
    pha
    lda $2002   // check if MSU is enabled
    cmp #$53
    beq +
    pla
    sta $2140
    rtl         // if not return
+;  lda $2000
    and #$08    // if track missing -> spc fallback
    bne +
    lda #$F1
    sta $2140   // if MSU, mute $2140
+;  pla
    rtl

// SPC fallback (sd2snes only or bsnes 0.89 ff)
seek($22E970)
    lda $2000   // load MSU status
    and #$08    // isolate error bit (track not found)
    bne +
    rts
+;  lda $0129   // if error bit is set, play spc
    sta $2140
    sta $0133
    sta $0130
    stz $2007
    sta $012c
    rts

// track selector - MSU main code
seek($22E990)
    lda $0133   // load music register
    cmp #$F4    // check if mute, if yes return
    bne +
    rts
+;  cmp #$F1    // check if fade-out, if yes return
    bne +
    rts
+;  lda $2002   // check if msu-enabled, if not return
    cmp #$53
    beq +
    rts
+;  lda #$00    // reset fade-out counter
    sta $7EE004
    lda $0133   // load music register
    sta $0130   // part of native code
    cmp $0129   // check if track played already
    beq ++      // if played, return
    lda $0133   // load music register
    bne +
    lda $012c   // if #$00 load music control $012C
+;  sta $2004   // store track to play
    sta $0129   // store to free ram (msu track)
    stz $2005   // new track id
    stz $012C   // reset $012C
    lda #$FF
    sta $2006   // max volume
    lda #$01
    sta $0127   // store intermediate free ram to tell new track
    lda $2000   // check msu-status
    nop
    nop
    nop
    nop
    nop
    nop
    beq ++
+;  rts
+;  lda #$F1    // if msu enabled mute spc
    sta $2140
    sta $0133
    rts

// fade-out volume level decrease
seek($22E9F0)
fade_out:
    lda $2002   // check msu enabled
    cmp #$53
    bne ++      // if not -> native fade-out routine
    lda $7EE004 // check if fade-out counter already in fade-out mode
    bne +       // if yes, do not enable
    lda #$F1    // enable counter
    sta $7EE004
+;  lda #$F1    // fade-out mute registers
    sta $012C
    sta $0130
    sta $2140
    sta $0133
    rtl
+;  lda #$F1
    sta $012C
    rtl

// map music volume decrease
seek($22EA20)
map_open:
    lda $2002
    cmp #$53
    bne +
    lda #$75    // set volume to #$75 instead of #$FF
    sta $2006
    nop
    nop
    nop
    nop
    rtl
+;  lda #$F2
    sta $012C
    rtl

// restore full volume when back to game from map
seek($22EA50)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    nop
    nop
    nop
    nop
    rtl
+;  lda #$F3
    sta $012C
    rtl

// lower volume level when entering a house
seek($22EA80)
    cmp #$FF
    bne +
    rtl
+;  tax
    lda $2002
    cmp #$53
    beq +
    nop
    nop
    stx $012C
    rtl
+;  lda #$FF
    sta $2006
    cpx #$F2    // check if #$F2 (half volume) to be stored, if yes store it to $2006
    beq +
    cpx #$F3
    beq ++
    txa
    jmp $EDD0
+;  lda #$75    // if #$F2, store half volume
    sta $2006
    nop
    nop
+;  rtl

// these codes cover mainly all ingame spc changes to play the specific msu tracks
// it loads the track to be stored to $2004 and jumps to $EDD0 then
seek($22EAB0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$15
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$15
    sta $012c
    rtl

seek($22EAD0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$0B
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$0B
    sta $012C
    rtl

seek($22EB00)
    bne +
    ldx #$F3
+;  lda $2002
    cmp #$53
    bne ++
    lda #$FF
    sta $2006
    cpx #$F3
    beq +
    stx $2004
    txa
    jmp $EDD0
+;  jsr $E880
    sta $2007
    nop
    nop
    rtl
+;  stx $012C
    rtl

seek($22EB30)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$08
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$08
    sta $012C
    rtl

seek($22EB60)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$0A
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$0A
    sta $012C
    rtl

seek($22EB90)
    sep #$20
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    nop
    nop
    nop
    nop
    nop
    txa
    jmp $EDD0
    nop
    nop
    nop
    nop
    rtl
+;  nop
    nop
    stx $012C
    rtl

seek($22EBC0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$0C
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$0C
    sta $012C
    rtl

seek($22EBF0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$0E
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$0E
    sta $012C
    rtl

seek($22EC20)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$13
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$13
    sta $012C
    rtl

seek($22EC50)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$1A
    sta $0133
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$1A
    sta $012C
    rtl

seek($22EC80)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$1B
    stz $0129
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$1B
    sta $012C
    rtl

seek($22ECB0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$1D
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$1D
    sta $012C
    rtl

seek($22ECE0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$1E
    sta $0133
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    rtl
+;  lda #$1E
    sta $012C
    rtl

seek($22ED10)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$1F
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$1F
    sta $012C
    rtl

seek($22ED40)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$20
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$20
    sta $012C
    rtl

seek($22ED70)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$21
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$21
    sta $012C
    rtl

seek($22EDA0)
    lda $2002
    cmp #$53
    bne +
    lda #$FF
    sta $2006
    lda #$22
    nop
    nop
    nop
    jmp $EDD0
    nop
    nop
    nop
    nop
    nop
    rtl
+;  lda #$22
    sta $012C
    rtl

seek($22EDD0)
    sta $0130
    sta $012C
    rtl

// code when defeated a boss to let acquire crystal play until end before loading sage in crystal theme
seek($22EDD7)
    lda $2002
    cmp #$53
    beq ++
    lda $2140
    bne +
    jml $08C60B
+;  jml $08C613
+;  lda $2000
    and #$10
    bne +
    jml $08C60B
+;  jml $08C613

// code to play msu
seek($22EE30)
    lda $0127   // check if new track is induced
    beq +
    bit $2000   // check msu ready
    bvs +
    stz $0127   // reset inducing new track
    lda $0130
    jsr $E880   // select if track is repeated or not
    sta $2007
    jsr $E970   // spc fallback if track not found
+;  rts