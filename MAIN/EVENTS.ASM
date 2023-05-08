
; Event handling
; Written by J.Horneman (In Tune With The Universe)
; Start : 11-5-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "Dawn of light lying between a silence and sold sources
;     Chased amid fusions of wonder in moments hardly seen forgotten
;      Coloured in pastures of chance dancing leaves cast spells of challenge
;       Amused but real in thought we fled from the sea whole."
;   The Revealing Science Of God / Dance Of The Dawn, Yes, 1973

; Notes :
;   - {Event_data} in the map data is accessed with a byte offset.

Max_events   = 21
ThatCode     = 193     ; Code for "THAT" in dictionary

             .MACRO Restore_coords
             move.w    Old_Xcoord,Map_Xcoord
             move.w    Old_Ycoord,Map_Ycoord
             move.w    Old_mapbufX,Mapbuf_X
             move.w    Old_mapbufY,Mapbuf_Y
             .ENDM 

             .MACRO Update_map_display
             movea.l   Module_sp,a0         ; Update map display
             move.l    (a0),d0
             beq.s     .\~Zero
             movea.l   d0,a0
             jsr       (a0)
             jsr       Switch_screen
.\~Zero:     .ENDM 

             .TEXT 
;*****************************************************************************
; [ Handle events at player's current location ]
; All registers are restored
;*****************************************************************************
Event_handler:         
             movem.l   d0/d1/a5,-(sp)
             cmpi.w    #5,Travel_mode       ; Normal travelmode ?
             bpl.s     .Exit
             move.w    Map_Xcoord,d0        ; Get player's coordinates
             move.w    Map_Ycoord,d1
             jsr       Find_event           ; Find event
             beq.s     .Exit                ; Any there ?
             jsr       Handle_event         ; Handle it
.Exit:       movem.l   (sp)+,d0/d1/a5
             rts       

; [ Find event ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;  OUT : a5 - Pointer to event data (.l)
;      Zero - No event
;  Not zero - Event
; Changed register : a5
Find_event:  
             movem.l   d0/d1/a0,-(sp)
             movea.l   Map_pointer,a0       ; Calculate map pointer
             subq.w    #1,d1
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             add.w     Size_of_map,d1
             lea.l     -1(a0,d1.w),a0
             cmpi.b    #2,Current_map_type  ; Go to event map
             bpl.s     .3D_map
             adda.w    Size_of_map,a0
.3D_map:     moveq.l   #0,d0                ; Get event number
             move.b    (a0),d0
             beq.s     .Exit                ; Any event at all ?
             subq.w    #1,d0                ; BASE 0 correction
             move.w    d0,Event_nr          ; Store
             movea.l   Mapd_ptr,a5          ; Calculate event data pointer
             mulu.w    #10,d0
             lea.l     Event_data(a5,d0.w),a5
             move.l    a5,Event_data_ptr
             moveq.l   #-1,d0               ; Non zero
.Exit:       movem.l   (sp)+,d0/d1/a0
             rts       

; [ Handle event ]
;   IN : a5 - Pointer to event data (.l)
; All registers are restored
Handle_event:          
             movem.l   d0-d7/a0-a6,-(sp)
             moveq.l   #0,d1                ; Get event save number
             move.b    5(a5),d1
             beq.s     .No_save             ; Event save on ?
             move.w    Map_nr,d6            ; Get map number x 65
             subq.w    #1,d6
             move.w    d6,d7
             lsl.w     #6,d6
             add.w     d7,d6
             add.w     d1,d6                ; Add event save number
             moveq.l   #$7,d7               ; Calculate bit & byte number
             and.w     d6,d7
             lsr.w     #3,d6
             lea.l     Event,a0             ; Get pointer to EVENT array
             adda.w    d6,a0
             cmpi.b    #4,(a5)              ; FUCKING EXCEPTION ONE ?
             beq.s     .Skip
             cmpi.b    #20,(a5)             ; FUCKING EXCEPTION TWO ?
             bne.s     .Go_on
             btst      d7,(a0)              ;    DOOR if not saved
             beq.s     .Skip
             jsr       Do_extra_event       ;    MAP EXIT if saved
             bra.s     .Exit
.Go_on:      btst      d7,(a0)              ; Check bit in EVENT array
             bne.s     .Exit
.Skip:       move.l    a0,EVENT_ptr         ; Store EVENT array pointers
             move.w    d7,EVENT_bit
.No_save:    moveq.l   #0,d1                ; Get event type
             move.b    (a5),d1
             cmpi.w    #Max_events+1,d1     ; Legal ?
             bmi.s     .Ok
             ERROR     "[ Handle_event ] : Illegal event number !!!"
             bra.s     .Exit
.Ok:         add.w     d1,d1                ; Get pointer to routine
             add.w     d1,d1
             movea.l   .Event_ptrs-4(pc,d1.w),a0
             jsr       (a0)
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

.Event_ptrs: .DC.l Map_exit,Door,Show_pictxt,Item_found
             .DC.l Trap_door,Teleporter,Wind_gate,Spinner
             .DC.l Damage_field,Anti_magic,Lp_regen,Sp_regen
             .DC.l ETrap,Riddle_mouth,Attr_change,Change_icon
             .DC.l Encounter,Places,Event_item,Door_exit
             .DC.l Travel_exit

;*****************************************************************************
; [ Set event bit ]
;   IN : a5 - Pointer to event data (.l)
; EVENT DATA :
;      5(a5)      - Event save number (.b)
; All registers are restored
;*****************************************************************************
Save_event:  
             tst.b     5(a5)                ; Event save on ?
             beq.s     .No_save
             movem.l   d0/a0,-(sp)          ; Save registers
             movea.l   EVENT_ptr,a0         ; Get EVENT array pointers
             move.w    EVENT_bit,d0
             bset      d0,(a0)              ; Set bit
             movem.l   (sp)+,d0/a0
.No_save:    rts       

;*****************************************************************************
; [ Probe ]
;   IN : d0 - Probe value (.w)
;  OUT : pl - Positive probe (dice roll =< probe value)
;        mi - Negative probe (dice roll  > probe value)
; All registers are restored
;*****************************************************************************
Probe:       
             movem.l   d0/d1,-(sp)
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             bpl.s     .Exit
             tst.w     d0                   ; Boundary check
             bmi.s     .Exit
             cmpi.w    #100,d0
             bpl.s     .Exit
             move.w    d0,d1
             jsr       Random               ; Get {random} MOD 100
             lsr.w     #1,d0
             ext.l     d0
             divu.w    #100,d0
             swap.w    d0
             cmp.w     d0,d1                ; Probe
.Exit:       movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Execute trap ]
;   IN : d0 - Trap number (.b)
; All registers are restored
;*****************************************************************************
Execute_trap:          
             movem.l   d0-d3/a0-a2/a5,-(sp)
             ext.w     d0                   ; Get trap parameters
             beq       .Exit
             lea.l     Trap_table,a5
             subq.w    #1,d0
             lsl.w     #3,d0
             adda.w    d0,a5
             movea.l   (a5),a1
             tst.w     4(a5)                ; Active or party ?
             bne.s     .Active
             lea.l     Chard_ptrs,a2        ; Party
             moveq.l   #1,d1
             moveq.l   #0,d2
.Loop:       tst.l     (a2)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a2),a0
             move.w    #$e400,d3            ; Alive and kicking ?
             and.w     Body_conditions(a0),d3
             bne.s     .Next
             move.w    Attr_7_normal(a0),d0 ; Probe luck
             add.w     Attr_7_normal_magic(a0),d0
             jsr       Probe
             bpl.s     .Next
             addq.w    #1,d3                ; Count
             move.w    d1,d0                ; Do bad stuff
             jsr       (a1)
.Next:       addq.l    #4,a2                ; Next character
             addq.w    #1,d1
             cmpi.w    #6+1,d1
             bmi.s     .Loop
             tst.w     d3                   ; Anyone hurt ?
             bne       .Go_on
             movea.l   Textfile_ptr,a1      ; Show text
             move.w    #1,WText_nr
             move.l    #Code0002Sys,Textfile_ptr
             Push      Module,TxtW_Mod
             move.l    a1,Textfile_ptr
             bra.s     .Exit
.Active:     movea.l   Current_active_char_data,a0
             move.w    Attr_7_normal(a0),d0 ; Probe luck
             add.w     Attr_7_normal_magic(a0),d0
             jsr       Probe
             bpl.s     .Exit
             move.w    Active_member,d0     ; Do bad stuff
             jsr       (a1)
.Go_on:      movea.l   Textfile_ptr,a1      ; Show text
             move.w    6(a5),WText_nr
             move.l    #Code0003Sys,Textfile_ptr
             Push      Module,TxtW_Mod
             move.l    a1,Textfile_ptr
.Exit:       movem.l   (sp)+,d0-d3/a0-a2/a5
             rts       

Trap_table:  .DC.l Damage_trap
             .DC.w 0,7
             .DC.l Poison_needle
             .DC.w 1,8
             .DC.l Poison_gas_cloud
             .DC.w 0,9
             .DC.l Blinding_flash
             .DC.w 0,10
             .DC.l Paralyzing_gas_cloud
             .DC.w 0,11
             .DC.l Stone_gaze
             .DC.w 1,12
             .DC.l Disease
             .DC.w 1,13

; [ Trap effects ]
;   IN : d0 - Number of victim's character (.w)
;        a0 - Pointer to victim's character data (.l)
; All registers are restored
Damage_trap: 
             movem.l   d1/a5,-(sp)
             movea.l   Event_data_ptr,a0    ; Get amount of damage
             move.b    3(a0),d1
             ext.w     d1
             jsr       Do_damage
             movem.l   (sp)+,d1/a0
             rts       

Poison_needle:         
             bset      #1,Body_conditions(a0)     ; Poisoned!
             rts       

Poison_gas_cloud:      
             bset      #1,Body_conditions(a0)     ; Poisoned!
             rts       

Blinding_flash:        
             bset      #4,Mind_conditions(a0)     ; Blind!
             rts       

Paralyzing_gas_cloud:  
             bset      #0,Body_conditions(a0)     ; Paralyzed!
             rts       

Stone_gaze:  
             bset      #2,Body_conditions(a0)     ; Stoned!
             rts       

Disease:     
             bset      #3,Body_conditions(a0)     ; Diseased!
             rts       

;*****************************************************************************
; [ Do damage ]
;   IN : d0 - Character number {1...6} (.w)
;        d1 - Amount of damage (.w)
; All registers are restored
;*****************************************************************************
Do_damage:   
             movem.l   d2/a0,-(sp)
             lea.l     Chard_ptrs-4,a0      ; Get pointer to character
             move.w    d0,d2                ; data
             add.w     d2,d2
             add.w     d2,d2
             adda.w    d2,a0
             tst.l     (a0)                 ; Anyone there ?
             beq.s     .Exit
             movea.l   (a0),a0
             move.w    Life_points_normal(a0),d2  ; Do the damage
             sub.w     d1,d2
             bgt.s     .Ok
             ori.w     #$2000,Body_conditions(a0) ; Kill!
             cmp.w     Active_member,d0     ; Was it our trusty leader ?
             bne.s     .No
             clr.w     Active_member        ; Select a new active member
             jsr       Exit_display
             move.l    a0,-(sp)
             Push      Module,ActSel_Mod
             movea.l   (sp)+,a0
