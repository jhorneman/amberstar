
; Normal icon actions
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-6-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "Machine Messiah
;    The mindless
;    Search for a higher
;    Controller
;    Take me to the fire
;    And hold me
;    Show me the strength of your
;    Singular eye"
;   Machine Messiah, Yes, 1980

; NOTES :
;   - [ Display_automap_icon ] must be adapted for the AMIGA !!!


SleepingIcon           = 148
Default_length         = 11126

             .TEXT 
;*****************************************************************************
; [ Eye action routine ]
; All registers are restored
;*****************************************************************************
Eye_spy:     
             movem.l   d0/a0/a5,-(sp)
; ------------- Check current map type -------------------------------
             cmpi.b    #2,Current_map_type
             bpl       .3D_map
; ------------- 2D map -----------------------------------------------
             jsr       Make_area_EYE
             Wait_4_unclick 
             lea.l     Eye2D_Mod,a0         ; Copy display vector
             movea.l   Module_sp,a1
             move.l    (a1),(a0)
             jsr       Push_Module
             bra       .Exit
; ------------- Get map coordinates in front of the player -----------
.3D_map:     lea.l     Dir_offset,a0
             move.w    View_direction,d2
             add.w     d2,d2
             move.b    0(a0,d2.w),d0        ; X offset
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    1(a0,d2.w),d1        ; Y offset
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Handle_visible_events
.Exit:       movem.l   (sp)+,d0/a0/a5
             rts       

;*****************************************************************************
; [ Respond to left click in 2D map eye-mode ]
; No registers are restored
;*****************************************************************************
Eye_clicked: 
             move.w    Mouse_X,d0           ; Determine map coordinates
             move.w    Mouse_Y,d1
             subi.w    #16,d0
             subi.w    #49,d1
             lsr.w     #4,d0
             lsr.w     #4,d1
             sub.w     Mapbuf_X,d0
             sub.w     Mapbuf_Y,d1
             add.w     Map_Xcoord,d0
             add.w     Map_Ycoord,d1
             jsr       Eye_exit
             Wait_4_unclick 
             jmp       Handle_visible_events

;*****************************************************************************
; [ Respond to right click in 2D map eye-mode ]
; All registers are restored
;*****************************************************************************
Eye_exit:    
             Pop       Module
             Pop       MA
             rts       

;*****************************************************************************
; [ Create a mouse area around the party (2D map - eye action) ]
; Changed registers : d0,a0
;*****************************************************************************
Make_area_EYE:         
             lea.l     Made_area,a0         ; Calculate mouse area
             move.w    Mapbuf_X,d0          ;  X
             subq.w    #1,d0
             lsl.w     #4,d0
             addi.w    #16+7,d0
             move.w    d0,(a0)+
             addi.w    #48-15,d0
             move.w    d0,(a0)+
             move.w    Mapbuf_Y,d0          ;  Y
             subq.w    #1,d0
             lsl.w     #4,d0
             addi.w    #49+7,d0
             move.w    d0,(a0)+
             addi.w    #48-15,d0
             move.w    d0,(a0)+
             subq.l    #8,a0                ; Set area
             jsr       Push_MA
             rts       

;*****************************************************************************
; [ Create a mouse area around the party (2D map - mouth action) ]
; Changed registers : d0,d1,a0
;*****************************************************************************
Make_area_MOUTH:       
             lea.l     Made_area,a0         ; Calculate mouse area
             move.w    Mapbuf_X,d0          ;  X
             subq.w    #1,d0
             lsl.w     #4,d0
             addi.w    #7,d0
             move.w    d0,d1
             cmpi.w    #16,d0               ; Left Ok ?
             bpl.s     .Left_Ok
             move.w    #16+7,d0
.Left_Ok:    move.w    d0,(a0)+
             addi.w    #80-15,d1
             cmpi.w    #16+176,d1           ; Right Ok ?
             bmi.s     .Right_Ok
             move.w    #16+176-8,d1
.Right_Ok:   move.w    d1,(a0)+
             move.w    Mapbuf_Y,d0          ;  Y
             subq.w    #1,d0
             lsl.w     #4,d0
             addi.w    #49-9,d0
             move.w    d0,d1
             cmpi.w    #49,d0               ; Top Ok ?
             bpl.s     .Top_Ok
             move.w    #49+7,d0
.Top_Ok:     move.w    d0,(a0)+
             addi.w    #80-15,d1
             cmpi.w    #49+144,d1           ; Bottom Ok ?
             bmi.s     .Bottom_Ok
             move.w    #49+144-8,d1
.Bottom_Ok:  move.w    d1,(a0)+
             subq.l    #8,a0                ; Set area
             jsr       Push_MA
             rts       

;*****************************************************************************
; [ Handle visible events ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Handle_visible_events: 
             movem.l   d0/d1/a0/a5,-(sp)
             jsr       Find_event           ; Find event
             beq       .Exit                ; Any there ?
             moveq.l   #0,d0                ; Get event type
             move.b    (a5),d0
             cmpi.w    #3,d0                ; [ Show_pictxt ] ?
             bne.s     .No_showpictxt
             st        Eye_flag             ; Handle it
             jsr       Handle_event
             sf        Eye_flag
             bra       .Exit
.No_showpictxt:        
             cmpi.w    #4,d0                ; [ Item_found ] ?
             bne.s     .No_itemfound
             move.w    Map_Xcoord,Old_Xcoord      ; Save old coordinates
             move.w    Map_Ycoord,Old_Ycoord
             move.w    Mapbuf_X,Old_mapbufX
             move.w    Mapbuf_Y,Old_mapbufY
             jsr       Handle_event         ; Handle it
             bra       .Exit
.No_itemfound:         
             cmpi.b    #14,d0               ; [ Riddle_mouth ]
             bne.s     .No_riddlemouth
             jsr       Handle_event         ; Handle it
.No_riddlemouth:       
             move.b    .Mess_tab-1(pc,d0.w),d1    ; Visible event ?
             bmi.s     .Exit
             movea.l   Current_active_char_data,a0          ; Found ?
             moveq.l   #0,d0
             move.b    Skill_8(a0),d0
             add.w     Skill_8_normal_magic(a0),d0
             jsr       Probe
             bmi.s     .Exit
             move.w    d1,WText_nr          ; Print text
             move.l    #Code0003Sys,Textfile_ptr
             Push      Module,TxtW_Mod
.Exit:       movem.l   (sp)+,d0/d1/a0/a5
             rts       

.Mess_tab:   .DC.b -1,-1,-1,-1,14,-1,-1,15,16,17,17,17,18,-1,-1,-1,-1,-1,-1,-1
             .EVEN 

;*****************************************************************************
; [ Mouth action routine ]
; All registers are restored
;*****************************************************************************
Mouth_action:          
             movem.l   d0/d1/a0,-(sp)
             cmpi.b    #2,Current_map_type  ; Check current map type
             bpl       .3D_map
             jsr       Make_area_MOUTH      ; 2D map
             Wait_4_unclick 
             lea.l     Mouth2D_Mod,a0       ; Copy display vector
             movea.l   Module_sp,a1
             move.l    (a1),(a0)
             jsr       Push_Module
             bra       .Exit
.3D_map:     move.w    Map_Xcoord,d0        ; 3D map
             move.w    Map_Ycoord,d1
             jsr       Talk
.Exit:       movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Respond to left click in 2D map mouth-mode ]
; No registers are restored
;*****************************************************************************
Mouth_clicked:         
             move.w    Mouse_X,d0           ; Determine map coordinates
             move.w    Mouse_Y,d1
             subi.w    #16,d0
             subi.w    #49,d1
             lsr.w     #4,d0
             lsr.w     #4,d1
             sub.w     Mapbuf_X,d0
             sub.w     Mapbuf_Y,d1
             add.w     Map_Xcoord,d0
             add.w     Map_Ycoord,d1
             jsr       Eye_exit
             Wait_4_unclick 
             jmp       Talk

