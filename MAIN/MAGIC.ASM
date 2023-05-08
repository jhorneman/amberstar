
; Magic routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 30-10-1991

             .TEXT 
;*****************************************************************************
; [ Cast a spell ]
;*****************************************************************************
Cast_spell:  
             Wait_4_unclick 
             sf        No_spell_selected    ; Clear flags
             sf        Magic_object_flag
             movea.l   Current_active_char_data,a0
             move.b    Spell_class_counter(a0),d0 ; Count spell classes
             moveq.l   #0,d1
             moveq.l   #1,d2
             moveq.l   #7-1,d7
.Loop:       btst      d2,d0
             beq.s     .Next
             move.w    d2,Selected_class
             addq.w    #1,d1
.Next:       addq.w    #1,d2
             dbra      d7,.Loop
             move.w    d1,Nr_of_spell_classes     ; Store
             lea.l     Spells_class_1(a0),a0      ; Any spells known ?
             move.w    Selected_class,d0
             add.w     d0,d0
             add.w     d0,d0
             tst.l     -4(a0,d0.w)
             beq.s     .Exit
             cmpi.w    #1,d1                ; Only one spell class ?
             bne.s     .More
             Push      Module,SpSelW_Mod    ; Select spell
             bra       .Exit
.More:       Push      Module,SCSelW_Mod    ; Select spell class
.Exit:       rts       

;*****************************************************************************
; [ Do magic ]
;*****************************************************************************
Do_magic:    
             movem.l   d0-d7/a0-a6,-(sp)
             tst.b     No_spell_selected    ; Any spell selected ?
             bne       .Exit
             lea.l     Spell_dat-124,a0     ; Get pointer to spell data
             move.w    Selected_class,d0
             mulu.w    #120,d0
             adda.w    d0,a0
             move.w    Selected_spell,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a0
             move.l    a0,Spelldat_ptr
             lea.l     SpellClass_ptrs,a0   ; Get class
             move.w    Selected_class,d0
             add.w     d0,d0
             add.w     d0,d0
             movea.l   -4(a0,d0.w),a0
             move.w    Selected_spell,d0    ; Get spell address
             add.w     d0,d0
             add.w     d0,d0
             movea.l   -4(a0,d0.w),a0
             jsr       (a0)                 ; Execute
.Exit:       movem.l   (sp)+,d0-d7/a0-a6
             rts       

SpellClass_ptrs:       
             .DC.l WhiteM_ptrs,GreyM_ptrs,BlackM_ptrs
             .DC.l 0,0,0,MonsterM_ptrs

WhiteM_ptrs: .DC.l Heal_1,Heal_2,Heal_3,Heal_4,Heal_5,Heal_all
             .DC.l Resurrect,Change_ashes,Change_dust
             .DC.l Heal_poisoned,Heal_lamed,Heal_diseased,Heal_aged
             .DC.l Heal_stoned,Heal_sleep,Heal_panic,Heal_irritated
             .DC.l Heal_blind,Heal_mad
             .DC.l Make_lamed,Make_sleep,Make_panic,Make_irritated
             .DC.l Make_blind
             .DC.l Kill_undead,Holy_word,Remove_curse,Create_food

GreyM_ptrs:  .DC.l Light_1,Light_2,Light_3
             .DC.l Armour_1,Armour_2,Armour_3
             .DC.l Weapon_1,Weapon_2,Weapon_3
             .DC.l AntiMagic_1,AntiMagic_2,AntiMagic_3
             .DC.l ClearV_1,ClearV_2,ClearV_3
             .DC.l Invisible_1,Invisible_2,Invisible_3
             .DC.l Magic_sphere,Magic_compass,Identify
             .DC.l Levitate,Hurry,Mega_hurry,MTeleport
             .DC.l Look_through

BlackM_ptrs: .DC.l Fire_beam,Fire_push,Fire_ball,Fire_storm,Fire_waltz
             .DC.l Water_hole,Waterfall,Ice_ball,Ice_shower
             .DC.l Hail_storm,Dirt_sling,Stone_storm,Swamp_field
             .DC.l Earth_slide,Earthquake,Wind_push,Wind_devil
             .DC.l Wind_howler,Thunderstrike,Whirlwind
             .DC.l Dissolve,Magic_arrows

MonsterM_ptrs:         
             .DC.l Lame_it,Poison_it,Stone_it,Disease_it,Age_it
             .DC.l Irritate_it,Madden_it,Sleep_it,Panic_it,Blind_it
             .DC.l Stone_monster,Map_view,Banish_demon,Spellpts1,Spellpts2
             .DC.l Weapon_gunk,Youth,0,Call_eagle

;*****************************************************************************
; [ Handle spell ]
;  OUT : pl - Spell succeeded
;        mi - Spell failed
; All registers are restored
;*****************************************************************************
Handle_spell:          
             movem.l   d0/a0/a1,-(sp)
             tst.b     Magic_object_flag    ; Magical object ?
             beq.s     .No_object
             jsr       Remove_used_magic_item     ; Remove item
             moveq.l   #0,d0                ; Force pl
             bra.s     .Exit
.No_object:  movea.l   Spelldat_ptr,a0      ; Remove spell points
             movea.l   Current_active_char_data,a1
             move.b    1(a0),d0
             ext.w     d0
             sub.w     d0,Power_points_normal(a1)
             moveq.l   #0,d0                ; Probe magic using skill
             move.b    Skill_10(a1),d0
             add.w     Skill_10_normal_magic(a1),d0
             jsr       Probe
             smi       Spell_failed         ; Set flag
.Exit:       movem.l   (sp)+,d0/a0/a1
             rts       

;*****************************************************************************
; [ White Magic spell routines ]
; No registers are restored
;*****************************************************************************

; ************* General healing spells ********************
Heal_1:      jsr       Random               ; 1st level healing
             mulu.w    #5,d0
             swap.w    d0
             addq.w    #1,d0
             jmp       Common_heal

Heal_2:      jsr       Random               ; 2nd level healing
             mulu.w    #8,d0
             swap.w    d0
             addq.w    #2,d0
             jmp       Common_heal

Heal_3:      jsr       Random               ; 3rd level healing
             mulu.w    #16,d0
             swap.w    d0
             addq.w    #4,d0
             jmp       Common_heal

Heal_4:      jsr       Random               ; 4th level healing
             mulu.w    #32,d0
             swap.w    d0
             addq.w    #8,d0
             jmp       Common_heal

Heal_5:      jsr       Random               ; 5th level healing
             mulu.w    #64,d0
             swap.w    d0
             addi.w    #16,d0

; !!! CONTINUES !!!

; [ Common healing routine ]
;   IN : d0 - Amount of added LP (.w)
; No registers are restored
Common_heal: 
             move.w    d0,Added_LP          ; Store
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #1,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             movea.l   Victim_ptr,a0        ; Alive and kicking ?
             move.w    Body_conditions(a0),d0
             andi.w    #$e000,d0
             bne.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             move.w    Added_LP,d0          ; Add
             movea.l   Victim_ptr,a0
             jsr       Increase_LP
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

; ************* Heal entire party *************************
Heal_all:    
             jsr       Handle_spell         ; Try
             bmi       .Exit
             lea.l     Chard_ptrs,a0        ; All healing
             moveq.l   #1,d0
             moveq.l   #6-1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d1            ; Alive and kicking ?
             and.w     Body_conditions(a1),d1
             bne.s     .Next
             move.w    Life_points_max(a1),d2     ; Fill it up !
             add.w     Life_points_max_magic(a1),d2
             cmp.w     Life_points_normal(a1),d2  ; Less than normal ?
             bmi.s     .Next
             move.w    d2,Life_points_normal(a1)
             jsr       Do_sparkle           ; Sparkle!
.Next:       addq.w    #1,d0                ; Next character
             addq.l    #4,a0
             dbra      d7,.Loop
.Exit:       rts       

; ************* Resurrection spells ***********************
Resurrect:   
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #2,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             movea.l   Victim_ptr,a0        ; Actually dead ?
             move.b    Body_conditions(a0),d0
             btst      #5,d0
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Failed
             bclr      #5,d0                ; Resurrect !
             bra.s     .End
.Failed:     bset      #6,d0                ; Change to ashes
.End:        move.b    d0,Body_conditions(a0)     ; Store
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
             jsr       Resurrection         ; Resurrect !
.Exit:       rts       

