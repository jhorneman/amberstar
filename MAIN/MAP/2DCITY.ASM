
; 2D City map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 17-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "To know there's so many ways
;     The force of nature prevails
;      I lay down, I lay down and I pray"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :
;   -

C2_animspeed           = 4                  ; Number of frames between animation phases

             .TEXT 
;*****************************************************************************
; [ Initialize 2D city map ] TYPE 0
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
C2_ModInit:  
             Pop       MA
             move.l    a5,Mapd_ptr          ; Store pointer to map data
             jsr       M2_time_evaluate     ; Set light parameters
             move.w    New_radius,Current_radius
; ------------- Load data --------------------------------------------
             move.w    Iconfile_nr(a5),d0   ; Icon data
             lea.l     Icondata_filename,a0
             jsr       Load_subfile
             move.l    a0,Icondata_ptr
             jsr       Init_maptexts        ; Map texts
; ------------- Calculate variables ----------------------------------
             lea.l     Iconstats(a0),a0     ; Get & store pointer
             move.l    a0,Iconstats_ptr     ;  to icon status array
             moveq.l   #0,d0                ; Get & store map's width
             move.b    Map_width(a5),d0
             move.w    d0,Width_of_map
             moveq.l   #0,d1                ; Get & store map's height
             move.b    Map_height(a5),d1
             move.w    d1,Height_of_map
             mulu.w    d0,d1                ; Calculate & store map's size
             move.w    d1,Size_of_map
             lea.l     Map_data(a5),a0      ; Get & store pointer
             move.l    a0,Map_pointer       ;  to actual map data
             move.b    #C2_animspeed,Anim_speed   ; Set animation speed
             move.b    #C2_animspeed,Anim_count
             move.w    #6,Anim_bias
             jsr       Recalc_mapbuf_coords
             move.w    Map_nr,d7            ; Modify map
             movea.l   Mapd_ptr,a0
             jsr       Make_modifications
             .LOCAL 
             jsr       Init_persons         ; Initialize character handler
             jsr       C2_DisInit
             jsr       Event_handler        ; Handle first event
             rts       

; [ Recalculate map buffer coordinates ]
; All registers are restored
Recalc_mapbuf_coords:  
             movem.l   d0/d1,-(sp)
             move.w    #Def_mapbuf_X,Mapbuf_X     ; Set window coordinates
             move.w    #Def_mapbuf_Y,Mapbuf_Y
             move.w    Map_Xcoord,d0        ; Load party coordinates
             move.w    Map_Ycoord,d1
             cmpi.w    #12,d0               ; Left boundary check
             bpl.s     .Skip_1
             subi.w    #11,d0
             add.w     d0,Mapbuf_X
             bra.s     .Go_1
.Skip_1:     sub.w     Width_of_map,d0      ; Right boundary check
             cmpi.w    #-11,d0
             bmi.s     .Go_1
             addi.w    #10,d0
             add.w     d0,Mapbuf_X
.Go_1:       cmpi.w    #10,d1               ; Top boundary check
             bpl.s     .Skip_2
             subi.w    #10,d1
             add.w     d1,Mapbuf_Y
             bra.s     .Go_2
.Skip_2:     sub.w     Height_of_map,d1     ; Bottom boundary check
             cmpi.w    #-9,d1
             bmi.s     .Go_2
             addi.w    #9,d1
             add.w     d1,Mapbuf_Y
.Go_2:       movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Initialize 2D city map display ] TYPE 0
; All registers are restored
;*****************************************************************************
C2_DisInit:  
             movea.l   Mapd_ptr,a5          ; Get pointer to map data
             jsr       Set_spell_area
; ------------- Initialize display -----------------------------------
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #1,d0                ; Show 2D map layout
             jsr       Show_layout
             jsr       Print_headline
             move.l    #C2_CIL,First_CIL_ptr      ; Display control icons
             jsr       Handle_CIL
             jsr       Show_control_icons
             jsr       C2_DisUpd            ; Display 2D map
             Update_screen 
; ------------- Various installations --------------------------------
             sf        Time_lock
             lea.l     Lay1_c1,a0           ; Object branch
             jsr       Set_layout_data
             move.l    #C2_CIL+10,Mousemove_ptr   ; Mouse actions
