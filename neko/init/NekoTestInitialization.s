; Copyright (C) 2018 Georg Ziegler
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of
; this software and associated documentation files (the "Software"), to deal in
; the Software without restriction, including without limitation the rights to
; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
; of the Software, and to permit persons to whom the Software is furnished to do
; so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
; -----------------------------------------------------------------------------
;   File: NekoTestInitialization.s
;   Author(s): Georg Ziegler
;   Description: This file contains subroutines to initialize the basic cradle
;   data and variables.
;

;----- Includes ----------------------------------------------------------------
.include "NekoLib.inc"
.include "SNESRegisters.inc"
.include "WRAMPointers.inc"
.include "TileData.inc"
;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816
.i16
.a8
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Routines found in this file
;-------------------------------------------------------------------------------
.export     InitNekoCradle      ; Load basic tile sets and map
.export     InitVariables       ; Initialize the variables in WRAM
.export     ResetOAM            ; Resets the OAM to $ff
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   Subroutine: InitNekoCradle
;   Parameters: -
;   Description: Load tile sets and maps, and sprite sheet into V-RAM
;-------------------------------------------------------------------------------
.proc   InitNekoCradle
        PreserveRegisters       ; preserve working registers

        ; load Chess Tile Set
        tsx                     ; save stack pointer
        PushSizeF $002000       ; move $002000 bytes
        PushSizeB $01           ; destination segment $01
        PushFarAddr ChessTileSet  ; source address
        lda #LoadTileSetOpcode
        jsl NekoLibLauncher
        txs                     ; restore stack pointer
        ; Chess Tile Set loaded

        ; load chess palette
        PushSizeB $0c           ; move 12 bytes
        PushSizeB $00           ; destination: palette $00
        PushFarAddr ChessPalette
        lda #LoadPaletteOpcode
        jsl NekoLibLauncher
        txs                     ; restore stack pointer
        ; chess palette loaded

        ; load tile map into VRAM
        PushSizeF $000800       ; move 2KB
        PushSizeB $00           ; destination: $0000
        PushFarAddr ChessTileMap
        lda #LoadTileMapOpcode
        jsl NekoLibLauncher
        txs                     ; restore stack pointer

        ; load neko sprite sheet
        PushSizeF $004000       ; move $004000 bytes
        PushSizeB $02           ; destination segment $4000
        PushFarAddr NekoSpriteSheet
        lda #LoadTileSetOpcode
        jsl NekoLibLauncher
        txs                     ; restore stack pointer

        ; load Neko Palette
        PushSizeB $20           ; move 32 bytes
        PushSizeB $80           ; destination: palette $80
        PushFarAddr NekoPalette
        lda #LoadPaletteOpcode
        jsl NekoLibLauncher
        txs                     ; restore stack pointer

        ; set background options
        lda #$21                ; set to BG Mode 1, BG2 tile size to 16 x 16
        sta BGMODE
        lda #$10                ; set BG2 base address
        sta BG12NBA
        lda #$00                ; set BG2 SC address to VRAM address $0000
        sta BG2SC

        ; set object options
        lda #$21                ; set OAM Address to $4000, size 8 / 32
        sta OBJSEL

        RestoreRegisters        ; restore working registers
        rtl
.endproc
;----- end of subroutine InitNekoCradle ----------------------------------------

;-------------------------------------------------------------------------------
;   Subroutine: InitVariables
;   Parameters: -
;   Description: Initialize variables in WRAM
;-------------------------------------------------------------------------------
.proc   InitVariables
        PreserveRegisters       ; preserve working registers

        ; set neko start position
        ldx #$0000
        lda #$40
        sta OAM, x              ; HPos
        inx
        sta OAM, x              ; VPos
        inx
        lda #$08                ; Name/Sprite
        sta OAM, x
        inx
        lda #$20                ; attribute
        sta OAM, x              ; no flip, priority 2, palette 0

        ; set sprite size
        ldx #$0200
        lda #$fa                ; size large for objects 0 and 1
        sta OAM, x

        ; set frame counter and offset
        lda #$00
        sta NekoFrameCount
        sta NekoFrameOffset

        ; initialize background offsets
        stz BG1HOffset
        stz BG1VOffset
        stz BG2HOffset
        stz BG2VOffset
        stz BG3HOffset
        stz BG3VOffset

        RestoreRegisters        ; restore working registers
        rtl
.endproc
;----- end of subroutine InitVariables -----------------------------------------

;-------------------------------------------------------------------------------
;   Subroutine: ResetOAM
;   Parameters: -
;   Description: Reset OAM to $ff
;-------------------------------------------------------------------------------
.proc   ResetOAM
        PreserveRegisters       ; preserve working registers

        ldx #$0000
        lda #$ff
loop:   sta OAM, x
        inx
        cpx #$0221
        bne loop

        RestoreRegisters        ; restore working registers
        rtl
.endproc
;----- end of subroutine ClearRegisters ----------------------------------------