Change_ashes:          
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #3,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             movea.l   Victim_ptr,a0        ; Actually ashes ?
             move.b    Body_conditions(a0),d0
             btst      #6,d0
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Failed
             bclr      #6,d0                ; Ashes to dead !
             bra.s     .End
.Failed:     bset      #7,d0                ; Change to dust
.End:        move.b    d0,Body_conditions(a0)     ; Store
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
             jsr       Force_char_update
.Exit:       rts       

Change_dust: 
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #4,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             movea.l   Victim_ptr,a0        ; Actually dust ?
             move.b    Body_conditions(a0),d0
             btst      #7,d0
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Failed
             bclr      #7,d0                ; Dust to ashes !
             bra.s     .End
.Failed:     
; KILL FOREVER !!!
             DIAG_ON 
             PRINT     "He's dead forever !!!"
             jsr       Wait_4_key
             DIAG_OFF 

.End:        move.b    d0,Body_conditions(a0)     ; Store
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
             jsr       Force_char_update
.Exit:       rts       

; ************* General heal condition spells *************
Heal_poisoned:         
             moveq.l   #5,d0                ; Heal poisoning
             moveq.l   #9,d1
             jmp       Common_heal_condition

Heal_lamed:  
             moveq.l   #6,d0                ; Heal lamed
             moveq.l   #8,d1
             jmp       Common_heal_condition

Heal_diseased:         
             moveq.l   #7,d0                ; Heal diseased
             moveq.l   #11,d1
             jmp       Common_heal_condition

Heal_aged:   
             moveq.l   #8,d0                ; Heal aged
             moveq.l   #12,d1
             jmp       Common_heal_condition

Heal_stoned: 
             moveq.l   #9,d0                ; Heal stoned
             moveq.l   #10,d1
             jmp       Common_heal_condition

Heal_panic:  
             moveq.l   #10,d0               ; Heal panic
             moveq.l   #3,d1
             jmp       Common_heal_condition

Heal_irritated:        
             moveq.l   #11,d0               ; Heal irritation
             moveq.l   #0,d1
             jmp       Common_heal_condition

Heal_blind:  
             moveq.l   #12,d0               ; Heal blindness
             moveq.l   #4,d1
             jmp       Common_heal_condition

Heal_mad:    
             moveq.l   #13,d0               ; Heal madness
             moveq.l   #1,d1

; !!! CONTINUES !!!

; [ Common condition healing routine ]
;   IN : d0 - Message number (.w)
;        d1 - Condition bit number (.w)
; No registers are restored
Common_heal_condition: 
             move.w    d1,Condition_nr      ; Store
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    d0,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             movea.l   Victim_ptr,a0        ; Actually set ?
             move.w    Body_conditions(a0),d0
             move.w    Condition_nr,d1
             btst      d1,d0
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             bclr      d1,d0                ; Heal !
             move.w    d0,Body_conditions(a0)
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

; ************* Heal sleeping party ***********************
Heal_sleep:  
             jsr       Handle_spell         ; Try
             bmi       .Exit
             lea.l     Chard_ptrs,a0        ; Do !
             moveq.l   #1,d0
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             move.w    Body_conditions(a0),d1     ; Alive and kicking ?
             andi.w    #$e000,d1
             bne.s     .Next
             bclr      #2,Mind_conditions(a0)     ; Wake up !!
             jsr       Do_sparkle           ; Show
.Next:       addq.l    #4,a0                ; Next member
             addq.w    #1,d0
             cmpi.w    #6+1,d0
             bmi.s     .Loop
.Exit:       rts       

; ************* General conditions combat spells **********
Make_lamed:  
Make_sleep:  
Make_panic:  
Make_irritated:        
Make_blind:  

; ************* Undead combat spells **********************
Kill_undead: 
Holy_word:   
             DIAG_ON 
             PRINT     "This is a combat spell !!!"
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

; ************* Remove cursed object **********************
Remove_curse:          
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #21,WText_nr         ; !!! CHANGE LATER !!!
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Already
             jsr       Exit_display
.Already:    Push      Module,RemCurse2_Mod ; Do it
.Exit:       rts       

RemCurse2_DisInit:     
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             sne       Fade_block
             move.l    Victim_ptr,Current_inventory_chardat_ptr       ; Show
             jsr       Inv2_DisInit
             movea.l   Off_screen,a6        ; Print message
             move.l    #Code0007Sys,Textfile_ptr
             HashMes   21
             Update_screen 
             Push      MA,RemCurse_MA       ; Body area
             rts       

RemCurse2_DisExit:     
             Pop       MA
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Already
             jsr       Inv2_DisExit         ; Remove Inventory II
.Already:    rts       

Do_RemCurse: 
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number      ; Store
             ext.w     d0
             subq.w    #1,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       .Exit
             lea.l     Inv_data(a0),a2
             mulu.w    #40,d0
             adda.w    d0,a2
             btst      #0,Item_stat_bits(a2)      ; Actually cursed ?
             beq       .Exit

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object data (.l)

             jsr       Handle_spell         ; Try
             bmi       .Leave
             jsr       Mouse_off
             moveq.l   #50,d0               ; Wait 1 second
             jsr       Delay
             clr.b     (a1)                 ; Remove object
             moveq.l   #0,d2
             move.w    Weight(a2),d2
             sub.l     d2,Weight_normal(a0)
             moveq.l   #0,d2                ; Get icon numbers
             moveq.l   #0,d3
             move.b    (a2),d2
             lea.l     Erase_icon,a3
             move.b    Object_slot_number,d0
             ext.w     d0
             move.b    -1(a3,d0.w),d3
             lea.l     Object_pos_list-4,a3 ; Get coordinates
             add.w     d0,d0
             add.w     d0,d0
             move.w    2(a3,d0.w),d1
             move.w    0(a3,d0.w),d0
             jsr       Show_item_destruction      ; Destroy
             moveq.l   #50,d0               ; Wait 1 second
             jsr       Delay
.Leave:      Pop       Module               ; Exit
             jsr       Mouse_on
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Exit
             jsr       Init_display
.Exit:       rts       

Exit_RemCurse:         
             Pop       Module
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Exit
             jsr       Init_display
.Exit:       rts       

; ************* Create food *******************************
Create_food: 
             jsr       Handle_spell         ; Try
             bmi       .Exit
             lea.l     Chard_ptrs,a0        ; Do !
             moveq.l   #1,d0
             move.l    #Food_weight,d1
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             move.w    Body_conditions(a0),d1     ; Alive and kicking ?
             andi.w    #$e000,d1
             bne.s     .Next
             addq.w    #1,Food_rations(a0)  ; Have some food
             add.l     d1,Weight_normal(a0)
.Next:       addq.l    #4,a0                ; Next member
             addq.w    #1,d0
             cmpi.w    #6+1,d0
             bmi.s     .Loop
.Exit:       rts       

;*****************************************************************************
; [ Grey Magic spell routines ]
; No registers are restored
;*****************************************************************************

; ************* Light spells (permanent) *****************************
Light_1:     jsr       Handle_spell
             bmi.s     .Exit
             move.w    #2,Spell_1_data      ; Set light spell
             move.w    #24,Spell_1_duration
.Exit:       rts       

Light_2:     jsr       Handle_spell
             bmi.s     .Exit
             move.w    #4,Spell_1_data      ; Set light spell
             move.w    #96,Spell_1_duration
.Exit:       rts       

Light_3:     jsr       Handle_spell
             bmi.s     .Exit
             move.w    #6,Spell_1_data      ; Set light spell
             move.w    #192,Spell_1_duration
.Exit:       rts       

; ************* Armour spells (permanent) ****************************
Armour_1:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #5,Spell_2_data      ; Set armour spell
             move.w    #24,Spell_2_duration
.Exit:       rts       

Armour_2:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #10,Spell_2_data     ; Set armour spell
             move.w    #96,Spell_2_duration
.Exit:       rts       

Armour_3:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #15,Spell_2_data     ; Set armour spell
             move.w    #192,Spell_2_duration
.Exit:       rts       

; ************* Weapon spells (permanent) ****************************
Weapon_1:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #5,Spell_3_data      ; Set weapon spell
             move.w    #24,Spell_3_duration
.Exit:       rts       

Weapon_2:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #10,Spell_3_data     ; Set weapon spell
             move.w    #96,Spell_3_duration
.Exit:       rts       

Weapon_3:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #15,Spell_3_data     ; Set weapon spell
             move.w    #192,Spell_3_duration
.Exit:       rts       

; ************* Anti-magic spells (permanent) ************************
AntiMagic_1: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #5,Spell_4_data      ; Set anti-magic spell
             move.w    #24,Spell_4_duration
