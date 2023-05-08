
; Graphics routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 31-1-1991

;   "Stand on hills of long forgotten yesterdays
;     Pass amongst your memories told returning ways
;      As certain as we walk today
;       We walk around the story."
;   The Remembering / High The Memory, Yes, 1973

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :

             .XDEF Init_gfx,Coord_convert,Draw_box
             .XDEF Put_unmasked_block,Put_masked_block
             .XDEF Blot_unmasked_block,Blot_masked_block
             .XDEF Blit_unmasked_block,Blit_masked_block
             .XDEF Duplicate_block,Get2_block

             .XREF DangerZone

             .MACRO Check
             movem.l   d0/a0,-(sp)
             move.l    DangerZone,d0
             beq.s     .AllClear
             movea.l   d0,a0
             tst.l     (a0)
             beq.s     .AllClear
             .DC.w $4afc
.AllClear:   movem.l   (sp)+,d0/a0
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Graphics routines initialization ]
; All registers are restored
;*****************************************************************************
Init_gfx:    
             movem.l   d0/d1/d6/d7/a0,-(sp)
             lea.l     X_conv_tab,a0        ; Fill X-conversion table
             moveq.l   #0,d0
             moveq.l   #19,d7
.Loop_1:     moveq.l   #0,d1
             moveq.l   #15,d6
.Loop_2:     move.w    d0,(a0)+             ; Store RSA
             move.w    d1,(a0)+             ; Store pixel number
             addq.l    #1,d1                ; Next pixel
             dbra      d6,.Loop_2
             addq.l    #8,d0                ; Next column
             dbra      d7,.Loop_1
             .LOCAL 
             lea.l     Y_conv_tab,a0        ; Fill Y-conversion table
             moveq.l   #0,d0
             move.w    #160,d1
             move.w    #199,d7
.Loop:       move.w    d0,(a0)+             ; Store data
             add.w     d1,d0                ; Next line
             dbra      d7,.Loop
             movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ Coordinate to RSA conversion routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - RSA (.w)
;        d3 - Pixel number (.w)
; Changed registers : d2,d3
;*****************************************************************************
Coord_convert:         
             movem.l   d0/d1/a0,-(sp)
             lea.l     Y_conv_tab,a0        ; Convert Y-coordinate
             add.w     d1,d1
             move.w    0(a0,d1.w),d2
             lea.l     X_conv_tab,a0        ; Convert X-coordinate
             lsl.w     #2,d0
             add.w     0(a0,d0.w),d2
             move.w    2(a0,d0.w),d3
             movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Draw a 4-plane box ]
