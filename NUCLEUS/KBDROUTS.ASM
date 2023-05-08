
; Keyboard & mouse routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 12-2-1991

;   "Along the drifting cloud the eagle searching
;     down on the land
;    Catching the swirling wind the sailor sees
;     the rim of the land
;    The eagles dancing wings create as weather
;     spins out of hand
;    Go closer hold the land feel partly no more
;     than grains of sand
;    We stand to lose all time a thousand answers
;     by in our hand
;    Next to your deeper fears we stand
;     surrounded by a million years."
;   Roundabout, Yes, 1972

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - These routines use TOS.
;   - The mouse is turned off by default !

             .XDEF Init_kbd,Draw_mouse,Erase_mouse
             .XDEF Push_Mptr,Pop_Mptr,Change_Mptr
             .XDEF Push_MA,Pop_MA,Mouse_on,Mouse_off
             .XDEF Read_key,Wait_4_key
             .XDEF Mouse_X,Mouse_Y,X_trespass,Y_trespass,Mouse_dX,Mouse_dY
             .XDEF Mouse_button_state,Mouse_click_state,Mouse_unclick_state
             .XDEF UDMPTR,My_mouse

             .XREF DI_Error,On_screen,Coord_convert

             .PATH 'E:\MAIN\'
             .INCLUDE 'CONST5X.IS'
             .INCLUDE 'MACRO4X.IS'

Max_mouses   = 26      ; Maximum number of mouse-pointers

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; String in DATA segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Push new MA ]
;   IN : a0 - Pointer to MA descriptor (.l)
; All registers are restored
;*****************************************************************************
Push_MA:     
             movem.l   d0-d2/a0/a1,-(sp)
             jsr       Mouse_off
             movea.l   MA_sp,a1             ; Increase MA sp
             addq.l    #4,a1
             move.l    Mouse_X,(a1)+        ; Store mouse coordinates (.l)
             cmpa.l    #End_of_MA_stack,a1
             bmi.s     .Not_full
             ERROR     "[ Push_MA ] : MA Stack overflow !!!"
             bra       .Exit
.Not_full:   move.l    a0,(a1)              ; Store new MA descriptor
             move.l    a1,MA_sp             ; Store new sp
             lea.l     Fake_packet,a0       ; Initialize new MA
             jsr       My_mouse
.Exit:       jsr       Mouse_on
             movem.l   (sp)+,d0-d2/a0/a1
             rts       

;*****************************************************************************
; [ Pop current MA ]
; All registers are restored
;*****************************************************************************
Pop_MA:      
             movem.l   d0-d2/a0/a1,-(sp)
             jsr       Mouse_off
             movea.l   MA_sp,a1             ; Decrease MA sp
             cmpa.l    #MA_Stack,a1
             bhi.s     .Not_empty
             ERROR     "[ Pop_MA ] : MA Stack underflow !!!"
             bra       .Exit
.Not_empty:  move.l    -(a1),Mouse_X        ; Restore mouse coordinates
             subq.l    #4,a1
             move.l    a1,MA_sp             ; Store new sp
             lea.l     Fake_packet,a0       ; Initialize old MA
             jsr       My_mouse
.Exit:       jsr       Mouse_on
             movem.l   (sp)+,d0-d2/a0/a1
             rts       

;*****************************************************************************
; [ Push new mouse pointer ]
;   IN : d0 - Pointer number (.w)
; All registers are restored
;*****************************************************************************
Push_Mptr:   
             movem.l   d0/a0/a1,-(sp)
             jsr       Mouse_off
             cmpi.w    #Max_mouses+1,d0     ; Input too high ?
             bmi.s     .No_error1
             ERROR     "[ Push_Mptr ] : Illegal input !!!"
             bra.s     .Exit
