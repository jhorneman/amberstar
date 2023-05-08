
; Character handling
; Written by J.Horneman
; Start : 2-5-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "Straight light moving and removing
;     SHARPNESS of the colour sun shine
;      Straight light searching all the meanings
;       Of the song"
;   Heart Of The Sunrise, Yes, 1972

; Notes :
;   - Even though the number of characters pro map is a constant, to change
;     it one also has to adjust the offsets in [Init_persons].

Max_chars    = 24      ; Maximum number of characters pro map

             .TEXT 
;*****************************************************************************
; [ Initialize persons ]
; All registers are restored
;*****************************************************************************
Init_persons:          
             movem.l   d0/d6/d7/a0-a3,-(sp)
             lea.l     CD-3,a0              ; Get pointer to CD array
             move.w    Map_nr,d0            ; Get map number x 3
             add.w     d0,d0
             add.w     Map_nr,d0
             adda.w    d0,a0
             moveq.l   #1,d0                ; Get value from CD array
             and.b     3(a0),d0
             lsl.w     #8,d0
             move.b    2(a0),d0
             swap.w    d0
             move.b    1(a0),d0
             lsl.w     #8,d0
             move.b    (a0),d0
             lsr.l     #1,d0
             move.l    d0,CD_value          ; Store
             movea.l   Mapd_ptr,a0          ; Get data from map
             move.w    Max_steps(a0),d6
             move.w    d6,Length_of_day
             add.w     d6,d6
             movea.l   Map_pointer,a2
             adda.w    Size_of_map,a2       ; Skip underlay
             adda.w    Size_of_map,a2       ; Skip overlay
             cmpi.b    #2,Current_map_type  ; Skip third layer if 2D
             bpl.s     .3D_map
             adda.w    Size_of_map,a2
.3D_map:     lea.l     Char_data(a0),a0
             lea.l     VChar_data,a1        ; Pointer to virtual chardata
             moveq.l   #0,d7                ; Character index is zero

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to char data (.l)
;  a1 - Pointer to virtual char data (.l)
;  a2 - Pointer to char position data (.l)
;  d6 - Max steps x 2 (.w)
;  d7 - Character index (.w)

.Loop:       lea.l     0(a0,d7.w),a3
             move.w    0(a3,d7.w),d0        ; Any character there ?
             move.w    d0,(a1)
             beq       .Next
             move.b    48(a3),VChar_icon(a1)      ; Copy data
             move.b    72(a3),VChar_move(a1)
             move.b    120(a3),VChar_day(a1)
             move.b    144(a3),VChar_month(a1)
             move.w    #0,VPathlen(a1)      ; Clear data
             move.b    96(a3),d0            ; Get character stats
             move.b    d0,VChar_stats(a1)   ; Copy
             btst      #0,d0                ; Monster or person ?
             bne.s     .No_path
             btst      #1,d0                ; Path or random ?
             bne.s     .No_path
             move.l    a2,VPath_ptr(a1)     ; Store pointer
             adda.w    d6,a2                ; Skip
             bra.s     .Next
.No_path:    moveq.l   #0,d0                ; Copy start position
             move.b    (a2)+,d0
             move.w    d0,VChar_X(a1)
             moveq.l   #0,d0
             move.b    (a2)+,d0
             move.w    d0,VChar_Y(a1)
.Next:       lea.l     VData_length(a1),a1  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             movem.l   (sp)+,d0/d6/d7/a0-a3
             rts       

;*****************************************************************************
; [ Clear persons buffer ]
; All registers are restored
;*****************************************************************************
Clear_persons_buffer:  
             movem.l   d0/d7/a0,-(sp)
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             lea.l     Persons_buf,a0       ; Clear 2D persons buffer
             moveq.l   #0,d0
             moveq.l   #35-1,d7
.Loop:       move.l    d0,(a0)+
             dbra      d7,.Loop
             move.w    d0,(a0)+
             move.b    d0,(a0)+
             bra       .Exit
.3D_map:     lea.l     Persons_buf_3D,a0    ; Clear 3D persons buffer
             moveq.l   #0,d0
             move.l    d0,(a0)+
             move.l    d0,(a0)+
             move.l    d0,(a0)+
