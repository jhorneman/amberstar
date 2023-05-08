
; In-game text routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 1-2-1991

;   "A simple peace
;     just can't be found
;      waste another day
;       blasting all the lives away
;    I've heard the thunder
;     underground
;      tunneling away
;       at the very soul of man"
;   I'm Running, Yes, 1987

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - All text must be in ASCII-format. The font isn't !!
;   - Special characters will be:
;          0 - end of text,
;          1 - set ink colour,
;          2 - set paper colour,
;         13 - end of line,
;         14 - backspace,
;          ~ - toggle rune font.

             .XDEF IG_Cursor_home,IG_Carriage_return,IG_Backspace
             .XDEF IG_Set_ink,IG_Set_paper,IG_Set_cursor
             .XDEF IG_Print,PArea

             .XREF DI_Error,Coord_convert

             .PATH 'E:\NUCLEUS\'

Max_areas    = 0       ; Maximum number of text areas

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; String in DATA segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Cursor Backspace routine ]
; All registers are restored
;*****************************************************************************
IG_Backspace:          
             move.l    d0,-(sp)
             move.w    Print_X,d0           ; Load X-coordinate
             subq.w    #6,d0                ; Backspace
             cmp.w     PArea,d0             ; Off screen ?
             bmi.s     .Exit
             move.w    d0,Print_X           ; Store new X-coordinate
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Cursor Home routine ]
; All registers are restored
;*****************************************************************************
IG_Cursor_home:        
             move.w    PArea,Print_X        ; Back to 1st column
             move.w    PArea+4,Print_Y      ; Back to 1st line
             rts       

;*****************************************************************************
; [ Carriage Return ]
; All registers are restored
;*****************************************************************************
IG_Carriage_return:    
             movem.l   d0/a0,-(sp)
             lea.l     PArea,a0
             move.w    (a0),Print_X         ; Back to 1st column
             move.w    Print_Y,d0           ; Load Y-coordinate
             addq.w    #7,d0                ; Next line
             cmp.w     6(a0),d0             ; Off screen ?
             bmi.s     .Skip
             move.w    4(a0),d0             ; Then back to 1st line
.Skip:       move.w    d0,Print_Y           ; Store new Y-coordinate
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Set IG_Ink ]
;  IN : d0 - New ink colour (.w)
; All registers are restored
;*****************************************************************************
IG_Set_ink:  
             move.l    d0,-(sp)
             cmpi.w    #16,d0               ; Legal input ?
             bmi.s     .Skip
             ERROR     "[ IG_Set_ink ] : Illegal input !!!"
             bra.s     .Exit
.Skip:       lsl.w     #3,d0                ; Multiply by 8
             move.w    d0,IG_Ink            ; Store
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Set IG_Paper ]
;  IN : d0 - New paper colour / -1 for transparency (.w)
; All registers are restored
;*****************************************************************************
IG_Set_paper:          
             move.l    d0,-(sp)
             tst.w     d0                   ; Transparent ?
             bpl.s     .Opaque
             move.w    d0,IG_Paper          ; Store
             move.l    #IG_Pchar_TRANS,Pchar_ptr
             bra.s     .Exit
.Opaque:     cmpi.w    #16,d0               ; Legal input ?
             bmi.s     .Skip
             ERROR     "[ IG_Set_paper ] : Illegal input !!!"
             bra.s     .Exit
.Skip:       lsl.w     #3,d0                ; Multiply by 8
             move.w    d0,IG_Paper          ; Store
             move.l    #IG_Pchar_OPAQUE,Pchar_ptr
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Set cursor position ]
;  IN : d0 - X-coordinate (.w)
;       d1 - Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
IG_Set_cursor:         
             move.w    d0,Print_X           ; Store new coordinates
             move.w    d1,Print_Y
             rts       

;*****************************************************************************
; [ Text printing routine ]
;   IN : a0 - Pointer to string (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
IG_Print:    
             movem.l   d0/a0/a1,-(sp)
.Again:      moveq.l   #0,d0                ; Load character from text
             move.b    (a0)+,d0             ; Check for {End of text}
             beq.s     .Exit
             cmpi.b    #13,d0               ; Check for {End of line}
             bne.s     .Skip1
             jsr       IG_Carriage_return   ; Carriage return
             bra.s     .Again
.Skip1:      cmpi.b    #1,d0                ; Check for {Set ink}
             bne.s     .Skip2
             move.b    (a0)+,d0             ; Set new ink
             ext.w     d0
             jsr       IG_Set_ink
             bra.s     .Again
.Skip2:      cmpi.b    #2,d0                ; Check for {Set paper}
             bne.s     .Skip3
             move.b    (a0)+,d0             ; Set new paper
             ext.w     d0
             jsr       IG_Set_paper
             bra.s     .Again
.Skip3:      cmpi.b    #14,d0               ; Check for {Backspace}
             bne.s     .Skip4
             jsr       IG_Backspace         ; Backspace
             bra.s     .Again
.Skip4:      cmpi.b    #"~",d0              ; Check for {Rune toggle}
             bne.s     .Skip5
             not.b     Rune_flag            ; Toggle runes
             bra.s     .Again
.Skip5:      movea.l   Pchar_ptr,a1         ; Print character
             jsr       (a1)
             bra.s     .Again
.Exit:       movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Transparent character print routine ]
;   IN : d0 - Character number (.b)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
IG_Pchar_TRANS:        
             movem.l   d0-d7/a0-a2,-(sp)
             lea.l     Text_conversion_tab-32,a0  ; Convert character
             tst.b     Rune_flag
             beq.s     .No_runes
             lea.l     Rune_conversion_tab-32,a0
