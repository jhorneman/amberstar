
; 2D map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 2-3-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "Shall we seal the truth of life
;     Shall we light the heavens
;      We're so good at finding pleasure
;       As to what we are, and how we fit
;        Together"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :
;   - Order of arrays in ICON_DAT.nnn is vital !!!
;   - If movement is überhaupt impossible, this should be detected before
;     the movement routines are called.
;   - It is impossible to display all the 2D map using only the Nucleus
;     graphic functions, therefore these routines must be edited for the
;     AMIGA. See {Display_buffer}.
;   - The radius of the night circle must be even !!!
;   - Clearing and re-filling of the persons buffer must be performed
;     in separate routines in the program Q, inserted BEFORE the map-
;     display routine.
;   - The time re-evaluate routine assumes a day has 24 hours.

Max_radius   = 200     ; Maximum radius of night circle
Def_mapbuf_X           = 5                  ; Default map-buffer coordinates
Def_mapbuf_Y           = 4

             .TEXT 
;*****************************************************************************
; [ Re-evaluate light ]
; All registers are restored
;*****************************************************************************
M2_time_evaluate:      
             movem.l   d0/d1/a0,-(sp)
             movea.l   Current_active_char_data,a0          ; Blind ?
             btst      #4,Mind_conditions(a0)
             sne       Stygian              ; Darkness !
             bne       .Exit
             movea.l   Mapd_ptr,a0          ; Get bits
             move.b    Map_special(a0),d0
             btst      #0,d0                ; Light bit on ?
             beq.s     .No_light
             move.w    #0,Current_radius    ; No circle
             move.w    #0,New_radius
             bra       .Exit
.No_light:   btst      #1,d0                ; Change bit on ?
             beq.s     .No_change
             move.w    Hour,d0              ; Get current hour
             moveq.l   #0,d1                ; Get radius
             move.b    .Radius(pc,d0.w),d1
             tst.w     Spell_1_duration     ; Any light spell active ?
             beq.s     .No
             move.w    Spell_1_data,d0      ; Add light spell's effect
             lsl.w     #3,d0
             add.w     d0,d1
.No:         move.w    d1,New_radius        ; Store
             bra       .Exit
.Radius:     .DC.b 16,16,16,16,16,16,40,64
             .DCB.b 9,200
             .DC.b 64,64,40,16,16,16,16,16
             .EVEN 
.No_change:  btst      #2,d0                ; Dark bit on ?
             beq       .Exit
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             beq       .Exit
             tst.w     Spell_1_duration     ; Any light spell active ?
             seq       Stygian
             beq.s     .Exit
             move.w    Spell_1_data,d1      ; Get light spell's effect
             lsl.w     #3,d1
             addi.w    #16,d1
             move.w    d1,New_radius        ; Store
             move.w    d1,Current_radius
.Exit:       movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Build 2D map ]
; All registers are restored
;*****************************************************************************
Build_2D_map:          
             movem.l   d0-d7/a0-a6,-(sp)
             jsr       M2_time_evaluate     ; Re-evaluate time
; ------------- Calculate buffer coordinates -------------------------
             move.w    Mapbuf_X,d0          ; Get buffer coordinates
             move.w    Mapbuf_Y,d1
             addq.w    #1,d0                ; Adapt buffer coordinates
             addq.w    #1,d1
             add.w     d0,d0
             add.w     d1,d1
             add.w     Half_X,d0
             add.w     Half_Y,d1
             tst.w     Scroll_X
             bne.s     .Not_zero1
             sub.w     Half_X,d0
             sub.w     Half_X,d0
.Not_zero1:  tst.w     Scroll_Y
             bne.s     .Not_zero2
             sub.w     Half_Y,d1
             sub.w     Half_Y,d1
.Not_zero2:  move.w    d0,Buffer_X          ; Store party coordinates
             move.w    d1,Buffer_Y
; ------------- Test for complete darkness ---------------------------
             tst.b     Stygian              ; Complete darkness ?
             beq.s     .I_can_see
             lea.l     Graphics_buf,a0      ; Clear graphics buffer
             moveq.l   #0,d0
             move.w    #4576-1,d7
.Clear:      move.l    d0,(a0)+
             dbra      d7,.Clear
             movea.l   Icondata_ptr,a0      ; Display party
             jsr       Display_party_icon
             bra       .Cont
