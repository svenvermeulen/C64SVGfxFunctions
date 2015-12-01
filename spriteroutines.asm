
*=$8000

; SpriteRoutines
; (C)2015 Sven Vermeulen


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






; Lookup table maps byte value to
; bits flipped value
; input value = index to table
; example %11000000 -> %00000011
SVGFX_LUT_SPRBITFLIP
        byte    %00000000, %10000000, %01000000, %11000000, %00100000, %10100000, %01100000, %11100000
        byte    %00010000, %10010000, %01010000, %11010000, %00110000, %10110000, %01110000, %11110000
        byte    %00001000, %10001000, %01001000, %11001000, %00101000, %10101000, %01101000, %11101000
        byte    %00011000, %10011000, %01011000, %11011000, %00111000, %10111000, %01111000, %11111000
        byte    %00000100, %10000100, %01000100, %11000100, %00100100, %10100100, %01100100, %11100100
        byte    %00010100, %10010100, %01010100, %11010100, %00110100, %10110100, %01110100, %11110100
        byte    %00001100, %10001100, %01001100, %11001100, %00101100, %10101100, %01101100, %11101100
        byte    %00011100, %10011100, %01011100, %11011100, %00111100, %10111100, %01111100, %11111100
        byte    %00000010, %10000010, %01000010, %11000010, %00100010, %10100010, %01100010, %11100010
        byte    %00010010, %10010010, %01010010, %11010010, %00110010, %10110010, %01110010, %11110010
        byte    %00001010, %10001010, %01001010, %11001010, %00101010, %10101010, %01101010, %11101010
        byte    %00011010, %10011010, %01011010, %11011010, %00111010, %10111010, %01111010, %11111010
        byte    %00000110, %10000110, %01000110, %11000110, %00100110, %10100110, %01100110, %11100110
        byte    %00010110, %10010110, %01010110, %11010110, %00110110, %10110110, %01110110, %11110110
        byte    %00001110, %10001110, %01001110, %11001110, %00101110, %10101110, %01101110, %11101110
        byte    %00011110, %10011110, %01011110, %11011110, %00111110, %10111110, %01111110, %11111110
        byte    %00000001, %10000001, %01000001, %11000001, %00100001, %10100001, %01100001, %11100001
        byte    %00010001, %10010001, %01010001, %11010001, %00110001, %10110001, %01110001, %11110001
        byte    %00001001, %10001001, %01001001, %11001001, %00101001, %10101001, %01101001, %11101001
        byte    %00011001, %10011001, %01011001, %11011001, %00111001, %10111001, %01111001, %11111001
        byte    %00000101, %10000101, %01000101, %11000101, %00100101, %10100101, %01100101, %11100101
        byte    %00010101, %10010101, %01010101, %11010101, %00110101, %10110101, %01110101, %11110101
        byte    %00001101, %10001101, %01001101, %11001101, %00101101, %10101101, %01101101, %11101101
        byte    %00011101, %10011101, %01011101, %11011101, %00111101, %10111101, %01111101, %11111101
        byte    %00000011, %10000011, %01000011, %11000011, %00100011, %10100011, %01100011, %11100011
        byte    %00010011, %10010011, %01010011, %11010011, %00110011, %10110011, %01110011, %11110011
        byte    %00001011, %10001011, %01001011, %11001011, %00101011, %10101011, %01101011, %11101011
        byte    %00011011, %10011011, %01011011, %11011011, %00111011, %10111011, %01111011, %11111011
        byte    %00000111, %10000111, %01000111, %11000111, %00100111, %10100111, %01100111, %11100111
        byte    %00010111, %10010111, %01010111, %11010111, %00110111, %10110111, %01110111, %11110111
        byte    %00001111, %10001111, %01001111, %11001111, %00101111, %10101111, %01101111, %11101111
        byte    %00011111, %10011111, %01011111, %11011111, %00111111, %10111111, %01111111, %11111111