.Exit:       movem.l   (sp)+,d0/d7/a0
             rts       

;*****************************************************************************
; [ Handle characters (2D map) ]
; All registers are restored
;*****************************************************************************
TwoD_char_handler:     
             movem.l   d0-d7/a0-a2,-(sp)
             jsr       Clear_persons_buffer
             lea.l     Persons_buf,a0       ; Initialize registers
             lea.l     VChar_data,a1
             move.l    CD_value,d6
             moveq.l   #0,d7                ; Character index is zero

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to persons buffer (.l)
;  a1 - Pointer to virtual chardata (.l)
;  d6 - CD array value (.l)
;  d7 - Character index {0...Max_chars-1} (.w)

.Loop:       tst.w     (a1)                 ; Any character there ?
             beq       .Next
             btst      d7,d6                ; Not removed ?
             bne       .Next
             move.b    VChar_stats(a1),d0   ; Get character stats
             btst      #0,d0                ; Monster or person ?
             beq       .Person
             btst      #2,d0                ; Hunt or stay ?
             beq.s     .Hunt
             move.w    VChar_X(a1),d0       ; Get position of staying
             move.w    VChar_Y(a1),d1       ;  monster
             jsr       Battle_check
             bra       .Show
.Hunt:       jsr       Hunting_monster
             jsr       Battle_check
             bra       .Show
.Person:     btst      #3,d0                ; There all the time ?
             beq.s     .There
             moveq.l   #0,d1                ; Get day
             move.b    VChar_day(a1),d1
             cmp.w     Day,d1               ; Same ?
             bne       .Next
             move.b    VChar_month(a1),d1   ; Get month
             cmp.w     Month,d1             ; Same ?
             bne       .Next
.There:      btst      #1,d0                ; Path or random ?
             beq.s     .Path
.Random:     jsr       Random_person
             bra       .Show
.Path:       movea.l   VPath_ptr(a1),a2     ; Get pointer to path
             move.w    Current_step,d2      ; Get position
             moveq.l   #0,d0
             move.b    0(a2,d2.w),d0
             add.w     Length_of_day,d2
             moveq.l   #0,d1
             move.b    0(a2,d2.w),d1
             move.w    d0,VChar_X(a1)       ; Store coordinates !!!
             move.w    d1,VChar_Y(a1)
             cmpi.w    #6,d0                ; Show at all ?
             bne.s     .Show
             cmpi.w    #6,d1
             beq       .Next
.Show:       sub.w     Map_Xcoord,d0        ; Calculate buffer coordinates
             sub.w     Map_Ycoord,d1
             add.w     Mapbuf_X,d0
             add.w     Mapbuf_Y,d1
             addq.w    #1,d0
             addq.w    #1,d1
             cmpi.w    #12,d0               ; Clip
             bhi       .Next
             cmpi.w    #10,d1
             bhi       .Next
             mulu.w    #13,d1               ; Calculate buffer offset
             add.w     d0,d1
             lea.l     Overlay_buf,a2       ; Get overlay icon number
             moveq.l   #0,d0
             move.b    0(a2,d1.w),d0
             beq.s     .Normal              ; Is there an overlay ?
             move.w    d0,d2                ; Save icon number
             movea.l   Iconstats_ptr,a2     ; Get overlay icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    -4(a2,d0.w),d0
             btst.l    #3,d0                ; Icon change ?
             beq.s     .Normal
             lea.l     Overlay_buf,a2       ; Icon change
             addq.b    #1,d2
             move.b    d2,0(a2,d1.w)
             bra.s     .Next
.Normal:     move.b    VChar_icon(a1),0(a0,d1.w)  ; Normal
.Next:       lea.l     VData_length(a1),a1  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             sf        New_step             ; Clear flags
             sf        New_move
             movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Handle characters (3D map) ]
; All registers are restored
;*****************************************************************************
ThreeD_char_handler:   
             movem.l   d0-d7/a0-a2,-(sp)
             jsr       Clear_persons_buffer
             lea.l     VChar_data,a1        ; Initialize registers
             move.l    CD_value,d6
             moveq.l   #0,d7                ; Character index is zero

