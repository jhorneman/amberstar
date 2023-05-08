
; Module Control routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 29-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - The instruction sequence in the main loop ensures error-free operation
;     when a process invoked by the Input Handler pushes or pops a module.

             .XDEF ScrQ_handler,VblQ_handler

Max_modules  = 16

             .TEXT 
;*****************************************************************************
; [ Init current module's display ]
; All registers are restored
;*****************************************************************************
Init_display:          
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Module_sp,a1
             move.l    DisInit_ptr(a1),d0   ; Get vector
             beq.s     .Exit
             movea.l   d0,a0                ; Execute
             jsr       (a0)
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Exit current module's display ]
; All registers are restored
;*****************************************************************************
Exit_display:          
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Module_sp,a1
             move.l    DisExit_ptr(a1),d0   ; Get vector
             beq.s     .Exit
             movea.l   d0,a0                ; Execute
             jsr       (a0)
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Push new module ]
;   IN : a0 - Pointer to new module data (.l)
; All registers are restored
;*****************************************************************************
Push_Module: 
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Module_sp,a1
             lea.l     ModuleDataSize(a1),a1      ; Increase module sp
             cmpa.l    #End_of_module_stack,a1
             bmi.s     .Not_full
             ERROR     "[ Push_Module ] : Module stack overflow !!!"
             bra.s     .Exit
.Not_full:   move.l    a1,Module_sp
             moveq.l   #(ModuleDataSize/2)-1,d7   ; Copy module data
.Loop:       move.w    (a0)+,(a1)+
             dbra      d7,.Loop
             lea.l     -ModuleDataSize(a1),a1
             st        Abort_list           ; Abort list
             move.w    Mouse_ptr(a1),d0     ; Set new mouse pointer
             jsr       Push_Mptr
             move.l    ModInit_ptr(a1),d0   ; Call initialization routine
             beq.s     .Exit
             movea.l   d0,a0
             jsr       (a0)
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Pop current module ]
; All registers are restored
;*****************************************************************************
Pop_Module:  
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Module_sp,a1
             cmpa.l    #Module_stack,a1
             bpl.s     .Not_empty
             ERROR     "[ Pop_Module ] : Module stack underflow !!!"
             bra       .Exit
.Not_empty:  lea.l     -ModuleDataSize(a1),a0     ; Decrease sp
             move.l    a0,Module_sp
             move.l    ModExit_ptr(a1),d0   ; Exit current module
             beq.s     .Zero1
             move.l    a1,-(sp)
             movea.l   d0,a0
             jsr       (a0)
             movea.l   (sp)+,a1
.Zero1:      st        Abort_list           ; Abort list
             Pop       Mptr                 ; Previous mouse pointer
             move.l    Return_ptr(a1),d0    ; Execute return routine
             beq.s     .Exit
             movea.l   d0,a0
             jsr       (a0)
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Input handler ]
; All registers are restored
;*****************************************************************************
Input_handler:         
             movem.l   d0-d2/a0,-(sp)
             sf        Abort_list
; ------------- Handle mouse input -----------------------------------
             move.w    Mouse_X,d0           ; Get object ID
             move.w    Mouse_Y,d1
             jsr       Find_object
             moveq.l   #0,d0                ; Create event ID
             move.b    Mouse_unclick_state,d0     ; Button states
             lsl.w     #2,d0
             or.b      Mouse_click_state,d0
             lsl.w     #2,d0
             or.b      Mouse_button_state,d0
             or.b      Mouse_click_state,d0 ; HA !
             tst.w     X_trespass           ; Horizontal trespass ?
             beq.s     .Skip1
             bset      #6,d0
.Skip1:      tst.w     Y_trespass           ; Vertical trespass ?
             beq.s     .Skip2
             bset      #7,d0
.Skip2:      lsl.w     #8,d0                ; Object ID
             swap.w    d0
             or.l      d2,d0
             clr.b     Mouse_click_state    ; Clear flags
             clr.b     Mouse_unclick_state
             movea.l   Module_sp,a0         ; Get pointer to Mev
             move.l    Mev_ptr(a0),d1
             beq.s     .No_Mev
             movea.l   d1,a0
             jsr       Handle_list
