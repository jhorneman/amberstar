
; Screen routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 11-6-1991

;   "The sunshine in mountains sometimes lost
;     The river can disregard the cost
;      And melt in the sky the warmth when you die
;       Were we ever warmer on that day a million miles away
;        We seemed from all of eternity"
;   South Side Of The Sky, Yes, 1972

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

             .XDEF Init_screen,Clear_screen,Copy_screen
             .XDEF Set_screen,Switch_screen,My_vsync
             .XDEF Off_screen,On_screen,Screen_base

             .XREF Mouse_off,Mouse_on,DI_Error,ScrQ_handler,Void

             .PATH 'E:\MAIN\'
             .INCLUDE 'CONST5X.IS'
             .INCLUDE 'MACRO4X.IS'

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; String in DATA segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Initialize screen ]
; All registers are restored
;*****************************************************************************
Init_screen: 
             movem.l   d0/d1,-(sp)
             move.l    #Screen,d0           ; Calculate screen bases
             clr.b     d0
             addi.l    #256,d0
             move.l    d0,d1
             addi.l    #32000,d1
             move.l    d0,On_screen
             move.l    d1,Off_screen
             jsr       Set_screen           ; Set new screen base
             movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Copy visible screen to invisible screen ]
; All registers are restored
;*****************************************************************************
Copy_screen: 
             movem.l   d0-d7/a0-a6,-(sp)
             jsr       Mouse_off            ; Disable mouse
             movea.l   Screen_base,a0       ; Initialize registers
             movea.l   Off_screen,a1
             move.w    #666-1,d7
.Loop:       movem.l   (a0)+,d0-d6/a2-a6    ; Copy 48 bytes
             movem.l   d0-d6/a2-a6,(a1)
             lea.l     48(a1),a1            ; Next 48 bytes
             dbra      d7,.Loop
             movem.l   (a0),d0-d6/a2        ; Copy last 32 bytes
             movem.l   d0-d6/a2,(a1)
             jsr       Mouse_on             ; Enable mouse
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Set screen base ]
;   IN : d0 - New screen base (.l)
; All registers are restored
;*****************************************************************************
Set_screen:  
             movem.l   d0/a0,-(sp)
             tst.b     d0                   ; Error check on input
             beq.s     .Ok
             ERROR     "[ Set_screen ] : Illegal input !!!"
             bra.s     .Exit
.Ok:         move.l    d0,Screen_base       ; Store screen base
             lea.l     Vbase_Hi-1,a0        ; Set screen base
             lsr.w     #8,d0                ; (Trick by M.Bittner)
             move.l    d0,(a0)
.Exit:       movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Switch screens ]
; All registers are restored
;*****************************************************************************
Switch_screen:         
             move.l    d0,-(sp)
             move.l    Off_screen,d0        ; Exchange screen bases
             move.l    On_screen,Off_screen
             move.l    d0,On_screen
             jsr       Set_screen           ; Set new screen base
             jsr       My_vsync
             jsr       ScrQ_handler
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Clear screen ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Clear_screen:          
             movem.l   d0-d7/a0/a1,-(sp)    ; Save registers
             movem.l   Void,d0-d6/a0        ; Load void
             lea.l     32000(a6),a1         ; End of screen
             move.w    #1000-1,d7
.Loop:       movem.l   d0-d6/a0,-(a1)       ; Clear 32 bytes
             dbra      d7,.Loop             ; Next
             movem.l   (sp)+,d0-d7/a0/a1    ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ Wait for vertical blank ]
; All registers are restored
;*****************************************************************************
My_vsync:    
             movem.l   d0-d2/a0-a2,-(sp)    ; Save registers
             VSYNC     ; Sigh...
             movem.l   (sp)+,d0-d2/a0-a2    ; Restore registers
             rts                            ; Return

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
On_screen:   .DS.l 1   ; Pointers to in-game screen buffers
Off_screen:  .DS.l 1
Screen_base: .DS.l 1   ; Pointer to current screen buffer

Screen:      .DS.l 16064                    ; Two screen buffers

             .END 