.No:         moveq.l   #0,d2
.Ok:         move.w    d2,Life_points_normal(a0)  ; Store new LP
             move.w    d0,d2
             add.w     d2,d2
             lea.l     Char_damage,a0       ; Set damage
             move.w    d1,-2(a0,d2.w)
             lea.l     Damage_timers,a0     ; Set timer
             move.b    #10,-1(a0,d0.w)
.Exit:       movem.l   (sp)+,d2/a0
             rts       

;*****************************************************************************
; [ Show event text ]
;   IN : d0 - Message number (.b)
; All registers are restored
;*****************************************************************************
Event_text:  
             cmpi.b    #26,d0               ; Show a text ?
             bpl.s     .Exit
             ext.w     d0                   ; Show text
             move.w    d0,WText_nr
             move.l    Maptext_ptr,Textfile_ptr
             move.l    (sp)+,.Filth+2       ; DIRTY TRICK !!!
             lea.l     TxtW_Mod,a0
             move.l    #.Dirty,Return_ptr(a0)
             jsr       Push_Module
             bra.s     .Exit
.Dirty:      clr.l     TxtW_Mod+Return_ptr
             movea.l   Event_data_ptr,a5
.Filth:      jsr       $deadface            ; Modified instruction !!!
.Exit:       rts       

;*****************************************************************************
; [ Event execution routines ]
;   IN : a5 - Pointer to event data (.l)
; EVENT DATA :
;     (a5) - Event type        (.b)
;    1(a5) - Data 2            (.b)
;    2(a5) - Data 3            (.b)
;    3(a5) - Data 4            (.b)
;    4(a5) - Data 5            (.b)
;    5(a5) - Event save number (.b)
;    6(a5) - Data 6            (.w)
;    8(a5) - Data 7            (.w)
; No registers need be restored

;*****************************************************************************
; [ Map exit ]
;*****************************************************************************
Map_exit:    
             jsr       Exit_map             ; Exit current map
             moveq.l   #0,d0                ; Get new coordinates,
             move.b    1(a5),d0             ; view direction & map number
             move.w    d0,Map_Xcoord
             move.b    2(a5),d0
             move.w    d0,Map_Ycoord
             move.b    3(a5),d0
             move.w    d0,View_direction
             move.w    6(a5),Map_nr
             jsr       Init_map             ; Initialize new map
             rts       

;*****************************************************************************
; [ Travel exit ]
;*****************************************************************************
Travel_exit: 
             jsr       Exit_map             ; Exit current map
             moveq.l   #0,d0                ; Get new coordinates,
             move.b    1(a5),d0             ; view direction & map number
             move.w    d0,Map_Xcoord
             move.b    2(a5),d0
             move.w    d0,Map_Ycoord
             move.b    3(a5),d0
             move.w    d0,View_direction
             move.w    6(a5),Map_nr
             moveq.l   #0,d0                ; Back on foot
             jsr       Set_new_travel_mode
             jsr       Init_map             ; Initialize new map
             rts       

;*****************************************************************************
; [ Door ]
;*****************************************************************************
Door:        
             move.w    Special_item_flags,d0      ; Amberstar on ?
             btst      #1,d0                ; 2-1 !!!
             beq.s     .No_Amber
             tst.b     Doorexit_flag        ; [ Door_exit ] event ?
             beq.s     .No_doorexit
             jsr       Do_extra_event
             sf        Doorexit_flag        ; Clear flag
.No_doorexit:          rts                  
.No_Amber:   jsr       Exit_display
             sf        Door_opened          ; Clear flags
             sf        Trap_found
             sf        Trap_disarmed
             Push      Module,Door_Mod
             jsr       Init_display
             rts       

Door_DisUpd: 
             jsr       Update_status_block
; ------------- Re-evaluate control icons ----------------------------
             lea.l     Door_CIL,a0
             lea.l     DoorCIL_evaluate,a1
             jsr       Update_control_icons
             tst.b     Door_opened
             beq.s     .Exit
             jsr       Exit_display
             Pop       Module
             tst.b     Doorexit_flag        ; [ Door_exit ] event ?
             beq.s     .No_doorexit
             jsr       Do_extra_event
             sf        Doorexit_flag        ; Clear flag
             bra.s     .Exit
.No_doorexit:          jsr                  Init_display
.Exit:       rts       

Door_ModInit:          
             moveq.l   #13,d0               ; Load door picture
             lea.l     Lay3_target_hbl+2,a0
             jsr       Load_80x80_picture
             rts       

Door_ModExit:          
             movea.l   Pic80_ptr,a0         ; Free picture memory
             jsr       Free_memory
             rts       

Door_DisInit:          
             move.l    #Lay3_PlusMes,PlusMes_info
             move.l    #Code0002Sys,Textfile_ptr
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; New layout
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show door picture
; ------------- Do rest of display -----------------------------------
             lea.l     Door_CIL,a0          ; Show control icons
             jsr       DoorCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Object branch
             jsr       Set_layout_data
; ------------- Fade in ----------------------------------------------
             lea.l     Lay3_target_hbl,a1   ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay3_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay3_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
             lea.l     Hbl_Lay3_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

Door_Exit:   
             Restore_coords                 ; Back to old position
             jsr       Exit_display
             Pop       Module
             jmp       Init_display

Pick_lock_DOOR:        
             Wait_4_unclick 
             movea.l   Current_active_char_data,a0
             movea.l   Event_data_ptr,a5
             cmpi.b    #100,1(a5)           ; Door fully locked ?
             beq.s     .Mess
             moveq.l   #0,d0                ; Probe lockpicking skills
             move.b    Skill_7(a0),d0
             add.w     Skill_7_normal_magic(a0),d0
             move.b    1(a5),d1
             ext.w     d1
             sub.w     d1,d0
             jsr       Probe
             bpl       .Picked_it
             addi.w    #10,d1               ; Increase probe value
             cmpi.w    #100,d1
             bmi.s     .Ok
             moveq.l   #99,d1
.Ok:         move.b    d1,1(a5)
.Skip:       tst.b     Trap_disarmed        ; Trap already disarmed ?
             beq       .Trap
.Mess:       PlusMes   25                   ; Print message {25,+}
             bra       .Exit
.Trap:       move.b    2(a5),d0             ; Any trap ?
             beq.s     .Mess
             move.w    Attr_3_normal(a0),d0 ; Probe dexterity
             add.w     Attr_3_normal_magic(a0),d0
             jsr       Probe
             bpl       .No_trap
             move.b    2(a5),d0             ; Execute trap
             jsr       Execute_trap
             bra       .Exit
.No_trap:    PlusMes   1                    ; Print message {1,+}
             bra       .Exit
.Picked_it:  jsr       Save_event           ; Opened the door !!!
             st        Door_opened
             PlusMes   0                    ; Print message {0,+}
.Exit:       rts       

Use_item_DOOR:         
             Wait_4_unclick 
             lea.l     UseItemDoor_Mod,a0
             jmp       Push_Module

UseItemDoor_DisUpd:    
             jsr       Update_quantity_colours
             rts       

