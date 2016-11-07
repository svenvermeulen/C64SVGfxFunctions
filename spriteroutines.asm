
*=$8000

; SpriteRoutines
; 2015 Sven Vermeulen


; General purpose pointers
; These are used by various routines as specified in the
; documentation of each routine
; Note: not thread-safe (LOL but actually means: do NOT use
; from both Raster-interrupt and non-raster interrupt code)


; Sprite Copy / Flip related pointers
; To be able to use ($xx),Y Indirect Indexed mode, these should be
; in the zero page.
SVGFX_SPRSRC = $40
SVGFX_SPRDST = $42
        


; Flip a sprite horizontally
; Uses global registers:
; (R) SVGFX_SPRSRC address of source sprite
; (R) SVGFX_SPRDST address of destination sprite
; NOTE: PLEASE CALL SVGFX_GenerateBitFlipLookupTable ONCE BEFORE USING
SVGFX_FlipSpriteH
        LDY #$0                         ; src index
SVGFX_Loop_FlipSpriteH
        LDA (SVGFX_SPRSRC),Y            ; load original byte                     
        TAX                             ; use original byte as index into bitflip table
        LDA SVGFX_LUT_SPRBITFLIP,X      ; A now containes flipped bits

        INY                             ; first read byte goes to third output byte
        INY
        STA (SVGFX_SPRDST),y            ; store at destination+Y bytes
        DEY                             ; go back 1 byte... net result = 1 forward
        
        LDA (SVGFX_SPRSRC),Y            ; second original byte
        TAX
        LDA SVGFX_LUT_SPRBITFLIP,X
        STA (SVGFX_SPRDST),y            ; second read byte goes to second output
        INY

        LDA (SVGFX_SPRSRC),Y            ; third input byte
        TAX
        LDA SVGFX_LUT_SPRBITFLIP,X
        DEY
        DEY
        STA (SVGFX_SPRDST),y            ; third input byte goes to first output
        INY                             ; move to next line
        INY
        INY

        CPY #63
        BNE SVGFX_Loop_FlipSpriteH

        RTS





; Flip a sprite vertically
; Uses global registers:
; (R) SVGFX_SPRSRC address of source sprite
; (R) SVGFX_SPRDST address of destination sprite
; note about implementation:
; we need the Y register for Indirect Indexed addressing for both
; the source and the destination locations, so the Y register
; "bounces" up and down the whole time.
SVGFX_FlipSpriteV
        LDY #$0                         ; src index
SVGFX_Loop_FlipSpriteV
        ; FIRST BYTE ON LINE
        LDA (SVGFX_SPRSRC),Y            ; load original byte                     
                
        TAX                             ; save data in X for a bit
        TYA                             ; make Y = 60-Y
        EOR #$FF
        SEC
        ADC #60
        TAY                             ; ok, Y is now 60-Y
        
        TXA                             ; put back the data byte in A
        STA (SVGFX_SPRDST),Y            ; save the data to pos. dest+60-Y

        TYA                             ; Point Y to previous in position plus 1
        EOR #$FF                        ; which means Y = 61-Y
        SEC
        ADC #61
        TAY

        ; SECOND BYTE ON LINE
        LDA (SVGFX_SPRSRC),Y            ; load original byte                     
                
        TAX                             ; save data in X for a bit
        TYA                             ; make Y = 62-Y
        EOR #$FF
        SEC
        ADC #62
        TAY                             ; ok, Y is now 62-Y
        
        TXA                             ; put back the data byte in A
        STA (SVGFX_SPRDST),Y            ; save the data to pos. dest+61-Y

        TYA                             ; Point Y to previous in position plus 1
        EOR #$FF                        ; which means Y = 63-Y
        SEC
        ADC #63
        TAY
        
        
        ; THIRD BYTE ON LINE
        LDA (SVGFX_SPRSRC),Y            ; load original byte                     
                
        TAX                             ; save data in X for a bit
        TYA                             ; make Y = 64-Y
        EOR #$FF
        SEC
        ADC #64
        TAY                             ; ok, Y is now 64-Y
        
        TXA                             ; put back the data byte in A
        STA (SVGFX_SPRDST),Y            ; save the data to pos. dest+62-Y

        TYA                             ; Point Y to previous in position plus 1
        EOR #$FF                        ; which means Y = 65-Y
        SEC
        ADC #65
        TAY
        



        CPY #63
        BNE SVGFX_Loop_FlipSpriteV

        RTS



; Generates a lookup table for bit flipping (for use by horizontal single-sprite flipper)
SVGFX_GenerateBitFlipLookupTable
        LDX #$1         ; Original Value = Offset into table
                        ; byte 0 needs not be calculated so I start at 1
                        ; Y will be used for tmp storage
        LDA #$0         ; A will be used for calculating result
        STA SVGFX_LUT_SPRBITFLIP
SVGFX_Loop_GenBFLT
        
        LDY #$0         ; count bitshift iterations for current input value
        TXA             ; A will be calculated based on current offset (x)
SVGFX_GBF_Bit0
        TXA             ; A will be calculated based on current offset (x)
        AND #%00000001
        BEQ SVGFX_GBF_Bit1
        TYA
        ORA #%10000000
        TAY
SVGFX_GBF_Bit1
        TXA
        AND #%00000010
        BEQ SVGFX_GBF_Bit2
        TYA
        ORA #%01000000
        TAY
SVGFX_GBF_Bit2
        TXA
        AND #%00000100
        BEQ SVGFX_GBF_Bit3
        TYA
        ORA #%00100000
        TAY
SVGFX_GBF_Bit3
        TXA
        AND #%00001000
        BEQ SVGFX_GBF_Bit4
        TYA
        ORA #%00010000
        TAY
SVGFX_GBF_Bit4
        TXA
        AND #%00010000
        BEQ SVGFX_GBF_Bit5
        TYA
        ORA #%00001000
        TAY
SVGFX_GBF_Bit5
        TXA
        AND #%00100000
        BEQ SVGFX_GBF_Bit6
        TYA
        ORA #%00000100
        TAY
SVGFX_GBF_Bit6
        TXA
        AND #%01000000
        BEQ SVGFX_GBF_Bit7
        TYA
        ORA #%00000010
        TAY
SVGFX_GBF_Bit7
        TXA
        AND #%10000000
        BEQ SVGFX_GBF_NextByte
        TYA
        ORA #%00000001
        TAY
SVGFX_GBF_NextByte
        TYA             ; cannot remove this because previous TAY is not ALWAYS executed
        STA SVGFX_LUT_SPRBITFLIP,x
        INX             ; next byte please
        CPX #$FF
        BNE SVGFX_Loop_GenBFLT

        TXA
        STA SVGFX_LUT_SPRBITFLIP,x

        RTS             ; all done


; Lookup table maps byte value to
; bits flipped value
; input value = index to table
; example %11000000 -> %00000011
SVGFX_LUT_SPRBITFLIP
        bytes   $ff
