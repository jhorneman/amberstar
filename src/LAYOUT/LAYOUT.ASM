
; New layout routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 2-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - The [Show_layout] routine sadly has to access the screen directly,
;     i.e. without using the nucleus graphics routines.

Layout_1st_line        = 37                 ; First line where the layouts are displayed
Max_layouts  = 11      ; Maximum number of layouts
Nr_AutoIcons           = 10

             .TEXT 
;*****************************************************************************
; [ Automatic icon switching ]
; All registers are restored
;*****************************************************************************
AutoIcon_switch:       
             cmpi.w    #100,AutoIcon_timer  ; Is it time ?
             bmi       ExitAutoIcon
             clr.w     AutoIcon_timer       ; Reset timer
DoAutoIcon:  movem.l   d0-d3/d6/d7/a0-a3,-(sp)
             tst.b     AutoIcon_flag        ; Activated ?
             beq       .Exit
             lea.l     Chard_ptrs,a0        ; Initialize registers
             lea.l     Char_status_icons,a1
             lea.l     AutoIcon_counters,a3
             moveq.l   #6-1,d7
.Loop1:      tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next1
             movea.l   (a0),a2              ; Get body & mind conditions
             move.w    Body_conditions(a2),d1
             move.w    #$e000,d2            ; Character dead ?
             and.w     d1,d2
             bne.s     .Next1
             move.w    (a3),d2              ; Load counter
             addq.w    #1,d2                ; Increase
             cmpi.w    #Nr_AutoIcons,d2     ; Clip
             bmi.s     .Ok1
             subi.w    #Nr_AutoIcons,d2
.Ok1:        moveq.l   #Nr_AutoIcons-1,d6
.Loop2:      move.b    .Bit_table(pc,d2.w),d3     ; Condition set ?
             btst      d3,d1
             bne.s     .Do_it
             addq.w    #1,d2                ; Next condition
             cmpi.w    #Nr_AutoIcons,d2     ; Clip
             bmi.s     .Ok2
             subi.w    #Nr_AutoIcons,d2
.Ok2:        dbra      d6,.Loop2
             clr.b     (a1)                 ; No icon
             bra.s     .Next1
.Bit_table:  .DC.b 8,9,10,11,12,0,1,2,3,4   ; Bit numbers
             .EVEN 
.Do_it:      move.w    d2,(a3)
             addi.w    #10,d2               ; Calculate icon number
             move.b    d2,(a1)              ; Set icon
.Next1:      addq.l    #4,a0                ; Next character
             addq.l    #1,a1
             addq.l    #2,a3
             dbra      d7,.Loop1
.Exit:       movem.l   (sp)+,d0-d3/d6/d7/a0-a3
ExitAutoIcon:          rts                  

TimeAutoIcon:          addq.w               #1,AutoIcon_timer
             rts       

;*****************************************************************************
; [ Show updated status block ]
; Changed registers : d0,d1,d4,d5,d6,d7,a0,a1
;*****************************************************************************
Show_updated_status_block:                  
             tst.b     Updated              ; ANY ???
             beq       .Exit
             jsr       Mouse_off
             move.b    Updated,d4           ; Initialize registers
             moveq.l   #16,d0
             moveq.l   #1,d1
             moveq.l   #1,d5
             moveq.l   #3,d6
             moveq.l   #35,d7
             movea.l   Screen_base,a0
             movea.l   Off_screen,a1
.Loop:       btst      d5,d4                ; Updated ?
             beq.s     .Next
             jsr       Duplicate_block      ; Copy 48x35 area
.Next:       addi.w    #48,d0               ; Next character
             addq.w    #1,d5
             cmpi.w    #6,d5
             bls.s     .Loop
             clr.b     Updated              ; Clear flag
             jsr       Mouse_on
.Exit:       rts       

