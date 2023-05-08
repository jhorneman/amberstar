
; Offsets in data-structures
; Written by J.Horneman (In Tune With The Universe)
; Start : 19-2-1991

; ********************************
; *    This file is a part of    *
; *      A M B E R S T A R       *
; * © 1991 Thalion Software GmbH *
; ********************************

             .XDEF Void

;*****************************************************************************
; These are the offsets for CHARDATA.nnn
             .ABS 0
             .DS.w 1   ; Fucking kennword !
Character_type:        .DS.b 1
Character_sex:         .DS.b 1
Character_race:        .DS.b 1
Character_class:       .DS.b 1
Skill_1:     .DS.b 1
Skill_2:     .DS.b 1
Skill_3:     .DS.b 1
Skill_4:     .DS.b 1
Skill_5:     .DS.b 1
Skill_6:     .DS.b 1
Skill_7:     .DS.b 1
Skill_8:     .DS.b 1
Skill_9:     .DS.b 1
Skill_10:    .DS.b 1
Skill_1_max: .DS.b 1
Skill_2_max: .DS.b 1
Skill_3_max: .DS.b 1
Skill_4_max: .DS.b 1
Skill_5_max: .DS.b 1
Skill_6_max: .DS.b 1
Skill_7_max: .DS.b 1
Skill_8_max: .DS.b 1
Skill_9_max: .DS.b 1
Skill_10_max:          .DS.b 1
Spell_class_counter:   .DS.b 1
Level_nr:    .DS.b 1
Hands_occupied:        .DS.b 1
Ringfingers_occupied:  .DS.b 1
Protection:  .DS.b 1
Damage:      .DS.b 1
Magic_bonus_weapon:    .DS.b 1
Magic_bonus_armour:    .DS.b 1
Neck_place_counter:    .DS.b 1
Head_place_counter:    .DS.b 1
Chest_place_counter:   .DS.b 1
Right_hand_place_counter:                   .DS.b 1
Body_place_counter:    .DS.b 1
Left_hand_place_counter:                    .DS.b 1
Right_finger_place_counter:                 .DS.b 1
Feet_place_counter:    .DS.b 1
Left_finger_place_counter:                  .DS.b 1
Inventory_1_place_counter:                  .DS.b 1
Inventory_2_place_counter:                  .DS.b 1
Inventory_3_place_counter:                  .DS.b 1
Inventory_4_place_counter:                  .DS.b 1
Inventory_5_place_counter:                  .DS.b 1
Inventory_6_place_counter:                  .DS.b 1
Inventory_7_place_counter:                  .DS.b 1
Inventory_8_place_counter:                  .DS.b 1
Inventory_9_place_counter:                  .DS.b 1
Inventory_10_place_counter:                 .DS.b 1
Inventory_11_place_counter:                 .DS.b 1
Inventory_12_place_counter:                 .DS.b 1
Learned_languages:     .DS.b 1
             .DS.b 1   ; Unused (current language)
             .DS.b 1   ; Unused
Body_conditions:       .DS.b 1
Mind_conditions:       .DS.b 1
Join_percentage_chance:                     .DS.b 1
Dialogue_quest:        .DS.b 1
Monster_picture_load_nr:                    .DS.b 1
Spell_chance_percentage:                    .DS.b 1
Magic_bonus_to_hit:    .DS.b 1
Moral_retreat_percentage:                   .DS.b 1
Battle_position:       .DS.b 1
Attacks_per_round:     .DS.b 1
Monster_type_status:   .DS.b 1
Elemental_status:      .DS.b 1

