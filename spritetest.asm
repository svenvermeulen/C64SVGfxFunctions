*=$1000

FlippedSprite = $2000

;Incasm "spriteroutines.asm"


MainProgram

        LDA #$0
        STA $D020

        JSR SVGFX_GenerateBitFlipLookupTable

        LDA #<OriginalSprite
        STA SVGFX_SPRSRC
        LDA #>OriginalSprite
        STA SVGFX_SPRSRC+1

        LDA #<FlippedSprite
        STA SVGFX_SPRDST
        LDA #>FlippedSprite
        STA SVGFX_SPRDST+1

        ;Jsr SVGFX_FlipSpriteH
        
        Jsr SVGFX_FlipSpriteV

        ; show sprite
        LDA #$80
        STA $D000       ; spr0 x
        LDA #$80
        STA $D001       ; spr0 y
        LDA #$0
        STA $D010       ; x coord high bits
        LDA #$1
        STA $d015        ; enable sprite 0

        LDA #$80
        STA $07F8       ; spr 0 pointer

        LDA #$2
        STA $D021

        RTS



OriginalSprite
        BYTE $F0,$00,$00
        BYTE $0F,$00,$00
        BYTE $00,$F0,$00
        BYTE $00,$0F,$00
        BYTE $00,$00,$F0
        BYTE $00,$00,$0F
        BYTE $00,$00,$03
        BYTE $00,$00,$0C
        BYTE $00,$00,$30
        BYTE $00,$00,$C0
        BYTE $00,$03,$00
        BYTE $00,$0C,$00
        BYTE $00,$30,$00
        BYTE $00,$C0,$00
        BYTE $03,$00,$00
        BYTE $0C,$00,$00
        BYTE $30,$00,$00
        BYTE $C0,$00,$00
        BYTE $20,$00,$00
        BYTE $10,$00,$00
        BYTE $08,$00,$00


;FlippedSprite
;        byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;        byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;        byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;        byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
