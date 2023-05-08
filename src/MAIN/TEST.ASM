
; AMBERSTAR
; Written by J.Horneman (In Tune With The Universe)
; Start : 19-2-1991

; Amberstar Base Program
; Written by J.Horneman (In Tune With The Universe)
; Start : 8-2-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

             .PATH 'E:\MAIN\'
             .PATH 'E:\LAYOUT\'
             .INCLUDE 'XREFS.IS'
             .INCLUDE 'OFFSETS.IS'
             .INCLUDE 'CONST5X.IS'
             .INCLUDE 'MACRO4X.IS'

Debug        = 1

Super_stack_size       = 4096               ; Size of super stack
User_stack_size        = 256                ; Size of user stack

Max_mods     = 512

             .TEXT 
             .IF Debug
             movea.l   4(sp),a0             ; Get start of command line
             lea.l     128(a0),a0
             tst.b     (a0)+                ; Anyone there ?
             beq.s     .Exit
             moveq.l   #0,d0                ; Initialize registers
             moveq.l   #100,d1
             moveq.l   #2,d7
.Loop:       moveq.l   #0,d2                ; Get digit
             move.b    (a0)+,d2
             cmpi.b    #"0",d2              ; Legal digit ?
             bmi.s     .Exit
             cmpi.b    #"9"+1,d2
             bpl.s     .Exit
             subi.w    #"0",d2              ; Scale down
             mulu.w    d1,d2                ; Calculate
             add.w     d2,d0
             divu.w    #10,d1               ; Next digit
             dbra      d7,.Loop
             move.w    d0,Number            ; Store number
.Exit:       
             .DATA 
Number:      .DC.w 0
             .TEXT 
             .ENDIF 

             .DC.w $a00a                    ; Hide mouse
             movea.l   4(sp),a0             ; Initialize memory manager
             move.l    a0,Basepage
             jsr       Init_memory
             .IF Debug=1
             move.l    Size_of_free_memory,Total_size
             .ENDIF 
             move.l    sp,Old_usp           ; Save old & set new
             lea.l     My_user_stack,sp     ;  user stack pointer
             SUPERX    #Supervisor          ; Execute in supervisor
             movea.l   Old_usp,sp           ; Restore user stack pointer
             .DC.w $a009                    ; Show mouse
             P_TERM_0  ; End of program

;*****************************************************************************
Supervisor:  
             move.l    sp,Old_ssp
             lea.l     My_super_stack,sp

             jsr       Save_computer        ; Save system settings
             jsr       Init_computer        ; System initialize
             jsr       Init_gfx
             jsr       Init_kbd
             jsr       Init_DI_print
             jsr       Init_file
             jsr       HBL_on
             jsr       Mouse_on

;*****************************************************************************

             Push      PA,Standard_PA
             jsr       Init_dictionary
             jsr       Restore_game

             lea.l     Place_dat,a0         ; Calculate pointer to place
             move.w    (a0)+,d0             ; texts
             mulu.w    #24,d0
             adda.w    d0,a0
             move.l    a0,Placetext_ptr

             jsr       Show_status_block    ; Show status block
             Update_screen 

             Push      Root,Main_root       ; Initialize object tree

;*****************************************************************************

             .IF Debug
;ori.w      #$0030,Special_item_flags

             tst.w     Number
             beq.s     .Skip
             move.w    #7,Map_Xcoord
             move.w    #7,Map_Ycoord
             move.w    Number,Map_nr
.Skip:       .ENDIF 

             jsr       DoAutoIcon
             jsr       Update_status_block
             Push      Module,Buffer_Mod
             jsr       Init_map

;*****************************************************************************
Main_loop:   
             move.w    #0,Draw_Cicon        ; Stop feedback
             jsr       Input_handler        ; Handle input
             movea.l   Module_sp,a0         ; Get pointer from stack
             move.l    (a0),d0
             beq.s     .Skip
             movea.l   d0,a0
             jsr       (a0)                 ; Update display