Possible_class:        .DS.w 1
Attr_1_normal:         .DS.w 1
Attr_2_normal:         .DS.w 1
Attr_3_normal:         .DS.w 1
Attr_4_normal:         .DS.w 1
Attr_5_normal:         .DS.w 1
Attr_6_normal:         .DS.w 1
Attr_7_normal:         .DS.w 1
Attr_8_normal:         .DS.w 1
Attr_9_normal:         .DS.w 1
Attr_10_normal:        .DS.w 1
Attr_1_max:  .DS.w 1
Attr_2_max:  .DS.w 1
Attr_3_max:  .DS.w 1
Attr_4_max:  .DS.w 1
Attr_5_max:  .DS.w 1
Attr_6_max:  .DS.w 1
Attr_7_max:  .DS.w 1
Attr_8_max:  .DS.w 1
Attr_9_max:  .DS.w 1
Attr_10_max: .DS.w 1
Special_1:   .DS.w 1
Special_2:   .DS.w 1
Special_3:   .DS.w 1
Special_4:   .DS.w 1
Special_5:   .DS.w 1
Special_6:   .DS.w 1
Special_7:   .DS.w 1
Special_8:   .DS.w 1
Special_9:   .DS.w 1
Special_10:  .DS.w 1
Special_11:  .DS.w 1
Life_points_normal:    .DS.w 1
Life_points_max:       .DS.w 1
Power_points_normal:   .DS.w 1
Power_points_max:      .DS.w 1
Nr_spell_learn_points: .DS.w 1
Gold_coins:  .DS.w 1
Food_rations:          .DS.w 1
Protection_magic:      .DS.w 1
Damage_magic:          .DS.w 1
Life_points_max_magic: .DS.w 1
Power_points_max_magic:                     .DS.w 1
Attr_1_normal_magic:   .DS.w 1
Attr_2_normal_magic:   .DS.w 1
Attr_3_normal_magic:   .DS.w 1
Attr_4_normal_magic:   .DS.w 1
Attr_5_normal_magic:   .DS.w 1
Attr_6_normal_magic:   .DS.w 1
Attr_7_normal_magic:   .DS.w 1
Attr_8_normal_magic:   .DS.w 1
Attr_9_normal_magic:   .DS.w 1
Attr_10_normal_magic:  .DS.w 1
Skill_1_normal_magic:  .DS.w 1
Skill_2_normal_magic:  .DS.w 1
Skill_3_normal_magic:  .DS.w 1
Skill_4_normal_magic:  .DS.w 1
Skill_5_normal_magic:  .DS.w 1
Skill_6_normal_magic:  .DS.w 1
Skill_7_normal_magic:  .DS.w 1
Skill_8_normal_magic:  .DS.w 1
Skill_9_normal_magic:  .DS.w 1
Skill_10_normal_magic: .DS.w 1
Person_save_bit_pos:   .DS.w 1
Battle_experience:     .DS.w 1
Battle_round_power_point_usage:             .DS.w 1
Birth_year:  .DS.w 1

Experience_points:     .DS.l 1
Spells_class_1:        .DS.l 1
Spells_class_2:        .DS.l 1
Spells_class_3:        .DS.l 1
Spells_class_4:        .DS.l 1
Spells_class_5:        .DS.l 1
Spells_class_6:        .DS.l 1
Spells_class_7:        .DS.l 1
Weight_normal:         .DS.l 1

Char_name:   .DS.b 16

Br_spell_class:        .DS.b 25
Br_spell_nr: .DS.b 25
Inv_data:    .DS.b 21*40                    ; !!! Different structure !!!
Action:      .DS.b 20
Act_dat:     .DS.w 20
Result:      .DS.b 100
Res_dat1:    .DS.b 100
Res_dat2:    .DS.b 100
Res_dat3:    .DS.w 100

; Portrait is only available if character is a person !
Portrait:    .DS.w 3   ; Header
             .DS.w 272 ; Bit image (32 x 34)

Character_text_start:  
; Irreguarly sized data follows !

;*****************************************************************************
; These are the offsets for MAP_DAT.nnn (2D)
             .ABS 0
             .DS.w 1   ; Kennbyte + fillbyte
Iconfile_nr: .DS.w 1
Map_type:    .DS.b 1
Map_special: .DS.b 1
Map_music:   .DS.b 1
Map_width:   .DS.b 1
Map_height:  .DS.b 1
Map_headline:          .DS.b 31
Event_data:  .DS.b 2540                     ; bbbbbbww
Char_data:   .DS.w 24
Char_icon:   .DS.b 24
Char_move:   .DS.b 24
Charstats:   .DS.b 24
Char_day:    .DS.b 24
Char_month:  .DS.b 24
Max_steps:   .DS.w 1
Time_year_len:         .DS.b 1
Time_month_len:        .DS.b 1
Time_day_len:          .DS.b 1
Time_hour_len:         .DS.b 1
Time_step_len:         .DS.b 1
Time_daytime:          .DS.b 1
Time_nighttime:        .DS.b 1
Map_data:    
; Irreguarly sized data follows !

