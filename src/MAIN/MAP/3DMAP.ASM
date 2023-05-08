
; 3D map routines
; Written by J.Horneman (Plodding On Relentlessly)
; Start : 12-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "Let us sing the song it is
;     Let the sound of all belief
;      Let's all find that space in life
;       To follow in between"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTE :
;  - If movement is überhaupt impossible, this should be detected before
;    the movement routines are called.
;  - The [Blit] routines access the screen directly and must be adapted for
;    the AMIGA.

Topleft_X    = 32      ; Coordinates of top-left corner of 3D map display
Topleft_Y    = 49      ;  window
M3_animspeed           = 1                  ; Number of frames between animation phases

             .TEXT 
;*****************************************************************************
; [ Cut from 3D map ]
; All registers are restored
;*****************************************************************************
Cut_from_3D_map:       
             movem.l   d0-d4/d7/a0-a3,-(sp)
             move.w    Map_Xcoord,d0        ; Get map coordinates
             move.w    Map_Ycoord,d1
             subq.w    #1,d0                ; BASE 0 correction
             subq.w    #1,d1
             move.w    Width_of_map,d4      ; Get width of map
             movea.l   Map_pointer,a0       ; Get map pointer
             lea.l     Cut_table_3D,a1      ; Calculate cut-table pointer
             moveq.l   #24,d2
             mulu.w    View_direction,d2
             adda.w    d2,a1
             lea.l     Map_buffer_3D,a2
             lea.l     Hash_buffer_3D,a3
             moveq.l   #12-1,d7
.Loop:       move.b    (a1)+,d2             ; Get coordinates
             ext.w     d2
             add.w     d0,d2
             move.b    (a1)+,d3
             ext.w     d3
             add.w     d1,d3
             muls.w    d4,d3                ; Calculate map offset
             add.w     d2,d3
             move.w    d3,(a3)+             ; Store for random hashing
             move.b    0(a0,d3.w),(a2)+     ; Copy from map to buffer
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d4/d7/a0-a3
             rts       

;*****************************************************************************
; [ Check for darkness & blind main character ]
; All registers are restored
;*****************************************************************************
M3_Dark_check:         
             movem.l   d0/a0,-(sp)
             movea.l   Current_active_char_data,a0          ; Blind ?
             btst      #4,Mind_conditions(a0)
             sne       Stygian              ; Darkness !
             bne       .Exit
             movea.l   Mapd_ptr,a0          ; Get bits
             move.b    Map_special(a0),d0
             btst      #2,d0                ; Dark bit on ?
             beq       .Exit
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             beq       .Exit
             tst.w     Spell_1_duration     ; Any light spell active ?
             seq       Stygian              ; Darkness !
.Exit:       movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Build 3D map ]
; All registers are restored
;*****************************************************************************
Build_3D_map:          
             movem.l   d0-d2/d6/d7/a0-a6,-(sp)
             jsr       M3_Dark_check
             tst.b     Stygian              ; Can we see ?
             beq.s     .I_can_see
             move.w    #Topleft_X,d0        ; Erase display window
             move.w    #Topleft_Y,d1
             move.w    d0,d2
             move.w    d1,d3
             addi.w    #144-1,d2
             addi.w    #144-1,d3
             moveq.l   #0,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             bra       .Go_on
.I_can_see:  lea.l     Map_buffer_3D,a1     ; Copy persons in map buffer
             lea.l     Persons_buf_3D,a2
             moveq.l   #12-1,d7
.Loop1:      tst.b     (a2)                 ; Any person there ?
             beq.s     .Next1
             cmpi.b    #1,(a1)              ; Something already there ?
             bne.s     .Next1
             move.b    (a2),(a1)            ; Copy
.Next1:      addq.l    #1,a1                ; Next
             addq.l    #1,a2
             dbra      d7,.Loop1
             lea.l     -12(a1),a1           ; Initialize registers
             movea.l   INB_ptr,a2
             lea.l     Labblock_ptrs,a3
             movea.l   Iconstats_ptr,a4
             movea.l   Off_screen,a6
             moveq.l   #1,d7                ; Start size
.Loop2:      moveq.l   #0,d0                ; Get byte from map buffer
             move.b    -1(a1,d7.w),d0
             jsr       Get_ptr_to_labblock
             cmpi.b    #1,Block_type(a0)    ; Is it an underlay ?
             bne.s     .Not_underlay
             jsr       Display_element
             bra.s     .Next2
.Not_underlay:         
             cmpi.b    #2,Block_type(a0)    ; Is it an overlay ?
             bne.s     .Not_overlay
             movem.l   d0/a0,-(sp)          ; Protect
             movea.l   OUH_ptr,a0           ; Display underlay
             move.b    -1(a0,d0.w),d0
             jsr       Get_ptr_to_labblock
             jsr       Display_element
             movem.l   (sp)+,d0/a0          ; Restore
             jsr       Display_element      ; Display overlays
             move.w    d7,d6
             move.b    .Extra_overlay-1(pc,d7.w),d7         ;  Get extra size
             beq.s     .Zero
             jsr       Display_element
.Zero:       move.w    d6,d7
             bra.s     .Next2
.Extra_overlay:        
             .DC.b 12,13,0,14,15,0,16,17,0,0,0,0
             .EVEN 
.Not_overlay:          
             jsr       Display_object       ; It's an object