.Skip:       jsr       Switch_screen
             bra.s     Main_loop

;*****************************************************************************
Exit_all:    
             jsr       Exit_display
Exit_program:          
             jsr       Restore_computer
             movea.l   Old_ssp,sp
             rts       

;*****************************************************************************
; Included files
;*****************************************************************************

             .IF Debug=1
             .INCLUDE 'STATUS.IS'
             .ENDIF 
             .INCLUDE 'MAP.IS'
             .INCLUDE 'TIME.IS'
             .INCLUDE 'LAYOUT.IS'
             .INCLUDE 'WORDS.IS'
             .INCLUDE 'EVENTS.IS'
             .INCLUDE 'EYE.IS'
             .INCLUDE 'MODCON.IS'
             .INCLUDE 'MODULES.IS'
             .INCLUDE 'INVENT.IS'
             .INCLUDE 'MAGIC.IS'
             .INCLUDE 'COMBAT.IS'

;*****************************************************************************
; Subroutines
;*****************************************************************************
             .TEXT 
;*****************************************************************************
; [ Restore game ]
; All registers are restored
;*****************************************************************************
Restore_game:          
             movem.l   d0/d7/a0-a2,-(sp)
             jsr       Load_party_data

; THIS is the logical place to re-evaluate certain things; for instance
; if the shadow must be switched off because of the new travel mode.

             move.w    Travel_mode,d0
             jsr       Set_new_travel_mode
; ------------- Load party characters' data --------------------------
             lea.l     Member_1_nr,a1
             lea.l     Chard_ptrs,a2
             moveq.l   #5,d7                ; Maximally 6 members
.Loop:       move.w    (a1)+,d0             ; Character number
             beq.s     .Next
             lea.l     Chard_filename,a0    ; Load subfile
             jsr       Load_subfile
             move.l    a0,(a2)              ; Store pointer
.Next:       addq.l    #4,a2                ; Next character
             dbra      d7,.Loop
; ------------- Set pointer to active character's data ---------------
             lea.l     Chard_ptrs,a0
             move.w    Active_member,d0
             add.w     d0,d0
             add.w     d0,d0
             move.l    -4(a0,d0.w),Current_active_char_data
             movem.l   (sp)+,d0/d7/a0-a2
             rts       

;*****************************************************************************
; [ Constant logic ]
; All registers are restored
;*****************************************************************************
Constant_logic:        

             rts       

;*****************************************************************************
; [ Load & copy party data ]
; All registers are restored
;*****************************************************************************
Load_party_data:       
             movem.l   d0/d7/a0/a1,-(sp)
             lea.l     Partydata_filename,a0      ; Load party data
             jsr       Load_file
             move.l    a0,-(sp)             ; Store
             lea.l     Party_data,a1
             moveq.l   #0,d0
             moveq.l   #24-1,d7             ; Copy 24 bytes
.Loop1:      move.b    (a0)+,d0
             move.w    d0,(a1)+
             dbra      d7,.Loop1
             move.w    #5550-1,d7           ; Copy 5550 words
.Loop2:      move.w    (a0)+,(a1)+
             dbra      d7,.Loop2
             jsr       Init_modifications   ; Copy modification list
             movea.l   (sp)+,a0             ; Remove file
             jsr       Kill_memory
             movem.l   (sp)+,d0/d7/a0/a1
             rts       

; **** Modifying events ***********************************

; - Use item
; - Riddlemouth
; - Change icon

; Make modification when {Event_save}-bit is set.

; **** Modification list data format **********************

;  0 - Map number / 0 = Sentinel       (.w)
;  2 - X-coordinate                    (.b)
;  3 - Y-coordinate                    (.b)
;  4 - Icon number / -1 = Remove event (.w)