UseItemDoor_DisInit:   
             movea.l   Current_active_char_data,a0          ; Set object name data
             lea.l     Inventory_1_place_counter(a0),a1
             lea.l     Inv_data+360(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3    ; Show character's objects
             Update_screen 
             Push      MA,L3_objects_area   ; Set mouse area
             Wait_4_unclick 
             rts       

UseItemDoor_DisExit:   
             Pop       MA
             movea.l   Off_screen,a6
; ------------- Erase items ------------------------------------------
             lea.l     Layout_icn+9856,a0
             lea.l     Door_object_pos_list,a1
             moveq.l   #12-1,d7
.Loop:       move.w    (a1)+,d0             ; Get coordinates
             move.w    (a1)+,d1
             jsr       Put_unmasked_block
             dbra      d7,.Loop
; ------------- Erase previous object name ---------------------------
             move.w    #112,d0
             move.w    #73,d1
             move.w    #112+192-1,d2
             move.w    #73+6,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             Update_screen 
             rts       

UseItemDoor_objselect: 
             Wait_4_unclick 
             tst.b     d0                   ; Any object ?
             beq       .Exit
             move.b    d0,Object_slot_number
; ------------- Calculate data pointers ------------------------------
             movea.l   Current_active_char_data,a0
             lea.l     Inventory_1_place_counter-1(a0),a1
             lea.l     Inv_data+320(a0),a2
             ext.w     d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             movea.l   Event_data_ptr,a5

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to active character's data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object's data (.l)
;  a5 - Pointer to current event's data (.l)

             move.w    Item_ID(a2),d1       ; Right item ?
             cmp.w     6(a5),d1
             bne       .Wrong
             btst      #3,Item_stat_bits(a2)      ; Use once ?
             beq.s     .Use_more
             tst.b     5(a5)                ; Event saved ?
             beq.s     .Use_more
             subq.b    #1,(a1)              ; Remove object
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             lea.l     Door_object_pos_list-4,a3  ; Show item destruction
             move.b    Object_slot_number,d0
             ext.w     d0
             add.w     d0,d0
             add.w     d0,d0
             move.w    2(a3,d0.w),d1
             move.w    0(a3,d0.w),d0
             moveq.l   #0,d2
             move.b    (a2),d2
             move.b    Object_slot_number,d3
             ext.w     d3
             lea.l     Erase_icon+9,a3
             move.b    -1(a3,d3.w),d3
             ext.w     d3
             jsr       Show_item_destruction
.Use_more:   jsr       Save_event           ; Opened the door !!!
             st        Door_opened
             PlusMes   2                    ; Print message {2,+}
             Pop       Module
             bra       .Exit
.Wrong:      cmpi.b    #7,Spell_class(a2)   ; Special magical object ?
             bne       .Exit
             cmpi.b    #18,Spell_number(a2)
             bne       .Exit
             subq.b    #1,(a1)              ; Remove ONE item
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             cmpi.b    #100,1(a5)           ; Fully locked ?
             bmi       .Magic_works
             moveq.l   #7,d0                ; Print message {7,+}
             bra       .Skip
.Magic_works:          moveq.l              #6,d0 ; Print message {6,+}
             st        Door_opened          ; Open door
             jsr       Save_event
.Skip:       jsr       Plus_message
             Pop       Module
.Exit:       rts       

Find_trap_DOOR:        
             Wait_4_unclick 
             movea.l   Event_data_ptr,a0    ; IS there a trap ?
             tst.b     2(a0)
             beq.s     .No_find
             movea.l   Current_active_char_data,a0
             moveq.l   #0,d0                ; Probe {Find traps}
             move.b    Skill_5(a0),d0
             add.w     Skill_5_normal_magic(a0),d0
             jsr       Probe
             bpl.s     .Found_it
.No_find:    moveq.l   #4,d0                ; Print message {4,+}
             bra.s     .Go_on
.Found_it:   moveq.l   #3,d0                ; Print message {3,+}
             st        Trap_found           ; Found it! Yay!
.Go_on:      jsr       Plus_message
.Exit:       rts       

Disarm_trap_DOOR:      
             Wait_4_unclick 
             movea.l   Current_active_char_data,a0
             moveq.l   #0,d0                ; Probe {Disarm traps}
             move.b    Skill_6(a0),d0
             add.w     Skill_6_normal_magic(a0),d0
             jsr       Probe
             bpl.s     .Disarmed_it
             move.w    Attr_3_normal(a0),d0 ; Probe {Dexterity}
             add.w     Attr_3_normal_magic(a0),d0
             jsr       Probe
             bmi.s     .Trapped
             moveq.l   #1,d0                ; Print message {1,+}
             bra.s     .Go_on
.Trapped:    movea.l   Event_data_ptr,a0    ; Execute trap
             move.b    2(a0),d0
             jmp       Execute_trap
.Disarmed_it:          moveq.l              #5,d0 ; Print message {5,+}
             st        Trap_disarmed        ; Disarmed it! Yay!
.Go_on:      jsr       Plus_message
             rts       

; [ Display name of object ]
; Changed registers : d0,d1,d2,a0,a3,a6
Show2_object_name:     
             tst.b     d0                   ; Any object selected ?
             beq.s     .Exit
             movea.l   Itemdata_ptr,a0
             movea.l   Itemslots_ptr,a1
             ext.w     d0                   ; Any object there ?
             tst.b     -1(a1,d0.w)
             beq.s     .Exit
             mulu.w    #40,d0               ; Get number of word
             lea.l     -40(a0,d0.w),a0
             cmpi.b    #17,Item_type(a0)    ; Is it a monster item ?
             beq.s     .Exit
             move.w    Name_word_nr(a0),d0
             cmp.w     Object_name_nr,d0    ; Already printed ?
             beq       .Exit
             move.w    d0,Object_name_nr
             move.b    #2,Print_objname_flag
.Exit:       rts       

Erase2_object_name:    
             tst.b     d0                   ; On an object ?
             beq.s     .Skip
             move.l    #$00ffff00,d1        ; In object area ?
             and.l     d0,d1
             cmpi.l    #$00020200,d1
             beq.s     .Exit
.Skip:       move.b    #2,Erase_objname_flag
.Exit:       rts       

Upd2_objname_print:    
             tst.b     Print_objname_flag   ; Print anything ?
             beq       .Exit
             lea.l     .Init_string(pc),a0  ; Set colours
             jsr       IG_Print
             move.w    Object_name_nr,d0    ; Get word
             beq       .Exit
             jsr       Get_word
             move.w    #112,d0              ; Erase previous text
             move.w    #73,d1
             move.w    #112+192-1,d2
             move.w    #73+6,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             move.w    #192,d2              ; Print word
             lea.l     Line_buffer,a0
             jsr       Print_centered_string
             subq.b    #1,Print_objname_flag      ; Count down
.Exit:       rts       

.Init_string:          .DC.b 1,15,2,-1,0
             .EVEN 

Upd2_objname_erase:    
             tst.b     Erase_objname_flag   ; Erase anything ?
             beq       .Exit
             move.w    #112,d0              ; Erase text
             move.w    #73,d1
             move.w    #112+192-1,d2
             move.w    #73+6,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             subq.b    #1,Erase_objname_flag      ; Count down
             clr.w     Object_name_nr
.Exit:       rts       

; [ Re-evaluate control icons for Layout 3 ]
;   IN : a0 - Pointer to control icon list (.l)
; All registers are restored
DoorCIL_evaluate:      
             movem.l   d0/d7/a2,-(sp)
; ------------- Enable all icons -------------------------------------
             movea.l   a0,a2                ; Enable all icons
             moveq.l   #9-1,d7
.Loop1:      bclr      #7,(a2)+
             dbra      d7,.Loop1
; ------------- Any items in backpack ? ------------------------------
             movea.l   Current_active_char_data,a2          ; Check backpack
             lea.l     Inventory_1_place_counter(a2),a2
             move.b    (a2)+,d0
             moveq.l   #11-1,d7
.Loop2:      or.b      (a2)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Any objects ?
             bne.s     .Not_empty
             bset      #7,1(a0)             ; Disable {Use item}
; ------------- Any trap found yet ? ---------------------------------
.Not_empty:  tst.b     Trap_found
             beq.s     .Not_found
             bset      #7,3(a0)             ; Disable {Find trap}
             bra.s     .Continue
.Not_found:  bset      #7,6(a0)             ; Disable {Disarm trap}
; ------------- Trap disarmed yet ? ----------------------------------
.Continue:   tst.b     Trap_disarmed
             beq.s     .Ok
             bset      #7,6(a0)             ; Disable {Disarm trap}
; ------------- Active character blind ? -----------------------------
.Ok:         movea.l   Current_active_char_data,a1
             btst      #4,Mind_conditions(a1)
             beq.s     .Exit
             bset      #7,3(a0)             ; Disable {Find trap}
             bset      #7,6(a0)             ; Disable {Disarm trap}
.Exit:       movem.l   (sp)+,d0/d7/a2
             rts       

; [ Display quantities of objects ]
; Changed registers : d0,d1,d2,d6,d7,a0,a2,a3,a4,a6
Display2_quantities:   
             lea.l     Quant_init_string,a0 ; Set colours
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Initialize registers
             movea.l   Itemslots_ptr,a2
             lea.l     Door_object_pos_list,a4
             movea.l   Off_screen,a6
             tst.b     Quant_block          ; Display quantities ?
             bne.s     .No_quant
             moveq.l   #0,d0
             moveq.l   #2,d7
             moveq.l   #12-1,d6
.Loop1:      cmpi.b    #1,(a2)+             ; More as one object ?
             bls.s     .Next1
             move.b    -1(a2),d0            ; Get quantity
             ext.w     d0
             cmpi.w    #-1,d0               ; Infinite slot ?
             bne.s     .Finite
             moveq.l   #99,d0
.Finite:     movea.l   a0,a3                ; Convert number
             moveq.l   #" ",d1
             jsr       RConvert_number
             clr.b     (a3)                 ; Insert EOL
             moveq.l   #10,d1               ; Get coordinates
             move.w    (a4),d0
             add.w     2(a4),d1
             addq.w    #2,d0
             jsr       IG_Set_cursor
             jsr       IG_Print
.Next1:      addq.l    #4,a4                ; Next backpack object
             dbra      d6,.Loop1
             rts       
; ------------- Restore object graphics ------------------------------
.No_quant:   movea.l   Itemslots_ptr,a2
             movea.l   Itemdata_ptr,a3
             moveq.l   #12-1,d7
.Loop2:      cmpi.b    #1,(a2)+             ; More as one object ?
             bls.s     .Next2
             move.w    (a4),d0              ; Get coordinates
             move.w    2(a4),d1
             lea.l     Layout_icn+9856,a0   ; Display empty block
             jsr       Put_unmasked_block
             lea.l     Objects_icn,a0       ; Calculate graphics address
             move.b    (a3),d2
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block     ; Display object
.Next2:      lea.l     40(a3),a3            ; Next object
             addq.l    #4,a4
             dbra      d7,.Loop2
             rts       

;*****************************************************************************
; [ Show picture or text ]
;*****************************************************************************

; Flag 3(a5) :
; 0 - Eye only
; 1 - Walk only
; 2 - Eye & walk

Show_pictxt: 
             tst.b     Stygian              ; Can you see ?
             beq.s     .I_can_see
             jsr       Save_event           ; No !
             bra.s     .Exit
.I_can_see:  tst.b     Eye_flag
             beq.s     .Walk
             cmpi.b    #1,3(a5)             ; No walk ?
             bne.s     .Skip2
.Exit:       rts       
.Walk:       tst.b     3(a5)                ; Walk ?
             beq.s     .Exit
.Skip:       Update_map_display 
.Skip2:      .LOCAL 
             moveq.l   #0,d1                ; Show picture ?
             move.b    1(a5),d1
             beq       .No_pict
; ------------- Show picture & text ----------------------------------
             jsr       Exit_display
             moveq.l   #0,d0                ; Set text number
             move.b    2(a5),d0
             move.w    d0,WText_nr
             Push      Module,Pic80_Mod
             bra       .Exit
; ------------- Show text only ---------------------------------------
.No_pict:    moveq.l   #0,d0                ; Set text number
             move.b    2(a5),d0
             move.w    d0,WText_nr
             move.l    Maptext_ptr,Textfile_ptr
             Push      Module,TxtW_Mod
.Exit:       move.w    6(a5),d0             ; Set word bit ?
             beq.s     .Leave_it
             moveq.l   #$7,d1               ; Calculate bit & byte number
             and.w     d0,d1
             lsr.w     #3,d0
             lea.l     WD,a0                ; Set bit in WD array
             bset      d1,0(a0,d0.w)
.Leave_it:   jsr       Save_event           ; Save event if necessary
             rts       

; ************* 80x80 picture module **********************
P80_ModInit: 
             lea.l     Pics80_filename,a0   ; Load picture + palette
             move.w    d1,d0
             add.w     d1,d0
             jsr       Load_subfile
             move.l    a0,Pic80pal_ptr
             lea.l     Pics80_filename,a0
             subq.w    #1,d0
             jsr       Load_subfile
             move.l    a0,Pic80_ptr
             jmp       P80_DisInit

P80_ModExit: 
             movea.l   Pic80pal_ptr,a0      ; Return memory
             jsr       Free_memory
             movea.l   Pic80_ptr,a0
             jsr       Free_memory
             jmp       P80_DisExit

P80_DisInit: 
             Push      PA,P80_PA            ; Set areas
             Push      MA,P80_area
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #7,d0                ; New layout
             jsr       Show_layout
             moveq.l   #16,d0               ; Display 80x80 block
             moveq.l   #49+32,d1
             moveq.l   #5,d6
             moveq.l   #80,d7
             movea.l   Pic80_ptr,a0
             jsr       Blot_unmasked_block
             Update_screen 
; ------------- Fade in ----------------------------------------------
             movea.l   Pic80pal_ptr,a1      ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_pic80_list,a0    ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 3 Vbl's
             jsr       My_vsync
             jsr       My_vsync
             lea.l     Pic80_below,a0       ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_pic80_list,a0    ; Update palettes
             jsr       Update_HBL
             movea.l   Maptext_ptr,a1       ; Print text
             move.w    WText_nr,d0
             jsr       Mr_Blue_Sky
             jsr       Pop_Module           ; Exit
             jmp       Init_display

P80_DisExit: 
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_pic80_list,a0    ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 3 Vbl's
             jsr       My_vsync
             jsr       My_vsync
             lea.l     Pic80_below,a0       ; Fade palette
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_pic80_list,a0    ; Update palettes
             jsr       Update_HBL
             Pop       PA
             Pop       MA
             rts       

; ************* Text window module ************************
TxtW_ModInit:          
             movem.l   d0-d7/a0-a6,-(sp)
             Push      PA,TxtW_PA           ; Install fake PA
             move.w    WText_nr,d0          ; Convert the text to ASCII
             move.w    Nr_of_chars,d2
             movea.l   Textfile_ptr,a1
             jsr       Prepare_text_block
             move.w    Lines_in_text,d0     ; Window large enough ?
             mulu.w    #7,d0
             cmpi.w    #7*16,d0
             bhi       .Scroll              ; No, scroll
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
             Pop       PA                   ; Re-install PA
             Push      PA,TxtW_PA
             movea.l   Text_buffer,a0       ; Print text
             movea.l   Off_screen,a6
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d7
             bra.s     .Entry
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry:      dbra      d7,.Loop
             Update_screen 
             movea.l   Text_buffer,a0       ; Free old text
             jsr       Free_memory
             bra.s     .Exit
.Scroll:     moveq.l   #16,d0               ; Open a window
             moveq.l   #52,d1
             moveq.l   #18,d2
             moveq.l   #9,d3
             moveq.l   #0,d6
             suba.l    a0,a0
             jsr       Open_window
             move.w    d0,Window_handle
             movea.l   Text_buffer,a0       ; Free old text
             jsr       Free_memory
             Pop       PA                   ; Install new print area
             Push      PA,MaxTxtW_PA
             movea.l   Textfile_ptr,a1      ; Print & scroll text
             move.w    WText_nr,d0
             jsr       Mr_Blue_Sky
             Pop       Module               ; Exit
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

TxtW_ModExit:          
             movem.l   d0/a0,-(sp)
             move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             Pop       PA
             Wait_4_unclick 
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Item found event ]
;   IN : a5 - Pointer to event data (.l)
; Changed registers : d0,d1,d2,d7,a0
;*****************************************************************************
Item_found:  
; ------------- Is the chest hidden ? --------------------------------
             tst.b     4(a5)                ; Well, is it ?
             beq.s     .Not_hidden
             movea.l   Current_active_char_data,a0          ; Probe {Searching}
             moveq.l   #0,d0
             move.b    Skill_8(a0),d0
             add.w     Skill_8_normal_magic(a0),d0
             jsr       Probe
             bmi       .Exit