; ------------- Fade-in display --------------------------------------
             movea.l   Icondata_ptr,a0      ; Convert IFF-palette
             lea.l     Icon_palette(a0),a0
             lea.l     Pal_buffer,a1
             jsr       IFF_pal_convert
             lea.l     Subfade1,a2          ; Fade in
.Again:      lea.l     Hbl_2D_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_2D,a0      ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_2D_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ Exit 2D city map ]
; All registers are restored
;*****************************************************************************
C2_ModExit:  
             jsr       Clear_persons_buffer
             movea.l   Mapd_ptr,a0          ; Free memory
             jsr       Free_memory
             movea.l   Icondata_ptr,a0
             jsr       Free_memory
             movea.l   Maptext_ptr,a0
             jsr       Free_memory
             jsr       Next_generation
             rts       

;*****************************************************************************
; [ Exit 2D city map display ]
; All registers are restored
;*****************************************************************************
C2_DisExit:  
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_2D_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_2D,a0      ; Fade palette
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_2D_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ 2D city - Move down/right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_downright:          
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move down/right
             addq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Downright
             jsr       C2_down              ; Try to move down or right
             beq       .Exit
             jsr       C2_right
             bra       .Exit
.Downright:  move.w    d0,Map_Xcoord        ; Update coordinates
             move.w    d1,Map_Ycoord
             jsr       Move_down_2D         ; Move down/right
             jsr       Move_right_2D
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move up/right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_upright:  
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move up/right
             subq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Upright
             jsr       C2_up                ; Try to move up or right
             beq.s     .Exit
             jsr       C2_right
             bra.s     .Exit
.Upright:    move.w    d0,Map_Xcoord        ; Update coordinates
             move.w    d1,Map_Ycoord
             jsr       Move_up_2D           ; Move up/right
             jsr       Move_right_2D
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move down/left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_downleft: 
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move down/left
             addq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Downleft
             jsr       C2_down              ; Try to move down or left
             beq       .Exit
             jsr       C2_left
             bra       .Exit
.Downleft:   move.w    d0,Map_Xcoord        ; Update coordinates
             move.w    d1,Map_Ycoord
             jsr       Move_down_2D         ; Move down/left
             jsr       Move_left_2D
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move up/left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_upleft:   
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move up/left
             subq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Upleft
             jsr       C2_up                ; Try to move up or left
             beq       .Exit
             jsr       C2_left
             bra       .Exit
.Upleft:     move.w    d0,Map_Xcoord        ; Update coordinates
             move.w    d1,Map_Ycoord
             jsr       Move_up_2D           ; Move up/left
             jsr       Move_left_2D
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move up ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_up:       
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d1                ; Try to move up
             jsr       Movement_check_2D
             sne       Bumped
             bne       .Exit
             move.w    d1,Map_Ycoord        ; Update coordinate
             jsr       Move_up_2D           ; Move up
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move down ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_down:     
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d1                ; Try to move down
             jsr       Movement_check_2D
             sne       Bumped
             bne       .Exit
             move.w    d1,Map_Ycoord        ; Update coordinate
             jsr       Move_down_2D         ; Move down
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_right:    
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #1,View_direction    ; View east
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move right
             jsr       Movement_check_2D
             sne       Bumped
             bne       .Exit
             move.w    d0,Map_Xcoord        ; Update coordinate
             jsr       Move_right_2D        ; Move right
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Move left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
C2_left:     
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #3,View_direction    ; View west
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move left
             jsr       Movement_check_2D
             sne       Bumped
             bne       .Exit
             move.w    d0,Map_Xcoord        ; Update coordinate
             jsr       Move_left_2D         ; Move left
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D city - Display map ]
; All registers are restored
;*****************************************************************************
C2_DisUpd:   
             movem.l   d0/d1/d6/d7/a0-a4,-(sp)
             movea.l   Map_pointer,a1       ; Calculate map address
             move.w    Map_Xcoord,d0
             sub.w     Mapbuf_X,d0
             subq.w    #2,d0
             adda.w    d0,a1
             move.w    Map_Ycoord,d0
             sub.w     Mapbuf_Y,d0
             subq.w    #2,d0
             move.w    Width_of_map,d1
             mulu.w    d1,d0
             adda.w    d0,a1
             subi.w    #13,d1               ; Get map width - 13
             movea.l   a1,a2                ; Copy maps to buffer
             adda.w    Size_of_map,a2
             lea.l     Underlay_buf,a3
             lea.l     Overlay_buf,a4
             moveq.l   #10,d7
