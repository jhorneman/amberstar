
; Diagnostic routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 30-1-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - The printing routines only work in medium resolution.
;   - They are meant for diagnostic screens only.
;   - They require Line-A for the system font.
;   - The Error routine uses the original screen buffer.
;   - All text must be in ASCII-format. Special characters are :
;          0 - end of text,
;          1 - inverse on,
;          2 - inverse off,
;          3 - set ink colour (to next byte in text),
;         13 - end of line, and
;         14 - backspace.
;   - To use the Error routine, include the following macro in the main
;     source :
;             .MACRO ERROR error_msg
;             lea.l      .\~ET,a1             ; Call error routine
;             jsr        DI_Error
;             .SECTION 4,DATA
;.\~ET:   .DC.b \1,13,0                       ; String in DATA segment
;             .TEXT
;             .ENDM

             .XDEF DI_Error,ON_Diag_screen,OFF_Diag_screen
             .XDEF Init_DI_print,DI_Print,DI_Input
             .XDEF DI_Cursor_home,DI_Carriage_return,DI_Backspace
             .XDEF DI_Hexb_print,DI_Hexw_print,DI_Hexl_print
             .XDEF DI_Decb_print,DI_Decw_print,DI_Decl_print

             .XREF Screen_base,Mouse_on,Mouse_off,HBL_on,HBL_off
             .XREF My_vsync,Set_screen,Clear_screen,Wait_4_key
             .XREF Old_screen,Hex_convert,Dec_convert

             .PATH 'E:\MAIN\'
             .INCLUDE 'CONST5X.IS'
             .INCLUDE 'MACRO4X.IS'

Max_digits   = 4       ; Maximum number of input digits

             .TEXT 
;*****************************************************************************
; [ Error message routine ]
;   IN : a1 - Pointer to error message (.l)
; All registers are restored
;*****************************************************************************
DI_Error:    
             movem.l   d0-d2/a0-a2/a6,-(sp)
             jsr       ON_Diag_screen       ; Switch to diagnostic screen
             movea.l   Screen_base,a6
             jsr       DI_Cursor_home       ; Cursor home
             lea.l     Error_msg1,a0        ; Print error message part 1
             jsr       DI_Print
             movea.l   a1,a0                ; Print error message
             jsr       DI_Print
             lea.l     Error_msg2,a0        ; Print error message part 2
             jsr       DI_Print
             C_RAWCIN  ; Wait for a key
             cmpi.b    #"x",d0              ; Exit on 'x'
             bne.s     .Exit
             illegal 
.Exit:       jsr       OFF_Diag_screen      ; Switch back
             movem.l   (sp)+,d0-d2/a0-a2/a6
             rts       

;*****************************************************************************
; [ Switch to diagnostic screen ]
; All registers are restored
;*****************************************************************************
ON_Diag_screen:        
             movem.l   d0/a0/a6,-(sp)
             jsr       Mouse_off            ; Mouse off
             move.l    Colour_0,Old_pal     ; Save palette
             move.l    Colour_2,Old_pal+4
             move.l    Screen_base,Prev_screen
             jsr       HBL_off              ; HBL's off
             jsr       My_vsync
             move.b    #1,Shift_mode        ; Med rez
             moveq.l   #0,d0                ; Set new screen base
             move.w    Old_screen,d0
             lsl.l     #8,d0
             jsr       Set_screen
             movea.l   Screen_base,a6       ; Clear the screen
             jsr       Clear_screen
             move.l    Diag_pal,Colour_0    ; Set palette
             move.l    Diag_pal+4,Colour_2
             movem.l   (sp)+,d0/a0/a6
             rts       

;*****************************************************************************
; [ Switch from diagnostic screen ]
; All registers are restored
;*****************************************************************************
OFF_Diag_screen:       
             move.l    a0,-(sp)
             jsr       My_vsync
             move.b    #0,Shift_mode        ; Low rez
             move.l    Old_pal,Colour_0     ; Restore palette
             move.l    Old_pal+4,Colour_2
             move.l    Prev_screen,d0       ; Restore screen base
             jsr       Set_screen
             jsr       HBL_on               ; HBL's off
             jsr       Mouse_on             ; Mouse on
             movea.l   (sp)+,a0
             rts       

;*****************************************************************************
; [ Initialize print routines ]
; No registers are restored
;*****************************************************************************
Init_DI_print:         
             .DC.w $a000                    ; Get & store Line-A font base
             move.l    -22(a0),DI_Font_ptr
             rts       

;*****************************************************************************
; [ Cursor Home routine ]
; All registers are restored
;*****************************************************************************
DI_Cursor_home:        
             clr.w     Print_X              ; Back to 1st column
             clr.w     Print_Y              ; Back to top of screen
             rts       