; ------------- Is the chest already open ? --------------------------
.Not_hidden: movea.l   EVENT_ptr,a0         ; Event saved ?
             move.w    EVENT_bit,d0
             btst      d0,(a0)
             bne.s     .Opened
             tst.b     1(a5)                ; 0 % locked ?
             beq.s     .Opened
             move.w    Special_item_flags,d0      ; Amberstar on ?
             btst      #1,d0
             bne.s     .Opened
             jsr       Exit_display         ; Fade out
             sf        Door_opened          ; Clear flags
             sf        Trap_found
             sf        Trap_disarmed
             Push      Module,ClosedChest_Mod     ; Closed chest
             bra       .Exit
.Opened:     jsr       Init_chest
             bne.s     .Full                ; Is the chest empty ?
             tst.w     Current_chest_gold   ; What ? No gold either ?
             beq.s     .Exit
.Full:       jsr       Exit_display         ; Fade out
             Push      Module,OpenedChest_Mod     ; Opened chest
.Exit:       rts       

Chest_exit:  
             Restore_coords 
             jsr       Exit_display
             Pop       Module
             jmp       Init_display

; [ Initialize chest ]
;   IN : a5 - Pointer to event data (.l)
;  OUT :     zero = Bugger! This thing's empty!
;        non-zero = Yay! It's full of loot!
; All registers are restored
Init_chest:  
             movem.l   d0-d2/d7/a0,-(sp)
             move.w    6(a5),d7             ; Get chest number
             lea.l     Chest_gold,a0        ; Get amount of gold
             move.w    d7,d0
             add.w     d0,d0
             move.w    0(a0,d0.w),Current_chest_gold
             lea.l     Chest,a0             ; Get slot bit-list
             subq.w    #1,d7                ; DOUBLE FUCK !!!
             move.w    d7,d0
             lsr.w     #1,d0
             move.w    d0,d1
             add.w     d0,d0
             add.w     d1,d0
             btst      #0,d7
             bne.s     .Odd
             move.b    1(a0,d0.w),d2        ; Get 12 bits - even
             lsl.w     #8,d2
             move.b    0(a0,d0.w),d2
             lsr.w     #1,d2
             bra       .Continue
.Odd:        move.b    2(a0,d0.w),d2        ; Get 12 bits - odd
             lsl.w     #8,d2
             move.b    1(a0,d0.w),d2
             lsr.w     #5,d2
             moveq.l   #1,d1
             and.b     3(a0,d0.w),d1
             ror.w     #5,d1
             or.w      d1,d2
.Continue:   andi.w    #$0fff,d2            ; Mask off rubbish & store
             move.w    d2,Current_chest_slots
             movem.l   (sp)+,d0-d2/d7/a0
             rts       

;*****************************************************************************
; [ Closed Chest module ]
;*****************************************************************************

; ************* Closed Chest - Initialize module **********
ClosedChest_ModInit:   
             moveq.l   #12,d0               ; Load closed chest picture
             lea.l     Lay3_target_hbl+2,a0
             jsr       Load_80x80_picture
             jmp       Init_display

; ************* Closed Chest - Exit module ****************
ClosedChest_ModExit:   
             movea.l   Pic80_ptr,a0         ; Free memory
             jmp       Free_memory

; ************* Closed Chest - Initialize display *********
ClosedChest_DisInit:   
             move.l    #Lay3_PlusMes,PlusMes_info
             move.l    #Code0002Sys,Textfile_ptr
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show closed chest
             lea.l     ClosedChest_CIL,a0   ; Show control icons
             jsr       ClosedChestCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

; ************* Closed Chest - Update display *************
ClosedChest_DisUpd:    
; ------------- Update display ---------------------------------------
             jsr       Update_status_block  ; Update status block
             lea.l     ClosedChest_CIL,a0   ; Update control icons
             lea.l     ClosedChestCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Update_quantity_colours    ; Update quantity colours
; ------------- Check if the chest has been opened -------------------
             tst.b     Door_opened          ; Well ?
             beq.s     .Exit
             st        Fade_block           ; Open chest
             Pop       Module
             movea.l   Event_data_ptr,a5
             jsr       Init_chest
             Push      Module,OpenedChest_Mod
             sf        Fade_block
.Exit:       rts       

; ************* Closed Chest - Use Item icon **************
Use_item_CHEST:        
             lea.l     UseItemChest_Mod,a0
             jmp       Push_Module

; ************* Closed Chest - Use item *******************
UseItemChest_objselect:                     
             tst.b     d0                   ; Any object ?
             beq       .Exit
; ------------- Calculate data pointers ------------------------------
             movea.l   Current_active_char_data,a0
             lea.l     Inventory_1_place_counter-1(a0),a1
             lea.l     Inv_data+320(a0),a2
             ext.w     d0
             adda.w    d0,a1
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a2
             movea.l   Event_data_ptr,a5

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Object slot number (.w)
;  a0 - Pointer to active character's data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object's data (.l)
;  a5 - Pointer to current event's data (.l)

             cmpi.b    #7,Spell_class(a2)   ; Special magical object ?
             bne       .Exit
             cmpi.b    #18,Spell_number(a2)
             bne       .Exit
             subq.b    #1,(a1)              ; Remove ONE item
             cmpi.b    #100,1(a5)           ; Fully locked ?
             bmi       .Magic_works
             moveq.l   #7,d0                ; Print message {7,+}
             bra       .Skip
.Magic_works:          moveq.l              #6,d0 ; Print message {6,+}
             st        Door_opened          ; Opened the chest !!!
             jsr       Save_event
.Skip:       jsr       Plus_message
             Pop       Module
.Exit:       rts       

; ************* Closed Chest - Re-evaluate control icons ***
ClosedChestCIL_evaluate:                    
             movem.l   d0/d7/a1,-(sp)
; ------------- Enable all icons -------------------------------------
             bclr      #7,(a0)              ; Enable {Pick lock}
             bclr      #7,1(a0)             ;        {Use item}
             bclr      #7,3(a0)             ;        {Find trap}
             bclr      #7,6(a0)             ;        {Disarm trap}
; ------------- Any items in backpack ? ------------------------------
             movea.l   Current_active_char_data,a1          ; Check backpack
             lea.l     Inventory_1_place_counter(a1),a1
             move.b    (a1)+,d0
             moveq.l   #11-1,d7
.Loop:       or.b      (a1)+,d0
             dbra      d7,.Loop
             tst.b     d0                   ; Any objects ?
             bne.s     .Not_empty
             bset      #7,1(a0)             ; Disable {Use item}
; ------------- Any trap found yet ? ---------------------------------
.Not_empty:  tst.b     Trap_found
             beq.s     .Not_found
             bset      #7,3(a0)             ; Disable {Find trap}
             bra.s     .Continue
.Not_found:  bset      #7,6(a0)             ; Disable {Disarm trap}
; ------------- Trap disarmed yet ? ----------------------------------
.Continue:   tst.b     Trap_disarmed
             beq.s     .Ok
             bset      #7,6(a0)             ; Disable {Disarm trap}
; ------------- Active character blind ? -----------------------------
.Ok:         movea.l   Current_active_char_data,a1
             btst      #4,Mind_conditions(a1)
             beq.s     .Exit
             bset      #7,3(a0)             ; Disable {Find trap}
             bset      #7,6(a0)             ; Disable {Disarm trap}
.Exit:       movem.l   (sp)+,d0/d7/a1
             rts       

;*****************************************************************************
; [ Opened Chest module ]
;*****************************************************************************

; ************* Opened Chest - Initialize module **********
OpenedChest_ModInit:   
             moveq.l   #21,d0               ; Load opened chest picture
             lea.l     Lay3_target_hbl+2,a0
             jsr       Load_80x80_picture
             movea.l   Event_data_ptr,a0    ; Get chest number
             move.w    6(a0),d0
             lea.l     Chestdata_filename,a0      ; Load chest data
             jsr       Load_subfile
             move.l    a0,Chestdata_ptr
; ------------- Create slot list -------------------------------------
             lea.l     Chest_slot_list+12,a1
             move.w    Current_chest_slots,d0
             moveq.l   #12-1,d7
.Loop:       btst      d7,d0                ; Bit set ?
             sne       -(a1)                ; Set slot
             dbra      d7,.Loop
             jsr       Init_display
; ------------- Show a text ? ----------------------------------------
             movea.l   Event_data_ptr,a0    ; Well ?
             move.w    8(a0),d0
             cmpi.b    #26,d0
             bpl.s     .Exit
             ext.w     d0                   ; Show text
             move.l    Maptext_ptr,Textfile_ptr
             jsr       Plus_message
.Exit:       rts       

; ************* Opened Chest - Exit module ****************
OpenedChest_ModExit:   
; ------------- Write back chest data --------------------------------
             lea.l     Chest_slot_list+12,a0      ; Make new slot bit-list
             moveq.l   #0,d2
             moveq.l   #12-1,d7
.Loop:       tst.b     -(a0)                ; Slot filled ?
             beq.s     .Next
             bset      d7,d2
.Next:       dbra      d7,.Loop
             movea.l   Event_data_ptr,a0    ; Get chest number
             move.w    6(a0),d7
             lea.l     Chest_gold,a0        ; Write amount of gold
             move.w    d7,d0
             add.w     d0,d0
             move.w    Current_chest_gold,0(a0,d0.w)
             lea.l     Chest,a0             ; Write slot bit-list
             subq.w    #1,d7                ; DOUBLE FUCK !!!
             move.w    d7,d0
             lsr.w     #1,d0
             move.w    d0,d1
             add.w     d0,d0
             add.w     d1,d0
             btst      #0,d7
             bne.s     .Odd
             andi.b    #$01,0(a0,d0.w)      ; Clear 12 bits
             andi.b    #$e0,1(a0,d0.w)
             lsl.w     #1,d2                ; Write 12 bits - even
             or.b      d2,0(a0,d0.w)
             lsr.w     #8,d2
             or.b      d2,1(a0,d0.w)
             bra       .Continue
