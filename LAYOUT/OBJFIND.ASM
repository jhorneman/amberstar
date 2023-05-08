
; Object recognition system
; Written by J.Horneman (In Tune With The Universe)
; Start : 28-2-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

             .XDEF Find_object,Push_Root,Pop_Root
             .XDEF Translate_object_branch

             .XREF DI_Error

Max_roots    = 8

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; String in DATA segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Find object ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;  OUT : d2 - $00xxyyzz
;             xx = first layer identification
;             yy = second layer identification
;             zz = third layer identification
;              0 = no find
; Changed registers : d2
;*****************************************************************************
Find_object: 
             movem.l   d4/a0,-(sp)
             moveq.l   #0,d2
             movea.l   Object_sp,a0         ; Current root
             move.l    (a0),d4
             jsr       Search_layer         ; Identify 1st layer
             tst.b     d2
             beq.s     .Exit
             swap.w    d2
             move.l    Obj_child(a0),d4     ; Second layer child
             beq.s     .Exit
             jsr       Search_layer         ; Identify 2nd layer
             tst.b     d2
             beq.s     .Exit
             lsl.w     #8,d2
             move.l    Obj_child(a0),d4     ; Third layer child
             beq.s     .Exit
             jsr       Search_layer         ; Identify 3rd layer
.Exit:       movem.l   (sp)+,d4/a0
             rts       

; [ Search a layer ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d4 - Pointer to first entry in layer (.l)
;  OUT : d2 - ID of entry (.b)
;        a0 - Pointer to entry (.l)
; Changed registers : d2,d4,a0
Search_layer:          
.Loop:       movea.l   d4,a0
             cmp.w     (a0),d0              ; Check X against left edge
             bmi.s     .Next
             cmp.w     2(a0),d0             ; Check X against right edge
             bhi.s     .Next
             cmp.w     4(a0),d1             ; Check Y against top edge
             bmi.s     .Next
             cmp.w     6(a0),d1             ; Check Y against bottom edge
             bhi.s     .Next
             move.b    8(a0),d2             ; Load ID
             bra.s     .Exit
.Next:       move.l    Obj_brother(a0),d4   ; Next brother
             bne.s     .Loop
.Exit:       rts       

;*****************************************************************************
; [ Translate object branch ]
;   IN : d0 - X offset (.w)
;        d1 - Y offset (.w)
;        a0 - Pointer to branch that must be translated (.l)
; All registers are restored
; NOTE : - To translate back, use negative offsets.
;*****************************************************************************
Translate_object_branch:                    
             movem.l   d2/a0,-(sp)
             move.l    a0,d2
.Loop1:      movea.l   d2,a0
             add.w     d0,(a0)              ; Translate first layer
             add.w     d0,2(a0)
             add.w     d1,4(a0)
             add.w     d1,6(a0)
             move.l    Obj_child(a0),d2     ; Second layer child
             beq       .Next1
             move.l    a0,-(sp)
.Loop2:      movea.l   d2,a0
             add.w     d0,(a0)              ; Translate second layer
             add.w     d0,2(a0)
             add.w     d1,4(a0)
             add.w     d1,6(a0)
             move.l    Obj_child(a0),d2     ; Third layer child
             beq.s     .Next2
             move.l    a0,-(sp)
.Loop3:      movea.l   d2,a0
             add.w     d0,(a0)              ; Translate second layer
             add.w     d0,2(a0)
             add.w     d1,4(a0)
             add.w     d1,6(a0)
             move.l    Obj_brother(a0),d2   ; Third layer brother
             bne       .Loop3
             movea.l   (sp)+,a0
.Next2:      move.l    Obj_brother(a0),d2   ; Second layer brother
             bne       .Loop2
             movea.l   (sp)+,a0
.Next1:      move.l    Obj_brother(a0),d2   ; First layer brother
             bne       .Loop1
.Exit:       movem.l   (sp)+,d2/a0
             rts       

;*****************************************************************************
; [ Push new object root ]
;   IN : a0 - Pointer to new object root (.l)
; All registers are restored
;*****************************************************************************
Push_Root:   
             move.l    a1,-(sp)
             movea.l   Object_sp,a1
             addq.l    #4,a1                ; Increase object sp
             cmpa.l    #End_of_object_stack,a1
             bmi.s     .Not_full
             ERROR     "[ Push_Root ] : Object stack overflow !!!"
             bra.s     .Exit
.Not_full:   move.l    a0,(a1)              ; Push root
             move.l    a1,Object_sp
.Exit:       movea.l   (sp)+,a1
             rts       

;*****************************************************************************
; [ Pop current object root ]
; All registers are restored
;*****************************************************************************
Pop_Root:    
             move.l    a1,-(sp)
             movea.l   Object_sp,a1
             cmpa.l    #Object_stack,a1
             bpl.s     .Not_empty
             ERROR     "[ Pop_Root ] : Object stack underflow !!!"
             bra.s     .Exit
.Not_empty:  subq.l    #4,a1                ; Decrease sp
             move.l    a1,Object_sp
.Exit:       movea.l   (sp)+,a1
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .ABS 0
             .DS.w 4   ; Area descriptor
Obj_ID:      .DS.b 1
             .EVEN 
Obj_brother: .DS.l 1
Obj_child:   .DS.l 1

             .DATA 
Object_sp:   .DC.l Object_stack-4

             .BSS 
Object_stack:          .DS.l Max_roots
End_of_object_stack:   

             .END 