.No_error1:  lea.l     Mouse_base,a0        ; Calculate graphics address
             mulu.w    #68,d0
             adda.w    d0,a0
             movea.l   Mptr_sp,a1           ; Get sp
             addq.l    #4,a1
             tst.l     (a1)                 ; Stack full ?
             beq.s     .No_error2
             ERROR     "[ Push_Mptr ] : Stack is full !!!"
             bra.s     .Exit
.No_error2:  move.l    a0,(a1)              ; Push on stack
             move.l    a1,Mptr_sp           ; Store sp
.Exit:       jsr       Mouse_on
             movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Pop mouse pointer ]
; All registers are restored
;*****************************************************************************
Pop_Mptr:    
             move.l    a1,-(sp)
             jsr       Mouse_off
             movea.l   Mptr_sp,a1           ; Get sp
             cmpa.l    #Mptr_stack,a1       ; Stack empty ?
             bhi.s     .No_error
             ERROR     "[ Pop_Mptr ] : Stack is empty !!!"
             bra.s     .Exit
.No_error:   clr.l     (a1)                 ; Pop from stack
             subq.l    #4,a1
             move.l    a1,Mptr_sp           ; Store sp
.Exit:       jsr       Mouse_on
             movea.l   (sp)+,a1
             rts       

;*****************************************************************************
; [ Change current mouse pointer ]
;   IN : d0 - Pointer number (.w)
; All registers are restored
;*****************************************************************************
Change_Mptr: 
             movem.l   d0/a0/a1,-(sp)
             cmpi.w    #Max_mouses+1,d0     ; Input too high ?
             bmi.s     .No_error1
             ERROR     "[ Change_Mptr ] : Illegal input !!!"
             bra.s     .Exit
.No_error1:  lea.l     Mouse_base,a0        ; Calculate graphics address
             mulu.w    #68,d0
             adda.w    d0,a0
             movea.l   Mptr_sp,a1           ; Get sp
             move.l    a0,(a1)              ; Change
.Exit:       movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Read key from keyboard ]
;  OUT : d0 - 0 : No key available (.l)
;           <>0 : bit  0- 7 : ASCII-code of pressed key
;                 bit 16-23 : Scan-code of pressed key
;                 bit    24 : Right shift
;                 bit    25 : Left shift
;                 bit    26 : Control
;                 bit    27 : Alternate
;                 bit    28 : Caps Lock
;                 bit    29 : Clr/Home, emulating left mouse button
;                 bit    30 : Insert, emulating right mouse button
; Changed registers : d0
;*****************************************************************************
Read_key:    
             movem.l   d1-d3/a0-a2,-(sp)
             C_CONIS   ; Check status of standard input
             tst.w     d0                   ; Is there a key available ?
             bne.s     .Read
             movea.l   _Sysbase,a0          ; Get pointer to TOS-header
             cmpi.w    #$102,2(a0)          ; Tos 1.2 or higher ?
             bmi.s     .Tos_10
             movea.l   $24(a0),a0           ; Get address of Kbshift
             move.b    $1e(a0),d1           ; Read previous scan-code
             bra.s     .Previous
.Tos_10:     move.b    $e39,d1              ; Read previous scan-code
.Previous:   cmp.b     Last_key+1,d1        ; Last key pressed ?
             bne.s     .Exit
             move.l    Last_key,d0          ; Last key still pressed
             bra.s     .Exit
.Read:       C_RAWCIN  ; Raw input from standard input
             move.l    d0,d3                ; Protect d0
.Repeat:     C_CONIS   ; Wait until there are no more keys
             tst.w     d0
             beq.s     .Done
             C_RAWCIN 
             bra.s     .Repeat
.Done:       move.l    d3,d0                ; Copy to output register
             move.l    d0,Last_key          ; Store for next time
.Exit:       movem.l   (sp)+,d1-d3/a0-a2
             rts       

