
; Inventory
; Written by J.Horneman (In Tune With The Universe)
; Start : 5-7-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "Mr. Blue you did it right
;     But soon comes Mr. Night
;      Creepin' over, now his
;       Hand is on your shoulder
;        Never mind
;        I'll remember you this way"
;   Mr. Blue Sky, ELO, 1977

Gold_weight  = 10      ; Weight of 1 gold coin
Food_weight  = 250     ; Weight of 1 food unit
Gold_icon    = 96      ; Number of gold icon
Food_icon    = 109     ; Number of food icon

             .TEXT 
;*****************************************************************************
; [ Inventory I module ]
;*****************************************************************************
Inv1_DisUpd: 
             jsr       Update_status_block
             rts       

Inv1_Exit:   
             Pop       Module
             jmp       Init_display

Inv1_ModInit:          
             movea.l   Current_inventory_chardat_ptr,a0     ; Install object data
             lea.l     Neck_place_counter(a0),a1
             lea.l     Inv_data(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             Push      MA,Standard_MA
             jmp       Inv1_DisInit

Inv1_ModExit:          
             Pop       MA
             jmp       Inv1_DisExit

Inv1_DisInit:          
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #6,d0                ; New layout
             jsr       Show_layout
             moveq.l   #34,d7
             movea.l   Current_inventory_chardat_ptr,a1
             jsr       Display_character
; ------------- Print character skills -------------------------------
             move.w    #16+6,d0             ; Print "SKILLS"
             move.w    #50+65,d1
             move.w    #12*6,d2
             jsr       IG_Set_cursor
             lea.l     Skills_name,a0
             jsr       Print_centered_string
             move.w    #16+6,d2
             move.w    #50+72,d3
             moveq.l   #0,d6
             moveq.l   #2,d7
             lea.l     Class_dat+Class_names+22,a2          ; Get pointer to words
             lea.l     Skill_1(a1),a4
             lea.l     Skill_1_normal_magic(a1),a5
.Loop:       move.w    d2,d0                ; Set cursor
             move.w    d3,d1
             jsr       IG_Set_cursor
             move.w    d6,d0                ; Find skill word
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print skill name
             clr.b     3(a0)                ; First 3 characters
             jsr       IG_Print
             move.w    #6*5,d0              ; Set cursor
             add.w     d2,d0
             move.w    d3,d1
             jsr       IG_Set_cursor
             lea.l     Skill_txt,a3
             moveq.l   #"0",d1
             moveq.l   #0,d0                ; Convert normal skill
             move.b    (a4)+,d0
             add.w     (a5)+,d0
             jsr       RConvert_number
             addq.l    #2,a3
             moveq.l   #0,d0                ; Convert maximum skill
             move.b    10-1(a4),d0
             jsr       RConvert_number
             lea.l     Skill_txt,a0         ; Print skill levels
             jsr       IG_Print
             addi.w    #7,d3                ; Next skill
             addq.w    #1,d6
             cmpi.w    #10,d6
             bmi.s     .Loop
             .LOCAL 
; ------------- Print character attributes ---------------------------
             move.w    #16+6,d0             ; Print "ATTRIBUTES"
             move.w    #50,d1
             move.w    #12*6,d2
             lea.l     Attrs_name,a0
             jsr       Print_centered_string
             lea.l     Race_dat+Race_names+30,a2  ; Get pointer to words
             move.w    #16+6,d2
             move.w    #50+7,d3
             moveq.l   #0,d6
             moveq.l   #3,d7
             lea.l     Attr_1_normal(a1),a4
             lea.l     Attr_1_normal_magic(a1),a5
.Loop:       move.w    d2,d0                ; Set cursor
             move.w    d3,d1
             jsr       IG_Set_cursor
             move.w    d6,d0                ; Find attribute word
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print attribute name
             clr.b     3(a0)                ; First 3 characters
             jsr       IG_Print
             move.w    #6*5,d0              ; Set cursor
             add.w     d2,d0
             move.w    d3,d1
             jsr       IG_Set_cursor
             lea.l     Attr_txt,a3
             moveq.l   #"0",d1
             move.w    (a4)+,d0             ; Convert normal attribute
             add.w     (a5)+,d0
             jsr       RConvert_number
             addq.l    #1,a3
             move.w    20-2(a4),d0          ; Convert maximum attribute
             jsr       RConvert_number
             lea.l     Attr_txt,a0          ; Print attribute levels
             jsr       IG_Print
             addi.w    #7,d3                ; Next attribute
             addq.w    #1,d6
             cmpi.w    #8,d6                ; !!!
             bmi.s     .Loop
             .LOCAL 
; ------------- Print known languages --------------------------------
             move.w    #16+15*6,d0          ; Set cursor
             move.w    #50,d1
             jsr       IG_Set_cursor
             lea.l     Language_txt,a0      ; Print "LANGUAGES"
             jsr       IG_Print
             lea.l     Misc_dat,a2          ; Get pointer to words
             move.w    #50+7,d1
             move.w    #16+15*6,d2
             move.b    Learned_languages(a1),d6
             moveq.l   #0,d7
.Loop:       move.w    d2,d0                ; Set cursor
             jsr       IG_Set_cursor
             btst      d7,d6                ; Language known ?
             beq.s     .Next
             move.w    (a2),d0              ; Find language word
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print language
             jsr       IG_Print
             addq.w    #7,d1
.Next:       addq.l    #2,a2                ; Next language
             addq.w    #1,d7
             cmpi.b    #8,d7
             bmi.s     .Loop
             .LOCAL 
; ------------- Display body conditions ------------------------------
             move.w    #16+15*6,d0          ; Set cursor
             move.w    #50+65,d1
             jsr       IG_Set_cursor
             lea.l     Body_txt,a0          ; Print "BODY"
             jsr       IG_Print
             move.w    #16+15*6,d2          ; Initialize registers
             move.w    #52+72,d3
             lea.l     Status_icn,a0
             lea.l     Bodymind_relpos_list,a2
             move.b    Body_conditions(a1),d6     ; Member dead ?
             move.b    #$e0,d7
             and.b     d6,d7
             beq.s     .Not_dead
             move.w    d2,d0                ; Display cross
             move.w    d3,d1
             jsr       Blit_masked_block
             bra.s     .Dead
.Not_dead:   lea.l     9*128(a0),a0
             moveq.l   #0,d7
.Loop:       btst      d7,d6                ; Body condition ?
             beq.s     .Next
             move.w    d2,d0                ; Get coordinates
             move.w    d3,d1
             add.w     (a2)+,d0
             add.w     (a2)+,d1
             jsr       Blit_masked_block    ; Display icon
.Next:       lea.l     128(a0),a0           ; Next body condition
             addq.w    #1,d7
             cmpi.w    #6,d7                ; !!!
             bmi.s     .Loop
.Dead:       .LOCAL 
; ------------- Display mind conditions ------------------------------
             move.w    #16+23*6,d0          ; Set cursor
             move.w    #50+65,d1
             jsr       IG_Set_cursor
             lea.l     Mind_txt,a0          ; Print "MIND"
             jsr       IG_Print
             move.w    #16+23*6,d2          ; Initialize registers
             move.w    #52+72,d3
             lea.l     Status_icn,a0
             lea.l     Bodymind_relpos_list,a2
             move.b    Mind_conditions(a1),d6     ; Member dead ?
             move.b    #$e0,d7
             and.b     d6,d7
             bne.s     .Dead
             lea.l     14*128(a0),a0
             moveq.l   #0,d7
.Loop:       btst      d7,d6                ; Mind condition ?
             beq.s     .Next
             move.w    d2,d0                ; Get coordinates
             move.w    d3,d1
             add.w     (a2)+,d0
             add.w     (a2)+,d1
             jsr       Blit_masked_block    ; Display icon
.Next:       lea.l     128(a0),a0           ; Next mind condition
             addq.w    #1,d7
             cmpi.w    #6,d7                ; !!!
             bmi.s     .Loop
.Dead:       .LOCAL 
; ------------- Rest of display --------------------------------------
             move.l    #Inv1_CIL,Control_list_ptr ; Display control icons
             jsr       Show_control_icons
             Update_screen 
             lea.l     Control_area,a0      ; Object branch
             jsr       Set_layout_data
; ------------- Fade in ----------------------------------------------
             tst.b     Fade_block           ; Fade ?
             beq.s     .Skip
             sf        Fade_block
             bra.s     .Continue
.Skip:       lea.l     Inv1_pal,a1          ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Inv1_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Inv1_below,a0        ; Fade
             jsr       Fade_pal
             bne.s     .Again
.Continue:   lea.l     Hbl_Inv1_list,a0     ; Update palettes
             jsr       Update_HBL
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

Inv1_DisExit:          
             movem.l   a0-a2,-(sp)
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Inv1_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Inv1_below,a0        ; Fade palette
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_Inv1_list,a0     ; Update palettes
             jsr       Update_HBL
             movem.l   (sp)+,a0-a2
.Exit:       rts       

; [ Get word & copy to line buffer ]
;   IN : d0 - Word number (.w)
; Changed registers : a0,a3
Get_word:    
             move.l    d0,-(sp)
             jsr       Find_word
             lea.l     Line_buffer,a3
             moveq.l   #0,d0                ; Get length of word
             move.b    (a0)+,d0
             subq.w    #1,d0                ; !!! REMOVE LATER !!!
             bra.s     .Entry
.Loop:       move.b    (a0)+,(a3)+          ; Copy character
.Entry:      dbra      d0,.Loop
             clr.b     (a3)                 ; Insert EOL
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Inventory II module ]
;*****************************************************************************
Go_Inv2:     
             movea.l   Current_inventory_chardat_ptr,a0     ; Possible ?
             move.w    #$0402,d0
             and.w     Body_conditions(a0),d0
             bne.s     .Exit
             jsr       Exit_display
             Push      Module,Inv2_Mod
.Exit:       rts       

Inv21_Exit:  
             Pop       Module
             jmp       Inv1_Exit

Inv2_DisUpd: 
             jsr       Update_status_block
             lea.l     Inv2_CIL,a0          ; Update control icons
             lea.l     Inv2CIL_evaluate,a1
             jsr       Update_control_icons
             movea.l   Current_inventory_chardat_ptr,a1     ; Update weight
             move.l    Weight_normal(a1),d0
             moveq.l   #0,d1
             move.w    Attr_1_normal(a1),d1
             add.w     Attr_1_normal_magic(a1),d1
             cmp.l     XWeight,d0           ; Change ?
             bne.s     .Update
             cmp.l     XStrength,d1         ; Change ?
             beq.s     .No_change
.Update:     move.l    d0,XWeight           ; Update
             move.l    d1,XStrength
             move.b    #2,Weight_update
.No_change:  .LOCAL 
             jsr       Update_quantity_colours
             rts       

Inv2_Exit:   
             Pop       Module
             jmp       Init_display

Inv2_DisInit:          
             SetMesMin                      16,49+1,176,Code0001Sys
             move.l    #Inv2_PlusMes,PlusMes_info
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #2,d0                ; New layout
             jsr       Show_layout
             moveq.l   #33,d7
             movea.l   Current_inventory_chardat_ptr,a1
             jsr       Display_character
; ------------- Display objects --------------------------------------
             lea.l     Neck_place_counter(a1),a2
             lea.l     Inv_data(a1),a4
             moveq.l   #1,d1
             moveq.l   #21-1,d7
             cmpi.b    #14,Character_race(a1)     ; Special or monster ?
             bmi.s     .Loop
             lea.l     9(a2),a2             ; Skip body items
             lea.l     9*40(a4),a4
             addi.w    #9,d1
             subi.w    #9,d7
.Loop:       tst.b     (a2)+                ; Any object there ?
             beq.s     .Next
             cmpi.b    #17,Item_type(a4)    ; Is it a monster item ?
             beq.s     .Next
             move.b    (a4),d0              ; Display object
             jsr       INV2_Show_object
.Next:       addq.l    #1,d1                ; Next object
             lea.l     40(a4),a4
             dbra      d7,.Loop
; ------------- FUCKING EXCEPTION ------------------------------------
             lea.l     Right_hand_place_counter(a1),a2
             tst.b     (a2)                 ; Double-handed
             beq.s     .Skip                ; object in right hand ?
             lea.l     Inv_data+3*40(a1),a3
             cmpi.b    #2,Hand_use(a3)
             bne.s     .Skip
             moveq.l   #0,d0                ; Display cross over left hand
             moveq.l   #6,d1
             jsr       INV2_Show_object
.Skip:       .LOCAL 
; ------------- Print weight -----------------------------------------
             move.w    #16,d0               ; Print "WEIGHT"
             move.w    #178,d1
             move.w    #80,d2
             lea.l     Weight_name,a0
             jsr       Print_centered_string
             clr.l     XWeight              ; Force a update
             clr.l     XStrength
; ------------- Rest of display --------------------------------------
             lea.l     Inv2_CIL,a0          ; Display control icons
             jsr       Inv2CIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Inv2_L2,a0           ; Object branch
             jsr       Set_layout_data
; ------------- Fade in ----------------------------------------------
             tst.b     Fade_block           ; Fade ?
             beq.s     .Skip
             sf        Fade_block
             bra.s     .Continue
.Skip:       lea.l     Inv2_target_hbl,a1   ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Inv2_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Inv2_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
.Continue:   lea.l     Hbl_Inv2_list,a0     ; Update palettes
             jsr       Update_HBL
.Exit:       rts       

Inv2_DisExit:          
             lea.l     Void,a1              ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_Inv2_list,a0     ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Inv2_below,a0        ; Fade
             jsr       Hbl_fade
             bne.s     .Again
             lea.l     Hbl_Inv2_list,a0     ; Update palettes
             jsr       Update_HBL
             rts       

