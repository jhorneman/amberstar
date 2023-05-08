
; General map handling routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 26-3-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "Let us be together, let's pretend that we
;     Are free, let's all be where the angels
;      Find us, we all have the key"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :

             .PATH 'E:\MAIN\'
             .PATH 'E:\MAIN\MAP\'

             .TEXT 
;*****************************************************************************
; [ Initialize map ]
; All registers are restored
;*****************************************************************************
Init_map:    
             movem.l   d0/a0/a5,-(sp)
             st        Time_lock
             Push      MA,Load_area
             lea.l     Mapd_filename,a0     ; Load map
             move.w    Map_nr,d0
             jsr       Load_subfile
             movea.l   a0,a5                ; Protect map-data pointer
             move.b    Map_type(a5),d0      ; Get map type
             tst.b     d0                   ; 2D or 3D map ?
             beq.s     .2D
             move.b    Map_special(a5),d0   ; Get statusbits
             btst      #6,d0                ; City or dungeon ?
             bne.s     .3DCity
             moveq.l   #2,d0                ; 3D dungeon
             bra.s     .Cont
.3DCity:     moveq.l   #3,d0                ; 3D city
             bra.s     .Cont
.2D:         move.b    Map_special(a5),d0   ; Get statusbits
             btst      #5,d0                ; City or wilderness ?
             bne.s     .2DWild
             moveq.l   #0,d0                ; 2D city
             bra.s     .Cont
.2DWild:     moveq.l   #1,d0                ; 2D wilderness
.Cont:       move.b    d0,Current_map_type  ; Set map type
             tst.b     First                ; First time ?
             bne.s     .Skip
             jsr       Init_time
             st        First
.Skip:       lea.l     .Map_modules(pc),a0  ; Get pointer to module
             add.w     d0,d0
             add.w     d0,d0
             movea.l   0(a0,d0.w),a0
             jsr       Push_Module
.Exit:       movem.l   (sp)+,d0/a0/a5
             rts       

.Map_modules:          .DC.l C2map_Mod,W2map_Mod,D3map_Mod,C3map_Mod

;*****************************************************************************
; [ Exit map ]
; All registers are restored
;*****************************************************************************
Exit_map:    
             jsr       Exit_display
             Pop       Module
             rts       

;*****************************************************************************
; [ Change mouse pointer ] MOUSE EVENT
; All registers are restored
;*****************************************************************************
Change_mouse:          
             movem.l   d0-d2/a0,-(sp)
             move.w    Mouse_X,d0           ; Load mouse coordinates
             move.w    Mouse_Y,d1
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
; ------------- Calculate index for 2D map ---------------------------
             lea.l     .Mousetab2D,a0
             subi.w    #16,d0               ; Translate to (0,0)
             subi.w    #49,d1
             lsr.w     #4,d0                ; Divide by 16
             lsr.w     #4,d1
             sub.w     Mapbuf_X,d0          ; Calculate dX
             sub.w     Mapbuf_Y,d1          ; Calculate dY
             tst.w     d0                   ; Test dX
             beq.s     .Zero1
             bmi.s     .Neg1
             moveq.l   #2,d2                ; V = 2
             bra.s     .Test_Y
.Zero1:      moveq.l   #1,d2                ; V = 1
             bra.s     .Test_Y
.Neg1:       moveq.l   #0,d2                ; V = 0
.Test_Y:     tst.w     d1                   ; Test dY
             beq.s     .Zero2
             bmi.s     .Continue
             addq.w    #6,d2                ; V = V + (2 x 3)
             bra.s     .Continue
.Zero2:      addq.w    #3,d2                ; V = V + (1 x 3)
             bra.s     .Continue
; ------------- Calculate index for 3D map ---------------------------
.3D_map:     lea.l     .Mousetab3D,a0
             subi.w    #Topleft_X,d0        ; Translate to top-left
             subi.w    #Topleft_Y,d1        ;  corner of map window
             asr.w     #4,d0                ; Divide by 16
             asr.w     #4,d1
             move.b    .Div_3(pc,d0.w),d0   ; Divide by 3
             move.b    .Div_3(pc,d1.w),d2
             ext.w     d2
             add.w     d2,d0                ; Calculate index
             add.w     d2,d2
             add.w     d0,d2