;*****************************************************************************
; [ Carriage Return routine ]
; All registers are restored
;*****************************************************************************
DI_Carriage_return:    
             move.l    d0,-(sp)
             clr.w     Print_X              ; Back to 1st column
             move.w    Print_Y,d0           ; Load y-coordinate
             addi.w    #8*160,d0            ; Next line
             cmpi.w    #32000,d0            ; Off screen ?
             bmi.s     .Exit
             moveq.l   #0,d0                ; Then back to top of screen
.Exit:       move.w    d0,Print_Y           ; Store new y-coordinate
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Cursor Backspace routine ]
; All registers are restored
;*****************************************************************************
DI_Backspace:          
             move.l    d0,-(sp)
             move.w    Print_X,d0           ; Load X-coordinate
             btst      #0,d0                ; Odd column ?
             bne.s     .Odd_address
             subq.w    #3,d0                ; Previous column
             bra.s     .Skip
.Odd_address:          subq.w               #1,d0 ; Previous column
.Skip:       tst.w     d0                   ; Check for end of line
             bmi.s     .Exit
             move.w    d0,Print_X           ; Store new X-coordinate
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Input a number ]
;   IN : a0 - Pointer to input message (.l)
;        a6 - Screen base (.l)
;  OUT : d0 - Number / -1 = no input (.l)
; Changed registers : d0
;*****************************************************************************
DI_Input:    
             movem.l   d2-d4/d7/a0/a1,-(sp)
             jsr       DI_Print             ; Print input message
             lea.l     Output_string,a0     ; Initialize registers
             lea.l     Input_buffer,a1
             moveq.l   #0,d7
             move.b    #" ",1(a0)           ; Clear from previous input
             jsr       DI_Print             ; Print cursor
.Again:      jsr       Wait_4_key           ; Read a key
             cmpi.b    #$d,d0               ; Return ?
             beq       .Return
             swap.w    d0                   ; Backspace ?
             cmpi.b    #$e,d0
             beq       .Backspace
             swap.w    d0
             cmpi.b    #"0",d0              ; Legal digit ?
             bmi.s     .Again
             cmpi.b    #"9",d0
             bhi.s     .Again
             move.b    d0,1(a0)             ; Print digit
             jsr       DI_Print
             subi.b    #"0",d0              ; Scale down
             addq.l    #1,d7                ; Next digit
             move.b    d0,-1(a1,d7.w)       ; Store digit
             cmpi.b    #Max_digits,d7       ; Last digit ?
             bmi.s     .Again
             bra.s     .Return
.Backspace:  tst.w     d7                   ; First digit ?
             beq       .Again
             lea.l     Backspace_string,a0  ; Print cursor
             jsr       DI_Print
             lea.l     Output_string,a0
             subq.l    #1,d7                ; Previous digit
             bra.s     .Again
.Return:     lea.l     End_string,a0        ; Print end string
             jsr       DI_Print
             moveq.l   #0,d0                ; Number is zero
             moveq.l   #1,d2                ; Initialize registers
             moveq.l   #10,d3
             subq.l    #1,d7                ; DBRA correction
             bpl.s     .Loop                ; Exit if no digits
             moveq.l   #-1,d0               ; Indicate no input
             bra.s     .Exit
.Loop:       moveq.l   #0,d4                ; Load digit
             move.b    0(a1,d7.w),d4
             mulu.w    d2,d4                ; 10th power
             add.l     d4,d0
             mulu.w    d3,d2                ; Next digit
             dbra      d7,.Loop
.Exit:       movem.l   (sp)+,d2-d4/d7/a0/a1
             rts       

;*****************************************************************************
; [ Hexadecimal number (BYTE) print routine ]
;   IN : d0 - Number (.b)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Hexb_print:         
             movem.l   d7/a0,-(sp)
             moveq.l   #2,d7                ; Convert 2 digits
             jsr       Hex_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Hexadecimal number (WORD) print routine ]
;   IN : d0 - Number (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Hexw_print:         
             movem.l   d7/a0,-(sp)
             moveq.l   #4,d7                ; Convert 4 digits
             jsr       Hex_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Hexadecimal number (LONGWORD) print routine ]
;   IN : d0 - Number (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Hexl_print:         
             movem.l   d7/a0,-(sp)
             moveq.l   #8,d7                ; Convert 8 digits
             jsr       Hex_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Decimal number (BYTE) print routine ]
;   IN : d0 - Number (.b)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Decb_print:         
             movem.l   d7/a0,-(sp)
             ext.w     d0                   ; Extend number
             ext.l     d0
             moveq.l   #3,d7                ; Convert 3 digits
             jsr       Dec_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Decimal number (WORD) print routine ]
