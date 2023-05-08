
; Colour fade routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 22-1-1991

;   "Our gods awaken in thunderous roars
;     And guide our leaders' hands in paths of glory
;      To the cause"
;   Gates Of Delirium, Yes, 1974

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

             .XDEF Fade_pal,List_fade,Hbl_outfade
             .XDEF Hbl_fade,Subfade1,Subfade2

             .TEXT 
;*****************************************************************************
; [ Palette fade routine ]
;   IN : a0 - Pointer to current (work) palette (.l)
;        a1 - Pointer to target palette  (.l)
;        a2 - Pointer to fade subroutine (.l)
;  OUT :     Zero - fade completed
;        Non-zero - fade not completed
; All registers are restored
;*****************************************************************************
Fade_pal:    
             movem.l   d0/d1/d5-d7/a0/a1,-(sp)    ; Save registers
             move.w    #$777,d5             ; RGB mask
             moveq.l   #0,d6
             moveq.l   #16-1,d7
.Loop:       move.w    (a0),d0              ; Load current & target
             move.w    (a1),d1              ;  colour
             and.w     d5,d0                ; Mask
             and.w     d5,d1
             cmp.w     d0,d1                ; Compare
             beq.s     .Next
             jsr       (a2)                 ; Fade colour
             move.w    d0,(a0)              ; Store
             addq.w    #1,d6
.Next:       addq.l    #2,a0                ; Next colour
             addq.l    #2,a1
             dbra      d7,.Loop
             tst.w     d6                   ; Determine zero flag
             movem.l   (sp)+,d0/d1/d5-d7/a0/a1    ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ Colour list fade-in routine ]
;   IN : a0 - Pointer to current HBL list (.l)
;        a1 - Pointer to list of colours (.l)
;        a2 - Pointer to fade subroutine (.l)
;  OUT :     Zero - fade completed
;        Non-zero - fade not completed
; All registers are restored
;*****************************************************************************
List_fade:   
             movem.l   d0-d3/d5/a0/a1,-(sp) ; Save registers
             moveq.l   #0,d3                ; Completion flag
             move.w    #$777,d5             ; RGB mask
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             tst.b     1(a0)                ; Palette or single colour ?
             bne.s     .Single
             addq.l    #2,a0                ; Skip word
             jsr       Fade_pal             ; Fade palette
             sne       d2                   ; Completion check
             sub.b     d2,d3
             lea.l     32(a0),a0            ; Skip palette
             lea.l     32(a1),a1
             bra.s     .Again
.Single:     move.w    4(a0),d0             ; Load current & target
             move.w    (a1)+,d1             ;  colour
             cmp.w     d0,d1                ; Compare
             beq.s     .Equal
             and.w     d5,d0                ; Mask
             and.w     d5,d1
             jsr       (a2)                 ; Fade colour
             sne       d2                   ; Completion check
             sub.b     d2,d3
             move.w    d0,4(a0)             ; Store
.Equal:      addq.l    #6,a0                ; Skip single colour
             bra.s     .Again
.End:        tst.w     d3                   ; Determine zero flag
             movem.l   (sp)+,d0-d3/d5/a0/a1 ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ HBL list fade-out routine ]
;   IN : a0 - Pointer to HBL list (.l)
;        a1 - Pointer to target palette (.l)
;        a2 - Pointer to fade subroutine (.l)
;  OUT :     Zero - fade completed
;        Non-zero - fade not completed
; All registers are restored
;*****************************************************************************
Hbl_outfade: 
             movem.l   d0-d3/d5/a0/a1,-(sp) ; Save registers
             move.w    (a1),d1              ; Target colour
             moveq.l   #0,d3                ; Completion flag
             move.w    #$777,d5             ; RGB mask
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             tst.b     1(a0)                ; Palette or single colour ?
             bne.s     .Single
             addq.l    #2,a0                ; Skip word
             jsr       Fade_pal             ; Fade palette
             sne       d2                   ; Completion check
             sub.b     d2,d3
             lea.l     32(a0),a0            ; Skip palette
             bra.s     .Again
.Single:     move.w    4(a0),d0             ; Load current colour
             cmp.w     d0,d1                ; Compare
             beq.s     .Equal
             and.w     d5,d0                ; Mask
             jsr       (a2)                 ; Fade colour
             sne       d2                   ; Completion check
             sub.b     d2,d3
             move.w    d0,4(a0)             ; Store