;*****************************************************************************
; [ Wait for key from keyboard ]
;  OUT : d0 - 0 : No key available (.l)
;           <>0 : bit  0- 7 : ASCII-code of pressed key
;                 bit 16-23 : Scan-code of pressed key
;                 bit    24 : Right shift
;                 bit    25 : Left shift
;                 bit    26 : Control
;                 bit    27 : Alternate
;                 bit    28 : Caps Lock
;                 bit    29 : Clr/Home, emulating left mouse button
;                 bit    30 : Insert, emulating right mouse button
; Changed registers : d0
;*****************************************************************************
Wait_4_key:  
             movem.l   d1/d2/a0-a2,-(sp)
             C_RAWCIN  ; Raw input from standard input
             movem.l   (sp)+,d1/d2/a0-a2
             rts       

;*****************************************************************************
; [ Initialize keyboard ]
; All registers are restored
;*****************************************************************************
Init_kbd:    
             move.l    #MArea_0,MA_Stack    ; Initialize mouse routine
             jsr       Draw_mouse
             rts       

;*****************************************************************************
; [ Personal mouse handler ]
;   IN : a0 - Pointer to IKBD relative mouse packet (.l)
;             0(a0) = bit 0 - Right mouse-button status
;                     bit 1 -  Left mouse-button status
;             1(a0) = relative X-coordinate displacement
;             2(a0) = relative Y-coordinate displacement
; Changed registers : d0,d1,d2,a1
;*****************************************************************************
My_mouse:    
             movea.l   MA_sp,a1             ; Get pointer to MA
             movea.l   (a1),a1
; ------------- Update mouse button state ----------------------------
             moveq.l   #3,d0                ; Load button state
             and.b     (a0),d0              ; Mask off rubbish
             move.b    Mouse_button_state,d1      ; Load old button state
             move.b    d1,d2                ; Duplicate
             not.b     d1                   ; Calculate click state
             and.b     d0,d1
             or.b      d1,Mouse_click_state ; Store new click state
             move.b    d0,Mouse_button_state      ; Store new button state
             not.b     d0                   ; Calculate unclick state
             and.b     d2,d0
             or.b      d0,Mouse_unclick_state
; ------------- Update X-coordinate ----------------------------------
             move.b    1(a0),d0             ; Load delta-X
             move.w    Mouse_X,d1           ; Load current X-coordinate
             ext.w     d0                   ; Update X-coordinate
             add.w     d0,Mouse_dX
             add.w     d0,d1
             move.w    d1,d2                ; Duplicate X-coordinate
             sub.w     (a1),d2              ; Check X against left
             bpl.s     .No_clip1            ; boundary
             move.w    (a1),Mouse_X         ; Set X to left boundary
             bra.s     .Skip_1
.No_clip1:   move.w    d1,d2                ; Duplicate X-coordinate
             sub.w     2(a1),d2             ; Check X against right
             blt.s     .No_clip2            ; boundary
             move.w    2(a1),Mouse_X        ; Set X to right boundary
             bra.s     .Skip_1
.No_clip2:   move.w    d1,Mouse_X           ; Store new X-coordinate
             moveq.l   #0,d2                ; No X-trespass
.Skip_1:     move.w    d2,X_trespass        ; Store X-trespass
; ------------- Update Y-coordinate ----------------------------------
             move.b    2(a0),d0             ; Load delta-Y
             move.w    Mouse_Y,d1           ; Load current Y-coordinate
             ext.w     d0                   ; Update Y-coordinate
             add.w     d0,Mouse_dY
             add.w     d0,d1
             move.w    d1,d2                ; Duplicate Y-coordinate
             sub.w     4(a1),d2             ; Check Y against top boundary
             bpl.s     .No_clip3
             move.w    4(a1),Mouse_Y        ; Set Y to top boundary
             bra.s     .Skip_2
.No_clip3:   move.w    d1,d2                ; Duplicate Y-coordinate
             sub.w     6(a1),d2             ; Check Y against bottom boundary
             blt.s     .No_clip4
             move.w    6(a1),Mouse_Y        ; Set Y to bottom boundary
             bra.s     .Skip_2
