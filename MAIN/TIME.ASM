
; Time update routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 29-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

             .TEXT 
;*****************************************************************************
; [ Initialize time  ]
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
Init_time:   
             movem.l   d0/d1,-(sp)
             moveq.l   #0,d0                ; Calculate current step
             move.b    Time_hour_len(a5),d0
             mulu.w    Hour,d0
             moveq.l   #0,d1
             move.w    Minute,d1
             add.l     d1,d0
             moveq.l   #0,d1
             move.b    Time_step_len(a5),d1
             divu.w    d1,d0
             move.w    d0,Current_step
             movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Update time (next step) ]
; All registers are restored
;*****************************************************************************
Update_time: 
             st        New_step             ; Signal
             movem.l   d0/d1/a0,-(sp)
             jsr       Every_step           ; 5 beautiful new minutes!
             moveq.l   #0,d1                ; Clear register
             movea.l   Mapd_ptr,a0
             addq.w    #1,Current_step      ; Next step
             move.w    Minute,d0
             move.b    Time_step_len(a0),d1
             add.w     d1,d0
             move.w    d0,Minute
             move.b    Time_hour_len(a0),d1 ; Next hour ?
             sub.w     d1,d0
             bmi       .Exit
             move.w    d0,Minute
             move.w    Hour,d0              ; Next hour
             addq.w    #1,d0
             move.w    d0,Hour
             jsr       Every_hour           ; A beautiful new hour!
             move.b    Time_day_len(a0),d1  ; Next day ?
             sub.w     d1,d0
             bmi       .Exit
             move.w    d0,Hour
             move.w    #0,Current_step      ; Next day
             addq.w    #1,Nr_travelled_days
             move.w    Day,d0
             addq.w    #1,d0
             move.w    d0,Day
             jsr       Every_day            ; A beautiful new day!
             move.b    Time_month_len(a0),d1      ; Next month ?
             sub.w     d1,d0
             bls       .Exit
             move.w    d0,Day
             move.w    Month,d0             ; Next month
             addq.w    #1,d0
             move.w    d0,Month
             move.b    Time_year_len(a0),d1 ; Next year ?
             sub.w     d1,d0
             bls       .Exit
             move.w    d0,Month
             addq.w    #1,Year              ; Next year
             addq.w    #1,Time_data_year
             jsr       Every_year           ; A beautiful new year!
.Exit:       movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Every step ]
; All registers are restored
;*****************************************************************************
Every_step:  
             movem.l   d7/a0,-(sp)
             lea.l     Spell_1_duration,a0  ; Update special spells
             moveq.l   #6-1,d7
.Loop:       tst.w     (a0)                 ; Active ?
             beq.s     .Next
             subq.w    #1,(a0)              ; Time out !
.Next:       addq.l    #2,a0                ; Next spell
             dbra      d7,.Loop
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Every hour ]
; All registers are restored
;*****************************************************************************
Every_hour:  
             movem.l   d0-d2/d7/a0/a1,-(sp)
             lea.l     Chard_ptrs,a0        ; Any poisoned people in the
             moveq.l   #1,d7                ; party ?
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d2            ; Alive and kicking ?
             and.w     Body_conditions(a1),d2
             bne.s     .Next
             btst      #1,Body_conditions(a1)     ; Poisoned ?
             beq.s     .Next
             jsr       Random               ; Hurt person
             moveq.l   #5,d1
             mulu.w    d0,d1
             swap.w    d1
             addq.w    #1,d1
             move.w    d7,d0
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0-d2/d7/a0/a1
             rts       

;*****************************************************************************
; [ Every day ]
; All registers are restored
;*****************************************************************************
Every_day:   
             movem.l   d0/d1/d7/a0/a1,-(sp)
             lea.l     Chard_ptrs,a0        ; Any diseased people in the
             moveq.l   #0,d1                ; party ?
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d0            ; Alive and kicking ?
             and.w     Body_conditions(a1),d0
             bne.s     .Next
             btst      #3,Body_conditions(a1)     ; Diseased ?
             beq.s     .Next
             lea.l     Attr_1_normal(a1),a2 ; Choose attribute
             jsr       Random
             mulu.w    #8,d0                ; Only first 8 !!!
             swap.w    d0
             add.w     d0,d0
             adda.w    d0,a2
             move.w    (a2),d0
             cmpi.w    #1,d0                ; Already one ?
             beq.s     .Done
             subq.w    #1,d0                ; Decrease attribute
             move.w    d0,(a2)
.Done:       move.w    d7,d0                ; Display empty damage star
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0/d1/d7/a0/a1
             rts       

;****************************************************************************
; [ Every year ]
; All registers are restored
;*****************************************************************************
Every_year:  
             movem.l   d0/d1/d7/a0/a1,-(sp)
             lea.l     Chard_ptrs,a0        ; Any old people in the
             moveq.l   #1,d7                ; party ?
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d0            ; Alive and kicking ?
             and.w     Body_conditions(a1),d0
             bne.s     .Next
             move.w    Attr_9_normal(a1),d0 ; Get age
             add.w     Attr_9_normal_magic(a1),d0
             add.w     Time_data_year,d0
             move.w    Attr_9_max(a1),d1    ; Get maximum age
             cmp.w     d0,d1                ; Too old ?
             bpl.s     .Next
             ori.w     #$2000,Body_conditions(a1) ; Kill!
             cmp.w     Active_member,d7     ; Was it our trusty leader ?
             bne.s     .Next
             clr.w     Active_member        ; Select a new active member
             jsr       Exit_display
             move.l    a0,-(sp)
             Push      Module,ActSel_Mod
             movea.l   (sp)+,a0
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0/d1/d7/a0/a1
             rts       

;*****************************************************************************
; [ Zzz function ]
; All registers are restored
;*****************************************************************************
Zzz:         
             move.w    #0,Frame             ; Clear Vbl-counter
             jsr       Update_time          ; Next step
             rts       

;*****************************************************************************
; [ Realtime step update ]
; All registers are restored
;*****************************************************************************
Realtime_step:         
             move.l    d0,-(sp)
             tst.b     Time_lock            ; Update ?
             bne.s     .Exit
             move.w    Frame,d0             ; Next frame
             addq.w    #1,d0
             move.w    d0,Frame
             sub.w     Vbl_per_step,d0      ; Next step ?
             bmi.s     .Exit
             move.w    d0,Frame             ; Clear counter
             jsr       Update_time          ; Next step
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Vbl_per_step:          .DC.w 500

             .BSS 
Time_lock:   .DS.b 1   ; Used to lock time-update
New_step:    .DS.b 1   ; Signals a new step
             .EVEN 
Current_step:          .DS.w 1              ; Current step
Frame:       .DS.w 1   ; Current frame (Vbl)

             .END 









