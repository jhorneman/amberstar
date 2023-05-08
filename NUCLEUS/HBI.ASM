
; HBI handling routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 11-5-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "And I heard a million voices singing
;     Acting to the story that they had heard about
;      Does one child know the secret and can say it
;       Or does it all come out
;        Along without you
;        Along without you
;        Along without you."
;   'The Ancient' / Giants Under The Sun, Yes, 1973

; Notes :
;   - [ Update_HBL ] does not check if an update was already asked for.
;   - Due to the self-modifying code in [ Single_HBL ], all optimizers
;     MUST be activated.

             .XDEF HBL_on,HBL_off,Update_HBL
             .XDEF HBL_handler,HBL_flag
             .XDEF User_HBL_list,Copy_HBL_list

             .PATH 'E:\MAIN\'
             .INCLUDE 'CONST5X.IS'

             .TEXT 
;*****************************************************************************
; [ Handle HBL's ] VBI INTERRUPT
; All registers are restored
;*****************************************************************************
HBL_handler: 
             movem.l   d0-d7/a0-a2,-(sp)
             tst.b     HBL_flag             ; HBL's blocked ?
             beq       No_HBLs
             tst.l     New_HBL_list         ; New HBL list ?
             beq       No_new_list
             movea.l   New_HBL_list,a0      ; Start of new list
             lea.l     HBL_list,a1          ; Start of real list
             moveq.l   #0,d0
             addq.l    #2,a0                ; Skip dummy word
             movem.l   (a0)+,d1-d7/a2       ; Copy first palette
             movem.l   d1-d7/a2,(a1)
             lea.l     32(a1),a1
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             moveq.l   #0,d1                ; Load line number
             move.b    (a0),d1
             sub.w     d0,d1                ; Calculate TBDR value
             move.b    d1,(a1)+             ;  & insert it
             move.b    (a0)+,d0             ; Reload
             move.b    (a0)+,d1             ; Load type & insert it
             move.b    d1,(a1)+
             beq.s     .Zero                ; Palette or single colour ?
             move.w    (a0)+,d2             ; Calculate colour register
             add.w     d2,d2
             addi.w    #$8240,d2            ; COLOUR 0 !!!
             move.w    d2,(a1)+
             move.w    (a0)+,(a1)+
             bra.s     .Again
.Zero:       subq.b    #1,-2(a1)            ; Correction
             subq.w    #1,d0
             movem.l   (a0)+,d1-d7/a2       ; Copy palette
             movem.l   d1-d7/a2,(a1)
             lea.l     32(a1),a1
             bra.s     .Again
.End:        move.w    (a0),(a1)+           ; Copy sentinel
             clr.l     New_HBL_list         ; Clear "flag"
             .LOCAL 
No_new_list: lea.l     HBL_list,a0          ; Start of list
             movem.l   (a0)+,d0-d7          ; Set main palette
             movem.l   d0-d7,Colour_0
             tst.w     (a0)                 ; End of list ?
             beq.s     No_HBLs
             move.b    (a0)+,MFP_Tbdr       ; Set TBDR
             tst.b     (a0)+                ; Palette or single colour ?
             beq.s     .Zero
             move.l    #Single_HBL,Timer_B_vec    ; Install HBL-routine
             move.w    (a0)+,Single_HBL+4   ; MODIFY INSTRUCTION
             move.w    (a0)+,Single_HBL+2
             bra.s     .Continue
.Zero:       move.l    #Palette_HBL,Timer_B_vec   ; Install HBL-routine
.Continue:   move.b    #8,MFP_Tbcr          ; Start Timer B
             move.l    a0,HBL_list_ptr      ; Store pointer to HBL list
No_HBLs:     movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; The HBL routines
;*****************************************************************************
Single_HBL:  
             move.w    #$0000,Colour_0      ; SELF-MODIFYING CODE
             move.l    a0,-(sp)
             clr.b     MFP_Tbcr             ; Stop Timer B
             movea.l   HBL_list_ptr,a0
             tst.w     (a0)                 ; End of list ?
             beq.s     .Exit
             move.b    (a0)+,MFP_Tbdr       ; Set TBDR
             tst.b     (a0)+                ; Palette or single colour ?
             bne.s     .Single
             move.l    #Palette_HBL,Timer_B_vec   ; Palette change
             bra.s     .Continue
.Single:     move.w    (a0)+,Single_HBL+4   ; MODIFY INSTRUCTION
             move.w    (a0)+,Single_HBL+2
.Continue:   move.l    a0,HBL_list_ptr
             move.b    #8,MFP_Tbcr          ; Start Timer B
.Exit:       movea.l   (sp)+,a0
             bclr.b    #0,MFP_Isra
             rte       

Palette_HBL: 
             movem.l   d0-d7/a0-a2,-(sp)
             movea.l   HBL_list_ptr,a0      ; Load pointer to HBL list
             movem.l   (a0)+,d1-d7/a1       ; Load palette
             lea.l     Colour_0,a2
             clr.b     MFP_Tbcr             ; Stop Timer B
             moveq.l   #8,d0                ; Dummy TBDR value
             move.b    d0,MFP_Tbdr
             move.b    #8,MFP_Tbcr          ; Start Timer B
.Wait:       cmp.b     MFP_Tbdr,d0          ; Wait for right border
             beq.s     .Wait
             movem.l   d1-d7/a1,(a2)        ; Set palette
             move.b    #0,MFP_Tbcr          ; Stop Timer B
             tst.w     (a0)                 ; End of list ?
             beq.s     .Exit
             move.b    (a0)+,MFP_Tbdr       ; Set TBDR
             tst.b     (a0)+                ; Palette or single colour ?
             beq.s     .Continue
             move.l    #Single_HBL,Timer_B_vec    ; Install HBL-routine
             move.w    (a0)+,Single_HBL+4   ; MODIFY INSTRUCTION
             move.w    (a0)+,Single_HBL+2
.Continue:   move.l    a0,HBL_list_ptr      ; Store pointer to HBL list
             move.b    #8,MFP_Tbcr          ; Start Timer B
.Exit:       movem.l   (sp)+,d0-d7/a0-a2
             bclr.b    #0,MFP_Isra
             rte       

;*****************************************************************************
; [ Turn HBL's on ]
; All registers are restored
;*****************************************************************************
HBL_on:      
             st        HBL_flag             ; Unblock HBL's
             rts       

;*****************************************************************************
; [ Turn HBL's off ]
; All registers are restored
;*****************************************************************************
HBL_off:     
             sf        HBL_flag             ; Block HBL's
             rts       

;*****************************************************************************
; [ Force an update of the HBL list ]
;   IN : a0 - Pointer to new HBL list (.l)
; All registers are restored
;*****************************************************************************
Update_HBL:  
             move.l    a0,New_HBL_list      ; Signal update
             move.l    a0,User_HBL_list     ; Store
             rts       

;*****************************************************************************
; [ Copy a HBL list ]
;   IN : a0 -      Source (.l)
;        a1 - Destination (.l)
; All registers are restored
;*****************************************************************************
Copy_HBL_list:         
             movem.l   d0-d7/a0/a1,-(sp)
             move.w    (a0)+,(a1)+          ; Copy dummy word
             movem.l   (a0)+,d0-d7          ; Copy first palette
             movem.l   d0-d7,(a1)
             lea.l     32(a1),a1
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             move.w    (a0)+,(a1)+          ; Copy word
             tst.b     -1(a0)               ; Palette or single colour ?
             bne.s     .Single
             movem.l   (a0)+,d0-d7          ; Copy palette
             movem.l   d0-d7,(a1)
             lea.l     32(a1),a1
             bra.s     .Again
.Single:     move.l    (a0)+,(a1)+          ; Copy single colour
             bra.s     .Again
.End:        move.w    #0,(a1)+             ; Insert sentinel
             movem.l   (sp)+,d0-d7/a0/a1
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
HBL_flag:    .DS.b 1   ; HBL block flag
             .EVEN 
New_HBL_list:          .DS.l 1              ; Pointer to new list / 0
User_HBL_list:         .DS.l 1              ; Pointer to current USER list
HBL_list_ptr:          .DS.l 1              ; Pointer to current position in HBL list

; This is the real HBL-list. The first entry is always the main palette.
; Uninitialized, it just darkens the screen.
HBL_list:    .DS.w 512

             .END 

; HBI information (user)
;  0 - Line (.b)
;  1 - Entire palette / single colour (0/-1) (.b)

;  2 - Palette (16.w)
; OR
;  2 - Colour number (.w)
;  4 - Colour (.w)

; HBI information (system)
;  0 - Next TBDR value / 0 (Sentinel) (.b)
;  1 - Entire palette / single colour (0/-1) (.b)

;  2 - Palette (16.w)
; OR
;  2 - Colour register address (.w) !!!!!!!!!
;  4 - Colour (.w)