.Next2:      addq.l    #1,d7                ; Next
             cmpi.w    #12,d7
             bmi       .Loop2
             moveq.l   #0,d0                ; Get last byte
             move.b    11(a1),d0
             jsr       Get_ptr_to_labblock
             cmpi.b    #3,Block_type(a0)    ; Is it an object ?
             bne       .Go_on
             cmpi.b    #1,Block_animation(a0)     ; Animated ?
             bne.s     .Special
             jsr       Display_object
             bra       .Go_on
.Special:    jsr       Display_special_object
; ------------- Display "OUCH!" when necessary -----------------------
.Go_on:      tst.b     Bumped               ; Ouch ?
             beq.s     .Exit
             move.w    #49,d1               ; Calculate random coordinate
             jsr       Random
             andi.w    #$3f,d0
             add.w     d0,d1
             move.w    #112,d0              ; Display "OUCH!"
             moveq.l   #2,d6
             moveq.l   #32,d7
             lea.l     Status_icn+3584,a0
             movea.l   Off_screen,a6
             jsr       Blot_masked_block
             sf        Bumped               ; Clear flag
.Exit:       jsr       Update_animation
             jsr       Update_status_block
             jsr       Show_special_items
             jsr       Show_spells
             movem.l   (sp)+,d0-d2/d6/d7/a0-a6
             rts       

;*****************************************************************************
; [ Get pointer to lab-block ]
;   IN : d0 - Byte from map buffer (1,...) (.w)
;        a2 - Pointer to INB-array (.l)
;        a3 - Pointer to list of pointers to lab-blocks (.l)
;  OUT : a0 - Pointer to lab-block (.l)
; Changed registers : a0
;*****************************************************************************
Get_ptr_to_labblock:   
             move.l    d1,-(sp)
             moveq.l   #0,d1                ; Get block number from
             move.b    -1(a2,d0.w),d1       ;  INB-array
             add.w     d1,d1                ; Get pointer to lab-block
             add.w     d1,d1
             movea.l   -4(a3,d1.w),a0
             move.l    (sp)+,d1
             rts       

;*****************************************************************************
; [ Display a 3D map element ]
;   IN : d0 - Byte from map buffer (1,...) (.w)
;        d7 - Size index (1,...17)
;        a0 - Pointer to lab-block (.l)
;       ( a4 - Pointer to block-stats (.l) )
;       ( a6 - Screen base (.l)            )
; All registers are restored
;*****************************************************************************
Display_element:       
             movem.l   d0-d2/d7/a0/a1,-(sp)
             moveq.l   #0,d1                ; Get number of frames
             move.b    Block_animation(a0),d1
             jsr       Get_current_anim_frame
             lea.l     Block_elements(a0),a1      ; Find correct frame
             moveq.l   #0,d0                ; Get number of elements
             move.b    Block_number(a0),d0
             subq.w    #1,d0                ; Counter corrections
             subq.w    #1,d1
             bmi.s     .First_frame
.Loop_1:     move.w    d0,d2                ; Duplicate counter
.Loop_2:     adda.l    (a1)+,a1
             dbra      d2,.Loop_2
             dbra      d1,.Loop_1
.First_frame:          move.w               d7,d0 ; Find correct size
             subq.w    #2,d0                ; Counter correction
             bmi.s     .First_size
.Loop_3:     adda.l    (a1)+,a1
             dbra      d0,.Loop_3
.First_size: add.w     d7,d7                ; Get coordinates of element
             move.w    Block_X_cor-2(a0,d7.w),d0
             move.w    Block_Y_cor-2(a0,d7.w),d1
             lea.l     4(a1),a0             ; Skip irrelevant longword
             jsr       Blit                 ; Display element
             movem.l   (sp)+,d0-d2/d7/a0/a1
             rts       

;*****************************************************************************
; [ Display a 3D map object ]
;   IN : d0 - Byte from map buffer (1,...) (.w)
;        d7 - Size index (1,...11)
;        a0 - Pointer to lab-block (.l)
;       ( a4 - Pointer to block-stats (.l) )
;       ( a6 - Screen base (.l)            )
; All registers are restored
;*****************************************************************************
OD_Table:    
             .DC.b 1,1,1,2,2,2,3,3,3,0,0,4
             .DC.b 0,8,4,0,8,4,0,8,4,0,8,4
             .EVEN 
Display_object:        
             movem.l   d0-d2/d6/d7/a0/a1,-(sp)
             moveq.l   #0,d1                ; Get number of frames
             move.b    Block_animation(a0),d1
             jsr       Get_current_anim_frame
             move.b    OD_Table+11(pc,d7.w),d6
             ext.w     d6
             move.b    OD_Table-1(pc,d7.w),d7
             beq       .Exit
             lea.l     Block_elements+4(a0),a1    ; Find correct frame
             moveq.l   #0,d0                ; Get number of elements
             move.b    Block_number(a0),d0
             subq.w    #1,d0                ; Counter corrections
             subq.w    #1,d1
             bmi.s     .First_frame
.Loop_1:     move.w    d0,d2                ; Duplicate counter
.Loop_2:     adda.l    (a1)+,a1
             dbra      d2,.Loop_2
             dbra      d1,.Loop_1
.First_frame:          move.w               d7,d0 ; Find correct size
             subq.w    #2,d0                ; Counter correction
             bmi.s     .First_size
.Loop_3:     adda.l    (a1)+,a1
             dbra      d0,.Loop_3
