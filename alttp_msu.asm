//******************************************************************************
// alttp_msu.asm
// 
// Author:        qwertymodo
// Date Created:  1 Nov 2014
// Date Modified: 3 Nov 2014
// Assembler:     bass v14
//
// Implements MSU-1 audio streaming in The Legend of Zelda: A Link to the Past
// Original patch by Conn, disassembled by qwertymodo.  This file should produce
// a patch original to Conn's other than 2 minor changes to account for
// limitations in bass's anonymous labels.  Neither change affects the
// functionality of the code.
//
// This patch is intended to be applied directly by bass.  Patch should be
// applied to an unheadered ROM.  Requires expanded ROM, but bass can expand the
// ROM if EXPAND_ROM is defined below.
//
// Unheadered ROM MD5: 608C22B8FF930C62DC2DE54BCD6EBA72
//
// Usage: bass -o [romfile] alttp_msu.asm
//
// See README for more information
//
//******************************************************************************

arch snes.cpu

// Comment out this line if applying to an already expanded ROM
define EXPAND_ROM()

if {defined EXPAND_ROM} {
    origin 0x100000
    fill 0x80000, 0xFF
}

// Header checksum
origin 0x007FDC
    dw 0x5BF1 // Checksum complement
    dw 0xA40E // ROM checksum

// the following codes are hooks in the native rom – mainly when music is stored
// to the controller $012c
origin 0x0000D9
    jsl $22E900
    nop
    nop

origin 0x0000F3
    jsl $22E950
    nop
    nop

origin 0x00740F
    jsl $22EA80
    nop
    nop
    nop

origin 0x0079C3
    jsl $22E9F0
    nop

origin 0x010BFF
    jsr $FFD0

origin 0x01134F
    jsl $22EA80
    nop
    nop
    nop

origin 0x011A04
    jsl $22E9F0
    nop

origin 0x011B14
    jsl $22E9F0
    nop

origin 0x011D22
    jsl $22EB30
    nop

origin 0x012027
    jsl $22E9F0
    nop

origin 0x0120C1
    jsl $22ED40
    nop

origin 0x012141
    jsl $22ED70
    nop

origin 0x012AB1
    jsl $22E9F0
    nop

origin 0x012E7E
    jsl $22E9F0
    nop

origin 0x013225
    jsl $22EB30
    nop

origin 0x017FD0
    jsl $22EB90
    rts

origin 0x028928
    jsl $22EB60
    nop

origin 0x02CC5F
    jsl $22EBC0
    nop

origin 0x0330D8
    jsl $22EA20
    nop

origin 0x033112
    jsl $22EA50
    nop

origin 0x034621
    jsl $22EC80
    nop

origin 0x034847
    jsl $22EC80
    nop

origin 0x03AA9C
    jsl $22EA20
    nop

origin 0x03EB90
    jsl $22EA50
    nop

origin 0x044606
    jml $22EDD7
    nop
    jsl $22EC50
    nop

origin 0x044D07
    jsl $22E9F0
    nop

origin 0x04505C
    jsl $22EA50
    nop

origin 0x048D2C
    jsl $22EA20
    nop

origin 0x04A234
    jsl $22EAB0
    nop

origin 0x04EE44
    jsl $22EC20
    nop

origin 0x04F2B2
    jsl $22E9F0
    nop

origin 0x04F4A6
    jsl $22EAD0
    nop

origin 0x04F50F
    jsl $22E9F0
    nop

origin 0x053940
    jsl $22EB00
    nop
    nop
    nop

origin 0x053A1E
    jsl $22EA20
    nop

origin 0x053C90
    jsl $22EA50
    nop

origin 0x056FB5
    jsl $22EA50
    nop

origin 0x064DA7
    jsl $22EAD0
    nop

origin 0x064F7A
    jsl $22E9F0
    nop

origin 0x067105
    jsl $22E9F0
    nop

origin 0x073D16
    jsl $22EDA0
    nop

origin 0x075A31
    jsl $22EA20
    nop

origin 0x0E8D39
    jsl $22ECE0
    nop

origin 0x0E92F1
    jsl $22ED10
    nop

origin 0x0EFCCC
    jsl $22EBF0
    nop

origin 0x0F53FA
    jsl $22ECB0
    nop

// this code selects whether the current theme is repeated or played one
// time (store to $2007)
origin 0x116880
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

origin 0x116900
    lda $4210   // native code overwritten by hook
    jsr $E910   // main MSU load code
    jsr $EE30   // play msu routine whin stream ready
    lda $012c   // native code overwritten by hook
    rtl

origin 0x116910
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
origin 0x116950
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
origin 0x116970
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
origin 0x116990
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
origin 0x1169F0
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
origin 0x116A20
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
origin 0x116A50
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
origin 0x116A80
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
origin 0x116AB0
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

origin 0x116AD0
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

origin 0x116B00
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

origin 0x116B30
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

origin 0x116B60
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

origin 0x116B90
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

origin 0x116BC0
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

origin 0x116BF0
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

origin 0x116C20
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

origin 0x116C50
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

origin 0x116C80
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

origin 0x116CB0
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

origin 0x116CE0
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

origin 0x116D10
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

origin 0x116D40
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

origin 0x116D70
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

origin 0x116DA0
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

origin 0x116DD0
    sta $0130
    sta $012C
    rtl

// code when defeated a boss to let acquire crystal play until end before loading sage in crystal theme
origin 0x116DD7
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
origin 0x116E30
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