;*****************************************************************************
; [ Initialize modifications ]
;   IN : a0 - Pointer to end of party data (.l)
; All registers are restored
;*****************************************************************************
Init_modifications:    
             movem.l   d0/a0/a1,-(sp)
             move.l    #Max_mods,d0         ; Allocate modification buffer
             mulu.w    #6,d0
             jsr       Allocate_memory
             move.l    a1,Modifications_ptr ; Store
             moveq.l   #0,d0
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .Exit
             move.l    (a0)+,(a1)+          ; Copy info
             move.w    (a0)+,(a1)+
             addq.w    #1,d0                ; Count
             bra.s     .Again
.Exit:       move.w    d0,Nr_of_modifications     ; Store
             movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ Make modifications to current map ]
;   IN : d7 - Map number (.w)
;        a0 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
Make_modifications:    
             movem.l   d0-d2/a1,-(sp)
             moveq.l   #0,d0                ; Initialize registers
             moveq.l   #0,d1
             movea.l   Modifications_ptr,a1
.Again:      tst.w     (a1)                 ; End of list ?
             beq       .Exit
             cmp.w     (a1),d7              ; This map ?
             bne       .Next
             move.b    2(a1),d0             ; Load coordinates
             move.b    3(a1),d1
             move.w    4(a1),d2             ; Load icon number
             bmi       .Event               ; Remove event ?
             jsr       Do_change_icon       ; Change icon
             bra.s     .Next
.Event:      jsr       Remove_event         ; Remove event
.Next:       addq.l    #6,a1                ; Next modification
             bra       .Again
.Exit:       movem.l   (sp)+,d0-d2/a1
             rts       

;*****************************************************************************
; [ Enter modifications in list ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Icon number / -1 = Remove event (.w)
; All registers are restored
;*****************************************************************************
Enter_modification:    
             movem.l   d7/a0,-(sp)
             move.w    Nr_of_modifications,d7     ; Too much ?
             cmpi.w    #Max_mods,d7
             bmi.s     .Ok
             ERROR     "[ Enter_modification ] : Too much modifications !!!"
             bra       .Exit
.Ok:         addq.w    #1,d7                ; Increase
             move.w    d7,Nr_of_modifications
             movea.l   Modifications_ptr,a0 ; Seek end of list
             mulu.w    #6,d7
             lea.l     -6(a0,d7.w),a0
             move.w    Map_nr,(a0)+         ; Store info
             move.b    d0,(a0)+
             move.b    d1,(a0)+
             move.w    d2,(a0)
.Exit:       movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Set new travel mode ]
;   IN : d0 - New travel mode (.w)
; All registers are restored
;*****************************************************************************
Set_new_travel_mode:   
             move.l    d0,-(sp)
             cmpi.w    #6,d0                ; In range ?
             bls.s     .Ok
             ERROR     "[ Set_new_travel_mode ] : Input out of range !!!"
             bra.s     .Exit
.Ok:         move.w    d0,Travel_mode       ; Store
             cmpi.w    #5,d0                ; Re-evaluate shadow
             smi       Shadow_flag
             add.w     d0,d0                ; Set new movement speed
             move.w    .Move_speed_table(pc,d0.w),Move_speed
             move.w    #1,Move_count
.Exit:       move.l    (sp)+,d0
             rts       

.Move_speed_table:     .DC.w 4,8,6,8,4,12,12

;*****************************************************************************
; [ Left mouse-button clicked on party member ] MOUSE EVENT
; No registers are restored
;*****************************************************************************
Member_left: 
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #6,d0
             move.w    d0,d1                ; Save for later
             lea.l     Chard_ptrs,a0        ; Get pointer to character
             movea.l   -4(a0,d0.w),a0       ; data
             move.w    Body_conditions(a0),d0
             andi.w    #$e506,d0
             bne.s     .Exit
             lsr.w     #2,d1                ; Set new active member
             move.w    d1,Active_member
             lea.l     Chard_ptrs,a0
             add.w     d1,d1
             add.w     d1,d1
             move.l    -4(a0,d1.w),Current_active_char_data