.Exit:       rts       

AntiMagic_2: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #10,Spell_4_data     ; Set anti-magic spell
             move.w    #96,Spell_4_duration
.Exit:       rts       

AntiMagic_3: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #15,Spell_4_data     ; Set anti-magic spell
             move.w    #192,Spell_4_duration
.Exit:       rts       

; ************* Clearvoyance spells (permanent) **********************
ClearV_1:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #2,Spell_5_data      ; Set clearvoyance spell
             move.w    #24,Spell_5_duration
.Exit:       rts       

ClearV_2:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #4,Spell_5_data      ; Set clearvoyance spell
             move.w    #96,Spell_5_duration
.Exit:       rts       

ClearV_3:    jsr       Handle_spell
             bmi.s     .Exit
             move.w    #6,Spell_5_data      ; Set clearvoyance spell
             move.w    #192,Spell_5_duration
.Exit:       rts       

; ************* Invisibility spells (permanent) **********************
Invisible_1: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #0,Spell_6_data      ; Set invisibility spell
             move.w    #24,Spell_6_duration
.Exit:       rts       

Invisible_2: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #0,Spell_6_data      ; Set invisibility spell
             move.w    #96,Spell_6_duration
.Exit:       rts       

Invisible_3: jsr       Handle_spell
             bmi.s     .Exit
             move.w    #0,Spell_6_data      ; Set invisibility spell
             move.w    #192,Spell_6_duration
.Exit:       rts       

; ************* Magic sphere (permanent) *****************************
Magic_sphere:          jsr                  Handle_spell
             bmi.s     .Exit
             move.w    #6,Spell_1_data      ; Set light spell
             move.w    #192,Spell_1_duration
             move.w    #15,Spell_2_data     ; Set armour spell
             move.w    #192,Spell_2_duration
             move.w    #15,Spell_3_data     ; Set weapon spell
             move.w    #192,Spell_3_duration
             move.w    #15,Spell_4_data     ; Set anti-magic spell
             move.w    #192,Spell_4_duration
             move.w    #6,Spell_5_data      ; Set clearvoyance spell
             move.w    #192,Spell_5_duration
             move.w    #0,Spell_6_data      ; Set invisibility spell
             move.w    #192,Spell_6_duration
.Exit:       rts       

; ************* Magic compass ****************************************
Magic_compass:         
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             Push      Module,MagicCompass_Mod    ; Do
.Exit:       rts       

MagicComp_DisInit:     
             moveq.l   #48,d0               ; Open window
             moveq.l   #64,d1
             moveq.l   #4,d2
             moveq.l   #4,d3
             moveq.l   #1,d6
             suba.l    a0,a0
             jsr       Open_window
             move.w    d0,Window_handle
             lea.l     Daynight_icn+2048,a0 ; Select direction
             move.w    View_direction,d0
             lsl.w     #8,d0
             add.w     d0,d0
             adda.w    d0,a0
             move.w    #48+16,d0            ; Display compass
             move.w    #64+16,d1
             moveq.l   #2,d6
             moveq.l   #32,d7
             movea.l   Off_screen,a6
             jsr       Blot_unmasked_block
             Update_screen 
             rts       

MagicComp_DisExit:     
             Wait_4_unclick 
             move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             rts       

; ************* Identify *********************************************
Identify:    
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #21,WText_nr         ; !!! CHANGE LATER !!!
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Already
             jsr       Exit_display
.Already:    Push      Module,Lore_Mod      ; Do it
.Exit:       rts       

Lore_DisInit:          
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             sne       Fade_block
             move.l    Victim_ptr,Current_inventory_chardat_ptr       ; Show
             jsr       Inv2_DisInit
             movea.l   Off_screen,a6        ; Print message
             move.l    #Code0007Sys,Textfile_ptr
             HashMes   22
             Update_screen 
             Push      MA,UseItem_area      ; Body & backpack area
             rts       

Do_Lore:     
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit2
             move.b    d0,Object_slot_number      ; Store
             ext.w     d0
             subq.w    #1,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       .Exit2
             lea.l     Inv_data(a0),a2
             mulu.w    #40,d0
             adda.w    d0,a2
             btst      #7,Item_stat_bits(a2)      ; Already lored ?
             bne       .Exit
             jsr       Handle_spell         ; Try
             bmi       .Exit
             bset      #7,Item_stat_bits(a2)      ; Lore item
             lea.l     ItemView1_Mod,a0     ; Show
             move.l    #.Dirty,Return_ptr(a0)
             jmp       Push_Module
.Dirty:      clr.l     ItemView1_Mod+Return_ptr   ; Clear pointer
.Exit:       Pop       Module               ; Exit
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Exit2
             jsr       Init_display
.Exit2:      rts       

; ************* Levitate *********************************************
Levitate:    
; ------------- Going up ? --------------------------------
             move.w    Map_Xcoord,d0        ; Find event
             move.w    Map_Ycoord,d1
             jsr       Find_event
             beq       .No_event            ; Any event ?
             cmpi.b    #5,(a5)              ; Trapdoor event ?
             bne       .No_event
             tst.b     3(a5)                ; Up ?
             bne       .No_event
             jsr       Handle_spell         ; Try
             bmi       Exit_levitate
             bra       Do_levitate
.No_event:   .LOCAL 
; ------------- Going down ? ------------------------------
             lea.l     Dir_offset,a0        ; Get coordinates in front
             move.w    View_direction,d0    ; of party
             add.w     d0,d0
             adda.w    d0,a0
             move.b    (a0)+,d0
             ext.w     d0
             add.w     Map_Xcoord,d0
             move.b    (a0),d1
             ext.w     d1
             add.w     Map_Ycoord,d1
             jsr       Find_event           ; Find event
             beq       Exit_levitate        ; Any event ?
             cmpi.b    #5,(a5)              ; Trapdoor event ?
             bne       Exit_levitate
             tst.b     3(a5)                ; Down ?
             beq       Exit_levitate
             jsr       Handle_spell         ; Try
             bmi       Exit_levitate
Do_levitate: jsr       Exit_map             ; Exit current map
             moveq.l   #0,d0                ; Get new coordinates
             move.b    1(a5),d0             ;  & map number
             move.w    d0,Map_Xcoord
             move.b    2(a5),d0
             move.w    d0,Map_Ycoord
             move.w    6(a5),Map_nr
             jsr       Init_map             ; Initialize new map
             jsr       Save_event
Exit_levitate:         
             rts       

; ************* Hurry ************************************************
Hurry:       
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #23,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             move.w    Victim_nr,d0         ; Already set ?
             move.w    Hurry_bitlist,d1
             btst      d0,d1
             bne.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             bset      d0,d1                ; Indicate
             move.w    d1,Hurry_bitlist
             movea.l   Victim_ptr,a0        ; Double attacks per round
             move.b    Attacks_per_round(a0),d0
             add.b     d0,d0
             move.b    d0,Attacks_per_round(a0)
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

; ************* Mega Hurry *******************************************
Mega_hurry:  
             move.w    Hurry_bitlist,d0     ; All hurried ?
             not.w     d0
             andi.w    #$007e,d0
             beq       .Exit
             jsr       Handle_spell         ; Try
             bmi       .Exit
             lea.l     Chard_ptrs,a0        ; All hurry
             moveq.l   #1,d0
             move.w    Hurry_bitlist,d1
             moveq.l   #6-1,d7
.Loop:       tst.l     (a0)                 ; Anyone there ?
             beq.s     .Next
             movea.l   (a0),a1              ; Get pointer to data
             move.w    #$e000,d2            ; Alive and kicking ?
             and.w     Body_conditions(a1),d2
             bne.s     .Next
             btst      d0,d1                ; Already set ?
             bne.s     .Next
             bset      d0,d1                ; Indicate
             move.b    Attacks_per_round(a1),d2   ; Double attacks per round
             add.b     d2,d2
             move.b    d2,Attacks_per_round(a1)
             jsr       Do_sparkle           ; Sparkle!
.Next:       addq.w    #1,d0                ; Next character
             addq.l    #4,a0
             dbra      d7,.Loop
             move.w    d1,Hurry_bitlist
.Exit:       rts       

MTeleport:   
Look_through:          
             rts       