.No_runes:   andi.w    #$00ff,d0
             move.b    0(a0,d0.w),d0
             bmi       .Exit
             lea.l     Little_font,a0       ; Calculate font address
             ext.w     d0
             adda.w    d0,a0
             lsl.w     #2,d0
             adda.w    d0,a0
             move.w    Print_X,d0           ; Calculate screen address
             move.w    Print_Y,d1           ; & shift value
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a1
             move.w    d3,d6
             lea.l     Colour_table,a2      ; Get pointer to colour
             adda.w    IG_Ink,a2
; ------------- Write first line (character only) --------------------
             moveq.l   #0,d0                ; Clear registers
             moveq.l   #0,d1
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d5
             move.b    (a0)+,d5             ; Load one line
             lsl.w     #8,d5
             move.w    d5,d0                ; Copy
             move.w    d5,d1
             move.w    d5,d2
             move.w    d5,d3
             and.w     (a2)+,d0             ; Colour masking
             and.w     (a2)+,d1
             and.w     (a2)+,d2
             and.w     (a2)+,d3
             subq.l    #8,a2                ; Correction
             ror.l     d6,d0                ; Rotate
             ror.l     d6,d1
             ror.l     d6,d2
             ror.l     d6,d3
             ror.l     d6,d5
             move.l    d5,d4                ; Calculate mask
             not.l     d4
             and.w     d4,(a1)              ; Display first half
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             swap.w    d0                   ; Swap to second half
             swap.w    d1
             swap.w    d2
             swap.w    d3
             swap.w    d4
             and.w     d4,(a1)              ; Display second half
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             lea.l     160-16(a1),a1        ; Next lines
; ------------- Write four lines (character + shadow) ----------------
             moveq.l   #4-1,d7
.Loop:       moveq.l   #0,d0                ; Clear registers
             moveq.l   #0,d1
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d5
             move.b    (a0)+,d5             ; Load one line
             lsl.w     #8,d5
             move.w    d5,d0                ; Copy
             move.w    d5,d1
             move.w    d5,d2
             move.w    d5,d3
             and.w     (a2)+,d0             ; Colour masking
             and.w     (a2)+,d1
             and.w     (a2)+,d2
             and.w     (a2)+,d3
             subq.l    #8,a2                ; Correction
             ror.l     d6,d0                ; Rotate
             ror.l     d6,d1
             ror.l     d6,d2
             ror.l     d6,d3
             moveq.l   #0,d4                ; Make shadow mask
             move.b    -2(a0),d4
             lsl.w     #7,d4
             or.w      d5,d4
             not.l     d4
             ror.l     d6,d4
             and.w     d4,(a1)              ; Display first half
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             swap.w    d0                   ; Swap to second half
             swap.w    d1
             swap.w    d2
             swap.w    d3
             swap.w    d4
             and.w     d4,(a1)              ; Display second half
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             swap.w    d4                   ; Next line
             lea.l     160-16(a1),a1
             dbra      d7,.Loop
; ------------- Write last line (shadow only) ------------------------
             moveq.l   #0,d4                ; Make shadow mask
             move.b    -1(a0),d4
             lsl.w     #7,d4
             not.l     d4
             ror.l     d6,d4
             and.w     d4,(a1)+             ; Display first half
             and.w     d4,(a1)+
             and.w     d4,(a1)+
             and.w     d4,(a1)+
             swap.w    d4                   ; Swap to second half
             and.w     d4,(a1)+             ; Display second half
             and.w     d4,(a1)+
             and.w     d4,(a1)+
             and.w     d4,(a1)+
; ------------- Update cursor position -------------------------------
             move.w    Print_X,d0           ; Load X-coordinate
             addq.w    #6,d0                ; Cursor forward
             cmp.w     PArea+2,d0           ; Check for end of line
             bmi.s     .Skip
             jsr       IG_Carriage_return
             bra.s     .Exit