.Exit:       rts       

;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT
; All registers are restored
;*****************************************************************************
Member_right:          
             movem.l   d0/a0,-(sp)
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #6,d0
             lea.l     Chard_ptrs-4,a0      ; Any character there ?
             adda.w    d0,a0
             tst.l     (a0)
             beq       .Exit
             movea.l   (a0),a0
             move.l    a0,Current_inventory_chardat_ptr
             jsr       Exit_display
             Push      Module,Inv1_Mod      ; Inventory I
.Exit:       movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Install new layout data
;   IN : a0 - Pointer to new layout data (.l)
; All registers are restored
;*****************************************************************************
Set_layout_data:       
             move.l    a0,Layout_data_ptr
             rts       

;*****************************************************************************
; [ Delay ]
;   IN : d0 - Number of VBL's to delay (.w)
; All registers are restored
;*****************************************************************************
Delay:       
             move.l    d0,-(sp)
             bra.s     .Entry               ; Wait
.Loop:       jsr       My_vsync
.Entry:      dbra      d0,.Loop
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; Control icon key event routines
;*****************************************************************************
Icon_1:      moveq.l   #1,d0
             jmp       Do_control_icons
Icon_2:      moveq.l   #2,d0
             jmp       Do_control_icons
Icon_3:      moveq.l   #3,d0
             jmp       Do_control_icons
Icon_4:      moveq.l   #4,d0
             jmp       Do_control_icons
Icon_5:      moveq.l   #5,d0
             jmp       Do_control_icons
Icon_6:      moveq.l   #6,d0
             jmp       Do_control_icons
Icon_7:      moveq.l   #7,d0
             jmp       Do_control_icons
Icon_8:      moveq.l   #8,d0
             jmp       Do_control_icons
Icon_9:      moveq.l   #9,d0
             jmp       Do_control_icons

;*****************************************************************************
; [ Update damage & magic ]
; All registers are restored
;*****************************************************************************
Update_damage_magic:   
             movem.l   d0/d7/a0/a1/a6,-(sp)
; ------------- Update damage bursts ---------------------------------
             lea.l     Damage_timers,a0
             lea.l     Char_damage,a1
             movea.l   Off_screen,a6
             moveq.l   #1,d7
.Loop:       tst.b     (a0)                 ; Any damage ?
             beq.s     .Next
             move.w    (a1),d0              ; Display damage
             jsr       Display_damage
             subq.b    #1,(a0)              ; Count down
             bne.s     .Next
             move.w    d7,d0                ; Remove burst
             jsr       Force_char_update
.Next:       addq.l    #1,a0                ; Next character
             addq.l    #2,a1
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             .LOCAL 
; ------------- Update magic sparkles --------------------------------
             move.w    Magic_anim_counter,d0      ; Update animation counter
             addq.w    #1,d0
             cmpi.w    #12,d0
             bmi.s     .Ok
             moveq.l   #0,d0
.Ok:         move.w    d0,Magic_anim_counter
             lea.l     Magic_timers,a0
             movea.l   Off_screen,a6
             moveq.l   #1,d7
.Loop:       tst.b     (a0)                 ; Any magic sparkles ?
             beq.s     .Next
             jsr       Display_magic
             subq.b    #1,(a0)              ; Count down
             bne.s     .Next
             move.w    d7,d0                ; Remove sparkles
             jsr       Force_char_update
.Next:       addq.l    #1,a0                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0/d7/a0/a1/a6
             rts       