;*****************************************************************************
; [ Black Magic spell routines ]
; No registers are restored
;*****************************************************************************
Fire_beam:   
Fire_push:   
Fire_ball:   
Fire_storm:  
Fire_waltz:  
Water_hole:  
Waterfall:   
Ice_ball:    
Ice_shower:  
Hail_storm:  
Dirt_sling:  
Stone_storm: 
Swamp_field: 
Earth_slide: 
Earthquake:  
Wind_push:   
Wind_devil:  
Wind_howler: 
Thunderstrike:         
Whirlwind:   
Dissolve:    
Magic_arrows:          
             rts       

;*****************************************************************************
; [ Monster Magic spell routines ]
; No registers are restored
;*****************************************************************************

Lame_it:     
Poison_it:   
Stone_it:    
Disease_it:  
Age_it:      
Irritate_it: 
Madden_it:   
Sleep_it:    
Panic_it:    
Blind_it:    
Stone_monster:         
Banish_demon:          
             DIAG_ON 
             PRINT     "This is a combat spell !!!"
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

; ************* Map view spell ****************************
Map_view:    
             jsr       Handle_spell         ; Try
             bmi       .Exit
             movea.l   Mapd_ptr,a0          ; šberhaupt possible ?
             move.b    Map_special(a0),d0
             btst      #3,d0
             bne.s     .Do_it
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0008Sys,Textfile_ptr
             move.w    #3,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             bra.s     .Exit
.Do_it:      tst.b     Magic_object_flag    ; Do
             beq.s     .No
             jsr       Inv2_DisExit
             bra       .Skip
.No:         jsr       Init_display
.Skip:       Push      Module,Minimap_Mod
.Exit:       rts       

;*****************************************************************************
; Minimap module
;*****************************************************************************
Minimap_DisUpd:        
             jsr       Update_status_block
             tst.b     Minimap_update       ; Update if necessary
             beq.s     .No_update
             movea.l   Off_screen,a6
             jsr       Display_minimap
             subq.b    #1,Minimap_update
.No_update:  move.w    Map_Xcoord,d0        ; Get party coordinates
             move.w    Map_Ycoord,d1
             cmpi.b    #1,Current_map_type  ; 2D wilderniss ?
             bne.s     .No_wild
             move.w    Quad_index,d2        ; Adapt coordinates
             btst      #0,d2
             beq.s     .Zero
             addi.w    #Submap_width,d0
.Zero:       btst      #1,d2
             beq.s     .No_wild
             addi.w    #Submap_height,d1
.No_wild:    subq.w    #1,d0
             subq.w    #1,d1
             move.w    d0,d2                ; Check if in window
             move.w    d1,d3
             lsr.w     #3,d2
             lsr.w     #3,d3
             sub.w     Minimap_X,d2
             sub.w     Minimap_Y,d3
             cmpi.w    #12,d2
             bhi.s     .Exit
             cmpi.w    #10,d3
             bhi.s     .Exit
             move.w    Minimap_X,d2         ; Adjust for scrolling
             move.w    Minimap_Y,d3
             lsl.w     #3,d2
             lsl.w     #3,d3
             sub.w     d2,d0
             sub.w     d3,d1
             add.w     d0,d0                ; Calculate pixel coordinates
             add.w     d1,d1
             addi.w    #16,d0
             addi.w    #49,d1
             move.w    d0,d2                ; Display party position
             move.w    d1,d3
             addq.w    #1,d2
             addq.w    #1,d3
             move.w    Minimap_colour,d6
             addq.w    #1,d6
             andi.w    #$f,d6
             move.w    d6,Minimap_colour
             movea.l   Off_screen,a6
             jsr       Draw_box
.Exit:       rts       

Minimap_ModInit:       
             Push      MA,Load_area         ; Z !
             Push      Mptr,#16
             lea.l     Minimap_CIL,a0       ; Enable all icons
             moveq.l   #9-1,d7
.Loop:       bclr      #7,(a0)+
             dbra      d7,.Loop
             lea.l     -9(a0),a0
             move.w    #0,Minimap_X         ; Set coordinates
             move.w    #0,Minimap_Y
             cmpi.b    #1,Current_map_type  ; 2D wilderniss ?
             bne       .No_wild
; ------------- Check control icons ----------------------------------
             move.w    #Submap_width,d0     ; Check width
             add.w     d0,d0
             cmpi.w    #8*11,d0
             bpl.s     .Ok1
             bset      #7,(a0)              ; Disable horizontal icons
             bset      #7,2(a0)
             bset      #7,3(a0)
             bset      #7,5(a0)
             bset      #7,6(a0)
             bset      #7,8(a0)
.Ok1:        move.w    #Submap_height,d0    ; Check height
             add.w     d0,d0
             cmpi.w    #8*9,d0
             bpl.s     .Ok2
             bset      #7,0(a0)             ; Disable vertical icons
             bset      #7,1(a0)
             bset      #7,2(a0)
             bset      #7,6(a0)
             bset      #7,7(a0)
             bset      #7,8(a0)
; ------------- Make minimap -----------------------------------------
.Ok2:        move.w    #Submap_width,d0     ; Calculate minimap size
             add.w     d0,d0
             addi.w    #7,d0
             lsr.w     #3,d0
             move.w    d0,Minimap_width
             move.w    #Submap_height,d1
             add.w     d1,d1
             addi.w    #7,d1
             lsr.w     #3,d1
             move.w    d1,Minimap_height
             mulu.w    d1,d0                ; Make minimap buffer
             lsl.l     #7,d0
             jsr       Allocate_memory
             move.l    a1,Minimap_ptr
             moveq.l   #0,d1                ; Clear minimap
             lsr.w     #2,d0
             subq.w    #1,d0
.Clear1:     move.l    d1,(a1)+
             dbra      d0,.Clear1
             lea.l     Quad_map,a3          ; Insert all 4 submaps
             moveq.l   #0,d1
             moveq.l   #0,d4
             movea.l   (a3)+,a0
             jsr       .Do_it
             moveq.l   #0,d1
             move.w    #Submap_width,d4
             movea.l   (a3)+,a0
             jsr       .Do_it
             move.w    #Submap_height,d1
             moveq.l   #0,d4
             movea.l   (a3)+,a0
             jsr       .Do_it
             move.w    #Submap_height,d1
             move.w    #Submap_width,d4
             movea.l   (a3),a0
             jsr       .Do_it
             bra       .Exit

; [ Insert wilderniss submap in minimap ]
;   IN : d1 - Start Y-coordinate (.w)
;        d4 - Start X-coordinate (.w)
;        a0 - Pointer to map data (.l)
; Changed registers : d0,d1,d2,d3,d5,d6,d7,a1
.Do_it:      
             lea.l     Map_data(a0),a0      ; Initialize registers
             movea.l   Icondata_ptr,a1
             lea.l     Map_icon_color(a1),a1
             moveq.l   #0,d2
             move.w    Size_of_map,d5
             move.w    Height_of_map,d7
             subq.w    #1,d7
.LoopY1:     move.w    d4,d0
             move.w    Width_of_map,d6
             subq.w    #1,d6
.LoopX1:     move.b    (a0),d2              ; Get underlay icon colour
             move.b    -1(a1,d2.w),d2
             jsr       Set1_minimap_element ; Set 2x2 pixels
             move.b    0(a0,d5.w),d2        ; Get overlay icon colour
             beq.s     .Next1
             move.b    -1(a1,d2.w),d2
             jsr       Set2_minimap_element ; Set 2x2 pixels
.Next1:      addq.l    #1,a0                ; Next X
             addq.w    #1,d0
             dbra      d6,.LoopX1
             addq.w    #1,d1                ; Next Y
             dbra      d7,.LoopY1
             rts       

; ------------- Check control icons ----------------------------------
.No_wild:    move.w    Width_of_map,d0      ; Check width
             cmpi.w    #8*11,d0
             bpl.s     .Ok3
             bset      #7,(a0)              ; Disable horizontal icons
             bset      #7,2(a0)
             bset      #7,3(a0)
             bset      #7,5(a0)
             bset      #7,6(a0)
             bset      #7,8(a0)
.Ok3:        move.w    Height_of_map,d0     ; Check height
             cmpi.w    #8*9,d0
             bpl.s     .Ok4
             bset      #7,0(a0)             ; Disable vertical icons
             bset      #7,1(a0)
             bset      #7,2(a0)
             bset      #7,6(a0)
             bset      #7,7(a0)
             bset      #7,8(a0)