.First_size: add.w     d7,d7                ; Get coordinates of element
             move.w    Block_X_cor-2(a0,d7.w),d0
             move.w    Block_Y_cor-2(a0,d7.w),d1
             lea.l     4(a1),a0             ; Skip irrelevant longword
             movea.l   .OD_ptrs(pc,d6.w),a1 ; Display element
             jsr       (a1)
.Exit:       movem.l   (sp)+,d0-d2/d6/d7/a0/a1
             rts       

.OD_ptrs:    .DC.l Blit_left,Blit,Blit_right

;*****************************************************************************
; [ Display a SPECIAL 3D map object ]
;   IN :  a0 - Pointer to lab-block (.l)
;       ( a4 - Pointer to block-stats (.l) )
;       ( a6 - Screen base (.l)            )
; All registers are restored
;*****************************************************************************
Display_special_object:                     
             movem.l   d0-d2/d7/a0/a1,-(sp)
             move.l    a0,-(sp)             ; Save
             move.w    d0,-(sp)
             lea.l     Block_elements+4(a0),a1    ; Find 4th size of
             adda.l    (a1)+,a1             ;  1st frame
             adda.l    (a1)+,a1
             adda.l    (a1)+,a1
             move.w    Block_X_cor+6(a0),d0 ; Get coordinates of element
             move.w    Block_Y_cor+6(a0),d1
             lea.l     4(a1),a0             ; Skip irrelevant longword
             jsr       Blit                 ; Display element
             move.w    (sp)+,d0             ; Restore
             movea.l   (sp)+,a0
; ------------- Display extra frame ----------------------------------
             moveq.l   #0,d1                ; Get number of frames
             move.b    Block_animation(a0),d1
             subq.w    #1,d1                ; One less !!!
             moveq.l   #12,d7
             jsr       Get_current_anim_frame
             addq.w    #1,d1                ; One more !!!
             lea.l     Block_elements+4(a0),a1    ; Find correct frame
             moveq.l   #0,d0                ; Get number of elements
             move.b    Block_number(a0),d0
             subq.w    #1,d0                ; Counter corrections
             subq.w    #1,d1
             bmi.s     .First_frame
.Loop_1:     move.w    d0,d2                ; Duplicate counter
.Loop_2:     adda.l    (a1)+,a1
             dbra      d2,.Loop_2
             dbra      d1,.Loop_1
.First_frame:          adda.l               (a1)+,a1        ; Find fourth size
             adda.l    (a1)+,a1
             adda.l    (a1)+,a1
             move.w    Block_elements(a0),d0      ; Get coordinates of element
             move.w    Block_elements+2(a0),d1
             lea.l     4(a1),a0             ; Skip irrelevant longword
             jsr       Blit                 ; Display element
             movem.l   (sp)+,d0-d2/d7/a0/a1
             rts       

;*****************************************************************************
; [ Get current animation frame (3D map) ]
;   IN : d0 - Byte from map buffer {1...} (.w)
;        d1 - Number of animation frames {1...8} (.w)
;        d7 - Size index (.w)
;        a4 - Pointer to block stats (.l)
;  OUT : d1 - Current animation frame (.w)
; Changed registers : d1
;*****************************************************************************
Get_current_anim_frame:                     
             movem.l   d0/a0/a1,-(sp)
             subq.w    #1,d1                ; BASE 0 correction
             beq.s     .No_anim             ; Any animation ?
             add.w     d0,d0                ; Get block stats
             add.w     d0,d0
             move.l    -4(a4,d0.w),d0
             lea.l     Circle_anim,a1       ; Circle or wave ?
             btst      #0,d0
             beq.s     .Circle
             lea.l     Wave_anim,a1         ; Wave
.Circle:     add.w     d1,d1                ; Add number of frames
             add.w     d1,d1
             adda.w    d1,a1
             btst      #4,d0                ; Random animation ?
             beq.s     .No_random
             move.b    1(a1),d0             ; Get random offset
             ext.w     d0
             lea.l     Hash_buffer_3D-2,a0  ; Get hash number
             adda.w    d7,a0
             adda.w    d7,a0
             add.w     (a0),d0
             andi.w    #$000f,d0            ; Random hash
             move.w    2(a1),d1             ; Test
             btst      d0,d1
             bne.s     .No_random
             moveq.l   #0,d1                ; No animation
             bra.s     .No_anim
.No_random:  move.b    (a1),d1              ; Get current frame
             ext.w     d1