; [ Display an object (Inventory II) ]
;   IN : d0 - Object graphic number (.b)
;        d1 - Position index (.w)
;        a6 - Screen base (.l)
; All registers are restored
INV2_Show_object:      
             movem.l   d0-d2/a0,-(sp)
             move.b    d0,d2
             lea.l     Object_pos_list-4,a0 ; Get coordinates
             add.w     d1,d1
             add.w     d1,d1
             move.w    0(a0,d1.w),d0
             move.w    2(a0,d1.w),d1
             lea.l     Layout_icn+9856,a0   ; Display empty block
             jsr       Put_unmasked_block
             lea.l     Objects_icn,a0       ; Calculate graphics address
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block     ; Display object
             movem.l   (sp)+,d0-d2/a0
             rts       

; [ Erase an object (Inventory II) ]
;   IN : d0 - Position index (.b)
;        a6 - Screen base (.l)
; All registers are restored
INV2_Erase_object:     
             movem.l   d0-d2/a0,-(sp)
             ext.w     d0
             move.w    d0,d2
             lea.l     Object_pos_list-4,a0 ; Get coordinates
             add.w     d0,d0
             add.w     d0,d0
             move.w    2(a0,d0.w),d1
             move.w    0(a0,d0.w),d0
             lea.l     Erase_icon,a0        ; Get icon number
             move.b    -1(a0,d2.w),d2
             lea.l     Layout_icn-128,a0    ; Calculate graphics address
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_unmasked_block   ; Erase object
             movem.l   (sp)+,d0-d2/a0
             rts       

; [ Display quantities of backpack objects ]
; Changed registers : d0,d1,d2,d6,d7,a0,a1,a2,a3,a4,a5,a6
Display_quantities:    
             lea.l     Quant_init_string,a0 ; Set colours
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Initialize registers
             movea.l   Current_inventory_chardat_ptr,a1
             lea.l     Inventory_1_place_counter(a1),a2
             movea.l   Off_screen,a6
             tst.b     Quant_block          ; Display quantities ?
             bne.s     .No_quant
             lea.l     Object_pos_list+36,a4
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
.Finite:     lea.l     (a0),a3              ; Convert number
             moveq.l   #" ",d1
             jsr       RConvert_number
             clr.b     (a3)                 ; Insert EOL
             moveq.l   #10,d1               ; Get coordinates
             move.w    (a4),d0
             add.w     2(a4),d1
             addq.w    #2,d0
             jsr       IG_Set_cursor
             jsr       IG_Print
.Next1:      addq.l    #4,a4                ; Next object
             dbra      d6,.Loop1
             rts       
; ------------- Restore object graphics ------------------------------
.No_quant:   lea.l     Inventory_1_place_counter(a1),a2
             lea.l     Inv_data+9*40(a1),a3
             moveq.l   #10,d1
             moveq.l   #12-1,d6
.Loop2:      cmpi.b    #1,(a2)+             ; More as one object ?
             bls.s     .Next2
             move.b    (a3),d0              ; Display object
             jsr       INV2_Show_object
.Next2:      addq.w    #1,d1                ; Next backpack object
             lea.l     40(a3),a3
             dbra      d6,.Loop2
             rts       

Update_weight:         
             tst.b     Weight_update        ; Update ?
             beq       .Exit
             moveq.l   #15,d0               ; Set print colours
             tst.b     Overweight
             beq.s     .Skip
             moveq.l   #1,d0
.Skip::      jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             moveq.l   #"0",d1              ; Initialize registers
             moveq.l   #3,d7
             lea.l     Weight_txt,a0
             movea.l   Off_screen,a6
             move.l    XWeight,d0           ; Convert weight
             divu.w    #1000,d0
             ext.l     d0
             lea.l     (a0),a3
             jsr       RConvert_number
             lea.l     7(a0),a3             ; Convert maximum weight
             move.l    XStrength,d0
             jsr       RConvert_number
             move.w    #16,d0               ; Print weight
             move.w    #178+8,d1
             move.w    #80,d2
             jsr       Print_centered_string
             subq.b    #1,Weight_update
.Exit:       rts       

;*****************************************************************************
; [ Re-evaluate control icons for inventory II ]
;   IN : a0 - Pointer to control icon list (.l)
; All registers are restored
;*****************************************************************************
Inv2CIL_evaluate:      
             movem.l   d0/d7/a1/a2,-(sp)
; ------------- Enable all icons -------------------------------------
             lea.l     (a0),a2              ; Enable all icons
             moveq.l   #9-1,d7
.Loop0:      bclr      #7,(a2)+
             dbra      d7,.Loop0
; ------------- Check if character is special or monster -------------
             movea.l   Current_inventory_chardat_ptr,a1
             cmpi.b    #9,Character_class(a1)     ; Special or monster ?
             bmi.s     .No_special
             bset      #7,3(a0)             ; Disable {Use item}
             bset      #7,4(a0)             ; Disable {Pool gold}
             bset      #7,5(a0)             ; Disable {View item}
             bset      #7,7(a0)             ; Disable {Transfer gold}
; ------------- Check if character CARRIES any objects ---------------
.No_special: lea.l     Inventory_1_place_counter(a1),a2     ; Check backpack
             move.b    (a2)+,d0
             moveq.l   #11-1,d7
.Loop1:      or.b      (a2)+,d0
             dbra      d7,.Loop1
             tst.b     d0                   ; Any objects ?
             bne.s     .Check_gold
             bset      #7,1(a0)             ; Disable
             bset      #7,6(a0)
; ------------- Check if character WEARS any objects -----------------
             lea.l     Neck_place_counter(a1),a2  ; Check body
             move.b    (a2)+,d0
             moveq.l   #8-1,d7
.Loop2:      or.b      (a2)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Any objects ?
             bne.s     .Check_gold
             bset      #7,3(a0)             ; Disable
             bset      #7,5(a0)
; ------------- Check if character has any gold ----------------------
.Check_gold: tst.w     Gold_coins(a1)       ; Any gold ?
             bne.s     .Check_weight
             bset      #7,7(a0)             ; Disable {Transfer gold}
; ------------- Check if character can carry anything more -----------
.Check_weight:         
             move.w    Attr_1_normal(a1),d0 ; Get maximum weight
             add.w     Attr_1_normal_magic(a1),d0
             mulu.w    #1000,d0
             cmp.l     Weight_normal(a1),d0
             bls.s     .No_way
; ------------- Check if character is alive --------------------------
             move.w    #$e000,d0            ; Not dead ?
             and.w     Body_conditions(a1),d0
             beq.s     .Check_food
.No_way:     bset      #7,4(a0)             ; Disable {Pool gold}
; ------------- Check if character has any food ----------------------
.Check_food: tst.w     Food_rations(a1)     ; Any food ?
             bne.s     .Exit
             bset      #7,8(a0)             ; Disable {Transfer food}
.Exit:       movem.l   (sp)+,d0/d7/a1/a2
             rts       

;*****************************************************************************
; [ Update control icon list ]
; Changed registers : d0,a0,a6
;*****************************************************************************
Update_CIL:  
             tst.b     CIL_update           ; Update control icons ?
             beq.s     .Exit
             movea.l   Off_screen,a6        ; Update control icons
             jsr       Show_control_icons
             subq.b    #1,CIL_update        ; Count down
.Exit:       rts       