; ------------- Build graphics buffer --------------------------------
.I_can_see:  jsr       Shadow_handler       ; Handle shadows
             movea.l   Icondata_ptr,a0      ; Display map buffers
             lea.l     Underlay_buf,a1
             lea.l     Overlay_buf,a2
             lea.l     Persons_buf,a3
             lea.l     Trans_buf,a4
             movea.l   Iconstats_ptr,a5
             jsr       Get_hashable_number  ; Get hashable number
             moveq.l   #0,d1
             moveq.l   #0,d2
             moveq.l   #10,d7
.Loop_1:     moveq.l   #0,d0
             moveq.l   #12,d6
.Loop_2:     move.b    (a1)+,d2             ; Get underlay icon number
             subq.w    #1,d2
             move.w    d2,d3                ; Get icon status bits
             add.w     d3,d3
             add.w     d3,d3
             move.l    0(a5,d3.w),d3
             btst      #15,d3               ; Party invisible ?
             bne.s     .No_over
             jsr       Display_underlay_icon      ; Display underlay icon
             move.b    (a2),d2              ; Get overlay icon number
             beq.s     .No_over
             subq.w    #1,d2
             move.w    d2,d3                ; Get icon status bits
             add.w     d3,d3
             add.w     d3,d3
             move.l    0(a5,d3.w),d3
             btst      #6,d3                ; Ground overlay ?
             bne.s     .No_over
             btst      #15,d3               ; Party invisible ?
             bne.s     .No_over
             jsr       Display_overlay_icon ; Display icon
.No_over:    addq.l    #1,a2
             move.b    (a3)+,d2             ; Get person icon number
             beq.s     .No_person
             subq.w    #1,d2
             jsr       Display_overlay_icon ; Display overlay icon
.No_person:  move.b    (a4)+,d2             ; Get transport icon number
             beq.s     .Next
             subq.w    #1,d2
             jsr       Display_overlay_icon ; Display overlay icon
.Next:       addq.w    #1,d0                ; Next X
             addq.w    #1,d5
             dbra      d6,.Loop_2
             addq.w    #1,d1                ; Next Y
             subi.w    #13,d5
             add.w     Width_of_map,d5
             dbra      d7,.Loop_1
             movea.l   Icondata_ptr,a0
             cmpi.w    #5,Travel_mode       ; Giant eagle or higher ?
             bmi.s     .Normal
             jsr       Display_sky_icons    ; Display party in sky
             jsr       Display_party_icon
             bra.s     .Skip
.Normal:     jsr       Display_party_icon   ; Display party on ground
             jsr       Display_sky_icons
.Skip:       jsr       Display_night_circle ; Display night circle
.Cont:       movea.l   Off_screen,a6        ; Display graphics buffer
             jsr       Display_buffer
             jsr       Update_animation     ; Update animation
             clr.l     Scroll_X             ; Clear movement flags
             clr.l     Half_X
; ------------- Display "OUCH!" when necessary -----------------------
             tst.b     Bumped               ; Ouch ?
             beq.s     .Exit
             move.w    Buffer_X,d0          ; Get buffer coordinates
             move.w    Buffer_Y,d1
             lsl.w     #3,d0                ; Calculate screen coordinates
             lsl.w     #3,d1
             addi.w    #16-2,d0
             addi.w    #49-16-10,d1
             lea.l     Ouch,a0              ; Display OUCH!
             jsr       Blit_masked_block
             sf        Bumped               ; Clear flag
; ------------- Update rest of display -------------------------------
.Exit:       jsr       Update_status_block
             jsr       Show_special_items
             jsr       Show_spells
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

; [ Get hashable number ]
;  OUT : d5 - Hashable number (.w)
; Changed registers : d5
Get_hashable_number:   
             move.w    Map_Ycoord,d5        ; Calculate hashable number
             sub.w     Buffer_Y,d5
             subq.w    #1,d5
             mulu.w    Width_of_map,d5
             add.w     Map_Xcoord,d5
             sub.w     Buffer_X,d5
             subq.w    #1,d5
             rts       

;*****************************************************************************
; [ Display sky icons ]
;   IN : a0 - Pointer to icon data (.l)
; All registers are restored
;*****************************************************************************
Display_sky_icons:     
             movem.l   d0-d3/d5-d7/a1-a3,-(sp)
             lea.l     Underlay_buf,a1      ; Initialize registers
             lea.l     Overlay_buf,a2
             movea.l   Iconstats_ptr,a3
             jsr       Get_hashable_number  ; Get hashable number
             moveq.l   #0,d1
             moveq.l   #0,d2
             moveq.l   #10,d7