;*****************************************************************************
; [ Talk to person (if any) ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
; All registers are restored
;*****************************************************************************
Talk:        
             movem.l   d2/d6/d7/a0/a1,-(sp)
             lea.l     VChar_data,a0        ; Initialize registers
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
             tst.b     Current_map_type     ; 2D city ?
             bne       .Go_on
             lea.l     Overlay_buf,a1       ; Calculate map-buffer address
             move.w    d0,d2
             sub.w     Map_Xcoord,d2
             add.w     Mapbuf_X,d2
             addq.w    #1,d2
             adda.w    d2,a1
             move.w    d1,d2
             sub.w     Map_Ycoord,d2
             add.w     Mapbuf_Y,d2
             addq.w    #1,d2
             muls.w    #13,d2
             adda.w    d2,a1
             cmpi.b    #SleepingIcon,(a1)   ; In the Land of Nod ?
             bne.s     .Go_on
             move.w    #10,WText_nr         ; Display text
             move.l    #Code0006Sys,Textfile_ptr
             Push      Module,TxtW_Mod
             bra       .Exit
.Go_on:      move.b    VChar_stats(a0),d2   ; Get status bits
             btst      #0,d2                ; Person or monster ?
             bne       .Exit
             btst      #4,d2                ; Short or normal dialogue ?
             bne       .Short
             movea.l   Current_active_char_data,a1
             move.w    VChar_nr(a0),d0      ; Load character data
             move.w    d0,Dialogue_char_nr
             lea.l     Chard_filename,a0
             jsr       Load_subfile
             move.l    a0,Dialogue_chard_ptr
             move.w    d7,Dialogue_VChar_index
             move.b    Learned_languages(a0),d0   ; Que ?
             and.b     Learned_languages(a1),d0
             bne.s     .Capito
             jsr       Free_memory          ; No comprendo, signor !
             move.w    #1,WText_nr
             move.l    #Code0006Sys,Textfile_ptr
             Push      Module,TxtW_Mod
             bra       .Exit
.Capito:     jsr       Exit_display         ; Deep conversation
             Push      Module,Dialogue_Mod
             bra       .Exit
.Short:      move.w    (a0),WText_nr        ; Small talk
             move.l    Maptext_ptr,Textfile_ptr
             Push      Module,TxtW_Mod
             bra       .Exit
.Next:       lea.l     VData_length(a0),a0  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             cmp.w     Map_Xcoord,d0        ; Talking to yourself again ?
             bne.s     .Exit
             cmp.w     Map_Ycoord,d1
             bne.s     .Exit
             move.l    #Code0008Sys,Textfile_ptr  ; Show text
             move.w    #9,WText_nr
             Push      Module,TxtW_Mod
.Exit:       movem.l   (sp)+,d2/d6/d7/a0/a1
             rts       

;*****************************************************************************
; [ Dialogue module ]
;*****************************************************************************
Dialogue_ModInit:      
             sf        Joined               ; Clear flag
             jsr       Set_interaction_ptrs
             movea.l   Dialogue_chard_ptr,a0      ; Store pointer to text
             lea.l     Character_text_start(a0),a0
             move.l    a0,Dialogue_text_ptr
             lea.l     Sold_slots,a0        ; Clear slots
             clr.l     (a0)+
             clr.l     (a0)+
             clr.l     (a0)
             jmp       Dialogue_DisInit     ; Display

; [ Set pointers to interaction data ]
; All registers are restored
Set_interaction_ptrs:  
             movem.l   d0/d7/a0/a1,-(sp)
             movea.l   Dialogue_chard_ptr,a0      ; Determine interaction set
             moveq.l   #0,d7
             moveq.l   #0,d0                ; Wants a quest ?
             move.b    Dialogue_quest(a0),d0
             beq.s     .First
             lea.l     Quest,a1             ; Quest solved ?
             move.w    d0,d1
             andi.w    #7,d1
             lsr.w     #3,d0
             btst      d1,0(a1,d0.w)
             beq.s     .First
             moveq.l   #1,d7                ; Yay! Second set!
.First:      lea.l     Action(a0),a1        ; Set pointers
             move.w    d7,d0
             mulu.w    #10,d0
             adda.w    d0,a1
             move.l    a1,Action_ptr
             lea.l     Act_dat(a0),a1
             adda.w    d0,a1
             adda.w    d0,a1
             move.l    a1,Act_dat_ptr
             lea.l     Result(a0),a1
             move.w    d7,d0
             mulu.w    #50,d0
             adda.w    d0,a1
             move.l    a1,Result_ptr
             lea.l     Res_dat1(a0),a1
             adda.w    d0,a1
             move.l    a1,Res_dat1_ptr
             lea.l     Res_dat2(a0),a1
             adda.w    d0,a1
             move.l    a1,Res_dat2_ptr
             lea.l     Res_dat3(a0),a1
             adda.w    d0,a1
             adda.w    d0,a1
             move.l    a1,Res_dat3_ptr
             movem.l   (sp)+,d0/d7/a0/a1
             rts       

Dialogue_ModExit:      
             tst.b     Joined               ; Did he/she/it join ?
             bne.s     .Skip
             movea.l   Dialogue_chard_ptr,a0      ; Free memory
             jsr       Free_memory
.Skip:       jmp       Dialogue_DisExit

Dialogue_DisInit:      
             SetMesMin                      16,63,176,Code0006Sys     ; Set parameters
             move.l    #Lay8_PlusMes,PlusMes_info
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             moveq.l   #8,d0                ; Show new layout
             jsr       Show_layout
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink
             moveq.l   #2,d0                ; Set paper
             jsr       IG_Set_paper
             moveq.l   #0,d0                ; To clear top word
             movea.l   Dialogue_chard_ptr,a1
; ------------- Display portrait -------------------------------------
             lea.l     Portrait+6(a1),a0    ; Display portrait
             move.w    #208,d0
             move.w    #49,d1
             moveq.l   #2,d6
             moveq.l   #34,d7
             jsr       Blot_unmasked_block
; ------------- Print character name ---------------------------------
             moveq.l   #1,d0                ; Set ink
             jsr       IG_Set_ink
             move.w    #208,d0
             move.w    #84,d1
             move.w    #96,d2
             lea.l     Char_name(a1),a0
             jsr       Print_centered_string
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink
; ------------- Print character sex ----------------------------------
             move.w    #208+34,d0           ; Set cursor
             move.w    #49+7,d1
             jsr       IG_Set_cursor
             move.b    Character_sex(a1),d0 ; Print character sex
             beq.s     .Male
             lea.l     Female_name,a0
             bra.s     .Cont
.Male:       lea.l     Male_name,a0
.Cont:       jsr       IG_Print
; ------------- Print character race ---------------------------------
             cmpi.b    #9,Character_race(a1)      ; Special or monster ?
             bpl       .No_class
             move.w    #208+34,d0           ; Set cursor
             move.w    #49,d1
             jsr       IG_Set_cursor
             lea.l     Race_dat+Race_names,a2
             moveq.l   #0,d0                ; Find race word
             move.b    Character_race(a1),d0
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print character race
             jsr       IG_Print
; ------------- Print character class --------------------------------
             tst.b     Character_class(a1)  ; ANY class ?
             beq.s     .No_class
             move.w    #208+34,d0           ; Set cursor
             move.w    #49+21,d1
             jsr       IG_Set_cursor
             lea.l     Class_dat+Class_names,a2
             moveq.l   #0,d0                ; Find class word
             move.b    Character_class(a1),d0
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             move.b    #" ",(a3)+
; ------------- Print character level (if any) -----------------------
             moveq.l   #0,d0                ; Convert character level
             move.b    Level_nr(a1),d0
             moveq.l   #2,d7
             jsr       LConvert_number
             lea.l     Line_buffer,a0
             jsr       IG_Print             ; Print character level
; ------------- Print character's age --------------------------------
.No_class:   move.w    #208+34,d0           ; Set cursor
             move.w    #49+14,d1
             jsr       IG_Set_cursor
             lea.l     Age_txt,a0           ; Print "AGE"
             jsr       IG_Print
             lea.l     Line_buffer,a0
             move.w    Attr_9_normal(a1),d0 ; Convert age
             moveq.l   #3,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print age
             .LOCAL 
; ------------- Rest of display --------------------------------------
             move.w    #208,d0              ; Display GOLD icon
             move.w    #113,d1
             lea.l     Layout_icn+9856,a0
             jsr       Put_unmasked_block
             lea.l     Objects_icn+12288,a0
             jsr       Put_masked_block
             addi.w    #48,d0               ; Display FOOD icon
             lea.l     Layout_icn+9856,a0
             jsr       Put_unmasked_block
             lea.l     Objects_icn+13952,a0
             jsr       Put_masked_block
             movea.l   Off_screen,a6        ; Show items
             jsr       Show_objects_LAY3
             lea.l     Dialogue_CIL,a0      ; Show control icons
             jsr       DialogueCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
; ------------- Fade in ----------------------------------------------
             lea.l     Lay8_target,a1
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay8_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay8_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
             lea.l     Hbl_Lay8_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

Dialogue_DisExit:      
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay8_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay8_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
             lea.l     Hbl_Lay8_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

Dialogue_DisUpd:       
             jsr       Update_status_block
             lea.l     Dialogue_CIL,a0      ; Update control icons
             lea.l     DialogueCIL_evaluate,a1
             jsr       Update_control_icons
; ------------- Display gold & food ----------------------------------
             movea.l   Current_active_char_data,a1
             movea.l   Off_screen,a6
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             move.w    Gold_coins(a1),d0    ; Convert gold
             moveq.l   #"0",d1
             moveq.l   #5,d7
             lea.l     GoldDis_text,a0
             movea.l   a0,a3
             jsr       RConvert_number
             move.w    #224,d0              ; Print gold
             move.w    #113+5,d1
             move.w    #32,d2
             jsr       Print_centered_string
             move.w    Food_rations(a1),d0  ; Convert food
             moveq.l   #"0",d1
             moveq.l   #4,d7
             lea.l     GoldDis_text+1,a0
             movea.l   a0,a3
             jsr       RConvert_number
             move.w    #272,d0              ; Print food
             move.w    #113+5,d1
             move.w    #32,d2
             jsr       Print_centered_string
             rts       

DialogueCIL_evaluate:  
             movem.l   d0/d7/a1/a2,-(sp)
; ------------- Enable all icons -------------------------------------
             movea.l   a0,a2                ; Enable all icons
             moveq.l   #9-1,d7
.Loop0:      bclr      #7,(a2)+
             dbra      d7,.Loop0
; ------------- All slots full ? -------------------------------------
             lea.l     Sold_slots,a1        ; Check slots
             move.b    (a1)+,d0
             moveq.l   #11-1,d7
.Loop1:      and.b     (a1)+,d0
             dbra      d7,.Loop1
             tst.b     d0                   ; Well ?
             beq.s     .Ok1
             bset      #7,2(a0)             ; Disable all
             bset      #7,3(a0)             ; EXCEPT {Drop item}
             bset      #7,4(a0)             ; EXCEPT {Transfer item}
             bset      #7,5(a0)
             bset      #7,6(a0)
             bset      #7,7(a0)
             bset      #7,8(a0)
             bra       .Ok6
; ------------- Any slots filled ? -----------------------------------
.Ok1:        lea.l     Sold_slots,a1        ; Check slots
             move.b    (a1)+,d0
             moveq.l   #11-1,d7
.Loop2:      or.b      (a1)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Well ?
             beq.s     .All_MT
             bset      #7,2(a0)             ; Disable {Exit}
             bra.s     .Ok2
.All_MT:     bset      #7,(a0)              ; Disable {Transfer item}
             bset      #7,1(a0)             ; Disable {Drop item}
; ------------- Any stuff in backpack ? ------------------------------
.Ok2:        movea.l   Current_active_char_data,a1
             lea.l     Inventory_1_place_counter(a1),a2
             move.b    (a2)+,d0
             moveq.l   #11-1,d7
.Loop3:      or.b      (a2)+,d0
             dbra      d7,.Loop3
             tst.b     d0                   ; Well ?
             bne.s     .Ok3
             bset      #7,3(a0)             ; Disable {Show item}
             bset      #7,6(a0)             ; Disable {Give item}
; ------------- Any gold ? -------------------------------------------
.Ok3:        tst.w     Gold_coins(a1)       ; Well ?
             bne.s     .Ok4
             bset      #7,7(a0)             ; Disable {Give gold}
; ------------- Any food ? -------------------------------------------
.Ok4:        tst.w     Food_rations(a1)     ; Well ?
             bne.s     .Ok5
             bset      #7,8(a0)             ; Disable {Give food}
; ------------- Party full ? -----------------------------------------
.Ok5:        cmpi.w    #6,Nr_members        ; Well ?
             bmi.s     .Ok6
             bset      #7,5(a0)             ; Disable {Join party}
; ------------- Did he/she/it join the group ? -----------------------
.Ok6:        tst.b     Joined               ; Well ?
             beq.s     .Ok7
             bset      #7,3(a0)             ; Disable all
             bset      #7,4(a0)             ; EXCEPT {Drop item}
             bset      #7,5(a0)             ; EXCEPT {Transfer item}
             bset      #7,6(a0)             ; EXCEPT {Exit}
             bset      #7,7(a0)
             bset      #7,8(a0)
.Ok7:        movem.l   (sp)+,d0/d7/a1/a2
             rts       

; ************* Drop item *********************************
DIA_Drop_item:         
             lea.l     DIADropItem_Mod,a0
             jmp       Push_Module

DIADropItem_DisInit:   
             Push      MA,Lay3_L2           ; Mouse in object area
             movea.l   Off_screen,a6        ; Print message {0,-}
             move.l    #Code0001Sys,Textfile_ptr
             MesMin    0
             Update_screen 
             Wait_4_unclick 
             rts       

Do_DIADropItem:        
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number
             lea.l     Sold_slots,a1        ; Get slot address
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       .Exit
             lea.l     Sold_data,a2         ; Get item data address
             mulu.w    #40,d0
             adda.w    d0,a2
             btst      #1,Item_stat_bits(a2)      ; Can it be dropped ?
             bne.s     .Droppable
             PlusMes   1                    ; Print message {1,+}
             move.l    #Code0006Sys,Textfile_ptr
             jmp       Pop_Module
.Droppable:  move.l    #Code0001Sys,Textfile_ptr  ; Are U sure ?
             move.w    #22,ReqText_nr
             move.l    #Really_drop_item,ReqDo_ptr
             Push      Module,Req_Mod
.Exit:       rts       

Really_drop_item:      
             move.b    Object_slot_number,d0      ; Get slot number
             ext.w     d0
             subq.w    #1,d0
             lea.l     Sold_slots,a1        ; Get slot address
             adda.w    d0,a1
             lea.l     Sold_data,a2         ; Get item data address
             mulu.w    #40,d0
             adda.w    d0,a2
             clr.b     (a1)                 ; Remove object
             movea.l   Current_active_char_data,a1
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a1)
             movea.l   Off_screen,a6        ; Update object display
             jsr       Show_objects_LAY3
             move.w    #16,d0               ; Erase object name
             move.w    #72,d1
             move.w    #16+176-1,d2
             move.w    #72+6,d3
             move.w    #2,d6
             jsr       Draw_box
             Update_screen 
             move.l    #Code0006Sys,Textfile_ptr
             jmp       Pop_Module

; ************* Exit dialogue *****************************
DIA_Exit:    
             Pop       Module               ; Quit dialogue
             jmp       Init_display

; ************* Ask word **********************************
DIA_Ask_word:          
             Wait_4_unclick 
             lea.l     WSelW_Mod,a0         ; Select a word
             move.l    #DIA_Check_answer,Return_ptr(a0)
             jsr       Push_Module
             rts       

DIA_Check_answer:      
             tst.b     No_word_entered      ; Any word entered ?
             bne       .Exit
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             move.w    Found_word,d1
             moveq.l   #10-1,d7
.Loop:       cmpi.b    #1,(a0)+             ; {Ask word} action ?
             bne.s     .Next
             cmp.w     (a1),d1              ; Right word ?
             bne.s     .Next
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next:       addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop
             PlusMes   3                    ; Print message {3,+}
.Exit:       Wait_4_unclick 
             rts       

; ************* Show item *********************************
DIA_Show_item:         
             Wait_4_unclick 
             lea.l     ShowItem_Mod,a0
             jmp       Push_Module

