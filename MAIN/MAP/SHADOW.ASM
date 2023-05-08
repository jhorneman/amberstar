
; Shadow routines for 2D map
; Written by J.Horneman (In Tune With The Universe)
; Start : 27-3-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - The shadow handler is being called at the start of the {Build_2D_map}
;     routine. Therefore, it has no practical access to the screen display.
;     When lines/polygons are added, a second routine must be called at the
;     end of {Build_2D_map}, and the first routine must build a list of all
;     shadow-casting icons (groan).
;   - The shadows can be enabled/disabled by setting/clearing {Shadow_flag}.

             .TEXT 
;*****************************************************************************
; [ Shadow handler ]
; All registers are restored
;*****************************************************************************
Shadow_handler:        
             movem.l   d0-d5/d7/a0-a4,-(sp)
             tst.b     Shadow_flag          ; Display shadow ?
             beq       .Exit
             lea.l     Spiral_table,a0      ; Initialize registers
             lea.l     Underlay_buf,a1
             lea.l     Overlay_buf,a2
             lea.l     Persons_buf,a3
             movea.l   Iconstats_ptr,a5
             moveq.l   #10,d2               ; Calculate boundaries
             moveq.l   #0,d3
             moveq.l   #8,d4
             moveq.l   #0,d5
             sub.w     Mapbuf_X,d2
             sub.w     Mapbuf_X,d3
             sub.w     Mapbuf_Y,d4
             sub.w     Mapbuf_Y,d5
             add.w     Half_X,d2
             add.w     Half_X,d3
             add.w     Half_Y,d4
             add.w     Half_Y,d5
             move.w    #219,d7              ; 220 entries in spiral
.Loop:       move.b    (a0),d0              ; Load X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next
             move.b    1(a0),d1             ; Load Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next
             jsr       Do_shadow            ; Yay!
.Next:       addq.l    #2,a0                ; Next
             dbra      d7,.Loop
.Exit:       movem.l   (sp)+,d0-d5/d7/a0-a4
             rts       

; [ Display shadow ]
;   IN : d0 - Relative map buffer X-coordinate (.b)
;        d1 - Relative map buffer Y-coordinate (.b)
; Changed registers : a4
Do_shadow:   
             movem.l   d0-d7,-(sp)
             moveq.l   #11,d2               ; Calculate boundaries
             moveq.l   #-1,d3
             moveq.l   #9,d4
             moveq.l   #-1,d5
             sub.w     Mapbuf_X,d2
             sub.w     Mapbuf_X,d3
             sub.w     Mapbuf_Y,d4
             sub.w     Mapbuf_Y,d5
             ext.w     d0                   ; Extend to words
             ext.w     d1
             move.w    d1,d7                ; Calculate map buffer offset
             add.w     Mapbuf_Y,d7
             mulu.w    #13,d7
             add.w     d0,d7
             add.w     Mapbuf_X,d7
             moveq.l   #0,d6                ; Get overlay icon number
             move.b    14(a2,d7.w),d6
             beq.s     .Underlay
             add.w     d6,d6                ; Get overlay icon status
             add.w     d6,d6
             move.l    -4(a5,d6.w),d6
             btst      #5,d6                ; Underlay priority ?
             bne.s     .Underlay
             btst      #1,d6                ; Vision blocked ?
             beq.s     .Exit
             bra.s     .Ok
.Underlay:   moveq.l   #0,d6                ; Get underlay icon number
             move.b    14(a1,d7.w),d6
             add.w     d6,d6                ; Get underlay icon status
             add.w     d6,d6
             move.l    -4(a5,d6.w),d6
             btst      #1,d6                ; Vision blocked ?
             beq.s     .Exit
.Ok:         
; NOW : d0 - Relative map buffer X-coordinate (.w)
;       d1 - Relative map buffer Y-coordinate (.w)

             move.w    d0,d6                ; Copy
             bpl.s     .Pos_1               ; Absolute value
             neg.w     d6
.Pos_1:      move.w    d1,d7
             bpl.s     .Pos_2               ; Absolute value
             neg.w     d7
.Pos_2:      lea.l     Shadow_table,a4      ; Calculate shadow table
             mulu.w    #9,d7                ; pointer
             add.w     d6,d7
             add.w     d7,d7
             move.w    -2(a4,d7.w),d7       ; Get offset
             lea.l     124(a4,d7.w),a4
             tst.w     d0                   ; Determine quadrant
             bmi.s     .Quad_12             ; & call quadrant handler
             tst.w     d1
             bmi.s     .Quad_0
             jsr       Quadrant_3
             bra.s     .Exit
.Quad_0:     jsr       Quadrant_0
             bra.s     .Exit
.Quad_12:    tst.w     d1
             bmi.s     .Quad_1
             jsr       Quadrant_2
             bra.s     .Exit
.Quad_1:     jsr       Quadrant_1
.Exit:       movem.l   (sp)+,d0-d7
             rts       

Quadrant_0:  
.Again:      tst.w     (a4)                 ; End of shadow run ?
             beq.s     .Exit
             move.b    (a4),d0              ; Load X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next
             move.b    1(a4),d1             ; Load Y
             neg.b     d1                   ; Y = -Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next
             ext.w     d0                   ; Extend to words
             ext.w     d1
             add.w     Mapbuf_Y,d1          ; Calculate map buffer offset
             mulu.w    #13,d1
             add.w     d0,d1
             add.w     Mapbuf_X,d1
             move.b    #1,14(a1,d1.w)       ; Hide underlay icon
             move.b    #0,14(a2,d1.w)       ; Hide overlay icon
             move.b    #0,14(a3,d1.w)       ; Hide person
.Next:       addq.l    #2,a4                ; Next
             bra.s     .Again