;   IN : d0 - X-coordinate 1 (.w)
;        d1 - Y-coordinate 1 (.w)
;        d2 - X-coordinate 2 (.w)
;        d3 - Y-coordinate 2 (.w)
;        d6 - Colour (.w)
;        a6 - Screen base (.l)
; All registers are restored
; This routine was written by M.Bittner
;*****************************************************************************
Draw_box:    
             movem.l   d0-d7/a0-a3,-(sp)
             sub.w     d1,d3                ; Calculate number of lines-1
             move.w    d3,d7
             mulu.w    #160,d1              ; Calculate screen address (Y)
             lea.l     0(a6,d1.w),a0
             move.w    d2,d1

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate 1 (.w)
;   d1 - Y-coordinate 2 (.w)
;   d6 - Colour {0...15} (.w)
;   d7 - Number of lines - 1 (.w)
;   a0 - Screen address (.l)

             moveq.l   #15,d2               ; Get low nibbles of X's
             moveq.l   #15,d3
             and.w     d0,d2
             and.w     d1,d3
             sub.w     d2,d0                ; Clear low nibbles
             sub.w     d3,d1
             lea       StartEnd_tab,a1      ; Load start & end masks
             add.w     d2,d2
             add.w     d3,d3
             move.w    0(a1,d2.w),d2        ; (left)
             move.w    32(a1,d3.w),d3       ; (right)
             move.w    d2,d4                ; Invert start & end masks
             not.w     d4
             move.w    d3,d5
             not.w     d5
             lsr.w     #1,d0                ; Calculate screen address (X)
             adda.w    d0,a0

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate 1 AND $fff0 / 2 (.w)
;   d1 - Y-coordinate 2 AND $fff0 (.w)
;   d2 - Start mask (.w)
;   d3 - End mask (.w)
;   d4 - Inverted start mask (.w)
;   d5 - Inverted end mask (.w)
;   d6 - Colour {0...15} (.w)
;   d7 - Number of lines - 1 (.w)
;   a0 - Screen address (.l)

             add.w     d0,d0                ; Calculate
             sub.w     d0,d1                ; (nr. of truncs-1)*16
             beq       .Boxonetrunc
             movea.w   #160-8,a3            ; Calculate next line offset
             lsr.w     #1,d1
             suba.w    d1,a3
             lea       .Jumptower_end+4(pc),a1    ; Calculate jump tower pointer
             lsr.w     #1,d1
             suba.w    d1,a1
             lea       Box_hl_comms,a2      ; Colour patching
             lsl.w     #3,d6
             movem.l   0(a2,d6.w),d0/d1
             movem.l   d0/d1,.Patch1
             ori.l     #$2000200,d0
             ori.l     #$2000200,d1
             movem.l   d0/d1,.Patch2
             lea       Colour_tab,a2        ; Get colour data
             movem.l   0(a2,d6.w),d0/d1
; ------------- Draw horizontal lines --------------------------------
.Patch1:     or.w      d2,(a0)+             ; First trunc
             or.w      d2,(a0)+
             and.w     d4,(a0)+
             and.w     d4,(a0)+
             jmp       (a1)                 ; Jump into tower
             .REPT 18
             move.l    d0,(a0)+
             move.l    d1,(a0)+
             .ENDR 
.Jumptower_end:        
.Patch2:     or.w      d3,(a0)+             ; Last trunc
             or.w      d3,(a0)+
             and.w     d5,(a0)+
             and.w     d5,(a0)+
             adda.w    a3,a0                ; Next line
             dbra      d7,.Patch1
             bra       .Exit
; ------------- Box is only one trunc wide ---------------------------
.Boxonetrunc:          lea                  Box_hl_comms,a2 ; Colour patching
             lsl.w     #3,d6
             movem.l   0(a2,d6.w),d0/d1
             movem.l   d0/d1,.Patch3
             and.w     d3,d2
             or.w      d5,d4
.Patch3:     or.w      d2,(a0)+
             or.w      d2,(a0)+
             and.w     d4,(a0)+
             and.w     d4,(a0)+
             lea       160-8(a0),a0
             dbra      d7,.Patch3
.Exit:       movem.l   (sp)+,d0-d7/a0-a3
             rts       