.Odd:        andi.b    #$1f,1(a0,d0.w)      ; Clear 12 bits
             andi.b    #$fe,3(a0,d0.w)
             move.w    #$0800,d1            ; Write 12 bits - odd
             and.w     d2,d1
             rol.w     #5,d1
             or.b      d1,3(a0,d0.w)
             lsl.w     #5,d2
             or.b      d2,1(a0,d0.w)
             lsr.w     #8,d2
             move.b    d2,2(a0,d0.w)
; ------------- Free memory ------------------------------------------
.Continue:   movea.l   Pic80_ptr,a0
             jsr       Free_memory
             movea.l   Chestdata_ptr,a0
             jmp       Free_memory

; ************* Opened Chest - Initialize display *********
OpenedChest_DisInit:   
             move.l    #Lay3_PlusMes,PlusMes_info
             Push      PA,Lay3_PA
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             move.l    Chestdata_ptr,Itemdata_ptr ; Set object name data
             move.l    #Chest_slot_list,Itemslots_ptr
             jsr       Show_objects_LAY3    ; Show objects
; ------------- Display gold -----------------------------------------
             tst.w     Current_chest_gold   ; Any gold ?
             sne       Gold_in_chest_flag
             beq.s     .No_gold
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             move.w    #112,d0              ; Print "GOLD"
             move.w    #113,d1
             move.w    #64,d2
             lea.l     Gold_txt,a0
             jsr       Print_centered_string
; ------------- Rest of display --------------------------------------
.No_gold:    jsr       Display_80x80_picture      ; Show closed chest
             lea.l     OpenedChest_CIL,a0   ; Show control icons
             jsr       OpenedChestCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jsr       Fadein_lay3          ; Fade in
             rts       

; ************* Opened Chest - Update display *************
OpenedChest_DisUpd:    
; ------------- Update display ---------------------------------------
             jsr       Update_status_block  ; Update status block
             lea.l     OpenedChest_CIL,a0   ; Update control icons
             lea.l     OpenedChestCIL_evaluate,a1
             jsr       Update_control_icons
; ------------- Print gold -------------------------------------------
             tst.b     Gold_in_chest_flag   ; Any gold at all ?
             beq.s     .No_gold
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             move.w    Current_chest_gold,d0      ; Convert gold
             moveq.l   #"0",d1
             moveq.l   #5,d7
             lea.l     GoldDis_text,a0
             movea.l   a0,a3
             jsr       RConvert_number
             move.w    #112,d0              ; Print gold
             move.w    #113+8,d1
             move.w    #64,d2
             movea.l   Off_screen,a6
             jsr       Print_centered_string
.No_gold:    rts       

; ************* Opened Chest - Re-evaluate control icons ***
OpenedChestCIL_evaluate:                    
; ------------- Enable all icons -------------------------------------
             bclr      #7,5(a0)             ; Enable {Transfer item}
             bclr      #7,7(a0)             ;        {Transfer gold}
             bclr      #7,8(a0)             ;        {Divide gold}
; ------------- Any gold in chest ? ----------------------------------
             tst.w     Current_chest_gold   ; Well ?
             bne.s     .Gold_OK
             bset      #7,7(a0)             ; Disable {Transfer gold}
             bset      #7,8(a0)             ;         {Divide gold}
; ------------- Any items in chest ? ---------------------------------
.Gold_OK:    lea.l     Chest_slot_list,a1   ; Well ?
             move.l    (a1)+,d0
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             bne.s     .Exit
             bset      #7,5(a0)             ; Disable {Transfer item}
.Exit:       rts       

; ************* Opened Chest - Transfer item **************
Transfer_item_CHEST:   
             Wait_4_unclick 
             lea.l     TIChest_Mod,a0
             jmp       Push_Module

TIChest_DisInit:       
             movem.l   d0/a6,-(sp)
             SetMesMin                      112,66,192,Code0001Sys
             Push      MA,Lay3_L2           ; Mouse in object area
             movea.l   Off_screen,a6        ; Print message {4,-}
             MesMin    4
             Update_screen 
             Wait_4_unclick 
             movem.l   (sp)+,d0/a6
             rts       

Do_TIChest:  
             tst.b     d0                   ; Any slot selected ?
             bne.s     .A_slot
.Exit:       jmp       Pop_Module
.A_slot:     ext.w     d0
             lea.l     Chest_slot_list-1,a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     .Exit
             movea.l   Chestdata_ptr,a2
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
             move.l    #Chest_Do_TI,TIVS_Ptr
             lea.l     TIVS2_Mod,a0
             move.w    #24,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       rts       

; [ Transfer the item ]
;   IN : a0 - Pointer to victim's character data (.l)
Chest_Do_TI: 
             lea.l     Chest_slot_list,a2   ; Initialize registers
             movea.l   Chestdata_ptr,a3
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
             lea.l     Chest_slot_list,a0   ; Chest empty ?
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             Pop       Module
.Exit:       rts       

; ************* Opened Chest - Transfer gold **************
Transfer_gold_CHEST:   
             Wait_4_unclick 
             movem.l   d0/a6,-(sp)
             SetMesMin                      112,66,192,Code0001Sys
             movea.l   Off_screen,a6        ; Print message {6,-}
             MesMin    6
             Update_screen 
             Wait_4_unclick 
             moveq.l   #0,d0                ; Set parameters
             move.w    Current_chest_gold,d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TransGoldCHEST_Mod  ; Requester
             movem.l   (sp)+,d0/a6
             rts       

TGCHEST_DisInit:       
             movem.l   d0-d7/a0-a6,-(sp)
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit
             movea.l   Off_screen,a6
; ------------- Fill window ------------------------------------------
             move.w    #Gold_icon,d0        ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             lea.l     Gold_txt,a0          ; Print word
             jsr       IG_Print
             move.w    #32+17,d0            ; Set cursor
             move.w    #80+38+32,d1
             jsr       IG_Set_cursor
             moveq.l   #14,d0               ; Convert text
             lea.l     Code0001Sys,a1
             jsr       Convert_text_line
             lea.l     Line_buffer,a0       ; Print line
             jsr       IG_Print
             Update_screen 
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

TGCHEST_Return:        
             movem.l   d0/d1/a0,-(sp)
             move.l    ItemW_nr,d0          ; Any coins ?
             beq       .Exit
             move.w    d0,d1                ; Calculate weight
             mulu.w    #Gold_weight,d0
             suba.l    a0,a0
             jsr       Scan_4_gold_victims
             bne.s     .Go                  ; ANYONE interested ?
             PlusMes   5                    ; Print message {5,+}
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             move.l    #Do_TGCHEST,TIVS_Ptr ; Select transfer victim
             lea.l     TIVS2_Mod,a0
             move.w    #25,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       movem.l   (sp)+,d0/d1/a0
             Wait_4_unclick 
             rts       

; [ Transfer the gold ]
;   IN : a0 - Pointer to victim's character data (.l)
Do_TGCHEST:  
             move.l    d0,-(sp)
             move.l    ItemW_nr,d0          ; Transfer gold coins
             add.w     d0,Gold_coins(a0)
             sub.w     d0,Current_chest_gold
             mulu.w    #Gold_weight,d0      ; Adjust weight
             add.l     d0,Weight_normal(a0)
             move.l    (sp)+,d0
             rts       

; ************* Opened Chest - Divide gold ****************
Divide_gold_CHEST:     
             Wait_4_unclick 
             moveq.l   #0,d0                ; Get number of gold coins
             move.w    Current_chest_gold,d0
             jsr       Divide_gold          ; Divide
             move.w    d0,Current_chest_gold      ; Store remainder
             rts       

;*****************************************************************************
; [ Trap door ]
;*****************************************************************************
Trap_door:   
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
             tst.b     3(a5)                ; Floor or ceiling ?
             beq       .Exit
; ------------- Damage -----------------------------------------------
             lea.l     Chard_ptrs,a0        ; Damage the party
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1
             move.w    #$e400,d2            ; Alive and kicking ?
             and.w     Body_conditions(a1),d2
             bne.s     .Next
             jsr       Random               ; Hurt person
             move.w    d0,d1
             mulu.w    8(a5),d1
             swap.w    d1
             addq.w    #1,d1
             move.w    d7,d0
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
; ------------- Exit map ---------------------------------------------
             jsr       Exit_map             ; Exit current map
             moveq.l   #0,d0                ; Get new coordinates
             move.b    1(a5),d0             ;  & map number
             move.w    d0,Map_Xcoord
             move.b    2(a5),d0
             move.w    d0,Map_Ycoord
             move.w    6(a5),Map_nr
             jsr       Init_map             ; Initialize new map
             jsr       Save_event
.Exit:       rts       

;*****************************************************************************
; [ Teleporter ]
;*****************************************************************************
Teleporter:  
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- Teleport ! -------------------------------------------
             move.w    6(a5),d0             ; Same map ?
             cmp.w     Map_nr,d0
             beq.s     .Same
             jsr       Map_exit             ; Exit map
             bra.s     .Exit
.Same:       moveq.l   #0,d0                ; Set new coordinates
             move.b    1(a5),d0
             move.w    d0,Map_Xcoord
             move.b    2(a5),d0
             move.w    d0,Map_Ycoord
             cmpi.b    #2,Current_map_type  ; 3D map ?
             bmi.s     .No_3D
             jsr       Update_automap       ; Update !
.No_3D:      move.b    3(a5),d0             ; Set new view direction
             cmpi.w    #4,d0                ; Keep old ?
             beq.s     .Skip
             move.w    d0,View_direction    ; No! Set new
.Skip:       cmpi.b    #0,Current_map_type  ; 2D city ?
             bne.s     .Exit
             jsr       Recalc_mapbuf_coords ; Recalculate !
.Exit:       jsr       Save_event
             rts       

;*****************************************************************************
; [ Windgate ]
;*****************************************************************************
Wind_gate:   
             move.w    Special_item_flags,d0      ; Got the windchain ?
             btst      #3,d0                ; 4-1 !!
             bne.s     .Do_it
             rts       
.Do_it:      jmp       Teleporter           ; Teleport !

;*****************************************************************************
; [ Spinner ]
;*****************************************************************************
Spinner:     
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- Spin it ! --------------------------------------------
             move.b    1(a5),d0             ; Get direction
             ext.w     d0
             cmpi.w    #4,d0                ; Random or absolute ?
             bmi.s     .Absolute
.Repeat:     jsr       Random               ; Random !
             andi.w    #$0003,d0
             cmp.w     View_direction,d0    ; The same ?
             beq.s     .Repeat
.Absolute:   move.w    d0,View_direction    ; Set new view direction
             jsr       Save_event
             rts       

;*****************************************************************************
; [ Damage field ]
;*****************************************************************************
Damage_field:          
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- Do the damage ! --------------------------------------
             move.b    2(a5),d2             ; 0-Male, 1-Female, 2-Both
             lea.l     Chard_ptrs,a0
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d3            ; Alive and kicking ?
             and.w     Body_conditions(a1),d3
             bne.s     .Next
             cmpi.b    #2,d2                ; Both sexes ?
             beq.s     .Both
             cmp.b     Character_sex(a1),d2 ; Right sex ?
             bne.s     .Next
.Both:       moveq.l   #0,d1                ; How much damage ?
             move.b    1(a5),d1
             jsr       Random
             mulu.w    d0,d1
             swap.w    d1
             addq.w    #1,d1
             move.w    d7,d0                ; Hurt! Pain!
             jsr       Do_damage
.Next:       addq.l    #4,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             jsr       Save_event
             rts       