.Skip:       move.w    d0,Print_X           ; Store new X-coordinate
.Exit:       movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Opaque character print routine ]
;   IN : d0 - Character number (.b)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
IG_Pchar_OPAQUE:       
             movem.l   d0-d7/a0-a2,-(sp)
             andi.w    #$00ff,d0
             move.w    d0,d6
; ------------- Clear character area ---------------------------------
             move.w    Print_X,d0           ; Calculate screen address
             move.w    Print_Y,d1
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a0
             move.l    #$ffff03ff,d0        ; Get mask
             ror.l     d3,d0
             move.l    d0,d1
             swap.w    d1
             moveq.l   #6-1,d7
.Loop1:      and.w     d0,(a0)+             ; Clear first 16 pixels
             and.w     d0,(a0)+
             and.w     d0,(a0)+
             and.w     d0,(a0)+
             and.w     d1,(a0)+             ; Clear second 16 pixels
             and.w     d1,(a0)+
             and.w     d1,(a0)+
             and.w     d1,(a0)+
             lea.l     160-16(a0),a0        ; Next line
             dbra      d7,.Loop1
; ------------- Fill character buffer with paper colour --------------
             lea.l     Colour_table,a0      ; Get pointer to colour
             move.w    IG_Paper,d0
             adda.w    d0,a0
             move.l    (a0)+,d0
             move.l    (a0)+,d1
             lea.l     Char_buffer,a0
             moveq.l   #6-1,d7              ; Fill character buffer
.Loop2:      move.l    d0,(a0)+
             move.l    d1,(a0)+
             dbra      d7,.Loop2
; ------------- Put character in buffer ------------------------------
             lea.l     Text_conversion_tab-32,a0  ; Convert character
             tst.b     Rune_flag
             beq.s     .No_runes
             lea.l     Rune_conversion_tab-32,a0
.No_runes:   move.b    0(a0,d6.w),d0
             bmi       .Exit
             lea.l     Little_font,a0       ; Calculate font address
             ext.w     d0
             adda.w    d0,a0
             lsl.w     #2,d0
             adda.w    d0,a0
             lea.l     Colour_table,a1      ; Get pointer to colour
             adda.w    IG_Ink,a1
             lea.l     Char_buffer,a2
             moveq.l   #5-1,d7
.Loop3:      move.b    (a0)+,d0             ; Get line and duplicate twice
             lsl.w     #8,d0
             move.w    d0,d1
             swap.w    d0
             move.w    d1,d0
             move.l    d0,d1                ; Duplicate & invert
             not.l     d0
             move.l    d0,d2                ; Do shadow line
             ror.l     #1,d2
             and.l     d2,8(a2)
             and.l     d2,12(a2)
             move.l    d0,d2                ; Duplicate
             move.l    d1,d3
             or.l      (a1),d0              ; Colour masking
             and.l     (a1),d1
             or.l      4(a1),d2
             and.l     4(a1),d3
             move.l    (a2),d4              ; Write line to buffer
             and.l     d0,d4
             or.l      d1,d4
             move.l    d4,(a2)+
             move.l    (a2),d4
             and.l     d2,d4
             or.l      d3,d4
             move.l    d4,(a2)+
             dbra      d7,.Loop3            ; Next line
; ------------- Put character buffer on screen -----------------------
             lea.l     Char_buffer,a0
             move.w    Print_X,d0           ; Calculate screen address
             move.w    Print_Y,d1
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a1
             move.w    d3,d6
             moveq.l   #6-1,d7
.Loop4:      moveq.l   #0,d0                ; Clear registers
             moveq.l   #0,d1
             moveq.l   #0,d2
             moveq.l   #0,d3
             move.w    (a0)+,d0             ; Load one line
             move.w    (a0)+,d1
             move.w    (a0)+,d2
             move.w    (a0)+,d3
             ror.l     d6,d0                ; Rotate
             ror.l     d6,d1
             ror.l     d6,d2
             ror.l     d6,d3
             or.w      d0,(a1)+             ; Display first half
             or.w      d1,(a1)+
             or.w      d2,(a1)+
             or.w      d3,(a1)+
             swap.w    d0                   ; Swap to second half
             swap.w    d1
             swap.w    d2
             swap.w    d3
             or.w      d0,(a1)+             ; Display second half
             or.w      d1,(a1)+
             or.w      d2,(a1)+
             or.w      d3,(a1)+
             lea.l     160-16(a1),a1        ; Next line
             dbra      d7,.Loop4
; ------------- Update cursor position -------------------------------
             move.w    Print_X,d0           ; Load X-coordinate
             addq.w    #6,d0                ; Cursor forward
             cmp.w     PArea+2,d0           ; Check for end of line
             bmi.s     .Skip
             jsr       IG_Carriage_return
             bra.s     .Exit