.Ok4:        move.w    Width_of_map,d0      ; Calculate minimap size
             addq.w    #7,d0
             lsr.w     #3,d0
             move.w    d0,Minimap_width
             move.w    Height_of_map,d1
             addq.w    #7,d1
             lsr.w     #3,d1
             move.w    d1,Minimap_height
             mulu.w    d1,d0                ; Make minimap buffer
             lsl.l     #7,d0
             jsr       Allocate_memory
             move.l    a1,Minimap_ptr
             moveq.l   #0,d1                ; Clear minimap
             lsr.w     #2,d0
             subq.w    #1,d0
.Clear2:     move.l    d1,(a1)+
             dbra      d0,.Clear2
             cmpi.b    #2,Current_map_type  ; 3D map ?
             bmi       .No_3D
             movea.l   Map_pointer,a0       ; Initialize registers
             movea.l   Lab_IC_ptr,a1
             moveq.l   #0,d1
             moveq.l   #0,d2
             move.w    Height_of_map,d7
             subq.w    #1,d7
.LoopY2:     moveq.l   #0,d0
             move.w    Width_of_map,d6
             subq.w    #1,d6
.LoopX2:     move.b    (a0)+,d2             ; Get colour
             move.b    -1(a1,d2.w),d2
             jsr       Set1_minimap_element ; Set 2x2 pixels
             addq.w    #1,d0                ; Next X
             dbra      d6,.LoopX2
             addq.w    #1,d1                ; Next Y
             dbra      d7,.LoopY2
             bra       .Exit
.No_3D:      movea.l   Map_pointer,a0       ; Initialize registers
             movea.l   Icondata_ptr,a1
             lea.l     Map_icon_color(a1),a1
             moveq.l   #0,d1
             moveq.l   #0,d2
             move.w    Size_of_map,d5
             move.w    Height_of_map,d7
             subq.w    #1,d7
.LoopY3:     moveq.l   #0,d0
             move.w    Width_of_map,d6
             subq.w    #1,d6
.LoopX3:     move.b    (a0),d2              ; Get underlay icon colour
             move.b    -1(a1,d2.w),d2
             jsr       Set1_minimap_element ; Set 2x2 pixels
             move.b    0(a0,d5.w),d2        ; Get overlay icon colour
             beq.s     .Next3
             move.b    -1(a1,d2.w),d2
             jsr       Set2_minimap_element ; Set 2x2 pixels
.Next3:      addq.l    #1,a0                ; Next X
             addq.w    #1,d0
             dbra      d6,.LoopX3
             addq.w    #1,d1                ; Next Y
             dbra      d7,.LoopY3
.Exit:       Pop       Mptr                 ; No Z
             Pop       MA
             jmp       Init_display

Minimap_ModExit:       
             movea.l   Minimap_ptr,a0       ; Return memory
             jsr       Free_memory
             jmp       Minimap_DisExit

Minimap_DisInit:       
             Push      MA,Standard_MA
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #11,d0               ; Show automapper layout
             jsr       Show_layout
             move.w    #16,d0               ; Clear minimap area
             move.w    #49,d1
             move.w    #16+176-1,d2
             move.w    #49+144-1,d3
             moveq.l   #0,d6
             jsr       Draw_box
             movea.l   Mapd_ptr,a5          ; Print headline
             jsr       Print_headline
             move.b    #2,Minimap_update    ; Display minimap
             move.l    #Minimap_CIL,Control_list_ptr        ; Display control icons
             jsr       Show_control_icons
             Update_screen 
             lea.l     Control_area,a0      ; Set object branch
             jsr       Set_layout_data
             cmpi.b    #2,Current_map_type  ; 2D or 3D map ?
             bpl.s     .3D_map
             movea.l   Icondata_ptr,a0      ; Select palette
             lea.l     Icon_palette(a0),a0
             bra.s     .Go_on
.3D_map:     movea.l   Colpall_ptrs,a0
.Go_on:      lea.l     Pal_buffer,a1        ; Convert IFF-palette
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

Minimap_DisExit:       
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
             Pop       MA
             rts       

; ************* Exit minimap ******************************
Minimap_exit:          
             Pop       Module
             tst.b     Magic_object_flag
             beq.s     .No
             Pop       Module
.No:         jsr       Init_display
.Exit:       rts       

;*****************************************************************************
; [ Minimap controls ]
;*****************************************************************************
Minimap_up:  
             move.w    Minimap_Y,d0
             subq.w    #1,d0
             bmi.s     .Exit
             move.w    d0,Minimap_Y
             move.b    #2,Minimap_update
.Exit:       rts       

Minimap_left:          
             move.w    Minimap_X,d0
             subq.w    #1,d0
             bmi.s     .Exit
             move.w    d0,Minimap_X
             move.b    #2,Minimap_update
.Exit:       rts       

Minimap_right:         
             move.w    Minimap_X,d0
             addq.w    #1,d0
             move.w    Minimap_width,d1
             subi.w    #11-1,d1
             cmp.w     d1,d0
             bpl.s     .Exit
             move.w    d0,Minimap_X
             move.b    #2,Minimap_update
.Exit:       rts       

Minimap_down:          
             move.w    Minimap_Y,d0
             addq.w    #1,d0
             move.w    Minimap_height,d1
             subi.w    #9-1,d1
             cmp.w     d1,d0
             bpl.s     .Exit
             move.w    d0,Minimap_Y
             move.b    #2,Minimap_update
.Exit:       rts       

Minimap_upleft:        
             jsr       Minimap_up
             jmp       Minimap_left

Minimap_upright:       
             jsr       Minimap_up
             jmp       Minimap_right

Minimap_downleft:      
             jsr       Minimap_down
             jmp       Minimap_left

Minimap_downright:     
             jsr       Minimap_down
             jmp       Minimap_right