.No_Mev:     tst.b     Abort_list
             bne.s     .Exit
; ------------- Handle key input -------------------------------------
             jsr       Read_key             ; Read a key
             tst.l     d0                   ; Key pressed ?
             beq.s     .Exit
             bset      #31,d0               ; Indicate key was pressed
             movea.l   Module_sp,a0         ; Get pointer to Kev
             move.l    Kev_ptr(a0),d1
             beq.s     .Exit
             movea.l   d1,a0
             jsr       Handle_list
.Exit:       movem.l   (sp)+,d0-d2/a0
             rts       

; [ Event list handler ]
;   IN : d0 - Event ID (.l)
;        a0 - Pointer to Mev (.l)
; All registers are restored
Handle_list: 
             movem.l   d0-d7/a0-a6,-(sp)
.Again:      tst.l     (a0)                 ; End of list ?
             beq.s     .Exit
             move.l    (a0)+,d1             ; Mask
             and.l     d0,d1
             cmp.l     (a0)+,d1             ; Compare
             bne.s     .Next
             movem.l   d0/a0,-(sp)          ; Execute routine
             movea.l   (a0),a0
             jsr       (a0)
             movem.l   (sp)+,d0/a0
             tst.b     Abort_list           ; Abort list ?
             bne.s     .Exit
.Next:       addq.l    #4,a0                ; Next event
             bra.s     .Again
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Screen queue handler ]
; All registers are restored
;*****************************************************************************
ScrQ_handler:          
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Module_sp,a0         ; Get pointer to Screen Q
             move.l    ScrQ_ptr(a0),d0
             beq.s     .Exit
             movea.l   d0,a0
.Loop:       tst.l     (a0)                 ; End of list ?
             beq.s     .Exit
             move.l    a0,-(sp)             ; Execute routine
             movea.l   (a0),a0
             jsr       (a0)
             movea.l   (sp)+,a0
             addq.l    #4,a0                ; Next entry
             bra.s     .Loop
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; [ Vbl queue handler ]
; All registers are restored
;*****************************************************************************
VblQ_handler:          
             movem.l   d0-d7/a0-a6,-(sp)

             move.l    DangerZone,d0
             beq.s     .AllClear
             movea.l   d0,a0
             tst.l     (a0)
             beq.s     .AllClear
             ERROR     "Fatal error! Contact the programmer!"
             illegal 
.AllClear:   
             movea.l   Module_sp,a0         ; Get pointer to Vbl Q
             move.l    VblQ_ptr(a0),d0
             beq.s     .Exit
             movea.l   d0,a0
.Loop:       tst.l     (a0)                 ; End of list ?
             beq.s     .Exit
             move.l    a0,-(sp)             ; Execute routine
             movea.l   (a0),a0
             jsr       (a0)
             movea.l   (sp)+,a0
             addq.l    #4,a0                ; Next entry
             bra.s     .Loop
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .ABS 0
             .DS.l 1   ; Pointer to display update routine
VblQ_ptr:    .DS.l 1   ; Pointer to Vbl queue
ScrQ_ptr:    .DS.l 1   ; Pointer to Screen queue
Mev_ptr:     .DS.l 1   ; Pointer to Mouse Event list
Kev_ptr:     .DS.l 1   ; Pointer to Key Event list
ModInit_ptr: .DS.l 1   ; Pointer to Module Init routine
ModExit_ptr: .DS.l 1   ; Pointer to Module Exit routine
DisInit_ptr: .DS.l 1   ; Pointer to Display Init routine
DisExit_ptr: .DS.l 1   ; Pointer to Display Exit routine
IDString_ptr:          .DS.l 1              ; Pointer to identification string
Return_ptr:  .DS.l 1   ; Pointer to routine called after POPping this module
Mouse_ptr:   .DS.w 1   ; Number of mouse pointer
ModuleDataSize:        

             .DATA 
Module_sp:   .DC.l Module_stack-ModuleDataSize

             .BSS 
Abort_list:  .DS.b 1
             .EVEN 
Module_stack:          .DS.b Max_modules*ModuleDataSize
End_of_module_stack:   

             .END 







