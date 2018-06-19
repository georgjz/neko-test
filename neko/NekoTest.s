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
;

;----- Includes ----------------------------------------------------------------
.include "SNESRegisters.inc"
.include "WRAMPointers.inc"
.include "TileData.inc"
.include "NekoTestInitialization.inc"
.include "Neko.inc"

.include "NekoLib.inc"
; .include "NekoLibLauncher.inc"
; .include "CPUMacros.inc"
;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816
.i16
.a8
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Exports of subroutines for use in other files
;-------------------------------------------------------------------------------
.export     ResetHandler
.export     NMIHandler
.export     IRQHandler
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   This is the entry point of the cradle
;-------------------------------------------------------------------------------
.proc   ResetHandler
        ; sei                     ; disable interrupts
        ; clc                     ; set to native mode
        ; xce
        SetXY16
        SetA8
        ldx #$1fff              ; set up stack
        txs
        lda #$8f                ; force v-blanking
        sta INIDISP
        stz NMITIMEN            ; disable NMI

        ; use the Neko Lib Launcher to call library subroutines
        lda #ClearRegistersOpcode ; load library subroutine opcode into A
        jsl NekoLibLauncher     ; launcher calls library subroutine
        lda #ClearVRAMOpcode    ; rinse and repeat
        jsl NekoLibLauncher
        lda #ClearCGRAMOpcode   ; rinse and repeat
        jsl NekoLibLauncher
        phk                     ; restore data bank register
        plb

        jsl ResetOAM
        jsl InitNekoCradle      ; initalize neko cradle data
        jsl InitVariables       ; set up WRAM variables

        ; make BG2 and Objects visible
        lda #$12
        sta TM
        ; release forced blanking
        lda #$0f
        sta INIDISP
        ; enable NMI, turn on automatic joypad polling
        lda #$81
        sta NMITIMEN

        nop                     ; break point for debugger

        jml GameLoop
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   After the ResetHandler will jump to here
;-------------------------------------------------------------------------------
.proc   GameLoop
        wai                     ; wait for NMI / V-Blank

        jsr UpdateNeko          ; handle inputs and events for neko

        jmp GameLoop
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Will be called during V-Blank
;-------------------------------------------------------------------------------
.proc   NMIHandler
        lda RDNMI                   ; read NMI status, aknowledge NMI

        ; read input
        lda #PollJoypad1Opcode
        jsl NekoLibLauncher

        ; transfer OAM data
        tsx                         ; save stack pointer
        PushFarAddr OAM
        lda #UpdateOAMRAMOpcode
        jsl NekoLibLauncher
        txs                         ; restore stack pointer

        rti
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Is not used in this program
;-------------------------------------------------------------------------------
.proc   IRQHandler
        ; code
        rti
.endproc
;-------------------------------------------------------------------------------