;*****************************************************************************
; [ Display minimap ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_minimap:       
             movem.l   d0-d2/d5-d7/a0,-(sp)
             moveq.l   #11,d6               ; Load dimensions
             cmp.w     Minimap_width,d6
             bmi.s     .Ok1
             move.w    Minimap_width,d6
.Ok1:        moveq.l   #9,d5
             cmp.w     Minimap_height,d5
             bmi.s     .Ok2
             move.w    Minimap_height,d5
.Ok2:        movea.l   Minimap_ptr,a0       ; Calculate pointer to minimap
             move.w    Minimap_Y,d0
             mulu.w    Minimap_width,d0
             lsl.w     #7,d0
             adda.w    d0,a0
             move.w    Minimap_X,d0
             lsl.w     #3,d0
             adda.w    d0,a0
             moveq.l   #16,d0               ; Initialize registers
             moveq.l   #49,d1
             move.w    Minimap_width,d2
             lsl.w     #3,d2
             lsl.w     #4,d5
             subq.w    #1,d5
             moveq.l   #1,d7
.Loop:       jsr       Blot_unmasked_block  ; Display line
             addq.w    #1,d1
             adda.w    d2,a0                ; Next line
             dbra      d5,.Loop
             movem.l   (sp)+,d0-d2/d5-d7/a0
             rts       

;*****************************************************************************
; [ Set full minimap element in minimap graphics buffer ]
;   IN : d0 - X-coordinate {0...} (.w)
;        d1 - Y-coordinate {0...} (.w)
;        d2 - Colour {0...15} (.w)
; All registers are restored
;*****************************************************************************
Set1_minimap_element:  
             movem.l   d0-d3/d6/d7/a0,-(sp)
             movea.l   Minimap_ptr,a0
             move.w    Minimap_width,d6
             lsl.w     #3,d6
             move.w    d6,d3                ; Calculate Y-offset
             add.w     d3,d3
             mulu.w    d3,d1
             adda.w    d1,a0
             move.w    d0,d1
             andi.w    #$fff8,d0            ; Calculate X-offset
             adda.w    d0,a0
             andi.w    #$7,d1               ; Calculate shift value
             add.w     d1,d1
             move.w    #$c000,d0            ; Calculate graphic masks
             lsr.w     d1,d0
             move.w    d0,d1
             not.w     d1
             moveq.l   #4-1,d7
.Loop:       lsr.w     #1,d2                ; Test colour
             bcc.s     .Clear
             or.w      d0,0(a0,d6.w)        ; Set plane
             or.w      d0,(a0)+
             bra.s     .Next
.Clear:      and.w     d1,0(a0,d6.w)        ; Clear plane
             and.w     d1,(a0)+
.Next:       dbra      d7,.Loop
             movem.l   (sp)+,d0-d3/d6/d7/a0
             rts       

;*****************************************************************************
; [ Set transparent minimap element in minimap graphics buffer ]
;   IN : d0 - X-coordinate {0...} (.w)
;        d1 - Y-coordinate {0...} (.w)
;        d2 - Colour {0...15} (.w)
; All registers are restored
;*****************************************************************************
Set2_minimap_element:  
             movem.l   d0-d3/d6/d7/a0,-(sp)
             movea.l   Minimap_ptr,a0
             move.w    Minimap_width,d6
             lsl.w     #3,d6
             move.w    d6,d3                ; Calculate Y-offset
             add.w     d3,d3
             mulu.w    d3,d1
             adda.w    d1,a0
             move.w    d0,d1
             andi.w    #$fff8,d0            ; Calculate X-offset
             adda.w    d0,a0
             andi.w    #$7,d1               ; Calculate shift value
             add.w     d1,d1
             move.w    #$8000,d0            ; Calculate graphic masks
             lsr.w     d1,d0
             move.w    d0,d1
             not.w     d1
             moveq.l   #4-1,d7
.Loop:       lsr.w     #1,d2                ; Shift colour
             bcc.s     .Clear
             or.w      d0,0(a0,d6.w)        ; Set plane
             ror.w     #1,d0
             or.w      d0,(a0)+
             rol.w     #1,d0
             bra.s     .Next
.Clear:      and.w     d1,0(a0,d6.w)        ; Clear plane
             ror.w     #1,d1
             and.w     d1,(a0)+
             rol.w     #1,d1
.Next:       dbra      d7,.Loop
             movem.l   (sp)+,d0-d3/d6/d7/a0
             rts       

; ************* Spellpoints replenish spell ***************
Spellpts1:   
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0008Sys,Textfile_ptr
             move.w    #5,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             movea.l   Victim_ptr,a0        ; Do
             jsr       Random
             mulu.w    #25,d0
             swap.w    d0
             addq.w    #1,d0
             add.w     Power_points_normal(a0),d1
             move.w    Power_points_max(a0),d0
             add.w     Power_points_max_magic(a0),d0
             cmp.w     d1,d0
             bpl.s     .Skip
             move.w    d0,d1
.Skip:       move.w    d1,Power_points_normal(a0)
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

Spellpts2:   
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0008Sys,Textfile_ptr
             move.w    #5,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             movea.l   Victim_ptr,a0        ; Do
             move.w    Power_points_max(a0),d0
             add.w     Power_points_max_magic(a0),d0
             cmp.w     Power_points_normal(a0),d0
             bmi.s     .Exit
             move.w    d0,Power_points_normal(a0)
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

; ************* Weapon gunk spell ************************************
Weapon_gunk: 
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0007Sys,Textfile_ptr
             move.w    #21,WText_nr         ; !!! CHANGE LATER !!!
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Already
             jsr       Exit_display
.Already:    Push      Module,Gunk_Mod      ; Do it
.Exit:       rts       

Gunk_DisInit:          
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             sne       Fade_block
             move.l    Victim_ptr,Current_inventory_chardat_ptr       ; Show
             jsr       Inv2_DisInit
             movea.l   Off_screen,a6        ; Print message
             move.l    #Code0008Sys,Textfile_ptr
             HashMes   6
             Update_screen 
             Push      MA,UseItem_area      ; Body & backpack area
             rts       

Do_Gunk:     
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number      ; Store
             ext.w     d0
             subq.w    #1,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       .Exit
             lea.l     Inv_data(a0),a2
             mulu.w    #40,d0
             adda.w    d0,a2
             cmpi.b    #4,Item_type(a2)     ; Short-range weapon ?
             beq.s     .Ok
             cmpi.b    #5,Item_type(a2)     ; Long-range weapon ?
             bne       .Exit
.Ok:         jsr       Handle_spell         ; Try
             bmi       .Leave
             jsr       Random               ; Do
             lsl.w     #2,d0
             swap.w    d0
             addq.w    #1,d0
             moveq.l   #0,d1
             move.b    Damage_pts(a2),d1
             add.w     d0,d1
             cmpi.w    #128,d1
             bmi.s     .Not2much
             moveq.l   #127,d1
.Not2much:   move.b    d1,Damage_pts(a2)
.Leave:      Pop       Module               ; Exit
             tst.b     Magic_object_flag    ; Already in Inventory 2 ?
             bne.s     .Exit
             jsr       Init_display
.Exit:       rts       

; ************* Youth spell ******************************************
Youth:       
             movea.l   Textfile_ptr,a0      ; Print text
             move.l    #Code0008Sys,Textfile_ptr
             move.w    #7,WText_nr
             Push      Module,TxtW_Mod
             move.l    a0,Textfile_ptr
             lea.l     VictimSel_Mod,a0     ; Select a victim
             move.l    #.Continue,Return_ptr(a0)
             jmp       Push_Module
.Continue:   
             Pop       Module               ; Remove text
             tst.b     Victim_selected      ; Any selected ?
             beq.s     .Exit
             jsr       Handle_spell         ; Try
             bmi.s     .Exit
             movea.l   Victim_ptr,a0        ; Do
             move.w    Attr_9_normal(a0),d1
             jsr       Random
             mulu.w    #10,d0
             swap.w    d0
             addq.w    #1,d0
             sub.w     d0,d1
             cmpi.w    #15,d1               ; Too young ?
             bmi.s     .Exit
             move.w    d1,Attr_9_normal(a0) ; Store new age
             move.w    Victim_nr,d0         ; Show
             jsr       Do_sparkle
.Exit:       rts       

; ************* Call giant eagle *************************************
Call_eagle:  
             rts       

;*****************************************************************************
; [ Spell class select window module ]
;*****************************************************************************
SCSelW_DisInit:        
             move.w    #16,d0               ; Open window
             move.w    #64,d1
             move.w    #10,d2
             move.w    #5,d3
             moveq.l   #1,d6
             lea.l     SCSelW_L1,a0
             jsr       Open_window
             move.w    d0,SCSelW_handle
             Push      PA,SCSelW_PA
             movea.l   Off_screen,a6        ; Print class names
             moveq.l   #1,d1
             movea.l   Current_active_char_data,a0
             move.b    Spell_class_counter(a0),d2
             lea.l     Spell_dat+Spellclass_names,a1
             moveq.l   #7-1,d7
.Loop:       btst      d1,d2                ; Class known ?
             beq.s     .Next
             move.w    (a1),d0              ; Get class name
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print it
             jsr       IG_Print
.Next:       jsr       IG_Carriage_return   ; Next class
             addq.w    #1,d1
             addq.l    #2,a1
             dbra      d7,.Loop
             Update_screen 
             rts       

SCSelW_DisExit:        
             move.w    SCSelW_handle,d0
             jsr       Close_window
             Pop       PA
             rts       

ClassSelected:         
             Wait_4_unclick 
             lsr.w     #8,d0                ; Filled slot ?
             movea.l   Current_active_char_data,a0
             btst      d0,Spell_class_counter(a0)
             beq.s     .Exit
             move.w    d0,Selected_class    ; Store
             Pop       Module
             lea.l     Spells_class_1(a0),a0      ; Any spells known ?
             add.w     d0,d0
             add.w     d0,d0
             tst.l     -4(a0,d0.w)
             bne.s     .Select
             st        No_spell_selected    ; Exit !
             bra.s     .Exit
.Select:     Push      Module,SpSelW_Mod    ; Select spell
.Exit:       rts       

Exit_SCSelW: 
             st        No_spell_selected
             jmp       Pop_Module

;*****************************************************************************
; [ Spell select window module ]
;*****************************************************************************
SpSelW_ModInit:        
             sf        No_spell_selected
             clr.w     Spell_list_pos
; ------------- Make list of spells & status -------------------------
             movea.l   Current_active_char_data,a0
             moveq.l   #0,d1                ; Initialize registers
             moveq.l   #1,d2
             move.w    Spell_area_type,d4
             move.w    Power_points_normal(a0),d6
             lea.l     Spell_dat,a1         ; Get pointer to spell data
             move.w    Selected_class,d0
             subq.w    #1,d0
             mulu.w    #120,d0
             adda.w    d0,a1
             lea.l     Spells_class_1(a0),a0      ; Get known spells bit-list
             move.w    Selected_class,d0
             add.w     d0,d0
             add.w     d0,d0
             move.l    -4(a0,d0.w),d3
             lea.l     Spells_per_class,a0  ; Get number of spells
             move.w    Selected_class,d7
             add.w     d7,d7
             move.w    -2(a0,d7.w),d7
             lea.l     Spell_dat+Spell_names,a2   ; Get pointer to spell names
             move.w    Selected_class,d0
             subq.w    #1,d0
             mulu.w    #60,d0
             adda.w    d0,a2
             lea.l     Spell_table,a0
             bra       .Entry

; ------------- REGISTER CONTENTS ------------------------------------
;  d1 - Possible spell counter (.w)
;  d2 - Bit index (.w)
;  d3 - Known spells bit-list (.l)
;  d4 - Spell area type (.w)
;  d6 - Number of spell points (.w)
;  d7 - Spell counter (.w)
;  a0 - Pointer to spell table (.l)
;  a1 - Pointer to spell data (.l)
;  a2 - Pointer to spell names (.l)

.Loop:       btst      d2,d3                ; Spell known ?
             beq       .Next
             addq.w    #1,d1                ; Count
             moveq.l   #0,d5
             move.b    (a1),d0              ; Right area ?
             btst      d4,d0
             bne.s     .Right
             moveq.l   #1,d0                ; -> Wrong area
             bra.s     .Do
.Right:      move.b    1(a1),d0             ; Enough spell points ?
             ext.w     d0
             cmp.w     d0,d6
             bpl.s     .Enough
             moveq.l   #2,d0                ; -> Not enough PP
             bra.s     .Do
.Enough:     moveq.l   #0,d5                ; How many times ?
             move.w    d6,d5
             divu.w    d0,d5
             cmpi.w    #100,d5
             bmi.s     .Ok
             moveq.l   #99,d5
.Ok:         moveq.l   #15,d0               ; -> Possible spell
.Do:         move.b    d0,(a0)+             ; Store spell data
             move.b    d2,(a0)+
             move.w    d5,(a0)+
             move.w    (a2),(a0)+
.Next:       addq.w    #1,d2                ; Next spell
             addq.l    #4,a1
             addq.l    #2,a2
.Entry:      dbra      d7,.Loop
             move.w    d1,Nr_of_spells      ; Store number
             .LOCAL 
; ------------- Convert list to text ---------------------------------
             moveq.l   #28,d0               ; Make text buffer
             mulu.w    d1,d0
             jsr       Allocate_memory
             move.l    a1,Text_buffer
             movea.l   a1,a0                ; Clear text buffer
             lsr.w     #2,d0
             subq.w    #1,d0
             move.l    #"    ",d1
.Loop:       move.l    d1,(a0)+
             dbra      d0,.Loop
             .LOCAL 
             lea.l     Spell_table,a2       ; Initialize registers
             moveq.l   #" ",d1
             moveq.l   #2,d7
             move.w    Nr_of_spells,d6
             bra       .Entry
.Loop1:      movea.l   a1,a3                ; Duplicate text pointer
             move.b    #1,(a3)+             ; Set ink
             move.b    (a2),(a3)+
             move.w    4(a2),d0             ; Get pointer to word
             jsr       Find_word
             moveq.l   #0,d0                ; Get length of word
             move.b    (a0)+,d0
             subq.w    #1,d0
             bra.s     .Entry2
.Loop2:      move.b    (a0)+,(a3)+          ; Copy word
.Entry2:     dbra      d0,.Loop2
             move.w    2(a2),d0             ; Possible spell ?
             beq.s     .Next
             lea.l     23(a1),a3            ; Convert counter
             move.b    #"(",(a3)+
             jsr       RConvert_number
             move.b    #")",(a3)
.Next:       lea.l     27(a1),a1            ; Next spell
             clr.b     (a1)+
             addq.l    #6,a2
.Entry:      dbra      d6,.Loop1
             .LOCAL 
; ------------- Make graphics buffer ---------------------------------
             moveq.l   #-1,d0               ; Set paper
             jsr       IG_Set_paper
             move.w    #560,d0              ; Make graphics buffer
             mulu.w    Nr_of_spells,d0
             jsr       Allocate_memory
             move.l    a1,Text_graphics_buffer
             move.l    #7*160,d0            ; Make line graphics buffer
             jsr       Allocate_memory
             movea.l   a1,a6
             moveq.l   #0,d0                ; Initialize registers
             moveq.l   #0,d1
             move.w    #160-1,d2
             moveq.l   #7-1,d3
             moveq.l   #3,d4
             move.w    Nr_of_spells,d5
             moveq.l   #10,d6
             moveq.l   #7,d7
             movea.l   Text_buffer,a0
             movea.l   Text_graphics_buffer,a1
             lea.l     5,a2
             bra.s     .Entry
.Loop:       exg.l     d4,d6                ; Clear line graphics buffer
             jsr       Draw_box
             exg.l     d4,d6
             exg.l     d0,a2                ; Set cursor at (5,0)
             jsr       IG_Set_cursor
             exg.l     d0,a2
             jsr       IG_Print             ; Print text on fake screen
             exg.l     a0,a1                ; Copy line to graphics buffer
             jsr       Get2_block
             exg.l     a0,a1
             lea.l     28(a0),a0            ; Next line
             lea.l     560(a1),a1
.Entry:      dbra      d5,.Loop
             .LOCAL 
; ------------- Do stuff ---------------------------------------------
             move.w    Nr_of_spells,d0      ; Store height of buffer
             mulu.w    #7,d0
             move.w    d0,Height_of_buffer
             move.w    #80,Width_of_buffer  ; Store width of buffer
             movea.l   a6,a0                ; Free memory
             jsr       Free_memory
             movea.l   Text_buffer,a0
             jsr       Free_memory
             Push      PA,SpSelW_PA
             move.w    #First_add,Adding    ; Reset
; ------------- Open a window ----------------------------------------
             moveq.l   #32,d0
             moveq.l   #40,d1
             moveq.l   #12,d2
             moveq.l   #10,d3
             moveq.l   #2,d4
             moveq.l   #1,d6
             lea.l     SpSelW_L1,a0
             jsr       Open_window
             move.w    d0,SpSelW_handle
; ------------- Fill window ------------------------------------------
             movea.l   Off_screen,a6
             moveq.l   #32+16,d0            ; Clear word area
             moveq.l   #40+16,d1
             move.w    d0,d2
             addi.w    #159,d2
             move.w    d1,d3
             addi.w    #111,d3
             moveq.l   #3,d6
             jsr       Draw_box
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #32+16,d0            ; Up
             move.w    #40+16+112,d1
             lea.l     Control_icn+256,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; Down
             lea.l     Control_icn+512,a0
             jsr       Blot_unmasked_block
             addi.w    #96,d0               ; Exit
             lea.l     Control_icn+7680,a0
             jsr       Blot_unmasked_block
             Update_screen 
No_spells_known:       
             rts       

SpSelW_DisUpd:         
             move.w    Spell_list_pos,d0    ; Refresh text window
             mulu.w    #7,d0
             movea.l   PA_sp,a5
             movea.l   (a5),a5
             movea.l   Off_screen,a6
             jsr       Refresh_text_window
             rts       

SpSelW_ModExit:        
             Pop       PA
             movea.l   Text_graphics_buffer,a0    ; Free memory
             jsr       Free_memory
             move.w    SpSelW_handle,d0     ; Close window
             jsr       Close_window
             rts       

; [ Spell select action ]
;   IN : d0 - Number of spell slot (.w)
SpellSelected:         
             Wait_4_unclick 
             lsr.w     #8,d0                ; Calculate index
             subq.w    #1,d0
             add.w     Spell_list_pos,d0
             cmp.w     Nr_of_spells,d0      ; Empty slot ?
             bpl.s     .Exit
             lea.l     Spell_table,a0       ; Get spell data
             mulu.w    #6,d0
             tst.w     2(a0,d0.w)           ; Possible spell ?
             beq.s     .Exit
             move.b    1(a0,d0.w),d0        ; Get spell number
             ext.w     d0
             move.w    d0,Selected_spell
             Pop       Module
.Exit:       rts       

; [ Exit icon action ]
ExitSpellSelect:       
             st        No_spell_selected    ; No spell selected!
             Pop       Module
             Wait_4_unclick 
             rts       

;*****************************************************************************
; [ Spell list scroll routines ]
; Changed registers : d0,d1
;*****************************************************************************
SpSel_1Up:   
             moveq.l   #1,d0                ; Scroll up 1
             jmp       SpSel_UP

SpSel_1Down: 
             moveq.l   #1,d0                ; Scroll down 1
             jmp       SpSel_DOWN

SpSel_8Up:   
             moveq.l   #8,d0                ; Scroll up 8
             jmp       SpSel_UP

SpSel_8Down: 
             moveq.l   #8,d0                ; Scroll down 8
             jmp       SpSel_DOWN

SpSel_X1Up:  
             move.w    Adding,d0            ; Scroll up exp.
             lsr.w     #8,d0
             jsr       SpSel_UP
             jmp       Inc_adding

SpSel_X1Down:          
             move.w    Adding,d0            ; Scroll down exp.
             lsr.w     #8,d0
             jsr       SpSel_DOWN
             jmp       Inc_adding

SpSel_X8Up:  
             move.w    Adding,d0            ; Scroll up exp. x 8
             lsr.w     #5,d0
             andi.w    #$fff8,d0
             jsr       SpSel_UP
             jmp       Inc_adding

SpSel_X8Down:          
             move.w    Adding,d0            ; Scroll down exp. x 8
             lsr.w     #5,d0
             andi.w    #$fff8,d0
             jsr       SpSel_DOWN
             jmp       Inc_adding

; [ Scroll up ]
;   IN : d0 - Up offset (.w)
; Changed registers : d1
SpSel_UP:    
             move.w    Spell_list_pos,d1    ; Scroll up
             sub.w     d0,d1
             bpl.s     .Skip                ; Too far ?
             moveq.l   #0,d1                ; Reset
             move.w    #First_add,Adding
.Skip:       move.w    d1,Spell_list_pos
             rts       

; [ Scroll down ]
;   IN : d0 - Down offset (.w)
; Changed registers : d1
SpSel_DOWN:  
             move.w    Spell_list_pos,d1    ; Scroll down
             add.w     d0,d1
             cmp.w     Nr_of_spells,d1      ; Too far ?
             bmi.s     .Skip
             move.w    Nr_of_spells,d1      ; Reset
             subq.w    #1,d1
             move.w    #First_add,Adding
.Skip:       move.w    d1,Spell_list_pos
             rts       

;*****************************************************************************
; [ Character select module ]
; All registers are restored
;*****************************************************************************
VictimSel_ModInit:     
             sf        Victim_selected
             Push      MA,Load_area
             rts       

VictimSel_ModExit:     
             Pop       MA
             rts       

Victim_clicked:        
             Wait_4_unclick 
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #8,d0
             lea.l     Chard_ptrs-4,a0      ; Get pointer to character
             move.w    d0,d1                ; data
             add.w     d1,d1
             add.w     d1,d1
             adda.w    d1,a0
             tst.l     (a0)                 ; Anyone there ?
             beq.s     .Exit
             move.w    d0,Victim_nr         ; Set data
             move.l    (a0),Victim_ptr
             st        Victim_selected
.Exit:       jmp       Pop_Module

;*****************************************************************************
; [ Increase LP ]
;   IN : d0 - Added amount of LP (.w)
;        a0 - Pointer to character data (.l)
; All registers are restored
;*****************************************************************************
Increase_LP: 
             movem.l   d1/d2,-(sp)
             move.w    Life_points_normal(a0),d1  ; Get data
             move.w    Life_points_max(a0),d2
             add.w     Life_points_max_magic(a0),d2
             cmp.w     d2,d1                ; Already too much ?
             bpl.s     .Exit
             add.w     d0,d1                ; Add
             cmp.w     d2,d1                ; Not too much !
             bmi.s     .Ok
             move.w    d2,d1
.Ok:         move.w    d1,Life_points_normal(a0)
.Exit:       movem.l   (sp)+,d1/d2
             rts       

;*****************************************************************************
; [ Activate magic animation ]
;   IN : d0 - Character number (.w)
; All registers are restored
;*****************************************************************************
Do_sparkle:  
             move.l    a0,-(sp)
             lea.l     Magic_timers,a0      ; Activate sparkle
             move.b    #10,-1(a0,d0.w)
             movea.l   (sp)+,a0
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Spells_per_class:      .DC.w 28,26,22,0,0,0,19
SCSelW_PA:   .DC.w 16+16,64+16,128,49,15,2
SpSelW_PA:   .DC.w 32+16,40+16,160,112,15,3
Spellname_pos_list:    
y            set 0
             .REPT 15
             .DC.w 48,52+y
y            set y+7
             .ENDR 
y            set 0
             .REPT 15
             .DC.w 48+128,52+y
y            set y+7
             .ENDR 
RemCurse_MA: .DC.w 16,95,81,160
Minimap_CIL: .DC.b 46,1,45,4,30,3,48,2,47
             .EVEN 
             .DC.l Minimap_upleft,Minimap_up,Minimap_upright
             .DC.l Minimap_left,Minimap_exit,Minimap_right
             .DC.l Minimap_downleft,Minimap_down,Minimap_downright

             .BSS 
Nr_of_spell_classes:   .DS.w 1
SCSelW_handle:         .DS.w 1
SpSelW_handle:         .DS.w 1
Selected_class:        .DS.w 1
Selected_spell:        .DS.w 1
Spell_area_type:       .DS.w 1
Spelldat_ptr:          .DS.l 1

Victim_selected:       .DS.b 1
No_spell_selected:     .DS.b 1
Magic_object_flag:     .DS.b 1
Spell_failed:          .DS.b 1
             .EVEN 
Victim_nr:   .DS.w 1
Victim_ptr:  .DS.l 1
Added_LP:    .DS.w 1
Condition_nr:          .DS.w 1
Hurry_bitlist:         .DS.w 1

Spell_table: .DS.w 3*30
Spell_list_pos:        .DS.w 1
Nr_of_spells:          .DS.w 1

Minimap_X:   .DS.w 1
Minimap_Y:   .DS.w 1
Minimap_colour:        .DS.w 1
Minimap_height:        .DS.w 1
Minimap_width:         .DS.w 1
Minimap_ptr: .DS.l 1
Minimap_update:        .DS.b 1
             .EVEN 


             .SECTION 7,DATA
; SPELL CLASS SELECT WINDOW : 1st layer
SCSelW_L1:   
             .DC.w 0,127,0,48               ; Class area
             .DC.b 1
             .EVEN 
             .DC.l 0,SCSelW_L2

; SPELL CLASS SELECT WINDOW : 2nd layer
SCSelW_L2:   
             .DC.w 0,127,0,6                ; Classes
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 0,127,7,13
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 0,127,14,20
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 0,127,21,27
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 0,127,28,34
             .DC.b 5
             .EVEN 
             .DC.l .C6,0
.C6:         .DC.w 0,127,35,41
             .DC.b 6
             .EVEN 
             .DC.l .C7,0
.C7:         .DC.w 0,127,42,48
             .DC.b 7
             .EVEN 
             .DC.l 0,0

; SPELL SELECT WINDOW : 1st layer
SpSelW_L1:   .DC.w 0,127,0,111              ; Spell area
             .DC.b 1
             .EVEN 
             .DC.l .C2,SpSelW_L2
.C2:         .DC.w 0,31,112,127             ; Up icon
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 32,63,112,127            ; Down icon
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 128,159,112,127          ; Exit icon
             .DC.b 4
             .EVEN 
             .DC.l 0,0

; SPELL SELECT WINDOW : 2nd layer
SpSelW_L2:   .DC.w 0,127,0,6                ; Spells
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 0,127,7,13
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 0,127,14,20
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 0,127,21,27
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 0,127,28,34
             .DC.b 5
             .EVEN 
             .DC.l .C6,0
.C6:         .DC.w 0,127,35,41
             .DC.b 6
             .EVEN 
             .DC.l .C7,0
.C7:         .DC.w 0,127,42,48
             .DC.b 7
             .EVEN 
             .DC.l .C8,0
.C8:         .DC.w 0,127,49,55
             .DC.b 8
             .EVEN 
             .DC.l .C9,0
.C9:         .DC.w 0,127,56,62
             .DC.b 9
             .EVEN 
             .DC.l .C10,0
.C10:        .DC.w 0,127,63,69
             .DC.b 10
             .EVEN 
             .DC.l .C11,0
.C11:        .DC.w 0,127,70,76
             .DC.b 11
             .EVEN 
             .DC.l .C12,0
.C12:        .DC.w 0,127,77,83
             .DC.b 12
             .EVEN 
             .DC.l .C13,0
.C13:        .DC.w 0,127,84,90
             .DC.b 13
             .EVEN 
             .DC.l .C14,0
.C14:        .DC.w 0,127,91,97
             .DC.b 14
             .EVEN 
             .DC.l .C15,0
.C15:        .DC.w 0,127,98,104
             .DC.b 15
             .EVEN 
             .DC.l .C16,0
.C16:        .DC.w 0,127,105,111
             .DC.b 16
             .EVEN 
             .DC.l 0,0

             .END 