; ------------- REGISTER CONTENTS ------------------------------------
;  a1 - Pointer to virtual chardata (.l)
;  d6 - CD array value (.l)
;  d7 - Character index {0...Max_chars-1} (.w)

.Loop:       tst.w     (a1)                 ; Any character there ?
             beq       .Next
             btst      d7,d6                ; Not removed ?
             bne       .Next
             bclr      #2,VChar_flag(a1)    ; Don't show DEFAULT
             move.b    VChar_stats(a1),d0   ; Get character stats
             btst      #0,d0                ; Monster or person ?
             beq       .Person
             btst      #2,d0                ; Hunt or stay ?
             beq.s     .Hunt
             move.w    VChar_X(a1),d0       ; Get position of staying
             move.w    VChar_Y(a1),d1       ;  monster
             jsr       Battle_check
             bra       .Show
.Hunt:       jsr       Hunting_monster
             move.w    VChar_X(a1),d0       ; Get position of hunting
             move.w    VChar_Y(a1),d1       ;  monster
             jsr       Battle_check
             bra       .Show
.Person:     btst      #3,d0                ; There all the time ?
             beq.s     .There
             moveq.l   #0,d1                ; Get day
             move.b    VChar_day(a1),d1
             cmp.w     Day,d1               ; Same ?
             bne       .Next
             move.b    VChar_month(a1),d1   ; Get month
             cmp.w     Month,d1             ; Same ?
             bne       .Next
.There:      btst      #1,d0                ; Path or random ?
             beq.s     .Path
.Random:     jsr       Random_person
             bra       .Show
.Path:       movea.l   VPath_ptr(a1),a2     ; Get pointer to path
             move.w    Current_step,d2      ; Get position
             moveq.l   #0,d0
             move.b    0(a2,d2.w),d0
             add.w     Length_of_day,d2
             moveq.l   #0,d1
             move.b    0(a2,d2.w),d1
             cmpi.w    #6,d0                ; Show at all ?
             bne.s     .Ok
             cmpi.w    #6,d1
             beq.s     .Next
.Ok:         move.w    d0,VChar_X(a1)       ; Store coordinates
             move.w    d1,VChar_Y(a1)
.Show:       bset      #2,VChar_flag(a1)    ; Show
.Next:       lea.l     VData_length(a1),a1  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             sf        New_step             ; Clear flags
             sf        New_move
             .LOCAL 
; ------------- Put persons in buffer --------------------------------
             move.w    Map_Xcoord,d0        ; Get map coordinates
             move.w    Map_Ycoord,d1
             lea.l     Cut_table_3D,a1      ; Calculate cut-table pointer
             move.w    View_direction,d2    ;  Get view direction
             mulu.w    #24,d2
             adda.w    d2,a1
             lea.l     VChar_data,a0        ; Initialize registers
             lea.l     Persons_buf_3D,a2
             moveq.l   #12-1,d7
.Loop_1:     move.b    (a1)+,d2             ; Get relative coordinates
             ext.w     d2
             move.b    (a1)+,d3
             ext.w     d3
             add.w     d0,d2                ; Make absolute
             add.w     d1,d3
             movea.l   a0,a3                ; Copy pointer
             moveq.l   #0,d5                ; Character index is zero
.Loop_2:     tst.w     (a3)                 ; Any character there ?
             beq       .Next
             btst      d5,d6                ; Not removed ?
             bne       .Next
             btst      #2,VChar_flag(a3)    ; Show ?
             beq.s     .Next
             cmp.w     VChar_X(a3),d2       ; Correct position ?
             bne.s     .Next
             cmp.w     VChar_Y(a3),d3
             bne.s     .Next
             move.b    VChar_icon(a3),(a2)
             bra.s     .Next_2
.Next:       lea.l     VData_length(a3),a3  ; Next character
             addq.w    #1,d5
             cmpi.w    #Max_chars,d5
             bmi       .Loop_2
.Next_2:     addq.l    #1,a2                ; Next position
             dbra      d7,.Loop_1
             movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Hunting monster movement routine ]