;*****************************************************************************
; [ Anti magic ]
;*****************************************************************************
Anti_magic:  
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- No more magic ! --------------------------------------
             move.b    1(a5),d0             ; All or one ?
             bne.s     .One
             moveq.l   #0,d0                ; Clear all spells
             lea.l     Spell_1_duration,a0
             move.l    d0,(a0)+
             move.l    d0,(a0)+
             move.l    d0,(a0)+
             lea.l     Spell_1_data,a0
             move.l    d0,(a0)+
             move.l    d0,(a0)+
             move.l    d0,(a0)+
             bra.s     .Exit
.One:        ext.w     d0                   ; Clear one spell
             add.w     d0,d0
             lea.l     Spell_1_duration,a0
             clr.w     -2(a0,d0.w)
             lea.l     Spell_1_data,a0
             clr.w     -2(a0,d0.w)
.Exit:       jsr       Save_event
             rts       

;*****************************************************************************
; [ Life-points regeneration ]
;*****************************************************************************
Lp_regen:    
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- Pump up the juice ! ----------------------------------
             move.b    1(a5),d0             ; Top em all up ?
             bne       .No
             lea.l     Chard_ptrs,a0
             moveq.l   #6-1,d7
.Loop1:      tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next1
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next1
             move.w    Life_points_max(a1),d0     ; Fill it up !
             add.w     Life_points_max_magic(a1),d0
             cmp.w     Life_points_normal(a1),d0  ; Less than normal ?
             bmi.s     .Next1
             move.w    d0,Life_points_normal(a1)
.Next1:      addq.l    #4,a0                ; Next character
             dbra      d7,.Loop1
             bra       .Exit
.No:         lea.l     Chard_ptrs,a0
             ext.w     d0
             moveq.l   #6-1,d7
.Loop2:      tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next2
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next2
             move.l    a0,-(sp)             ; Increase LP
             movea.l   a1,a0
             jsr       Increase_LP
             movea.l   (sp)+,a0
.Next2:      addq.l    #4,a0                ; Next character
             dbra      d7,.Loop2
.Exit:       jsr       Save_event
             rts       

;*****************************************************************************
; [ Spell-points regeneration ]
;*****************************************************************************
Sp_regen:    
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
; ------------- Pump up the juice ! ----------------------------------
             move.b    1(a5),d0             ; Top em all up ?
             bne       .No
             lea.l     Chard_ptrs,a0
             moveq.l   #6-1,d7
.Loop1:      tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next1
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next1
             move.w    Power_points_max(a1),d0    ; Fill it up !
             add.w     Power_points_max_magic(a1),d0
             cmp.w     Power_points_normal(a1),d0 ; Less than normal ?
             bmi.s     .Next1
             move.w    d0,Power_points_normal(a1)
.Next1:      addq.l    #4,a0                ; Next character
             dbra      d7,.Loop1
             bra       .Exit
.No:         lea.l     Chard_ptrs,a0
             ext.w     d0
             moveq.l   #6-1,d7
.Loop2:      tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next2
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next2
             move.w    Power_points_normal(a1),d1 ; Add a bit
             move.w    Power_points_max(a1),d2
             add.w     Power_points_max_magic(a1),d2
             cmp.w     d2,d1                ; Already too much ?
             bpl.s     .Next2
             add.w     d0,d1
             cmp.w     d2,d1                ; Not too much !
             bmi.s     .Ok
             move.w    d2,d1
.Ok:         move.w    d1,Power_points_normal(a1)
.Next2:      addq.l    #4,a0                ; Next character
             dbra      d7,.Loop2
.Exit:       jsr       Save_event
             rts       

;*****************************************************************************
; [ Riddle-mouth ]
;*****************************************************************************
Riddle_mouth:          
             jsr       Exit_display
             Push      Module,RiddleM_Mod
             jsr       Init_display
             rts       

RiddleM_DisUpd:        
             jsr       Update_status_block
             tst.b     Door_opened          ; Did it ?
             beq.s     .Exit
             movea.l   Event_data_ptr,a5    ; Did it !
             jsr       Save_event
             jsr       Wait_4_user          ; Wait for left click
             jsr       Exit_display
             Pop       Module
             jsr       Init_display
.Exit:       rts       

RiddleM_ModInit:       
             moveq.l   #17,d0               ; Load mouth picture
             lea.l     Palette_buffer,a0
             jsr       Load_80x80_picture
             Push      PA,Lay9_PA           ; Set area
             sf        Door_opened          ; Clear flag
             rts       

RiddleM_ModExit:       
             Pop       PA                   ; Remove area
             movea.l   Pic80_ptr,a0         ; Free picture memory
             jsr       Free_memory
             rts       

RiddleM_DisInit:       
             move.l    #Lay9_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #9,d0                ; New layout
             jsr       Show_layout
             move.w    #224,d0              ; Show door picture
             moveq.l   #49,d1
             moveq.l   #5,d6
             moveq.l   #80,d7
             movea.l   Pic80_ptr,a0
             jsr       Blot_unmasked_block
             move.l    #RiddleM_CIL,Control_list_ptr        ; Display control icons
             jsr       Show_control_icons
             Update_screen 
; ------------- Fade in ----------------------------------------------
             lea.l     Palette_buffer,a1    ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay9_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay9_below,a0        ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay9_list,a0     ; Update palettes
             jsr       Update_HBL
; ------------- Open eyes --------------------------------------------
             move.w    #224,d0              ; Initialize registers
             move.w    #49+11,d1
             move.w    #1160,d2
             moveq.l   #4-1,d5
             moveq.l   #5,d6
             moveq.l   #29,d7
             lea.l     RiddleM_graphics,a0
.Loop:       movea.l   Off_screen,a6        ; Show animation frame
             jsr       Blot_unmasked_block
             jsr       Switch_screen
             moveq.l   #7-1,d3              ; Wait
.Wait:       jsr       My_vsync
             dbra      d3,.Wait
             adda.w    d2,a0                ; Next frame
             dbra      d5,.Loop
             jsr       Copy_screen
             moveq.l   #20-1,d7             ; Wait
.Wait2:      jsr       My_vsync
             dbra      d7,.Wait2
             jsr       Ask_riddleM          ; Print question
             rts       

RiddleM_DisExit:       
; ------------- Open eyes --------------------------------------------
             move.w    #224,d0              ; Initialize registers
             move.w    #49+11,d1
             move.w    #1160,d2
             moveq.l   #4-1,d5
             moveq.l   #5,d6
             moveq.l   #29,d7
             lea.l     RiddleM_graphics+3480,a0
.Loop:       movea.l   Off_screen,a6        ; Show animation frame
             jsr       Blot_unmasked_block
             jsr       Switch_screen
             moveq.l   #7-1,d3              ; Wait
.Wait1:      jsr       My_vsync
             dbra      d3,.Wait1
             suba.w    d2,a0                ; Next frame
             dbra      d5,.Loop
             jsr       Copy_screen
             moveq.l   #20-1,d7             ; Wait
.Wait2:      jsr       My_vsync
             dbra      d7,.Wait2
; ------------- Fade out ---------------------------------------------
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay9_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay9_below,a0        ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Lay9_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

RiddleM_Exit:          
             jsr       Exit_display
             Pop       Module
             jmp       Init_display

Answer_riddleM:        
             lea.l     WSelW_Mod,a0         ; Select a word
             move.l    #Check_answer_riddleM,Return_ptr(a0)
             jsr       Push_Module
             Wait_4_unclick 
             rts       

Check_answer_riddleM:  
             tst.b     No_word_entered      ; Any word entered ?
             bne       .Exit
             movea.l   Event_data_ptr,a5    ; Is it the one ?
             move.w    Found_word,d0
             cmp.w     6(a5),d0
             bne.s     .Wrong
             moveq.l   #$7,d1               ; Calculate bit & byte number
             and.w     d0,d1
             lsr.w     #3,d0
             lea.l     WD,a0                ; Set bit in WD array
             bset      d1,0(a0,d0.w)
             move.w    8(a5),d2             ; Change icon
             beq.s     .No_icon
             moveq.l   #0,d0
             move.b    1(a5),d0
             moveq.l   #0,d1
             move.b    2(a5),d1
             movea.l   Mapd_ptr,a0
             jsr       Do_change_icon
             tst.b     5(a5)                ; Save event ?
             beq.s     .No_icon
             jsr       Enter_modification
.No_icon:    st        Door_opened          ; Set flag
             moveq.l   #0,d0                ; Any message ?
             move.b    4(a5),d0
             cmpi.w    #26,d0
             beq.s     .No_text
             move.w    d0,PlusMes_nr        ; Print message
             move.l    Maptext_ptr,Textfile_ptr
             Push      Module,RiddleMes_Mod
.No_text:    bra.s     .Exit
.Wrong:      moveq.l   #11,d0               ; Set plus message
             lea.l     Code0002Sys,a1
             move.w    d0,PlusMes_nr
             move.l    a1,Textfile_ptr
             jsr       Calc_textblock_address     ; Modify message
             move.w    Found_word,d0
             bne.s     .Yes                 ; Any word ?
             move.w    #ThatCode,d0
.Yes:        move.w    d0,(a1)
             Push      Module,RiddleMes_Mod ; Print message
.Exit:       rts       

Ask_riddleM: 
             movea.l   Event_data_ptr,a5
             moveq.l   #0,d0                ; Any message ?
             move.b    3(a5),d0
             cmpi.w    #26,d0
             beq.s     .Exit
             move.w    d0,PlusMes_nr        ; Print message
             move.l    Maptext_ptr,Textfile_ptr
             lea.l     RiddleMes_Mod,a0
             jsr       Push_Module
.Exit:       rts       

; [ Riddlemouth message ]
RiddleMes:   
             jsr       Mouse_off
             movea.l   PlusMes_info,a0      ; Install mouse & print areas
             jsr       Push_MA
             addq.l    #8,a0
             jsr       Push_PA
             movea.l   Off_screen,a6        ; Erase previous text
             jsr       Erase_text_window
             move.w    PlusMes_nr,d0        ; Convert text
             move.w    Nr_of_chars,d2
             movea.l   Textfile_ptr,a1
             jsr       Prepare_text_block
             movea.l   Text_buffer,a0       ; Print text
             move.w    Nr_of_chars,d0
             addq.w    #1,d0
             move.w    Lines_in_text,d7
             subq.w    #1,d7
.Loop1:      jsr       IG_Print
             jsr       IG_Carriage_return
             adda.w    d0,a0
             dbra      d7,.Loop1
             Update_screen 
             moveq.l   #2,d7                ; Speak!
.Loop2:      jsr       Random               ; Open mouth randomly
             andi.w    #$7,d0
             beq.s     .Loop2
             jsr       .Move_mouth
             dbra      d7,.Loop2
             jsr       Copy_screen
             Pop       MA                   ; Remove mouse & print areas
             Pop       PA
             movea.l   Text_buffer,a0       ; De-allocate text buffer
             jsr       Free_memory
             Wait_4_unclick 
             jsr       Mouse_on
             jmp       Pop_Module

; [ Move mouth ]
;   IN : d0 - Last frame number {0...7} (.w)
; All registers are restored
.Move_mouth: 
             movem.l   d0-d3/d6/d7/a0/a6,-(sp)
             move.w    d0,d3                ; Initialize registers
             move.w    #224,d0
             move.w    #49+41,d1
             moveq.l   #0,d2
             moveq.l   #5,d6
             moveq.l   #15,d7
