
; Interrupt routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 11-6-1991

;   "Ever tried driving it to golden heights
;     Just simply jiving it
;    My mystification it got a
;     Jewel sky crazy spacing it."
;   Our Song, Yes, 1983

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - I ASSUME there's nothing important in the old VBL-queue.
;     This CAN go wrong when non-standard harddisk-drivers or resident
;     programs insert themselves in the queue.

             .XDEF IFF_pal_convert,Random
             .XDEF Save_computer,Init_computer,Restore_computer
             .XDEF Old_screen,Vbl_count

             .XREF VblQ_handler,HBL_handler,Init_screen,My_mouse

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
; [ Save hardware parameters ]
; All registers are restored
;*****************************************************************************
Save_computer:         
             movem.l   d0-d7/a0,-(sp)       ; Save registers
; --------------------------------------------------------------------
             movem.l   Colour_0,d0-d7       ; Save screen settings
             movem.l   d0-d7,Old_pal
             move.b    Shift_mode,Old_rez
             lea.l     Vbase_Hi,a0
             movep.w   0(a0),d0
             move.w    d0,Old_screen
; --------------------------------------------------------------------
             move.w    sr,-(sp)             ; BLOCK ALL INTERRUPTS
             ori.w     #$700,sr
             lea.l     Old_MFP,a0           ; Save MFP registers
             move.b    MFP_Iera,(a0)+
             move.b    MFP_Ierb,(a0)+
             move.b    MFP_Ipra,(a0)+
             move.b    MFP_Iprb,(a0)+
             move.b    MFP_Imra,(a0)+
             move.b    MFP_Imrb,(a0)+
             move.b    MFP_vecbase,(a0)+
             move.b    MFP_Tbcr,(a0)+
             move.b    MFP_Tbdr,(a0)+
             move.b    MFP_Tcdcr,(a0)+
; --------------------------------------------------------------------
             move.l    Timer_C_vec,Old_timer_C+2  ; Save interrupt vectors
             move.l    MKB_vec,Old_mkb+2
             move.l    VBI_vec,Old_vbi+2
; --------------------------------------------------------------------
             move.w    Nvbls,Old_nvbls      ; Save system variables
             move.l    Scr_dump,Old_dump_vec
             move.b    Conterm,Old_conterm
             KBDVBASE 
             movea.l   d0,a0                ; Save mouse vector
             move.l    a0,KBD_vec
             move.l    16(a0),Old_mouse_vec
             move.w    (sp)+,sr             ; UNBLOCK INTERRUPTS
; --------------------------------------------------------------------
             movem.l   (sp)+,d0-d7/a0       ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ Restore hardware parameters ]
; All registers are restored
;*****************************************************************************
Restore_computer:      
             movem.l   d0-d7/a0,-(sp)       ; Save registers
; --------------------------------------------------------------------
             move.w    sr,-(sp)             ; BLOCK ALL INTERRUPTS
             ori.w     #$700,sr
             lea.l     Old_MFP,a0           ; Restore MFP registers
             move.b    (a0)+,MFP_Iera
             move.b    (a0)+,MFP_Ierb
             move.b    (a0)+,MFP_Ipra
             move.b    (a0)+,MFP_Iprb
             move.b    (a0)+,MFP_Imra
             move.b    (a0)+,MFP_Imrb
             move.b    (a0)+,MFP_vecbase
             move.b    (a0)+,MFP_Tbcr
             move.b    (a0)+,MFP_Tbdr
             move.b    (a0)+,MFP_Tcdcr
; --------------------------------------------------------------------
             move.l    Old_timer_C+2,Timer_C_vec  ; Restore vectors
             move.l    Old_mkb+2,MKB_vec
             move.l    Old_vbi+2,VBI_vec
; --------------------------------------------------------------------
             move.w    Old_nvbls,Nvbls      ; Restore system variables
             move.l    Old_dump_vec,Scr_dump
             move.b    Old_conterm,Conterm
             movea.l   KBD_vec,a0           ; Restore mouse vector
             move.l    Old_mouse_vec,16(a0)
             move.w    (sp)+,sr             ; UNBLOCK INTERRUPTS
; --------------------------------------------------------------------
             VSYNC 
             move.b    Old_rez,Shift_mode   ; Restore screen settings
             movem.l   Old_pal,d0-d7
             movem.l   d0-d7,Colour_0
             lea.l     Vbase_Hi,a0
             move.w    Old_screen,d0
             movep.w   d0,0(a0)