;   IN : a1 - Pointer to virtual character data (.l)
;  OUT : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; Changed registers : d0,d1,d2,d3,d4,d5,d6
;*****************************************************************************
Hunting_monster:       
             movem.l   d2-d6,-(sp)
             move.w    VChar_X(a1),d0       ; Get position
             move.w    VChar_Y(a1),d1
             jsr       Check_line_of_sight  ; Check line of sight
             beq       .Visible
             tst.b     New_step             ; Update position ?
             beq       .Exit
             btst      #0,VChar_flag(a1)    ; Moving at random ?
             bne.s     .Not_random
             jsr       Random_person
             bra       .Exit
.Not_random: move.w    VDir(a1),d2          ; Get direction
             jsr       Move_character
             tst.w     d0                   ; X =< 0 ?
             ble.s     .No_move1
             cmp.w     Width_of_map,d0      ; X > Width ?
             bhi.s     .No_move1
             tst.w     d1                   ; Y =< 0 ?
             ble.s     .No_move1
             cmp.w     Height_of_map,d1     ; Y > Height ?
             bhi.s     .No_move1
             jsr       Character_movement_check
             beq       .Move
.No_move1:   bclr      #0,VChar_flag(a1)    ; Random movement
             move.w    #0,VPathlen(a1)      ; Force new path
             jsr       Random_person
             bra       .Exit
.Visible:    ori.b     #3,VChar_flag(a1)    ; Set bit 0 & 1
             tst.b     New_step             ; Update position ?
             bne.s     .Ok
             tst.b     New_move
             beq       .Exit
.Ok:         move.w    d0,d2                ; Duplicate coordinates
             move.w    d1,d3
             sub.w     Map_Xcoord,d2        ; Calculate dX & dY
             sub.w     Map_Ycoord,d3
             move.w    d2,d4
             bpl.s     .Pos1
             neg.w     d4
.Pos1:       move.w    d3,d5
             bpl.s     .Pos2
             neg.w     d5
.Pos2:       ext.l     d2                   ; Mega SGN function
             beq.s     .Zero1
             swap.w    d2
             bmi.s     .Zero1
             moveq.l   #1,d2
.Zero1:      ext.l     d3                   ; Mega SGN function
             beq.s     .Zero2
             swap.w    d3
             bmi.s     .Zero2
             moveq.l   #1,d3
.Zero2:      sub.w     d5,d4                ; dX - dY
             ext.l     d4                   ; Mega SGN function
             beq.s     .Zero3
             swap.w    d4
             bmi.s     .Zero3
             moveq.l   #1,d4
.Zero3:      neg.w     d2                   ; Invert
             neg.w     d3
             addq.w    #1,d2                ; Calculate index
             addq.w    #1,d3
             addq.w    #1,d4
             add.w     d3,d2
             add.w     d3,d3
             add.w     d3,d2
             move.w    d4,d3
             lsl.w     #3,d3
             add.w     d3,d2
             add.w     d4,d2
             add.w     d2,d2                ; Get direction priorities
             add.w     d2,d2
             move.l    .Dir_table(pc,d2.w),d2
             bmi       .Move
             move.w    d0,d4                ; Copy coordinates
             move.w    d1,d5
             rol.l     #8,d2                ; Get 1st direction
             tst.b     d2
             bmi.s     .No_move2
             jsr       Move_character       ; Try move
             jsr       Character_movement_check
             beq.s     .Move
             move.w    d4,d0                ; Restore coordinates
             move.w    d5,d1
             rol.l     #8,d2                ; Get 2nd direction
             tst.b     d2
             bmi.s     .No_move2
             jsr       Move_character       ; Try move
             jsr       Character_movement_check
             beq.s     .Move
             move.w    d4,d0                ; Restore coordinates
             move.w    d5,d1
             rol.l     #8,d2                ; Get 3rd direction
             tst.b     d2
             bmi.s     .No_move2
             jsr       Move_character       ; Try move
             jsr       Character_movement_check
             beq.s     .Move
.No_move2:   move.w    d4,d0                ; Restore coordinates
             move.w    d5,d1
             bra.s     .Exit
.Move:       move.w    d0,VChar_X(a1)       ; Store new coordinates
             move.w    d1,VChar_Y(a1)
             andi.w    #$00ff,d2            ; Store direction
             move.w    d2,VDir(a1)