.Loop3:      jsr       .Show_mouth_frame    ; Open mouth
             addq.w    #1,d2
             cmp.w     d2,d3
             bpl.s     .Loop3
             subq.w    #2,d2                ; Close mouth
.Loop4:      jsr       .Show_mouth_frame
             subq.w    #1,d2
             bpl.s     .Loop4
             movem.l   (sp)+,d0-d3/d6/d7/a0/a6
             rts       

.Show_mouth_frame:     
             movem.l   d2/a0/a6,-(sp)
             lea.l     RiddleM_graphics+4640,a0   ; Calculate graphics address
             mulu.w    #600,d2
             adda.w    d2,a0
             movea.l   Off_screen,a6        ; Show animation frame
             jsr       Blot_unmasked_block
             jsr       Switch_screen
             moveq.l   #7-1,d2              ; Wait
.Wait:       jsr       My_vsync
             dbra      d2,.Wait
             movem.l   (sp)+,d2/a0/a6
             rts       

;*****************************************************************************
; [ Attribute change ]
;*****************************************************************************
Attr_change: 
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
             tst.w     6(a5)                ; All or active ?
             beq.s     .All
             movea.l   Current_active_char_data,a1          ; Active
             jsr       .Change
             bra.s     .Go_on
.All:        lea.l     Chard_ptrs,a0        ; All
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next
             jsr       .Change
.Next:       addq.l    #4,a0                ; Next member
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi       .Loop
.Go_on:      jsr       Save_event
             rts       

.Change:     lea.l     Attr_1_normal-2(a1),a2     ; Which attribute ?
             move.b    1(a5),d0
             ext.w     d0
             add.w     d0,d0
             adda.w    d0,a2
             move.w    8(a5),d1
             tst.b     3(a5)                ; Random ?
             beq.s     .Not_random
             jsr       Random               ; Take a random value
             mulu.w    d0,d1
             swap.w    d1
             addq.w    #1,d1
.Not_random: tst.b     2(a5)                ; Add or subtract ?
             beq.s     .Add
             neg.w     d1
.Add:        add.w     d1,(a2)              ; Change attribute
             move.w    d7,d0                ; Show
             jsr       Do_sparkle
             rts       

;*****************************************************************************
; [ Change icon ]
;*****************************************************************************
Change_icon: 
             Update_map_display 
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
             moveq.l   #0,d0                ; Change icon
             move.b    1(a5),d0
             moveq.l   #0,d1
             move.b    2(a5),d1
             move.w    6(a5),d2
             movea.l   Mapd_ptr,a0
             jsr       Do_change_icon
             tst.b     5(a5)                ; Modify map ?
             beq.s     .No_save
             jsr       Enter_modification
             jsr       Save_event
.No_save:    rts       

;*****************************************************************************
; [ Event item ]
;*****************************************************************************
Event_item:  
             Update_map_display 
             moveq.l   #0,d0                ; Display text
             move.b    4(a5),d0
             move.w    d0,WText_nr
             move.l    Maptext_ptr,Textfile_ptr
             Push      Module,TxtW_Mod
.Exit:       rts       

Do_event_item:         
             movea.l   Event_data_ptr,a5
             moveq.l   #0,d0                ; Change icon
             move.b    1(a5),d0
             moveq.l   #0,d1
             move.b    2(a5),d1
             move.w    8(a5),d2
             movea.l   Mapd_ptr,a0
             jsr       Do_change_icon
             tst.b     5(a5)                ; Modify map ?
             beq.s     .No_save
             jsr       Enter_modification
             jsr       Save_event
.No_save:    rts       

;*****************************************************************************
; [ Door exit ]
;*****************************************************************************
Door_exit:   
             st        Doorexit_flag        ; Call [ Door ] - event
             jsr       Door
             rts       

Do_extra_event:        
             movea.l   Event_data_ptr,a5    ; Get extra event number
             moveq.l   #0,d0
             move.b    4(a5),d0
             movea.l   Mapd_ptr,a5          ; Calculate event data pointer
             mulu.w    #10,d0
             lea.l     Event_data-10(a5,d0.w),a5
             move.l    a5,Event_data_ptr
             jmp       Handle_event         ; Handle it

;*****************************************************************************
ETrap:       
             move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
             move.b    1(a5),d0             ; Trapped!
             jsr       Execute_trap
             jsr       Save_event
             rts       

;*****************************************************************************
Encounter:   
             move.b    1(a5),d0             ; Appear at all ?
             ext.w     d0
             jsr       Probe
             bmi       .Exit
             move.b    2(a5),d0             ; Quest required ?
             beq.s     .No_quest
             lea.l     Quest,a1             ; Quest solved ?
             ext.w     d0
             move.w    d0,d1
             andi.w    #7,d1
             lsr.w     #3,d0
             btst      d1,0(a1,d0.w)
             beq       .Exit                ; No !
             move.b    3(a5),d0             ; Show text ?
             jsr       Event_text
             bra.s     .Continue
.No_quest:   move.b    4(a5),d0             ; Show text ?
             jsr       Event_text
.Continue:   move.w    6(a5),mongroup_nr    ; Set group number
             st        CombatReq            ; Activate requester
             st        Pause_Upd
             jsr       Save_event
.Exit:       rts       

;*****************************************************************************
; [ Layout 3 fade-in & -out ]
; Changed registers ; a0,a1,a2
;*****************************************************************************
Fadein_lay3: 
             lea.l     Lay3_target_hbl,a1   ; Fade in
             bra       Fade_lay3
Fadeout_lay3:          
             lea.l     Void,a1              ; Fade out
Fade_lay3:   tst.b     Fade_block           ; No fade ?
             bne.s     .Exit
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Lay3_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Lay3_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
             lea.l     Hbl_Lay3_list,a0     ; Update palettes
             jsr       Update_HBL
.Exit:       rts       

;*****************************************************************************
; [ Update control icons ]
;   IN : a0 - Pointer to Control Icon List (.l)
;        a1 - Pointer to re-evaluation routine (.l)
; All registers are restored
;*****************************************************************************
Update_control_icons:  
             movem.l   a0-a2,-(sp)
             movea.l   a0,a2
             lea.l     CIL_buffer,a0        ; Copy CIL to buffer
             move.l    (a2),(a0)
             move.l    4(a2),4(a0)
             move.b    8(a2),8(a0)
             jsr       (a1)                 ; Re-evaluate CIL
             movea.l   a2,a1                ; Compare with original
             cmpm.l    (a0)+,(a1)+
             bne.s     .Update
             cmpm.l    (a0)+,(a1)+
             bne.s     .Update
             cmpm.b    (a0)+,(a1)+
             beq.s     .Ready
.Update:     lea.l     CIL_buffer,a0        ; Copy buffer to CIL
             move.l    (a0)+,(a2)+
             move.l    (a0)+,(a2)+
             move.b    (a0),(a2)
             move.b    #2,CIL_update        ; Set flag
.Ready:      movem.l   (sp)+,a0-a2
             rts       

;*****************************************************************************
; [ Load 80x80 picture ]
;   IN : d0 - Picture number (.w)
;        a0 - Palette destination address (.l)
; All registers are restored
;*****************************************************************************
Load_80x80_picture:    
             movem.l   d0-d7/a0-a2,-(sp)
             movea.l   a0,a2
             lea.l     Pics80_filename,a0   ; Load palette
             add.w     d0,d0
             jsr       Load_subfile
             movem.l   (a0),d1-d7/a1        ; Copy palette
             movem.l   d1-d7/a1,(a2)
             jsr       Free_memory          ; Delete palette file
             lea.l     Pics80_filename,a0   ; Load picture
             subq.w    #1,d0
             jsr       Load_subfile
             move.l    a0,Pic80_ptr
             movem.l   (sp)+,d0-d7/a0-a2
             rts       

;*****************************************************************************
; [ Display 80x80 picture ]
;   IN : a6 - Screen base (.l)
; All registers are restored
; !!! COORDINATES ARE FOR LAYOUT 3 !!!
;*****************************************************************************
Display_80x80_picture: 
             movem.l   d0/d1/d6/d7/a0,-(sp)
             moveq.l   #16,d0               ; Display 80x80 block
             moveq.l   #49,d1
             moveq.l   #5,d6
             moveq.l   #80,d7
             movea.l   Pic80_ptr,a0
             jsr       Blot_unmasked_block
             movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ Change an icon ]
;   IN : d0 - Map X-coordinate (.w)
;        d1 - Map Y-coordinate (.w)
;        d2 - New icon number (.w)
;        a0 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
Do_change_icon:        
             movem.l   d0/d1/a0/a1,-(sp)
             cmpi.b    #1,Current_map_type  ; 2D wilderniss ?
             bne.s     .Ok
             lea.l     Map_data(a0),a0
             bra.s     .Go_on
.Ok:         movea.l   Map_pointer,a0
.Go_on:      subq.w    #1,d1                ; Calculate map pointer
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             lea.l     -1(a0,d1.w),a0
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             movea.l   Iconstats_ptr,a1     ; Get new icon status
             move.w    d2,d1
             subq.w    #1,d1
             add.w     d1,d1
             add.w     d1,d1
             move.l    0(a1,d1.w),d1
             btst      #2,d1                ; Under- or overlay ?
             beq.s     .3D_map
             adda.w    Size_of_map,a0
.3D_map:     move.b    d2,(a0)              ; Change icon
             movem.l   (sp)+,d0/d1/a0/a1
             rts       

;*****************************************************************************
; [ Word Input window "module" ]
;   OUT : a0 - Pointer to input string (.l)
; Changed registers : a0
;*****************************************************************************
Do_WordIn:   
             movem.l   d0-d3/d6/d7/a0/a6,-(sp)
             jsr       Mouse_off            ; No mouse
             move.w    #48,d0               ; Open window
             move.w    #80,d1
             moveq.l   #10,d2
             moveq.l   #4,d3
             moveq.l   #1,d6
             suba.l    a0,a0
             jsr       Open_window
             move.w    d0,Window_handle
             movea.l   Screen_base,a6
             move.w    #48+16,d0            ; Print title string
             move.w    #80+16+7,d1
             jsr       IG_Set_cursor
             lea.l     .Title_string(pc),a0
             jsr       IG_Print
             lea.l     WordIn_PA,a0         ; Make PA
             addi.w    #7+3,d1
             move.w    d0,(a0)
             move.w    d1,PA_Y(a0)
             move.w    #21*6,PA_Wd(a0)
             jsr       Push_PA
             move.w    d0,d2                ; Clear input rectangle
             addi.w    #21*6,d2
             move.w    d1,d3
             addq.w    #6,d3
             subq.w    #1,d0
             subq.w    #1,d1
             moveq.l   #3,d6
             jsr       Draw_box
             move.w    d6,d0                ; Input word
             jsr       IG_Set_paper
             moveq.l   #20,d0
             jsr       Input_string
             move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             Pop       PA                   ; Exit
             jsr       Mouse_on
             movem.l   (sp)+,d0-d3/d6/d7/a0/a6
             jmp       Pop_Module

             .IF Language=1                 ; English
.Title_string:         .DC.b 1,15,2,2,"ENTER WORD :",0
             .EVEN 
             .ENDIF 
             .IF Language=2                 ; French