;*****************************************************************************
; [ Display damage ]
;   IN : d0 - Amount of damage (.w)
;        d7 - Character number {1...6} (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_damage:        
             movem.l   d0-d2/d6/d7/a0,-(sp)
             Push      PA,Status_PA
             move.w    d0,d2
             move.w    d7,d0
             mulu.w    #48,d0               ; Calculate X-coordinate
             subi.w    #32,d0
             moveq.l   #1,d1                ; Display damage burst
             moveq.l   #2,d6
             moveq.l   #32,d7
             lea.l     Status_icn+2560,a0
             jsr       Blot_masked_block
             addi.w    #10,d0
             exg.l     d2,d0
             tst.w     d0                   ; Any damage ?
             beq.s     .Skip
             moveq.l   #2,d7                ; Convert number
             lea.l     Temp_number,a0
             lea.l     4(a0),a3
             jsr       LConvert_number
             moveq.l   #12,d0               ; Print damage
             exg.l     d0,d2
             moveq.l   #11,d1
             jsr       Print_centered_string
.Skip:       Pop       PA
             movem.l   (sp)+,d0-d2/d6/d7/a0
             rts       

;*****************************************************************************
; [ Display magic sparkles ]
;   IN : d7 - Character number {1...6} (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_magic:         
             movem.l   d0/d1/d6/d7/a0,-(sp)
             move.w    d7,d0                ; Calculate X-coordinate
             mulu.w    #48,d0
             subi.w    #32,d0
             lea.l     Chard_ptrs,a0        ; Calculate graphics address
             add.w     d7,d7
             add.w     d7,d7
             movea.l   -4(a0,d7.w),a0
             lea.l     Portrait+6(a0),a0
             moveq.l   #1,d1                ; Load parameters
             moveq.l   #2,d6
             moveq.l   #32,d7
             jsr       Blot_unmasked_block  ; Display portrait
             lea.l     Status_icn+4096,a0   ; Calculate graphics address
             move.w    Magic_anim_counter,d2
             andi.w    #$fffc,d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Blot_masked_block    ; Display magic sparkles
             movem.l   (sp)+,d0/d1/d6/d7/a0
             rts       

;*****************************************************************************
; [ New active character select ] MODULE
;*****************************************************************************
ActSel_DisUpd:         
             jsr       Update_status_block
             tst.w     Active_member        ; Any found ?
             beq.s     .Exit
             Pop       Module
.Exit:       rts       

ActSel_ModInit:        
             Push      MA,Load_area
             rts       

ActSel_ModExit:        
             Pop       MA
             jmp       Init_display

;*****************************************************************************
; [ General requester ]
;*****************************************************************************
Req_ModInit: 
             move.w    #48,d0               ; Open window
             move.w    #80,d1
             moveq.l   #12,d2
             moveq.l   #5,d3
             moveq.l   #1,d6
             lea.l     PlacesExit_L1,a0
             jsr       Open_window
             move.w    d0,Window_handle
             movea.l   Off_screen,a6
             movea.l   PlusMes_info,a0      ; Print text
             move.l    #PlacesExit_MA,PlusMes_info
             move.w    ReqText_nr,d0
             jsr       Hash_message
             move.l    a0,PlusMes_info
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #48+32,d0
             move.w    #80+48,d1
             lea.l     Control_icn+6912,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0
             lea.l     Control_icn+7168,a0
             jsr       Blot_unmasked_block
             Update_screen 
             rts       

Req_ModExit: move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             Wait_4_unclick 
             rts       

Req_Yes:     Pop       Module
             movea.l   ReqDo_ptr,a0         ; Yes!
             jmp       (a0)

;*****************************************************************************
; [ Overweight check ]
; All registers are restored
;*****************************************************************************
Overweight_check:      
             movem.l   d0/d1/d7/a0-a2,-(sp)
             sf        Overweight           ; Clear flag
             lea.l     Chard_ptrs,a0        ; Anyone too heavy
             lea.l     Char_status_icons,a1
             moveq.l   #1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a2
             move.l    Weight_normal(a2),d0 ; Get current weight
             move.w    Attr_1_normal(a2),d1 ; Get maximum weight
             add.w     Attr_1_normal_magic(a2),d1
             mulu.w    #1000,d1
             cmp.l     d0,d1                ; Too heavy ?
             bpl.s     .Next
             move.b    #20,(a1)             ; Overweight !
             st        Overweight
.Next:       addq.l    #4,a0                ; Next member
             addq.l    #1,a1
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0/d1/d7/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Brightness:  .DCB.w 16,$777
Dir_offset:  .DC.b 0,-1,1,0,0,1,-1,0        ; NESW
             .EVEN 
Standard_MA: .DC.w 0,319,0,199
Standard_PA: .DC.w 0,0,319,199,15,0
Temp_number: .DC.b 1,9,2,-1
             .DC.b "  ",0
             .EVEN 
Load_area:   .DC.w 0,319,0,36


             .SECTION 5,DATA
Partydata_filename:    .DC.b 1,'PARTYDAT.SAV',0
Chard_filename:        .DC.b 3,'CHARDATA.AMB',0
             .EVEN 

             .SECTION 6,BSS 
Chard_ptrs:  .DS.l 6

             .SECTION 7,DATA
; MAIN ROOT : 1st layer
Main_root:   .DC.w 0,319,0,35               ; Status block area
             .DC.b 1
             .EVEN 
             .DC.l .C2,Statblk_L2C1
.C2:         .DC.w 0,319,37,199             ; Layout area
             .DC.b 2
             .EVEN 
             .DC.l 0
Layout_data_ptr:       
             .DC.l 0   ; Layout-dependent data

; STATUS BLOCK : 2nd layer
Statblk_L2C1:          .DC.w 16,47,1,34     ; Member 1 portrait
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 64,95,1,34               ; Member 2 portrait
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 112,143,1,34             ; Member 3 portrait
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 160,191,1,34             ; Member 4 portrait
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 208,239,1,34             ; Member 5 portrait
             .DC.b 5
             .EVEN 
             .DC.l .C6,0
.C6:         .DC.w 256,287,1,34             ; Member 6 portrait
             .DC.b 6
             .EVEN 
             .DC.l 0,0

; CONTROL ICONS : 2nd layer
Control_area:          .DC.w 208,303,145,192      ; Control icon area
             .DC.b 1
             .EVEN 
             .DC.l 0,Control_C1

; CONTROL ICONS : 3rd layer
Control_C1:  .DC.w 208,239,145,160          ; Control icon 1
             .DC.b 1
             .EVEN 
             .DC.l .C2
.C2:         .DC.w 240,271,145,160          ; Control icon 2
             .DC.b 2
             .EVEN 
             .DC.l .C3
.C3:         .DC.w 272,303,145,160          ; Control icon 3
             .DC.b 3
             .EVEN 
             .DC.l .C4
.C4:         .DC.w 208,239,161,176          ; Control icon 4
             .DC.b 4
             .EVEN 
             .DC.l .C5
.C5:         .DC.w 240,271,161,176          ; Control icon 5
             .DC.b 5
             .EVEN 
             .DC.l .C6
.C6:         .DC.w 272,303,161,176          ; Control icon 6
             .DC.b 6
             .EVEN 
             .DC.l .C7
.C7:         .DC.w 208,239,177,192          ; Control icon 7
             .DC.b 7
             .EVEN 
             .DC.l .C8
.C8:         .DC.w 240,271,177,192          ; Control icon 8
             .DC.b 8
             .EVEN 
             .DC.l .C9
.C9:         .DC.w 272,303,177,192          ; Control icon 9
             .DC.b 9
             .EVEN 
             .DC.l 0

             .BSS 
Magic_anim_counter:    .DS.w 1
Char_damage: .DS.w 6
Damage_timers:         .DS.b 6              ; Must follow each other !!!
Magic_timers:          .DS.b 6
Char_status_icons:     .DS.b 6
             .EVEN 
Current_active_char_data:                   .DS.l 1
Nr_of_modifications:   .DS.w 1
Modifications_ptr:     .DS.l 1
HBL_list_copy:         .DS.w 512

First:       .DS.b 1
Overweight:  .DS.b 1
             .EVEN 
ReqText_nr:  .DS.w 1
ReqDo_ptr:   .DS.l 1

Party_data:  
; This is the party data.
Month::      .DS.w 1   ; (1-99) Current data & time
Day::        .DS.w 1   ; (1-99)
Hour::       .DS.w 1   ; (1-99)
Minute::     .DS.w 1   ; (0-95) Actually 5 minutes !!!
Map_Xcoord:: .DS.w 1   ; (6-96) Current coordinates
Map_Ycoord:: .DS.w 1   ; (6-96)
View_direction::       .DS.w 1              ; (0=N,1=E,2=S,3=W)

; Duration of current lasting spells (per 5 minutes)
Spell_1_duration::     .DS.w 1              ; (0-255)
Spell_2_duration::     .DS.w 1              ; (0-255)
Spell_3_duration::     .DS.w 1              ; (0-255)
Spell_4_duration::     .DS.w 1              ; (0-255)
Spell_5_duration::     .DS.w 1              ; (0-255)
Spell_6_duration::     .DS.w 1              ; (0-255)
Nr_members:: .DS.w 1   ; (0-6) Number of members in the party
Active_member::        .DS.w 1              ; (0-6)
Travel_mode::          .DS.w 1              ; (0-5)
Special_item_flags::   .DS.w 1              ; (Bit 0-5)
Music_block::          .DS.w 1              ; (0 / -1)

; Depending on spell type
Spell_1_data::         .DS.w 1              ; (0-255) Light spell
Spell_2_data::         .DS.w 1              ; (0-255) Armour spell
Spell_3_data::         .DS.w 1              ; (0-255) Weapon spell
Spell_4_data::         .DS.w 1              ; (0-255) Anti-magic spell
Spell_5_data::         .DS.w 1              ; (0-255) Clearvoyance spell
Spell_6_data::         .DS.w 1              ; (0-255) Invisibility spell

Year::       .DS.w 1   ; (0-999)
Map_nr::     .DS.w 1   ; (1-999) Current map number
Member_1_nr::          .DS.w 1              ; (1-999) Character numbers
Member_2_nr::          .DS.w 1              ; (1-999)
Member_3_nr::          .DS.w 1              ; (1-999)
Member_4_nr::          .DS.w 1              ; (1-999)
Member_5_nr::          .DS.w 1              ; (1-999)
Member_6_nr::          .DS.w 1              ; (1-999)
Nr_travelled_days::    .DS.w 1              ; (0-32767)
Time_data_year::       .DS.w 1              ; Relative year

; For up to 30 transport objects ::
Trans_T::    .DS.b 30  ; Transport types
Trans_X::    .DS.b 30  ; Coordinates
Trans_Y::    .DS.b 30
Trans_M::    .DS.w 30  ; Map number

Quest::      .DS.b 32  ;           Quest solved boolean array
Event::      .DS.b 4064                     ;         Event executed boolean array
CD::         .DS.b 1502                     ;      Character removed boolean array
WD::         .DS.b 626 ; Known dictionary words boolean array

Chest::      .DS.b 1500                     ;       Chest item slots boolean array
Chest_gold:: .DS.w 1000                     ;                Chest gold word array
Ware_count:: .DS.b 1200                     ;       Merchant item slots byte array

Order::      .DS.b 6   ; Combat position for each character

Basepage:    .DS.l 1   ; Pointer to the basepage
Old_usp:     .DS.l 1   ; Old stack-pointers
Old_ssp:     .DS.l 1

; These are the new stacks.
             .DS.l Super_stack_size/4
My_super_stack:        
             .DS.l User_stack_size/4
My_user_stack:         

             .END 