.Exit:       rts       

Quadrant_1:  
.Again:      tst.w     (a4)                 ; End of shadow run ?
             beq.s     .Exit
             move.b    (a4),d0              ; Load X
             neg.b     d0                   ; X = -X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next
             move.b    1(a4),d1             ; Load Y
             neg.b     d1                   ; Y = -Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next
             ext.w     d0                   ; Extend to words
             ext.w     d1
             add.w     Mapbuf_Y,d1          ; Calculate map buffer offset
             mulu.w    #13,d1
             add.w     d0,d1
             add.w     Mapbuf_X,d1
             move.b    #1,14(a1,d1.w)       ; Hide underlay icon
             move.b    #0,14(a2,d1.w)       ; Hide overlay icon
             move.b    #0,14(a3,d1.w)       ; Hide person
.Next:       addq.l    #2,a4                ; Next
             bra.s     .Again
.Exit:       rts       

Quadrant_2:  
.Again:      tst.w     (a4)                 ; End of shadow run ?
             beq.s     .Exit
             move.b    (a4),d0              ; Load X
             neg.b     d0                   ; X = -X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next
             move.b    1(a4),d1             ; Load Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next
             ext.w     d0                   ; Extend to words
             ext.w     d1
             add.w     Mapbuf_Y,d1          ; Calculate map buffer offset
             mulu.w    #13,d1
             add.w     d0,d1
             add.w     Mapbuf_X,d1
             move.b    #1,14(a1,d1.w)       ; Hide underlay icon
             move.b    #0,14(a2,d1.w)       ; Hide overlay icon
             move.b    #0,14(a3,d1.w)       ; Hide person
.Next:       addq.l    #2,a4                ; Next
             bra.s     .Again
.Exit:       rts       

Quadrant_3:  
.Again:      tst.w     (a4)                 ; End of shadow run ?
             beq.s     .Exit
             move.b    (a4),d0              ; Load X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next
             move.b    1(a4),d1             ; Load Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next
             ext.w     d0                   ; Extend to words
             ext.w     d1
             add.w     Mapbuf_Y,d1          ; Calculate map buffer offset
             mulu.w    #13,d1
             add.w     d0,d1
             add.w     Mapbuf_X,d1
             move.b    #1,14(a1,d1.w)       ; Hide underlay icon
             move.b    #0,14(a2,d1.w)       ; Hide overlay icon
             move.b    #0,14(a3,d1.w)       ; Hide person
.Next:       addq.l    #2,a4                ; Next
             bra.s     .Again
.Exit:       rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Shadow_flag: .DC.b -1  ; Shadow active switch
             .EVEN 

; This is the Amazing Rectangular Spiral.
; It was generated by the Amazing Rectangular Spiral Generator. Yay!
Spiral_table:          
             .DC.b 0,-1,1,-1,1,0,1,1,0,1,-1,1,-1,0,-1,-1,-1,-2,0,-2,1,-2,2,-2,2,-1,2,0,2,1,2,2
             .DC.b 1,2,0,2,-1,2,-2,2,-2,1,-2,0,-2,-1,-2,-2,-2,-3,-1,-3,0,-3,1,-3,2,-3,3,-3,3,-2
             .DC.b 3,-1,3,0,3,1,3,2,3,3,2,3,1,3,0,3,-1,3,-2,3,-3,3,-3,2,-3,1,-3,0,-3,-1,-3,-2
             .DC.b -3,-3,-3,-4,-2,-4,-1,-4,0,-4,1,-4,2,-4,3,-4,4,-4,4,-3,4,-2,4,-1,4,0,4,1,4,2
             .DC.b 4,3,4,4,3,4,2,4,1,4,0,4,-1,4,-2,4,-3,4,-4,4,-4,3,-4,2,-4,1,-4,0,-4,-1,-4,-2
             .DC.b -4,-3,-4,-4,-4,-5,-3,-5,-2,-5,-1,-5,0,-5,1,-5,2,-5,3,-5,4,-5,5,-5,5,-4,5,-3
             .DC.b 5,-2,5,-1,5,0,5,1,5,2,5,3,5,4,5,5,4,5,3,5,2,5,1,5,0,5,-1,5,-2,5,-3,5,-4,5,-5,5
             .DC.b -5,4,-5,3,-5,2,-5,1,-5,0,-5,-1,-5,-2,-5,-3,-5,-4,-5,-5,-5,-6,-4,-6,-3,-6,-2,-6
             .DC.b -1,-6,0,-6,1,-6,2,-6,3,-6,4,-6,5,-6,6,-6,6,-5,6,-4,6,-3,6,-2,6,-1,6,0,6,1,6,2
             .DC.b 6,3,6,4,6,5,6,6,5,6,4,6,3,6,2,6,1,6,0,6,-1,6,-2,6,-3,6,-4,6,-5,6,-6,6,-6,5
             .DC.b -6,4,-6,3,-6,2,-6,1,-6,0,-6,-1,-6,-2,-6,-3,-6,-4,-6,-5,-6,-6,7,-6,7,-5,7,-4
             .DC.b 7,-3,7,-2,7,-1,7,0,7,1,7,2,7,3,7,4,7,5,7,6,-7,6,-7,5,-7,4,-7,3,-7,2,-7,1,-7,0
             .DC.b -7,-1,-7,-2,-7,-3,-7,-4,-7,-5,-7,-6,8,-6,8,-5,8,-4,8,-3,8,-2,8,-1,8,0,8,1,8,2
             .DC.b 8,3,8,4,8,5,8,6,-8,6,-8,5,-8,4,-8,3,-8,2,-8,1,-8,0,-8,-1,-8,-2,-8,-3,-8,-4
             .DC.b -8,-5,-8,-6
             .EVEN 

             .END 

