.Skip:       move.w    d0,Print_X           ; Store new X-coordinate
.Exit:       movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
PArea:       .DC.w 0,320-5,0,200-6

; This is the table used for conversion from ASCII to the little font.
; The first 32 characters aren't included.
Text_conversion_tab:   
             .DC.b 58,36,35,44,-1,42,-1,34  ; spc !"#$%&'
             .DC.b 40,41,38,46,32,45,33,43  ; ()*+,-./
             .DC.b 48,49,50,51,52,53,54,55,56,57  ; 0123456789
             .DC.b 31,30,-1,47,-1,37,-1     ; :;<=>?@
             .DC.b 0,1,2,3,4,5,6,7,8,9      ; ABCDEFGHIJ
             .DC.b 10,11,12,13,14,15,16,17,18,19  ; KLMNOPQRST
             .DC.b 20,21,22,23,24,25        ; UVWXYZ
             .DC.b -1,-1,-1,-1,39,-1        ; [\]^_`
             .DC.b 0,1,2,3,4,5,6,7,8,9      ; abcdefghij
             .DC.b 10,11,12,13,14,15,16,17,18,19  ; klmnopqrst
             .DC.b 20,21,22,23,24,25        ; uvwxyz
             .DCB.b 6,-1                    ; {|}~Ç
             .DC.b 27,-1,-1,26              ; üéâä
             .DCB.b 9,-1                    ; à...ì
             .DC.b 26  ;                          Ä
             .DCB.b 5,-1                    ; Å...ô
             .DC.b 28  ;                          ö
             .DCB.b 4,-1                    ; ò...ÿ
             .DC.b 28,27                    ; ÖÜ
             .DCB.b 3,-1                    ; ¢...¥
             .DC.b 29  ;                          ß
             .DCB.b 97,-1                   ; ƒ...¯
Rune_conversion_tab:   
             .DC.b 58,36,35,44,-1,42,-1,34  ; spc !"#$%&'
             .DC.b 40,41,38,46,32,45,33,43  ; ()*+,-./
             .DC.b 48,49,50,51,52,53,54,55,56,57  ; 0123456789
             .DC.b 31,30,-1,47,-1,37,-1     ; :;<=>?@
             .DC.b 59,60,61,62,63,64,65,66,67,68  ; ABCDEFGHIJ
             .DC.b 69,70,71,72,73,74,75,76,77,78  ; KLMNOPQRST
             .DC.b 79,80,81,82,83,84        ; UVWXYZ
             .DC.b -1,-1,-1,-1,39,-1        ; [\]^_`
             .DC.b 59,60,61,62,63,64,65,66,67,68  ; abcdefghij
             .DC.b 69,70,71,72,73,74,75,76,77,78  ; klmnopqrst
             .DC.b 79,80,81,82,83,84        ; uvwxyz
             .DCB.b 6,-1                    ; {|}~Ç
             .DC.b 85,-1,-1,86              ; üéâä
             .DCB.b 9,-1                    ; à...ì
             .DC.b 86  ;                          Ä
             .DCB.b 5,-1                    ; Å...ô
             .DC.b 87  ;                          ö
             .DCB.b 4,-1                    ; ò...ÿ
             .DC.b 87,85                    ; ÖÜ
             .DCB.b 3,-1                    ; ¢...¥
             .DC.b 88  ;                          ß
             .DCB.b 97,-1                   ; ƒ...¯

Little_font: .IBYTES 'LITLFONT.GFX'
             .DCB.b 5,0                     ; Space
             .IBYTES 'RUNEFONT.GFX'
             .EVEN 

Colour_table:          .DC.w 0,0,0,0
             .DC.w $fc00,0,0,0
             .DC.w 0,$fc00,0,0
             .DC.w $fc00,$fc00,0,0
             .DC.w 0,0,$fc00,0
             .DC.w $fc00,0,$fc00,0
             .DC.w 0,$fc00,$fc00,0
             .DC.w $fc00,$fc00,$fc00,0
             .DC.w 0,0,0,$fc00
             .DC.w $fc00,0,0,$fc00
             .DC.w 0,$fc00,0,$fc00
             .DC.w $fc00,$fc00,0,$fc00
             .DC.w 0,0,$fc00,$fc00
             .DC.w $fc00,0,$fc00,$fc00
             .DC.w 0,$fc00,$fc00,$fc00
             .DC.w $fc00,$fc00,$fc00,$fc00

IG_Ink:      .DC.w 8   ; Print colours
IG_Paper:    .DC.w 0
Pchar_ptr:   .DC.l IG_Pchar_TRANS


             .BSS 

Print_X:     .DS.w 1   ; Cursor coordinates in pixels
Print_Y:     .DS.w 1
Char_buffer: .DS.w 4*6
Rune_flag:   .DS.b 1
             .EVEN 

             .END 