.Loop_1:     moveq.l   #0,d0
             moveq.l   #12,d6
.Loop_2:     move.b    (a1)+,d2             ; Get underlay icon number
             subq.w    #1,d2
             move.w    d2,d3                ; Get icon status bits
             add.w     d3,d3
             add.w     d3,d3
             move.l    0(a3,d3.w),d3
             btst      #15,d3               ; Party invisible ?
             beq.s     .No_under
             jsr       Display_underlay_icon      ; Display icon
             move.b    (a2)+,d2             ; Get overlay icon number
             beq.s     .Next
             subq.w    #1,d2
             jsr       Display_overlay_icon ; Display icon
             bra.s     .Next
.No_under:   move.b    (a2)+,d2             ; Get overlay icon number
             beq.s     .Next
             subq.w    #1,d2
             move.w    d2,d3                ; Get icon status bits
             add.w     d3,d3
             add.w     d3,d3
             move.l    0(a3,d3.w),d3
             btst      #6,d3                ; Sky overlay ?
             bne.s     .Draw
             btst      #15,d3               ; Party invisible ?
             beq.s     .Next
.Draw:       jsr       Display_overlay_icon ; Display icon
.Next:       addq.w    #1,d0                ; Next X
             addq.w    #1,d5
             dbra      d6,.Loop_2
             addq.w    #1,d1                ; Next Y
             subi.w    #13,d5
             add.w     Width_of_map,d5
             dbra      d7,.Loop_1
             movem.l   (sp)+,d0-d3/d5-d7/a1-a3
             rts       

;*****************************************************************************
; [ Display party icon ]
;   IN : a0 - Pointer to icon data (.l)
; All registers are restored
;*****************************************************************************
Display_party_icon:    
             movem.l   d0-d7/a0/a1,-(sp)
             tst.b     Party_invisible      ; Party visible ?
             bne       .Exit
             lea.l     Hold_1(a0),a1
             moveq.l   #0,d0                ; Get start of travel icons
             move.b    Travel_icon_start(a0),d0
             subq.w    #1,d0
             tst.b     Current_map_type     ; Wilderness ?
             beq.s     .Skip
             add.w     Travel_mode,d0
.Skip:       add.w     d0,d0                ; Get number of first frame
             move.w    0(a1,d0.w),d4
             move.w    View_direction,d0    ; Get view direction
             add.w     d0,d4                ; Add to frame number
             lea.l     Frame_graphics-128(a0),a0  ; Calculate frame address
             mulu.w    #134,d4
             adda.l    d4,a0
             move.w    Buffer_X,d0          ; Get buffer coordinates
             move.w    Buffer_Y,d1
             move.w    d1,d2                ; Y - buffer offset
             mulu.w    #13*64,d2
             move.w    d0,d3                ; X - buffer offset
             andi.w    #$fffe,d3
             add.w     d3,d3
             add.w     d3,d3
             add.w     d3,d2
             moveq.l   #1,d3                ; X - bit number
             and.w     d0,d3
             lsl.w     #3,d3
             lea.l     Graphics_buf,a1      ; Calculate buffer address
             adda.w    d2,a1
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
             lea.l     13*8-16(a1),a1       ; Next line
             dbra      d7,.Loop
.Exit:       movem.l   (sp)+,d0-d7/a0/a1
             rts       