.Exit:       movem.l   (sp)+,d2-d6
             rts       

.Dir_table:  .DC.l $00030100,$00030100,$00010300  ; dX < dY
             .DC.l $03000200,-1,$01000200
             .DC.l $02030100,$02010300,$02010300
             .DC.l $0003ff00,-1,$0001ff00   ; dX = dY
             .DC.l -1,-1,-1
             .DC.l $0203ff00,-1,$0201ff00
             .DC.l $03000200,$00030100,$01000200  ; dX > dY
             .DC.l $03000200,-1,$01000200
             .DC.l $03020000,$02030100,$01020000

;*****************************************************************************
; [ Random character movement routine ]
;   IN : a1 - Pointer to virtual character data (.l)
;  OUT : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; Changed registers : d0,d1
;*****************************************************************************
Random_person:         
             movem.l   d2/d7,-(sp)
             moveq.l   #4-1,d7
             tst.w     VPathlen(a1)         ; End of path ?
             bne.s     .Loop
             jsr       Choose_random_path   ; Choose new path
.Loop:       move.w    VChar_X(a1),d0       ; Get position
             move.w    VChar_Y(a1),d1
             tst.b     New_step             ; Update position ?
             beq       .Exit
             move.w    VDir(a1),d2          ; Update position
             jsr       Move_character
             jsr       Character_movement_check   ; Possible ?
             beq.s     .Move
             jsr       Choose_random_path   ; Choose new path
             dbra      d7,.Loop
             move.w    #0,VPathlen(a1)      ; End of path
             bra.s     .Exit
.Move:       subq.w    #1,VPathlen(a1)      ; Count down
             move.w    d0,VChar_X(a1)       ; Store new coordinates
             move.w    d1,VChar_Y(a1)
.Exit:       movem.l   (sp)+,d2/d7
             rts       