.Loop_1:     moveq.l   #12,d6
.Loop_2:     move.b    (a1)+,(a3)+          ; Copy underlay & overlay
             move.b    (a2)+,(a4)+
             dbra      d6,.Loop_2
             adda.w    d1,a1
             adda.w    d1,a2
             dbra      d7,.Loop_1
             move.w    Map_Xcoord,d0        ; Get map coordinates
             move.w    Map_Ycoord,d1
             jsr       Get_2D_icon_status   ; Get icon status
             btst.l    #3,d1                ; Overlay icon change ?
             sne       Party_invisible
             beq.s     .Skip
             lea.l     Overlay_buf+14,a0    ; Change icon
             move.w    Mapbuf_Y,d0
             mulu.w    #13,d0
             add.w     Mapbuf_X,d0
             addq.b    #1,0(a0,d0.w)
.Skip:       jsr       TwoD_char_handler    ; Handle persons
             jsr       Build_2D_map         ; Build 2D map
             jsr       Update_map_CIL
             tst.b     CombatReq            ; Start combat ?
             beq.s     .Exit
             Push      Module,CombatReq_Mod
.Exit:       movem.l   (sp)+,d0/d1/d6/d7/a0-a4
             rts       

;*****************************************************************************
; [ Handle movement to the left (2D map) ]
; All registers are restored
;*****************************************************************************
Move_left_2D:          
             cmpi.w    #5,Mapbuf_X          ; In centre ?
             bne.s     .No_scroll
             cmpi.w    #11,Map_Xcoord       ; X-coordinate > 10 ?
             bmi.s     .No_scroll
             move.w    #-1,Scroll_X         ; Scroll left
             bra.s     .Exit
.No_scroll:  subq.w    #1,Mapbuf_X          ; Move left
.Exit:       move.w    #-1,Half_X
             rts       

;*****************************************************************************
; [ Handle movement to the right (2D map) ]
; All registers are restored
;*****************************************************************************
Move_right_2D:         
             move.l    d0,-(sp)
             cmpi.w    #5,Mapbuf_X          ; In centre ?
             bne.s     .No_scroll
             move.w    Width_of_map,d0      ; X-coordinate > map's
             subi.w    #9,d0                ; width - 8 ?
             cmp.w     Map_Xcoord,d0
             bls.s     .No_scroll
             move.w    #1,Scroll_X          ; Scroll right
             bra.s     .Exit
.No_scroll:  addq.w    #1,Mapbuf_X          ; Move right
.Exit:       move.w    #1,Half_X
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Handle movement up (2D map) ]
; All registers are restored
;*****************************************************************************
Move_up_2D:  
             cmpi.w    #4,Mapbuf_Y          ; In centre ?
             bne.s     .No_scroll
             cmpi.w    #10,Map_Ycoord       ; Y-coordinate > 9 ?
             bmi.s     .No_scroll
             move.w    #-1,Scroll_Y         ; Scroll up
             bra.s     .Exit
.No_scroll:  subq.w    #1,Mapbuf_Y          ; Move up
.Exit:       move.w    #-1,Half_Y
             rts       

;*****************************************************************************
; [ Handle movement down (2D map) ]
; All registers are restored
;*****************************************************************************
Move_down_2D:          
             move.l    d0,-(sp)
             cmpi.w    #4,Mapbuf_Y          ; In centre ?
             bne.s     .No_scroll
             move.w    Height_of_map,d0     ; Y-coordinate > map's
             subq.w    #8,d0                ; height - 7 ?
             cmp.w     Map_Ycoord,d0
             bls.s     .No_scroll
             move.w    #1,Scroll_Y          ; Scroll down
             bra.s     .Exit
.No_scroll:  addq.w    #1,Mapbuf_Y          ; Move down
.Exit:       move.w    #1,Half_Y
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
C2_CIL:      .DC.b 46,1,45,4,7,3,48,2,47    ; 2D city movement icons
             .EVEN 
             .DC.l C2_upleft,C2_up,C2_upright
             .DC.l C2_left,Zzz,C2_right
             .DC.l C2_downleft,C2_down,C2_downright

             .END 
