; ------------- Set new mouse pointer --------------------------------
.Continue:   move.w    d2,Mouse_direction   ; Store number
             moveq.l   #0,d0                ; Get number of new pointer
             move.b    0(a0,d2.w),d0
             jsr       Change_Mptr          ; Set new mouse pointer
             movem.l   (sp)+,d0-d2/a0
             rts       

.Div_3:      .DC.b 0,0,0,1,1,1,2,2,2
.Mousetab2D: .DC.b 5,1,6                    ; Mouse pointer matrix (2D)
             .DC.b 4,16,3
             .DC.b 8,2,7
.Mousetab3D: .DC.b 14,9,13                  ; Mouse pointer matrix (3D)
             .DC.b 12,16,11
             .DC.b 23,10,20
             .EVEN 

;*****************************************************************************
; [ Reset mouse pointer when not in map area ] SCREEN QUEUE
; Changed registers : d0,d1,d2
;*****************************************************************************
Reset_mouse: 
             move.w    Mouse_X,d0           ; Get mouse coordinates
             move.w    Mouse_Y,d1
             jsr       Find_object          ; Find object
             andi.l    #$00ffff00,d2        ; Map area ?
             cmpi.l    #$00020200,d2
             beq.s     .Exit
             moveq.l   #0,d0                ; Default pointer
             jsr       Change_Mptr
.Exit:       rts       

;*****************************************************************************
; [ Update animation ]
; All registers are restored
;*****************************************************************************
Update_animation:      
             subq.b    #1,Anim_count        ; Time for update ?
             bne       No_animation
             movem.l   d0-d2/d6/d7/a0/a1,-(sp)
             moveq.l   #$f,d1
             lea.l     Circle_anim+4,a0     ; Update circle animations
             moveq.l   #2,d7
.Loop1:      move.b    (a0),d0              ; Increase frame
             addq.b    #1,d0
             cmp.b     d0,d7                ; Last frame ?
             bne.s     .Skip
             jsr       Recalc_random
             moveq.l   #0,d0                ; Reset frame
.Skip:       move.b    d0,(a0)              ; Store frame
             addq.l    #4,a0                ; Next animation length
             addq.w    #1,d7
             cmpi.w    #8+1,d7
             bmi.s     .Loop1
             .LOCAL 
             lea.l     Wave_anim+8,a0       ; Update wave animation
             lea.l     Wave_anim+32,a1
             moveq.l   #3,d7
.Loop:       move.b    (a0),d0
             tst.b     (a1)+                ; Up or down ?
             bne.s     .Down
             addq.b    #1,d0                ; Increase
             cmp.b     d0,d7                ; Last frame ?
             bne.s     .Skip
             subq.b    #2,d0                ; Reverse direction
             not.b     -1(a1)
             bra.s     .Skip
.Down:       subq.b    #1,d0                ; Decrease
             bne.s     .Skip
             not.b     -1(a1)               ; Reverse direction
             jsr       Recalc_random
.Skip:       move.b    d0,(a0)              ; Store frame
             addq.l    #4,a0                ; Next animation length
             addq.w    #1,d7
             cmpi.w    #8+1,d7
             bmi.s     .Loop
             move.b    Anim_speed,Anim_count      ; Reset counter
             movem.l   (sp)+,d0-d2/d6/d7/a0/a1
No_animation:          rts                  

; [ Re-calculate random animation factors ]
;   IN : d1 - $0000000f (.l)
;        a0 - Pointer to animation table (.l)
; Changed registers : d2,d6
Recalc_random:         
             move.l    d0,-(sp)
             moveq.l   #0,d2                ; Re-calculate random
             move.w    Anim_bias,d6
             subq.w    #1,d6
.Loop:       jsr       Random
             lsr.w     #1,d0
             and.w     d1,d0
             bset      d0,d2
             dbra      d6,.Loop
             move.w    d2,2(a0)             ; Store
             jsr       Random               ; Re-calculate offset
             lsr.w     #1,d0
             move.b    d0,1(a0)
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Before- and after-movement routines ]
; All registers are restored
;*****************************************************************************
Before_move: movem.l   d0/a0,-(sp)
             movea.l   Current_active_char_data,a0          ; Can one move ?
             move.w    Body_conditions(a0),d0     ; i.e. not paralyzed ?
             btst      #0,d0
             beq.s     .Ok
             movem.l   (sp)+,d0/a0
             addq.l    #4,sp                ; OBSCENE STACK TRICK !!!
             rts       