;   IN : d0 - Number (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Decw_print:         
             movem.l   d7/a0,-(sp)
             ext.l     d0                   ; Extend number
             moveq.l   #5,d7                ; Convert 5 digits
             jsr       Dec_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Decimal number (LONGWORD) print routine ]
;   IN : d0 - Number (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Decl_print:         
             movem.l   d7/a0,-(sp)
             moveq.l   #10,d7               ; Convert 10 digits
             jsr       Dec_convert
             jsr       DI_Print             ; Print
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Text printing routine ]
;   IN : a0 - Pointer to string (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Print:    
             movem.l   d0/a0/a1,-(sp)
             movea.l   DI_Font_ptr,a1       ; Load font pointer
.Again:      moveq.l   #0,d0                ; Load character from text
             move.b    (a0)+,d0             ; Check for {End of text}
             beq.s     .Exit
             cmpi.b    #13,d0               ; Check for {End of line}
             bne.s     .Skip1
             jsr       DI_Carriage_return   ; Carriage return
             bra.s     .Again
.Skip1:      cmpi.b    #1,d0                ; Check for {Inverse on}
             bne.s     .Skip2
             move.w    #-1,Inverse          ; Inverse on
             bra.s     .Again
.Skip2:      cmpi.b    #2,d0                ; Check for {Inverse off}
             bne.s     .Skip3
             move.w    #0,Inverse           ; Inverse off
             bra.s     .Again
.Skip3:      cmpi.b    #3,d0                ; Check for {Set ink colour}
             bne.s     .Skip4
             move.b    (a0)+,d0             ; Set new ink colour
             andi.b    #3,d0
             move.b    d0,Ink
             bra.s     .Again
.Skip4:      cmpi.b    #$e,d0               ; Check for {Backspace}
             bne.s     .Skip5
             jsr       DI_Backspace         ; Backspace
             bra.s     .Again
.Skip5:      jsr       DI_Pchar             ; Print character
             bra.s     .Again
.Exit:       movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Character print routine ]
;   IN : d0 - Character number (.w)
;        a1 - Font pointer (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
DI_Pchar:    
             movem.l   d0-d2/d7/a1/a6,-(sp)
             adda.w    Print_X,a6           ; Calculate screen address
             adda.w    Print_Y,a6
             adda.w    d0,a1                ; Calculate font address
             move.b    Ink,d0               ; Get colour
             move.w    Inverse,d2           ; Get inverse-flag
             btst      #0,d0                ; Create ink colour mask
             sne       d1
             lsl.w     #8,d1
             btst      #1,d0
             sne       d1
; ------------- Display the character --------------------------------
             moveq.l   #7,d7
.Loop:       move.b    (a1),d0              ; Load one line
             lsl.w     #8,d0                ; & duplicate it 2 times
             move.b    (a1),d0
             eor.w     d2,d0                ; Inversion
             and.w     d1,d0                ; Colour masking
             movep.w   d0,0(a6)             ; Display line
             lea.l     256(a1),a1           ; Next line
             lea.l     160(a6),a6
             dbra      d7,.Loop
; ------------- Update the cursor position ---------------------------
             move.w    Print_X,d0           ; Load X-coordinate
             btst      #0,d0                ; Odd column ?
             bne.s     .Odd_address
             addq.w    #1,d0                ; Next column
             bra.s     .Skip
.Odd_address:          addq.w               #3,d0 ; Next column
             cmpi.w    #160,d0              ; Check for end of line
             bmi.s     .Skip
             jsr       DI_Carriage_return   ; Carriage return
             bra.s     .Exit
.Skip:       move.w    d0,Print_X           ; Store new X-coordinate
.Exit:       movem.l   (sp)+,d0-d2/d7/a1/a6
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Diag_pal:    .DC.w 0,$777,$0057,$0555       ; Diagnostic palette
Ink:         .DC.b 1   ; Current ink colour

Error_msg1:  .DC.b 3,2,1," !!! An ERROR has occurred !!! ",13,13,2,3,1,0
Error_msg2:  .DC.b 13,3,2,1," Press any key to continue...  ",13,13,2,0

Backspace_string:      .DC.b 14,14,"_ ",14,0
End_string:  .DC.b 14," ",13,0
Output_string:         .DC.b 14," _",0
             .EVEN 

             .BSS 
Input_buffer:          .DS.b Max_digits     ; Digit input buffer
             .EVEN 
Old_pal:     .DS.w 4   ; Old palette
Prev_screen: .DS.l 1   ; Old screen base
Print_X:     .DS.w 1   ; Printing coordinates
Print_Y:     .DS.w 1
Inverse:     .DS.w 1   ; Inverse flag
DI_Font_ptr: .DS.l 1   ; Pointer to system font

             .END 

