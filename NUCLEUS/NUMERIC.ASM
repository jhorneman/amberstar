
; Numeric conversion routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 12-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - All numbers must be EXTended to longwords before calling this
;     routine.

             .XDEF Hex_convert,Dec_convert

             .XREF DI_Error

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; Strings in separate segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Binary to hexadecimal ASCII converter ]
;   IN : d0 - Number (.l)
;        d7 - Number of digits to be put out (.w)
;  OUT : a0 - Pointer to output string (.l)
; Changed registers : a0
; NOTE : byte - 2 digits
;        word - 4 digits
;    longword - 8 digits
;*****************************************************************************
Hex_convert: 
             movem.l   d0/d1/d7,-(sp)
             lea.l     Output_string,a0     ; Clear string
             move.l    #"    ",(a0)
             move.l    #"    ",4(a0)
             move.l    #"    ",8(a0)
             adda.w    d7,a0                ; Go to end of string
             move.b    #" ",(a0)            ; Insert spaces + sentinel
             move.b    #" ",1(a0)
             move.b    #0,2(a0)
             subq.w    #1,d7                ; DBRA correction
.Loop:       moveq.l   #$f,d1               ; Get low nibble
             and.w     d0,d1
             cmpi.w    #$a,d1               ; Convert to HEX
             bmi.s     .No_letter
             addi.w    #"A"-10,d1
             bra.s     .Skip
.No_letter:  addi.w    #"0",d1
.Skip:       move.b    d1,-(a0)             ; Insert in string
             ror.l     #4,d0                ; Rotate
             dbra      d7,.Loop             ; Next nibble
             lea.l     Output_string,a0     ; Output
             movem.l   (sp)+,d0/d1/d7
             rts       

;*****************************************************************************
; [ Binary to decimal ASCII converter ]
;   IN : d0 - Number (.l)
;        d7 - Number of digits to be put out (.w)
;  OUT : a0 - Pointer to output string (.l)
; Changed registers : a0
; NOTE : byte -  3 digits
;        word -  5 digits
;    longword - 10 digits
;*****************************************************************************
Dec_convert: 
             movem.l   d0-d3/d7/a1,-(sp)
             cmpi.w    #10+1,d7             ; Legal input ?
             bmi.s     .Ok1
             ERROR     "[ Dec_convert ] : Number of digits too high !!!"
             bra       .Exit
.Ok1:        lea.l     Output_string,a0     ; Clear string
             move.l    #"    ",(a0)
             move.l    #"    ",4(a0)
             move.l    #"    ",8(a0)
             tst.l     d0                   ; Negative ?
             bpl.s     .Positive
             neg.l     d0
             move.b    #"-",(a0)+
             bra.s     .Go_on
.Positive:   move.b    #" ",(a0)+
.Go_on:      lea.l     Weights+40,a1        ; Weights table
             move.w    d7,d3
             add.w     d3,d3
             add.w     d3,d3
             suba.w    d3,a1
             cmp.l     -4(a1),d0            ; Not too big ?
             bmi.s     .Ok2
             subq.w    #1,d7                ; Make dummy number
.Loop1:      move.b    #"*",(a0)+
             dbra      d7,.Loop1
             bra       .Not_zero
.Ok2:        moveq.l   #0,d3
             subq.w    #1,d7
.Loop2:      move.l    (a1)+,d1             ; Load weight
             move.w    #"0",d2
.Weigh:      cmp.l     d1,d0                ; Weigh number
             bmi.s     .Skip
             sub.l     d1,d0                ; Reduce weight
             addq.w    #1,d2                ; Increase digit
             bra.s     .Weigh
.Skip:       cmpi.w    #"0",d2              ; Leading space ?
             bne.s     .No_leading_space
             tst.w     d3
             bne.s     .No_leading_space
             move.b    #" ",(a0)+
             bra.s     .Next_digit
.No_leading_space:     
             st        d3
             move.b    d2,(a0)+             ; Insert in string
.Next_digit: dbra      d7,.Loop2
             tst.w     d3                   ; Number was zero ?
             bne.s     .Not_zero
             move.b    #"0",-1(a0)          ; Insert zero in string
.Not_zero:   move.b    #" ",(a0)+           ; Insert spaces + sentinel
             move.b    #" ",(a0)+
             move.b    #0,(a0)
             lea.l     Output_string,a0     ; Output
.Exit:       movem.l   (sp)+,d0-d3/d7/a1
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Weights:     .DC.l 1000000000,100000000,10000000,1000000
             .DC.l 100000,10000,1000,100,10,1

             .BSS 
Output_string:         .DS.b 32+1
             .EVEN 

             .END 