;*****************************************************************************
; [ Force character update ]
;   IN : d0 - Number of character {1...6} (.w)
; All registers are restored
;*****************************************************************************
Force_char_update:     
             movem.l   d0/a0,-(sp)
             lea.l     Shadow_data,a0       ; Clear shadow pointer to
             subq.w    #1,d0                ; character data
             mulu.w    #XSize,d0
             clr.l     0(a0,d0.w)
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Update status block ]
; All registers are restored
;*****************************************************************************
Update_status_block:   
             movem.l   d0-d7/a0-a4/a6,-(sp)
             lea.l     Shadow_data,a1       ; Initialize registers
             lea.l     Chard_ptrs,a2
             lea.l     Char_status_icons,a3
             movea.l   Off_screen,a6
; ------------- Handle change of active member -----------------------
             move.w    Active_member,d1     ; New active member ?
             cmp.w     XActive_member,d1
             beq.s     .Continue
             move.w    XActive_member,d0    ; Active member before ?
             beq.s     .Skip1
             subq.w    #1,d0                ; Force redraw of deactivated
             mulu.w    #XSize,d0            ; member
             clr.l     0(a1,d0.w)
.Skip1:      tst.w     d1                   ; Active member now ?
             beq.s     .Skip2
             move.w    d1,d0                ; Force redraw of activated
             subq.w    #1,d0                ; member
             mulu.w    #XSize,d0
             clr.l     0(a1,d0.w)
.Skip2:      move.w    d1,XActive_member    ; Update
; ------------- Update all party members -----------------------------
.Continue:   moveq.l   #48,d4
             moveq.l   #1,d5
.Loop:       tst.l     (a2)                 ; Any character there ?
             bne.s     .Not_empty
             tst.l     (a1)
             beq       .Next
             jsr       Erase_portrait       ; Erase portrait, icon & bars
             jsr       Erase_status_icon
             jsr       Erase_bars
             clr.l     (a1)                 ; Update
             bset      d5,Updated           ; SET FLAG
             bra       .Next
.Not_empty:  movea.l   (a2),a4              ; New character ?
             cmpa.l    (a1),a4
             beq       .Same_character
             move.l    a4,(a1)              ; Update
             jsr       Display_portrait     ; Draw portrait, icon & bars
             jsr       Update_status_icon
             jsr       Update_bars
             bset      d5,Updated           ; SET FLAG
             bra       .Next
.Same_character:       
             cmpi.b    #1,XStat_icon(a1)    ; Already dead ?
             beq.s     .Next
             move.w    Body_conditions(a4),d0     ; Dead now ?
             andi.w    #$e000,d0
             beq.s     .Not_dead
             move.b    #1,(a3)              ; Cross icon
             jsr       Display_portrait     ; Draw portrait & icon
             jsr       Update_status_icon
             jsr       Erase_bars
             bset      d5,Updated           ; SET FLAG
             bra.s     .Next
.Not_dead:   jsr       Update_status_icon   ; Draw icon & bars
             jsr       Update_bars
.Next:       lea.l     XSize(a1),a1         ; Next character
             addq.l    #4,a2
             addq.l    #1,a3
             addi.w    #48,d4
             addq.l    #1,d5
             cmpi.w    #6,d5
             bls       .Loop
             movem.l   (sp)+,d0-d7/a0-a4/a6
             rts       

