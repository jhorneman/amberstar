
; 2D Wilderness map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 17-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "It's something that I feel
;     To pour upon my soul
;      Countenance of love
;       For one n'all"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :
;   -

World_width  = 8       ; Dimensions of world map
World_height           = 8                  ;  (measured in sub-maps)
Submap_width           = 50                 ; Dimensions of sub-map
Submap_height          = 50
Trigger      = 7       ; Distance from quad-map's edges which will trigger a re-load.
W2_animspeed           = 2                  ; Number of frames between animation phases

             .TEXT 
;*****************************************************************************
; [ Initialize 2D wilderness map ] TYPE 1
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
W2_ModInit:  
             Pop       MA
             move.l    a5,Mapd_ptr          ; Store pointer to map data
             jsr       M2_time_evaluate     ; Set light parameters
             move.w    New_radius,Current_radius
; ------------- Load data --------------------------------------------
             move.w    Iconfile_nr(a5),d0   ; Icon data
             lea.l     Icondata_filename,a0
             jsr       Load_subfile
             move.l    a0,Icondata_ptr
             jsr       Init_maptexts
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
             move.b    #W2_animspeed,Anim_speed   ; Set animation speed
             move.b    #W2_animspeed,Anim_count
             move.w    #6,Anim_bias
             move.w    #Def_mapbuf_X,Mapbuf_X     ; Set window coordinates
             move.w    #Def_mapbuf_Y,Mapbuf_Y
             move.w    Map_nr,d7            ; Modify map
             movea.l   Mapd_ptr,a0
             jsr       Make_modifications
; ------------- Wilderness initialization ----------------------------
             moveq.l   #0,d2                ; Get current map number
             move.w    Map_nr,d2
             subq.l    #1,d2                ; Subtract number of first map
             divu.w    #World_width,d2      ; Calculate world coordinates
             move.w    d2,World_Y           ; Store
             swap.w    d2
             move.w    d2,World_X
             move.w    Map_Xcoord,d0        ; Load party coordinates
             move.w    Map_Ycoord,d1
             moveq.l   #0,d2                ; Calculate quad-index
             cmpi.w    #Submap_width/2+1,d0 ; & quad-coordinates
             bpl.s     .Skip_X
             addi.w    #Submap_width,d0
             bset      #0,d2
.Skip_X:     cmpi.w    #Submap_height/2+1,d1
             bpl.s     .Skip_Y
             addi.w    #Submap_height,d1
             bset      #1,d2
.Skip_Y:     move.w    d0,Quad_X            ; Store
             move.w    d1,Quad_Y
             move.w    d2,Quad_index
             move.w    World_X,d0           ; Initialize registers
             move.w    World_Y,d1
             lea.l     Quad_map,a1
             lea.l     Load_table,a2
             add.w     d2,d2                ; Set map & text pointer
             add.w     d2,d2
             move.l    a5,0(a1,d2.w)
             move.l    Maptext_ptr,16(a1,d2.w)
             move.w    Map_nr,34(a1,d2.w)
             move.l    -16(a2,d2.w),d2      ; Get altered quad-index
             movea.l   0(a2,d2.w),a0        ; Execute routine
             jsr       (a0)
             addq.w    #4,d2                ; Next routine
             andi.w    #$000f,d2
             movea.l   0(a2,d2.w),a0        ; Execute routine
             jsr       (a0)
             addq.w    #4,d2                ; Next routine
             andi.w    #$000f,d2
             movea.l   0(a2,d2.w),a0        ; Execute routine
             jsr       (a0)
             .LOCAL 
             jsr       W2_DisInit
             jsr       Event_handler        ; Handle first event
             rts       

             .DC.l 4,8,0,12
Load_table:  .DC.l Load_0,Load_1,Load_3,Load_2