.No_clip4:   move.w    d1,Mouse_Y           ; Store new Y-coordinate
             moveq.l   #0,d2                ; No Y-trespass
.Skip_2:     move.w    d2,Y_trespass        ; Store Y-trespass
             rts       

;*****************************************************************************
; [ Switch the mouse on ]
; All registers are restored
;*****************************************************************************
Mouse_on:    
             tst.b     Mouse_flag           ; Already on ?
             beq.s     .Exit
             cmpi.b    #1,Mouse_flag        ; On now ?
             bne.s     .Skip
             jsr       DrawM_entry          ; Force draw
.Skip:       subq.b    #1,Mouse_flag        ; Decrease flag
.Exit:       rts       

;*****************************************************************************
; [ Switch the mouse off ]
; All registers are restored
;*****************************************************************************
Mouse_off:   
             addq.b    #1,Mouse_flag        ; Increase flag
             cmpi.b    #1,Mouse_flag        ; Off now ?
             bne.s     .Exit
             jsr       EraseM_entry         ; Force erase
.Exit:       rts       

;*****************************************************************************
; [ Mouse pointer erase & redraw routine ]
; All registers are restored
;*****************************************************************************
Erase_mouse: 
             tst.b     Mouse_flag           ; Mouse on ?
             bne.s     Exit_EraseM
EraseM_entry:          movem.l              d0-d3/d7/a0-a3/a6,-(sp)
             movea.l   Erase_rout,a1        ; Call erase routine
             lea.l     Mouse_back_buffer,a2
             movea.l   Erase_adr,a3
             move.w    Erase_height,d7
             jsr       (a1)
             movem.l   (sp)+,d0-d3/d7/a0-a3/a6
Exit_EraseM: rts       

Draw_mouse:  
             tst.b     Mouse_flag           ; Mouse on ?
             bne       Exit_DrawM
DrawM_entry: movem.l   d0-d3/d7/a0-a2/a6,-(sp)
             movea.l   On_screen,a6         ; Load screen base
             movea.l   Mptr_sp,a0           ; Get mouse graphics address
             movea.l   (a0),a0
             move.w    Mouse_X,d0           ; Load current coordinates
             move.w    Mouse_Y,d1
             sub.w     (a0)+,d0             ; Subtract HotSpot coordinates
             sub.w     (a0)+,d1
             lea.l     Mouse_draw_normal,a1 ; No clipping
             tst.w     d0                   ; X < 0 ?
             bpl.s     .No_left
             lea.l     Mouse_draw_left,a1   ; Clip left
             bra.s     .Continue
.No_left:    cmpi.w    #320-15,d0           ; X >= 320-16 ?
             bmi.s     .Continue
             lea.l     Mouse_draw_right,a1  ; Clip right
.Continue:   moveq.l   #16-1,d7             ; Height = 16
             tst.w     d1                   ; Y < 0 ?
             bpl.s     .No_up
             add.w     d1,d7                ; H = H + Y
             add.w     d1,d1                ; Y = Y x 2
             suba.w    d1,a0                ; Skip graphic lines
             moveq.l   #0,d1                ; Y = 0
             bra.s     .Continue2
.No_up:      cmpi.w    #200-15,d1           ; Y > 200-16 ?
             bmi.s     .Continue2
             move.w    #199,d7              ; H = 199 - Y
             sub.w     d1,d7
.Continue2:  move.w    d7,Erase_height      ; Store height
             lea.l     Mouse_back_buffer,a2 ; Call draw routine
             jsr       (a1)
             movem.l   (sp)+,d0-d3/d7/a0-a2/a6
Exit_DrawM:  rts       

; Draw mouse-pointer without horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a0 - Graphic pointer (.l)
;        a2 - Background buffer (.l)
;        a6 - Screen base (.l)
Mouse_draw_normal:     
             move.l    #Mouse_erase_normal,Erase_rout
             jsr       Coord_convert        ; Convert coordinates
             move.w    d3,d0
             lea.l     0(a6,d2.w),a1        ; Calculate screen address
             move.l    a1,Erase_adr