;*****************************************************************************
; These are the offsets for ICON_DAT.nnn
             .ABS 0
             .DS.b 1   ; Kennbyte
Travel_icon_start:     .DS.b 1
Frames:      .DS.b 250
Hold_1:      .DS.w 250
Iconstats:   .DS.l 250
Map_icon_color:        .DS.b 250
Icon_palette:          .DS.w 1
             .DS.l 16
Frame_graphics:        
; Irregularly sized data follows !

;*****************************************************************************
; These are the offsets for MAP_DAT.nnn (3D)
             .ABS 0
             .DS.w 1   ; Kennbyte + fillbyte
Labdatafile_nr:        .DS.w 1
             .DS.b 2753                     ; Identical to 2D map data
Max_block_num:         .DS.b 1
; Irreguarly sized data follows !

;*****************************************************************************
; These are the offsets for LABBLOCK.nnn
             .ABS 0
             .DS.b 1   ; Kennbyte
Block_type:  .DS.b 1
Block_number:          .DS.b 1
Block_animation:       .DS.b 1
Block_X_cor: .DS.w 17
Block_Y_cor: .DS.w 17
Block_elements:        
; Irreguarly sized data follows !

;*****************************************************************************
; These are the offsets for BACKGRND.nnn
             .ABS 0
             .DS.l 1
Bg_counter:  .DS.b 1
             .EVEN 
Bg_elements: 
; Irreguarly sized data follows !
;*****************************************************************************
; These are the offsets for MISC_DAT.DAT
             .ABS 0
             .DS.w 8   ; Language word indices
Body_names:  .DS.w 8   ; Body condition word indices
Mind_names:  .DS.w 8   ; Mind condition word indices
Item_type_names:                            ; Item type word indices

;*****************************************************************************
; These are the offsets for RACE_DAT.DAT
             .ABS 0
             .DS.w 165
Race_names:  

;*****************************************************************************
; These are the offsets for CLASSDAT.DAT
             .ABS 0
             .REPT 11  ; 394 bytes pro class
             .DS.b 10
             .DS.l 90
             .DS.w 11
             .DS.b 2
             .ENDR 
Class_names: 

;*****************************************************************************
; These are the offsets for SPELLDAT.DAT
             .ABS 0
             .REPT 210
             .DS.b 4
             .ENDR 
Spellclass_names:      .DS.w 7
Spell_names: .DS.w 210
Spellarea_names:       .DS.w 8
Spellonwhat_names:     .DS.w 8

;*****************************************************************************
; These are the offsets for item data
             .ABS 0
             .DS.b 1   ; Item picture number
Item_type:   .DS.b 1
Ammo_use_ID: .DS.b 1
Sex_use:     .DS.b 1
Hand_use:    .DS.b 1
Ring_use:    .DS.b 1
LP_max:      .DS.b 1
SP_max:      .DS.b 1
Attribute:   .DS.b 1
Attribute_normal:      .DS.b 1
Skill:       .DS.b 1
Skill_normal:          .DS.b 1
Spell_class: .DS.b 1
Spell_number:          .DS.b 1
Spell_charges:         .DS.b 1
Ammo_ID:     .DS.b 1
Protection_pts:        .DS.b 1
Damage_pts:  .DS.b 1
Item_body_place:       .DS.b 1
Weapon_magic_bonus:    .DS.b 1
Armour_magic_bonus:    .DS.b 1
Misc_1:      .DS.b 1
Enchantment_normal:    .DS.b 1
Enchantment_max:       .DS.b 1
Item_stat_bits:        .DS.b 1
Item_skill_1:          .DS.b 1
Item_skill_2:          .DS.b 1
Malus_1:     .DS.b 1
Malus_2:     .DS.b 1
Misc_2:      .DS.b 1
Class_use:   .DS.w 1
Price:       .DS.w 1
Weight:      .DS.w 1
Item_ID:     .DS.w 1
Name_word_nr:          .DS.w 1

;*****************************************************************************
; This is 1 kilobyte of void.
             .BSS 
Void:        .DS.l 256

             .END 