; [ Map load routines ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;        a1 - Pointer to quad-map (.l)
; Changed registers : d0,d1,a0

Load_0:      movem.l   d2/d7/a2,-(sp)
             subq.w    #1,d1                ; Next in chain
             jsr       Load_submap          ; Load map 0
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             move.w    d2,d7                ; Make modifications
             jsr       Make_modifications
             movem.l   (sp)+,d2/d7/a2
             rts       

Load_1:      movem.l   d2/d7/a2,-(sp)
             addq.w    #1,d0                ; Next in chain
             jsr       Load_submap          ; Load map 1
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             move.w    d2,d7                ; Make modifications
             jsr       Make_modifications
             movem.l   (sp)+,d2/d7/a2
             rts       

Load_3:      movem.l   d2/d7/a2,-(sp)
             addq.w    #1,d1                ; Next in chain
             jsr       Load_submap          ; Load map 3
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             move.w    d2,d7                ; Make modifications
             jsr       Make_modifications
             movem.l   (sp)+,d2/d7/a2
             rts       

Load_2:      movem.l   d2/d7/a2,-(sp)
             subq.w    #1,d0                ; Next in chain
             jsr       Load_submap          ; Load map 2
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             move.w    d2,d7                ; Make modifications
             jsr       Make_modifications
             movem.l   (sp)+,d2/d7/a2
             rts       

;*****************************************************************************
; [ Initialize 2D wilderness map display ] TYPE 1
; All registers are restored
;*****************************************************************************
W2_DisInit:  
             movea.l   Mapd_ptr,a5          ; Get pointer to map dta
             jsr       Set_spell_area
; ------------- Initialize display -----------------------------------
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #1,d0                ; Show 2D map layout
             jsr       Show_layout
             jsr       Print_headline
             move.l    #W2_CIL,First_CIL_ptr      ; Display control icons
             jsr       Handle_CIL
             jsr       Show_control_icons
             jsr       W2_DisUpd            ; Display 2D map
             Update_screen 
; ------------- Various installations --------------------------------
             sf        Time_lock
             lea.l     Lay1_c1,a0           ; Object branch
             jsr       Set_layout_data
             move.l    #W2_CIL+10,Mousemove_ptr   ; Mouse actions
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
; [ Exit 2D wilderness map ]
; All registers are restored
;*****************************************************************************
W2_ModExit:  
             lea.l     Trans_buf,a0         ; Clear transport buffer
             moveq.l   #0,d0
             move.b    d0,(a0)+
             move.w    d0,(a0)+
             moveq.l   #35-1,d7
.Loop:       move.l    d0,(a0)+
             dbra      d7,.Loop
             .LOCAL 
             lea.l     Quad_map,a1          ; Free memory
             moveq.l   #8-1,d7
.Loop:       movea.l   (a1)+,a0
             jsr       Free_memory
             dbra      d7,.Loop
             movea.l   Icondata_ptr,a0
             jsr       Free_memory
             jsr       Next_generation
             rts       

;*****************************************************************************
; [ Exit 2D wilderness map display ]
; All registers are restored
;*****************************************************************************
W2_DisExit:  
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
; [ Re-evaluate quad-map ]
; All registers are restored
;*****************************************************************************
Quad_evaluate:         
             movem.l   d0-d4/a0/a1,-(sp)    ; Save registers
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             move.w    World_X,d2           ; Get world coordinates
             move.w    World_Y,d3
             move.w    Quad_index,d4        ; Get quad-index
             cmpi.w    #1,d0                ; X < 1 ?
             bpl.s     .Skip_1
             addi.w    #Submap_width,d0     ; X = X + {width}
             bclr      #0,d4                ; Clear bit 0 of quad-index
             subq.w    #1,d2                ; DEC World_X
             bpl.s     .Check_Y             ; Wrap World_X
             move.w    #World_width-1,d2
             bra.s     .Check_Y
.Skip_1:     cmpi.w    #Submap_width+1,d0   ; X >= {width} ?
             bmi.s     .Check_Y
             subi.w    #Submap_width,d0     ; X = X - {width}
             bset      #0,d4                ; Set bit 0 of quad-index
             addq.w    #1,d2                ; INC World_X
             cmpi.w    #World_width,d2      ; Wrap World_X
             bmi.s     .Check_Y
             moveq.l   #0,d2
.Check_Y:    cmpi.w    #1,d1                ; Y < 1 ?
             bpl.s     .Skip_2
             addi.w    #Submap_height,d1    ; Y = Y + {height}
             bclr      #1,d4                ; Clear bit 1 of quad-index
             subq.w    #1,d3                ; DEC World_Y
             bpl.s     .Cont                ; Wrap World_Y
             move.w    #World_height-1,d3
             bra.s     .Cont
.Skip_2:     cmpi.w    #Submap_height+1,d1  ; Y >= {height} ?
             bmi.s     .Cont
             subi.w    #Submap_height,d1    ; Y = Y - {height}
             bset      #1,d4                ; Set bit 1 of quad-index
             addq.w    #1,d3                ; INC World_Y
             cmpi.w    #World_height,d3     ; Wrap World_Y
             bmi.s     .Cont
             moveq.l   #0,d3
.Cont:       move.w    d0,Map_Xcoord        ; Store
             move.w    d1,Map_Ycoord
             move.w    d2,World_X
             move.w    d3,World_Y
             move.w    d4,Quad_index
             mulu.w    #World_width,d3      ; Calculate new map number
             add.w     d2,d3
             addq.w    #1,d3                ; Add number of first map
             move.w    d3,Map_nr            ; Store
             .LOCAL 
             move.w    Quad_X,d0            ; Get quad coordinates
             move.w    Quad_Y,d1
             moveq.l   #0,d3                ; Calculate shift index
             cmpi.w    #Trigger+1,d0
             bmi.s     .Check_Y
             cmpi.w    #101-Trigger,d0      ; !!!!!
             bmi.s     .Mid_X
             addq.w    #8,d3
             bra.s     .Check_Y
.Mid_X:      addq.w    #4,d3
.Check_Y:    cmpi.w    #Trigger+1,d1
             bmi.s     .Cont
             cmpi.w    #101-Trigger,d1      ; !!!!!
             bmi.s     .Mid_Y
             addi.w    #24,d3
             bra.s     .Cont
.Mid_Y:      addi.w    #12,d3
.Cont:       .LOCAL 
             move.w    World_X,d0           ; Initialize registers
             move.w    World_Y,d1
             move.w    Quad_index,d2
             lea.l     Quad_map,a1
             lea.l     Shift_tab,a0         ; Get routine address
             move.l    0(a0,d3.w),d3
             beq.s     .Skip
             movea.l   d3,a0                ; Execute shift routine
             jsr       (a0)
             move.w    d2,Quad_index        ; Store new quad-index
.Skip:       lea.l     Quad_map,a1          ; Set new map pointer
             move.w    Quad_index,d2        ; & text pointer
             add.w     d2,d2
             add.w     d2,d2
             movea.l   0(a1,d2.w),a0
             move.l    a0,Mapd_ptr
             lea.l     Map_data(a0),a0
             move.l    a0,Map_pointer
             move.l    16(a1,d2.w),Maptext_ptr
             movem.l   (sp)+,d0-d4/a0/a1    ; Restore registers
             rts                            ; Return

Shift_tab:   .DC.l Shift_UL,Shift_U,Shift_UR
             .DC.l Shift_L,0,Shift_R
             .DC.l Shift_DL,Shift_D,Shift_DR

; [ Quad-map shift routines ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;        a1 - Pointer to quad-map (.l)
;  OUT : d2 - New quad-index (.w)
; Changed registers : d0,d1,d2,a0,a2

Shift_UL:    movea.l   4(a1),a0             ; Free memory
             jsr       Free_memory
             movea.l   8(a1),a0
             jsr       Free_memory
             movea.l   12(a1),a0
             jsr       Free_memory
             movea.l   16+4(a1),a0          ; Free memory
             jsr       Free_memory
             movea.l   16+8(a1),a0
             jsr       Free_memory
             movea.l   16+12(a1),a0
             jsr       Free_memory
             move.l    (a1),12(a1)          ; Shift quad-map
             move.l    16(a1),16+12(a1)
             move.w    34(a1),34+12(a1)
             subq.w    #1,d0                ; Load new maps
             jsr       Load_submap
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             subq.w    #1,d1
             jsr       Load_submap
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             addq.w    #1,d0
             jsr       Load_submap
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             addi.w    #Submap_width,Quad_X ; Update quad coordinates
             addi.w    #Submap_height,Quad_Y
             move.w    #3,d2                ; Adjust quad-index
             rts       

Shift_U:     move.l    d2,-(sp)
             movea.l   8(a1),a0             ; Free memory
             jsr       Free_memory
             movea.l   12(a1),a0
             jsr       Free_memory
             movea.l   16+8(a1),a0
             jsr       Free_memory
             movea.l   16+12(a1),a0
             jsr       Free_memory
             move.l    (a1),8(a1)           ; Shift quad-map
             move.l    4(a1),12(a1)
             move.l    16(a1),16+8(a1)
             move.l    16+4(a1),16+12(a1)
             move.w    34(a1),34+8(a1)
             move.w    34+4(a1),34+12(a1)
             btst      #0,Quad_index+1      ; Adapt X
             beq.s     .Skip
             subq.w    #1,d0
.Skip:       subq.w    #1,d1                ; Load new maps
             jsr       Load_submap
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             addq.w    #1,d0
             jsr       Load_submap
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             addi.w    #Submap_height,Quad_Y      ; Update quad coordinate
             move.l    (sp)+,d2             ; Adjust quad-index
             bset      #1,d2
             rts       

Shift_UR:    movea.l   (a1),a0              ; Free memory
             jsr       Free_memory
             movea.l   8(a1),a0
             jsr       Free_memory
             movea.l   12(a1),a0
             jsr       Free_memory
             movea.l   16(a1),a0
             jsr       Free_memory
             movea.l   16+8(a1),a0
             jsr       Free_memory
             movea.l   16+12(a1),a0
             jsr       Free_memory
             move.l    4(a1),8(a1)          ; Shift quad-map
             move.l    16+4(a1),16+8(a1)
             move.w    34+4(a1),34+8(a1)
             subq.w    #1,d1                ; Load new maps
             jsr       Load_submap
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             addq.w    #1,d0
             jsr       Load_submap
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             addq.w    #1,d1
             jsr       Load_submap
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             subi.w    #Submap_width,Quad_X ; Update quad coordinates
             addi.w    #Submap_height,Quad_Y
             move.w    #2,d2                ; Adjust quad-index
             rts       

Shift_L:     move.l    d2,-(sp)
             movea.l   4(a1),a0             ; Free memory
             jsr       Free_memory
             movea.l   12(a1),a0
             jsr       Free_memory
             movea.l   16+4(a1),a0
             jsr       Free_memory
             movea.l   16+12(a1),a0
             jsr       Free_memory
             move.l    (a1),4(a1)           ; Shift quad-map
             move.l    8(a1),12(a1)
             move.l    16(a1),16+4(a1)
             move.l    16+8(a1),16+12(a1)
             move.w    34(a1),34+4(a1)
             move.w    34+8(a1),34+12(a1)
             btst      #1,Quad_index+1      ; Adapt Y
             beq.s     .Skip
             subq.w    #1,d1
.Skip:       subq.w    #1,d0                ; Load new maps
             jsr       Load_submap
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             addq.w    #1,d1
             jsr       Load_submap
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             addi.w    #Submap_width,Quad_X ; Update quad coordinate
             move.l    (sp)+,d2             ; Adjust quad-index
             bset      #0,d2
             rts       

Shift_R:     move.l    d2,-(sp)
             movea.l   (a1),a0              ; Free memory
             jsr       Free_memory
             movea.l   8(a1),a0
             jsr       Free_memory
             movea.l   16(a1),a0
             jsr       Free_memory
             movea.l   16+8(a1),a0
             jsr       Free_memory
             move.l    4(a1),(a1)           ; Shift quad-map
             move.l    12(a1),8(a1)
             move.l    16+4(a1),16(a1)
             move.l    16+12(a1),16+8(a1)
             move.w    34+4(a1),34(a1)
             move.w    34+12(a1),34+8(a1)
             btst      #1,Quad_index+1      ; Adapt Y
             beq.s     .Skip
             subq.w    #1,d1
.Skip:       addq.w    #1,d0                ; Load new maps
             jsr       Load_submap
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             addq.w    #1,d1
             jsr       Load_submap
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             subi.w    #Submap_width,Quad_X ; Update quad coordinate
             move.l    (sp)+,d2             ; Adjust quad-index
             bclr      #0,d2
             rts       

Shift_DL:    movea.l   (a1),a0              ; Free memory
             jsr       Free_memory
             movea.l   4(a1),a0
             jsr       Free_memory
             movea.l   12(a1),a0
             jsr       Free_memory
             movea.l   16(a1),a0
             jsr       Free_memory
             movea.l   16+4(a1),a0
             jsr       Free_memory
             movea.l   16+12(a1),a0
             jsr       Free_memory
             move.l    8(a1),4(a1)          ; Shift quad-map
             move.l    16+8(a1),16+4(a1)
             move.w    34+8(a1),34+4(a1)
             addq.w    #1,d1                ; Load new maps
             jsr       Load_submap
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             subq.w    #1,d0
             jsr       Load_submap
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             subq.w    #1,d1
             jsr       Load_submap
             move.l    a0,(a1)
             move.l    a2,16(a1)
             move.w    d2,34(a1)
             addi.w    #Submap_width,Quad_X ; Update quad coordinates
             subi.w    #Submap_height,Quad_Y
             move.w    #1,Quad_index        ; Adjust quad-index
             rts       

Shift_D:     move.l    d2,-(sp)
             movea.l   (a1),a0              ; Free memory
             jsr       Free_memory
             movea.l   4(a1),a0
             jsr       Free_memory
             movea.l   16(a1),a0
             jsr       Free_memory
             movea.l   16+4(a1),a0
             jsr       Free_memory
             move.l    8(a1),(a1)           ; Shift quad-map
             move.l    12(a1),4(a1)
             move.l    16+8(a1),16(a1)
             move.l    16+12(a1),16+4(a1)
             move.w    34+8(a1),34(a1)
             move.w    34+12(a1),34+4(a1)
             btst      #0,Quad_index+1      ; Adapt X
             beq.s     .Skip
             subq.w    #1,d0
.Skip:       addq.w    #1,d1                ; Load new maps
             jsr       Load_submap
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             addq.w    #1,d0
             jsr       Load_submap
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             subi.w    #Submap_height,Quad_Y      ; Update quad coordinate
             move.l    (sp)+,d2             ; Adjust quad-index
             bclr      #1,d2
             rts       

Shift_DR:    movea.l   (a1),a0              ; Free memory
             jsr       Free_memory
             movea.l   4(a1),a0
             jsr       Free_memory
             movea.l   8(a1),a0
             jsr       Free_memory
             movea.l   16(a1),a0            ; Free memory
             jsr       Free_memory
             movea.l   16+4(a1),a0
             jsr       Free_memory
             movea.l   16+8(a1),a0
             jsr       Free_memory
             move.l    12(a1),(a1)          ; Shift quad-map
             move.l    16+12(a1),16(a1)
             move.w    34+12(a1),34(a1)
             addq.w    #1,d0                ; Load new maps
             jsr       Load_submap
             move.l    a0,4(a1)
             move.l    a2,16+4(a1)
             move.w    d2,34+4(a1)
             addq.w    #1,d1
             jsr       Load_submap
             move.l    a0,12(a1)
             move.l    a2,16+12(a1)
             move.w    d2,34+12(a1)
             subq.w    #1,d0
             jsr       Load_submap
             move.l    a0,8(a1)
             move.l    a2,16+8(a1)
             move.w    d2,34+8(a1)
             subi.w    #Submap_width,Quad_X ; Update quad coordinates
             subi.w    #Submap_height,Quad_Y
             move.w    #0,d2                ; Adjust quad-index
             rts       

; [ Load a submap ]
;   IN : d0 - World X (.w)
;        d1 - World Y (.w)
;  OUT : d2 - Map number (.w)
;        a0 - Pointer to map data (.l)
;        a2 - Pointer to text file (.l)
; Changed registers : a0
Load_submap: 
             movem.l   d0/d1,-(sp)
             tst.w     d0                   ; Wrap X
             bpl.s     .Skip_1
             addi.w    #World_width,d0
             bra.s     .Check_Y
.Skip_1:     cmpi.w    #World_width,d0
             bmi.s     .Check_Y
             subi.w    #World_width,d0
.Check_Y:    tst.w     d1                   ; Wrap Y
             bpl.s     .Skip_2
             addi.w    #World_height,d1
             bra.s     .Cont
.Skip_2:     cmpi.w    #World_height,d1
             bmi.s     .Cont
             subi.w    #World_height,d1
.Cont:       mulu.w    #World_width,d1
             add.w     d1,d0
             addq.w    #1,d0                ; Add number of first map
             lea.l     Maptext_filename,a0  ; Load text
             jsr       Load_subfile
             movea.l   a0,a2
             lea.l     Mapd_filename,a0     ; Load map
             jsr       Load_subfile
             move.w    d0,d2                ; Copy
             movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ 2D wilderness - Move down/right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_downright:          
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move down/right
             addq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Move
             jsr       W2_down              ; Try to move down or right
             beq       .Exit
             jsr       W2_right
             bra       .Exit
.Move:       move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             addq.w    #1,Quad_X            ; Update quad coordinates
             addq.w    #1,Quad_Y
             jsr       Quad_evaluate
             move.w    #1,Scroll_X          ; Set scroll direction
             move.w    #1,Scroll_Y
             move.w    #1,Half_X
             move.w    #1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move up/right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_upright:  
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move up/right
             subq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Move
             jsr       W2_up                ; Try to move up or right
             beq.s     .Exit
             jsr       W2_right
             bra.s     .Exit
.Move:       move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             addq.w    #1,Quad_X            ; Update quad coordinates
             subq.w    #1,Quad_Y
             jsr       Quad_evaluate
             move.w    #1,Scroll_X          ; Set scroll direction
             move.w    #-1,Scroll_Y
             move.w    #1,Half_X
             move.w    #-1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move down/left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_downleft: 
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move down/left
             addq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Move
             jsr       W2_down              ; Try to move down or left
             beq.s     .Exit
             jsr       W2_left
             bra.s     .Exit
.Move:       move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             subq.w    #1,Quad_X            ; Update quad coordinates
             addq.w    #1,Quad_Y
             jsr       Quad_evaluate
             move.w    #-1,Scroll_X         ; Set scroll direction
             move.w    #1,Scroll_Y
             move.w    #-1,Half_X
             move.w    #1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move up/left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_upleft:   
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move up/left
             subq.w    #1,d1
             jsr       Movement_check_2D
             beq.s     .Move
             jsr       W2_up                ; Try to move up or left
             beq.s     .Exit
             jsr       W2_left
             bra.s     .Exit
.Move:       move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             subq.w    #1,Quad_X            ; Update quad coordinates
             subq.w    #1,Quad_Y
             jsr       Quad_evaluate
             move.w    #-1,Scroll_X         ; Set scroll direction
             move.w    #-1,Scroll_Y
             move.w    #-1,Half_X
             move.w    #-1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move up ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_up:       
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #0,View_direction    ; View north
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d1                ; Try to move up
             jsr       Movement_check_2D
             sne       Bumped
             bne.s     .Exit
             move.w    d1,Map_Ycoord        ; Store new coordinate
             subq.w    #1,Quad_Y            ; Update quad coordinate
             jsr       Quad_evaluate
             move.w    #-1,Scroll_Y         ; Set scroll direction
             move.w    #-1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move down ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_down:     
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #2,View_direction    ; View south
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d1                ; Try to move down
             jsr       Movement_check_2D
             sne       Bumped
             bne.s     .Exit
             move.w    d1,Map_Ycoord        ; Store new coordinate
             addq.w    #1,Quad_Y            ; Update quad coordinate
             jsr       Quad_evaluate
             move.w    #1,Scroll_Y          ; Set scroll direction
             move.w    #1,Half_Y
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move right ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_right:    
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #1,View_direction    ; View east
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             addq.w    #1,d0                ; Try to move right
             jsr       Movement_check_2D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinate
             addq.w    #1,Quad_X            ; Update quad coordinate
             jsr       Quad_evaluate
             move.w    #1,Scroll_X          ; Set scroll direction
             move.w    #1,Half_X
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D wilderness - Move left ]
;  OUT :     Zero - Movement made
;        Non-zero - No movement made
; All registers are restored
;*****************************************************************************
W2_left:     
             jsr       Before_move
             movem.l   d0-d2,-(sp)
             moveq.l   #-1,d2               ; Zero flag off
             move.w    #3,View_direction    ; View west
             move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; Try to move left
             jsr       Movement_check_2D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinate
             subq.w    #1,Quad_X            ; Update quad coordinate
             jsr       Quad_evaluate
             move.w    #-1,Scroll_X         ; Set scroll direction
             move.w    #-1,Half_X
             jsr       Build_2D_map         ; Build 2D map
             jsr       Switch_screen        ; Switch screen
             jsr       After_move
             moveq.l   #0,d2                ; Success
.Exit:       tst.w     d2                   ; Get zero flag
             movem.l   (sp)+,d0-d2
             rts       

;*****************************************************************************
; [ 2D Wilderness - display map ]
; All registers are restored
;*****************************************************************************
W2_DisUpd:   
             movem.l   d0-d2/a0/a1,-(sp)
             lea.l     Trans_buf,a0         ; Clear transport buffer
             moveq.l   #0,d0
             move.b    d0,(a0)+
             move.w    d0,(a0)+
             moveq.l   #35-1,d1
.Loop:       move.l    d0,(a0)+
             dbra      d1,.Loop
             move.w    Quad_X,d0            ; Get quad-map coordinates
             move.w    Quad_Y,d1
             subi.w    #Def_mapbuf_X+2,d0   ; Adjust coordinates
             subi.w    #Def_mapbuf_Y+2,d1
             move.w    Quad_index,d2        ; Calculate multi-map index
             add.w     d2,d2
             add.w     d2,d2
             cmpi.w    #Submap_width-12,d0
             bmi.s     .Check_Y
             cmpi.w    #Submap_width,d0
             bpl.s     .Check_Y
             bset      #4,d2
.Check_Y:    cmpi.w    #Submap_height-10,d1
             bmi.s     .Cont
             cmpi.w    #Submap_height,d1
             bpl.s     .Cont
             bset      #5,d2
.Cont:       lea.l     Quad_map,a1          ; Pointer to quad-map
             lea.l     Multimap_table,a0    ; Get routine address
             movea.l   0(a0,d2.w),a0
             jsr       (a0)                 ; Execute routine
             .LOCAL 
             jsr       Build_2D_map         ; Build 2D map
             jsr       Update_map_CIL
             tst.b     CombatReq            ; Start combat ?
             beq.s     .Exit
             Push      Module,CombatReq_Mod
.Exit:       movem.l   (sp)+,d0-d2/a0/a1
             rts       

Multimap_table:        
             .DC.l Cut_A,Cut_A,Cut_A,Cut_A
             .DC.l Cut_B,Cut_B,Cut_E,Cut_E
             .DC.l Cut_C,Cut_D,Cut_C,Cut_D
             .DC.l Cut_F,Cut_F,Cut_F,Cut_F

; [ Multi-map cut routines ]
;   IN : d0 - Quad X (.w)
;        d1 - Quad Y (.w)
;        a1 - Pointer to quad-map (.l)
; Changed registers : d0,d1,a0

Cut_A:       move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             subi.w    #Def_mapbuf_X+2,d0   ; Adjust coordinates
             subi.w    #Def_mapbuf_Y+2,d1
             movea.l   Mapd_ptr,a0          ; Cut from normal map
             move.w    Map_nr,d2
             jmp       Copy_map_part

Cut_B:       movea.l   (a1),a0              ; Cut from first map
             move.w    34(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_width,d0     ; Cut from second map
             movea.l   4(a1),a0
             move.w    34+4(a1),d2
             jmp       Copy_map_part

Cut_C:       movea.l   (a1),a0              ; Cut from first map
             move.w    34(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_height,d1    ; Cut from third map
             movea.l   8(a1),a0
             move.w    34+8(a1),d2
             jmp       Copy_map_part

Cut_D:       subi.w    #Submap_width,d0     ; Cut from second map
             movea.l   4(a1),a0
             move.w    34+4(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_height,d1    ; Cut from fourth map
             movea.l   12(a1),a0
             move.w    34+12(a1),d2
             jmp       Copy_map_part

Cut_E:       subi.w    #Submap_height,d1    ; Cut from third map
             movea.l   8(a1),a0
             move.w    34+8(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_width,d0     ; Cut from fourth map
             movea.l   12(a1),a0
             move.w    34+12(a1),d2
             jmp       Copy_map_part

Cut_F:       movea.l   (a1),a0              ; Cut from first map
             move.w    34(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_width,d0     ; Cut from second map
             movea.l   4(a1),a0
             move.w    34+4(a1),d2
             jsr       Copy_map_part
             subi.w    #Submap_height,d1    ; Cut from fourth map
             movea.l   12(a1),a0
             move.w    34+12(a1),d2
             jsr       Copy_map_part
             addi.w    #Submap_width,d0     ; Cut from third map
             movea.l   8(a1),a0
             move.w    34+8(a1),d2
             jmp       Copy_map_part

; [ Copy part of map ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Map number (.w)
;        a0 - Pointer to map data (.l)
; All registers are restored
Copy_map_part:         
             movem.l   d0-d3/d5-d7/a0-a3,-(sp)
             lea.l     Map_data(a0),a0      ; Point to actual map data
             lea.l     Underlay_buf,a1      ; Map buffer
             moveq.l   #10,d7               ; Load counters
             moveq.l   #12,d6
             tst.w     d0                   ; X < 0 ?
             bpl.s     .X_pos
             add.w     d0,d6                ; Adjust width
             neg.w     d0                   ; Adjust buffer pointer
             adda.w    d0,a1
             moveq.l   #0,d0                ; X = 0
             bra.s     .Y_check
.X_pos:      cmpi.w    #Submap_width-12,d0  ; X > width - 12 ?
             bmi.s     .Y_check
             move.w    #Submap_width-1,d3   ; Adjust width
             sub.w     d0,d3
             move.w    d3,d6
.Y_check:    tst.w     d1                   ; Y < 0 ?
             bpl.s     .Y_pos
             add.w     d1,d7                ; Adjust height
             neg.w     d1                   ; Adjust buffer pointer
             mulu.w    #13,d1
             adda.w    d1,a1
             moveq.l   #0,d1                ; Y = 0
             bra.s     .Cont
.Y_pos:      cmpi.w    #Submap_height-10,d1 ; Y > height - 10 ?
             bmi.s     .Cont
             move.w    #Submap_height-1,d3  ; Adjust height
             sub.w     d1,d3
             move.w    d3,d7
.Cont:       tst.w     d6                   ; Exit if no copy
             bmi.s     .Exit
             tst.w     d7
             bmi.s     .Exit
             jsr       Enter_transport_icons      ; Handle transports
             move.w    Width_of_map,d2      ; Get width of map
             adda.w    d0,a0                ; Calculate map pointer
             mulu.w    d2,d1
             adda.w    d1,a0
             move.w    Size_of_map,d0       ; Load constants
             move.w    #13*11,d1
.Loop_1:     movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             move.w    d6,d5                ; Duplicate counter
.Loop_2:     move.b    (a2)+,(a3)+          ; Copy underlay & overlay
             move.b    -1(a2,d0.w),-1(a3,d1.w)
             dbra      d5,.Loop_2           ; Next column
             adda.w    d2,a0                ; Next line
             lea.l     13(a1),a1
             dbra      d7,.Loop_1
.Exit:       movem.l   (sp)+,d0-d3/d5-d7/a0-a3
             rts       

;*****************************************************************************
; [ Enter transport icons ]
;   IN : d0 - Top-left X-coordinate (.w)
;        d1 - Top-left Y-coordinate (.w)
;        d2 - Map number (.w)
;        d6 - Width of area - 1 (.w)
;        d7 - Height of area - 1 (.w)
;        a1 - Pointer to map area (.l)
; All registers are restored
;*****************************************************************************
Enter_transport_icons: 
             movem.l   d0-d7/a0-a2,-(sp)
             lea.l     429(a1),a2
             addq.w    #1,d0                ; Calculate clip edges
             addq.w    #1,d1
             move.w    d0,d4
             move.w    d1,d5
             add.w     d0,d6
             add.w     d1,d7
             lea.l     Trans_T,a0           ; Initialize registers
             lea.l     90(a0),a1
             moveq.l   #30-1,d3
.Loop:       tst.b     (a0)                 ; Any there ?
             beq       .Next
             cmp.w     (a1),d2              ; Current map ?
             bne       .Next
             moveq.l   #0,d0                ; Get coordinates
             move.b    30(a0),d0
             moveq.l   #0,d1
             move.b    60(a0),d1
             cmp.w     d4,d0                ; X too low ?
             bmi       .Next
             cmp.w     d0,d6                ; X too high ?
             bmi       .Next
             cmp.w     d5,d1                ; Y too low ?
             bmi       .Next
             cmp.w     d1,d7                ; Y too high ?
             bmi       .Next
             sub.w     d4,d0                ; Calculate buffer coordinates
             sub.w     d5,d1
             mulu.w    #13,d1               ; Calculate buffer offset
             add.w     d0,d1
             moveq.l   #0,d0                ; Set icon
             move.b    (a0),d0
             addi.w    #244,d0
             move.b    d0,0(a2,d1.w)
.Next:       addq.l    #1,a0                ; Next
             addq.l    #2,a1
             dbra      d3,.Loop
             movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
W2_CIL:      .DC.b 46,1,45,4,7,3,48,2,47    ; 2D wild movement icons
             .EVEN 
             .DC.l W2_upleft,W2_up,W2_upright
             .DC.l W2_left,Zzz,W2_right
             .DC.l W2_downleft,W2_down,W2_downright

             .BSS 
World_X:     .DS.w 1   ; World coordinates
World_Y:     .DS.w 1
Quad_X:      .DS.w 1   ; Quad-map coordinates
Quad_Y:      .DS.w 1
Quad_index:  .DS.w 1   ; Quad-map index
Quad_map:    .DS.l 4   ; Pointers to four maps
             .DS.l 4   ; Pointers to map text files
             .DS.l 4   ; Map numbers

             .END 

