; --------------------------------------------------------------------
             movem.l   (sp)+,d0-d7/a0       ; Restore registers
             rts                            ; Return

;*****************************************************************************
; [ Set hardware parameters ]
; All registers are restored
;*****************************************************************************
Init_computer:         
             movem.l   d0-d7/a0,-(sp)
; --------------------------------------------------------------------
             move.w    sr,-(sp)             ; BLOCK ALL INTERRUPTS
             ori.w     #$700,sr
             lea.l     MFP_Base,a0          ; Enable Timer B & KBD
             move.w    #256+64+32,d0
             movep.w   d0,7(a0)
             movep.w   d0,19(a0)
             move.b    #0,MFP_Ipra          ; Clear pending registers
             move.b    #0,MFP_Iprb
             move.b    #$48,MFP_vecbase     ; Set vector base
             move.b    #0,MFP_Tbcr          ; Stop Timer B
; --------------------------------------------------------------------
             move.l    #My_timer_C,Timer_C_vec    ; Set interrupt vectors
             move.l    #My_mkb,MKB_vec
             move.l    #My_vbi,VBI_vec
; --------------------------------------------------------------------
             clr.w     Nvbls                ; Set system variables
             move.l    #Dummy,Scr_dump
             move.b    #8,Conterm           ;  (Key-click/repeat off)
             movea.l   KBD_vec,a0           ; Set mouse vector
             move.l    #My_mouse,16(a0)
             move.w    (sp)+,sr             ; UNBLOCK INTERRUPTS
; --------------------------------------------------------------------
             VSYNC 
             move.b    #0,Shift_mode        ; Low rez
             jsr       Init_screen
; --------------------------------------------------------------------
             movem.l   (sp)+,d0-d7/a0
Dummy:       rts       

;*****************************************************************************
; [ Stolen interrupts ]
;*****************************************************************************

My_timer_C:  move.w    #$2500,sr            ; Allow HBI override
Old_timer_C: jmp       $fc0000              ; Jump through old vector

My_mkb:      move.w    #$2500,sr            ; Allow HBI override
Old_mkb:     jmp       $fc0000              ; Jump through old vector

;*****************************************************************************
; [ Vertical blank routine ]
; All registers are restored
;*****************************************************************************
My_vbi:      
             jsr       HBL_handler          ; Handle HBL's
             addq.w    #1,Vbl_count         ; Increase counter
             jsr       VblQ_handler
Old_vbi:     jmp       $fc0000              ; Jump through old vector

;*****************************************************************************
; [ Convert IFF palette ]
;   IN : a0 - Pointer to IFF palette (.l)
;        a1 - Pointer to destination (.l)
; All registers are restored
;*****************************************************************************
IFF_pal_convert:       
             movem.l   d0/d7/a0/a1,-(sp)
             move.w    (a0)+,d7             ; Load number of colours
             subq.w    #1,d7                ; DBRA correction
.Loop:       move.w    (a0)+,d0             ; Load RED nibble
             lsl.w     #8,d0
             move.b    (a0)+,d0             ; Load GREEN nibble
             lsl.b     #4,d0
             or.b      (a0)+,d0             ; Load BLUE nibble
             move.w    d0,(a1)+             ; Store colour
             dbra      d7,.Loop
             movem.l   (sp)+,d0/d7/a0/a1
             rts       

;*****************************************************************************
; [ Get random number ]
;  OUT : d0 - Random number (.l)
; Changed registers : d0
;*****************************************************************************
Random:      
             movem.l   d1/d2/a0-a2,-(sp)
             _RANDOM   ; Sigh...
             movem.l   (sp)+,d1/d2/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
Old_nvbls:   .DS.w 1   ; Old system variables
Old_dump_vec:          .DS.l 1
Old_conterm: .DS.b 1
             .EVEN 
Old_mouse_vec:         .DS.l 1

Old_rez:     .DS.b 1   ; Old screen settings
             .EVEN 
Old_pal:     .DS.w 16
Old_screen:  .DS.w 1

Old_MFP:     .DS.b 10  ; Old MFP registers
             .EVEN 

KBD_vec:     .DS.l 1   ; Pointer to KBD-structure
Vbl_count:   .DS.w 1   ; Vbl counter

             .END 