;*****************************************************************************
; [ Display character info ]
;   IN : d7 - Height of portrait (.w)
;        a1 - Pointer to character data (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_character:     
             movem.l   d0/d1/d6/d7/a0/a2/a3,-(sp)
             moveq.l   #2,d0                ; Set paper
             jsr       IG_Set_paper
             moveq.l   #0,d0                ; To clear top word
; ------------- Display portrait -------------------------------------
             lea.l     Portrait+6(a1),a0    ; Display portrait
             move.w    #208,d0
             move.w    #49,d1
             moveq.l   #2,d6
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
             add.w     Attr_9_normal_magic(a1),d0
             moveq.l   #3,d7
             lea.l     (a0),a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print age
; ------------- Print character's experience points ------------------
             move.w    #208+34,d0           ; Set cursor
             move.w    #49+28,d1
             jsr       IG_Set_cursor
             lea.l     XP_txt,a0
             move.l    Experience_points(a1),d0   ; Convert XP
             moveq.l   #6,d7
             lea.l     3(a0),a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print XP
; ------------- Display sword & shield icons -------------------------
             move.w    #208+6,d0            ; Display sword icon
             move.w    #85+35,d1
             moveq.l   #1,d6
             moveq.l   #10,d7
             lea.l     Swordshield,a0
             jsr       Blot_unmasked_block
             addi.w    #48,d0               ; Display shield icon
             lea.l     80(a0),a0
             jsr       Blot_unmasked_block
             jsr       Update_character_info
             movem.l   (sp)+,d0/d1/d6/d7/a0/a2/a3
             rts       

;*****************************************************************************
; [ Update character info ]
; All registers are restored
;*****************************************************************************
Update_character_info: 
             movem.l   d0/d1/d7/a0/a1/a3/a6,-(sp)
             movea.l   Current_inventory_chardat_ptr,a1
             movea.l   Off_screen,a6
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
; ------------- Print character's life points ------------------------
             move.w    #208+12,d0           ; Set cursor
             move.w    #85+7,d1
             jsr       IG_Set_cursor
             moveq.l   #"0",d1
             moveq.l   #3,d7
             move.w    Life_points_normal(a1),d0  ; Convert normal LP
             lea.l     LP_txt+5,a3
             jsr       RConvert_number
             move.w    Life_points_max(a1),d0     ; Convert maximum LP
             add.w     Life_points_max_magic(a1),d0
             lea.l     LP_txt+9,a3
             jsr       RConvert_number
             lea.l     LP_txt,a0            ; Print LP
             jsr       IG_Print
; ------------- Print character's power points -----------------------
             move.w    #208+12,d0           ; Set cursor
             move.w    #85+14,d1
             jsr       IG_Set_cursor
             move.w    Power_points_max(a1),d0    ; Convert maximum PP
             add.w     Power_points_max_magic(a1),d0
             beq       .No_magic
             moveq.l   #"0",d1
             lea.l     PP_txt+9,a3
             jsr       RConvert_number
             move.w    Power_points_normal(a1),d0 ; Convert normal PP
             lea.l     PP_txt+5,a3
             jsr       RConvert_number
             lea.l     PP_txt,a0            ; Print PP
             jsr       IG_Print
; ------------- Print character's spell learn points -----------------
             move.w    #208+12,d0           ; Set cursor
             move.w    #85+21,d1
             jsr       IG_Set_cursor
             move.w    Nr_spell_learn_points(a1),d0         ; Convert SLP
             moveq.l   #"0",d1
             lea.l     SLP_txt+5,a3
             jsr       RConvert_number
             lea.l     SLP_txt,a0           ; Print SLP
             jsr       IG_Print
; ------------- Display gold & food ----------------------------------
.No_magic:   move.w    #208+6,d0            ; Set cursor
             move.w    #85+28,d1
             jsr       IG_Set_cursor
             moveq.l   #"0",d1
             lea.l     Goldfood_txt,a0
             move.w    Gold_coins(a1),d0    ; Convert protection
             moveq.l   #5,d7
             lea.l     2(a0),a3
             jsr       RConvert_number
             move.w    Food_rations(a1),d0  ; Convert protection
             moveq.l   #4,d7
             lea.l     10(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
; ------------- Display protection & damage --------------------------
             move.w    #208+18,d0           ; Set cursor
             move.w    #85+35+2,d1
             jsr       IG_Set_cursor
             moveq.l   #3,d7
             lea.l     ProtDam_txt,a0
             moveq.l   #0,d0                ; Convert damage
             move.b    Damage(a1),d0
             add.w     Damage_magic(a1),d0
             moveq.l   #"0",d1
             lea.l     1(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
             move.w    #208+18+48,d0        ; Set cursor
             move.w    #85+35+2,d1
             jsr       IG_Set_cursor
             moveq.l   #0,d0                ; Convert protection
             move.b    Protection(a1),d0
             add.w     Protection_magic(a1),d0
             moveq.l   #"0",d1
             lea.l     1(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
             movem.l   (sp)+,d0/d1/d7/a0/a1/a3/a6
             rts       

;*****************************************************************************
; [ Convert number & copy to text buffer RIGHT JUSTIFIED ]
;   IN : d0 - Number (.w)
;        d1 - Fill character (.b)
;        d7 - Number of digits (.w)
;        a3 - Pointer to text buffer (.l)
;  OUT : a3 - Pointer to first character after number (.l)
; Changed registers : a3
;*****************************************************************************
RConvert_number:       
             movem.l   d0/d7/a0,-(sp)
             ext.l     d0
             jsr       Dec_convert
             addq.l    #1,a0                ; Skip sign
             bra.s     .Entry
.Loop:       move.b    (a0)+,d0             ; Copy to output string
             cmpi.b    #" ",d0
             bne.s     .Skip
             move.b    d1,d0
.Skip:       move.b    d0,(a3)+
.Entry:      dbra      d7,.Loop
             movem.l   (sp)+,d0/d7/a0
             rts       

;*****************************************************************************
; [ Convert number & copy to text buffer LEFT JUSTIFIED ]
;   IN : d0 - Number (.w)
;        d7 - Number of digits (.w)
;        a3 - Pointer to text buffer (.l)
;  OUT : a3 - Pointer to first character after number (.l)
; Changed registers : d0,a3
;*****************************************************************************
LConvert_number:       
             movem.l   d7/a0,-(sp)
             ext.l     d0
             jsr       Dec_convert
             cmpi.b    #"-",(a0)+           ; Negative ?
             bne.s     .Seek
             move.b    #"-",(a3)+           ; Insert sign
.Seek:       subq.w    #1,d7                ; Find first non-space
             cmpi.b    #" ",(a0)+
             beq.s     .Seek
             subq.l    #1,a0
.Loop:       move.b    (a0)+,(a3)+          ; Copy to output string
             dbra      d7,.Loop
             clr.b     (a3)                 ; Insert EOL
             movem.l   (sp)+,d7/a0
             rts       

;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT / INVENTORY I
; All registers are restored
;*****************************************************************************
Inv1_Mright: 
             movem.l   d0/a0,-(sp)
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #6,d0
             lea.l     Chard_ptrs-4,a0      ; Any character there ?
             adda.w    d0,a0
             tst.l     (a0)
             beq       .Exit
             movea.l   (a0),a0
             cmpa.l    Current_inventory_chardat_ptr,a0
             beq.s     .Exit
             move.l    a0,Current_inventory_chardat_ptr
             lea.l     Neck_place_counter(a0),a1  ; Install object data
             lea.l     Inv_data(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             st        Fade_block
             jsr       Init_display
.Exit:       movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Right mouse-button clicked on party member ] MOUSE EVENT / INVENTORY II
; All registers are restored
;*****************************************************************************
Inv2_Mright: 
             movem.l   d0/a0,-(sp)
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #6,d0
             lea.l     Chard_ptrs-4,a0      ; Any character there ?
             adda.w    d0,a0
             tst.l     (a0)
             beq       .Exit
             movea.l   (a0),a0
             cmpa.l    Current_inventory_chardat_ptr,a0
             beq.s     .Exit
             move.w    #$0402,d0            ; Possible ?
             and.w     Body_conditions(a0),d0
             bne.s     .Exit
             move.l    a0,Current_inventory_chardat_ptr
             lea.l     Neck_place_counter(a0),a1  ; Install object data
             lea.l     Inv_data(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             st        Fade_block
             jsr       Init_display
.Exit:       movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Display name of object ]
; Changed registers : d0,d1,d2,a0,a3,a6
;*****************************************************************************
Show_object_name:      
             tst.b     d0                   ; Any object selected ?
             beq.s     .Exit
             move.w    #$ff00,d1            ; Body or backpack area ?
             and.w     d0,d1
             cmpi.w    #$0300,d1
             bmi.s     .Body
             addi.b    #9,d0
.Body:       movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a3          ; Any object there ?
             ext.w     d0
             tst.b     0(a3,d0.w)
             beq.s     .Exit
             lea.l     Inv_data-40(a0),a0   ; Get number of word
             mulu.w    #40,d0
             adda.w    d0,a0
             cmpi.b    #17,Item_type(a0)    ; Is it a monster item ?
             beq.s     .Exit
             move.w    Name_word_nr(a0),d0
             cmp.w     Object_name_nr,d0    ; Already printed ?
             beq       .Exit
             move.w    d0,Object_name_nr
             move.b    #2,Print_objname_flag
.Exit:       rts       

Erase_object_name:     
             tst.b     d0                   ; On an object ?
             beq.s     .Skip
             move.l    #$00ffff00,d1        ; In object area ?
             and.l     d0,d1
             cmpi.l    #$00020200,d1
             beq.s     .Exit
             cmpi.l    #$00020300,d1
             beq.s     .Exit
.Skip:       move.b    #2,Erase_objname_flag
.Exit:       rts       

Upd_objname_print:     
             tst.b     Print_objname_flag   ; Print anything ?
             beq       .Exit
             lea.l     .Init_string(pc),a0  ; Set colours
             jsr       IG_Print
             move.w    Object_name_nr,d0    ; Get word
             beq       .Exit
             jsr       Get_word
             move.w    #16,d0               ; Erase previous text
             move.w    #58,d1
             move.w    #16+176-1,d2
             move.w    #58+7-1,d3
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

Upd_objname_erase:     
             tst.b     Erase_objname_flag   ; Erase anything ?
             beq       .Exit
             move.w    #16,d0               ; Erase text
             move.w    #58,d1
             move.w    #16+176-1,d2
             move.w    #58+7-1,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             subq.b    #1,Erase_objname_flag      ; Count down
             clr.w     Object_name_nr
.Exit:       rts       

;*****************************************************************************
; [ Drop item module ]
;*****************************************************************************
Drop_item:   
             Push      Module,DropItem_Mod
             rts       

DropItem_DisInit:      
             Push      MA,Backpack_area     ; Mouse in backpack area
             movea.l   Off_screen,a6        ; Print message {0,-}
             MesMin    0
             Update_screen 
             Wait_4_unclick 
             rts       

Transparent_DisExit:   
             movea.l   Off_screen,a6        ; Erase text
             jsr       Erase_message_minus
             Update_screen 
             Pop       MA
             Wait_4_unclick 
             rts       

Exit_DropItem:         
             Pop       Module
             rts       
Do_DropItem: 
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq.s     Exit_DropItem
             ext.w     d0
             addi.w    #9,d0
             move.b    d0,Object_slot_number
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       Exit_DropItem
             lea.l     Inv_data-40(a0),a2
             mulu.w    #40,d0
             adda.w    d0,a2

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object data (.l)

             btst      #1,Item_stat_bits(a2)      ; Can it be dropped ?
             bne.s     .Droppable
             PlusMes   1                    ; Print message {1,+}
             Pop       Module
             bra       .Exit
.Droppable:  btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .Single
             cmpi.b    #1,(a1)              ; More as one ?
             bhi.s     .Multiple
.Single:     move.l    #Code0001Sys,Textfile_ptr  ; Are U sure ?
             move.w    #22,ReqText_nr
             move.l    #Do_Drop1Item,ReqDo_ptr
             Push      Module,Req_Mod
             bra       .Exit
.Multiple:   moveq.l   #0,d0                ; Set parameters
             move.b    (a1),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,DropMItem_Mod ; Requester
.Exit:       rts       

Do_Drop1Item:          
             Wait_4_unclick 
             movea.l   Current_inventory_chardat_ptr,a0     ; Calculate pointers
             lea.l     Neck_place_counter-1(a0),a1
             lea.l     Inv_data-40(a0),a2
             move.b    Object_slot_number,d0
             ext.w     d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             clr.b     (a1)                 ; Remove item
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             movea.l   Off_screen,a6
             move.b    Object_slot_number,d0      ; Remove graphic
             jsr       INV2_Erase_object
             move.w    #16,d0               ; Erase object name
             move.w    #58,d1
             move.w    #16+176-1,d2
             move.w    #58+7-1,d3
             move.w    #2,d6
             jsr       Draw_box
             Update_screen 
             jmp       Pop_Module

;*****************************************************************************
; [ Drop Multiple Item window module ]
;*****************************************************************************
DropMItem_DisInit:     
             movem.l   d0-d7/a0-a6,-(sp)
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit
; ------------- Initialize pointers ----------------------------------
             move.b    Object_slot_number,d0
             ext.w     d0
             movea.l   Current_inventory_chardat_ptr,a1
             lea.l     Neck_place_counter-1(a1),a2
             lea.l     Inv_data-40(a1),a3
             adda.w    d0,a2
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a3
             movea.l   Off_screen,a6

; ------------- REGISTER CONTENTS ------------------------------------
;  a1 - Pointer to character data (.l)
;  a2 - Pointer to object slot (.l)
;  a3 - Pointer to object data (.l)
;  a6 - Screen base (.l)

; ------------- Fill window ------------------------------------------
             move.b    (a3),d0              ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             move.w    Name_word_nr(a3),d0  ; Get number of word
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print word
             jsr       IG_Print
             move.w    #32+17,d0            ; Set cursor
             move.w    #80+38+32,d1
             jsr       IG_Set_cursor
             moveq.l   #15,d0               ; Convert text
             lea.l     Code0001Sys,a1
             jsr       Convert_text_line
             lea.l     Line_buffer,a0       ; Print line
             jsr       IG_Print
             Update_screen 
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

DropMItem_Return:      
             Wait_4_unclick 
             move.l    #Code0001Sys,Textfile_ptr  ; Are U sure ?
             move.w    #22,ReqText_nr
             move.l    #Do_DropMItem,ReqDo_ptr
             lea.l     Req_Mod,a0
             jmp       Push_Module

Do_DropMItem:          
             Wait_4_unclick 
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1          ; Calculate pointers
             lea.l     Inv_data-40(a0),a2
             move.b    Object_slot_number,d0
             ext.w     d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             movea.l   Off_screen,a6

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object data (.l)
;  a6 - Pointer to screen base (.l)

             moveq.l   #0,d1                ; Get number
             move.b    (a1),d1
             move.l    ItemW_nr,d2
             sub.w     d2,d1                ; Subtract
             move.b    d1,(a1)
             bne.s     .Some_left           ; None left ?
             move.b    Object_slot_number,d0      ; Remove graphic
             jsr       INV2_Erase_object
             move.w    #16,d0               ; Erase object name
             move.w    #58,d1
             move.w    #16+176-1,d2
             move.w    #58+7-1,d3
             move.w    #2,d6
             jsr       Draw_box
             Update_screen 
             bra.s     .Exit
.Some_left:  cmpi.b    #1,(a1)              ; Remove quantity ?
             bne.s     .Exit
             move.b    (a2),d0              ; Redraw object
             move.b    Object_slot_number,d1
             jsr       INV2_Show_object
             move.w    #16,d0               ; Erase object name
             move.w    #58,d1
             move.w    #16+176-1,d2
             move.w    #58+7-1,d3
             move.w    #2,d6
             jsr       Draw_box
             Update_screen 
.Exit:       move.l    ItemW_nr,d0          ; Remove weight
             mulu.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             jmp       Pop_Module

;*****************************************************************************

First_add    = 256-8*20                     ; Delay for repeat

ItemW_DisUpd:          
             movem.l   d0-d7/a0-a6,-(sp)
             movea.l   Off_screen,a6
             move.w    #89,d0               ; Erase previous number
             move.w    #141,d1
             move.w    #89+30,d2
             move.w    #141+7,d3
             moveq.l   #2,d6
             jsr       Draw_box
             jsr       IG_Set_cursor        ; Set cursor
             move.l    ItemW_nr,d0          ; Convert number of objects
             moveq.l   #" ",d1
             moveq.l   #5,d7
             lea.l     Line_buffer,a0
             lea.l     (a0),a3
             jsr       RConvert_number
             clr.b     (a3)                 ; Insert EOL
             jsr       IG_Print             ; Print number
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

ItemW_DisInit:         
             movem.l   d0-d3/d6/d7/a0/a6,-(sp)
; ------------- Open a window ----------------------------------------
             moveq.l   #32,d0
             moveq.l   #80+32,d1
             moveq.l   #10,d2
             moveq.l   #6,d3
             moveq.l   #1,d6
             lea.l     ItemW_L1,a0
             jsr       Open_window
             move.w    d0,Window_handle
; ------------- Fill window ------------------------------------------
             movea.l   Off_screen,a6
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #48,d0               ; Arrow up
             move.w    #128+32,d1
             lea.l     Control_icn+256,a0
             jsr       Blot_unmasked_block
             move.w    #48,d0               ; Arrow down
             move.w    #96+48+32,d1
             lea.l     Control_icn+512,a0
             jsr       Blot_unmasked_block
             move.w    #128,d0              ; Exit icon
             move.w    #144+32,d1
             lea.l     Control_icn+7680,a0
             jsr       Blot_unmasked_block
             jsr       ItemW_DisUpd         ; Print figure
             movem.l   (sp)+,d0-d3/d6/d7/a0/a6
             rts       

ItemW_DisExit:         
             move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             jsr       Copy_screen
             movea.l   Off_screen,a6        ; Erase message
             jsr       Erase_message_minus
             Update_screen 
             Wait_4_unclick 
             rts       

Clear_adding:          
             move.w    #First_add,Adding    ; Reset
             rts       

Inc_adding:  
             move.w    Adding,d1            ; Increase adding factor
             addq.w    #8,d1
             bmi       .Exit                ; Overflow ?
             move.w    d1,Adding
.Exit:       rts       

ItemW_1Up:   
             move.l    ItemW_nr,d0          ; Get number
             cmp.l     Original_number,d0   ; Maximum value ?
             bpl.s     .Exit
             addq.l    #1,d0                ; Increase
             move.l    d0,ItemW_nr
.Exit:       rts       

ItemW_1Down: 
             move.l    ItemW_nr,d0          ; Get number
             tst.l     d0                   ; Minimum value ?
             beq.s     .Exit
             subq.l    #1,d0                ; Decrease
             move.l    d0,ItemW_nr
.Exit:       rts       

ItemW_Up:    
             move.l    ItemW_nr,d0          ; Get number
             cmp.l     Original_number,d0   ; Maximum value ?
             bpl.s     .Exit
             moveq.l   #0,d1                ; Increase
             move.b    Adding,d1
             add.l     d1,d0
             cmp.l     Original_number,d0   ; Maximum value ?
             bmi.s     .Skip
             move.w    #First_add,Adding    ; Reset
             move.l    Original_number,d0
.Skip:       jsr       Inc_adding
             move.l    d0,ItemW_nr
.Exit:       rts       

ItemW_Down:  
             move.l    ItemW_nr,d0          ; Get number
             tst.l     d0                   ; Minimum value ?
             beq.s     .Exit
             moveq.l   #0,d1                ; Decrease
             move.b    Adding,d1
             sub.l     d1,d0
             bpl.s     .Skip                ; Minimum value ?
             move.w    #First_add,Adding    ; Reset
             moveq.l   #0,d0
.Skip:       jsr       Inc_adding
             move.l    d0,ItemW_nr
.Exit:       rts       

;*****************************************************************************
; [ Use item module ]
;*****************************************************************************
Use_item:    
             Push      Module,UseItem_Mod
             rts       

UseItem_DisInit:       
             Push      MA,UseItem_area      ; Backpack & body area
             moveq.l   #2,d0
             movea.l   Off_screen,a6        ; Print message {2,-}
             MesMin    2
             Update_screen 
             Wait_4_unclick 
             rts       

Use_backpack_item:     
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             ext.w     d0                   ; Backpack slot
             addi.w    #9,d0
             bra.s     UseItem_entry
.Exit:       jmp       Pop_Module

Use_body_item:         
             tst.b     d0                   ; Any slot selected ?
             beq.s     .Exit
             ext.w     d0                   ; Body slot
             bra.s     UseItem_entry
.Exit:       jmp       Pop_Module

UseItem_entry:         
             Wait_4_unclick 
             move.b    d0,Object_slot_number      ; Store
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq       .Exit
             lea.l     Inv_data-40(a0),a2
             mulu.w    #40,d0
             adda.w    d0,a2

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object data (.l)

; ------------- Check for a Use Item event ---------------------------
             move.w    Map_Xcoord,d0        ; Find event
             move.w    Map_Ycoord,d1
             jsr       Find_event
             beq       .No_event            ; Any event ?
             cmpi.b    #19,(a5)             ; Use Item event ?
             bne       .No_event
             move.w    6(a5),d0             ; Correct ID ?
             cmp.w     Item_ID(a2),d0
             bne       .No_event
             jsr       Do_event_item        ; Do it !
             btst      #3,Item_stat_bits(a2)      ; Use once ?
             beq.s     .Use_more
             subq.b    #1,(a1)              ; Remove object
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             move.b    Object_slot_number,d0      ; Body or backpack ?
             cmpi.b    #10,d0
             bpl.s     .Destroy
             jsr       Remove_boni          ; Remove boni if body item
.Destroy:    jsr       Destroy_used_item
.Use_more:   jsr       Pop_Module           ; Leave inventory
             jsr       Inv21_Exit
             rts       
; ------------- Check if there's a spell in the item -----------------
.No_event:   tst.b     Spell_charges(a2)    ; Any magic in this item ?
             beq       .No_magic
             move.b    Character_class(a0),d1     ; Right class ?
             move.w    Class_use(a2),d2
             btst      d1,d2
             bne.s     .Class_OK
             PlusMes   9                    ; Print message {9,+}
             bra       .Exit
.Class_OK:   lea.l     Spell_dat-124,a3     ; Get pointer to spell data
             move.b    Spell_class(a2),d0
             ext.w     d0
             mulu.w    #120,d0
             adda.w    d0,a3
             move.b    Spell_number(a2),d0
             ext.w     d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a3
             move.b    (a3),d0              ; Right area ?
             move.w    Spell_area_type,d1
             btst      d1,d0
             bne.s     .Right
             movea.l   Textfile_ptr,a1      ; Print message
             move.w    #0,WText_nr
             move.l    #Code0007Sys,Textfile_ptr
             Push      Module,TxtW_Mod
             move.l    a1,Textfile_ptr
             rts       
.Right:      moveq.l   #0,d0                ; Do magic !
             move.b    Spell_class(a2),d0
             move.w    d0,Selected_class
             move.b    Spell_number(a2),d0
             move.w    d0,Selected_spell
             st        Magic_object_flag    ; Signal
             jsr       Do_magic
             move.l    #Code0001Sys,Textfile_ptr
             rts       
; ------------- Check if it's a special item -------------------------
.No_magic:   cmpi.b    #13,1(a2)            ; Is it a special item ?
             bne       .No_special_item
             move.w    Special_item_flags,d0      ; Get data
             move.b    21(a2),d1
             subq.b    #1,d1
             btst      d1,d0                ; Already used ?
             beq.s     .No
             PlusMes   23                   ; Print message {23,+}
             jmp       Pop_Module
.No:         bset      d1,d0                ; Set flag for this item
             move.w    d0,Special_item_flags
             clr.b     (a1)                 ; Remove item
             moveq.l   #0,d0
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             jsr       Destroy_used_item
             PlusMes   18                   ; Print message {18,+}
             jmp       Pop_Module
; ------------- Check if it's a text scroll --------------------------
.No_special_item:      
             cmpi.b    #7,1(a2)             ; Is it a text scroll ?
             bne       .No_text_scroll
             lea.l     Codetxt_filename,a0  ; Load textfile
             moveq.l   #0,d0
             move.b    Misc_1(a2),d0
             jsr       Load_subfile
             move.l    a0,Codetxt_ptr
             move.b    Misc_2(a2),d0        ; Show text
             move.w    d0,WText_nr
             move.l    a0,Textfile_ptr
             lea.l     TxtW_Mod,a0
             move.l    #.End_text_scroll,Return_ptr(a0)
             jsr       Push_Module
             rts       
.End_text_scroll:      
             clr.l     TxtW_Mod+Return_ptr  ; Restore stuff
             move.l    #Code0001Sys,Textfile_ptr
             movea.l   Codetxt_ptr,a0       ; Free memory
             jsr       Free_memory
             jmp       Pop_Module
; ------------- Check if it's a magic disc ---------------------------
.No_text_scroll:       
             cmpi.b    #18,1(a2)            ; Is it a magic disc ?
             bne       .Exit
             cmpi.b    #1,Current_map_type  ; Are we in 2D wilderness ?
             beq.s     .Correct_map_type
             PlusMes   16                   ; Print message {16,+}
             bra       .Exit
.Correct_map_type:     
             moveq.l   #4,d0                ; Do it!
             jsr       Set_new_travel_mode
             Pop       Module
             Pop       Module
             Pop       Module
             jmp       Init_display
.Exit:       jmp       Pop_Module

; [ Destroy used item ]
;   IN : a0 - Pointer to character data (.l)
;        a1 - Pointer to object slot (.l)
;        a2 - Pointer to object data (.l)
; All registers are restored
Destroy_used_item:     
             movem.l   d0-d3/a3,-(sp)
             lea.l     Object_pos_list-4,a3 ; Show item destruction
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
             lea.l     Erase_icon,a3
             move.b    -1(a3,d3.w),d3
             ext.w     d3
             jsr       Show_item_destruction
             movem.l   (sp)+,d0-d3/a3
             rts       

; [ Remove used magic item ]
; All registers are restored
Remove_used_magic_item:                     
             movem.l   d0/d1/a0-a2/a6,-(sp)
             jsr       Copy_screen
             movea.l   Current_inventory_chardat_ptr,a0     ; Initialize registers
             lea.l     Neck_place_counter-1(a0),a1
             lea.l     Inv_data-40(a0),a2
             move.b    Object_slot_number,d0
             ext.w     d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             btst      #2,Item_stat_bits(a2)      ; Multiple ?
             bne.s     .Skip
             cmpi.b    #$ff,Spell_charges(a2)     ; Infinite charges ?
             beq.s     .Go_on
             subq.b    #1,Spell_charges(a2) ; One charge less
             bne.s     .Go_on
.Skip:       moveq.l   #0,d0                ; Remove item
             move.w    Weight(a2),d0
             sub.l     d0,Weight_normal(a0)
             subq.b    #1,(a1)
             bne       .More_left
             jsr       Destroy_used_item
             bra       .Go_on
.More_left:  cmpi.b    #1,(a1)              ; Remove quantity ?
             bne.s     .Go_on
             move.b    (a2),d0              ; Redraw object
             move.b    Object_slot_number,d1
             movea.l   Off_screen,a6
             jsr       INV2_Show_object
             Update_screen 
.Go_on:      movem.l   (sp)+,d0/d1/a0-a2/a6
             rts       

;*****************************************************************************
; [ Pool gold ]
;*****************************************************************************
Pool_gold_INV2:        
             movea.l   Current_inventory_chardat_ptr,a0     ; Pool gold
             move.w    Gold_coins(a0),d0
             move.l    Weight_normal(a0),d1
             move.w    Attr_1_normal(a0),d2
             add.w     Attr_1_normal_magic(a0),d2
             mulu.w    #1000,d2
             jsr       Pool_gold
             add.w     d0,Gold_coins(a0)    ; Add extra gold
             mulu.w    #Gold_weight,d0
             add.l     d0,Weight_normal(a0)
             rts       

;*****************************************************************************
; [ View item module ]
;*****************************************************************************
View_item:   
             Wait_4_unclick 
             lea.l     ViewItem_Mod,a0
             jmp       Push_Module

ViewItem_DisInit:      
             SetMesMin                      16,49+1,176,Code0001Sys
             Push      MA,UseItem_area      ; Backpack & body area
             moveq.l   #3,d0
             movea.l   Off_screen,a6        ; Print message {3,-}
             MesMin    3
             Update_screen 
             Wait_4_unclick 
             rts       

Exit_view_item:        
             jmp       Pop_Module
Do_view_backpack_item: 
             tst.b     d0                   ; Any slot selected ?
             beq.s     Exit_view_item
             ext.w     d0
             addi.w    #9,d0
             bra.s     View_item_entry
Do_view_body_item:     
             tst.b     d0                   ; Any slot selected ?
             beq.s     Exit_view_item
             ext.w     d0
View_item_entry:       
             Wait_4_unclick 
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a0
             adda.w    d0,a0
             tst.b     (a0)                 ; Anything in this slot ?
             beq.s     Exit_view_item
             move.b    d0,Object_slot_number      ; Open item view window
             Push      Module,ItemView1_Mod
             rts       

;*****************************************************************************
ItemViewW1_DisInit:    
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper

             moveq.l   #16,d0               ; Open a window
             moveq.l   #112,d1
             moveq.l   #18,d2
             moveq.l   #6,d3
             moveq.l   #2,d4
             moveq.l   #1,d6
             lea.l     ItemView1_L1,a0
             jsr       Open_window
             move.w    d0,Window_handle

             movea.l   Itemdata_ptr,a1
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #40,d0
             adda.w    d0,a1
             movea.l   Off_screen,a6

             btst      #0,Item_stat_bits(a1)      ; Cursed item ?
             sne       Cursed

             move.w    #32,d0               ; Display empty icon
             move.w    #128,d1
             lea.l     Layout_icn+9856,a0
             jsr       Put_unmasked_block
             lea.l     Objects_icn,a0       ; Get graphics address
             move.b    (a1),d2
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block     ; Display object icon

             move.w    #32+19,d0            ; Set cursor
             move.w    #129,d1
             jsr       IG_Set_cursor
             move.w    Name_word_nr(a1),d0  ; Print item name
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print

             move.w    #32+19,d0            ; Set cursor
             move.w    #129+8,d1
             jsr       IG_Set_cursor
             lea.l     Misc_dat+Item_type_names,a0          ; Print item type
             moveq.l   #0,d0
             move.b    Item_type(a1),d0
             add.w     d0,d0
             move.w    0(a0,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print

             move.w    #32+145,d0           ; Set cursor
             move.w    #129,d1
             jsr       IG_Set_cursor
             lea.l     Classes_txt,a0       ; Print "CLASSES:"
             jsr       IG_Print

             lea.l     Class_dat+Class_names,a2   ; Print classes
             lea.l     Classname_pos_list,a4
             moveq.l   #1,d2
             move.w    Class_use(a1),d3
             moveq.l   #8-1,d7
.Loop:       btst      d2,d3                ; Usable ?
             beq.s     .Next
             move.w    (a4)+,d0             ; Set cursor
             move.w    (a4)+,d1
             jsr       IG_Set_cursor
             move.w    d2,d0                ; Print class name
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
.Next:       addq.w    #1,d2                ; Next class
             dbra      d7,.Loop

             move.w    #32+145,d0           ; Set cursor
             move.w    #129+38,d1
             jsr       IG_Set_cursor
             lea.l     Sex_use_txt,a0       ; Print "SEX USE:"
             jsr       IG_Print
             lea.l     Sex_use_strings,a0   ; Print sex use
             moveq.l   #0,d0
             move.b    Sex_use(a1),d0
             lsl.w     #2,d0
             movea.l   0(a0,d0.w),a0
             jsr       IG_Print

             lea.l     Control_icn+2816,a0  ; Display control icon
             move.w    #32+224,d0
             move.w    #128+48,d1
             moveq.l   #2,d6
             moveq.l   #16,d7
             jsr       Blot_unmasked_block
             btst      #7,Item_stat_bits(a1)      ; Lored ?
             sne       Xtra_window
             bne.s     .Yes
             cmpi.w    #6,Travel_mode       ; Superchicken mode ?
             seq       Xtra_window
             beq.s     .Yes
             lea.l     Chequered,a0         ; Disable icon
             jsr       Blot_masked_block
.Yes:        
             move.w    #32,d0               ; Set cursor
             move.w    #128+19,d1
             jsr       IG_Set_cursor
             lea.l     Weight2_txt,a0       ; Print "WEIGHT:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print weight
             moveq.l   #0,d0
             move.w    Weight(a1),d0
             moveq.l   #5,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print
             lea.l     Gram_txt,a0          ; Print " GR"
             jsr       IG_Print

             move.w    #32,d0               ; Set cursor
             move.w    #128+30,d1
             jsr       IG_Set_cursor
             lea.l     Hands_txt,a0         ; Print "HANDS:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print number of hands
             moveq.l   #0,d0
             move.b    Hand_use(a1),d0
             moveq.l   #1,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #32,d0               ; Set cursor
             move.w    #128+38,d1
             jsr       IG_Set_cursor
             lea.l     Fingers_txt,a0       ; Print "FINGERS:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print number of fingers
             moveq.l   #0,d0
             move.b    Ring_use(a1),d0
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #32,d0               ; Set cursor
             move.w    #128+46,d1
             jsr       IG_Set_cursor
             lea.l     Damage_txt,a0        ; Print "DAMAGE:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print damage points
             moveq.l   #0,d0
             move.b    Damage_pts(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC1
             neg.w     d0
.NoC1:       moveq.l   #3,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #32,d0               ; Set cursor
             move.w    #128+54,d1
             jsr       IG_Set_cursor
             lea.l     Protection_txt,a0    ; Print "PROTECTION:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print damage points
             moveq.l   #0,d0
             move.b    Protection_pts(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC2
             neg.w     d0
.NoC2:       moveq.l   #3,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             Update_screen 
             rts       

Open_ExtraW: 
             Wait_4_unclick 
             tst.b     Xtra_window          ; Possible ?
             beq.s     .Exit
             Push      Module,ItemView2_Mod
.Exit:       rts       

;*****************************************************************************
ItemViewW2_DisInit:    
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper

             moveq.l   #32,d0
             moveq.l   #48,d1
             moveq.l   #12,d2
             moveq.l   #6,d3
             moveq.l   #2,d4
             moveq.l   #1,d6
             suba.l    a0,a0
             jsr       Open_window
             move.w    d0,View2_handle

             movea.l   Itemdata_ptr,a1
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #40,d0
             adda.w    d0,a1
             movea.l   Off_screen,a6

             move.w    #48,d0               ; Set cursor
             move.w    #64,d1
             jsr       IG_Set_cursor
             lea.l     LPMax_txt,a0         ; Print "LP-MAX:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print LP maximum
             moveq.l   #0,d0
             move.b    LP_max(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC1
             neg.w     d0
.NoC1:       moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #48+80,d0            ; Set cursor
             move.w    #64,d1
             jsr       IG_Set_cursor
             lea.l     PPMax_txt,a0         ; Print "PP-MAX:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print PP maximum
             moveq.l   #0,d0
             move.b    SP_max(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC2
             neg.w     d0
.NoC2:       moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #48,d0               ; Set cursor
             move.w    #64+7,d1
             jsr       IG_Set_cursor
             lea.l     MBW_txt,a0           ; Print "M-B-W:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print Magic Bonus Weapon
             moveq.l   #0,d0
             move.b    Weapon_magic_bonus(a1),d0
             moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #48+80,d0            ; Set cursor
             move.w    #64+7,d1
             jsr       IG_Set_cursor
             lea.l     MBA_txt,a0           ; Print "M-B-A:"
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print PP maximum
             moveq.l   #0,d0
             move.b    Armour_magic_bonus(a1),d0
             moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print

             move.w    #48,d0               ; Set cursor
             move.w    #64+14,d1
             jsr       IG_Set_cursor
             lea.l     Attr2_txt,a0         ; Print "ATTRIBUTE"
             jsr       IG_Print

             tst.b     Attribute(a1)        ; Any attribute changed ?
             beq       .No_attr

             move.w    #48,d0               ; Set cursor
             move.w    #64+21,d1
             jsr       IG_Set_cursor
             lea.l     Race_dat+Race_names+30,a2  ; Print attribute name
             moveq.l   #0,d0
             move.b    Attribute(a1),d0
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             lea.l     Tween_txt,a0         ; Print " : "
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print attribute value
             moveq.l   #0,d0
             move.b    Attribute_normal(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC3
             neg.w     d0
.NoC3:       moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print
.No_attr:    
             move.w    #48,d0               ; Set cursor
             move.w    #64+28,d1
             jsr       IG_Set_cursor
             lea.l     Skill2_txt,a0        ; Print "SKILL"
             jsr       IG_Print

             tst.b     Skill(a1)            ; Any skill changed ?
             beq       .No_skill

             move.w    #48,d0               ; Set cursor
             move.w    #64+35,d1
             jsr       IG_Set_cursor
             lea.l     Class_dat+Class_names+22,a2          ; Print skill name
             moveq.l   #0,d0
             move.b    Skill(a1),d0
             add.w     d0,d0
             move.w    -2(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             lea.l     Tween_txt,a0         ; Print " : "
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print skill value
             moveq.l   #0,d0
             move.b    Skill_normal(a1),d0
             tst.b     Cursed               ; Negate if cursed
             beq.s     .NoC4
             neg.w     d0
.NoC4:       moveq.l   #2,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print
.No_skill:   
             tst.b     Spell_charges(a1)    ; Any magic ?
             bne       .Magic
             move.w    #48,d0               ; Set cursor
             move.w    #64+42,d1
             jsr       IG_Set_cursor
             lea.l     Magic_txt,a0         ; Print "MAGIC"
             jsr       IG_Print
             bra       .No_magic

.Magic:      move.w    #48,d0               ; Set cursor
             move.w    #64+42,d1
             jsr       IG_Set_cursor
             moveq.l   #1,d0                ; Set ink
             jsr       IG_Set_ink
             lea.l     Spell_dat+Spellclass_names,a2        ; Print spell class name
             moveq.l   #0,d0
             move.b    Spell_class(a1),d0
             add.w     d0,d0
             move.w    -2(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink

             move.w    #48,d0               ; Set cursor
             move.w    #64+49,d1
             jsr       IG_Set_cursor
             lea.l     Spell_dat+Spell_names,a2   ; Print spell name
             move.b    Spell_class(a1),d0
             subq.w    #1,d0
             mulu.w    #60,d0
             adda.w    d0,a2
             moveq.l   #0,d0
             move.b    Spell_number(a1),d0
             add.w     d0,d0
             move.w    -2(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             lea.l     Tween2_txt,a0        ; Print " ("
             jsr       IG_Print
             lea.l     Line_buffer,a0       ; Print spell charges
             moveq.l   #0,d0
             move.b    Spell_charges(a1),d0
             cmpi.b    #$ff,d0
             bne.s     .Finite
             lea.l     Infinite_charges_txt,a0    ; Print "***"
             jsr       IG_Print
             bra.s     .Continue
.Finite:     moveq.l   #3,d7
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print
.Continue:   lea.l     Tween3_txt,a0        ; Print ")"
             jsr       IG_Print
.No_magic:   
             Update_screen 
             rts       

ItemViewW2_DisExit:    
             move.l    d0,-(sp)
             move.w    View2_handle,d0      ; Close window
             jsr       Close_window
             move.l    (sp)+,d0
             rts       

Accursed_blink:        
             tst.b     Cursed               ; Cursed ?
             beq.s     .Exit
             lea.l     Cursed_txt,a0
; ------------- Update colour ----------------------------------------
             subq.w    #1,Curse_count       ; Every 4 frames
             bne.s     .Skip
             move.w    #4,Curse_count
             lea.l     .Colours,a1
             move.w    Curse_index,d0
             addq.w    #1,d0
             move.b    0(a1,d0.w),d1
             bpl.s     .Not_end             ; End of colour list ?
             moveq.l   #0,d0                ; Reset
             move.b    (a1),d1
.Not_end:    move.w    d0,Curse_index
             move.b    d1,1(a0)
; ------------- Print text -------------------------------------------
.Skip:       movea.l   Off_screen,a6        ; Print "CURSED"
             move.w    #48,d0
             move.w    #65+56,d1
             move.w    #160,d2
             jsr       Print_centered_string
.Exit:       rts       

.Colours:    .DC.b 1,5,6,10,10,10,6,5,1,1,1
             .DC.b -1
             .EVEN 

;*****************************************************************************
Double_Pop:  
             Pop       Module
             jmp       Pop_Module

Window_DisExit:        
             move.l    d0,-(sp)
             move.w    Window_handle,d0     ; Close window
             jsr       Close_window
             move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Transfer item module ]
;*****************************************************************************
Transfer_item:         
             lea.l     TransferItem_Mod,a0
             jmp       Push_Module

TransferItem_DisInit:  
             Push      MA,Backpack_area     ; Mouse in backpack area
             movea.l   Off_screen,a6        ; Print message {4,-}
             MesMin    4
             Update_screen 
             Wait_4_unclick 
             rts       

Exit_TransferItem:     
             Pop       Module
             rts       
Do_TransferItem:       
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq.s     Exit_TransferItem
             ext.w     d0
             addi.w    #9,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     Exit_TransferItem
             lea.l     Inv_data-40(a0),a2
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a2

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to object data (.l)

             move.b    d0,Object_slot_number
             moveq.l   #-1,d1               ; Default non-multiple
             btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .Single
             cmpi.b    #1,(a1)              ; More as one ?
             bhi.s     .Multiple
             move.w    Item_ID(a2),d1
.Single:     moveq.l   #0,d0                ; Get parameters
             move.w    Weight(a2),d0
             moveq.l   #1,d2
             jmp       Continue_transfer_item
.Multiple:   moveq.l   #0,d0                ; Set parameters
             move.b    (a1),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TransMItem_Mod      ; Requester
             rts       

;*****************************************************************************
; [ Transfer Multiple Item window module ]
;*****************************************************************************
TransMItem_DisInit:    
             movem.l   d0-d7/a0-a6,-(sp)
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit
; ------------- Initialize pointers ----------------------------------
             move.b    Object_slot_number,d0
             ext.w     d0
             movea.l   Current_inventory_chardat_ptr,a1
             lea.l     Neck_place_counter-1(a1),a2
             lea.l     Inv_data-40(a1),a3
             adda.w    d0,a2
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a3
             movea.l   Off_screen,a6

; ------------- REGISTER CONTENTS ------------------------------------
;  a1 - Pointer to character data (.l)
;  a2 - Pointer to object slot (.l)
;  a3 - Pointer to object data (.l)
;  a6 - Screen base (.l)

; ------------- Fill window ------------------------------------------
             move.b    (a3),d0              ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             move.w    Name_word_nr(a3),d0  ; Get number of word
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print word
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

TransMItem_Return:     
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Inv_data-40(a0),a0   ; Get pointer to object data
             move.b    Object_slot_number,d0
             ext.w     d0
             mulu.w    #40,d0
             adda.w    d0,a0
             move.l    ItemW_nr,d2          ; Get parameters
             bne.s     .Not_zero
             jmp       Pop_Module
.Not_zero:   move.w    d2,d0
             mulu.w    Weight(a0),d0
             move.w    Item_ID(a0),d1
; WATCH IT !!! ROUTINE CONTINUES !!!

;*****************************************************************************
; [ Transfer Item - part II ]
;   IN : d0 - Weight of transferred object(s) (.l)
;        d1 - Object ID / -1  when not multiple item (.w)
; No registers are restored
;*****************************************************************************
Continue_transfer_item:                     
             movea.l   Current_inventory_chardat_ptr,a0
             jsr       Scan_4_transfer_victims
             bne.s     .Go                  ; ANYONE interested ?
             PlusMes   5                    ; Print message {5,+}
             jmp       Pop_Module
.Go:         jsr       Show_transfer_victims
             move.b    Object_slot_number,d0      ; Set icon number
             ext.w     d0
             mulu.w    #40,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Inv_data-40(a0),a0
             move.b    0(a0,d0.w),TIVS_Icon_nr
             move.l    #Inv2_Do_TI,TIVS_Ptr ; Set pointer to routine
             lea.l     TIVS1_Mod,a0         ; Select transfer victim
             move.w    #24,Mouse_ptr(a0)
             jmp       Push_Module

; [ Transfer the item ]
;   IN : a0 - Pointer to victim's character data (.l)
Inv2_Do_TI:  
             movea.l   Current_inventory_chardat_ptr,a1
             lea.l     Neck_place_counter-1(a1),a2          ; Initialize registers
             lea.l     Inv_data-40(a1),a3
             moveq.l   #0,d0
             move.b    Object_slot_number,d0
             adda.w    d0,a2
             mulu.w    #40,d0
             adda.w    d0,a3

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to victim's character data (.l)
;  a1 - Pointer to transferring character's data (.l)
;  a2 - Pointer to transferred object's slot (.l)
;  a3 - Pointer to transferred object's data (.l)

             moveq.l   #1,d1
             btst      #2,Item_stat_bits(a3)      ; Multiple item ?
             beq       .Continue
             cmpi.b    #1,(a2)              ; More as one in slot ?
             bhi.s     .Multiple
             move.l    d1,ItemW_nr
; ------------- Search for a slot already containing this item -------
.Multiple:   lea.l     Inventory_1_place_counter(a0),a4
             lea.l     Inv_data+360(a0),a5
             move.w    Item_ID(a3),d0
             move.l    ItemW_nr,d1
             moveq.l   #12-1,d7
.Loop1:      tst.b     (a4)                 ; Anything there ?
             beq.s     .Next1
             cmp.w     Item_ID(a5),d0       ; Same item ?
             bne.s     .Next1
             cmpi.b    #99,(a4)             ; Not full ?
             bmi.s     .Found1
.Next1:      addq.l    #1,a4
             lea.l     40(a5),a5
             dbra      d7,.Loop1
             bra       .Continue
.Found1:     moveq.l   #0,d0                ; Does it fit in the slot ?
             move.b    (a4),d0
             add.w     d1,d0
             cmpi.w    #99,d0
             bls       .Do_it
             moveq.l   #99,d2               ; Calculate number that will
             sub.b     (a4),d2              ; fit
             sub.l     d2,ItemW_nr
             move.b    #99,(a4)             ; Fill slot
             sub.b     d2,(a2)              ; Remove item(s)
             mulu.w    Weight(a3),d2        ; Adjust weight
             add.l     d2,Weight_normal(a0)
             sub.l     d2,Weight_normal(a1)
             bra       .Multiple
; ------------- Search for a free slot then transfer the item --------
.Continue:   lea.l     Inventory_1_place_counter(a0),a4
             lea.l     Inv_data+360(a0),a5
             moveq.l   #12-1,d7
.Loop2:      tst.b     (a4)                 ; Free slot ?
             beq.s     .Do_it
             addq.l    #1,a4
             lea.l     40(a5),a5
             dbra      d7,.Loop2
             bra       .Exit
.Do_it:      moveq.l   #0,d2                ; Adjust weight
             move.b    d1,d2
             mulu.w    Weight(a3),d2
             add.l     d2,Weight_normal(a0)
             sub.l     d2,Weight_normal(a1)
             add.b     d1,(a4)              ; Fill slot
             moveq.l   #20-1,d7             ; Copy item data
.Loop3:      move.w    (a3)+,(a5)+
             dbra      d7,.Loop3
             lea.l     -40(a3),a3
             movea.l   Off_screen,a6
             sub.b     d1,(a2)              ; Remove item(s)
             bne.s     .Skip
             move.b    Object_slot_number,d0      ; Erase object
             jsr       INV2_Erase_object
             Update_screen 
             bra.s     .Exit
.Skip:       cmpi.b    #1,(a2)              ; Remove quantity ?
             bne.s     .Exit
             move.b    (a3),d0              ; Redraw object
             move.b    Object_slot_number,d1
             jsr       INV2_Show_object
             Update_screen 
.Exit:       jmp       Pop_Module

;*****************************************************************************
; [ Transfer gold module ]
;*****************************************************************************
Transfer_gold:         
             movea.l   Off_screen,a6        ; Print message {6,-}
             MesMin    6
             Update_screen 
             Wait_4_unclick 
             movea.l   Current_inventory_chardat_ptr,a0
             moveq.l   #0,d0                ; Set parameters
             move.w    Gold_coins(a0),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TransGold_Mod ; Requester
             rts       

;*****************************************************************************
; [ Transfer Gold window module ]
;*****************************************************************************
TransGold_DisInit:     
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

TransGold_Return:      
             move.l    ItemW_nr,d0          ; Any coins ?
             beq       .Exit
             move.w    d0,d1                ; Calculate weight
             mulu.w    #Gold_weight,d0
             movea.l   Current_inventory_chardat_ptr,a0
             jsr       Scan_4_gold_victims
             bne.s     .Go                  ; ANYONE interested ?
             PlusMes   5                    ; Print message {5,+}
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             move.l    #Do_TransferGold,TIVS_Ptr  ; Select transfer victim
             lea.l     TIVS1_Mod,a0
             move.w    #25,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       Wait_4_unclick 
             rts       

; [ Transfer the gold ]
;   IN : a0 - Pointer to victim's character data (.l)
Do_TransferGold:       
             movea.l   Current_inventory_chardat_ptr,a1
             move.l    ItemW_nr,d0          ; Transfer gold coins
             add.w     d0,Gold_coins(a0)
             sub.w     d0,Gold_coins(a1)
             mulu.w    #Gold_weight,d0      ; Adjust weight
             add.l     d0,Weight_normal(a0)
             sub.l     d0,Weight_normal(a1)
             rts       

;*****************************************************************************
; [ Transfer food module ]
;*****************************************************************************
Transfer_food:         
             movea.l   Off_screen,a6        ; Print message {7,-}
             MesMin    7
             Update_screen 
             Wait_4_unclick 
             movea.l   Current_inventory_chardat_ptr,a0
             moveq.l   #0,d0                ; Set parameters
             move.w    Food_rations(a0),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TransFood_Mod ; Requester
             rts       

;*****************************************************************************
; [ Transfer Food window module ]
;*****************************************************************************
TransFood_DisInit:     
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit
             movea.l   Off_screen,a6
             move.w    #Food_icon,d0        ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             lea.l     Food_txt,a0          ; Print word
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
             rts       

TransFood_Return:      
             movea.l   Current_inventory_chardat_ptr,a0
             move.l    ItemW_nr,d0          ; Any food ?
             beq       .Exit
             mulu.w    #Food_weight,d0      ; Calculate weight
; ------------- Scan characters for possible victims -----------------
             lea.l     Chard_ptrs,a1
             lea.l     Char_status_icons,a4
             moveq.l   #0,d6
             moveq.l   #1,d7
.Loop1:      tst.l     (a1)                 ; Any character there ?
             beq       .Next
             cmpa.l    (a1),a0              ; Current character ?
             bne.s     .Do_it
             move.w    d7,d5
             bra       .Next
.Do_it:      movea.l   (a1),a2              ; Get character data
; ------------- Check if character can carry the extra weight --------
             move.w    Attr_1_normal(a2),d1
             add.w     Attr_1_normal_magic(a2),d1
             mulu.w    #1000,d1
             sub.l     Weight_normal(a2),d1
             cmp.l     d0,d1                ; Not too heavy ?
             bmi       .Next
; ------------- Check if the character can carry the food ------------
             move.w    Food_rations(a2),d1
             add.w     d0,d1
             bvs       .Next
; ------------- Check if character is alive and kicking --------------
             move.w    #$e402,d1
             and.w     Body_conditions(a2),d1
             bne.s     .Next
             bset      d7,d6                ; Gimme! Gimme!
.Next:       addq.l    #4,a1                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi       .Loop1
             bmi       .Loop1
             move.w    d5,Transferring      ; Store results
             move.w    d6,Transfer_victims
             tst.w     d6                   ; ANYONE interested ?
             bne.s     .Go
             PlusMes   5                    ; Print message {5,+}
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             move.l    #Do_TransferFood,TIVS_Ptr  ; Select transfer victim
             lea.l     TIVS1_Mod,a0
             move.w    #26,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       Wait_4_unclick 
             rts       

; [ Transfer the food ]
;   IN : a0 - Pointer to victim's character data (.l)
Do_TransferFood:       
             movea.l   Current_inventory_chardat_ptr,a1
             move.l    ItemW_nr,d0          ; Transfer food rations
             add.w     d0,Food_rations(a0)
             sub.w     d0,Food_rations(a1)
             mulu.w    #Food_weight,d0      ; Adjust weight
             add.l     d0,Weight_normal(a0)
             sub.l     d0,Weight_normal(a1)
             rts       

;*****************************************************************************
; [ Equip item ]
;   IN : d0 - Slot number (.b)
; No registers are restored
;*****************************************************************************
Equip_item:  
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             ext.w     d0
             addi.w    #9,d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Anything in this slot ?
             beq       .Exit
             lea.l     Inv_data-40(a0),a2   ; Get pointer to item data
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a2
             movea.l   Off_screen,a6

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Object slot number (.w)
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to object slot (.l)
;  a2 - Pointer to item data (.l)
;  a6 - Screen base (.l)

; ------------- Is it a monster item ? -------------------------------
             cmpi.b    #17,Item_type(a2)
             beq       .Exit
; ------------- Can it be equipped in battle ? -----------------------
             tst.b     Battling             ; Are we fighting ?
             beq.s     .Battle_OK
             btst      #4,Item_stat_bits(a2)      ; Well ?
             bne       .Exit
; ------------- Is this item equipable ? -----------------------------
.Battle_OK:  move.b    Item_body_place(a2),d1
             beq.s     .No_equip
             cmpi.b    #7,d1                ; FUCKING EXCEPTION ???
             beq.s     .Equip_OK
             lea.l     Neck_place_counter-1(a0),a3          ; Slot free ?
             ext.w     d1
             tst.b     0(a3,d1.w)
             beq.s     .Equip_OK
.No_equip:   PlusMes   8                    ; Print message {8,+}
             bra       .Exit
; ------------- Does the character have the right class ? ------------
.Equip_OK:   move.b    Character_class(a0),d1     ; Right class ?
             move.w    Class_use(a2),d2
             btst      d1,d2
             bne.s     .Class_OK
             PlusMes   9                    ; Print message {9,+}
             bra       .Exit
; ------------- Does the character have the right sex ? --------------
.Class_OK:   move.b    Sex_use(a2),d1       ; Does it matter ?
             beq.s     .Sex_OK
             subq.b    #1,d1                ; FUCK !!!
             cmp.b     Character_sex(a0),d1 ; Right sex ?
             beq.s     .Sex_OK
             PlusMes   10                   ; Print message {10,+}
             bra       .Exit
; ------------- Does the character have enough hands ? ---------------
.Sex_OK:     move.b    Hand_use(a2),d1      ; Does it matter ?
             beq.s     .Hands_OK
             moveq.l   #2,d2                ; Maximally two hands
             sub.b     Hands_occupied(a0),d2
             cmp.b     d1,d2
             bpl.s     .Hands_OK
             PlusMes   11                   ; Print message {11,+}
             bra       .Exit
; ------------- Does the character have enough ring-fingers ? --------
.Hands_OK:   move.b    Ring_use(a2),d1      ; Does it matter ?
             beq.s     .Fingers_OK
             moveq.l   #2,d2                ; Maximally two ringfingers
             sub.b     Ringfingers_occupied(a0),d2
             cmp.b     d1,d2
             bpl.s     .Fingers_OK
             PlusMes   12                   ; Print message {12,+}
             bra       .Exit
; ------------- Equip it ---------------------------------------------
.Fingers_OK: lea.l     Neck_place_counter-1(a0),a3
             move.b    Item_body_place(a2),d1
             cmpi.b    #7,d1                ; FUCKING EXCEPTION ?
             bne.s     .No_ring
             tst.b     7(a3)                ; First finger occupied ?
             beq.s     .No_ring
             addq.b    #2,d1                ; Go to second finger
.No_ring:    ext.w     d1                   ; Get pointer to target slot
             adda.w    d1,a3
             lea.l     Inv_data-40(a0),a4   ; Get pointer to target item
             moveq.l   #40,d2               ; data
             mulu.w    d1,d2
             adda.w    d2,a4

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Source object slot number (.w)
;  d1 - Target object slot number (.w)
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to source object slot (.l)
;  a2 - Pointer to source item data (.l)
;  a3 - Pointer to target object slot (.l)
;  a4 - Pointer to target item data (.l)
;  a6 - Screen base (.l)

; ------------- Give boni --------------------------------------------
             move.b    Hand_use(a2),d2      ; Adjust hands & fingers
             add.b     d2,Hands_occupied(a0)      ; occupied
             move.b    Ring_use(a2),d2
             add.b     d2,Ringfingers_occupied(a0)
             move.b    Weapon_magic_bonus(a2),d2  ; Weapon bonus
             add.b     d2,Magic_bonus_weapon(a0)
             move.b    Armour_magic_bonus(a2),d2  ; Armour bonus
             add.b     d2,Magic_bonus_armour(a0)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 1
             move.b    Item_skill_1(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_1(a2),d2
             ext.w     d2
             sub.w     d2,(a5)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 2
             move.b    Item_skill_2(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_2(a2),d2
             ext.w     d2
             sub.w     d2,(a5)
             btst      #0,Item_stat_bits(a2)      ; Cursed item ?
             bne.s     .Cursed
             jsr       Positive_boni
             bra.s     .Well
.Cursed:     jsr       Negative_boni
; ------------- Equip it ---------------------------------------------
.Well:       move.b    #1,(a3)              ; Fill slot
             moveq.l   #20-1,d7             ; Copy object data
.Loop:       move.w    (a2)+,(a4)+
             dbra      d7,.Loop
             lea.l     -40(a2),a2
             lea.l     -40(a4),a4
; ------------- FUCKING EXCEPTION ------------------------------------
             cmpi.b    #2,Hand_use(a2)      ; Double-handed object in
             bne.s     .Go_on               ; right hand ?
             cmpi.w    #4,d1
             bne.s     .Go_on
             movem.l   d0/d1,-(sp)          ; Display cross over left hand
             moveq.l   #0,d0
             moveq.l   #6,d1
             jsr       INV2_Show_object
             movem.l   (sp)+,d0/d1
.Go_on:      subq.b    #1,(a1)              ; Remove source item
             bne.s     .Skip
             jsr       INV2_Erase_object    ; Erase object
             bra.s     .Continue
.Skip:       cmpi.b    #1,(a1)              ; Remove quantity ?
             bne.s     .Continue
             movem.w   d0/d1,-(sp)          ; Redraw source object
             move.b    d0,d1
             move.b    (a2),d0
             jsr       INV2_Show_object
             movem.w   (sp)+,d0/d1
.Continue:   move.b    (a4),d0              ; Draw target object
             jsr       INV2_Show_object
             Update_screen 
.Exit:       rts       

;*****************************************************************************
; [ Unequip item ]
;   IN : d0 - Slot number (.b)
; No registers are restored
;*****************************************************************************
Unequip_item:          
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             ext.w     d0
             movea.l   Current_inventory_chardat_ptr,a0
             lea.l     Neck_place_counter-1(a0),a1
             adda.w    d0,a1
             tst.b     (a1)                 ; Anything in this slot ?
             beq       .Exit
             lea.l     Inv_data-40(a0),a2   ; Get pointer to item data
             moveq.l   #40,d1
             mulu.w    d0,d1
             adda.w    d1,a2
             movea.l   Off_screen,a6
; ------------- Is it a monster item ? -------------------------------
             cmpi.b    #17,Item_type(a2)
             beq       .Exit
; ------------- Can it be un-equipped in battle ? --------------------
             tst.b     Battling             ; Are we fighting ?
             beq.s     .Battle_OK
             btst      #4,Item_stat_bits(a2)      ; Well ?
             bne       .Exit
; ------------- Is this item cursed ? --------------------------------
.Battle_OK:  btst      #0,Item_stat_bits(a2)      ; Cursed item ?
             beq.s     .Not_cursed
             PlusMes   17                   ; Print message {17,+}
             bra       .Exit
.Not_cursed: btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq       .Single
; ------------- Search for a slot already containing this item -------
.Multiple:   lea.l     Inventory_1_place_counter(a0),a3
             lea.l     Inv_data+360(a0),a4
             moveq.l   #10,d1
             move.w    Item_ID(a2),d2
             moveq.l   #12-1,d7
.Loop1:      tst.b     (a3)                 ; Anything there ?
             beq.s     .Next1
             cmp.w     Item_ID(a4),d2       ; Same item ?
             bne.s     .Next1
             cmpi.b    #99,(a3)             ; Not full ?
             bmi.s     .Continue
.Next1:      addq.w    #1,d1
             addq.l    #1,a3
             lea.l     40(a4),a4
             dbra      d7,.Loop1
; ------------- Scan for a free slot in backpack ---------------------
.Single:     lea.l     Inventory_1_place_counter(a0),a3
             lea.l     Inv_data+360(a0),a4
             moveq.l   #10,d1
             moveq.l   #12-1,d7
.Loop2:      tst.b     (a3)                 ; Free slot ?
             beq.s     .Continue
             addq.w    #1,d1                ; Next backpack slot
             addq.l    #1,a3
             lea.l     40(a4),a4
             dbra      d7,.Loop2
             PlusMes   13                   ; Print message {13,+}
             bra       .Exit

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Source object slot number (.w)
;  d1 - Target object slot number (.w)
;  a0 - Pointer to character data (.l)
;  a1 - Pointer to source object slot (.l)
;  a2 - Pointer to source item data (.l)
;  a3 - Pointer to target object slot (.l)
;  a4 - Pointer to target item data (.l)
;  a6 - Screen base (.l)

; ------------- Remove boni ------------------------------------------
.Continue:   move.b    Hand_use(a2),d2      ; Adjust hands & fingers
             sub.b     d2,Hands_occupied(a0)      ; occupied
             move.b    Ring_use(a2),d2
             sub.b     d2,Ringfingers_occupied(a0)
             move.b    Weapon_magic_bonus(a2),d2  ; Weapon bonus
             sub.b     d2,Magic_bonus_weapon(a0)
             move.b    Armour_magic_bonus(a2),d2  ; Armour bonus
             sub.b     d2,Magic_bonus_armour(a0)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 1
             move.b    Item_skill_1(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_1(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 2
             move.b    Item_skill_2(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_2(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             btst      #0,Item_stat_bits(a2)      ; Cursed item ?
             bne.s     .Cursed
             jsr       Negative_boni
             bra.s     .Well
.Cursed:     jsr       Positive_boni
; ------------- Unequip it -------------------------------------------
.Well:       clr.b     (a1)                 ; Clear source slot
             addq.b    #1,(a3)              ; Increase target slot
             moveq.l   #20-1,d7             ; Copy object data
.Loop3:      move.w    (a2)+,(a4)+
             dbra      d7,.Loop3
             lea.l     -40(a2),a2
             lea.l     -40(a4),a4
; ------------- FUCKING EXCEPTION ------------------------------------
             cmpi.b    #2,Hand_use(a2)      ; Double-handed object in
             bne.s     .Go_on               ; right hand ?
             cmpi.w    #4,d0
             bne.s     .Go_on
             move.l    d0,-(sp)             ; Remove cross over left hand
             moveq.l   #6,d0
             jsr       INV2_Erase_object
             move.l    (sp)+,d0
.Go_on:      jsr       INV2_Erase_object    ; Remove source object
             move.b    (a4),d0              ; Draw target object
             jsr       INV2_Show_object
             Update_screen 
.Exit:       rts       

; [ Give positive boni ]
;   IN : a0 - Pointer to character data (.l)
;        a2 - Pointer to source item data (.l)
; Changed registers : d2,a5
Positive_boni:         
             move.b    LP_max(a2),d2        ; LP max bonus
             ext.w     d2
             add.w     d2,Life_points_max_magic(a0)
             move.b    SP_max(a2),d2        ; SP max bonus
             ext.w     d2
             add.w     d2,Power_points_max_magic(a0)
             lea.l     Attr_1_normal_magic-2(a0),a5         ; Attribute bonus
             move.b    Attribute(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Attribute_normal(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill bonus
             move.b    Skill(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Skill_normal(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             move.b    Protection_pts(a2),d2      ; Protection bonus
             ext.w     d2
             add.w     d2,Protection_magic(a0)
             move.b    Damage_pts(a2),d2    ; Armour bonus
             ext.w     d2
             add.w     d2,Damage_magic(a0)
             rts       

; [ Give negative boni ]
;   IN : a0 - Pointer to character data (.l)
;        a2 - Pointer to source item data (.l)
; Changed registers : d2,a5
Negative_boni:         
             move.b    LP_max(a2),d2        ; LP max bonus
             ext.w     d2
             sub.w     d2,Life_points_max_magic(a0)
             move.b    SP_max(a2),d2        ; SP max bonus
             ext.w     d2
             sub.w     d2,Power_points_max_magic(a0)
             lea.l     Attr_1_normal_magic-2(a0),a5         ; Attribute bonus
             move.b    Attribute(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Attribute_normal(a2),d2
             ext.w     d2
             sub.w     d2,(a5)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill bonus
             move.b    Skill(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Skill_normal(a2),d2
             ext.w     d2
             sub.w     d2,(a5)
             move.b    Protection_pts(a2),d2      ; Protection bonus
             ext.w     d2
             sub.w     d2,Protection_magic(a0)
             move.b    Damage_pts(a2),d2    ; Armour bonus
             ext.w     d2
             sub.w     d2,Damage_magic(a0)
             rts       

;*****************************************************************************
; [ Update quantity colours ]
; Changed registers: d0,d1,a0
;*****************************************************************************
Update_quantity_colours:                    
             subq.b    #1,Quant_count       ; Every 4 frames
             bne.s     .Exit
             move.b    #4,Quant_count
             lea.l     Quant_cycles,a0
             move.w    Quant_index,d0
             addq.w    #1,d0
             move.b    0(a0,d0.w),d1
             bpl.s     .Not_end             ; End of colour list ?
             moveq.l   #0,d0                ; Reset
             move.b    (a0),d1
.Not_end:    move.w    d0,Quant_index
             cmpi.b    #4,d1                ; No display ?
             seq       Quant_block
             move.b    d1,Quant_init_string+1
.Exit:       rts       

;*****************************************************************************
; [ Transfer Item Victim Select module ]
;*****************************************************************************
TIVS_ModInit:          
             Push      MA,Main_root         ; Mouse in status area
             movea.l   Module_sp,a0
             cmpi.w    #24,Mouse_ptr(a0)    ; Object or gold/food ?
             bne.s     .Skip
             move.b    TIVS_Icon_nr,d0      ; Build mouse pointer
             jsr       Build_object_mptr
.Skip:       movea.l   Off_screen,a6
             MesMin    19                   ; Print message {19,-}
             Update_screen 
             Wait_4_unclick 
             rts       

TIVS_DisUpd: 
             jsr       Update_status_block
             jsr       Update_quantity_colours
             rts       

TIVS_ModExit:          
             st        AutoIcon_flag        ; Enable AutoIcon switching
             jsr       DoAutoIcon
             movea.l   Off_screen,a6        ; Erase message
             jsr       Erase_message_minus
             Update_screen 
             Pop       MA
             rts       

; [ Victim has been selected ]
;   IN : d0 - Victim number x 256 (.w)
TIVS_Action: 
             Wait_4_unclick 
             move.w    Transfer_victims,d1  ; Is it a victim ?
             lsr.w     #8,d0
             btst      d0,d1
             beq       .Exit
             lea.l     Chard_ptrs,a0        ; Get pointer to victim's
             add.w     d0,d0                ; character data
             add.w     d0,d0
             movea.l   -4(a0,d0.w),a0
             movea.l   TIVS_Ptr,a1          ; Execute routine
             jsr       (a1)
.Exit:       jmp       Pop_Module

;*****************************************************************************
; [ Scan characters to see if transfer is possible ]
;   IN : d0 - Weight of transferred object(s)                 (.l)
;        d1 - Transferred object's ID / -1 when not multiple  (.w)
;        a0 - Pointer to transferring character's data / 0    (.l)
;  OUT :     zero = Nobody wants to have anything to do with this filthy thing
;        non-zero = Someone might perhaps be vaguely interested
; All registers are restored
;*****************************************************************************
Scan_4_transfer_victims:                    
             movem.l   d2/d3/d5-d7/a0-a4,-(sp)
             lea.l     Chard_ptrs,a1
             lea.l     Char_status_icons,a4
             moveq.l   #0,d5                ; Dummy value
             moveq.l   #0,d6
             moveq.l   #1,d7
.Loop1:      tst.l     (a1)                 ; Any character there ?
             beq       .Next
             cmpa.l    (a1),a0              ; It's the current character ?
             bne.s     .Do_it
             move.w    d7,d5
             bra       .Next
.Do_it:      movea.l   (a1),a2              ; Get character data
; ------------- Check if character can carry the extra weight --------
             move.w    Attr_1_normal(a2),d2
             add.w     Attr_1_normal_magic(a2),d2
             mulu.w    #1000,d2
             sub.l     Weight_normal(a2),d2
             cmp.l     d0,d2                ; Not too heavy ?
             bmi       .Next
; ------------- Scan for slots already filled with this item ---------
             lea.l     Inventory_1_place_counter(a2),a3
             lea.l     Inv_data+360(a2),a4
             moveq.l   #12-1,d2
.Loop2:      tst.b     (a3)+                ; Anything there ?
             beq.s     .Next2
             cmp.w     Item_ID(a4),d1       ; Same item ?
             bne.s     .Next2
             cmpi.b    #99,-1(a3)           ; Not full ?
             bls.s     .Continue
.Next2:      lea.l     40(a4),a4
             dbra      d2,.Loop2
; ------------- Scan for free slots in backpack ----------------------
             lea.l     Inventory_1_place_counter(a2),a3
             moveq.l   #12-1,d2
.Loop3:      tst.b     (a3)+                ; Free slot ?
             beq.s     .Continue
             dbra      d2,.Loop3
             bra       .Next
; ------------- Check if character is NOT special or monster ---------
.Continue:   cmpi.b    #9,Character_race(a2)      ; Special or monster ?
             bpl       .Next
; ------------- Check if character is alive and kicking --------------
             move.w    #$e402,d2
             and.w     Body_conditions(a2),d2
             bne.s     .Next
             bset      d7,d6                ; Gimme! Gimme!
.Next:       addq.l    #4,a1                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi       .Loop1
             move.w    d5,Transferring      ; Set data
             move.w    d6,Transfer_victims
             tst.w     d6                   ; Anyone interested ?
             movem.l   (sp)+,d2/d3/d5-d7/a0-a4
             rts       

;*****************************************************************************
; [ Scan characters to see if gold transfer is possible ]
;   IN : d0 - Weight of transferred gold                   (.l)
;        d1 - Number of gold coins                         (.l)
;        a0 - Pointer to transferring character's data / 0 (.l)
;  OUT :     zero = Nobody wants to have anything to do with this filthy gold
;        non-zero = Someone might perhaps be vaguely interested
; All registers are restored
;*****************************************************************************
Scan_4_gold_victims:   
             movem.l   d2/d5-d7/a0-a2,-(sp)
             lea.l     Chard_ptrs,a1        ; Initialize registers
             moveq.l   #0,d6
             moveq.l   #1,d7
.Loop:       tst.l     (a1)                 ; Any character there ?
             beq       .Next
             cmpa.l    (a1),a0              ; Current character ?
             bne.s     .Do_it
             move.w    d7,d5
             bra       .Next
.Do_it:      movea.l   (a1),a2              ; Get character data
; ------------- Check if character can carry the extra weight --------
             move.w    Attr_1_normal(a2),d2
             add.w     Attr_1_normal_magic(a2),d2
             mulu.w    #1000,d2
             sub.l     Weight_normal(a2),d2
             cmp.l     d0,d2                ; Not too heavy ?
             bmi       .Next
; ------------- Check if the character can carry the coins -----------
             move.w    Gold_coins(a2),d2
             add.w     d1,d2
             bvs       .Next
; ------------- Check if character is NOT special or monster ---------
             cmpi.b    #9,Character_race(a2)      ; Special or monster ?
             bpl       .Next
; ------------- Check if character is alive and kicking --------------
             move.w    #$e402,d2
             and.w     Body_conditions(a2),d2
             bne.s     .Next
             bset      d7,d6                ; Gimme! Gimme!
.Next:       addq.l    #4,a1                ; Next character
             addq.w    #1,d7
             cmpi.w    #6+1,d7
             bmi       .Loop
             move.w    d5,Transferring      ; Store results
             move.w    d6,Transfer_victims
             tst.w     d6                   ; Anyone interested ?
             movem.l   (sp)+,d2/d5-d7/a0-a2
             rts       

;*****************************************************************************
; [ Set status icons according to transfer victim status ]
; All registers are restored
;*****************************************************************************
Show_transfer_victims: 
             movem.l   d0/d1/d7/a0,-(sp)
             sf        AutoIcon_flag        ; Disable AutoIcon switching
             lea.l     Char_status_icons,a0
             move.w    Transferring,d0      ; Get data
             move.w    Transfer_victims,d1
             moveq.l   #1,d7
.Loop:       cmp.w     d0,d7                ; Transferring character ?
             beq.s     .No
             btst      d7,d1                ; Interested ?
             bne.s     .Yes
.No:         move.b    #8,(a0)+             ; NO
             bra.s     .Next
.Yes:        move.b    #9,(a0)+             ; YES
.Next:       addq.w    #1,d7                ; Next character
             cmpi.w    #6+1,d7
             bmi.s     .Loop
             movem.l   (sp)+,d0/d1/d7/a0
             rts       

;*****************************************************************************
; [ Build a mouse pointer from object graphics ]
;   IN : d0 - Object icon number (.b)
; All registers are restored
;*****************************************************************************
Build_object_mptr:     
             movem.l   d0/d7/a0/a1,-(sp)
             lea.l     Objects_icn,a0       ; Calculate graphics address
             andi.w    #$00ff,d0
             lsl.w     #7,d0
             adda.w    d0,a0
             lea.l     UDMPTR+4,a1          ; Build mouse pointer
             moveq.l   #16-1,d7
.Loop:       move.w    (a0)+,d0             ; Load 4-plane graphics
             or.w      (a0)+,d0             ; Calculate 1-plane graphics
             or.w      (a0)+,d0
             or.w      (a0)+,d0
             move.w    d0,(a1)+             ; Store graphics
             not.w     d0                   ; Store mask
             move.w    d0,32-2(a1)
             dbra      d7,.Loop
             movem.l   (sp)+,d0/d7/a0/a1
             rts       

;*****************************************************************************
; [ Pool gold ]
;   IN : d0 - Start amount of gold coins (.w)
;        d1 - Weight carried by receiving character (.l)
;        d2 - Strength of receiving character in gram (.l)
;        a0 - Pointer to receiving character's data / 0 (.l)
;  OUT : d0 - Extra amount of gold coins (.w)
; Changed registers : d0
;*****************************************************************************
Pool_gold:   
             movem.l   d1-d5/d7/a0-a2,-(sp)
             lea.l     Chard_ptrs,a1
             move.w    d0,d3
             moveq.l   #0,d0
             moveq.l   #6-1,d7
.Loop:       tst.l     (a1)                 ; Any character there ?
             beq       .Next
             cmpa.l    (a1),a0              ; Current character ?
             beq       .Next
             movea.l   (a1),a2              ; Get character data
             move.w    #$0402,d5            ; Normal average person ?
             and.w     Body_conditions(a2),d5
             bne       .Next
             move.w    Gold_coins(a2),d4    ; Get number of gold coins
             move.w    d4,d5                ; More as 32767 coins ?
             add.w     d3,d5
             bvc.s     .Not_too_much
             move.w    #32767,d5            ; Correction
             sub.w     d3,d5
             sub.w     d4,d5
             move.w    d5,d4
             moveq.l   #0,d7                ; Force end of loop
.Not_too_much:         
             moveq.l   #Gold_weight,d5      ; Too much weight ?
             mulu.w    d4,d5
             add.l     d1,d5
             cmp.l     d2,d5
             bls.s     .Not_too_heavy
             move.l    d2,d5                ; Correction
             sub.l     d1,d5
             divu.w    #Gold_weight,d5
             move.w    d5,d4
             moveq.l   #0,d7                ; Force end of loop
.Not_too_heavy:        
             sub.w     d4,Gold_coins(a2)    ; Remove coins
             add.w     d4,d0
             mulu.w    #Gold_weight,d4
             sub.l     d4,Weight_normal(a2)
.Next:       addq.l    #4,a1
             dbra      d7,.Loop
             movem.l   (sp)+,d1-d5/d7/a0-a2
             rts       

;*****************************************************************************
; [ Remove item's effects ]
;   IN : d0 - Slot number {1...9} (.b)
;        a0 - Pointer to character data (.l)
; No registers are restored
;*****************************************************************************
Remove_boni: 
             movem.l   d0/d2/a0-a2/a5,-(sp)
             lea.l     Neck_place_counter(a0),a1  ; Calculate pointers
             lea.l     Inv_data(a0),a2
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
; ------------- Remove boni ------------------------------------------
             move.b    Hand_use(a2),d2      ; Adjust hands & fingers
             sub.b     d2,Hands_occupied(a0)      ; occupied
             move.b    Ring_use(a2),d2
             sub.b     d2,Ringfingers_occupied(a0)
             move.b    Weapon_magic_bonus(a2),d2  ; Weapon bonus
             sub.b     d2,Magic_bonus_weapon(a0)
             move.b    Armour_magic_bonus(a2),d2  ; Armour bonus
             sub.b     d2,Magic_bonus_armour(a0)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 1
             move.b    Item_skill_1(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_1(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             lea.l     Skill_1_normal_magic-2(a0),a5        ; Skill tax 2
             move.b    Item_skill_2(a2),d2
             ext.w     d2
             add.w     d2,d2
             adda.w    d2,a5
             move.b    Malus_2(a2),d2
             ext.w     d2
             add.w     d2,(a5)
             btst      #0,Item_stat_bits(a2)      ; Cursed item ?
             bne.s     .Cursed
             jsr       Negative_boni
             bra.s     .Exit
.Cursed:     jsr       Positive_boni
.Exit:       movem.l   (sp)+,d0/d2/a0-a2/a5
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Inv1_CIL:    .DC.b 29,56,30,56,56,56,56,56,56     ; Inventory 1 control icons
             .EVEN 
             .DC.l Go_Inv2,0,Inv1_Exit
             .DC.l 0,0,0
             .DC.l 0,0,0
Inv2_CIL:    .DC.b 8,34,30,32,31,35,33,18,20      ; Inventory 2 control icons
             .EVEN 
             .DC.l Inv2_Exit,Drop_item,Inv21_Exit
             .DC.l Use_item,Pool_gold_INV2,View_item
             .DC.l Transfer_item,Transfer_gold,Transfer_food

Inv2_target_hbl:       
             .DC.w 0
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.w 0
             .DC.w 0,$651,$333,$222,$111,$531,$421,$124     ; Objects palette
             .DC.w $236,$610,$310,$541,$340,$451,$444,$765

             .IF Language=1
; ...
             .ENDIF 
             .IF Language=2
; ...
             .ENDIF 
             .IF Language=3
Skills_name: .DC.b 1,8,"FÄHIGKEITEN",1,15,0 ; German
Attrs_name:  .DC.b 1,8,"ATTRIBUTE",1,15,0
Age_txt:     .DC.b "ALTER: ",0
Language_txt:          .DC.b 1,8,"SPRACHEN",1,15,0
Body_txt:    .DC.b 1,8,"KÖRPER",1,15,0
Mind_txt:    .DC.b 1,8,"GEIST",1,15,0
Weight_name: .DC.b 1,15,2,2,"GEWICHT",0
Gold_txt:    .DC.b "GOLD",0
Food_txt:    .DC.b "RATIONEN",0
Goldfood_txt:          .DC.b "G:01234 R:0123",0

Male_name:   .DC.b "MANN",0
Female_name: .DC.b "FRAU",0
Both_txt:    .DC.b "BEIDE",0
Sex_use_txt: .DC.b 1,1,"GESCHLECHT:",1,15,0
Hands_txt:   .DC.b "HÄNDE   : ",0
Fingers_txt: .DC.b "FINGER  : ",0
Classes_txt: .DC.b 1,1,"---- KLASSEN ----",1,15,0
Damage_txt:  .DC.b "SCHADEN : ",0
Protection_txt:        .DC.b "SCHUTZ  : ",0
Weight2_txt: .DC.b 1,1,"GEWICHT : ",1,15,0
Attr2_txt:   .DC.b 1,1,"ATTRIBUT",1,15,0
Skill2_txt:  .DC.b 1,1,"FÄHIGKEIT",1,15,0
Magic_txt:   .DC.b 1,1,"MAGIE",1,15,0
Cursed_txt:  .DC.b 1,9,"VERFLUCHT",1,15,0
             .ENDIF 

XP_txt:      .DC.b "EP:         ",0
LP_txt:      .DC.b "LP :    /   ",0
PP_txt:      .DC.b "SP :    /   ",0
SLP_txt:     .DC.b "SLP:    ",0
ProtDam_txt: .DC.b ":   ",0
Skill_txt:   .DC.b "  %/  %",0
Attr_txt:    .DC.b "   /   ",0
Weight_txt:  .DC.b "    KG/    KG",0
Gram_txt:    .DC.b " GR",0
LPMax_txt:   .DC.b "LP-MAX:",0
PPMax_txt:   .DC.b "PP-MAX:",0
MBW_txt:     .DC.b " M-B-W:",0
MBA_txt:     .DC.b " M-B-A:",0
Tween_txt:   .DC.b " : ",0
Tween2_txt:  .DC.b " (",0
Infinite_charges_txt:  .DC.b "***",0
Tween3_txt:  .DC.b ")",0
             .EVEN 

Classname_pos_list:    
y            set 0
             .REPT 4
             .DC.w 32+145,129+7+y
y            set y+7
             .ENDR 
y            set 0
             .REPT 4
             .DC.w 32+145+54,129+7+y
y            set y+7
             .ENDR 

Bodymind_relpos_list:  
             .DC.w 0,0,18,12,0,24,18,36,0,48

             .DC.w 32+16,80+16+32           ; Item window
Object_pos_list:       
             .DC.w 16,81,48,81,80,81        ; Body
             .DC.w 16,113,48,113,80,113
             .DC.w 16,145,48,145,80,145
             .DC.w 112,81,144,81,176,81     ; Backpack
             .DC.w 112,113,144,113,176,113
             .DC.w 112,145,144,145,176,145
             .DC.w 112,177,144,177,176,177
Window_fill: .REPT 16
             .DC.l $ffffffff,0
             .ENDR 
UseItem_area:          .DC.w 16,191,81,192  ; Backpack & body object area
Sex_use_strings:       
             .DC.l Both_txt,Male_name,Female_name

Quant_index: .DC.w 0
Quant_init_string:     .DC.b 1,0,2,-1,0
Quant_block: .DC.b 0
Quant_count: .DC.b 1
Quant_cycles:          .DC.b 15,15,15,15,15,15,15,2,3,4,4,4,4,4,4,4,3,2,-1
             .EVEN 
Inv2_PlusMes:          .DC.w 16,191,49,64
             .DC.w 16,50,176,14,15,2
Curse_count: .DC.w 1


             .BSS 
Current_inventory_chardat_ptr:              
             .DS.l 1
Object_name_nr:        .DS.w 1
TIVS_Icon_nr:          .DS.l 1              ; Transfer Item Victim Select
TIVS_Ptr:    .DS.l 1
CIL_buffer:  .DS.b 9   ; Must start on an EVEN address !!!
Print_objname_flag:    .DS.b 1
Erase_objname_flag:    .DS.b 1
Fade_block:  .DS.b 1
CIL_update:  .DS.b 1
Weight_update:         .DS.b 1
Charinfo_update:       .DS.b 1
Object_slot_number:    .DS.b 1
Battling:    .DS.b 1
Xtra_window: .DS.b 1
Cursed:      .DS.b 1
             .EVEN 
ItemW_nr:    .DS.l 1
Original_number:       .DS.l 1
Adding:      .DS.w 1
XWeight:     .DS.l 1
XStrength:   .DS.l 1
Transferring:          .DS.w 1
Transfer_victims:      .DS.w 1
View2_handle:          .DS.w 1
Curse_index: .DS.w 1


             .SECTION 5,DATA
Codetxt_filename:      .DC.b 18,"CODETXT.AMB",0
             .EVEN 

             .SECTION 6,BSS 
Codetxt_ptr: .DS.l 1


             .SECTION 7,DATA
; INVENTORY II : 2nd layer
Inv2_L2:     .DC.w 16,95,81,160             ; Body object area
             .DC.b 2
             .EVEN 
             .DC.l Backpack_area,BodyObj_C1
Backpack_area:         
             .DC.w 112,191,81,192           ; Backpack object area
             .DC.b 3
             .EVEN 
             .DC.l Control_area,Backpack_C1

; INVENTORY II : 3rd layer
BodyObj_C1:  .DC.w 16,31,81,96              ; Body object 1
             .DC.b 1
             .EVEN 
             .DC.l .C2
.C2:         .DC.w 48,63,81,96              ; Body object 2
             .DC.b 2
             .EVEN 
             .DC.l .C3
.C3:         .DC.w 80,95,81,96              ; Body object 3
             .DC.b 3
             .EVEN 
             .DC.l .C4
.C4:         .DC.w 16,31,113,128            ; Body object 4
             .DC.b 4
             .EVEN 
             .DC.l .C5
.C5:         .DC.w 48,63,113,128            ; Body object 5
             .DC.b 5
             .EVEN 
             .DC.l .C6
.C6:         .DC.w 80,95,113,128            ; Body object 6
             .DC.b 6
             .EVEN 
             .DC.l .C7
.C7:         .DC.w 16,31,145,160            ; Body object 7
             .DC.b 7
             .EVEN 
             .DC.l .C8
.C8:         .DC.w 48,63,145,160            ; Body object 8
             .DC.b 8
             .EVEN 
             .DC.l .C9
.C9:         .DC.w 80,95,145,160            ; Body object 9
             .DC.b 9
             .EVEN 
             .DC.l 0

; INVENTORY II : 3rd layer
Backpack_C1: .DC.w 112,127,81,96            ; Backpack object 1
             .DC.b 1
             .EVEN 
             .DC.l .C2
.C2:         .DC.w 144,159,81,96            ; Backpack object 2
             .DC.b 2
             .EVEN 
             .DC.l .C3
.C3:         .DC.w 176,191,81,96            ; Backpack object 3
             .DC.b 3
             .EVEN 
             .DC.l .C4
.C4:         .DC.w 112,127,113,128          ; Backpack object 4
             .DC.b 4
             .EVEN 
             .DC.l .C5
.C5:         .DC.w 144,159,113,128          ; Backpack object 5
             .DC.b 5
             .EVEN 
             .DC.l .C6
.C6:         .DC.w 176,191,113,128          ; Backpack object 6
             .DC.b 6
             .EVEN 
             .DC.l .C7
.C7:         .DC.w 112,127,145,160          ; Backpack object 7
             .DC.b 7
             .EVEN 
             .DC.l .C8
.C8:         .DC.w 144,159,145,160          ; Backpack object 8
             .DC.b 8
             .EVEN 
             .DC.l .C9
.C9:         .DC.w 176,191,145,160          ; Backpack object 9
             .DC.b 9
             .EVEN 
             .DC.l .C10
.C10:        .DC.w 112,127,177,192          ; Backpack object 10
             .DC.b 10
             .EVEN 
             .DC.l .C11
.C11:        .DC.w 144,159,177,192          ; Backpack object 11
             .DC.b 11
             .EVEN 
             .DC.l .C12
.C12:        .DC.w 176,191,177,192          ; Backpack object 12
             .DC.b 12
             .EVEN 
             .DC.l 0

; ITEM WINDOW : 1st layer
ItemW_L1:    .DC.w 0,143,0,63               ; Item window area
             .DC.b 1
             .EVEN 
             .DC.l 0,ItemW_L2

; ITEM WINDOW : 2nd layer
ItemW_L2:    .DC.w 0,31,32,47               ; Arrow up icon
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 0,31,48,63               ; Arrow down icon
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 80,111,48,63             ; Exit icon
             .DC.b 3
             .EVEN 
             .DC.l 0,0

; VIEW ITEM WINDOW 1 : 1st layer
ItemView1_L1:          
             .DC.w 224,255,48,63
             .DC.b 1
             .EVEN 
             .DC.l 0,0

             .SECTION 8,DATA
Hbl_Inv1_list:         
             .DC.w $ff00                    ; Dummy word
Inv1_pal:    .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Inv1_below:  .DCB.w 16,0
             .DC.w 0

Hbl_Inv2_list:         
             .DC.w $ff00                    ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
Inv2_below:  .DC.b 36,0
             .DCB.w 16,0
             .DC.b 49+32,0
             .DCB.w 16,0
             .DC.w 0

             .END 