.No_anim:    movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Blit routines ]
;   IN : d0 - X-coordinate in 3D map display window (.w)
;        d1 - Y-coordinate in 3D map display window (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored

; NOTES :
;   - These routines assume the block has a Gfa-basic GET-header.
;   - They also assume all parameters are correct.
;   - They will only display 4-bitplane blocks.

;*****************************************************************************
             .ABS 2
Nr_columns:  .DS.w 1   ; Local variables offsets
Line_size:   .DS.w 1
End_mask:    .DS.w 1
Local_size:  

             .TEXT 
End_masks:   .DC.w $ffff,$8000,$c000,$e000
             .DC.w $f000,$f800,$fc00,$fe00
             .DC.w $ff00,$ff80,$ffc0,$ffe0
             .DC.w $fff0,$fff8,$fffc,$fffe

;*****************************************************************************
; [ Normal blit routine ]
;*****************************************************************************
Blit:        
             movem.l   d0-d7/a0-a4,-(sp)
             link      a4,#-Local_size      ; Space for local variables
             addi.w    #Topleft_X,d0        ; Translate coordinates
             addi.w    #Topleft_Y,d1
             move.w    (a0)+,d6             ; Get width & height
             move.w    (a0)+,d7
             cmpi.w    #4,(a0)+             ; 4 bitplanes ?
             bne       .Exit
             addq.w    #1,d6                ; Correction
             addq.w    #1,d7

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate of block       (.w)
;   d1 - Y-coordinate of block       (.w)
;   d6 - Width of block              (.w)
;   d7 - Height of block             (.w)
;   a0 - Pointer to block graphics   (.l)
;   a4 - Pointer to local variables  (.l)
;   a6 - Screen base                 (.l)

; ------------- Calculate variables ----------------------------------

             lea.l     End_masks,a1         ; Get end mask
             moveq.l   #$f,d2
             and.w     d6,d2
             add.w     d2,d2
             move.w    0(a1,d2.w),-End_mask(a4)

             moveq.l   #15,d2               ; Calculate number of columns
             add.w     d6,d2
             lsr.w     #4,d2
             subq.w    #1,d2
             move.w    d2,-Nr_columns(a4)

             subq.w    #1,d7                ; DBRA correction

             jsr       Coord_convert        ; Calculate screen address
             lea.l     0(a6,d2.w),a1

             andi.w    #$f,d0               ; Calculate shift value

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - Shift value                 (.w)
;   d7 - Height counter              (.w)
;   a0 - Pointer to block graphics   (.l)
;   a1 - Pointer to screen           (.l)
;   a4 - Pointer to local variables  (.l)

; ------------- Main loop --------------------------------------------

.Loop_Y:     movea.l   a1,a3                ; Duplicate pointer
             move.w    -Nr_columns(a4),d6   ; Load width counter
.Loop_X:     moveq.l   #0,d1                ; Clear registers
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d4
             move.w    (a0)+,d1             ; Load one column from block
             move.w    (a0)+,d2
             move.w    (a0)+,d3
             move.w    (a0)+,d4
             tst.w     d6                   ; Last column ?
             bne.s     .Not_last
             and.w     -End_mask(a4),d1     ; End masks
             and.w     -End_mask(a4),d2
             and.w     -End_mask(a4),d3
             and.w     -End_mask(a4),d4
.Not_last:   ror.l     d0,d1                ; Rotate
             ror.l     d0,d2
             ror.l     d0,d3
             ror.l     d0,d4
             move.l    d1,d5                ; Calculate mask
             or.l      d2,d5
             or.l      d3,d5
             or.l      d4,d5
             not.l     d5
             and.w     d5,(a3)              ; Display 1st part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             swap.w    d1                   ; Swap
             swap.w    d2
             swap.w    d3
             swap.w    d4
             swap.w    d5
             and.w     d5,(a3)              ; Display 2nd part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             subq.l    #8,a3                ; Adjust screen pointer
             dbra      d6,.Loop_X
             lea.l     160(a1),a1           ; Next line
             dbra      d7,.Loop_Y
.Exit:       unlk      a4                   ; Return local variable space
             movem.l   (sp)+,d0-d7/a0-a4
             rts       

;*****************************************************************************
; [ Left blit routine ]
;*****************************************************************************
Blit_left:   
             movem.l   d0-d7/a0-a4,-(sp)
             link      a4,#-Local_size      ; Space for local variables
             addi.w    #Topleft_Y,d1        ; Translate coordinate
             move.w    (a0)+,d6             ; Get width & height
             move.w    (a0)+,d7
             cmpi.w    #4,(a0)+             ; 4 bitplanes ?
             bne       .Exit
             addq.w    #1,d6                ; Correction
             addq.w    #1,d7

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate of block       (.w)
;   d1 - Y-coordinate of block       (.w)
;   d6 - Width of block              (.w)
;   d7 - Height of block             (.w)
;   a0 - Pointer to block graphics   (.l)
;   a4 - Pointer to local variables  (.l)
;   a6 - Screen base                 (.l)

; ------------- Calculate variables ----------------------------------
             moveq.l   #15,d2               ; Calculate size of line
             add.w     d6,d2
             andi.w    #$fff0,d2
             lsr.w     #1,d2
             move.w    d2,-Line_size(a4)

             lea.l     End_masks,a1         ; Get end mask
             moveq.l   #$f,d2
             and.w     d6,d2
             add.w     d2,d2
             move.w    0(a1,d2.w),-End_mask(a4)

             move.w    d6,d5                ; HALF WIDTH
             lsr.w     #1,d5
             move.w    d6,d4
             sub.w     d5,d4

             move.w    d4,d0                ; Calculate shift value
             neg.w     d0
             andi.w    #$f,d0
             move.w    d0,-(sp)

             moveq.l   #-1,d2               ; Skip half a line
             add.w     d4,d2
             andi.w    #$fff0,d2
             lsr.w     #1,d2
             adda.w    d2,a0

             moveq.l   #$f,d2               ; Calculate number of columns
             and.w     d6,d2
             move.w    d5,d3
             sub.w     d2,d3
             addi.w    #15,d3
             lsr.w     #4,d3
             tst.w     d2
             bne.s     .Not_zero1
             subq.w    #1,d3
.Not_zero1:  move.w    d3,-Nr_columns(a4)

             subq.w    #1,d7                ; DBRA correction

             move.w    #Topleft_X,d0        ; Calculate screen address
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a1

             move.w    (sp)+,d0             ; Retrieve shift value
             bne.s     .Not_zero2           ; Correction
             addq.w    #1,-Nr_columns(a4)
.Not_zero2:  

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - Shift value                 (.w)
;   d7 - Height counter              (.w)
;   a0 - Pointer to block graphics   (.l)
;   a1 - Pointer to screen           (.l)
;   a4 - Pointer to local variables  (.l)

; ------------- Main loop --------------------------------------------

.Loop_Y:     movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             move.w    -Nr_columns(a4),d6   ; Load width counter
             moveq.l   #0,d1                ; Clear registers
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d4
             move.w    (a2)+,d1             ; Load one column from block
             move.w    (a2)+,d2
             move.w    (a2)+,d3
             move.w    (a2)+,d4
             tst.w     d6                   ; Last column ?
             bne.s     .Not_last1
             and.w     -End_mask(a4),d1     ; End masks
             and.w     -End_mask(a4),d2
             and.w     -End_mask(a4),d3
             and.w     -End_mask(a4),d4
.Not_last1:  ror.l     d0,d1                ; Rotate
             ror.l     d0,d2
             ror.l     d0,d3
             ror.l     d0,d4
             move.l    d1,d5                ; Calculate mask
             or.l      d2,d5
             or.l      d3,d5
             or.l      d4,d5
             not.l     d5
             swap.w    d1                   ; Swap
             swap.w    d2
             swap.w    d3
             swap.w    d4
             swap.w    d5
             and.w     d5,(a3)              ; Display 2nd part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             subq.l    #8,a3                ; Adjust screen pointer
             bra.s     .Entry
.Loop_X:     moveq.l   #0,d1                ; Clear registers
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d4
             move.w    (a2)+,d1             ; Load one column from block
             move.w    (a2)+,d2
             move.w    (a2)+,d3
             move.w    (a2)+,d4
             tst.w     d6                   ; Last column ?
             bne.s     .Not_last2
             and.w     -End_mask(a4),d1     ; End masks
             and.w     -End_mask(a4),d2
             and.w     -End_mask(a4),d3
             and.w     -End_mask(a4),d4
.Not_last2:  ror.l     d0,d1                ; Rotate
             ror.l     d0,d2
             ror.l     d0,d3
             ror.l     d0,d4
             move.l    d1,d5                ; Calculate mask
             or.l      d2,d5
             or.l      d3,d5
             or.l      d4,d5
             not.l     d5
             and.w     d5,(a3)              ; Display 1st part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             swap.w    d1                   ; Swap
             swap.w    d2
             swap.w    d3
             swap.w    d4
             swap.w    d5
             and.w     d5,(a3)              ; Display 2nd part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             subq.l    #8,a3                ; Adjust screen pointer
.Entry:      dbra      d6,.Loop_X
             adda.w    -Line_size(a4),a0    ; Next line
             lea.l     160(a1),a1
             dbra      d7,.Loop_Y
.Exit:       unlk      a4                   ; Return local variable space
             movem.l   (sp)+,d0-d7/a0-a4
             rts       

;*****************************************************************************
; [ Right blit routine ]
;*****************************************************************************
Blit_right:  
             movem.l   d0-d7/a0-a4,-(sp)
             link      a4,#-Local_size      ; Space for local variables
             addi.w    #Topleft_Y,d1        ; Translate coordinate
             move.w    (a0)+,d6             ; Get width & height
             move.w    (a0)+,d7
             cmpi.w    #4,(a0)+             ; 4 bitplanes ?
             bne       .Exit
             addq.w    #1,d6                ; Correction
             addq.w    #1,d7

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - X-coordinate of block       (.w)
;   d1 - Y-coordinate of block       (.w)
;   d6 - Width of block              (.w)
;   d7 - Height of block             (.w)
;   a0 - Pointer to block graphics   (.l)
;   a4 - Pointer to local variables  (.l)
;   a6 - Screen base                 (.l)

; ------------- Calculate variables ----------------------------------
             moveq.l   #15,d2               ; Calculate size of line
             add.w     d6,d2
             andi.w    #$fff0,d2
             lsr.w     #1,d2
             move.w    d2,-Line_size(a4)

             move.w    d6,d5                ; HALF WIDTH
             lsr.w     #1,d5

             move.w    #Topleft_X+144,d0    ; Adapt X
             sub.w     d5,d0

             lea.l     End_masks,a1         ; Get end mask
             moveq.l   #$f,d2
             and.w     d5,d2
             add.w     d2,d2
             move.w    0(a1,d2.w),-End_mask(a4)

             moveq.l   #15,d2               ; Calculate number of columns
             add.w     d5,d2
             lsr.w     #4,d2
             subq.w    #1,d2
             move.w    d2,-Nr_columns(a4)

             subq.w    #1,d7                ; DBRA correction

             jsr       Coord_convert        ; Calculate screen address
             lea.l     0(a6,d2.w),a1

             andi.w    #$f,d0               ; Calculate shift value

; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - Shift value                 (.w)
;   d7 - Height counter              (.w)
;   a0 - Pointer to block graphics   (.l)
;   a1 - Pointer to screen           (.l)
;   a4 - Pointer to local variables  (.l)

; ------------- Main loop --------------------------------------------

.Loop_Y:     movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             move.w    -Nr_columns(a4),d6   ; Load width counter
.Loop_X:     moveq.l   #0,d1                ; Clear registers
             moveq.l   #0,d2
             moveq.l   #0,d3
             moveq.l   #0,d4
             move.w    (a2)+,d1             ; Load one column from block
             move.w    (a2)+,d2
             move.w    (a2)+,d3
             move.w    (a2)+,d4
             tst.w     d6                   ; Last column ?
             bne.s     .Not_last
             and.w     -End_mask(a4),d1     ; End masks
             and.w     -End_mask(a4),d2
             and.w     -End_mask(a4),d3
             and.w     -End_mask(a4),d4
.Not_last:   ror.l     d0,d1                ; Rotate
             ror.l     d0,d2
             ror.l     d0,d3
             ror.l     d0,d4
             move.l    d1,d5                ; Calculate mask
             or.l      d2,d5
             or.l      d3,d5
             or.l      d4,d5
             not.l     d5
             and.w     d5,(a3)              ; Display 1st part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             swap.w    d1                   ; Swap
             swap.w    d2
             swap.w    d3
             swap.w    d4
             swap.w    d5
             and.w     d5,(a3)              ; Display 2nd part
             or.w      d1,(a3)+
             and.w     d5,(a3)
             or.w      d2,(a3)+
             and.w     d5,(a3)
             or.w      d3,(a3)+
             and.w     d5,(a3)
             or.w      d4,(a3)+
             subq.l    #8,a3                ; Adjust screen pointer
             dbra      d6,.Loop_X
             adda.w    -Line_size(a4),a0    ; Next line
             lea.l     160(a1),a1
             dbra      d7,.Loop_Y
.Exit:       unlk      a4                   ; Return local variable space
             movem.l   (sp)+,d0-d7/a0-a4
             rts       

;*****************************************************************************
; Movement routines for the 3D map
;*****************************************************************************
D3_turnleft: 
             move.l    d0,-(sp)
             move.w    View_direction,d0    ; Get view direction
             subq.w    #1,d0                ; Turn counter-clockwise
             andi.w    #3,d0
             move.w    d0,View_direction    ; Store
             move.l    (sp)+,d0
             rts       

D3_turnright:          
             move.l    d0,-(sp)
             move.w    View_direction,d0    ; Get view direction
             addq.w    #1,d0                ; Turn clockwise
             andi.w    #3,d0
             move.w    d0,View_direction    ; Store
             move.l    (sp)+,d0
             rts       

D3_fullturnleft:       
             move.l    a0,-(sp)
             jsr       D3_turnleft          ; Turn left
             movea.l   Module_sp,a0         ; Update display
             movea.l   (a0),a0
             jsr       (a0)
             jsr       Switch_screen
             jsr       D3_turnleft          ; Turn left
             movea.l   (sp)+,a0
             rts       

D3_fullturnright:      
             move.l    a0,-(sp)
             jsr       D3_turnright         ; Turn right
             movea.l   Module_sp,a0         ; Update display
             movea.l   (a0),a0
             jsr       (a0)
             jsr       Switch_screen
             jsr       D3_turnright         ; Turn right
             movea.l   (sp)+,a0
             rts       

D3_forward:  
             jsr       Before_move
             movem.l   d0/d1,-(sp)
             move.w    View_direction,d1    ; Get view direction
             add.w     d1,d1
             move.b    .Forward(pc,d1.w),d0 ; Adapt X
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    .Forward+1(pc,d1.w),d1     ; Adapt Y
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Movement_check_3D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             jsr       Update_automap
             jsr       After_move
.Exit:       movem.l   (sp)+,d0/d1
             rts       
.Forward:    .DC.b 0,-1,1,0,0,1,-1,0

D3_left:     
             jsr       Before_move
             movem.l   d0/d1,-(sp)
             move.w    View_direction,d1    ; Get view direction
             add.w     d1,d1
             move.b    .Left(pc,d1.w),d0    ; Adapt X
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    .Left+1(pc,d1.w),d1  ; Adapt Y
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Movement_check_3D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             jsr       Update_automap
             jsr       After_move
.Exit:       movem.l   (sp)+,d0/d1
             rts       
.Left:       .DC.b -1,0,0,-1,1,0,0,1

D3_right:    
             jsr       Before_move
             movem.l   d0/d1,-(sp)
             move.w    View_direction,d1    ; Get view direction
             add.w     d1,d1
             move.b    .Right(pc,d1.w),d0   ; Adapt X
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    .Right+1(pc,d1.w),d1 ; Adapt Y
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Movement_check_3D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             jsr       Update_automap
             jsr       After_move
.Exit:       movem.l   (sp)+,d0/d1
             rts       
.Right:      .DC.b 1,0,0,1,-1,0,0,-1

D3_back:     
             jsr       Before_move
             movem.l   d0/d1,-(sp)
             move.w    View_direction,d1    ; Get view direction
             add.w     d1,d1
             move.b    .Back(pc,d1.w),d0    ; Adapt X
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    .Back+1(pc,d1.w),d1  ; Adapt Y
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Movement_check_3D
             sne       Bumped
             bne.s     .Exit
             move.w    d0,Map_Xcoord        ; Store new coordinates
             move.w    d1,Map_Ycoord
             jsr       Update_automap
             jsr       After_move
.Exit:       movem.l   (sp)+,d0/d1
             rts       
.Back:       .DC.b 0,1,-1,0,0,-1,1,0

;*****************************************************************************
; [ Get icon status (3D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : d0 - Icon status (.l)
; Changed registers : d0
;*****************************************************************************
Get_3D_icon_status:    
             movem.l   d1/a0/a1,-(sp)
             movea.l   Iconstats_ptr,a0
             movea.l   Map_pointer,a1       ; Calculate map address
             subq.w    #1,d1
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             moveq.l   #0,d0                ; Get block number
             move.b    -1(a1,d1.w),d0
             beq.s     .Exit
             subq.w    #1,d0                ; Get icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    0(a0,d0.w),d0
.Exit:       movem.l   (sp)+,d1/a0/a1
             rts       

;*****************************************************************************
; [ Check if movement is possible (3D map) ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
;*****************************************************************************
Movement_check_3D:     
             movem.l   d0/d6/d7/a0,-(sp)
             move.w    d0,d6                ; Copy coordinate
             cmpi.w    #6,Travel_mode       ; Is it a bird ?
             bne.s     .Normal              ; Is it a plane ?
             moveq.l   #0,d0
             bra       .Exit
.Normal:     jsr       Get_3D_icon_status   ; Get icon status
             btst.l    #7,d0                ; Way blocked ?
             bne       .Exit
             move.w    d6,d0                ; Copy back
             lea.l     VChar_data,a0        ; Another one already there ?
             move.l    CD_value,d6
             moveq.l   #0,d7                ; Character index is zero
.Loop:       tst.w     (a0)                 ; Any character there ?
             beq       .Next
             btst      d7,d6                ; Not removed ?
             bne       .Next
             cmp.w     VChar_X(a0),d0       ; Right coordinates ?
             bne       .Next
             cmp.w     VChar_Y(a0),d1
             bne       .Next
             move.b    VChar_icon(a0),d0    ; Get icon number
             beq.s     .Exit
             movea.l   Iconstats_ptr,a0
             subq.w    #1,d0                ; Get icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    0(a0,d0.w),d0
             btst.l    #7,d0                ; Way blocked ?
             bra       .Exit
.Next:       lea.l     VData_length(a0),a0  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             moveq.l   #0,d0                ; Zero
.Exit:       movem.l   (sp)+,d0/d6/d7/a0
             rts       

;*****************************************************************************
; [ Any size unmasked MIRRORED block-put routine (for 3D map) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d6 - Width in columns (.w)
;        d7 - Height in pixels (.w)
;        a0 - Pointer to block (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Blot_mirrored_unmasked_block:               
             movem.l   d2-d7/a0-a2,-(sp)
             jsr       Coord_convert        ; Calculate screen pointer
             move.w    d6,d3                ; (Add width x 8 - 8)
             lsl.w     #3,d3
             add.w     d3,d2
             lea.l     -8(a6,d2.w),a1
             moveq.l   #0,d2                ; Clear register
             subq.w    #1,d7                ; DBRA corrections
             subq.w    #1,d6
.Loop_1:     movea.l   a1,a2
             move.w    d6,d5
.Loop_2:     move.b    (a0)+,d2             ; Display line
             move.b    .Reverse_tab(pc,d2.w),1(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),0(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),3(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),2(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),5(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),4(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),7(a2)
             move.b    (a0)+,d2
             move.b    .Reverse_tab(pc,d2.w),6(a2)
             subq.l    #8,a2                ; Next column
             dbra      d5,.Loop_2
             lea.l     160(a1),a1           ; Next line
             dbra      d7,.Loop_1
             movem.l   (sp)+,d2-d7/a0-a2
             rts       

.Reverse_tab:          .DC.b 0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240,8,136,72,200,40,168,104,232,24,152,88,216
             .DC.b 56,184,120,248,4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244,12,140,76,204,44,172,108
             .DC.b 236,28,156,92,220,60,188,124,252,2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242,10,138
             .DC.b 74,202,42,170,106,234,26,154,90,218,58,186,122,250,6,134,70,198,38,166,102,230,22,150,86,214,54
             .DC.b 182,118,246,14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254,1,129,65,193,33,161,97,225
             .DC.b 17,145,81,209,49,177,113,241,9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249,5,133,69,197
             .DC.b 37,165,101,229,21,149,85,213,53,181,117,245,13,141,77,205,45,173,109,237,29,157,93,221,61,189,125
             .DC.b 253,3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243,11,139,75,203,43,171,107,235,27,155
             .DC.b 91,219,59,187,123,251,7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247,15,143,79,207,47
             .DC.b 175,111,239,31,159,95,223,63,191,127,255
             .EVEN 

;*****************************************************************************
; [ Prepare 3D map ]
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
Prepare_3D_map:        
             movem.l   d0/d1/d7/a0-a3,-(sp)
; ------------- Load datafiles ---------------------------------------
             lea.l     Labdata_filename,a0  ; Load LAB_DATA file
             move.w    Labdatafile_nr(a5),d0
             jsr       Load_subfile
             movea.l   a0,a3                ; Store pointer
             lea.l     2(a0),a2             ; Protect pointer
             lea.l     Labblock_ptrs,a1     ; Load LABBLOCK files
             moveq.l   #0,d7                ; Load number of lab blocks
             move.b    (a2)+,d7
             bne.s     .Ok
.Error:      ERROR     "[ Prepare_3D_map ] : Error in LAB_DATA !!!"
             bra       .Exit
.Ok:         subq.w    #1,d7                ; DBRA correction
             move.w    d7,Nr_labblocks      ; Store
.Loop:       lea.l     Labblock_filename,a0 ; Load LABBLOCK file
             moveq.l   #0,d0
             move.b    (a2)+,d0
             jsr       Load_subfile
             move.l    a0,(a1)+             ; Store pointer
             dbra      d7,.Loop
             addq.l    #3,a2                ; Skip irrelevant bytes
             lea.l     Backgrnd_filename,a1 ; Load BACKGRND files
             movea.l   a1,a0
             move.b    (a2)+,d0
             jsr       Load_subfile
             move.l    a0,Ceiling_ptr       ; Store pointer
             movea.l   a1,a0
             move.b    (a2)+,d0
             jsr       Load_subfile
             move.l    a0,Floor_ptr         ; Store pointer
             addq.l    #1,a2                ; Skip irrelevant byte
             lea.l     Colpall_filename,a0  ; Load COL_PALL file
             moveq.l   #0,d0
             move.b    (a2)+,d0
             jsr       Load_subfile
             move.l    a0,Colpall_ptrs      ; Store pointer
             movea.l   a3,a0                ; Free memory
             jsr       Free_memory
             jsr       Init_maptexts        ; Map texts
; ------------- Calculate variables ----------------------------------
             lea.l     Max_block_num(a5),a0 ; Get number of blocks
             moveq.l   #0,d7
             move.b    (a0)+,d7
             move.l    a0,Iconstats_ptr     ; Store
             adda.w    d7,a0
             adda.w    d7,a0
             adda.w    d7,a0
             adda.w    d7,a0
             move.l    a0,INB_ptr           ; Store
             adda.w    d7,a0
             move.l    a0,OUH_ptr           ; Store
             adda.w    d7,a0
             move.l    a0,Lab_IC_ptr        ; Store
             adda.w    d7,a0
             move.l    a0,Map_pointer       ; Store
             moveq.l   #0,d0                ; Get & store map's width
             move.b    Map_width(a5),d0
             move.w    d0,Width_of_map
             moveq.l   #0,d1                ; Get & store map's height
             move.b    Map_height(a5),d1
             move.w    d1,Height_of_map
             mulu.w    d0,d1                ; Calculate & store map's size
             move.w    d1,Size_of_map
             move.b    #M3_animspeed,Anim_speed   ; Set animation speed
             move.b    #M3_animspeed,Anim_count
             move.w    #12,Anim_bias
             move.w    Map_nr,d7            ; Modify map
             movea.l   Mapd_ptr,a0
             jsr       Make_modifications
             jsr       Init_automap         ; Load/create automap
             jsr       Update_automap
.Exit:       movem.l   (sp)+,d0/d1/d7/a0-a3
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Cut_table_3D:          .DC.b -1,-3,1,-3,0,-3      ; North
             .DC.b -1,-2,1,-2,0,-2,-1,-1,1,-1,0,-1
             .DC.b -1,0,1,0,0,0
             .DC.b 3,-1,3,1,3,0             ; East
             .DC.b 2,-1,2,1,2,0,1,-1,1,1,1,0
             .DC.b 0,-1,0,1,0,0
             .DC.b 1,3,-1,3,0,3             ; South
             .DC.b 1,2,-1,2,0,2,1,1,-1,1,0,1
             .DC.b 1,0,-1,0,0,0
             .DC.b -3,1,-3,-1,-3,0          ; West
             .DC.b -2,1,-2,-1,-2,0,-1,1,-1,-1,-1,0
             .DC.b 0,1,0,-1,0,0
             .EVEN 

M3_CIL:      .DC.b 44,39,43,42,7,41,16,40,49      ; 3D map movement icons
             .EVEN 
             .DC.l D3_turnleft,D3_forward,D3_turnright
             .DC.l D3_left,Zzz,D3_right
             .DC.l D3_fullturnleft,D3_back,D3_fullturnright

             .BSS 
Nr_labblocks:          .DS.w 1              ; Number of lab-blocks
INB_ptr:     .DS.l 1   ; Pointers to map data
OUH_ptr:     .DS.l 1
Lab_IC_ptr:  .DS.l 1
Map_buffer_3D:         .DS.b 12             ; Map buffer
Persons_buf_3D:        .DS.b 12             ; Persons buffer
Hash_buffer_3D:        .DS.w 12             ; Hash buffer

             .SECTION 5,DATA
Labdata_filename:      .DC.b 5,'LAB_DATA.AMB',0
Labblock_filename:     .DC.b 6,'LABBLOCK.AMB',0
Backgrnd_filename:     .DC.b 7,'BACKGRND.AMB',0
Colpall_filename:      .DC.b 8,'COL_PALL.AMB',0

             .SECTION 6,BSS 
Labblock_ptrs:         .DS.l 50             ; Maximum numbers
Ceiling_ptr: .DS.l 1
Floor_ptr:   .DS.l 1
Colpall_ptrs:          .DS.l 1

             .SECTION 7,DATA
; Layout 5 : 3D map, 2nd layer
Lay5_c1:     .DC.w Topleft_X,Topleft_X+143,Topleft_Y,Topleft_Y+143    ; Map area
             .DC.b 2
             .EVEN 
             .DC.l Control_area,0           ; Link to control icons

             .END 
