.Ok:         move.w    Map_Xcoord,Old_Xcoord      ; Save old coordinates
             move.w    Map_Ycoord,Old_Ycoord
             move.w    Mapbuf_X,Old_mapbufX
             move.w    Mapbuf_Y,Old_mapbufY
             movem.l   (sp)+,d0/a0
             rts       

After_move:  movem.l   d0/d1/d7/a0/a1,-(sp)
             st        New_move             ; Signal new move
             move.w    #0,Frame             ; Clear Vbl-counter
             subq.w    #1,Move_count        ; Next step ?
             bne.s     .Skip
             move.w    Move_speed,Move_count      ; Reset counter
             jsr       Update_time          ; Next step
; ------------- Check for poison field -------------------------------
.Skip:       cmpi.w    #4,Travel_mode       ; Foot, horse or disc ?
             beq.s     .Try
             cmpi.w    #2,Travel_mode
             bpl       .No_poison
.Try:        move.w    Map_Xcoord,d0        ; Get coordinates
             move.w    Map_Ycoord,d1
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             jsr       Get_2D_icon_status
             tst.l     d1                   ; Any overlay ?
             beq.s     .Underlay
             btst      #5,d1                ; Underlay priority ?
             bne.s     .Underlay
             btst      #31,d1               ; Poison ?
             beq       .No_poison
             bra.s     .Poison
.Underlay:   btst      #31,d0               ; Poison ?
             beq       .No_poison
             bra.s     .Poison
.3D_map:     jsr       Get_3D_icon_status
             btst      #31,d0               ; Poison ?
             beq       .No_poison
; ------------- Poison party -----------------------------------------
.Poison:     lea.l     Chard_ptrs,a0
             moveq.l   #0,d1
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d0            ; Alive and kicking ?
             and.w     Body_conditions(a1),d0
             bne.s     .Next
             move.w    Attr_7_normal(a1),d0 ; Probe luck
             add.w     Attr_7_normal_magic(a1),d0
             jsr       Probe
             bpl.s     .Next
             bset      #1,Body_conditions(a1)     ; Poisoned!
             move.w    d7,d0                ; Show empty damage star
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
.No_poison:  .LOCAL 
; ------------- Check for swimming field -----------------------------
             tst.w     Travel_mode          ; On foot ?
             bne       .No_swim
             cmpi.b    #2,Current_map_type  ; 2D map ?
             bpl.s     .No_swim
             move.w    Map_Xcoord,d0        ; Get coordinates
             move.w    Map_Ycoord,d1
             jsr       Get_2D_icon_status
             tst.l     d1                   ; Any overlay ?
             beq.s     .Underlay
             btst      #5,d1                ; Underlay priority ?
             bne.s     .Underlay
             btst      #14,d1               ; Swim ?
             beq.s     .No_swim
             bra.s     .Swim
.Underlay:   btst      #14,d0               ; Swim ?
             beq.s     .No_swim
; ------------- Let the party swim -----------------------------------
.Swim:       lea.l     Chard_ptrs,a0
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d0            ; Alive and kicking ?
             and.w     Body_conditions(a1),d0
             bne.s     .Next
             moveq.l   #0,d0                ; Probe swimming
             move.b    Skill_3(a1),d0
             add.w     Skill_3_normal_magic(a1),d0
             jsr       Probe
             bpl.s     .Next
             jsr       Random               ; Do damage !
             move.w    d0,d1
             mulu.w    #5,d1
             swap.w    d1
             addq.w    #1,d1
             move.w    d7,d0
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
.No_swim:    .LOCAL 
             jsr       Event_handler
; ------------- World map movement delay -----------------------------
             cmpi.b    #1,Current_map_type  ; Wilderniss ?
             bne.s     .No_delay
             move.w    Travel_mode,d0       ; Get delay
             add.w     d0,d0
             move.w    .Move_delay(pc,d0.w),d0
             beq.s     .No_delay
             jsr       Delay                ; Delay