.Equal:      addq.l    #6,a0                ; Skip single colour
             bra.s     .Again
.End:        tst.w     d3                   ; Determine zero flag
             movem.l   (sp)+,d0-d3/d5/a0/a1 ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ HBL list fade routine ]
;   IN : a0 - Pointer to current HBL list (.l)
;        a1 - Pointer to  target HBL list (.l)
;        a2 - Pointer to fade subroutine  (.l)
;  OUT :     Zero - fade completed
;        Non-zero - fade not completed
; All registers are restored
;*****************************************************************************
Hbl_fade:    
             movem.l   d0-d3/d5/a0/a1,-(sp)
             moveq.l   #0,d3                ; Completion flag
             move.w    #$777,d5             ; RGB mask
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             tst.b     1(a0)                ; Palette or single colour ?
             bne.s     .Single
             addq.l    #2,a0                ; Skip word
             addq.l    #2,a1
             jsr       Fade_pal             ; Fade palette
             sne       d2                   ; Completion check
             sub.b     d2,d3
             lea.l     32(a0),a0            ; Skip palette
             lea.l     32(a1),a1
             bra.s     .Again
.Single:     move.w    4(a0),d0             ; Load current colour
             move.w    4(a1),d1
             cmp.w     d0,d1                ; Compare
             beq.s     .Equal
             and.w     d5,d0                ; Mask
             and.w     d5,d1
             jsr       (a2)                 ; Fade colour
             sne       d2                   ; Completion check
             sub.b     d2,d3
             move.w    d0,4(a0)             ; Store
.Equal:      addq.l    #6,a0                ; Skip single colour
             addq.l    #6,a1
             bra.s     .Again
.End:        tst.w     d3                   ; Determine zero flag
             movem.l   (sp)+,d0-d3/d5/a0/a1
             rts       

;*****************************************************************************
; [ Fade one colour I ]
;   IN : d0 - Current colour (.w)
;        d1 - Target colour  (.w)
;  OUT : d0 - Faded colour (.w)
; Changed registers : d0
;*****************************************************************************
Subfade1:    
             movem.l   d2/d3,-(sp)
             move.w    #$0700,d2            ; Isolate RED nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Green
             bpl.s     .Red_up
             subi.w    #$0100,d0            ; Fade RED down
             bra.s     .Green
.Red_up:     addi.w    #$0100,d0            ; Fade RED up
.Green:      move.w    #$0070,d2            ; Isolate GREEN nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Blue
             bpl.s     .Green_up
             subi.w    #$0010,d0            ; Fade GREEN down
             bra.s     .Blue
.Green_up:   addi.w    #$0010,d0            ; Fade GREEN up
.Blue:       move.w    #$0007,d2            ; Isolate BLUE nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Exit
             bpl.s     .Blue_up
             subi.w    #$0001,d0            ; Fade BLUE down
             bra.s     .Exit
.Blue_up:    addi.w    #$0001,d0            ; Fade BLUE up
.Exit:       movem.l   (sp)+,d2/d3
             rts       

;*****************************************************************************
; [ Fade one colour II ]
;   IN : d0 - Current colour (.w)
;        d1 - Target colour  (.w)
;  OUT : d0 - Faded colour (.w)
; Changed registers : d0
;*****************************************************************************
Subfade2:    
             movem.l   d2/d3,-(sp)
             move.w    #$0700,d2            ; Isolate RED nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Green
             bpl.s     .Red_up
             subi.w    #$0100,d0            ; Fade RED down
             bra.s     .Exit
.Red_up:     addi.w    #$0100,d0            ; Fade RED up
             bra.s     .Exit
.Green:      move.w    #$0070,d2            ; Isolate GREEN nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Blue
             bpl.s     .Green_up
             subi.w    #$0010,d0            ; Fade GREEN down
             bra.s     .Exit
.Green_up:   addi.w    #$0010,d0            ; Fade GREEN up
             bra.s     .Exit
.Blue:       move.w    #$0007,d2            ; Isolate BLUE nibble
             move.w    d2,d3
             and.w     d0,d2
             and.w     d1,d3
             cmp.w     d2,d3                ; Compare
             beq.s     .Exit
             bpl.s     .Blue_up
             subi.w    #$0001,d0            ; Fade BLUE down
             bra.s     .Exit
.Blue_up:    addi.w    #$0001,d0            ; Fade BLUE up
.Exit:       movem.l   (sp)+,d2/d3
             rts       

             .END 