;*****************************************************************************
; [ Display portrait ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        d5 - Current character number {1...6} (.w)
;        a4 - Pointer to character data (.l)
;        a6 - Screen base (.l)
; All registers are restored
; NOTE : - This routines assumes there IS a character.
;*****************************************************************************
Display_portrait:      
             movem.l   d0/d1/d6/d7/a0/a1,-(sp)
; ------------- Display portrait or skull ----------------------------
             lea.l     Portrait+6(a4),a0
             move.w    Body_conditions(a4),d0     ; Check if character is
             andi.w    #$e000,d0            ; deceased
             beq.s     .Not_dead
             lea.l     Skull_portrait,a0
.Not_dead:   moveq.l   #-32,d0
             add.w     d4,d0
             moveq.l   #1,d1                ; Display portrait
             moveq.l   #2,d6
             moveq.l   #34,d7
             jsr       Blot_unmasked_block
             moveq.l   #35,d1               ; Redraw bottom edge
             moveq.l   #1,d7
             lea.l     Topblk_bot,a0
             jsr       Blot_unmasked_block
; ------------- Print character's name -------------------------------
             lea.l     Char_name(a4),a0     ; Duplicate first five letters
             lea.l     Temp_name+4,a1       ; of character name
             moveq.l   #5-1,d7
.Loop3:      move.b    (a0)+,(a1)+
             dbeq      d7,.Loop3
             Push      PA,Status_PA
             addq.w    #2,d0                ; Set cursor
             moveq.l   #31,d1
             jsr       IG_Set_cursor
             moveq.l   #9,d0                ; Set ink
             cmp.w     Active_member,d5     ; Active character ?
             bne.s     .Snarl
             moveq.l   #8,d0
.Snarl:      lea.l     Temp_name,a0         ; Display character name
             move.b    d0,1(a0)
             jsr       IG_Print
             Pop       PA
             movem.l   (sp)+,d0/d1/d6/d7/a0/a1
             rts       

;*****************************************************************************
; [ Update status icon ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        d5 - Character number {1...6} (.w)
;        a1 - Pointer to shadow data (.l)
;        a3 - Pointer to status icon list (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Update_status_icon:    
             movem.l   d0-d2/a0,-(sp)
             move.b    (a3),d2              ; Check if icon has changed
             cmp.b     XStat_icon(a1),d2
             beq.s     .Exit
             move.b    d2,XStat_icon(a1)    ; Update
             jsr       Erase_status_icon    ; Erase previous icon
             move.w    d4,d0
             tst.b     d2                   ; Is there a new icon ?
             beq.s     .No_new
             moveq.l   #1,d1                ; Display new icon
             lea.l     Status_icn-128,a0
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block
.No_new:     bset      d5,Updated           ; SET FLAG
.Exit:       movem.l   (sp)+,d0-d2/a0
             rts       

;*****************************************************************************
; [ Update life & powerpoint bars ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        d5 - Character number {1...6} (.w)
;        a1 - Pointer to shadow data (.l)
;        a2 - Pointer to status icon list (.l)
;        a4 - Pointer to character data (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Update_bars: 
             movem.l   d0/d1/d6/d7/a0,-(sp)
; ------------- See if an update is necessary ------------------------
             move.w    Life_points_max(a4),d0     ; Check maximum Lp
             add.w     Life_points_max_magic(a4),d0
             cmp.w     XLP_max(a1),d0
             bne.s     .Redraw
             move.w    Life_points_normal(a4),d0  ; Check normal Lp
             cmp.w     XLP_norm(a1),d0
             bne.s     .Redraw
             move.w    Power_points_max(a4),d0    ; Check maximum Pp
             add.w     Power_points_max_magic(a4),d0
             cmp.w     XPP_max(a1),d0
             bne.s     .Redraw
             move.w    Power_points_normal(a4),d3 ; Check normal Pp
             cmp.w     XPP_norm(a1),d3
             beq       .Exit
.Redraw:     jsr       Erase_bars           ; Erase previous bars
             bset      d5,Updated           ; SET FLAG
; ------------- Update life-points bar -------------------------------
             move.w    d4,d0
             move.w    Life_points_max(a4),d6     ; Get maximum Lp
             add.w     Life_points_max_magic(a4),d6
             move.w    d6,XLP_max(a1)       ; Update
             beq.s     .Do_power
             move.w    Life_points_normal(a4),d7  ; Get normal Lp
             move.w    d7,XLP_norm(a1)
             beq       .Exit
             cmp.w     d6,d7                ; More as maximum ?
             bmi.s     .Less1
             moveq.l   #16,d7               ; Full bar
             bra.s     .Not_zero1
.Less1:      ext.l     d7                   ; Calculate height of bar
             lsl.l     #4,d7
             divu.w    d6,d7
             bne.s     .Not_zero1
             addq.l    #1,d7
.Not_zero1:  addq.l    #1,d7
             moveq.l   #35,d1               ; Draw life-points bar
             sub.w     d7,d1
             moveq.l   #1,d6
             lea.l     Red_bar,a0
             jsr       Blot_masked_block
; ------------- Update power points bar ------------------------------
.Do_power:   move.w    Power_points_max(a4),d6    ; Get maximum Pp
             add.w     Power_points_max_magic(a4),d6
             move.w    d6,XPP_max(a1)       ; Update
             beq.s     .Exit
             move.w    Power_points_normal(a4),d7 ; Get normal Pp
             move.w    d7,XPP_norm(a1)
             beq.s     .Exit
             cmp.w     d6,d7                ; More as maximum ?
             bmi.s     .Less2
             moveq.l   #16,d7               ; Full bar
             bra.s     .Not_zero2
.Less2:      ext.l     d7                   ; Calculate height of bar
             lsl.l     #4,d7
             divu.w    d6,d7
             bne.s     .Not_zero2
             addq.l    #1,d7
.Not_zero2:  addq.l    #1,d7
             moveq.l   #35,d1               ; Draw life-points bar
             sub.w     d7,d1
             moveq.l   #1,d6
             lea.l     Blue_bar,a0
             jsr       Blot_masked_block
.Exit:       movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ Erase portrait ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Erase_portrait:        
             movem.l   d0/d1/d6/d7/a0,-(sp)
             moveq.l   #-32,d0              ; Erase portrait
             add.w     d4,d0
             moveq.l   #1,d1
             moveq.l   #2,d6
             moveq.l   #34,d7
             lea.l     Void,a0
             jsr       Blot_unmasked_block
             moveq.l   #35,d1               ; Redraw bottom edge
             moveq.l   #1,d7
             lea.l     Topblk_bot,a0
             jsr       Blot_unmasked_block
             movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ Erase status icon ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Erase_status_icon:     
             movem.l   d0/d1/a0,-(sp)
             move.w    d4,d0                ; Erase status icon
             moveq.l   #1,d1
             lea.l     Topblk_mid+8,a0
             jsr       Put_unmasked_block
             movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Erase bars ]
;   IN : d4 - X-coordinate of left edge of status column (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Erase_bars:  
             movem.l   d0/d1/d6/d7/a0,-(sp)
             move.w    d4,d0                ; Erase bars
             moveq.l   #18,d1
             moveq.l   #1,d6
             moveq.l   #17,d7
             lea.l     Topblk_mid+144,a0
             jsr       Blot_unmasked_block
             movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ Display spell icons ]
; All registers are restored
;*****************************************************************************
Show_spells: 
             movem.l   d0-d3/d6/d7/a0/a1/a6,-(sp)
             lea.l     Daynight_icn+4864,a0
             lea.l     Spell_1_duration,a1
             movea.l   Off_screen,a6
             move.w    #208,d0              ; Clear window
             move.w    #49+64,d1
             move.w    #208+95,d2
             move.w    #128,d3
             moveq.l   #2,d6
             jsr       Draw_box
             moveq.l   #6-1,d7
.Loop:       tst.w     (a1)+                ; Spell active ?
             beq.s     .Next
             jsr       Put_unmasked_block   ; Show icon
.Next:       addi.w    #16,d0               ; Next icon
             lea.l     128(a0),a0
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d3/d6/d7/a0/a1/a6
             rts       

;*****************************************************************************
; [ Display special items ]
; All registers are restored
; NOTE : This routines does NOT handle the removing of the items !!!
;*****************************************************************************
Show_special_items:    
             movem.l   d0-d3/d6/d7/a0/a1/a3/a6,-(sp)
             movea.l   Off_screen,a6
; ------------- Handle Compass ---------------------------------------
             btst      #0,Special_item_flags+1    ; Compass present ?
             beq.s     .No_compass
             lea.l     Daynight_icn+2048,a0
             cmpi.b    #2,Current_map_type  ; 3D map ?
             bmi.s     .2D_map
             move.w    View_direction,d0    ; Select direction
             moveq.l   #9,d1
             lsl.w     d1,d0
             adda.w    d0,a0
.2D_map:     move.w    #208,d0              ; Display compass
             move.w    #49+16,d1
             moveq.l   #2,d6
             moveq.l   #32,d7
             jsr       Blot_unmasked_block
.No_compass: 
; ------------- Handle Amberstar -------------------------------------
             btst      #1,Special_item_flags+1    ; Amberstar present ?
             beq.s     .No_Amberstar
             move.w    #208+32,d0           ; Display Amberstar
             move.w    #49,d1
             moveq.l   #2,d6
             moveq.l   #32,d7
             lea.l     Daynight_icn+4096,a0
             jsr       Blot_unmasked_block
.No_Amberstar:         
; ------------- Handle Day/Night display  ----------------------------
             btst      #2,Special_item_flags+1    ; Day/night display present ?
             beq.s     .No_daynight
             lea.l     Daynight_icn,a0      ; Select according to time
             move.w    Hour,d0
             move.b    .Daynight_tab(pc,d0.w),d0
             moveq.l   #9,d1
             lsl.w     d1,d0
             adda.w    d0,a0
             move.w    #208+64,d0           ; Display day/night
             move.w    #49+16,d1
             moveq.l   #2,d6
             moveq.l   #32,d7
             jsr       Blot_unmasked_block
             bra.s     .No_daynight
.Daynight_tab:         
             .DC.b 0,0,0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,2
             .DC.b 3,3,0,0,0,0
.No_daynight:          
; ------------- Handle Windchain -------------------------------------
             btst      #3,Special_item_flags+1    ; Windchain present ?
             beq.s     .No_windchain
             move.w    #208+32,d0           ; Display Windchain
             move.w    #49+32,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             lea.l     Daynight_icn+4608,a0
             jsr       Blot_unmasked_block
.No_windchain:         
; ------------- Handle Coordinates -----------------------------------
             btst      #4,Special_item_flags+1    ; Coordinates present ?
             beq       .No_coordinates
             lea.l     Control_icn,a0       ; Erase area
             move.w    #208,d0
             move.w    #49,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             jsr       Blot_unmasked_block
             move.w    Map_Xcoord,d2        ; Load coordinates
             move.w    Map_Ycoord,d3
             cmpi.b    #1,Current_map_type  ; Wilderness ?
             bne.s     .No_wild
             move.w    World_X,d0           ; Adapt coordinates
             mulu.w    #Submap_width,d0
             add.w     d0,d2
             move.w    World_Y,d0
             mulu.w    #Submap_height,d0
             add.w     d0,d3
.No_wild:    moveq.l   #3,d7
             move.w    #208+2,d0            ; Set cursor
             move.w    #49+2,d1
             jsr       IG_Set_cursor
             move.w    d2,d0                ; Convert X-coordinate
             moveq.l   #"0",d1
             lea.l     .X_string,a0
             lea.l     6(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
             move.w    #208+2,d0            ; Set cursor
             move.w    #49+10,d1
             jsr       IG_Set_cursor
             move.w    d3,d0                ; Convert Y-coordinate
             moveq.l   #"0",d1
             lea.l     .Y_string,a0
             lea.l     2(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
.No_coordinates:       
; ------------- Handle Time ------------------------------------------
             btst      #5,Special_item_flags+1    ; Time present ?
             beq       .No_time
             lea.l     Control_icn,a0       ; Erase area
             move.w    #208+64,d0
             move.w    #49,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             jsr       Blot_unmasked_block
             move.w    #208+65,d0           ; Set cursor
             move.w    #49+5,d1
             jsr       IG_Set_cursor
             lea.l     Time_string,a0
             moveq.l   #"0",d1
             moveq.l   #2,d7
             move.w    Hour,d0              ; Convert hour
             lea.l     4(a0),a3
             jsr       RConvert_number
             move.w    Minute,d0            ; Convert minute
             lea.l     7(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
.No_time:    movem.l   (sp)+,d0-d3/d6/d7/a0/a1/a3/a6
             rts       

.X_string:   .DC.b 1,15,2,2                 ; Ink 15, Paper 2
             .DC.b "X:   ",0
.Y_string:   .DC.b "Y:   ",0
             .EVEN 

;*****************************************************************************
; [ Show layout ]
;   IN : d0 - Layout number (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Show_layout: 
             movem.l   d0-d7/a0-a2,-(sp)
             subq.w    #1,d0                ; BASE 0 correction
             cmpi.w    #Max_layouts+1,d0    ; Check for illegal input
             bmi.s     .No_error
             ERROR     "[ Show_layout ] : Illegal input !!!"
             bra       .Exit
.No_error:   lea.l     Layouts,a2           ; Calculate layout address
             mulu.w    #220,d0
             adda.w    d0,a2
             lea.l     Layout_icn,a1        ; Adress of layout blocks
; ------------- Display the first line of blocks ---------------------
; NOTE : The first 4 lines of each block are missing
             moveq.l   #0,d0                ; Start coordinates
             move.w    #Layout_1st_line,d1
             moveq.l   #20-1,d5
             moveq.l   #1,d6                ; Set width & height
             moveq.l   #12,d7
.Loop_1:     moveq.l   #0,d2                ; Get block number
             move.b    (a2)+,d2
             subq.w    #1,d2
             lea.l     32(a1),a0            ; Calculate block address
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Blot_unmasked_block
             addi.w    #16,d0               ; Next block
             dbra      d5,.Loop_1
; ------------- Display 9 normal lines of blocks ---------------------
             move.w    #Layout_1st_line+12,d1     ; Start Y-coordinate
             moveq.l   #9-1,d7
.Loop_2:     moveq.l   #0,d0                ; Start X-coordinate
             moveq.l   #20-1,d6
.Loop_3:     moveq.l   #0,d2                ; Get icon number
             move.b    (a2)+,d2
             subq.w    #1,d2
             movea.l   a1,a0                ; Calculate block address
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_unmasked_block   ; Put block
             addi.w    #16,d0               ; Next X
             dbra      d6,.Loop_3
             addi.w    #16,d1               ; Next Y
             dbra      d7,.Loop_2
; ------------- Display the last line of blocks ----------------------
; NOTE : The last 9 lines of each block are missing
             moveq.l   #0,d0                ; Start coordinates
             move.w    #193,d1
             moveq.l   #20-1,d5
             moveq.l   #1,d6                ; Set width & height
             moveq.l   #7,d7
.Loop_4:     moveq.l   #0,d2                ; Get block number
             move.b    (a2)+,d2
             subq.w    #1,d2
             movea.l   a1,a0                ; Calculate block address
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Blot_unmasked_block
             addi.w    #16,d0               ; Next block
             dbra      d5,.Loop_4
; ------------- Display the bottom corners ---------------------------
             lea.l     Bot_corners,a0       ; Graphics address
             lea.l     Bot_masks,a1
             move.w    #0,d0                ; Calculate 1st screen address
             move.w    #184,d1
             jsr       Coord_conv
             lea.l     0(a6,d2.w),a2
             moveq.l   #15,d7
.Loop_5:     movem.w   (a2),d0-d3           ; Load one line
             move.w    (a1)+,d4             ; Load mask
             not.w     d4
             and.w     d4,d0                ; Mask
             and.w     d4,d1
             and.w     d4,d2
             and.w     d4,d3
             or.w      (a0)+,d0
             or.w      (a0)+,d1
             or.w      (a0)+,d2
             or.w      (a0)+,d3
             movem.w   d0-d3,(a2)           ; Write one line
             lea.l     160(a2),a2           ; Next line
             dbra      d7,.Loop_5
             move.w    #304,d0              ; Calculate 2nd screen address
             move.w    #184,d1
             jsr       Coord_conv
             lea.l     0(a6,d2.w),a2
             moveq.l   #15,d7
.Loop_6:     movem.w   (a2),d0-d3           ; Load one line
             move.w    (a1)+,d4             ; Load mask
             not.w     d4
             and.w     d4,d0                ; Mask
             and.w     d4,d1
             and.w     d4,d2
             and.w     d4,d3
             or.w      (a0)+,d0
             or.w      (a0)+,d1
             or.w      (a0)+,d2
             or.w      (a0)+,d3
             movem.w   d0-d3,(a2)           ; Write one line
             lea.l     160(a2),a2           ; Next line
             dbra      d7,.Loop_6
.Exit:       movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Show status block ]
; All registers are restored
;*****************************************************************************
Show_status_block:     
             movem.l   d0/d1/d5-d7/a0/a6,-(sp)
             movea.l   Off_screen,a6        ; Load screen base
             moveq.l   #0,d0                ; Display left edge
             moveq.l   #0,d1
             moveq.l   #1,d6
             moveq.l   #36,d7
             lea.l     Topblk_left,a0
             jsr       Blot_unmasked_block
             moveq.l   #5,d5                ; Display middle parts
             lea.l     Topblk_mid,a0
.Loop_1:     addi.w    #48,d0
             jsr       Blot_unmasked_block
             dbra      d5,.Loop_1           ; Next
             addi.w    #16,d0               ; Display right edge
             lea.l     Topblk_right,a0
             jsr       Blot_unmasked_block
             moveq.l   #16,d0               ; Display top edges
             moveq.l   #5,d5
             moveq.l   #2,d6
             moveq.l   #1,d7
             lea.l     Topblk_top,a0
.Loop_2:     jsr       Blot_unmasked_block
             addi.w    #48,d0               ; Next
             dbra      d5,.Loop_2
             moveq.l   #16,d0               ; Display bottom edges
             moveq.l   #35,d1
             moveq.l   #5,d5
             lea.l     Topblk_bot,a0
.Loop_3:     jsr       Blot_unmasked_block
             addi.w    #48,d0               ; Next
             dbra      d5,.Loop_3
             movem.l   (sp)+,d0/d1/d5-d7/a0/a6
             rts       

;*****************************************************************************
; [ Show control icons ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Show_control_icons:    
             movem.l   d0-d7/a0-a2,-(sp)
             sf        Control_icon_flag    ; Deactivate control icons
             jsr       Feedb_off            ; Feedback off
             move.w    #0,Draw_Cicon
             move.w    #0,Erase_Cicon
             lea.l     Control_icn,a1       ; Initialize registers
             movea.l   Control_list_ptr,a2
             move.w    #145,d1
             move.w    #208,d2
             moveq.l   #3-1,d5
             moveq.l   #2,d6
             moveq.l   #16,d7
.Loop1:      move.w    d2,d0
             moveq.l   #3-1,d4
.Loop2:      moveq.l   #$7f,d3              ; Load icon number
             and.b     (a2),d3              ; Copy icon
             lsl.w     #8,d3
             lea.l     0(a1,d3.w),a0
             jsr       Blot_unmasked_block
             btst.b    #7,(a2)+             ; Disabled icon ?
             beq.s     .Next
             lea.l     Chequered,a0         ; Overlay chequered icon
             jsr       Blot_masked_block
.Next:       addi.w    #32,d0               ; Next X
             dbra      d4,.Loop2
             addi.w    #16,d1               ; Next Y
             dbra      d5,.Loop1
.Continue:   st        Control_icon_flag    ; Activate control icons
             movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Control icon interaction ] MOUSE EVENT
;   IN : d0 - Event ID (.l)
; No registers are restored
;*****************************************************************************
Do_control_icons:      
             tst.b     Control_icon_flag    ; Control icons active ?
             beq.s     .Exit
             andi.w    #$00ff,d0            ; Mask off rubbish
             movea.l   Control_list_ptr,a0  ; Any icon there ?
             move.b    -1(a0,d0.w),d1
             cmpi.b    #56,d1               ; Empty icon ?
             beq.s     .Exit
             btst      #7,d1                ; Disabled ?
             bne.s     .Exit
             move.w    d0,Draw_Cicon        ; Feedback
             lsl.w     #2,d0                ; Get function address
             move.l    10-4(a0,d0.w),d0
             beq.s     .Exit
             movea.l   d0,a0                ; Execute function
             jsr       (a0)
.Exit:       rts       

; [ Display command feedback ]
; All registers are restored
Feedb_on:    
             movem.l   d0-d2/d6/d7/a0/a1/a6,-(sp)
             move.w    Draw_Cicon,d2        ; Draw ?
             move.w    d2,Erase_Cicon       ; Erase !
             beq.s     .Exit
             lea.l     Icon_pos-4,a1        ; Get icon coordinates
             add.w     d2,d2
             add.w     d2,d2
             adda.w    d2,a1
             move.w    (a1)+,d0
             move.w    (a1)+,d1
             movea.l   On_screen,a6         ; Get screen base
             move.l    a6,Feedback_screen
             moveq.l   #2,d6                ; Set width & height
             moveq.l   #16,d7
             lea.l     Feedback,a0
             jsr       Blot_masked_block    ; Display block
.Exit:       movem.l   (sp)+,d0-d2/d6/d7/a0/a1/a6
             rts       

; [ Erase command feedback ]
; All registers are restored
Feedb_off:   
             movem.l   d0-d3/d6/d7/a0/a1/a6,-(sp)
             move.w    Erase_Cicon,d2       ; Erase ?
             beq.s     .Exit
             move.w    d2,d3
             lea.l     Icon_pos-4,a1        ; Get icon coordinates
             add.w     d2,d2
             add.w     d2,d2
             adda.w    d2,a1
             move.w    (a1)+,d0
             move.w    (a1)+,d1
             lea.l     Control_icn,a0       ; Get icon address
             movea.l   Control_list_ptr,a1
             moveq.l   #$7f,d2
             and.b     -1(a1,d3.w),d2
             lsl.w     #8,d2
             adda.w    d2,a0
             moveq.l   #2,d6                ; Set width & height
             moveq.l   #16,d7
             movea.l   Feedback_screen,a6   ; Get screen base
             jsr       Blot_unmasked_block
.Exit:       movem.l   (sp)+,d0-d3/d6/d7/a0/a1/a6
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .ABS 0
             .DS.l 1   ; Pointer to character data
XLP_norm:    .DS.w 1   ; Life points normal
XLP_max:     .DS.w 1   ; Life points maximum
XPP_norm:    .DS.w 1   ; Power points normal
XPP_max:     .DS.w 1   ; Power points maximum
XStat_icon:  .DS.b 1   ; Status icon
             .EVEN 
XSize:       

             .DATA 
Erase_icon:  .DC.b 71,72,73,76,78,77,74,91,75
             .DCB.b 12,78
             .EVEN 
Status_PA:   .DC.w 0,0,319,34,9,0
Icon_pos:    .DC.w 208,145,240,145,272,145  ; Screen coordinates
             .DC.w 208,161,240,161,272,161  ; for each control icon
             .DC.w 208,177,240,177,272,177
Temp_name:   .DC.b 1,0,2,0                  ; Ink ?, Paper 0
             .DC.b "     ",0
Time_string: .DC.b 1,15,2,2                 ; Ink 15, Paper 2
             .DC.b "  :  ",0
AutoIcon_flag:         .DC.b -1
             .EVEN 

             .BSS 
Control_icon_flag:     .DS.b 1
             .EVEN 
Feedback_screen:       .DS.l 1
Draw_Cicon:  .DS.w 1
Erase_Cicon: .DS.w 1
Control_list_ptr:      .DS.l 1

XActive_member:        .DS.w 1
Shadow_data: .DS.b 6*XSize                  ; Shadow character data
Updated:     .DS.b 1
             .EVEN 
AutoIcon_counters:     .DS.w 6              ; AutoIcon switching variables
AutoIcon_timer:        .DS.w 1


             .END 