.Loop:       moveq.l   #0,d2                ; Clear registers
             moveq.l   #-1,d3
             move.w    (a0)+,d2             ; Load graphic line
             move.w    32-2(a0),d3          ; Load mask line
             ror.l     d0,d2                ; Rotate lines
             ror.l     d0,d3
             .REPT 4
             move.w    (a1),(a2)+           ; Save background
             and.w     d3,(a1)              ; Mask
             or.w      d2,(a1)+
             .ENDR 
             swap.w    d2                   ; Second half
             swap.w    d3
             .REPT 4
             move.w    (a1),(a2)+           ; Save background
             and.w     d3,(a1)              ; Mask
             or.w      d2,(a1)+
             .ENDR 
             lea.l     160-16(a1),a1        ; Next line
             dbra      d7,.Loop
             rts       

; Draw mouse-pointer with left horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a0 - Graphic pointer (.l)
;        a2 - Background buffer (.l)
;        a6 - Screen base (.l)
Mouse_draw_left:       
             move.l    #Mouse_erase_left,Erase_rout
             addi.w    #16,d0               ; Adapt X-coordinate
             jsr       Coord_convert        ; Convert coordinates
             move.w    d3,d0
             lea.l     0(a6,d2.w),a1        ; Calculate screen address
             move.l    a1,Erase_adr
.Loop:       moveq.l   #0,d2                ; Clear registers
             moveq.l   #-1,d3
             move.w    (a0)+,d2             ; Load graphic line
             move.w    32-2(a0),d3          ; Load mask line
             ror.l     d0,d2                ; Rotate lines
             ror.l     d0,d3
             swap.w    d2                   ; Second half
             swap.w    d3
             .REPT 4
             move.w    (a1),(a2)+           ; Save background
             and.w     d3,(a1)              ; Mask
             or.w      d2,(a1)+
             .ENDR 
             lea.l     160-8(a1),a1         ; Next line
             dbra      d7,.Loop
             rts       

; Draw mouse-pointer with right horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a0 - Graphic pointer (.l)
;        a2 - Background buffer (.l)
;        a6 - Screen base (.l)
Mouse_draw_right:      
             move.l    #Mouse_erase_right,Erase_rout
             jsr       Coord_convert        ; Convert coordinates
             move.w    d3,d0
             lea.l     0(a6,d2.w),a1        ; Calculate screen address
             move.l    a1,Erase_adr
.Loop:       moveq.l   #0,d2                ; Clear registers
             moveq.l   #-1,d3
             move.w    (a0)+,d2             ; Load graphic line
             move.w    32-2(a0),d3          ; Load mask line
             ror.l     d0,d2                ; Shift lines
             ror.l     d0,d3
             .REPT 4
             move.w    (a1),(a2)+           ; Save background
             and.w     d3,(a1)              ; Mask
             or.w      d2,(a1)+
             .ENDR 
             lea.l     160-8(a1),a1         ; Next line
             dbra      d7,.Loop
             rts       

; Erase mouse-pointer without horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a2 - Background buffer (.l)
;        a3 - Erase screen address (.l)
Mouse_erase_normal:    
.Loop:       movem.l   (a2)+,d0-d3          ; Restore background
             movem.l   d0-d3,(a3)
             lea.l     160(a3),a3           ; Next line
             dbra      d7,.Loop
             rts       

; Erase mouse-pointer with left horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a2 - Background buffer (.l)
;        a3 - Erase screen address (.l)
Mouse_erase_left:      
.Loop:       move.l    (a2)+,(a3)+          ; Restore background
             move.l    (a2)+,(a3)+
             lea.l     160-8(a3),a3         ; Next line
             dbra      d7,.Loop
             rts       