;*****************************************************************************
; [ Copy any-sized block from one screen to another ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in columns (.w)
;        d7 - Height in pixels (.w)
;        a0 - Source screen base (.l)
;        a1 - Destination screen base (.l)
; All registers are restored
;*****************************************************************************
Duplicate_block:       
             movem.l   d2-d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointers
             adda.w    d2,a0
             adda.w    d2,a1
             move.w    d6,d5                ; Calculate scanline offset
             lsl.w     #3,d5
             subi.w    #160,d5
             neg.w     d5
             subq.w    #1,d7                ; DBRA corrections
             subq.w    #1,d6
.Loop_1:     move.w    d6,d4                ; Duplicate counter
.Loop_2:     move.l    (a0)+,(a1)+          ; Copy line
             move.l    (a0)+,(a1)+
             dbra      d4,.Loop_2
             adda.w    d5,a0                ; Next line
             adda.w    d5,a1
             dbra      d7,.Loop_1
             movem.l   (sp)+,d2-d7/a0/a1
             rts       

;*****************************************************************************
; [ Any size block-get routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in columns (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to buffer (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Get2_block:  
             movem.l   d2-d7/a0/a1,-(sp)
             jsr       Mouse_off            ; Mouse off
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             move.w    d6,d5                ; Calculate scanline offset
             lsl.w     #3,d5
             subi.w    #160,d5
             neg.w     d5
             subq.w    #1,d7                ; DBRA corrections
             subq.w    #1,d6
.Loop_1:     move.w    d6,d4                ; Duplicate counter
.Loop_2:     move.l    (a1)+,(a0)+          ; Get line
             move.l    (a1)+,(a0)+
             dbra      d4,.Loop_2
             adda.w    d5,a1                ; Next line
             dbra      d7,.Loop_1
             jsr       Mouse_on             ; Mouse on
             movem.l   (sp)+,d2-d7/a0/a1
             rts       

;*****************************************************************************
; [ 16x16 any coordinate unmasked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Blit_unmasked_block:   
             movem.l   d0-d5/d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             move.l    #$ffff0000,d5        ; Calculate mask
             ror.l     d3,d5
             moveq.l   #15,d7
.Loop:       moveq.l   #0,d0                ; Load one line
             move.w    (a0)+,d0
             moveq.l   #0,d1
             move.w    (a0)+,d1
             moveq.l   #0,d2
             move.w    (a0)+,d2
             moveq.l   #0,d4
             move.w    (a0)+,d4
             ror.l     d3,d0                ; Rotate
             ror.l     d3,d1
             ror.l     d3,d2
             ror.l     d3,d4
             and.w     d5,(a1)              ; Mask half a line
             or.w      d0,(a1)+
             and.w     d5,(a1)
             or.w      d1,(a1)+
             and.w     d5,(a1)
             or.w      d2,(a1)+
             and.w     d5,(a1)
             or.w      d4,(a1)+
             swap.w    d0                   ; Swap
             swap.w    d1
             swap.w    d2
             swap.w    d4
             swap.w    d5
             and.w     d5,(a1)              ; Mask half a line
             or.w      d0,(a1)+
             and.w     d5,(a1)
             or.w      d1,(a1)+
             and.w     d5,(a1)
             or.w      d2,(a1)+
             and.w     d5,(a1)
             or.w      d4,(a1)+
             swap.w    d5
             lea.l     160-16(a1),a1        ; Next line
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d5/d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; [ 16x16 any coordinate masked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Blit_masked_block:     
             movem.l   d0-d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             move.l    #$ffff0000,d5        ; Calculate mask
             ror.l     d3,d5
             move.w    d3,d6                ; Copy bit number
             moveq.l   #15,d7
.Loop:       moveq.l   #0,d0                ; Load one line
             move.w    (a0)+,d0
             moveq.l   #0,d1
             move.w    (a0)+,d1
             moveq.l   #0,d2
             move.w    (a0)+,d2
             moveq.l   #0,d3
             move.w    (a0)+,d3
             ror.l     d6,d0                ; Rotate
             ror.l     d6,d1
             ror.l     d6,d2
             ror.l     d6,d3
             move.l    d0,d4                ; Calculate mask
             or.l      d1,d4
             or.l      d2,d4
             or.l      d3,d4
             not.l     d4
             or.l      d5,d4
             and.w     d4,(a1)              ; Mask half a line
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             swap.w    d0                   ; Swap
             swap.w    d1
             swap.w    d2
             swap.w    d3
             swap.w    d4
             and.w     d4,(a1)              ; Mask half a line
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             lea.l     160-16(a1),a1        ; Next line
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; [ 16x16 unmasked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Put_unmasked_block:    
             movem.l   d2/d3/d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             moveq.l   #15,d7
.Loop:       move.l    (a0)+,(a1)+          ; Display line
             move.l    (a0)+,(a1)+
             lea.l     160-8(a1),a1         ; Next line
             dbra      d7,.Loop
             movem.l   (sp)+,d2/d3/d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; [ Any size unmasked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in columns (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Blot_unmasked_block:   
             movem.l   d2-d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             move.w    d6,d5                ; Calculate scanline offset
             lsl.w     #3,d5
             subi.w    #160,d5
             neg.w     d5
             subq.w    #1,d7                ; DBRA corrections
             subq.w    #1,d6
.Loop_1:     move.w    d6,d4                ; Duplicate counter
.Loop_2:     move.l    (a0)+,(a1)+          ; Display line
             move.l    (a0)+,(a1)+
             dbra      d4,.Loop_2
             adda.w    d5,a1                ; Next line
             dbra      d7,.Loop_1
             movem.l   (sp)+,d2-d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; [ 16x16 masked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Put_masked_block:      
             movem.l   d0-d4/d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             moveq.l   #15,d7
.Loop:       movem.w   (a0)+,d0-d3          ; Load one line
             move.w    d0,d4                ; Calculate mask
             or.w      d1,d4
             or.w      d2,d4
             or.w      d3,d4
             not.w     d4
             and.w     d4,(a1)              ; Display one line
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             lea.l     160-8(a1),a1         ; Next line
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d4/d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; [ Any size masked block-put routine ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in columns (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Blot_masked_block:     
             movem.l   d0-d7/a0/a1,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             lea.l     0(a6,d2.w),a1
             move.w    d6,d5                ; Calculate scanline offset
             lsl.w     #3,d5
             subi.w    #160,d5
             neg.w     d5
             subq.w    #1,d7                ; DBRA corrections
             subq.w    #1,d6
             move.w    d6,-(sp)             ;tore counter
.Loop_1:     move.w    (sp),d6              ; Load counter
.Loop_2:     movem.w   (a0)+,d0-d3          ; Load one line
             move.w    d0,d4                ; Calculate mask
             or.w      d1,d4
             or.w      d2,d4
             or.w      d3,d4
             not.w     d4
             and.w     d4,(a1)              ; Display one line
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             dbra      d6,.Loop_2
             adda.w    d5,a1                ; Next line
             dbra      d7,.Loop_1
             addq.l    #2,sp                ; Adjust stack pointer
             movem.l   (sp)+,d0-d7/a0/a1
             Check 
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Box_hl_comms:          .DC.w $c958,$c958,$c958,$c958,$8558,$c958,$c958,$c958
             .DC.w $c958,$8558,$c958,$c958,$8558,$8558,$c958,$c958
             .DC.w $c958,$c958,$8558,$c958,$8558,$c958,$8558,$c958
             .DC.w $c958,$8558,$8558,$c958,$8558,$8558,$8558,$c958
             .DC.w $c958,$c958,$c958,$8558,$8558,$c958,$c958,$8558
             .DC.w $c958,$8558,$c958,$8558,$8558,$8558,$c958,$8558
             .DC.w $c958,$c958,$8558,$8558,$8558,$c958,$8558,$8558
             .DC.w $c958,$8558,$8558,$8558,$8558,$8558,$8558,$8558
StartEnd_tab:          .DC.w $ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
             .DC.w $00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001
             .DC.w $8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
             .DC.w $ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
Colour_tab:  .DC.w $0000,$0000,$0000,$0000,$ffff,$0000,$0000,$0000
             .DC.w $0000,$ffff,$0000,$0000,$ffff,$ffff,$0000,$0000
             .DC.w $0000,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
             .DC.w $0000,$ffff,$ffff,$0000,$ffff,$ffff,$ffff,$0000
             .DC.w $0000,$0000,$0000,$ffff,$ffff,$0000,$0000,$ffff
             .DC.w $0000,$ffff,$0000,$ffff,$ffff,$ffff,$0000,$ffff
             .DC.w $0000,$0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff
             .DC.w $0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff

             .BSS 
; These are the coordinate conversion tables.
; The X-table contains the RSA and pixel number for each X-coordinate.
; Each entry takes 4 bytes.
; The Y-table contains the RSA for each Y-coordinate.
; Each entry takes 2 bytes.

X_conv_tab:  .DS.l 320
Y_conv_tab:  .DS.w 200

             .END 