ShowItem_DisInit:      
             Push      PA,Lay8_PA
             Push      MA,L3_objects_area
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inventory_1_place_counter(a0),a1
             lea.l     Inv_data+360(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             HashMes   4                    ; Print message {4,#}
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

ShowItem_DisExit:      
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6        ; Show items
             jsr       Show_objects_LAY3
             jsr       Erase_text_window
             Update_screen 
             Pop       MA
             Pop       PA
             Wait_4_unclick 
             rts       

ShowItem_DisUpd:       
             jsr       Update_status_block
             jsr       Update_quantity_colours
             rts       

ShowItem_objselect:    
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq.s     .Exit
             move.b    d0,Object_slot_number
             ext.w     d0                   ; Calculate pointers to item
             subq.w    #1,d0                ; data
             movea.l   Itemslots_ptr,a1
             movea.l   Itemdata_ptr,a2
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             tst.b     (a1)                 ; Any item in this slot ?
             beq       .Exit
             move.w    Item_ID(a2),d1       ; Get ID
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             moveq.l   #10-1,d7
.Loop:       cmpi.b    #2,(a0)+             ; {Show item} action ?
             bne.s     .Next
             cmp.w     (a1),d1              ; Right item ?
             bne.s     .Next
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next:       addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop
             PlusMes   5                    ; Print message {5,+}
.Exit:       jmp       Pop_Module

; ************* Give gold *********************************
DIA_Give_gold:         
             movea.l   Off_screen,a6        ; Print message {6,-}
             move.l    #Code0001Sys,Textfile_ptr
             MesMin    6
             Update_screen 
             Wait_4_unclick 
             movea.l   Current_active_char_data,a0          ; Set parameters
             moveq.l   #0,d0
             move.w    Gold_coins(a0),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,DIATransGold_Mod    ; Requester
             rts       

DIATG_Return:          
             move.l    ItemW_nr,d1          ; Any coins ?
             beq       .Exit
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             moveq.l   #10-1,d7
.Loop:       cmpi.b    #4,(a0)+             ; {Give gold} action ?
             bne.s     .Next
             cmp.w     (a1),d1              ; Enough gold ?
             bmi.s     .No_way
             movea.l   Current_active_char_data,a0          ; Remove coins
             sub.w     d1,Gold_coins(a0)
             mulu.w    #Gold_weight,d1
             sub.l     d1,Weight_normal(a0)
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next:       addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop
.No_way:     move.l    #Code0006Sys,Textfile_ptr  ; Print message {7,+}
             PlusMes   7
.Exit:       move.l    #Code0006Sys,Textfile_ptr
             Wait_4_unclick 
             rts       

; ************* Transfer item *****************************
DIA_Transfer_item:     
             lea.l     TIDIA_Mod,a0
             jmp       Push_Module

TIDIA_DisInit:         
             Push      MA,Lay3_L2           ; Mouse in object area
             movea.l   Off_screen,a6        ; Print message {4,-}
             move.l    #Code0001Sys,Textfile_ptr
             MesMin    4
             Update_screen 
             Wait_4_unclick 
             rts       

Do_TIDIA:    
             tst.b     d0                   ; Any slot selected ?
             bne.s     .A_slot
.Exit:       jmp       Pop_Module
.A_slot:     ext.w     d0
             lea.l     Sold_slots-1,a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     .Exit
             lea.l     Sold_data,a2
             moveq.l   #40,d1
             mulu.w    d0,d1
             lea.l     -40(a2,d1.w),a2
             move.b    d0,Object_slot_number
             .LOCAL 
; ------------- Do the transfer --------------------------------------
             moveq.l   #0,d0                ; Scan for victims
             move.w    Weight(a2),d0
             btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .Single
             move.w    Item_ID(a2),d1
             bra.s     .Continue
.Single:     moveq.l   #-1,d1
.Continue:   suba.l    a0,a0
             jsr       Scan_4_transfer_victims
             bne.s     .Go                  ; Anyone interested ?
             PlusMes   5                    ; No, print message {5,+}
             Pop       Module
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             move.b    (a2),TIVS_Icon_nr    ; Select transfer victim
             move.l    #DIA_Do_TI,TIVS_Ptr
             lea.l     TIVS2_Mod,a0
             move.w    #24,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       rts       

; [ Transfer the item ]
;   IN : a0 - Pointer to victim's character data (.l)
DIA_Do_TI:   
             lea.l     Sold_slots,a2        ; Initialize registers
             lea.l     Sold_data,a3
             moveq.l   #0,d0
             move.b    Object_slot_number,d0
             subq.w    #1,d0
             adda.w    d0,a2
             mulu.w    #40,d0
             adda.w    d0,a3

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to victim's character data (.l)
;  a2 - Pointer to transferred object's slot (.l)
;  a3 - Pointer to transferred object's data (.l)

             btst      #2,Item_stat_bits(a3)      ; Multiple item ?
             beq       .Continue
; ------------- Search for a slot already containing this item -------
             lea.l     Inventory_1_place_counter(a0),a4
             lea.l     Inv_data+360(a0),a5
             move.w    Item_ID(a3),d0
             moveq.l   #12-1,d7
.Loop1:      tst.b     (a4)                 ; Anything there ?
             beq.s     .Next1
             cmp.w     Item_ID(a5),d0       ; Same item ?
             bne.s     .Next1
             cmpi.b    #99,(a4)             ; Not full ?
             bmi       .Do_it
.Next1:      addq.l    #1,a4
             lea.l     40(a5),a5
             dbra      d7,.Loop1
; ------------- Search for a free slot -------------------------------
.Continue:   lea.l     Inventory_1_place_counter(a0),a4
             lea.l     Inv_data+360(a0),a5
             moveq.l   #12-1,d7
.Loop2:      tst.b     (a4)                 ; Free slot ?
             beq.s     .Do_it
             addq.l    #1,a4
             lea.l     40(a5),a5
             dbra      d7,.Loop2
             bra       .Exit
; ------------- Transfer the item ------------------------------------
.Do_it:      moveq.l   #0,d2                ; Adjust weight
             move.w    Weight(a3),d2
             add.l     d2,Weight_normal(a0)
             addq.b    #1,(a4)              ; Fill slot
             moveq.l   #20-1,d7             ; Copy item data
.Loop3:      move.w    (a3)+,(a5)+
             dbra      d7,.Loop3
             lea.l     -40(a3),a3
             clr.b     (a2)                 ; Remove item
             movea.l   Off_screen,a6
             lea.l     Door_object_pos_list-4,a0  ; Erase object
             moveq.l   #0,d0
             move.b    Object_slot_number,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a0
             move.w    (a0)+,d0
             move.w    (a0)+,d1
             lea.l     Layout_icn+9856,a0
             jsr       Put_unmasked_block
             Update_screen 
             lea.l     Sold_slots,a0        ; Chest empty ?
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             Pop       Module               ; Exit !
             move.l    #Code0006Sys,Textfile_ptr
.Exit:       rts       

; ************* Give item *********************************
DIA_Give_item:         
             Wait_4_unclick 
             lea.l     GiveItem_Mod,a0
             jmp       Push_Module

GiveItem_DisInit:      
             Push      PA,Lay8_PA
             Push      MA,L3_objects_area
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inventory_1_place_counter(a0),a1
             lea.l     Inv_data+360(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             HashMes   6                    ; Print message {6,#}
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

GiveItem_objselect:    
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number
             ext.w     d0                   ; Calculate pointers to item
             subq.w    #1,d0                ; data
             movea.l   Itemslots_ptr,a3
             movea.l   Itemdata_ptr,a4
             adda.w    d0,a3
             mulu.w    #40,d0
             adda.w    d0,a4
             tst.b     (a3)                 ; Any item in this slot ?
             beq       .Exit
             move.w    Item_ID(a4),d1       ; Get ID
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             moveq.l   #10-1,d7
.Loop:       cmpi.b    #3,(a0)+             ; {Give item} action ?
             bne.s     .Next
             cmp.w     (a1),d1              ; Right item ?
             bne.s     .Next
             movea.l   Current_active_char_data,a0          ; Remove item
             subq.b    #1,(a3)
             move.w    Weight(a4),d2
             ext.l     d2
             sub.l     d2,Weight_normal(a0)
             movea.l   Off_screen,a6        ; Show items
             jsr       Show_objects_LAY3
             Update_screen 
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next:       addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop
             PlusMes   5                    ; Print message {5,+}
.Exit:       jmp       Pop_Module

; ************* Give food *********************************
DIA_Give_food:         
             movea.l   Off_screen,a6        ; Print message {6,-}
             move.l    #Code0001Sys,Textfile_ptr
             MesMin    7
             Update_screen 
             Wait_4_unclick 
             movea.l   Current_active_char_data,a0          ; Set parameters
             moveq.l   #0,d0
             move.w    Food_rations(a0),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,DIATransFood_Mod    ; Requester
             rts       

DIATF_Return:          
             move.l    ItemW_nr,d1          ; Any food ?
             beq       .Exit
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             moveq.l   #10-1,d7
.Loop:       cmpi.b    #5,(a0)+             ; {Give food} action ?
             bne.s     .Next
             cmp.w     (a1),d1              ; Enough food ?
             bmi.s     .No_way
             movea.l   Current_active_char_data,a0          ; Remove food
             sub.w     d1,Food_rations(a0)
             mulu.w    #Food_weight,d1
             sub.l     d1,Weight_normal(a0)
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next:       addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop
.No_way:     move.l    #Code0006Sys,Textfile_ptr  ; Print message {8,+}
             PlusMes   8
.Exit:       move.l    #Code0006Sys,Textfile_ptr
             Wait_4_unclick 
             rts       

; ************* Join party ********************************
DIA_Join_party:        
             Wait_4_unclick 
             movea.l   Dialogue_chard_ptr,a0
             moveq.l   #0,d0                ; Load chance
             move.b    Join_percentage_chance(a0),d0
             beq.s     .No                  ; At all ?
             cmpi.w    #100,d0              ; Absolutely ?
             beq.s     .Yes
             jsr       Probe
             bpl.s     .Yes
.No:         PlusMes   9                    ; Print message {9,+}
             rts       
.Yes:        lea.l     Chard_ptrs,a1        ; Find free slot
             moveq.l   #0,d0
             moveq.l   #6-1,d7
.Loop1:      tst.l     (a1)
             beq.s     .Found
             addq.l    #4,a1
             addq.w    #1,d0
             dbra      d7,.Loop1
             bra       .Exit
.Found:      move.l    a0,(a1)              ; Insert character
             move.w    Map_nr,d7            ; Store CD index
             subq.w    #1,d7
             mulu.w    #24,d7
             add.w     Dialogue_VChar_index,d7
             addq.w    #1,d7
             move.w    d7,Person_save_bit_pos(a0)
             lea.l     Member_1_nr,a0       ; Insert character in party data
             add.w     d0,d0
             move.w    Dialogue_char_nr,0(a0,d0.w)
             move.l    CD_value,d0          ; Set bit in internal CD bitlist
             move.w    Dialogue_VChar_index,d1
             bset      d1,d0
             move.l    d0,CD_value
             lea.l     CD,a0                ; Set bit in CD array
             move.w    d7,d0
             lsr.w     #3,d0
             adda.w    d0,a0
             andi.w    #7,d7
             bset      d7,(a0)
             addq.w    #1,Nr_members        ; Increase
             st        Joined               ; Set flag
             movea.l   Action_ptr,a0        ; Search for reaction
             movea.l   Act_dat_ptr,a1
             moveq.l   #0,d0
             moveq.l   #10-1,d7
.Loop2:      cmpi.b    #6,(a0)+             ; {Join} action ?
             bne.s     .Next2
             jsr       Do_results           ; Yay! Do it!
             bra.s     .Exit
.Next2:      addq.l    #1,d0                ; Next action
             addq.l    #2,a1
             dbra      d7,.Loop2
.Exit:       rts       

;*****************************************************************************
; [ Handle dialogue results ]
;   IN : d0 - Action number {0...9} (.w)
; All registers are restored
;*****************************************************************************
Do_results:  
             movem.l   d0/d7/a0-a4,-(sp)
             movea.l   Result_ptr,a0        ; Calculate pointers
             movea.l   Res_dat1_ptr,a1
             movea.l   Res_dat2_ptr,a2
             movea.l   Res_dat3_ptr,a3
             mulu.w    #5,d0
             adda.w    d0,a0
             adda.w    d0,a1
             adda.w    d0,a2
             adda.w    d0,a3
             adda.w    d0,a3
             moveq.l   #0,d0                ; Handle results
             moveq.l   #5-1,d7
.Loop:       move.b    (a0)+,d0             ; Last result ?
             beq.s     .Exit
             add.w     d0,d0                ; Get result address
             add.w     d0,d0
             movea.l   Results-4(pc,d0.w),a4
             movem.l   d0-d7/a0-a6,-(sp)    ; Execute result
             jsr       (a4)
             movem.l   (sp)+,d0-d7/a0-a6
             addq.l    #1,a1                ; Next result
             addq.l    #1,a2
             addq.l    #2,a3
             dbra      d7,.Loop
.Exit:       movem.l   (sp)+,d0/d7/a0-a4
             rts       

Results:     .DC.l Text_res,Word_res,Item_res,Gold_res,Food_res
             .DC.l Quest_res,Data_res

; [ Result routines ]
;   IN : a1 - Pointer to result data 1 (.l)
;        a2 - Pointer to result data 2 (.l)
;        a3 - Pointer to result data 3 (.l)
; No registers need be restored

; ************* Text result *******************************
Text_res:    
             Push      MA,Lay8_PlusMes
             Push      PA,Lay8_PA
             move.w    (a3),d0              ; Show text
             movea.l   Dialogue_text_ptr,a1
             jsr       Mr_Blue_Sky
             Pop       PA
             Pop       MA
             rts       

; ************* Word result *******************************
Word_res:    
             move.w    (a3),d0              ; Get word number
             move.w    d0,d1                ; Calculate bit & byte number
             andi.w    #7,d1
             lsr.w     #3,d0
             lea.l     WD,a0                ; Set bit in WD array
             bset      d1,0(a0,d0.w)
             rts       

; ************* Item result *******************************
Item_res:    
             movea.l   Dialogue_chard_ptr,a0      ; Get pointer to item data
             lea.l     Inv_data-40(a0),a0
             move.w    (a3),d0
             mulu.w    #40,d0
             adda.w    d0,a0
             lea.l     Sold_slots,a1        ; Search free slot
             moveq.l   #0,d1
             moveq.l   #12-1,d7
.Loop1:      tst.b     0(a1,d1.w)
             beq.s     .Found
             addq.l    #1,d1
             dbra      d7,.Loop1
             ERROR     "[ Item_res ] : Logical error ! Contact the game designer !"
             bra       .Exit
.Found:      move.b    #1,0(a1,d1.w)        ; Fill slot
             lea.l     Sold_data,a1         ; Get pointer to target data
             mulu.w    #40,d1
             adda.w    d1,a1
             moveq.l   #10-1,d7             ; Copy item data
.Loop2:      move.l    (a0)+,(a1)+
             dbra      d7,.Loop2
             movea.l   Off_screen,a6        ; Update items
             jsr       Show_objects_LAY3
             Update_screen 
.Exit:       rts       

; ************* Gold result *******************************
Gold_res:    
             move.w    (a3),d0              ; Divide gold
             jmp       Divide_gold

; ************* Food result *******************************
Food_res:    
             move.w    (a3),d0              ; Divide food
             jmp       Divide_food

; ************* Quest result ******************************
Quest_res:   
             move.w    (a3),d0              ; Get word number
             move.w    d0,d1                ; Calculate bit & byte number
             andi.w    #7,d1
             lsr.w     #3,d0
             lea.l     Quest,a0             ; Set bit in Quest array
             bset      d1,0(a0,d0.w)
             jsr       Set_interaction_ptrs ; Re-evaluate
             rts       

; ************* Data result *******************************
Data_res:    
             movea.l   Current_active_char_data,a0          ; Get address of
             move.b    (a1),d0              ; modified data
             ext.w     d0
             adda.w    d0,a0
             moveq.l   #0,d1                ; Get pointer to modifying
             move.b    (a2),d1              ; routine
             add.w     d1,d1
             add.w     d1,d1
             movea.l   .Modify_ptrs-4(pc,d1.w),a4
             jmp       (a4)                 ; Modify!

.Modify_ptrs:          .DC.l .Increase,.Decrease,.Bitclear,.Bitset,.Bitchange

.Increase:   move.w    (a3),d1              ; Increase
             ext.l     d1
             cmpi.w    #70,d0               ; Byte ?
             bpl.s     .No_byteI
             moveq.l   #0,d0                ; Modify byte
             move.b    (a0),d0
             add.w     d1,d0
             cmpi.w    #256,d0              ; Range check
             bmi.s     .Ok1I
             move.w    #255,d0
.Ok1I:       move.b    d0,(a0)
             bra       .ExitI
.No_byteI:   cmpi.w    #204,d0              ; Word ?
             bpl.s     .LongwordI
             moveq.l   #0,d0                ; Modify word
             move.w    (a0),d0
             add.w     d1,d0
             bvc.s     .Ok2I                ; Range check
             move.w    #$7fff,d0
.Ok2I:       move.w    d0,(a0)
             bra       .ExitI
.LongwordI:  move.l    (a0),d0              ; Modify longword
             add.l     d1,d0
             bvc.s     .Ok3I                ; Range check
             move.l    #$7fffffff,d0
.Ok3I:       move.l    d0,(a0)
.ExitI:      rts       

.Decrease:   move.w    (a3),d1              ; Decrease
             ext.l     d1
             cmpi.w    #70,d0               ; Byte ?
             bpl.s     .No_byteD
             moveq.l   #0,d0                ; Modify byte
             move.b    (a0),d0
             sub.b     d1,d0
             bpl.s     .Ok1D                ; Range check
             moveq.l   #0,d0
.Ok1D:       move.b    d0,(a0)
             bra       .ExitD
.No_byteD:   cmpi.w    #204,d0              ; Word ?
             bpl.s     .LongwordD
             moveq.l   #0,d0                ; Modify word
             move.w    (a0),d0
             sub.w     d1,d0
             bpl.s     .Ok2D                ; Range check
             moveq.l   #0,d0
.Ok2D:       move.w    d0,(a0)
             bra       .ExitD
.LongwordD:  move.l    (a0),d0              ; Modify longword
             sub.l     d1,d0
             bpl.s     .Ok3D                ; Range check
             moveq.l   #0,d0
.Ok3D:       move.l    d0,(a0)
.ExitD:      rts       

.Bitclear:   move.w    (a3),d1              ; Clear bit
             bclr      d1,(a0)
             rts       

.Bitset:     move.w    (a3),d1              ; Set bit
             bset      d1,(a0)
             rts       

.Bitchange:  move.w    (a3),d1              ; Change bit
             bchg      d1,(a0)
             rts       

;*****************************************************************************
Upd5_objname_print:    
             tst.b     Print_objname_flag   ; Print anything ?
             beq       .Exit
             lea.l     .Init_string(pc),a0  ; Set colours
             jsr       IG_Print
             move.w    Object_name_nr,d0    ; Get word
             beq       .Exit
             jsr       Get_word
             move.w    #16,d0               ; Erase previous text
             move.w    #72,d1
             move.w    #16+176-1,d2
             move.w    #72+6,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             move.w    #176,d2              ; Print word
             lea.l     Line_buffer,a0
             jsr       Print_centered_string
             subq.b    #1,Print_objname_flag      ; Count down
.Exit:       rts       

.Init_string:          .DC.b 1,15,2,-1,0
             .EVEN 

Upd5_objname_erase:    
             tst.b     Erase_objname_flag   ; Erase anything ?
             beq       .Exit
             move.w    #16,d0               ; Erase previous text
             move.w    #72,d1
             move.w    #16+176-1,d2
             move.w    #72+6,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             subq.b    #1,Erase_objname_flag      ; Count down
             clr.w     Object_name_nr
.Exit:       rts       

;*****************************************************************************
; [ Change travelmode ]
; All registers are restored
;*****************************************************************************
Change_travelmode:     
             movem.l   d0/d1/a0,-(sp)
             tst.w     Travel_mode          ; On foot now ?
             beq.s     .Up
             cmpi.w    #4,Travel_mode       ; Magic disk ?
             beq.s     .Skip
             cmpi.w    #6,Travel_mode       ; Super chicken ?
             beq.s     .Skip
             lea.l     Trans_T,a0           ; Seek free slot
             moveq.l   #30-1,d1
.Loop:       tst.b     0(a0,d1.w)           ; Any there ?
             bne.s     .Next
             move.w    Travel_mode,d0       ; Set travelmode
             move.b    d0,0(a0,d1.w)
             move.w    Map_Xcoord,d0        ; Set coordinates
             move.b    d0,30(a0,d1.w)
             move.w    Map_Ycoord,d0
             move.b    d0,60(a0,d1.w)
             lea.l     90(a0,d1.w),a0       ; Set map number
             move.w    Map_nr,0(a0,d1.w)
             bra.s     .Skip
.Next:       subq.w    #1,d1                ; Next
             bpl.s     .Loop
             ERROR     "[ Change_travel_mode ] : No slot free !!!"
             bra.s     .Exit
.Skip:       moveq.l   #0,d0                ; Back on foot
             jsr       Set_new_travel_mode
; Maybe new event
             beq.s     .Exit
.Up:         jsr       Seek_transport       ; Get on what ?
             lea.l     Trans_T,a0           ; Remove transport
             clr.b     0(a0,d1.w)
             jsr       Set_new_travel_mode  ; Do it !
.Exit:       Wait_4_unclick 
             movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Automapper ]
;*****************************************************************************
Automapper:  
             jsr       Exit_display
             Push      Module,Automap_Mod
             rts       

;*****************************************************************************
; Automapper module
;*****************************************************************************
Automap_DisUpd:        
             jsr       Update_status_block
             movea.l   Off_screen,a6
             move.w    Width_of_map,d5
             movea.l   Automapicon_ptr,a0   ; Calculate automap pointer
             move.w    Automap_Y,d0
             subq.w    #1,d0
             mulu.w    d5,d0
             add.w     Automap_X,d0
             subq.w    #1,d0
             adda.w    d0,a0
             moveq.l   #0,d1                ; Display automap
             moveq.l   #0,d2
             move.w    Automap_height,d7
             subq.w    #1,d7
.Loop1:      movea.l   a0,a1
             moveq.l   #0,d0
             move.w    Automap_width,d6
             subq.w    #1,d6
.Loop2:      move.b    (a1)+,d2             ; Display icon
             jsr       Display_automap_icon
             addq.w    #1,d0                ; Next
             dbra      d6,.Loop2
             addq.w    #1,d1
             adda.w    d5,a0
             dbra      d7,.Loop1
             rts       

Automap_ModInit:       
             lea.l     Automap_CIL,a0       ; Enable all icons
             moveq.l   #9-1,d7
.Loop:       bclr      #7,(a0)+
             dbra      d7,.Loop
             lea.l     -9(a0),a0
             move.w    #6,Automap_X         ; Set coordinates
             move.w    #6,Automap_Y
             move.w    #22,Automap_width    ; Set width & height
             move.w    #18,Automap_height
             move.w    Width_of_map,d0      ; Check width
             subi.w    #10,d0
             cmpi.w    #22,d0
             bpl.s     .Ok1
             move.w    d0,Automap_width
             bset      #7,(a0)              ; Disable horizontal icons
             bset      #7,2(a0)
             bset      #7,3(a0)
             bset      #7,5(a0)
             bset      #7,6(a0)
             bset      #7,8(a0)
             bra.s     .Go_on1
.Ok1:        move.w    Map_Xcoord,d0        ; Set X-coordinate
             subi.w    #10,d0
             cmpi.w    #6,d0
             bmi.s     .Go_on1
             moveq.l   #22+5,d1
             add.w     d0,d1
             cmp.w     Width_of_map,d1
             bmi.s     .Ok2
             move.w    Width_of_map,d0
             subi.w    #21+5,d0
.Ok2:        move.w    d0,Automap_X
.Go_on1:     move.w    Height_of_map,d0     ; Check height
             subi.w    #10,d0
             cmpi.w    #18,d0
             bpl.s     .Ok3
             move.w    d0,Automap_height
             bset      #7,0(a0)             ; Disable vertical icons
             bset      #7,1(a0)
             bset      #7,2(a0)
             bset      #7,6(a0)
             bset      #7,7(a0)
             bset      #7,8(a0)
             bra.s     .Go_on2
.Ok3:        move.w    Map_Ycoord,d0        ; Set Y-coordinate
             subi.w    #8,d0
             cmpi.w    #6,d0
             bmi.s     .Go_on2
             moveq.l   #18+5,d1
             add.w     d0,d1
             cmp.w     Height_of_map,d1
             bmi.s     .Ok4
             move.w    Height_of_map,d0
             subi.w    #17+5,d0
.Ok4:        move.w    d0,Automap_Y
.Go_on2:     .LOCAL 
             move.w    Size_of_map,d0       ; Make icon buffer
             ext.l     d0
             jsr       Allocate_memory
             move.l    a1,Automapicon_ptr
             movea.l   Automap_ptr,a0       ; Convert bitlist
             movea.l   Map_pointer,a2
             movea.l   Iconstats_ptr,a3
             movea.l   Mapd_ptr,a4
             lea.l     Event_data-10(a4),a4
             moveq.l   #0,d4
             moveq.l   #0,d5
             move.w    Size_of_map,d6
             move.w    d6,d7
             subq.w    #1,d7
.Loop:       moveq.l   #0,d0
             btst      d4,0(a0,d5.w)        ; Automapped ?
             beq       .Insert
             moveq.l   #0,d0                ; Any event here ?
             move.b    0(a2,d6.w),d0
             beq.s     .No_event
             mulu.w    #10,d0               ; Get event type
             move.b    0(a4,d0.w),d0
             ext.w     d0                   ; Icon for this one ?
             move.b    .EventIcon-1(pc,d0.w),d0
             bmi.s     .No_event
             ext.w     d0                   ; Yes!
             bra.s     .Insert
.EventIcon:  .DC.b 4,3,-1,5,-1,8,-1,-1,-1,-1
             .DC.b -1,-1,-1,6,-1,-1,-1,7,-1,3
             .EVEN 
.No_event:   moveq.l   #0,d0                ; Get block number
             move.b    (a2),d0
             beq       .Insert
             subq.w    #1,d0                ; Get icon status
             add.w     d0,d0
             add.w     d0,d0
             move.l    0(a3,d0.w),d0
             btst      #5,d0                ; Reverse effect ?
             beq.s     .No_rev
             bchg      #7,d0                ; Reverse !
.No_rev:     btst      #7,d0                ; Way blocked ?
             bne.s     .Blocked
.Empty:      moveq.l   #2,d0
             bra.s     .Insert
.Blocked:    moveq.l   #1,d0
.Insert:     move.b    d0,(a1)              ; Insert icon number
.Next:       addq.w    #1,d4                ; Next
             cmpi.w    #8,d4
             bmi.s     .Ok
             moveq.l   #0,d4
             addq.w    #1,d5
.Ok:         addq.l    #1,a1
             addq.l    #1,a2
             dbra      d7,.Loop
             movea.l   Automapicon_ptr,a0   ; Insert party
             move.w    Map_Ycoord,d0
             subq.w    #1,d0
             mulu.w    Width_of_map,d0
             add.w     Map_Xcoord,d0
             subq.w    #1,d0
             btst      #0,Special_item_flags+1    ; Compass present ?
             beq.s     .No_compass
             moveq.l   #10,d1
             add.w     View_direction,d1
             bra.s     .Go
.No_compass: moveq.l   #9,d1
.Go:         move.b    d1,0(a0,d0.w)
             move.w    d1,Party_automap_icon      ; Store
             jmp       Init_display

Automap_ModExit:       
             movea.l   Automapicon_ptr,a0   ; Return memory
             jsr       Free_memory
             jmp       Automap_DisExit

Automap_DisInit:       
             movea.l   Off_screen,a6
             moveq.l   #11,d0               ; Show new layout
             jsr       Show_layout
             movea.l   Mapd_ptr,a5          ; Print headline
             jsr       Print_headline
             move.w    #208,d0              ; Display automapper icons
             move.w    #49,d1
             moveq.l   #8-1,d5
             moveq.l   #1,d6
             moveq.l   #8,d7
             lea.l     Automap_icn+64,a0
.Loop:       jsr       Blot_unmasked_block
             addi.w    #9,d1                ; Next icon
             lea.l     64(a0),a0
             dbra      d5,.Loop
             .LOCAL 
             lea.l     Automap_icn,a0       ; Display party icon
             move.w    Party_automap_icon,d2
             lsl.w     #6,d2
             adda.w    d2,a0
             jsr       Blot_unmasked_block
             move.w    #208+8,d0            ; Remove black box
             move.w    #49,d1
             move.w    #208+15,d2
             move.w    #49+80,d3
             moveq.l   #2,d6
             jsr       Draw_box
             move.w    #208+14,d0           ; Display legend texts
             move.w    #49+1,d1
             move.w    #12,d2
             moveq.l   #9-1,d7
             lea.l     Line_buffer,a0
             lea.l     Code0006Sys,a1
.Loop:       jsr       IG_Set_cursor        ; Set cursor
             exg.l     d0,d2                ; Convert & print text
             jsr       Convert_text_line
             exg.l     d0,d2
             jsr       IG_Print
             addi.w    #9,d1                ; Next text
             addq.w    #1,d2
             dbra      d7,.Loop
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink
             moveq.l   #-1,d0               ; Set paper (transparent)
             jsr       IG_Set_paper
             moveq.l   #11,d0               ; Convert text
             jsr       Convert_text_line
             move.w    #208,d0              ; Print "LEGEND"
             move.w    #39,d1
             move.w    #96,d2
             lea.l     Line_buffer,a0
             jsr       Print_centered_string
             .LOCAL 
             move.l    #Automap_CIL,Control_list_ptr        ; Show control icons
             jsr       Show_control_icons
             Update_screen 
             lea.l     Control_area,a0      ; Set object branch
             jsr       Set_layout_data
             lea.l     Lay11_target,a1      ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay11_list,a0    ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay11_below,a0       ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay11_list,a0    ; Update palettes
             jsr       Update_HBL
             rts       

Automap_DisExit:       
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay11_list,a0    ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay11_below,a0       ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay11_list,a0    ; Update palettes
             jsr       Update_HBL
             rts       

; ************* Exit automapper ***************************
Automap_exit:          
             Pop       Module
             jmp       Init_display

;*****************************************************************************
; [ Automapper controls ]
;*****************************************************************************
Automap_up:  
             move.w    Automap_Y,d0
             subq.w    #1,d0
             cmpi.w    #6,d0
             bmi.s     .Exit
             move.w    d0,Automap_Y
.Exit:       rts       

Automap_left:          
             move.w    Automap_X,d0
             subq.w    #1,d0
             cmpi.w    #6,d0
             bmi.s     .Exit
             move.w    d0,Automap_X
.Exit:       rts       

Automap_right:         
             move.w    Automap_X,d0
             addq.w    #1,d0
             move.w    Width_of_map,d1
             subi.w    #25,d1
             cmp.w     d1,d0
             bpl.s     .Exit
             move.w    d0,Automap_X
.Exit:       rts       

Automap_down:          
             move.w    Automap_Y,d0
             addq.w    #1,d0
             move.w    Height_of_map,d1
             subi.w    #21,d1
             cmp.w     d1,d0
             bpl.s     .Exit
             move.w    d0,Automap_Y
.Exit:       rts       

Automap_upleft:        
             jsr       Automap_up
             jmp       Automap_left

Automap_upright:       
             jsr       Automap_up
             jmp       Automap_right

Automap_downleft:      
             jsr       Automap_down
             jmp       Automap_left

Automap_downright:     
             jsr       Automap_down
             jmp       Automap_right

;*****************************************************************************
; [ Display automapper icon ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number {0...13} (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_automap_icon:  
             movem.l   d0-d3/d7/a0/a1,-(sp)
             lea.l     Automap_icn,a0       ; Calculate graphics address
             lsl.w     #6,d2
             adda.w    d2,a0
             lsl.w     #3,d0                ; Convert coordinates
             addi.w    #16,d0
             lsl.w     #3,d1
             addi.w    #49,d1
             jsr       Coord_convert
             lea.l     0(a6,d2.w),a1
             tst.w     d3                   ; Left or right ?
             bne.s     .Right
             move.l    #$00ff00ff,d2        ; Display left
             moveq.l   #8-1,d7
.Loop1:      move.l    (a0)+,d0             ; Load one line
             move.l    (a0)+,d1
             and.l     d2,(a1)              ; Display
             or.l      d0,(a1)
             and.l     d2,4(a1)
             or.l      d1,4(a1)
             lea.l     160(a1),a1           ; Next line
             dbra      d7,.Loop1
             bra.s     .Exit
.Right:      move.l    #$ff00ff00,d2        ; Display right
             moveq.l   #8-1,d7
.Loop2:      move.l    (a0)+,d0             ; Load one line
             move.l    (a0)+,d1
             ror.l     d3,d0                ; Rotate
             ror.l     d3,d1
             and.l     d2,(a1)              ; Display
             or.l      d0,(a1)
             and.l     d2,4(a1)
             or.l      d1,4(a1)
             lea.l     160(a1),a1           ; Next line
             dbra      d7,.Loop2
.Exit:       movem.l   (sp)+,d0-d3/d7/a0/a1
             rts       

;*****************************************************************************
; [ Initialize automap ]
; All registers are restored
;*****************************************************************************
Init_automap:          
             movem.l   d0/a0,-(sp)
             lea.l     Automap_filename,a0  ; Load automap
             move.w    Map_nr,d0
             jsr       Load_subfile
             move.l    a0,Automap_ptr
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Exit automap ]
; All registers are restored
;*****************************************************************************
Exit_automap:          
             movem.l   d0/a0/a1,-(sp)
             lea.l     Automap_filename,a0
             movea.l   Automap_ptr,a1
             move.w    Map_nr,d0
             jsr       Save_subfile
             movea.l   a1,a0
             jsr       Free_memory
             movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Update automap ]
; All registers are restored
;*****************************************************************************
Update_automap:        
             movem.l   d0-d3/d7/a0/a1,-(sp)
             tst.b     Stygian              ; Can you see ?
             bne       .Exit
             move.w    Map_Xcoord,d2        ; Initialize registers
             move.w    Map_Ycoord,d3
             subq.w    #1,d2
             subq.w    #1,d3
             movea.l   Automap_ptr,a0
             lea.l     Cut_table,a1
             moveq.l   #9-1,d7
.Loop:       move.b    (a1)+,d0             ; Get coordinates
             ext.w     d0
             add.w     d2,d0
             move.b    (a1)+,d1
             ext.w     d1
             add.w     d3,d1
             jsr       Set_automap_bit      ; Set bit in automap
             dbra      d7,.Loop
.Exit:       movem.l   (sp)+,d0-d3/d7/a0/a1
             rts       

;****************************************************************************
; [ Set bit in automap ]
;   IN : d0 - X-coordinate {0...} (.w)
;        d1 - Y-coordinate {0...} (.w)
;        a0 - Pointer to automap (.l)
; All registers are restored
;****************************************************************************
Set_automap_bit:       
             movem.l   d0/d1,-(sp)
             mulu.w    Width_of_map,d1      ; Calculate bit number & index
             add.w     d0,d1
             moveq.l   #7,d0
             and.w     d1,d0
             lsr.w     #3,d1
             bset      d0,0(a0,d1.w)        ; Set bit
             movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Options menu ]
;*****************************************************************************
Options_menu:          
             Wait_4_unclick 
             jsr       Exit_display
             lea.l     Options_Mod,a0
             jmp       Push_Module

;*****************************************************************************
; [ Options menu module ]
;*****************************************************************************
Options_DisUpd:        
             jsr       Update_status_block
             lea.l     Options_CIL,a0       ; Update control icons
             lea.l     OptionsCIL_evaluate,a1
             jsr       Update_control_icons
             rts       

Options_DisInit:       
             movea.l   Off_screen,a6
             moveq.l   #6,d0                ; Show new layout
             jsr       Show_layout
             lea.l     Options_CIL,a0       ; Show control icons
             jsr       OptionsCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Control_area,a0      ; Set object branch
             jsr       Set_layout_data
             lea.l     Lay6_target,a1       ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay6_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay6_below,a0        ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay6_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

Options_DisExit:       
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay6_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay6_below,a0        ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay6_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

OptionsCIL_evaluate:   
             tst.w     Music_block          ; Music blocked ?
             beq.s     .On
             bclr      #7,3(a0)             ; Enable {Music on}
             bset      #7,4(a0)             ; Disable {Music off}
             bra.s     .Exit
.On:         bset      #7,3(a0)             ; Disable {Music on}
             bclr      #7,4(a0)             ; Enable {Music off}
.Exit:       rts       

; ************* Options - Exit ****************************
Exit_options:          
             Wait_4_unclick 
             Pop       Module
             jmp       Init_display

; ************* Options - Music on ************************
Music_on:    
             clr.w     Music_block
; Turn music on
             rts       

; ************* Options - Music off ***********************
Music_off:   
             move.w    #-1,Music_block
; Turn music off
             rts       

; ************* Options - Quit game ***********************
Quit_game:   
             Wait_4_unclick 
             move.l    #Code0008Sys,Textfile_ptr  ; Are U sure ?
             move.w    #8,ReqText_nr
             move.l    #Exit_all,ReqDo_ptr
             lea.l     Req_Mod,a0
             jmp       Push_Module

; ************* Options - Save game ***********************
Save_game:   
             Wait_4_unclick 
             clr.w     SaveGame_bitlist     ; Clear list
             lea.l     Chard_ptrs+4,a0      ; Any other people in the
             moveq.l   #5-1,d7              ; party ?
.Loop:       tst.l     (a0)+
             bne.s     .Select
             dbra      d7,.Loop
             move.l    #Code0004Sys,Textfile_ptr  ; Are U sure ?
             move.w    #24,ReqText_nr
             move.l    #Really_save_game,ReqDo_ptr
             Push      Module,Req_Mod
             bra.s     .Exit
.Select:     Push      Module,SaveGame_Mod  ; Select
.Exit:       rts       

;*****************************************************************************
; [ Save game ]
;*****************************************************************************
SaveGame_ModInit:      
             move.l    #Lay6_PlusMes,PlusMes_info ; Install
             move.l    #Code0005Sys,Textfile_ptr
             Push      MA,SaveGame_MA
             moveq.l   #-1,d0               ; Set paper colour
             jsr       IG_Set_paper
; ------------- Display character portraits --------------------------
             lea.l     Chard_ptrs+4,a1      ; Initialize registers
             lea.l     Portrait_pos_list,a2
             movea.l   Off_screen,a6
             moveq.l   #2,d5
             moveq.l   #2,d6
             moveq.l   #34,d7
.Loop:       tst.l     (a1)                 ; Anyone there ?
             beq.s     .Next
             move.w    (a2)+,d0             ; Display portrait
             move.w    (a2)+,d1
             movea.l   (a1),a3
             lea.l     Portrait+6(a3),a0
             jsr       Blot_unmasked_block
             move.w    (a2)+,d0             ; Set cursor
             move.w    (a2)+,d1
             jsr       IG_Set_cursor
             moveq.l   #9,d0                ; Set ink
             cmp.w     Active_member,d5     ; Active character ?
             bne.s     .Snarl
             moveq.l   #8,d0
.Snarl:      jsr       IG_Set_ink
             lea.l     Char_name(a3),a0     ; Print name
             jsr       IG_Print
.Next:       addq.l    #4,a1                ; Next member
             addq.w    #1,d5
             cmpi.w    #6+1,d5
             bmi.s     .Loop
             move.w    #160-32,d0           ; Display OK icon
             move.w    #176,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             lea.l     Control_icn+15104,a0
             jsr       Blot_unmasked_block
             move.w    #160,d0              ; Display Exit icon
             move.w    #176,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             lea.l     Control_icn+7680,a0
             jsr       Blot_unmasked_block
             HashMes   20                   ; Print message {20,#}
             Update_screen 
             Push      Root,SaveGame_L1
             rts       

SaveGame_ModExit:      
             movea.l   Off_screen,a6
             Push      PA,Lay6_PA           ; Erase text window
             jsr       Erase_text_window
             Pop       PA
             move.w    #16,d0               ; Erase main window
             move.w    #49,d1
             move.w    #191,d2
             move.w    #191,d3
             moveq.l   #2,d6
             jsr       Draw_box
             Update_screen 
             Pop       Root
             Pop       MA
             rts       

Exit_SaveGame:         
             Wait_4_unclick                 ; Abort save
             Pop       Module
             jmp       Init_display

Do_SaveGame: 
             Wait_4_unclick 
             move.w    Active_member,d0     ; Active character deactivated ?
             move.w    SaveGame_bitlist,d1
             btst      d0,d1
             beq.s     .Exit
; Select new active character
             nop       
.Exit:       Pop       Module
             jmp       Really_save_game

Really_save_game:      
; ------------- Save character data ----------------------------------
             lea.l     Chard_filename,a0
             lea.l     Chard_ptrs,a2
             lea.l     Member_1_nr,a3
             moveq.l   #6-1,d7
.Loop:       tst.l     (a2)                 ; Anyone there ?
             beq.s     .Next
             move.w    (a3),d0              ; Save datafile
             movea.l   (a2),a1
             jsr       Save_subfile
.Next:       addq.l    #4,a2                ; Next member
             addq.l    #2,a3
             dbra      d7,.Loop
             .LOCAL 
; ------------- Remove unwanted characters ---------------------------
             lea.l     Chard_ptrs+4,a1
             lea.l     Member_2_nr,a2
             lea.l     Damage_timers,a3
             move.w    SaveGame_bitlist,d0
             moveq.l   #0,d1
             moveq.l   #1,d7
.Loop:       btst      d7,d0                ; Remove ?
             beq.s     .Next
             movea.l   (a1),a0              ; Clear bit in CD array
             move.w    Person_save_bit_pos(a0),d2
             lea.l     CD,a0
             move.w    d2,d3
             move.w    d2,d4
             lsr.w     #3,d3
             adda.w    d3,a0
             andi.w    #7,d4
             bset      d4,(a0)
             move.l    CD_value,d3          ; Set bit in internal CD bitlist
             ext.l     d2
             divu.w    #24,d2
             swap.w    d2
             bset      d2,d3
             move.l    d3,CD_value
             movea.l   (a1),a0              ; Free memory
             jsr       Kill_memory
             clr.l     (a1)                 ; Clear pointers
             clr.w     (a2)
             clr.b     (a3)                 ; Clear counters
             clr.b     6(a3)
             clr.b     12(a3)
             addq.w    #1,d1                ; Count
.Next:       addq.l    #4,a1                ; Next member
             addq.l    #2,a2
             addq.l    #1,a3
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi       .Loop
             sub.w     d1,Nr_members        ; Update
             jsr       Update_status_block  ; Redraw status block
             Update_screen 
             .LOCAL 
; ------------- Compile & save party data ----------------------------
             moveq.l   #0,d0                ; Make buffer
             move.w    Nr_of_modifications,d0
             mulu.w    #6,d0
             addi.l    #Default_length,d0
             move.l    d0,Partydata_length
             jsr       Allocate_memory
             move.l    a1,-(sp)             ; Store pointer
             lea.l     Party_data,a0
             moveq.l   #0,d0
             moveq.l   #24-1,d7             ; Copy 24 bytes
.Loop1:      move.w    (a0)+,d0
             move.b    d0,(a1)+
             dbra      d7,.Loop1
             move.w    #5550-1,d7           ; Copy 5550 words
.Loop2:      move.w    (a0)+,(a1)+
             dbra      d7,.Loop2
             movea.l   Modifications_ptr,a0 ; Copy modification list
             move.w    Nr_of_modifications,d7
             bra.s     .Entry3
.Loop3:      move.l    (a0)+,(a1)+
             move.w    (a0)+,(a1)+
.Entry3:     dbra      d7,.Loop3
             clr.w     (a1)+                ; Write modification sentinel
             lea.l     Partydata_filename+1,a0    ; Save party data
             movea.l   (sp)+,a1
             move.l    Partydata_length,d0
             jsr       Save_file
             movea.l   a1,a0                ; Free memory
             jsr       Free_memory
             rts       

Portrait_selected:     
             Wait_4_unclick 
             lsr.w     #8,d0                ; Any portrait selected ?
             tst.w     d0
             beq       .Exit
             lea.l     Chard_ptrs,a0        ; Get pointer to character data
             move.w    d0,d1
             add.w     d1,d1
             add.w     d1,d1
             tst.l     0(a0,d1.w)           ; Anyone there ?
             beq       .Exit
             movea.l   0(a0,d1.w),a2
             move.w    Body_conditions(a2),d1
             move.w    #$e000,d2            ; Alive and kicking ?
             and.w     d1,d2
             beq.s     .Alive
             PlusMes   21                   ; Print message {21,+}
             bra       .Exit
.Alive:      btst      #1,d1                ; Bonkers ?
             beq       .Sane
             lea.l     Lay6_PlusMes,a0
             jsr       Push_MA
             addq.l    #8,a0
             jsr       Push_PA
             jsr       Init_RText           ; Start
             lea.l     Char_name(a2),a0     ; Add name
             jsr       Add_ASCII_2_RText
             lea.l     Space,a0             ; Add space
             jsr       Add_ASCII_2_RText
             move.w    #22,d0               ; Add encoded text
             lea.l     Code0005Sys,a1
             jsr       Add_encoded_2_RText
             movea.l   Off_screen,a6        ; Clear window
             jsr       Erase_text_window
             jsr       IG_Cursor_home
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d1
             bra.s     .Entry
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry:      dbra      d1,.Loop
             Update_screen                  ; Wait for user
             jsr       Exit_RText
             jsr       Wait_4_user
             movea.l   Off_screen,a6        ; Clear window
             jsr       Erase_text_window
             Update_screen 
             Pop       PA
             Pop       MA
             clr.b     Mouse_click_state    ; Aargh
             bra       .Exit
.Sane:       btst      #10,d1               ; Stoned ?
             beq.s     .Clean
             PlusMes   23                   ; Print message {23,+}
             bra       .Exit
.Clean:      lea.l     Portrait_pos_list,a1 ; Get pointer to coordinates
             move.w    d0,d1
             subq.w    #1,d1
             lsl.w     #3,d1
             adda.w    d1,a1
             movea.l   Off_screen,a6
             move.w    SaveGame_bitlist,d1  ; Toggle bit
             bchg      d0,d1
             move.w    d1,SaveGame_bitlist
             btst      d0,d1                ; Redraw or deactivate ?
             bne.s     .Clear
; ------------- Redraw portrait --------------------------------------
             move.w    (a1)+,d0             ; Display portrait
             move.w    (a1)+,d1
             moveq.l   #2,d6
             moveq.l   #34,d7
             lea.l     Portrait+6(a2),a0
             jsr       Blot_unmasked_block
             Update_screen 
             bra       .Exit
; ------------- Deactivate portrait ----------------------------------
.Clear:      move.w    (a1)+,d0             ; Deactivate portrait
             move.w    (a1)+,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             lea.l     Chequered,a0
             jsr       Blot_masked_block
             addi.w    #16,d1
             lea.l     Chequered,a0
             jsr       Blot_masked_block
             addi.w    #16,d1
             moveq.l   #2,d7
             jsr       Blot_masked_block
             Update_screen 
.Exit:       rts       

; ************* Options - Load game ***********************
Load_game:   
             Wait_4_unclick 
             move.l    #Code0004Sys,Textfile_ptr  ; Are U sure ?
             move.w    #25,ReqText_nr
             move.l    #Really_load_game,ReqDo_ptr
             lea.l     Req_Mod,a0
             jmp       Push_Module

Really_load_game:      
             Pop       Module               ; Leave options & map
             jsr       Exit_map
             lea.l     Chard_ptrs,a1        ; Remove character data files
             moveq.l   #6-1,d7
.Loop1:      tst.l     (a1)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a1),a0              ; Remove memory
             jsr       Kill_memory
.Next:       addq.l    #4,a1                ; Next member
             dbra      d7,.Loop1
             lea.l     Chard_ptrs,a0        ; Clear variables
             moveq.l   #6-1,d7
.Loop2:      clr.l     (a0)+
             dbra      d7,.Loop2
             lea.l     Damage_timers,a0
             moveq.l   #15-1,d7
.Loop3:      clr.w     (a0)+
             dbra      d7,.Loop3
             sf        Which_CIL
             jsr       Restore_game         ; Load new data
             jsr       Init_map             ; Re-initialize
             jmp       Init_time

;*****************************************************************************
; [ Camp screen ]
;*****************************************************************************
Camp:        
             Wait_4_unclick 
             jsr       Exit_display
             lea.l     Camp_Mod,a0
             jmp       Push_Module

;*****************************************************************************
; [ Camp module ]
;*****************************************************************************
Camp_DisUpd: 
             jsr       Update_status_block
             lea.l     Camp_CIL,a0          ; Update control icons
             lea.l     CampCIL_evaluate,a1
             jsr       Update_control_icons
             rts       

Camp_ModInit:          
             sf        Slept                ; Clear flag
             moveq.l   #1,d0                ; Load picture
             lea.l     Lay3_target_hbl+2,a0
             jsr       Load_80x80_picture
             jmp       Camp_DisInit

Camp_ModExit:          
             movea.l   Pic80_ptr,a0         ; Free memory
             jsr       Free_memory
             jmp       Fadeout_lay3         ; Fade out

Camp_DisInit:          
             move.w    #3,Spell_area_type   ; Set spell area
             move.l    #Lay3_PlusMes,PlusMes_info
             move.l    #Code0005Sys,Textfile_ptr
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show new layout
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             lea.l     Camp_CIL,a0          ; Show control icons
             jsr       CampCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

CampCIL_evaluate:      
             bclr      #7,6(a0)             ; Enable all icons
             bclr      #7,(a0)
             bclr      #7,3(a0)
             tst.b     Slept                ; Already slept ?
             beq.s     .Ok
             bset      #7,6(a0)             ; Disable {Rest}
.Ok:         movea.l   Current_active_char_data,a1          ; Any spell classes ?
             tst.b     Spell_class_counter(a1)
             bne.s     .Exit
             bset      #7,(a0)              ; Disable {Cast spell}
             bset      #7,3(a0)             ; Disable {Learn spell}
.Exit:       rts       

; ************* Camp screen - Exit camp *******************
Exit_camp:   
             Wait_4_unclick 
             tst.b     Inn_flag             ; Inn ?
             beq.s     .Exit
             movea.l   Placedat_ptr,a0      ; Set new coordinates
             move.w    2(a0),Map_Xcoord
             move.w    4(a0),Map_Ycoord
             move.w    6(a0),View_direction
             cmpi.b    #0,Current_map_type  ; 2D city ?
             bne.s     .Exit
             jsr       Recalc_mapbuf_coords ; Recalculate !
             sf        Inn_flag
.Exit:       Pop       Module
             jmp       Init_display

; ************* Camp screen - Learn spell *****************
Learn_spell: 
             Wait_4_unclick 
             lea.l     LearnSpell_Mod,a0
             jmp       Push_Module

LearnSpell_DisInit:    
             Push      MA,L3_objects_area
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inventory_1_place_counter(a0),a1
             lea.l     Inv_data+360(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             HashMes   11                   ; Print message {11,#}
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

LearnSpell_DisExit:    
             move.l    #Void,Itemslots_ptr  ; Remove objects & clear
             Push      PA,Lay3_PA           ; text window
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3
             jsr       Erase_text_window
             Update_screen 
             Pop       PA
             Pop       MA
             rts       

LearnSpell_objselect:  
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number
             ext.w     d0                   ; Calculate pointers to item
             subq.w    #1,d0                ; data
             movea.l   Itemslots_ptr,a0
             movea.l   Itemdata_ptr,a1
             adda.w    d0,a0
             mulu.w    #40,d0
             adda.w    d0,a1
             tst.b     (a0)                 ; Any item in this slot ?
             beq       .Exit
             cmpi.b    #8,Item_type(a1)     ; Is it a spell scroll ?
             beq.s     .Scroll
             PlusMes   12                   ; Print message {12,+}
             bra       .Exit
.Scroll:     movea.l   Current_active_char_data,a2
             move.b    Spell_class(a1),d0   ; Correct spell class ?
             btst      d0,Spell_class_counter(a2)
             bne.s     .Class
             PlusMes   13                   ; Print message {13,+}
             bra       .Exit
.Class:      lea.l     Spell_data,a3        ; Get pointer to spell data
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #120,d0
             adda.w    d0,a3
             move.b    Spell_number(a1),d0
             ext.w     d0
             subq.w    #1,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a3
             moveq.l   #0,d0                ; Enough spell learn points ?
             move.b    2(a3),d0
             cmp.w     Nr_spell_learn_points(a2),d0
             bls.s     .Points
             PlusMes   24                   ; Print message {24,+}
             bra       .Exit
.Points:     moveq.l   #0,d0                ; Probe {Learn Spell}-skill
             move.b    Skill_9(a2),d0
             add.w     Skill_9_normal_magic(a2),d0
             jsr       Probe
             bpl.s     .Probed
             PlusMes   15                   ; Print message {15,+}
             bra       .Destroy
.Probed:     moveq.l   #0,d0                ; Remove spell learn points
             move.b    2(a3),d0
             sub.w     d0,Nr_spell_learn_points(a2)
             lea.l     Spells_class_1(a2),a3      ; Learn spell
             move.b    Spell_class(a1),d0
             ext.w     d0
             subq.w    #1,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a3
             move.b    Spell_number(a1),d0
             move.l    (a3),d1
             bset      d0,d1
             move.l    d1,(a3)
             PlusMes   14                   ; Print message {14,+}
.Destroy:    clr.b     (a0)                 ; Remove object
             move.w    Weight(a1),d0
             ext.l     d0
             sub.l     d0,Weight_normal(a2)
             lea.l     Door_object_pos_list-4,a4  ; Show item destruction
             move.b    Object_slot_number,d0
             ext.w     d0
             add.w     d0,d0
             add.w     d0,d0
             move.w    2(a4,d0.w),d1
             move.w    0(a4,d0.w),d0
             moveq.l   #0,d2
             move.b    (a1),d2
             moveq.l   #78,d3
             jsr       Show_item_destruction
             movea.l   Off_screen,a6        ; Reprint message
             HashMes   11
             Update_screen 
             rts       
.Exit:       jmp       Pop_Module

; ************* Camp screen - Rest ************************
Rest:        
             Wait_4_unclick 
             st        Slept                ; Set flag
             PlusMes   16
             Push      PA,Lay3_PA
             Push      MA,Lay3_PlusMes
; ------------- Wait for 8 hours -------------------------------------
             movea.l   Mapd_ptr,a0          ; Calculate length of 8 hours
             moveq.l   #0,d6
             move.b    Time_step_len(a0),d6
             moveq.l   #0,d7
             move.b    Time_hour_len(a0),d7
             lsl.w     #3,d7
             divu.w    d6,d7
             subq.w    #1,d7
.Wait:       jsr       Update_time          ; Wait 8 hours
             dbra      d7,.Wait
             cmpi.b    #2,Current_map_type  ; 2D map ?
             bpl.s     .Go_on
             jsr       M2_time_evaluate     ; Fix night circle
             move.w    New_radius,Current_radius
.Go_on:      tst.b     Inn_flag             ; Inn ?
             bne       Inn
; ------------- Age aging people -------------------------------------
             lea.l     Chard_ptrs,a0        ; Any aging people in the
             moveq.l   #1,d7                ; party ?
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d0            ; Alive and kicking ?
             and.w     Body_conditions(a1),d0
             bne.s     .Next
             btst      #4,Body_conditions(a1)     ; Aging ?
             beq.s     .Next
             addq.w    #1,Birth_year(a1)    ; Increase age
             move.w    Attr_9_normal(a1),d0
             addq.w    #1,d0
             move.w    d0,Attr_9_normal(a1)
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
; ------------- Camping under the stars ------------------------------
             moveq.l   #4,d7                ; Rest
             lea.l     Code0005Sys,a1
             lea.l     Chard_ptrs,a2
             moveq.l   #6-1,d6
.Loop1:      tst.l     (a2)                 ; Anyone there ?
             beq       .Next1
             movea.l   (a2),a4
             move.w    Body_conditions(a4),d0     ; Alive and kicking ?
             andi.w    #$e400,d0
             bne       .Next1
             jsr       Init_RText           ; Start random access text
             lea.l     Char_name(a4),a0     ; Add character name + space
             jsr       Add_ASCII_2_RText
             lea.l     Space,a0
             jsr       Add_ASCII_2_RText
; ------------- Print message if no food -----------------------------
             tst.w     Food_rations(a4)     ; Any food left ?
             bne.s     .Enough
             moveq.l   #17,d0               ; Add message {17}
             jsr       Add_encoded_2_RText
             bra       .Continue
; ------------- Calculate & print added LP & PP ----------------------
.Enough:     moveq.l   #18,d0               ; Add message {18} + space
             jsr       Add_encoded_2_RText
             moveq.l   #0,d0                ; Get maximum LP
             move.w    Life_points_max(a4),d0
             add.w     Life_points_max_magic(a4),d0
             move.w    d0,d1
             divu.w    #10,d0               ; Get added amount
             move.w    d0,d2
             add.w     Life_points_normal(a4),d2  ; Not too much ?
             cmp.w     d2,d1
             bpl.s     .Ok1
             move.w    d1,d2
.Ok1:        move.w    d2,Life_points_normal(a4)  ; Store new LP
             lea.l     Number_buffer,a0     ; Convert added LP
             movea.l   a0,a3
             jsr       LConvert_number
             moveq.l   #0,d0                ; Get maximum PP
             move.w    Power_points_max(a4),d0
             add.w     Power_points_max_magic(a4),d0
             move.w    d0,d1
             divu.w    #10,d0               ; Get added amount
             move.w    d0,d2
             add.w     Power_points_normal(a4),d2 ; Not too much ?
             cmp.w     d2,d1
             bpl.s     .Ok2
             move.w    d1,d2
.Ok2:        move.w    d2,Power_points_normal(a4) ; Store new PP
             move.b    #"L",(a3)+           ; Add string
             move.b    #"P",(a3)+
             move.b    #",",(a3)+
             move.b    #" ",(a3)+
             jsr       LConvert_number      ; Convert added PP
             move.b    #"P",(a3)+           ; Add string
             move.b    #"P",(a3)+
             move.b    #" ",(a3)+
             clr.b     (a3)
             lea.l     Number_buffer,a0     ; Add
             jsr       Add_ASCII_2_RText
; ------------- End message & wait for user --------------------------
             moveq.l   #19,d0               ; Add message {19}
             jsr       Add_encoded_2_RText
             subq.w    #1,Food_rations(a4)  ; Remove 1 food
             subi.l    #Food_weight,Weight_normal(a4)
.Continue:   movea.l   Off_screen,a6        ; Clear window
             jsr       Erase_text_window
             jsr       IG_Cursor_home
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d1
             bra.s     .Entry2
.Loop2:      jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry2:     dbra      d1,.Loop2
             jsr       Switch_screen        ; Wait for user
             jsr       Exit_RText
             Wait_4_unclick 
             jsr       Wait_4_user
.Next1:      addq.l    #4,a2                ; Next member
             dbra      d6,.Loop1
             bra       Exit_rest
             .LOCAL 
; ------------- Camping in a warm room -------------------------------
Inn:         moveq.l   #4,d7                ; Rest
             lea.l     Code0005Sys,a1
             lea.l     Chard_ptrs,a2
             moveq.l   #6-1,d6
.Loop1:      tst.l     (a2)                 ; Anyone there ?
             beq       .Next1
             movea.l   (a2),a4
             move.w    Body_conditions(a4),d0     ; Alive and kicking ?
             andi.w    #$e400,d0
             bne       .Next1
             jsr       Init_RText           ; Start random access text
             lea.l     Char_name(a4),a0     ; Add character name + space
             jsr       Add_ASCII_2_RText
             lea.l     Space,a0
             jsr       Add_ASCII_2_RText
; ------------- Calculate & print added LP & PP ----------------------
             moveq.l   #18,d0               ; Add message {18} + space
             jsr       Add_encoded_2_RText
             moveq.l   #0,d0                ; Get maximum LP
             move.w    Life_points_max(a4),d0
             add.w     Life_points_max_magic(a4),d0
             sub.w     Life_points_normal(a4),d0
             bpl.s     .Ok1                 ; Already too much ?
             moveq.l   #0,d0
.Ok1:        add.w     d0,Life_points_normal(a4)  ; Increase LP
             lea.l     Number_buffer,a0     ; Convert added LP
             movea.l   a0,a3
             jsr       LConvert_number
             moveq.l   #0,d0                ; Get maximum PP
             move.w    Power_points_max(a4),d0
             add.w     Power_points_max_magic(a4),d0
             sub.w     Power_points_normal(a4),d0
             bpl.s     .Ok2                 ; Already too much ?
             moveq.l   #0,d0
.Ok2:        add.w     d0,Power_points_normal(a4) ; Increase LP
             move.b    #"L",(a3)+           ; Add string
             move.b    #"P",(a3)+
             move.b    #",",(a3)+
             move.b    #" ",(a3)+
             jsr       LConvert_number      ; Convert added PP
             move.b    #"P",(a3)+           ; Add string
             move.b    #"P",(a3)+
             move.b    #" ",(a3)+
             clr.b     (a3)
             lea.l     Number_buffer,a0     ; Add
             jsr       Add_ASCII_2_RText
; ------------- End message & wait for user --------------------------
             moveq.l   #19,d0               ; Add message {19}
             jsr       Add_encoded_2_RText
             movea.l   Off_screen,a6        ; Clear window
             jsr       Erase_text_window
             jsr       IG_Cursor_home
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d1
             bra.s     .Entry2
.Loop2:      jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry2:     dbra      d1,.Loop2
             jsr       Switch_screen        ; Wait for user
             jsr       Exit_RText
             Wait_4_unclick 
             jsr       Wait_4_user
.Next1:      addq.l    #4,a2                ; Next member
             dbra      d6,.Loop1
; ------------- Deactivate all permanent spells ----------------------
Exit_rest:   lea.l     Spell_1_data,a0
             clr.l     (a0)+
             clr.w     (a0)
             lea.l     Spell_1_duration,a0
             clr.l     (a0)+
             clr.w     (a0)
; ------------- End --------------------------------------------------
             movea.l   Off_screen,a6        ; Erase texts
             jsr       Erase_text_window
             Update_screen 
             Pop       MA
             Pop       PA
             Wait_4_unclick 
             rts       

;*****************************************************************************
; [ Ear action ]
;*****************************************************************************
Ear_action:  
             move.l    #Code0005Sys,Textfile_ptr
             movea.l   Current_active_char_data,a0          ; Can you hear ?
             moveq.l   #0,d0
             move.b    Skill_4(a0),d0
             add.w     Skill_4_normal_magic(a0),d0
             jsr       Probe
             bmi       .None
             ext.l     d0                   ; Calculate hearing index
             divu.w    #20,d0
             move.w    d0,Hearing
             lea.l     Spiral_lengths,a0    ; Get number of spiral entries
             moveq.l   #0,d7
.Loop1:      add.w     (a0)+,d7
             dbra      d0,.Loop1
             subq.w    #1,d7
             move.w    Width_of_map,d2      ; Right boundary
             sub.w     Map_Xcoord,d2
             move.w    Map_Xcoord,d3        ; Left boundary
             neg.w     d3
             addq.w    #1,d3
             move.w    Height_of_map,d4     ; Bottom boundary
             sub.w     Map_Ycoord,d4
             move.w    Map_Ycoord,d5        ; Top boundary
             neg.w     d5
             addq.w    #1,d5
             lea.l     Spiral_table,a0
.Loop2:      move.b    (a0),d0              ; Load X
             cmp.b     d2,d0                ; X too high ?
             bgt.s     .Next2
             cmp.b     d3,d0                ; X too low ?
             blt.s     .Next2
             move.b    1(a0),d1             ; Load Y
             cmp.b     d4,d1                ; Y too high ?
             bgt.s     .Next2
             cmp.b     d5,d1                ; Y too low ?
             blt.s     .Next2
             jsr       Try_2_hear           ; Yay!
             bpl.s     .Exit
.Next2:      addq.l    #2,a0                ; Next
             dbra      d7,.Loop2
.None:       move.w    #0,WText_nr          ; Show text
             Push      Module,TxtW_Mod
.Exit:       rts       

; [ Search for person ]
;   IN : d0 - Relative X-coordinate (.w)
;        d1 - Relative Y-coordinate (.w)
;  OUT : pl - Someone was found
;        mi - No-one was found
; Changed registers : d0,d1
Try_2_hear:  
             movem.l   d6/d7/a0,-(sp)
             ext.w     d0                   ; Calculate coordinates
             add.w     Map_Xcoord,d0
             ext.w     d1
             add.w     Map_Ycoord,d1
             lea.l     VChar_data,a0        ; Initialize registers
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
             jsr       Heard_it             ; Yay! Do it!
             moveq.l   #0,d7                ; Force plus
             bra.s     .Exit
.Next:       lea.l     VData_length(a0),a0  ; Next character
             addq.w    #1,d7
             cmpi.w    #Max_chars,d7
             bmi       .Loop
             moveq.l   #-1,d7               ; Force minus
.Exit:       movem.l   (sp)+,d6/d7/a0
             rts       

Heard_it:    movem.l   d0/d1/d7/a0/a1/a3,-(sp)
             sub.w     Map_Xcoord,d0        ; Make relative coordinates
             sub.w     Map_Ycoord,d1
             ext.l     d0                   ; Mega SGN function
             beq.s     .Zero1
             swap.w    d0
             bmi.s     .Zero1
             moveq.l   #1,d0
.Zero1:      ext.l     d1                   ; Mega SGN function
             beq.s     .Zero2
             swap.w    d1
             bmi.s     .Zero2
             moveq.l   #1,d1
.Zero2:      addq.w    #1,d0                ; Make index
             addq.w    #1,d1
             mulu.w    #3,d1
             add.w     d1,d0
             lea.l     Hear_table,a0        ; Get direction
             move.b    0(a0,d0.w),d0
             ext.w     d0
             move.w    d0,Hear_direction
             lea.l     Code0005Sys,a1       ; Start random access text
             Push      PA,TxtW_PA
             jsr       Init_RText
             move.w    #1,d0                ; Add message {1}
             jsr       Add_encoded_2_RText
             lea.l     Hearing_txt,a0       ; Convert hearing skill
             movea.l   a0,a3
             move.w    Hearing,d0
             addq.w    #1,d0
             mulu.w    #5,d0
             moveq.l   #2,d7
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add string
             clr.b     (a3)
             jsr       Add_ASCII_2_RText    ; Add
             move.w    #2,d0                ; Add message {2}
             jsr       Add_encoded_2_RText
             move.w    Hear_direction,d0    ; Add message { -direction- }
             jsr       Add_encoded_2_RText
             Pop       PA
             Push      Module,HearTxtW_Mod  ; Display text
             movem.l   (sp)+,d0/d1/d7/a0/a1/a3
             rts       

; ************* Special text window module ****************
HearTxtW_ModInit:      
             move.w    Lines_in_text,d0     ; Calculate height of window
             mulu.w    #7,d0
             moveq.l   #15,d3               ; Yes, calculate new height
             add.w     d0,d3
             andi.w    #$fff0,d3
             lsr.w     #4,d3
             cmpi.w    #2,d3                ; Window too small ?
             bpl.s     .Not2small
             moveq.l   #2,d3
.Not2small:  move.w    d3,d4                ; Calculate vertical offset
             lsl.w     #4,d4
             sub.w     d0,d4
             moveq.l   #16,d0               ; Open a window
             moveq.l   #52,d1
             moveq.l   #18,d2
             addq.w    #2,d3
             moveq.l   #0,d6
             suba.l    a0,a0
             jsr       Open_window
             move.w    d0,Window_handle
             lsr.w     #1,d4                ; Vertical cursor centering
             add.w     d4,d1
             addi.w    #16,d1
             move.w    d1,TxtW_PA+2
             subq.w    #2,d3                ; Set height
             lsl.w     #4,d3
             move.w    d3,TxtW_PA+6
             Push      PA,TxtW_PA
             movea.l   Off_screen,a6        ; Print text
             movea.l   RText_ptr,a0
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d7
             subq.w    #1,d7
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
             dbra      d7,.Loop
             Update_screen 
             jsr       Exit_RText           ; De-allocate text buffer
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Automap_CIL: .DC.b 46,1,45,4,30,3,48,2,47
             .EVEN 
             .DC.l Automap_upleft,Automap_up,Automap_upright
             .DC.l Automap_left,Automap_exit,Automap_right
             .DC.l Automap_downleft,Automap_down,Automap_downright
Lay8_target: .DC.w 0
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200     ; Portrait palette
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.w 0
             .DC.w 0,$651,$333,$222,$111,$531,$421,$124     ; Objects palette
             .DC.w $236,$610,$310,$541,$340,$451,$444,$765
Lay11_target:          .DC.w 0,$500,$333,$222,$111,$444,$555,$210
             .DC.w $320,$431,$542,$0012,$123,$351,$230,$666
Cut_table:   .DC.b -1,-1,-1,0,-1,1
             .DC.b 0,-1,0,0,0,1
             .DC.b 1,-1,1,0,1,1
Dialogue_CIL:          .DC.b 33,34,30,35,17,67,61,63,62
             .EVEN 
             .DC.l DIA_Transfer_item,DIA_Drop_item,DIA_Exit
             .DC.l DIA_Show_item,DIA_Ask_word,DIA_Join_party
             .DC.l DIA_Give_item,DIA_Give_gold,DIA_Give_food
SaveGame_MA: .DC.w 16,191,49,191
Lay6_PlusMes:          .DC.w 208,303,49,128
Lay6_PA:     .DC.w 208,49,96,80,15,2
Lay8_PlusMes:          .DC.w 16,191,49,128
Lay8_PA:     .DC.w 16,49,176,77,15,2
Options_CIL: .DC.b 65,56,30,25,26,56,23,24,56
             .EVEN 
             .DC.l Quit_game,0,Exit_options
             .DC.l Music_on,Music_off,0
             .DC.l Save_game,Load_game,0
Lay6_target: .DC.w 0,$750,$333,$222,$111,$742,$631,$200     ; Portrait palette
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
Camp_CIL:    .DC.b 12,56,30,58,56,56,7,56,56
             .EVEN 
             .DC.l Cast_spell,0,Exit_camp
             .DC.l Learn_spell,0,0
             .DC.l Rest,0,0
Spiral_lengths:        .DC.w 8,16,24,32,40
Hear_table:  .DC.b 10,3,4,9,0,5,8,7,6
             .EVEN 
Portrait_pos_list:     
             .DC.w 16,49,16,49+36
             .DC.w 16+96,49+24,16+90,49+24+36
             .DC.w 16,49+48,16,49+48+36
             .DC.w 16+96,49+24+48,16+90,49+24+48+36
             .DC.w 16,49+96,16,49+96+36

             .BSS 
Eye_flag:    .DS.b 1   ; For [ Show_pictxt ] event
Joined:      .DS.b 1
Inn_flag:    .DS.b 1
Slept:       .DS.b 1
             .EVEN 
Made_area:   .DS.w 4   ; Mouse area
Automap_ptr: .DS.l 1
Automapicon_ptr:       .DS.l 1
Automap_X:   .DS.w 1
Automap_Y:   .DS.w 1
Automap_width:         .DS.w 1
Automap_height:        .DS.w 1
Party_automap_icon:    .DS.w 1

Dialogue_chard_ptr:    .DS.l 1
Dialogue_char_nr:      .DS.w 1
Dialogue_VChar_index:  .DS.w 1
Action_ptr:  .DS.l 1
Act_dat_ptr: .DS.l 1
Result_ptr:  .DS.l 1
Res_dat1_ptr:          .DS.l 1
Res_dat2_ptr:          .DS.l 1
Res_dat3_ptr:          .DS.l 1
Dialogue_text_ptr:     .DS.l 1

Hearing:     .DS.w 1
Hear_direction:        .DS.w 1
Hearing_txt: .DS.b 5
             .EVEN 
SaveGame_bitlist:      .DS.w 1
Partydata_length:      .DS.l 1

             .SECTION 5,DATA
Automap_filename:      .DC.b 17,"AUTOMAP.AMB",0
             .EVEN 

             .SECTION 7,DATA
; SAVE GAME : 1st layer
SaveGame_L1: .DC.w 16,143,49,178            ; Portrait area
             .DC.b 1
             .EVEN 
             .DC.l .C2,SaveGame_L2
.C2:         .DC.w 128,159,176,191          ; OK icon
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 160,191,176,191          ; Exit icon
             .DC.b 3
             .EVEN 
             .DC.l 0,0

; SAVE GAME : 2nd layer
SaveGame_L2: 
             .DC.w 16,47,49,82              ; Portraits
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 112,143,49+24,82+24
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 16,47,97,130
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 112,143,97+24,130+24
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 16,47,145,178
             .DC.b 5
             .EVEN 
             .DC.l 0,0

             .SECTION 8,DATA
Hbl_Lay8_list:         .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
Lay8_below:  .DC.b 36,0
             .DCB.w 16,0
             .DC.b 49+64,0
             .DCB.w 16,0
             .DC.w 0
Hbl_Lay11_list:        .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Lay11_below: .DCB.w 16,0
             .DC.w 0
Hbl_Lay6_list:         .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Lay6_below:  .DCB.w 16,0
             .DC.w 0

             .END 