; Erase mouse-pointer with right horizontal clipping
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d7 - Height - 1 (.w)
;        a2 - Background buffer (.l)
;        a3 - Erase screen address (.l)
Mouse_erase_right:     
.Loop:       move.l    (a2)+,(a3)+          ; Restore background
             move.l    (a2)+,(a3)+
             lea.l     160-8(a3),a3         ; Next line
             dbra      d7,.Loop
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
MA_sp:       .DC.l MA_Stack
MArea_0:     .DC.w 0,319,0,199

Mptr_sp:     .DC.l Mptr_stack
Mptr_stack:  .DC.l Mouse_base
             .DCB.l 16,0                    ; 16 entries
             .DC.w -1  ; Sentinel

Mouse_flag:  .DC.b 1   ; Mouse visibility COUNTER
             .EVEN 

Mouse_X:     .DC.w 152 ; Current mouse coordinates
Mouse_Y:     .DC.w 92

; This is the data for the mouse pointers.
; The data format is as follows :
;    0 - Hot Spot X-coordinate (.w)
;    2 - Hot Spot Y-coordinate (.w)
;    4 - Graphic data (16.w)
;   36 - Mask data (16.w)
Mouse_base:  
             .DC.w 1,1 ; Sword
             .DC.w 0,$7000,$7800,$5c00,$2e00,$1700,$b98,$5d8,$2f0,$160,$f0,$3b8,$31e,$a,$c,0,$fff,$7ff,$3ff,$1ff,$80ff
             .DC.w $c067,$e003,$f003,$f807,$fc0f,$fc07,$f800,$f840,$fce0,$ffe1,$ffe3
             .DC.w 7,7 ; 2D Arrow Up
             .DC.w 0,0,0,$100,$280,$540,$aa0,$1ef0,$280,$280,$280,$280,$380,0,0,0,$ffff,$ffff,$feff,$fc7f,$f83f,$f01f
             .DC.w $e00f,$c007,$c007,$f83f,$f83f,$f83f,$f83f,$f83f,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Down
             .DC.w 0,0,0,$1c0,$140,$140,$140,$140,$f78,$550,$2a0,$140,$80,0,0,0,$ffff,$ffff,$fc1f,$fc1f,$fc1f,$fc1f
             .DC.w $fc1f,$e003,$e003,$f007,$f80f,$fc1f,$fe3f,$ff7f,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Right
             .DC.w 0,0,0,$80,$c0,$a0,$1fd0,$1028,$1fd0,$a0,$c0,$80,0,0,0,0,$ffff,$ffff,$fe7f,$fe3f,$fe1f,$c00f,$c007
             .DC.w $c003,$c007,$c00f,$fe1f,$fe3f,$fe7f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Left
             .DC.w 0,0,0,$100,$300,$500,$bf8,$1408,$bf8,$500,$300,$100,0,0,0,0,$ffff,$ffff,$fe7f,$fc7f,$f87f,$f003
             .DC.w $e003,$c003,$e003,$f003,$f87f,$fc7f,$fe7f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Up-Left
             .DC.w 0,0,0,0,$fe0,$840,$b80,$ac0,$b60,$db0,$8d8,$70,$20,0,0,0,$ffff,$ffff,$ffff,$e00f,$e00f,$e01f,$e03f
             .DC.w $e01f,$e00f,$e007,$e203,$e707,$ff8f,$ffdf,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Up-Right
             .DC.w 0,0,0,0,$7f0,$210,$1d0,$350,$6d0,$db0,$1b10,$e00,$400,0,0,0,$ffff,$ffff,$ffff,$f007,$f007,$f807
             .DC.w $fc07,$f807,$f007,$e007,$c047,$e0e7,$f1ff,$fbff,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Down-Right
             .DC.w 0,0,0,$400,$e00,$1b10,$db0,$6d0,$350,$1d0,$210,$7f0,0,0,0,0,$ffff,$ffff,$fbff,$f1ff,$e0e7,$c047
             .DC.w $e007,$f007,$f807,$fc07,$f807,$f007,$f007,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 2D Arrow Down-Left
             .DC.w 0,0,0,$20,$70,$8d8,$db0,$b60,$ac0,$b80,$840,$fe0,0,0,0,0,$ffff,$ffff,$ffdf,$ff8f,$e707,$e203,$e007
             .DC.w $e00f,$e01f,$e03f,$e01f,$e00f,$e00f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow In
             .DC.w 0,0,0,$100,$6c0,$1d70,$280,$280,$440,$440,$820,$fe0,0,0,0,0,$ffff,$ffff,$feff,$f83f,$e00f,$8003
             .DC.w $8003,$f83f,$f01f,$f01f,$e00f,$e00f,$c007,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow Out
             .DC.w 0,0,0,0,$380,$280,$440,$7efc,$1930,$6c0,$100,0,0,0,0,0,$ffff,$ffff,$ffff,$fc7f,$f83f,$f01f,$1,$1
             .DC.w $8003,$e00f,$f83f,$feff,$ffff,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow Right
             .DC.w 0,0,0,$200,$380,$1e0,$3fd8,$7fb6,$a4,$48,$50,$20,0,0,0,0,$ffff,$ffff,$f9ff,$f87f,$f81f,$c007,$8001
             .DC.w 0,$1,$ff03,$ff07,$ff8f,$ff9f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow Left
             .DC.w 0,0,0,$40,$1c0,$780,$1bfc,$6dfe,$2500,$1200,$a00,$400,0,0,0,0,$ffff,$ffff,$ff9f,$fe1f,$f81f,$e003
             .DC.w $8001,0,$8000,$c0ff,$e0ff,$f1ff,$f9ff,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow Turn Right
             .DC.w 0,0,0,$200,$380,$1e0,$7d8,$1bb6,$24a4,$4848,$4850,$7820,0,0,0,0,$ffff,$ffff,$f9ff,$f87f,$f81f,$f807
             .DC.w $e001,$c000,$8001,$103,$307,$38f,$39f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; 3D Arrow Turn Left
             .DC.w 0,0,0,$40,$1c0,$780,$1be0,$6dd8,$2524,$1212,$a12,$41e,0,0,0,0,$ffff,$ffff,$ff9f,$fe1f,$f81f,$e01f
             .DC.w $8007,$3,$8001,$c080,$e0c0,$f1c0,$f9c0,$ffff,$ffff,$ffff
             .DC.w 7,7 ; Disk
             .DC.w 0,0,$3768,$300c,$30cc,$30cc,$30cc,$300c,$3ffc,$3ffc,$3ffc,$3ffc,$3ffc,0,0,0,$ffff,$8007,$8003,$8001
             .DC.w $8001,$8001,$8001,$8001,$8001,$8001,$8001,$8001,$8001,$8001,$ffff,$ffff
             .DC.w 7,7 ; Zzz
             .DC.w 0,0,0,$3e00,$3e00,$600,$c00,$19e0,$3e60,$3ec0,$19c,$1e4,$8,$1c,0,0,$ffff,$ffff,$80ff,$80ff,$80ff
             .DC.w $80ff,$e00f,$c00f,$800f,$8001,$8001,$fc01,$fc01,$ffc1,$ffc1,$ffff
             .DC.w 7,7 ; Eye
             .DC.w 0,0,0,0,$ff0,$300c,$fc5e,$fe2f,$742e,$7a5e,$1db8,$7e0,0,0,0,0,$ffff,$ffff,$ffff,$f00f,$c003,$8001
             .DC.w 0,0,0,$8001,$e007,$f81f,$ffff,$ffff,$ffff,$ffff
             .DC.w 7,7 ; Mouth
             .DC.w 0,0,0,0,0,0,$ee0,$3ff8,$c006,$783c,$3ff8,$fe0,0,0,0,0,$ffff,$ffff,$ffff,$ffff,$ffff,$f01f,$c007
             .DC.w $1,$1,$1,$8003,$c007,$f01f,$ffff,$ffff,$ffff
             .DC.w 7,7 ; Ear
             .DC.w 0,$1c0,$7e0,$e30,$1c10,$1998,$1b48,$a48,$d58,$d90,$6b0,$660,$fc0,$f80,$700,0,$fe3f,$f81f,$f00f,$e007
             .DC.w $c007,$c003,$c003,$e003,$e003,$e007,$f007,$f00f,$e01f,$e03f,$f07f,$f8ff
             .DC.w 7,7 ; Full turn right
             .DC.w 0,0,0,0,0,0,$780,$1b60,$2490,$4850,$4b8e,$48d8,$7820,0,0,0,$ffff,$ffff,$ffff,$ffff,$ffff,$f87f,$e01f
             .DC.w $c00f,$8007,$1,0,$1,$307,$3df,$ffff,$ffff
             .DC.w 7,7 ; Little arrow up
             .DC.w 0,$100,$380,$7c0,$fe0,$380,$380,$380,0,0,0,0,0,0,0,0,$feff,$fc7f,$f83f,$f01f,$e00f,$e00f,$f83f,$f83f
             .DC.w $f83f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
             .DC.w 7,7 ; Little arrow down
             .DC.w 0,0,0,0,0,0,0,0,$380,$380,$380,$fe0,$7c0,$380,$100,0,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$f83f
             .DC.w $f83f,$f83f,$e00f,$e00f,$f01f,$f83f,$fc7f,$feff
             .DC.w 7,7 ; Full turn left
             .DC.w 0,0,0,0,0,0,$1e0,$6d8,$924,$a12,$71d2,$1b12,$41e,0,0,0,$ffff,$ffff,$ffff,$ffff,$ffff,$fe1f,$f807
             .DC.w $f003,$e001,$8000,0,$8000,$e0c0,$fbc0,$ffff,$ffff