;*****************************************************************************
; [ Move a character ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        d2 - Direction {0,1,2,3} (.w)
; Changed registers : d0,d1
;*****************************************************************************
Move_character:        
             movem.l   d2/d3/a0,-(sp)
             lea.l     Dir_offset,a0
             andi.w    #$00ff,d2            ; Mask off rubbish
             add.w     d2,d2
             move.b    0(a0,d2.w),d3        ; X update
             ext.w     d3
             add.w     d3,d0
             move.b    1(a0,d2.w),d3        ; Y update
             ext.w     d3
             add.w     d3,d1
             movem.l   (sp)+,d2/d3/a0
             rts       

;*****************************************************************************
; [ Choose random path ]
;   IN : a1 - Pointer to virtual character data (.l)
; All registers are restored
;*****************************************************************************
Choose_random_path:    
             movem.l   d0-d2/a0,-(sp)
             jsr       Random               ; Choose random path length
             lsr.w     #1,d0
             moveq.l   #$3,d1
             and.w     d0,d1
             addq.w    #1,d1
             move.w    VDir(a1),d2          ; Get current direction
             addq.w    #1,d2                ; Rotate counter-clockwise
             andi.w    #$0003,d2
             jsr       Random               ; Make random full turn
             andi.w    #$0002,d0
             add.w     d0,d2
             andi.w    #$0003,d2
             move.w    d2,VDir(a1)          ; Store
             add.w     d2,d2                ; Check path length
             add.w     d2,d2
             movea.l   .Pathcheck(pc,d2.w),a0
             jsr       (a0)
             move.w    d1,VPathlen(a1)      ; Store
             movem.l   (sp)+,d0-d2/a0
             rts       

.Pathcheck:  .DC.l .Up,.Right,.Down,.Left

; Path check routines
;   IN : d1 - Path length (.w)
;        a1 - Pointer to virtual character data (.l)
; Changed registers : d0,d1

.Up:         move.w    VChar_Y(a1),d0       ; Check path length
             sub.w     d1,d0
             bmi.s     .Up_exit             ; Ok ?
             subq.w    #1,d0                ; Adjust
             add.w     d0,d1
.Up_exit:    rts       

.Right:      move.w    Width_of_map,d0      ; Check path length
             sub.w     VChar_X(a1),d0
             sub.w     d1,d0
             bpl.s     .Right_exit          ; Ok ?
             add.w     d0,d1                ; Adjust
.Right_exit: rts       

.Down:       move.w    Height_of_map,d0     ; Check path length
             sub.w     VChar_Y(a1),d0
             sub.w     d1,d0
             bpl.s     .Down_exit           ; Ok ?
             add.w     d0,d1                ; Adjust
.Down_exit:  rts       

.Left:       move.w    VChar_X(a1),d0       ; Check path length
             sub.w     d1,d0
             bmi.s     .Left_exit           ; Ok ?
             subq.w    #1,d0                ; Adjust
             add.w     d0,d1
.Left_exit:  rts       

;*****************************************************************************
; [ Check movement for characters ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        a1 - Pointer to virtual person data (.l)
;  OUT :     Zero - Movement possible
;        Non-zero - Movement impossible
; All registers are restored
;*****************************************************************************
Character_movement_check:                   
             movem.l   d0-d3/d6/d7/a0,-(sp)
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
             st        d3                   ; Set flag
             bra       .Exit
.Next:       lea.l     VData_length(a0),a0  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
; ------------- Check if movement is possible ------------------------
             moveq.l   #0,d2
             move.b    VChar_move(a1),d2    ; Get travel mode
             addq.w    #8,d2                ; Add 8
             moveq.l   #-1,d3               ; Zero flag off
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bmi.s     .2D_map
             jsr       Get_3D_icon_status   ; Get icon status
             btst.l    #7,d0                ; Way blocked ?
             sne       d3
             bne       .Exit
             btst.l    d2,d0                ; Way blocked for current
             seq       d3                   ; travel mode ?
             bra       .Exit
.2D_map:     subq.w    #1,d0                ; BASE 0 correction
             subq.w    #1,d1
             movea.l   Map_pointer,a0       ; Calculate map pointer
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             adda.w    d1,a0
             moveq.l   #0,d0                ; Get underlay icon number
             move.b    (a0),d0
             adda.w    Size_of_map,a0       ; Skip to overlay map
             moveq.l   #0,d1                ; Get overlay icon number
             move.b    (a0),d1
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
             movem.l   (sp)+,d0-d3/d6/d7/a0
             rts       

;*****************************************************************************
; [ Check monster's line of sight ]
;   IN : a1 - Pointer to virtual map data (.l)
;  OUT :     Zero - In line of sight
;        Non-zero - NOT in line of sight
; All registers are restored
; ATTENTION !!! The destination coordinates are (0,0) !!!
;*****************************************************************************
Check_line_of_sight:   
             movem.l   d0-d7/a0-a2,-(sp)
             tst.w     Spell_6_duration     ; Invisiblity on ?
             bne       .Exit
             movea.l   Iconstats_ptr,a2
             move.w    VChar_X(a1),d0       ; Calculate monster's
             move.w    VChar_Y(a1),d1       ; relative coordinates
             sub.w     Map_Xcoord,d0
             sub.w     Map_Ycoord,d1
             movea.l   Map_pointer,a0       ; Calculate pointer to
             move.w    Map_Ycoord,d2        ; party's map position
             subq.w    #1,d2
             mulu.w    Width_of_map,d2
             add.w     Map_Xcoord,d2
             lea.l     -1(a0,d2.w),a0
             lea.l     (a0),a1              ; Overlay map
             adda.w    Size_of_map,a1
             move.w    d0,d2                ; Mega SGN function
             ext.l     d2
             beq.s     .Zero1
             swap.w    d2
             bmi.s     .Zero1
             moveq.l   #1,d2
.Zero1:      move.w    d1,d3                ; Mega SGN function
             ext.l     d3
             beq.s     .Zero2
             swap.w    d3
             bmi.s     .Zero2
             moveq.l   #1,d3
.Zero2:      neg.w     d2                   ; Reverse
             neg.w     d3
             move.w    d0,d4                ; Calculate dX & dY
             move.w    d1,d5
             tst.w     d2
             bmi.s     .No_abs1
             neg.w     d4
.No_abs1:    tst.w     d3
             bmi.s     .No_abs2
             neg.w     d5
.No_abs2:    muls.w    Width_of_map,d3      ; Vertical offset
             muls.w    Width_of_map,d1      ; Calculate map offset
             add.w     d1,d0
             cmp.w     d5,d4                ; Dy > Dx ?
             bpl.s     .DxDy
             exg.l     d2,d3
             exg.l     d4,d5
.DxDy:       move.w    d4,d6                ; Initialize variable
             lsr.w     #1,d6
             move.w    d4,d7                ; Load counter
             subq.w    #1,d7                ; One less
             bmi.s     .End
             bra.s     .Entry
.Again:      moveq.l   #0,d1                ; Check if underlay blocks
             move.b    0(a0,d0.w),d1        ;  vision
             add.w     d1,d1
             add.w     d1,d1
             move.l    -4(a2,d1.w),d1
             btst      #1,d1
             bne.s     .Exit
             moveq.l   #0,d1                ; Check if overlay blocks
             move.b    0(a1,d0.w),d1        ;  vision
             beq.s     .Entry
             add.w     d1,d1
             add.w     d1,d1
             move.l    -4(a2,d1.w),d1
             btst      #1,d1
             bne.s     .Exit
.Entry:      add.w     d5,d6                ; Trace line
             cmp.w     d4,d6
             bmi.s     .Skip
             sub.w     d4,d6
             add.w     d3,d0                ; Update
.Skip:       add.w     d2,d0                ; Update
             dbra      d7,.Again            ; Next
.End:        moveq.l   #0,d0                ; Clear zero flag
.Exit:       movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Check for collision with monster ]
;   IN : d0 - Monster's X-coordinate (.w)
;        d1 - Monster's Y-coordinate (.w)
;        a1 - Pointer to virtual character data (.l)
; All registers are restored
;*****************************************************************************
Battle_check:          
             rts       

             cmpi.w    #5,Travel_mode       ; Bird mode ?
             bpl.w     .Exit
             cmp.w     Map_Xcoord,d0        ; X the same ?
             bne.s     .Exit
             cmp.w     Map_Ycoord,d1        ; Y the same ?
             bne.s     .Exit
             move.w    VChar_nr(a1),mongroup_nr   ; Set group number
             st        CombatReq            ; Activate requester
             st        Pause_Upd
.Exit:       rts       

;*****************************************************************************
; [ Combat requester module ]
;*****************************************************************************
CombatReq_ModInit:     
             sf        CombatReq            ; Clear flags
             sf        Party_advantage
             sf        Monster_advantage
; ------------- Pause display if in 3D map ---------------------------
             cmpi.b    #2,Current_map_type  ; 3D map ?
             bmi.s     .Go_on
             tst.b     Stygian              ; Can anything be seen ?
             bne.s     .Go_on
             cmpi.b    #2,Current_map_type  ; Dungeon or city ?
             bne.s     .City
             lea.l     D3_DisUpd,a0
             bra.s     .Continue
.City:       lea.l     C3_DisUpd,a0
.Continue:   moveq.l   #10-1,d7
.Loop:       jsr       (a0)
             jsr       Switch_screen
             dbra      d7,.Loop
             sf        Pause_Upd            ; Clear flag
.Go_on:      .LOCAL 
; ------------- Display combat requester -----------------------------
             moveq.l   #16,d0               ; Open a window
             moveq.l   #52,d1
             moveq.l   #18,d2
             moveq.l   #5,d3
             moveq.l   #1,d6
             lea.l     CombatReq_L1,a0
             jsr       Open_window
             move.w    d0,Window_handle
             Push      PA,CombatReq_PA
             moveq.l   #15,d0               ; Convert text
             move.w    Nr_of_chars,d2
             lea.l     Code0004Sys,a1
             jsr       Prepare_text_block
             movea.l   Off_screen,a6        ; Print text
             movea.l   Text_buffer,a0
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d7
             subq.w    #1,d7
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
             dbra      d7,.Loop
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #208,d0
             move.w    #52+48,d1
             lea.l     Control_icn+9216,a0
             jsr       Blot_unmasked_block
             move.w    #208+32,d0
             move.w    #52+48,d1
             lea.l     Control_icn+16896,a0
             jsr       Blot_unmasked_block
             Update_screen 
             movea.l   Text_buffer,a0       ; Remove text buffer
             jsr       Free_memory
             rts       

CombatReq_ModExit:     
             move.w    Window_handle,d0
             jsr       Close_window
             Pop       PA
             rts       

CombatYes:   tst.w     Spell_6_duration     ; Invisibility on ?
             beq.s     .Visible
             st        Party_advantage      ; Player advantage !!!
.Visible:    move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             jsr       Get_2D_icon_status
             tst.l     d1                   ; Any overlay ?
             beq.s     .Go_on
             btst.l    #5,d1                ; Underlay priority ?
             bne.s     .Go_on
             move.l    d1,d0                ; Check overlay
             bra.s     .Go_on
.3D_map:     jsr       Get_3D_icon_status
.Go_on:      moveq.l   #16,d1               ; Search
             moveq.l   #14-1,d7
.Loop:       btst      d1,d0                ; Set ?
             bne.s     .Found
             addq.w    #1,d1                ; Next
             dbra      d7,.Loop
             moveq.l   #16,d1               ; Default value
.Found:      subi.w    #16-1,d1             ; Set background number
             move.w    d1,comback_nr
             st        Battling             ; Do combat !
             move.w    #4,Spell_area_type
             jsr       Exit_display
             lea.l     Combat_Mod,a0
             jmp       Push_Module

CombatNo:    tst.w     Spell_6_duration     ; Invisibility on ?
             bne.s     .Done
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             bpl.s     .Exit
             movea.l   Current_active_char_data,a0
             move.w    Attr_3_normal(a0),d0
             add.w     Attr_3_normal_magic(a0),d0
             add.w     Attr_7_normal(a0),d0
             add.w     Attr_7_normal_magic(a0),d0
             tst.w     d0                   ; Boundary check
             bmi.s     .Exit
             cmpi.w    #150,d0
             bpl.s     .Exit
             move.w    d0,d1
             jsr       Random               ; Get {random} MOD 150
             lsr.w     #1,d0
             ext.l     d0
             divu.w    #150,d0
             swap.w    d0
             cmp.w     d0,d1                ; Probe
.Exit:       bmi.s     .Failed              ; Done it ?
.Done:       move.w    Old_Xcoord,Map_Xcoord      ; Restore coordinates
             move.w    Old_Ycoord,Map_Ycoord
             move.w    Old_mapbufX,Mapbuf_X
             move.w    Old_mapbufY,Mapbuf_Y
             Pop       Module
             bra.s     .Exit2
.Failed:     st        Monster_advantage    ; Monster advantage !!!
             jsr       CombatYes
.Exit2:      rts       

;*****************************************************************************
; These are the offsets for the virtual character data.
             .ABS 0
VChar_nr:    .DS.w 1   ; Number of CHARDATA.nnn
VChar_icon:  .DS.b 1   ; Icon number
VChar_move:  .DS.b 1   ; Travel mode
VChar_stats: .DS.b 1   ; Stats
VChar_day:   .DS.b 1   ; Day & month on which character is present
VChar_month: .DS.b 1   ; (if bit 3 of VChar_stats = 1)
VChar_flag:  .DS.b 1   ; Internal flags
             .EVEN 
VChar_X:     .DS.w 1   ; Current map position
VChar_Y:     .DS.w 1
VPath_ptr:   .DS.l 1   ; Pointer to path (if necessary)
VDir:        .DS.w 1   ; Direction & remaining (!) length of random path
VPathlen:    .DS.w 1
VData_length:          

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
CombatReq_PA:          .DC.w 16+16,52+16,256,48,15,2

             .BSS 
CD_value:    .DS.l 1
Length_of_day:         .DS.w 1
VChar_data:  .DS.b Max_chars*VData_length
             .EVEN 
CombatReq:   .DS.b 1
Pause_Upd:   .DS.b 1
Party_advantage:       .DS.b 1
Monster_advantage:     .DS.b 1
             .EVEN 

             .SECTION 7,DATA
; COMBAT REQUESTER : 1st layer
CombatReq_L1:          .DC.w 176,207,32,47  ; Combat icon
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 208,239,32,47            ; Exit icon
             .DC.b 2
             .EVEN 
             .DC.l 0,0


             .END 