; ------------- Clearvoyance -----------------------------------------
.No_delay:   

; Check in front
; Call EYE


             movem.l   (sp)+,d0/d1/d7/a0/a1
             rts       

.Move_delay: .DC.w 5,2,3,2,4,0,0            ; Number of VBL's pro step

;*****************************************************************************
; [ Move according to mouse pointer for 3D map ] MOUSE EVENT
; No registers are restored (nor need they be)
;*****************************************************************************
Move_mouse:  
             tst.b     Overweight           ; Possible ?
             bne.s     .Exit
             move.w    Mouse_direction,d0   ; Get routine address
             add.w     d0,d0
             add.w     d0,d0
             movea.l   Mousemove_ptr,a0
             movea.l   0(a0,d0.w),a0
             jsr       (a0)                 ; Execute
.Exit:       rts       

;*****************************************************************************
; [ Print map headline ]
;   IN : a5 - Pointer to map data (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Print_headline:        
             movem.l   d0/d1/d7/a0,-(sp)
             lea.l     Map_headline(a5),a0  ; Search headline for first
             moveq.l   #30-1,d7             ;  non-space
.Loop:       cmpi.b    #" ",0(a0,d7.w)
             dbne      d7,.Loop
             addq.w    #1,d7                ; Calculate X-coordinate
             move.w    d7,d0                ;  for a centred cursor
             add.w     d0,d0
             add.w     d7,d0
             add.w     d0,d0
             subi.w    #180,d0
             neg.w     d0
             lsr.w     #1,d0
             addi.w    #13,d0
             moveq.l   #39,d1               ; Set cursor
             jsr       IG_Set_cursor
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink
             moveq.l   #-1,d0               ; Set paper (transparent)
             jsr       IG_Set_paper
             jsr       IG_Print             ; Print string
             movem.l   (sp)+,d0/d1/d7/a0
             rts       

;*****************************************************************************
; Control icon switch routines
;*****************************************************************************
Handle_CIL:  
             tst.b     Which_CIL            ; Which control icon list ?
             beq.s     .First
             lea.l     Second_CIL,a0        ; Evaluate icons
             jsr       Second_CIL_evaluate
             move.l    a0,Control_list_ptr
             bra.s     .Exit
.First:      movea.l   First_CIL_ptr,a0
             jsr       Map_CIL_evaluate
             move.l    a0,Control_list_ptr
.Exit:       rts       

Switch_control_icons:  
             not.b     Which_CIL            ; Switch
             jsr       Handle_CIL
             jsr       Copy_screen          ; Display
             jsr       Switch_screen
             movea.l   Off_screen,a6
             jsr       Show_control_icons
             Update_screen 
Dummy:       rts       

;*****************************************************************************
; [ Re-evaluate map control icons ]
;   IN : a0 - Pointer to CIL (.l)
; All registers are restored
;*****************************************************************************
Map_CIL_evaluate:      
             bclr      #7,(a0)              ; Enable all icons
             bclr      #7,1(a0)
             bclr      #7,2(a0)
             bclr      #7,3(a0)
             bclr      #7,5(a0)
             bclr      #7,6(a0)
             bclr      #7,7(a0)
             bclr      #7,8(a0)
             tst.b     Overweight           ; Anyone overweight ?
             beq.s     .Exit
             bset      #7,(a0)              ; Disable all icons
             bset      #7,1(a0)
             bset      #7,2(a0)
             bset      #7,3(a0)
             bset      #7,5(a0)
             bset      #7,6(a0)
             bset      #7,7(a0)
             bset      #7,8(a0)
.Exit:       rts       

;*****************************************************************************
; [ Re-evaluate second control icon list ]
;   IN : a0 - Pointer to CIL (.l)
; All registers are restored
;*****************************************************************************
Second_CIL_evaluate:   
             movem.l   d0/d1/a1,-(sp)
             bclr      #7,(a0)              ; Enable all icons
             bclr      #7,3(a0)
             bclr      #7,4(a0)
             bclr      #7,5(a0)
             bclr      #7,6(a0)
             movea.l   Current_active_char_data,a1
; ------------- Active character blind ? -----------------------------
             btst      #4,Mind_conditions(a1)     ; Well ?
             beq.s     .Not_blind
             bset      #7,(a0)              ; Disable {Eye}
; ------------- Can the party change travelmode ? --------------------
.Not_blind:  cmpi.b    #1,Current_map_type  ; 2D wilderness ?
             bne.s     .Deac
             tst.w     Travel_mode          ; On foot or not ?
             beq.s     .Get_up
             move.w    Map_Xcoord,d0        ; Get icon status
             move.w    Map_Ycoord,d1
             jsr       Get_2D_icon_status
             tst.l     d1                   ; Any overlay ?
             beq.s     .Underlay1
             btst.l    #5,d1                ; Underlay priority ?
             bne.s     .Underlay1
             btst.l    #7,d1                ; Overlay way blocked ?
             bne.s     .Deac
             btst.l    #8,d1                ; Way blocked for foot ?
             beq.s     .Deac
             bra.s     .Go_on
.Underlay1:  btst.l    #7,d0                ; Underlay way blocked ?
             bne.s     .Deac
             btst.l    #8,d0                ; Way blocked for foot ?
             beq.s     .Deac
.Go_on:      jsr       Seek_transport       ; Something already there ?
             tst.w     d0
             bne.s     .Deac
             bra.s     .Ok
.Get_up:     jsr       Seek_transport       ; Anything here ?
             tst.w     d0
             bne.s     .Ok
.Deac:       bset      #7,3(a0)             ; Disable {Change travelmode}
; ------------- Active character magical ? ---------------------------
.Ok:         tst.b     Spell_class_counter(a1)    ; Any spell classes ?
             bne.s     .Magic
             bset      #7,4(a0)             ; Disable {Use magic}
; ------------- Can the party camp here ? ----------------------------
.Magic:      movea.l   Mapd_ptr,a1          ; Well ?
             btst      #4,Map_special(a1)
             beq       .No_camp
             tst.w     Travel_mode          ; On foot ?
             bne       .Camp
             cmpi.b    #2,Current_map_type  ; 2D map ?
             bpl       .Camp
             move.w    Map_Xcoord,d0        ; Get coordinates
             move.w    Map_Ycoord,d1
             jsr       Get_2D_icon_status
             tst.l     d1                   ; Any overlay ?
             beq.s     .Underlay2
             btst      #5,d1                ; Underlay priority ?
             bne.s     .Underlay2
             btst      #14,d1               ; Swim ?
             beq.s     .Camp
             bra.s     .No_camp
.Underlay2:  btst      #14,d0               ; Swim ?
             beq.s     .Camp
.No_camp:    bset      #7,5(a0)             ; Disable {Camp}
; ------------- Can the party use the auto-mapper ? ------------------
.Camp:       cmpi.b    #2,Current_map_type  ; 3D map ?
             bpl.s     .Exit
             bset      #7,6(a0)             ; Disable {Automapper}
.Exit:       movem.l   (sp)+,d0/d1/a1
             rts       

;*****************************************************************************
; [ Seek transport on current position ]
;  OUT : d0 - Travel mode number / 0 (.w)
;        d1 - Index (.w)
; Changed registers : d0,d1
;*****************************************************************************
Seek_transport:        
             movem.l   d2/d3/d7/a0/a1,-(sp)
             lea.l     Trans_T,a0           ; Initialize registers
             lea.l     90(a0),a1
             move.w    Map_Xcoord,d0
             move.w    Map_Ycoord,d1
             move.w    Map_nr,d2
             moveq.l   #0,d3
             moveq.l   #30-1,d7
.Loop:       tst.b     (a0)                 ; Any there ?
             beq.s     .Next
             cmp.w     (a1),d2              ; Same map ?
             bne.s     .Next
             cmp.b     30(a0),d0            ; Same position ?
             bne.s     .Next
             cmp.b     60(a0),d1
             bne.s     .Next
             moveq.l   #0,d0                ; Get travel mode
             move.b    (a0),d0
             move.w    d3,d1
             bra.s     .Exit
.Next:       addq.w    #1,d3                ; Next
             addq.l    #1,a0
             addq.l    #2,a1
             dbra      d7,.Loop
             moveq.l   #0,d0                ; No success
.Exit:       movem.l   (sp)+,d2/d3/d7/a0/a1
             rts       

;*****************************************************************************
Update_map_CIL:        
             movem.l   a0/a1,-(sp)
             tst.b     Which_CIL            ; Second CIL ?
             bne.s     .Second
             movea.l   First_CIL_ptr,a0     ; Update control icons
             lea.l     Map_CIL_evaluate,a1
             jsr       Update_control_icons
             bra       .Exit
.Second:     lea.l     Second_CIL,a0        ; Update control icons
             lea.l     Second_CIL_evaluate,a1
             jsr       Update_control_icons
.Exit:       movem.l   (sp)+,a0/a1
             rts       

;*****************************************************************************
; [ Set spell area ]
; All registers are restored
;*****************************************************************************
Set_spell_area:        
             movem.l   d0/a0,-(sp)
             movea.l   Mapd_ptr,a0
             move.b    Map_special(a0),d0
             btst      #5,d0                ; Wilderniss ?
             beq.s     .No_W
             moveq.l   #0,d0
             bra       .Exit
.No_W:       btst      #6,d0                ; City ?
             beq.s     .No_C
             moveq.l   #1,d0
             bra       .Exit
.No_C:       moveq.l   #2,d0                ; Dungeon
.Exit:       move.w    d0,Spell_area_type
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; Included files
;*****************************************************************************

             .INCLUDE '2DMAP.IS'
             .INCLUDE '3DMAP.IS'
             .INCLUDE '2DWILD.IS'
             .INCLUDE '2DCITY.IS'
             .INCLUDE '3DDUNGEO.IS'
             .INCLUDE '3DCITY.IS'
             .INCLUDE 'SHADOW.IS'
             .INCLUDE 'PERSONS.IS'

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Old_Xcoord:  .DC.w 7   ; Old coordinates
Old_Ycoord:  .DC.w 7
Old_mapbufX: .DC.w 1
Old_mapbufY: .DC.w 1
Second_CIL:  .DC.b 11,10,17
             .DC.b 21,12,19
             .DC.b 57,38,60
             .EVEN 
             .DC.l Eye_spy,Ear_action,Mouth_action
             .DC.l Change_travelmode,Cast_spell,Camp
             .DC.l Automapper,Dummy,Options_menu


             .BSS 
Stygian:     .DS.b 1   ; Indicates total darkness
Bumped:      .DS.b 1   ; Indicates collision with large inanimate object
New_move:    .DS.b 1   ; Signals a new move
Anim_count:  .DS.b 1   ; Animation counter
Anim_speed:  .DS.b 1   ; Animation speed
; 0 = 2D city
; 1 = 2D wilderness
; 2 = 3D dungeon
; 3 = 3D city
Current_map_type:      .DS.b 1
Which_CIL:   .DS.b 1
             .EVEN 
Move_count:  .DS.w 1   ; Counts number of moves till next step
Move_speed:  .DS.w 1

Mouse_direction:       .DS.w 1              ; Current direction of mouse
Mousemove_ptr:         .DS.l 1              ; Pointer to list
First_CIL_ptr:         .DS.l 1              ; Pointer to first CIL

Pal_buffer:  .DS.w 16  ; Palette buffer
Party_invisible:       .DS.b 1
             .EVEN 

Width_of_map:          .DS.w 1              ; Current map's width
Height_of_map:         .DS.w 1              ; Current map's height
Size_of_map: .DS.w 1   ; Current map's size

Map_pointer: .DS.l 1   ; Pointer to current map data
Iconstats_ptr:         .DS.l 1              ; Pointer to current icon status array

Anim_bias:   .DS.w 1
Circle_anim: .DS.l 8   ; Animation tables
Wave_anim:   .DS.l 8
             .DS.b 8
             .EVEN 

             .SECTION 5,DATA
Mapd_filename:         .DC.b 4,'MAP_DATA.AMB',0
             .EVEN 

             .SECTION 6,BSS 
Mapd_ptr:    .DS.l 1   ; Pointer to MAP_DAT.nnn

             .END 