UDMPTR:      .DC.w 7,7 ; User defined
             .DCB.w 32,0
             .DC.w 7,7 ; Gold
             .DC.w $f8,$104,$22a,$263,$227,$1273,$1507,$6efe,$107c,$1410,$1818,$1018,$838,$7f0,$3e0,0,$fe07,$fc03,$f801
             .DC.w $f800,$f800,$d800,$c000,0,$8000,$8001,$8003,$800f,$c00f,$e00f,$f01f,$f83f
             .DC.w 7,7 ; Food
             .DC.w 0,$3c00,$7e00,$7f00,$7f00,$7f80,$3f80,$e40,$180,$1c0,$e0,$70,$78,$58,$60,0,$c3ff,$80ff,$7f,$7f,$3f
             .DC.w $3f,$801f,$c01f,$f01f,$fc0f,$fe07,$ff03,$ff01,$ff01,$ff03,$ff87


             .BSS 
MA_Stack:    .DS.l 16  ; 8 entries
End_of_MA_stack:       

Last_key:    .DS.l 1   ; Last pressed key
Erase_adr:   .DS.l 1   ; Mouse erase parameters.
Erase_rout:  .DS.l 1
Erase_height:          .DS.w 1
Mouse_back_buffer:     .DS.w 8*16           ; Mouse pointer background buffer


; These contain the current button, click & unclick state of the mouse.
; The bits are ordered as follows :
;   0 - right button state,
;   1 - left button state,
; The other bits aren't used.
Mouse_click_state:     .DS.b 1
Mouse_unclick_state:   .DS.b 1
Fake_packet: 
Mouse_button_state:    .DS.b 1              ; PART OF FAKE PACKET !!!
             .DS.b 2
             .EVEN 
X_trespass:  .DS.w 1   ; Current boundary trespass values
Y_trespass:  .DS.w 1
Mouse_dX:    .DS.w 1   ; Cumulative relative coordinates
Mouse_dY:    .DS.w 1

             .END 