.Title_string:         .DC.b 1,15,2,2,"ENTER WORD :",0
             .EVEN 
             .ENDIF 
             .IF Language=3                 ; German
.Title_string:         .DC.b 1,15,2,2,"GEBE WORT EIN :",0
             .EVEN 
             .ENDIF 

;*****************************************************************************
; [ Divide gold ]
;   IN : d0 - Number of gold coins (.w)
;  OUT : d0 - Remaining gold coins (.w)
; Changed registers : d0
;*****************************************************************************
Divide_gold: 
             movem.l   d1-d3/d6/d7/a0-a2,-(sp)
             ext.l     d0
             beq       .Exit                ; Any gold ?
             move.l    d0,d3
; ------------- Calculate potential gold demand ----------------------
             lea.l     Chard_ptrs,a0        ; Initialize registers
             lea.l     Divide_gold_workspace,a1
             moveq.l   #0,d6
             moveq.l   #6-1,d7
.Loop1:      moveq.l   #0,d0                ; Zero gold
             tst.l     (a0)                 ; Any character there ?
             beq       .Next1
             movea.l   (a0),a2              ; Get character data
             cmpi.b    #9,Character_race(a2)      ; Not special or monster ?
             bpl       .Next1
             move.w    #$e402,d1            ; Alive and kicking ?
             and.w     Body_conditions(a2),d1
             bne       .Next1
             move.w    Attr_1_normal(a2),d0 ; Carry how many ?
             add.w     Attr_1_normal_magic(a2),d0
             mulu.w    #1000,d0
             sub.l     Weight_normal(a2),d0
             divu.w    #Gold_weight,d0
             move.w    Gold_coins(a2),d1    ; Not too much ?
             add.w     d0,d1
             bvc.s     .Next1
             move.w    #32767,d0
             sub.w     Gold_coins(a2),d0
.Next1:      tst.w     d0                   ; Want any gold ?
             beq.s     .Skip1
             addq.w    #1,d6                ; Count!
.Skip1:      move.w    d0,(a1)+             ; Store potential gold
             addq.l    #4,a0                ; Next character
             dbra      d7,.Loop1
; ------------- Divide the gold --------------------------------------
             move.l    d3,d0
             tst.w     d6                   ; Anyone interested ?
             beq.s     .Exit
.Again:      lea.l     -24(a0),a0
             lea.l     -12(a1),a1
             moveq.l   #6-1,d7
.Loop2:      move.w    (a1),d1              ; Want any ?
             beq       .Next2
             movea.l   (a0),a2              ; Get character data
             move.l    d0,d2                ; Calculate divided amount
             divu.w    d6,d2
             tst.w     d2                   ; Zero ?
             bne.s     .Skip2
             move.l    d0,d2                ; Divide remainder!
.Skip2:      cmp.w     d2,d1                ; Want enough ?
             bpl.s     .Enough
             sub.w     d1,(a1)              ; Divide gold
             bne.s     .Notzero1
             subq.w    #1,d6
.Notzero1:   sub.w     d1,d0
             add.w     d1,Gold_coins(a2)
             mulu.w    #Gold_weight,d1
             add.l     d1,Weight_normal(a2)
             bra.s     .Next2
.Enough:     sub.w     d2,(a1)
             bne.s     .Notzero2
             subq.w    #1,d6
.Notzero2:   sub.w     d2,d0
             add.w     d2,Gold_coins(a2)
             mulu.w    #Gold_weight,d2
             add.l     d2,Weight_normal(a2)
.Next2:      addq.l    #4,a0                ; Next character
             addq.l    #2,a1
             dbra      d7,.Loop2
             tst.w     d0                   ; All gold gone ?
             beq.s     .Exit
             tst.w     d6                   ; Everyone fully satisfied ?
             bne       .Again
.Exit:       movem.l   (sp)+,d1-d3/d6/d7/a0-a2
             rts       

;*****************************************************************************
; [ Show objects - layout 3 ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Show_objects_LAY3:     
             movem.l   d0-d2/d7/a1-a3,-(sp)
             movea.l   Itemdata_ptr,a1      ; Show objects
             lea.l     Door_object_pos_list,a2
             movea.l   Itemslots_ptr,a3
             moveq.l   #12-1,d7
.Loop:       move.w    (a2)+,d0             ; Get coordinates
             move.w    (a2)+,d1
             lea.l     Layout_icn+9856,a0   ; Erase object
             jsr       Put_unmasked_block
             tst.b     (a3)+                ; Any object there ?
             beq.s     .Next
             cmpi.b    #17,Item_type(a1)    ; Is it a monster item ?
             beq.s     .Next
             lea.l     Objects_icn,a0       ; Calculate graphics address
             move.b    (a1),d2
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block     ; Display object
.Next:       lea.l     40(a1),a1            ; Next object
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d2/d7/a1-a3
             rts       

;*****************************************************************************
; [ Remove event ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        a0 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
Remove_event:          
             movem.l   d1/a0,-(sp)
             lea.l     Map_data(a0),a0      ; Calculate map pointer
             subq.w    #1,d1
             mulu.w    Width_of_map,d1
             add.w     d0,d1
             lea.l     -1(a0,d1.w),a0
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             adda.w    Size_of_map,a0
.3D_map:     adda.w    Size_of_map,a0
             clr.b     (a0)                 ; Remove event
             movem.l   (sp)+,d1/a0
             rts       

;*****************************************************************************

             .INCLUDE 'WSELW.IS'
             .INCLUDE 'PLACES.IS'

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
P80_area:    .DC.w 112,303,49,192
Lay9_area:   .DC.w 16,207,49,192
L3_objects_area:       .DC.w 16,191,145,192
TxtW_PA:     .DC.w 32,0,256,0,15,3
MaxTxtW_PA:  .DC.w 32,52+16,256,112,15,3
P80_PA:      .DC.w 112,49,192,140,15,2
Lay3_PlusMes:          .DC.w 112,303,49,96
Lay3_PA:     .DC.w 112,49,192,48,15,2
Lay9_PlusMes:          .DC.w 16,191,49,192
Lay9_PA:     .DC.w 16,49,176,144,15,2
WordIn_PA:   .DC.w 0,0,0,7,15,3

Door_object_pos_list:  
             .DC.w 16,145,48,145,80,145,112,145,144,145,176,145
             .DC.w 16,177,48,177,80,177,112,177,144,177,176,177

Door_CIL:    .DC.b 15,32,30,13,56,56,14,56,56
             .EVEN 
             .DC.l Pick_lock_DOOR,Use_item_DOOR,Door_Exit
             .DC.l Find_trap_DOOR,0,0
             .DC.l Disarm_trap_DOOR,0,0
ClosedChest_CIL:       
             .DC.b 15,32,30,13,56,$80+33,14,$80+18,$80+50
             .EVEN 
             .DC.l Pick_lock_DOOR,Use_item_CHEST,Chest_exit
             .DC.l Find_trap_DOOR,0,0
             .DC.l Disarm_trap_DOOR,0,0
OpenedChest_CIL:       
             .DC.b $80+15,$80+32,30,$80+13,56,33,$80+14,18,50
             .EVEN 
             .DC.l 0,0,Chest_exit
             .DC.l 0,0,Transfer_item_CHEST
             .DC.l 0,Transfer_gold_CHEST,Divide_gold_CHEST
RiddleM_CIL: .DC.b 56,56,30,56,56,56,17,56,10
             .EVEN 
             .DC.l 0,0,RiddleM_Exit
             .DC.l 0,0,0
             .DC.l Answer_riddleM,0,Ask_riddleM

Lay3_target_hbl:       
             .DC.w 0
             .DCB.w 16,0                    ; 80x80 picture palette
             .DC.w 0
             .DC.w 0,$651,$333,$222,$111,$531,$421,$124     ; Objects palette
             .DC.w $236,$610,$310,$541,$340,$451,$444,$765


             .BSS 
Palette_buffer:        .DS.w 16

Trap_found:  .DS.b 1
Trap_disarmed:         .DS.b 1
Door_opened: .DS.b 1
Doorexit_flag:         .DS.b 1
Gold_in_chest_flag:    .DS.b 1
             .EVEN 

Current_chest_gold:    .DS.w 1              ; Copy of chest array data
Current_chest_slots:   .DS.w 1
Chest_slot_list:       .DS.b 12             ; Slot list for current chest
Divide_gold_workspace: 
             .DS.w 6

Itemdata_ptr:          .DS.l 1
Itemslots_ptr:         .DS.l 1

EVENT_ptr:   .DS.l 1   ; Pointer to EVENT array
EVENT_bit:   .DS.w 1   ; Bit number in EVENT array
Event_nr:    .DS.w 1   ; Number of current event
Event_data_ptr:        .DS.l 1

WText_nr:    .DS.w 1   ; Text window information ; ERROR
Window_handle:         .DS.w 1


             .SECTION 5,DATA
Pics80_filename:       .DC.b 9,'PICS80.AMB',0
Chestdata_filename:    .DC.b 10,'CHESTDAT.AMB',0

             .SECTION 6,BSS 
Pic80_ptr:   .DS.l 1
Pic80pal_ptr:          .DS.l 1
Chestdata_ptr:         .DS.l 1

             .SECTION 7,DATA
; LAYOUT 3 : 2nd layer
Lay3_L2:     .DC.w 16,191,145,192           ; Object area
             .DC.b 2
             .EVEN 
             .DC.l Control_area,Lay3Obj_C1

; LAYOUT 3 : 3rd layer
Lay3Obj_C1:  .DC.w 16,31,145,160
             .DC.b 1
             .EVEN 
             .DC.l .C2
.C2:         .DC.w 48,63,145,160
             .DC.b 2
             .EVEN 
             .DC.l .C3
.C3:         .DC.w 80,95,145,160
             .DC.b 3
             .EVEN 
             .DC.l .C4
.C4:         .DC.w 112,127,145,160
             .DC.b 4
             .EVEN 
             .DC.l .C5
.C5:         .DC.w 144,159,145,160
             .DC.b 5
             .EVEN 
             .DC.l .C6
.C6:         .DC.w 176,191,145,160
             .DC.b 6
             .EVEN 
             .DC.l .C7
.C7:         .DC.w 16,31,177,192
             .DC.b 7
             .EVEN 
             .DC.l .C8
.C8:         .DC.w 48,63,177,192
             .DC.b 8
             .EVEN 
             .DC.l .C9
.C9:         .DC.w 80,95,177,192
             .DC.b 9
             .EVEN 
             .DC.l .C10
.C10:        .DC.w 112,127,177,192
             .DC.b 10
             .EVEN 
             .DC.l .C11
.C11:        .DC.w 144,159,177,192
             .DC.b 11
             .EVEN 
             .DC.l .C12
.C12:        .DC.w 176,191,177,192
             .DC.b 12
             .EVEN 
             .DC.l 0

             .SECTION 8,DATA
Hbl_pic80_list:        .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Pic80_below: .DCB.w 16,0
             .DC.w 0

Hbl_Lay3_list:         .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
Lay3_below:  .DC.b 36,0
             .DCB.w 16,0                    ; 80x80 picture palette
             .DC.b 49+79,0
             .DCB.w 16,0                    ; Objects palette
             .DC.w 0

Hbl_Lay9_list:         .DC.w $ff00          ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Lay9_below:  .DCB.w 16,0                    ; 80x80 picture palette
             .DC.w 0

             .END 