;*****************************************************************************
; [ Display 2D map underlay icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon data (.l)
; All registers are restored
;*****************************************************************************
Display_underlay_icon: 
             movem.l   d0-d6/a0-a2,-(sp)
             lea.l     Frames(a0),a1        ; Get number of frames
             moveq.l   #0,d3
             move.b    0(a1,d2.w),d3
             subq.w    #1,d3                ; BASE 0 correction
             lea.l     250(a1),a1           ; Get icon number of 1st frame
             add.w     d2,d2
             move.w    0(a1,d2.w),d4
             lea.l     500(a1),a1           ; Get icon status
             add.w     d2,d2
             move.l    0(a1,d2.w),d6
             lea.l     Circle_anim,a1       ; Circle or wave ?
             btst      #0,d6
             beq.s     .Circle
             lea.l     Wave_anim,a1         ; Wave
.Circle:     add.w     d3,d3                ; Add number of frames
             add.w     d3,d3
             adda.w    d3,a1

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate in display window (.w)
;   d1 - Y-coordinate in display window (.w)
;   d4 - Icon number of first frame (.w)
;   d6 - Icon status (.l)
;   a1 - Pointer to animation table (.l)

             btst      #4,d6                ; Random animation ?
             beq.s     .No_random
             move.b    1(a1),d2             ; Random hash
             ext.w     d2
             add.w     d2,d5
             andi.w    #$000f,d5
             move.w    2(a1),d2             ; Test
             btst      d5,d2
             beq.s     .No_anim
.No_random:  move.b    (a1),d3              ; Get current frame
             ext.w     d3
             add.w     d3,d4
.No_anim:    lea.l     Frame_graphics-128(a0),a0  ; Calculate frame address
             mulu.w    #134,d4
             adda.l    d4,a0
             lea.l     Graphics_buf,a1      ; Calculate buffer address
             lsl.w     #3,d0
             adda.w    d0,a1
             mulu.w    #13*128,d1
             adda.w    d1,a1
             moveq.l   #15,d2
.Loop:       move.l    (a0)+,(a1)+          ; Copy one line
             move.l    (a0)+,(a1)+
             lea.l     13*8-8(a1),a1        ; Next line
             dbra      d2,.Loop
.Exit:       movem.l   (sp)+,d0-d6/a0-a2
             rts       

;*****************************************************************************
; [ Display 2D map overlay icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number (.w)
;        d5 - Hashable number (.w)
;        a0 - Pointer to icon data (.l)
; All registers are restored
;*****************************************************************************
Display_overlay_icon:  
             movem.l   d0-d6/a0/a1,-(sp)
             lea.l     Frames(a0),a1        ; Get number of frames
             moveq.l   #0,d3
             move.b    0(a1,d2.w),d3
             subq.w    #1,d3                ; BASE 0 correction
             lea.l     250(a1),a1           ; Get start frame number
             add.w     d2,d2
             move.w    0(a1,d2.w),d4
             lea.l     500(a1),a1           ; Get icon status
             add.w     d2,d2
             move.l    0(a1,d2.w),d6
             lea.l     Circle_anim,a1       ; Circle or wave ?
             btst      #0,d6
             beq.s     .Circle
             lea.l     Wave_anim,a1         ; Wave
.Circle:     add.w     d3,d3                ; Add number of frames
             add.w     d3,d3
             adda.w    d3,a1

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate in display window (.w)
;   d1 - Y-coordinate in display window (.w)
;   d4 - Icon number of first frame (.w)
;   d6 - Icon status (.l)
;   a1 - Pointer to animation table (.l)

             btst      #4,d6                ; Random animation ?
             beq.s     .No_random
             move.b    1(a1),d2             ; Random hash
             ext.w     d2
             add.w     d2,d5
             andi.w    #$000f,d5
             move.w    2(a1),d2             ; Test
             btst      d5,d2
             beq.s     .No_anim
.No_random:  move.b    (a1),d3              ; Get current frame
             ext.w     d3
             add.w     d3,d4
.No_anim:    lea.l     Frame_graphics-128(a0),a0  ; Calculate frame address
             mulu.w    #134,d4
             adda.l    d4,a0
             lea.l     Graphics_buf,a1      ; Calculate buffer address
             lsl.w     #3,d0
             adda.w    d0,a1
             mulu.w    #13*128,d1
             adda.w    d1,a1
             moveq.l   #15,d5
.Loop:       movem.w   (a0)+,d0-d3          ; Load one line
             move.w    d0,d4                ; Calculate mask
             or.w      d1,d4
             or.w      d2,d4
             or.w      d3,d4
             not.w     d4
             and.w     d4,(a1)              ; Mask one line
             or.w      d0,(a1)+
             and.w     d4,(a1)
             or.w      d1,(a1)+
             and.w     d4,(a1)
             or.w      d2,(a1)+
             and.w     d4,(a1)
             or.w      d3,(a1)+
             lea.l     13*8-8(a1),a1        ; Next line
             dbra      d5,.Loop
             movem.l   (sp)+,d0-d6/a0/a1
             rts       

;*****************************************************************************
; [ Display graphics buffer ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_buffer:        
             movem.l   d0-d7/a0-a3,-(sp)
             lea.l     Graphics_buf+1672,a0
             moveq.l   #16,d0               ; Calculate screen address
             moveq.l   #49,d1
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a1
             move.w    #143,d7              ; 9 x 16 - 1
             move.w    Scroll_Y,d0          ; Calculate buffer offset
             muls.w    #832,d0
             tst.w     Scroll_X             ; Normal or shifted ?
             bne.s     .Shifted
; ------------- Normal buffer display --------------------------------
             adda.w    d0,a0                ; Add buffer offset
.Loop_1:     movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             moveq.l   #10,d6
.Loop_2:     move.l    (a2)+,(a3)+          ; Copy
             move.l    (a2)+,(a3)+
             dbra      d6,.Loop_2           ; Next column
             lea.l     13*8(a0),a0          ; Next line
             lea.l     160(a1),a1
             dbra      d7,.Loop_1
             bra       .Exit
; ------------- Shifted buffer display -------------------------------
.Shifted:    bpl.s     .Skip                ; Adjust buffer offset
             subq.w    #8,d0
.Skip:       adda.w    d0,a0                ; Add buffer offset
.Loop_3:     movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             movep.l   1(a2),d0
             movep.l   d0,0(a3)
             addq.l    #8,a2
             moveq.l   #10-1,d6
.Loop_4:     movep.l   0(a2),d0
             movep.l   d0,1(a3)
             movep.l   1(a2),d0
             movep.l   d0,8(a3)
             addq.l    #8,a2
             addq.l    #8,a3
             dbra      d6,.Loop_4
             movep.l   0(a2),d0
             movep.l   d0,1(a3)
             lea.l     13*8(a0),a0          ; Next line
             lea.l     160(a1),a1
             dbra      d7,.Loop_3
.Exit:       movem.l   (sp)+,d0-d7/a0-a3
             rts       

;*****************************************************************************
; [ Get icon status (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : d0 - Underlay icon status (.l)
;        d1 - Overlay icon status (.l)
; Changed registers : d0,d1
;*****************************************************************************
Get_2D_icon_status:    
             movem.l   a0/a1,-(sp)
             movea.l   Iconstats_ptr,a0
             tst.b     Current_map_type     ; Wilderness ?
             bne       .Wild
             movea.l   Map_pointer,a1       ; Calculate map address
             subq.w    #1,d1
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             lea.l     -1(a1,d1.w),a1
             moveq.l   #0,d0                ; Get underlay icon number
             move.b    (a1),d0
             subq.w    #1,d0                ; Get underlay icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    0(a0,d0.w),d0
             adda.w    Size_of_map,a1       ; Go to overlay map
             moveq.l   #0,d1                ; Get overlay icon number
             move.b    (a1),d1
             beq.s     .Exit                ; Is there an overlay ?
             subq.w    #1,d1                ; Get overlay icon status
             add.w     d1,d1
             add.w     d1,d1
             move.l    0(a0,d1.w),d1
             bra.s     .Exit
.Wild:       lea.l     Underlay_buf+71,a1   ; Calculate map-buffer address
             sub.w     Map_Xcoord,d0
             sub.w     Map_Ycoord,d1
             mulu.w    #13,d1
             add.w     d0,d1
             adda.w    d1,a1
             moveq.l   #0,d0                ; Get underlay icon number
             move.b    (a1),d0
             subq.w    #1,d0                ; Get underlay icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    0(a0,d0.w),d0
             moveq.l   #0,d1                ; Get overlay icon number
             move.b    143(a1),d1
             beq.s     .Exit                ; Is there an overlay ?
             subq.w    #1,d1                ; Get overlay icon status
             add.w     d1,d1
             add.w     d1,d1
             move.l    0(a0,d1.w),d1
.Exit:       movem.l   (sp)+,a0/a1
             rts       

;*****************************************************************************
; [ Check if movement is possible (2D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
;*****************************************************************************
Movement_check_2D:     
             movem.l   d0-d3/a0,-(sp)
             cmpi.w    #6,Travel_mode       ; Is it a bird ?
             bne.s     .Normal              ; Is it a plane ?
             moveq.l   #0,d3
             bra.s     .Exit
.Normal:     moveq.l   #-1,d3               ; Zero flag off
             moveq.l   #0,d2
             tst.b     Current_map_type     ; Wilderness ?
             beq.s     .Skip
             move.w    Travel_mode,d2       ; Get travel mode
.Skip:       addq.w    #8,d2                ; Add 8
             sub.w     Map_Xcoord,d0        ; Calculate buffer coordinates
             sub.w     Map_Ycoord,d1
             add.w     Mapbuf_X,d0
             add.w     Mapbuf_Y,d1
             lea.l     Underlay_buf+14,a0   ; Calculate buffer pointer
             mulu.w    #13,d1
             add.w     d0,d1
             adda.w    d1,a0
             moveq.l   #0,d0                ; Get underlay icon number
             move.b    (a0),d0
             moveq.l   #0,d1                ; Get overlay icon number
             move.b    143(a0),d1
             movea.l   Iconstats_ptr,a0     ; Get underlay icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    -4(a0,d0.w),d0
             tst.w     d1                   ; Is there an overlay ?
             beq.s     .Underlay
             add.w     d1,d1                ; Get overlay icon status
             add.w     d1,d1
             move.l    -4(a0,d1.w),d1
             btst.l    #5,d1                ; Underlay priority ?
             bne.s     .Underlay
             btst.l    #7,d1                ; Overlay way blocked ?
             bne.s     .Exit
             btst.l    d2,d1                ; Way blocked for current
             seq       d3                   ; travel mode ?
             bra.s     .Exit
.Underlay:   btst.l    #7,d0                ; Underlay way blocked ?
             bne.s     .Exit
             btst.l    d2,d0                ; Way blocked for current
             seq       d3                   ; travel mode ?
.Exit:       tst.b     d3                   ; Get zero flag
             movem.l   (sp)+,d0-d3/a0
             rts       

;*****************************************************************************
; [ Handle night circle ]
; All registers are restored
;*****************************************************************************
Display_night_circle:  
             movem.l   d0-d7/a0/a1/a5,-(sp)
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             beq       .Exit                ; X-ray specs !!!
             lea.l     Graphics_buf,a5      ; Initialize registers
             move.w    #13*8,d5
             move.w    Current_radius,d1    ; Circle überhaupt ?
             bne.s     .Ok
             tst.w     New_radius
             beq       .Exit
.Ok:         cmp.w     New_radius,d1        ; Alter radius ?
             beq.s     .Continue
             bmi.s     .Up
             subq.w    #2,d1                ; Down
             move.w    d1,Current_radius
             bra.s     .Continue
.Up:         addq.w    #2,d1                ; Up
             cmpi.w    #Max_radius,d1       ; Check
             bhi       .Exit
             move.w    d1,Current_radius
.Continue:   move.w    Buffer_X,d6          ; Calculate centre coordinates
             move.w    Buffer_Y,d7
             addq.w    #1,d6
             addq.w    #1,d7
             lsl.w     #3,d6
             lsl.w     #3,d7
             moveq.l   #0,d2                ; Clear register
             movea.l   a5,a0                ; Clear top part
             move.w    d7,d0
             sub.w     d1,d0
             cmpi.w    #175,d0              ; Out of range ?
             bhi.s     .Clip_1
             bra.s     .Entry_1             ; Enter loop
.Loop_1:     moveq.l   #12,d3
.Loop_3a:    move.l    d2,(a0)+             ; Clear 8 bytes
             move.l    d2,(a0)+
             dbra      d3,.Loop_3a          ; Next column
.Entry_1:    dbra      d0,.Loop_1           ; Next line
.Clip_1:     lea.l     18304(a5),a0         ; Clear bottom part
             move.w    #176,d0
             sub.w     d1,d0
             sub.w     d7,d0
             cmpi.w    #175,d0              ; Out of range ?
             bhi.s     .Clip_2
             bra.s     .Entry_2             ; Enter loop
.Loop_2:     moveq.l   #12,d3
.Loop_3b:    move.l    d2,-(a0)             ; Clear 8 bytes
             move.l    d2,-(a0)
             dbra      d3,.Loop_3b          ; Next column
.Entry_2:    dbra      d0,.Loop_2           ; Next line
.Clip_2:     moveq.l   #0,d0                ; Initialize registers
             moveq.l   #0,d2
             move.w    d1,d3
             subq.w    #1,d3
             add.w     d3,d3
             move.w    d1,d4
.Again:      exg.l     d0,d1                ; Draw lines
             jsr       Draw_four_lines
             exg.l     d0,d1
             addq.w    #1,d0                ; x = x + 1
             add.w     d2,d4                ; xy2 = xy2 + dx
             addq.w    #2,d2                ; dx = dx + 2
             tst.w     d4                   ; xy2 >= 0 ?
             bmi.s     .Skip
             jsr       Draw_four_lines      ; Draw lines
             subq.w    #1,d1                ; y = y - 1
             sub.w     d3,d4                ; xy2 = xy2 - dy
             subq.w    #2,d3                ; dy = dy - 2
.Skip:       cmp.w     d1,d0                ; UNTIL x > y
             bls.s     .Again
.Exit:       movem.l   (sp)+,d0-d7/a0/a1/a5
             rts       

; [ Draw four horizontal lines ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Centre X-coordinate (.w)
;        d7 - Centre Y-coordinate (.w)
; All registers are restored
Draw_four_lines:       
             movem.l   d0-d4/d6,-(sp)
             move.w    d6,d2                ; Calculate coordinates
             add.w     d0,d2
             sub.w     d6,d0
             neg.w     d0
             add.w     d7,d1
             jsr       Draw_two_lines       ; Draw bottom
             sub.w     d7,d1
             neg.w     d1
             add.w     d7,d1
             jsr       Draw_two_lines       ; Draw top
             movem.l   (sp)+,d0-d4/d6
             rts       

; [ Draw two horizontal lines ]
;   IN : d0 - X-coordinate 1 (.w)
;        d1 - Y coordinate (.w)
;        d2 - X-coordinate 2 (.w)
;        d5 - 13 x 8 (.w)
; Changed registers : d3,d4,d6
Draw_two_lines:        
             cmpi.w    #175,d1              ; Clip
             bhi.s     .Exit
             moveq.l   #0,d6                ; Clear register
             movea.l   a5,a0                ; Calculate buffer addresses
             move.w    d1,d3
             mulu.w    d5,d3
             adda.w    d3,a0
             movea.l   a0,a1
             adda.w    d5,a1
             cmpi.w    #207,d0              ; Clip
             bhi.s     .Skip
             move.w    d0,d3                ; Left line
             lsr.w     #4,d3
             bra.s     .Entry_1
.Loop_1:     move.l    d6,(a0)+             ; Clear 8 bytes
             move.l    d6,(a0)+
.Entry_1:    dbra      d3,.Loop_1
             move.w    d0,d4
             andi.w    #$000f,d4
             move.l    #$0000ffff,d3
             ror.l     d4,d3
             .REPT 4
             and.w     d3,(a0)+
             .ENDR 
.Skip:       cmpi.w    #207,d2              ; Clip
             bhi.s     .Exit
             move.w    #207,d3              ; Right line
             sub.w     d2,d3
             lsr.w     #4,d3
             bra.s     .Entry_2
.Loop_2:     move.l    d6,-(a1)             ; Clear 8 bytes
             move.l    d6,-(a1)
.Entry_2:    dbra      d3,.Loop_2
             move.w    d2,d4
             andi.w    #$000f,d4
             move.l    #$ffff0000,d3
             ror.l     d4,d3
             .REPT 4
             and.w     d3,-(a1)
             .ENDR 
.Exit:       rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
Current_radius:        .DS.w 1              ; Circle parameters
New_radius:  .DS.w 1

Mapbuf_X:    .DS.w 1   ; Relative coordinates in map window
Mapbuf_Y:    .DS.w 1
Buffer_X:    .DS.w 1   ; Relative coordinates in graphic buffer
Buffer_Y:    .DS.w 1
Half_X:      .DS.w 1   ; Movement flags
Half_Y:      .DS.w 1
Scroll_X:    .DS.w 1
Scroll_Y:    .DS.w 1

Underlay_buf:          .DS.b 11*13          ; Temporary maps
Overlay_buf: .DS.b 11*13
Persons_buf: .DS.b 11*13
Trans_buf:   .DS.b 11*13
             .EVEN 

Graphics_buf:          .DS.l 2*16*11*13     ; Graphics buffer


             .SECTION 5,DATA
Icondata_filename:     
             .DC.b 2,'ICON_DAT.AMB',0
             .EVEN 

             .SECTION 6,BSS 
Icondata_ptr:          .DS.l 1

             .SECTION 7,DATA
; Layout 1 : 2D map, 2nd layer
Lay1_c1:     .DC.w 16,191,49,192            ; Map area
             .DC.b 2
             .EVEN 
             .DC.l Control_area,0           ; Link to control icons

             .SECTION 8,DATA
Hbl_2D_map:  .DC.w $ff00                    ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Below_pal_2D:          .DCB.w 16,0
             .DC.w 0

             .END 













