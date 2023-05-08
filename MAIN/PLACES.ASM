
; Places event
; Written by J.Horneman
; Start : 23-9-1991

MaxLevel     = 20

             .TEXT 
;*****************************************************************************
; [ Places ]
;*****************************************************************************
Places:      
             moveq.l   #0,d0                ; Get opening time
             move.b    1(a5),d0
             beq.s     .Open                ; Open 24 hours ?
             move.w    Hour,d1
             cmp.w     d1,d0                ; Too early ?
             ble.s     .Not_early
.Closed:     Restore_coords                 ; Back, sinister fiend !
             moveq.l   #0,d0                ; Closed text ?
             move.b    4(a5),d0
             cmpi.w    #26,d0
             beq       .Exit
             move.w    d0,WText_nr          ; Show text
             move.l    Maptext_ptr,Textfile_ptr
             Push      Module,TxtW_Mod
             bra       .Exit
.Not_early:  move.b    2(a5),d0             ; Get closing time
             cmp.w     d0,d1                ; Too late ?
             bge.s     .Closed
.Open:       lea.l     Place_dat-22,a0      ; Get address of place data
             move.w    6(a5),d0
             mulu.w    #24,d0
             adda.w    d0,a0
             move.l    a0,Placedat_ptr
             moveq.l   #0,d0                ; Get place type
             move.b    3(a5),d0
             add.w     d0,d0                ; Get pointer to module
             add.w     d0,d0
             move.l    .Place_mods-4(pc,d0.w),d0
             bne.s     .Ok
             ERROR     "[ Places ] : Illegal place type !!!"
             bra.s     .Exit
.Ok:         jsr       Exit_display
             movea.l   d0,a0                ; Do it
             jsr       Push_Module
.Exit:       rts       

.Place_mods: .REPT 8
             .DC.l Guild_Mod
             .ENDR 
             .DC.l MerchOBJC_Mod,MerchFOOD_Mod
             .DC.l 0,MerchHORSE_Mod,Healer_Mod,Sage_Mod
             .DC.l MerchRAFT_Mod,MerchSHIP_Mod,Inn_Mod,MerchMAGIC_Mod,0,0

;*****************************************************************************
Places_ModInit:        
             clr.w     Places_gold          ; No gold here
             movea.l   Event_data_ptr,a0    ; Get picture number
             moveq.l   #0,d0
             move.b    3(a0),d0
             move.w    d0,Place_nr
             move.b    .Place_pix-1(pc,d0.w),d0
             lea.l     Lay3_target_hbl+2,a0 ; Load picture
             jsr       Load_80x80_picture
             cmpi.w    #9,Place_nr          ; Object merchant ?
             beq.s     .Yes
             cmpi.w    #18,Place_nr         ; Magic merchant ?
             bne.s     .No
.Yes:        movea.l   Event_data_ptr,a0    ; Load merchant data
             move.w    8(a0),d0
             lea.l     Waredat_filename,a0
             jsr       Load_subfile
             move.l    a0,Waredat_ptr
             lea.l     Ware_count-12,a0     ; Calculate pointer to slot
             mulu.w    #12,d0               ; list
             adda.w    d0,a0
             move.l    a0,Warecount_ptr
             lea.l     Sold_slots,a0        ; Clear slots
             clr.l     (a0)+
             clr.l     (a0)+
             clr.l     (a0)
.No:         jmp       Init_display

.Place_pix:  .DC.b 3,3,3,3,3,3,3,3,4,4,6,7,8,10,14,14,15,23,0,0
             .EVEN 

Places_ModExit:        
             movea.l   Pic80_ptr,a0         ; Free memory
             jsr       Free_memory
             cmpi.w    #9,Place_nr          ; Object merchant ?
             beq.s     .Yes
             cmpi.w    #18,Place_nr         ; Magic merchant ?
             bne.s     .No
.Yes:        movea.l   Waredat_ptr,a0       ; Free memory
             jmp       Free_memory
.No:         rts       

; ************* General places actions *******************************
Exit_PLACES: 
             tst.w     Places_gold          ; Any gold left behind ?
             bne.s     .No_exit
             cmpi.w    #10,Place_nr         ; Food merchant ?
             bne.s     .No1
             tst.w     Places_food          ; Any food left behind ?
             beq       Do_PlacesExit
             bra       .No_exit
.No1:        cmpi.w    #9,Place_nr          ; Object merchant ?
             beq.s     .Yes
             cmpi.w    #18,Place_nr         ; Magic merchant ?
             bne.s     Do_PlacesExit
.Yes:        lea.l     Sold_slots,a0        ; Any objects left ?
             tst.l     (a0)+
             bne.s     .No_exit
             tst.l     (a0)+
             bne.s     .No_exit
             tst.l     (a0)
             beq.s     Do_PlacesExit
; ------------- Are U sure ? -----------------------------------------
.No_exit:    move.w    Place_nr,d0          ; Get text number
             move.b    .Exit_txts-1(pc,d0.w),d0
             ext.w     d0
             move.w    d0,ReqText_nr
             lea.l     Code0002Sys,a0       ; Set text file
             cmpi.w    #17,Place_nr         ; FUCKING EXCEPTION ???
             bne.s     .No2
             lea.l     Code0003Sys,a0
.No2:        move.l    a0,Textfile_ptr
             move.l    #Do_PlacesExit,ReqDo_ptr
             lea.l     Req_Mod,a0           ; Are U sure ?
             jmp       Push_Module

.Exit_txts:  .DC.b 8,8,8,8,8,8,8,8,17,17,-1,18,21,18,18,18,5,17,-1,-1
             .EVEN 

Do_PlacesExit:         
             Restore_coords                 ; Exit !
             jsr       Exit_display
             Pop       Module
             cmpi.w    #17,Place_nr         ; Inn ?
             bne.s     .Exit
             tst.b     Inn_flag             ; Gonna camp ?
             beq.s     .Exit
             Push      Module,Camp_Mod
.Exit:       jmp       Init_display

Pool_gold_PLACES:      
             suba.l    a0,a0                ; Pool gold
             move.w    Places_gold,d0
             moveq.l   #0,d1
             moveq.l   #-1,d2
             lsr.l     #1,d2
             jsr       Pool_gold
             add.w     d0,Places_gold       ; Add extra gold
             rts       

Divide_gold_PLACES:    
             moveq.l   #0,d0                ; Get number of gold coins
             move.w    Places_gold,d0
             jsr       Divide_gold          ; Divide
             move.w    d0,Places_gold       ; Store remainder
             Wait_4_unclick 
             rts       

Transfer_gold_PLACES:  
             SetMesMin                      112,63,192,Code0001Sys
             movea.l   Off_screen,a6        ; Print message {6,-}
             MesMin    6
             Update_screen 
             Wait_4_unclick 
             moveq.l   #0,d0                ; Set parameters
             move.w    Places_gold,d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TransGoldPLACES_Mod ; Requester
             rts       

TGPLACES_Return:       
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
             move.l    #Do_TGPLACES,TIVS_Ptr      ; Select transfer victim
             lea.l     TIVS2_Mod,a0
             move.w    #25,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       movem.l   (sp)+,d0/d1/a0
             Wait_4_unclick 
             rts       

; [ Transfer the gold ]
;   IN : a0 - Pointer to victim's character data (.l)
Do_TGPLACES: 
             move.l    d0,-(sp)
             move.l    ItemW_nr,d0          ; Transfer gold coins
             add.w     d0,Gold_coins(a0)
             sub.w     d0,Places_gold
             mulu.w    #Gold_weight,d0      ; Adjust weight
             add.l     d0,Weight_normal(a0)
             move.l    (sp)+,d0
             rts       

Places_CIL_evaluate:   
             movem.l   d0/d7/a1/a2,-(sp)
             bclr      #7,6(a0)             ; Enable { Pool gold }
             bclr      #7,7(a0)             ; Enable { Divide gold }
             bclr      #7,8(a0)             ; Enable { Transfer gold }
; ------------- Any gold pooled ? ------------------------------------
             tst.w     Places_gold          ; Well ?
             bne.s     .Ok1
             bset      #7,7(a0)             ; Disable { Divide gold }
             bset      #7,8(a0)             ; Disable { Transfer gold }
; ------------- Any gold carried ? -----------------------------------
.Ok1:        lea.l     Chard_ptrs,a1
             moveq.l   #6-1,d7
.Loop:       tst.l     (a1)                 ; Any character there ?
             beq       .Next
             movea.l   (a1)+,a2             ; Get character data
             move.w    #$0402,d0            ; Normal average person ?
             and.w     Body_conditions(a2),d0
             bne.s     .Next
             tst.w     Gold_coins(a2)       ; Got any dough ?
             bne.s     .Ok2
.Next:       dbra      d7,.Loop
             bset      #7,6(a0)             ; Disable { Pool gold }
.Ok2:        movem.l   (sp)+,d0/d7/a1/a2
             rts       

; [ Update gold display ]
; Changed registers : d0,d1,d2,d7,a0,a3,a6
Display_gold:          
             movem.l   d0-d2/d7/a0/a3/a6,-(sp)
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             move.w    Places_gold,d0       ; Convert gold
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
             movem.l   (sp)+,d0-d2/d7/a0/a3/a6
             rts       

; [ Initialize places display ]
;   IN : a6 - Screen base (.l)
; All registers are restored
Places_DisInit:        
             movem.l   d0-d2/a0,-(sp)
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #-1,d0
             jsr       IG_Set_paper
             movea.l   Event_data_ptr,a0    ; Get pointer to place text
             move.w    6(a0),d0
             subq.w    #1,d0
             mulu.w    #30,d0
             movea.l   Placetext_ptr,a0
             adda.w    d0,a0
             clr.b     29(a0)               ; Watch it!
             moveq.l   #16,d0               ; Print headline
             moveq.l   #39,d1
             move.w    #320,d2
             jsr       Print_centered_string
             move.w    #112,d0              ; Print "GOLD"
             move.w    #113,d1
             move.w    #64,d2
             lea.l     Gold_txt,a0
             jsr       Print_centered_string
             movem.l   (sp)+,d0-d2/a0
             rts       

;*****************************************************************************
; [ Guild place event ]
;*****************************************************************************
Guild_DisUpd:          
             jsr       Update_status_block  ; Update status block
             lea.l     Guild_CIL,a0         ; Update control icons
             lea.l     GuildCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

Guild_DisInit:         
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             lea.l     Guild_CIL,a0         ; Show control icons
             jsr       GuildCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             jsr       Update_guild_messages
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

Update_guild_messages: 
             movem.l   d0/d1/d7/a0-a6,-(sp)
             Push      PA,Lay3_PlusMes+8    ; Start message
             jsr       Init_RText
             movea.l   Current_active_char_data,a2          ; Initialize registers
             movea.l   Placedat_ptr,a4
             lea.l     Class_dat+10,a5
             move.w    Place_nr,d0
             mulu.w    #394,d0
             adda.w    d0,a5
             moveq.l   #0,d0
             move.b    Level_nr(a2),d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a5
             movea.l   Off_screen,a6
             jsr       Erase_text_window    ; Clear text area
; ------------- Print price of joining -------------------------------
             tst.b     Character_class(a2)  ; Any class ?
             bne       .Skip1
             move.w    Place_nr,d0          ; Possible ?
             move.w    Possible_class(a2),d1
             btst      d0,d1
             beq       .Skip1
             move.l    (a5),d0              ; Enough experience ?
             cmp.l     Experience_points(a2),d0
             bgt.s     .Skip1
             lea.l     Code0003Sys,a1       ; Add message
             move.w    #19,d0
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add price of joining
             movea.l   a0,a3
             moveq.l   #0,d0
             move.w    (a4),d0
             moveq.l   #4,d7
             jsr       LConvert_number
             move.b    #" ",(a3)+
             clr.b     (a3)
             jsr       Add_ASCII_2_RText
             lea.l     Gold_txt,a0          ; Add "GOLD"
             jsr       Add_ASCII_2_RText
             lea.l     Return,a0            ; Add 2 carriage returns
             jsr       Add_ASCII_2_RText
             jsr       Add_ASCII_2_RText
; ------------- Print price of making a level ------------------------
.Skip1:      move.w    Place_nr,d0          ; Right guild ?
             cmp.b     Character_class(a2),d0
             bne.s     .Skip2
             cmpi.b    #MaxLevel,Level_nr(a2)     ; Maximum level ?
             bpl.s     .Skip2
             move.l    (a5),d0              ; Enough experience ?
             cmp.l     Experience_points(a2),d0
             bgt.s     .Skip2
             lea.l     Code0003Sys,a1       ; Add message
             move.w    #20,d0
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add price of making
             movea.l   a0,a3
             move.w    2(a4),d0
             moveq.l   #4,d7
             jsr       LConvert_number
             move.b    #" ",(a3)+
             clr.b     (a3)
             jsr       Add_ASCII_2_RText
             lea.l     Gold_txt,a0          ; Add "GOLD"
             jsr       Add_ASCII_2_RText
             lea.l     Return,a0            ; Add 2 carriage returns
             jsr       Add_ASCII_2_RText
             jsr       Add_ASCII_2_RText
; ------------- Print amount of experience points needed -------------
.Skip2:      tst.b     Character_class(a2)  ; Any class ?
             bne       .Class
             move.w    Place_nr,d0          ; Possible to join ?
             move.w    Possible_class(a2),d1
             btst      d0,d1
             bne       .Ok3
             bra       .Skip3
.Class:      move.w    Place_nr,d0          ; Right guild ?
             cmp.b     Character_class(a2),d0
             bne.s     .Skip3
             cmpi.b    #MaxLevel,Level_nr(a2)     ; Maximum level ?
             bpl.s     .Skip3
.Ok3:        move.l    (a5),d1              ; Get needed experience points
             sub.l     Experience_points(a2),d1
             ble.s     .Skip3
             lea.l     Char_name(a2),a0     ; Add name of active character
             jsr       Add_ASCII_2_RText
             lea.l     Space,a0             ; Add space
             jsr       Add_ASCII_2_RText
             lea.l     Code0004Sys,a1       ; Add message
             move.w    #17,d0
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add number of experience
             movea.l   a0,a3                ; points
             move.l    d1,d0
             moveq.l   #4,d7
             jsr       LConvert_number
             jsr       Add_ASCII_2_RText
; ------------- Print message & exit ---------------------------------
.Skip3:      jsr       Erase_text_window    ; Clear window
             jsr       IG_Cursor_home
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d7
             bra.s     .Entry
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry:      dbra      d7,.Loop
             Update_screen 
             jsr       Exit_RText
             Pop       PA
             movem.l   (sp)+,d0/d1/d7/a0-a6
             rts       

GuildCIL_evaluate:     
             movem.l   d0/d1/a1-a3,-(sp)
             bclr      #7,0(a0)             ; Enable {Join Guild}
             bclr      #7,3(a0)             ; Enable {Make Level}
             movea.l   Current_active_char_data,a1
             movea.l   Placedat_ptr,a2
             lea.l     Class_dat+10,a3      ; Get required experience
             move.w    Place_nr,d0
             mulu.w    #394,d0
             adda.w    d0,a3
             moveq.l   #0,d0
             move.b    Level_nr(a1),d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a3
; ------------- Can one join the guild ? -----------------------------
             tst.b     Character_class(a1)  ; Any class ?
             bne.s     .Deac1
             move.w    Places_gold,d0       ; Enough money ?
             cmp.w     (a2),d0
             bmi.s     .Deac1
             move.w    Place_nr,d0          ; Possible ?
             move.w    Possible_class(a1),d1
             btst      d0,d1
             beq.s     .Deac1
             move.l    (a3),d0              ; Enough experience ?
             cmp.l     Experience_points(a1),d0
             ble.s     .Ok1
.Deac1:      bset      #7,0(a0)             ; Disable {Join Guild}
; ------------- Can one make a level ? -------------------------------
.Ok1:        move.w    Place_nr,d0          ; Right guild ?
             cmp.b     Character_class(a1),d0
             bne.s     .Deac2
             move.w    Places_gold,d0       ; Enough money ?
             cmp.w     2(a2),d0
             bmi.s     .Deac2
             cmpi.b    #MaxLevel,Level_nr(a1)     ; Maximum level ?
             bpl.s     .Deac2
             move.l    (a3),d0              ; Enough experience ?
             cmp.l     Experience_points(a1),d0
             ble.s     .Ok2
.Deac2:      bset      #7,3(a0)             ; Disable {Make Level}
.Ok2:        jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d1/a1-a3
             rts       

; ************* Guild - Join guild ***********************************
Join_guild:  
             Wait_4_unclick 
             movea.l   Placedat_ptr,a0      ; Pay for it !
             move.w    (a0),d0
             sub.w     d0,Places_gold
             movea.l   Current_active_char_data,a0          ; Enter guild
             move.w    Place_nr,d0
             move.b    d0,Character_class(a0)
             lea.l     Class_dat,a2         ; Get new skill maxima
             move.w    Place_nr,d0
             mulu.w    #394,d0
             adda.w    d0,a2
             lea.l     Skill_1_max(a0),a1   ; Set skill maxima
             moveq.l   #10-1,d7
.Loop1:      move.b    (a2)+,(a1)+
             dbra      d7,.Loop1
             lea.l     Special_1(a0),a1     ; Set new special values
             lea.l     360(a2),a2
             moveq.l   #11-1,d7
.Loop2:      move.w    (a2)+,(a1)+
             dbra      d7,.Loop2
             move.b    (a2)+,Spell_class_counter(a0)        ; Set spell classes
             jsr       Increase_level       ; Level 1
             rts       

; ************* Guild - Make level ***********************************
Make_level:  
             Wait_4_unclick 
             movea.l   Placedat_ptr,a0      ; Pay for it !
             move.w    2(a0),d0
             sub.w     d0,Places_gold
             movea.l   Current_active_char_data,a0
Increase_level:        
             addq.b    #1,Level_nr(a0)      ; Next level
             moveq.l   #0,d0                ; Adjust attacks per round
             move.b    Level_nr(a0),d0
             move.w    Special_1(a0),d1
             beq.s     .Zero
             divu.w    d1,d0
             move.b    d0,Attacks_per_round(a0)
.Zero:       moveq.l   #0,d0                ; Increase maximum LP
             move.w    Attr_5_normal(a0),d0
             add.w     Attr_5_normal_magic(a0),d0
             divu.w    #10,d0
             add.w     Special_2(a0),d0
             add.w     d0,Life_points_max(a0)
             tst.b     Spell_class_counter(a0)    ; Any spell classes ?
             beq.s     .No_magic
             moveq.l   #0,d0                ; Increase maximum PP
             move.w    Attr_2_normal(a0),d0
             add.w     Attr_2_normal_magic(a0),d0
             divu.w    #20,d0
             move.w    d0,d1
             add.w     Special_3(a0),d0
             add.w     d0,Power_points_max(a0)
             add.w     Special_4(a0),d1     ; Increase SLP
             add.w     d1,Nr_spell_learn_points(a0)
.No_magic:   move.l    #Code0004Sys,Textfile_ptr  ; Print message {18,+}
             PlusMes   18
             Push      Module,SkillW_Mod
             rts       

;*****************************************************************************
; [ Left mouse-button clicked on party member - Guild ]
; All registers are restored
;*****************************************************************************
Guild_Member_left:     
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
             jsr       Update_guild_messages      ; Print messages
.Exit:       rts       

;*****************************************************************************
; [ Skill distribution window ]
; All registers are restored
;*****************************************************************************
SkillW_ModInit:        
; ------------- Open a window ----------------------------------------
             moveq.l   #32,d0
             moveq.l   #37,d1
             moveq.l   #10,d2
             moveq.l   #8,d3
             moveq.l   #2,d4
             moveq.l   #1,d6
             lea.l     SkillW_L1,a0
             jsr       Open_window
             move.w    d0,Window_handle
; ------------- Fill window ------------------------------------------
             movea.l   Off_screen,a6
             move.w    #32+16,d0            ; Clear area
             move.w    #37+16+7,d1
             move.w    d0,d2
             addi.w    #127,d2
             move.w    d1,d3
             addi.w    #70,d3
             moveq.l   #3,d6
             jsr       Draw_box
             moveq.l   #2,d6                ; Display icon
             moveq.l   #16,d7
             move.w    #32+16,d0
             move.w    #37+16+80,d1
             lea.l     Control_icn+7680,a0
             jsr       Blot_unmasked_block
             lea.l     Chequered,a0         ; Overlay chequered icon
             jsr       Blot_masked_block
; ------------- Print character skills -------------------------------
             moveq.l   #-1,d0               ; Set paper
             jsr       IG_Set_paper
             moveq.l   #1,d0                ; Set ink
             jsr       IG_Set_ink
             move.w    #32+16,d0            ; Print "SKILLS"
             move.w    #37+16,d1
             move.w    #128,d2
             jsr       IG_Set_cursor
             lea.l     Skills_name,a0
             jsr       Print_centered_string
             moveq.l   #15,d0               ; Set ink
             jsr       IG_Set_ink
             move.w    #61,d2               ; Initialize registers
             moveq.l   #0,d6
             moveq.l   #2,d7
             movea.l   Current_active_char_data,a1
             lea.l     Class_dat+Class_names+22,a2          ; Get pointer to words
             lea.l     Skill_1(a1),a4
             lea.l     Skill_1_normal_magic(a1),a5
.Loop:       move.w    #48+2,d0             ; Set cursor
             move.w    d2,d1
             jsr       IG_Set_cursor
             move.w    d6,d0                ; Find skill word
             add.w     d0,d0
             move.w    0(a2,d0.w),d0
             jsr       Get_word
             lea.l     Line_buffer,a0       ; Print skill name
             clr.b     7(a0)                ; First 7 characters
             jsr       IG_Print
             move.w    #48+9*6,d0           ; Set cursor
             move.w    d2,d1
             jsr       IG_Set_cursor
             lea.l     Skill_txt,a3         ; Initialize registers
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
             jsr       IG_Carriage_return   ; Next skill
             addq.w    #7,d2
             addq.w    #1,d6
             cmpi.w    #10,d6
             bmi.s     .Loop
             Update_screen 
             .LOCAL 
; ------------- Initialize variables ---------------------------------
             move.w    #10,Remaining_offset
             lea.l     Make_level_offsets,a0
             clr.l     (a0)+
             clr.l     (a0)+
             clr.w     (a0)
             movea.l   Current_active_char_data,a0
             lea.l     Skill_1(a0),a0
             lea.l     Possible_level_offsets,a1
             moveq.l   #10-1,d7
.Loop:       move.b    10(a0),d0            ; Get maximum - normal
             sub.b     (a0)+,d0
             move.b    d0,(a1)+
             dbra      d7,.Loop
             move.w    -(a1),d0             ; Deactivate exit icon
             .REPT 4
             or.w      -(a1),d0
             .ENDR 
             seq       Exit_on
             rts       

SkillW_ModExit:        
             move.w    Window_handle,d0
             jsr       Close_window
             rts       

SkillW_DisUpd:         
             moveq.l   #6,d0                ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #3,d0
             jsr       IG_Set_paper
             move.w    #154,d2              ; Initialize registers
             move.w    #37+24,d3
             moveq.l   #10-1,d6
             moveq.l   #2,d7
             lea.l     Make_level_txt,a0
             lea.l     Make_level_offsets,a1
             movea.l   Off_screen,a6
.Loop:       move.w    d2,d0                ; Set cursor
             move.w    d3,d1
             jsr       IG_Set_cursor
             moveq.l   #0,d0                ; Convert & print offset
             move.b    (a1)+,d0
             moveq.l   #"0",d1
             movea.l   a0,a3
             jsr       RConvert_number
             jsr       IG_Print
             addq.w    #7,d3                ; Next offset
             dbra      d6,.Loop
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             move.w    #96,d0               ; Set cursor
             move.w    #137,d1
             jsr       IG_Set_cursor
             move.w    Remaining_offset,d0  ; Convert & print remaining
             moveq.l   #"0",d1              ; offset
             lea.l     Bonus_txt,a0
             lea.l     8(a0),a3
             jsr       RConvert_number
             jsr       IG_Print
             rts       

Inc_skill:   tst.w     Remaining_offset     ; Any offset remaining ?
             beq       .Exit
             lsr.w     #8,d0
             lea.l     Possible_level_offsets-1,a1          ; Check possible offset
             adda.w    d0,a1
             tst.b     (a1)                 ; Not possible ?
             beq       .Exit
             movea.l   Current_active_char_data,a0          ; Increase skill
             lea.l     Skill_1-1(a0),a0
             addq.b    #1,0(a0,d0.w)
             jsr       Reprint_skill
             lea.l     Make_level_offsets-1,a0    ; Increase offset
             adda.w    d0,a0
             addq.b    #1,(a0)
             subq.w    #1,Remaining_offset  ; Less remaining
             subq.b    #1,(a1)              ; Decrease possible offset
             bne.s     .Ok
             lea.l     Possible_level_offsets,a0  ; None other possible ?
             move.w    (a0)+,d0
             .REPT 4
             or.w      (a0)+,d0
             .ENDR 
             beq.s     .Done
.Ok:         tst.w     Remaining_offset     ; None left ?
             bne.s     .Exit
.Done:       moveq.l   #2,d6                ; Display icon
             moveq.l   #16,d7
             move.w    #32+16,d0
             move.w    #37+16+80,d1
             lea.l     Control_icn+7680,a0
             movea.l   Off_screen,a6
             jsr       Blot_unmasked_block
             Update_screen 
             st        Exit_on              ; You can go now
.Exit:       rts       

Dec_skill:   lea.l     Make_level_offsets-1,a0    ; Get offset
             lsr.w     #8,d0
             adda.w    d0,a0
             tst.b     (a0)                 ; Offset already zero ?
             beq.s     .Exit
             movea.l   Current_active_char_data,a1
             lea.l     Skill_1-1(a1),a1     ; Get normal skill
             adda.w    d0,a1
             tst.b     (a1)                 ; Already zero ?
             beq.s     .Exit
             subq.b    #1,(a1)              ; Decrease skill
             jsr       Reprint_skill
             subq.b    #1,(a0)              ; Decrease offset
             lea.l     Possible_level_offsets-1,a0          ; Increase possible offset
             adda.w    d0,a0
             addq.b    #1,(a0)
             tst.w     Remaining_offset     ; Any remaining ?
             bne.s     .Skip
             moveq.l   #2,d6                ; Overlay chequered icon
             moveq.l   #16,d7
             move.w    #32+16,d0
             move.w    #37+16+80,d1
             lea.l     Chequered,a0
             movea.l   Off_screen,a6
             jsr       Blot_masked_block
             Update_screen 
             sf        Exit_on              ; No exit
.Skip:       addq.w    #1,Remaining_offset  ; More remaining
.Exit:       rts       

; [ Reprint skill ]
;   d0 - Skill number {1...10} (.w)
; All registers are restored
Reprint_skill:         
             movem.l   d0-d2/d6/d7/a0-a3/a6,-(sp)
             move.w    d0,d2
             movea.l   Off_screen,a6
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #3,d0
             jsr       IG_Set_paper
             move.w    #48+9*6,d0           ; Set cursor
             move.w    d2,d1
             mulu.w    #7,d1
             addi.w    #61-7,d1
             jsr       IG_Set_cursor
             movea.l   Current_active_char_data,a1          ; Calculate pointers
             lea.l     Skill_1_normal_magic(a1),a2
             lea.l     Skill_1-1(a1),a1
             adda.w    d2,a1
             adda.w    d2,a2
             adda.w    d2,a2
             lea.l     Skill_txt,a3         ; Initialize registers
             moveq.l   #"0",d1
             moveq.l   #2,d7
             moveq.l   #0,d0                ; Convert normal skill
             move.b    (a1),d0
             add.w     (a2),d0
             jsr       RConvert_number
             addq.l    #2,a3
             moveq.l   #0,d0                ; Convert maximum skill
             move.b    10(a1),d0
             jsr       RConvert_number
             lea.l     Skill_txt,a0         ; Print skill levels
             jsr       IG_Print
             Update_screen 
             movem.l   (sp)+,d0-d2/d6/d7/a0-a3/a6
             rts       

Exit_SkillW: tst.b     Exit_on              ; Allowed to leave ?
             beq       .Exit
             Pop       Module               ; Yes !
             Wait_4_unclick 
             movea.l   Current_active_char_data,a2
             Push      PA,Lay3_PlusMes+8    ; Start message
             jsr       Init_RText
             lea.l     Char_name(a2),a0     ; Add character name
             jsr       Add_ASCII_2_RText
             lea.l     Space,a0             ; Add space
             jsr       Add_ASCII_2_RText
             lea.l     Code0004Sys,a1       ; Add message
             moveq.l   #19,d0
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add level number
             movea.l   a0,a3
             moveq.l   #0,d0
             move.b    Level_nr(a2),d0
             moveq.l   #2,d7
             jsr       LConvert_number
             move.b    #" ",(a3)+
             clr.b     (a3)
             jsr       Add_ASCII_2_RText
             moveq.l   #20,d0               ; Add message
             jsr       Add_encoded_2_RText
             lea.l     Return,a0            ; Add a carriage return
             jsr       Add_ASCII_2_RText
             moveq.l   #21,d0               ; Add message
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add maximum LP
             movea.l   a0,a3
             move.w    Life_points_max(a2),d0
             add.w     Life_points_max_magic(a2),d0
             moveq.l   #3,d7
             jsr       LConvert_number
             jsr       Add_ASCII_2_RText
             tst.b     Spell_class_counter(a2)    ; Any magic ?
             beq       .No_magic
             lea.l     Return,a0            ; Add a carriage return
             jsr       Add_ASCII_2_RText
             moveq.l   #22,d0               ; Add message
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add maximum PP
             movea.l   a0,a3
             move.w    Power_points_max(a2),d0
             add.w     Power_points_max_magic(a2),d0
             moveq.l   #3,d7
             jsr       LConvert_number
             jsr       Add_ASCII_2_RText
             lea.l     Return,a0            ; Add a carriage return
             jsr       Add_ASCII_2_RText
             moveq.l   #23,d0               ; Add message
             jsr       Add_encoded_2_RText
             lea.l     Number_buffer,a0     ; Add SLP
             movea.l   a0,a3
             move.w    Nr_spell_learn_points(a2),d0
             moveq.l   #3,d7
             jsr       LConvert_number
             jsr       Add_ASCII_2_RText
.No_magic:   jsr       Erase_text_window    ; Clear window
             jsr       IG_Cursor_home
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d7
             bra.s     .Entry
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry:      dbra      d7,.Loop
             Update_screen                  ; Wait for user
             jsr       Wait_4_user
             jsr       Exit_RText
             Pop       PA
             jsr       Update_guild_messages      ; Update messages
.Exit:       rts       

;*****************************************************************************
; [ Object merchant ]
;*****************************************************************************
MerchOBJC_DisUpd:      
             jsr       Update_status_block  ; Update status block
             lea.l     MOBJC_CIL,a0         ; Update control icons
             lea.l     MOBJCCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             jsr       Update_quantity_colours
             rts       

MerchOBJC_DisInit:     
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             move.l    #Code0002Sys,Textfile_ptr
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             lea.l     MOBJC_CIL,a0         ; Show control icons
             jsr       MOBJCCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MOBJCCIL_evaluate:     
             movem.l   d0/d7/a1,-(sp)
             bclr      #7,(a0)              ; Enable {Buy item}
             bclr      #7,3(a0)             ; Enable {Sell item}
             bclr      #7,4(a0)             ; Enable {View item}
             bclr      #7,5(a0)             ; Enable {Transfer item}
; ------------- Can one view an object ? -----------------------------
             movea.l   Warecount_ptr,a1     ; Anything ?
             move.l    (a1)+,d0
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             bne.s     .Ok
             bset      #7,4(a0)             ; Disable {View item}
; ------------- Can one sell an object ? -----------------------------
.Ok:         movea.l   Current_active_char_data,a1
             lea.l     Inventory_1_place_counter(a1),a1
             move.b    (a1)+,d0             ; Anything in backpack ?
             moveq.l   #11-1,d7
.Loop1:      or.b      (a1)+,d0
             dbra      d7,.Loop1
             tst.b     d0                   ; Well ?
             bne.s     .Not_empty1
             bset      #7,3(a0)             ; Disable {Sell item}
; ------------- Can one buy an object ? ------------------------------
.Not_empty1: tst.w     Places_gold          ; Any gold ?
             beq.s     .Deac
             movea.l   Warecount_ptr,a1
             move.l    (a1)+,d0             ; Anything ?
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             beq.s     .Deac
             lea.l     Sold_slots,a1        ; Any slot free ?
             move.b    (a1)+,d0
             moveq.l   #11-1,d7
.Loop2:      and.b     (a1)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Well ?
             beq.s     .Not_empty2
.Deac:       bset      #7,(a0)              ; Disable {Buy item}
; ------------- Can one transfer an object ? -------------------------
.Not_empty2: lea.l     Sold_slots,a1
             move.l    (a1)+,d0             ; Anything ?
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             bne.s     .Not_empty3
             bset      #7,5(a0)             ; Disable {Transfer item}
.Not_empty3: jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d7/a1
             rts       

; ************* Object merchant - View item ***************
View_item_MOBJC:       
             Wait_4_unclick 
             lea.l     ViewItemMOBJC_Mod,a0
             jmp       Push_Module

ViewItemMOBJC_DisInit: 
             move.l    #Lay3_PlusMes,PlusMes_info
             Push      PA,Lay3_PA
             Push      MA,L3_objects_area
             move.l    Waredat_ptr,Itemdata_ptr   ; Set object data
             move.l    Warecount_ptr,Itemslots_ptr
             movea.l   Off_screen,a6
             movea.l   Textfile_ptr,a0      ; Print message {21,#}
             move.l    #Code0001Sys,Textfile_ptr
             HashMes   3
             move.l    a0,Textfile_ptr
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

; [ Player has selected object ]
;   IN : d0 - Slot number (.w)
; No registers are restored
ViewItem_objselect:    
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq.s     .Exit
             ext.w     d0
             movea.l   Itemslots_ptr,a0     ; Get slot address
             adda.w    d0,a0
             tst.b     -1(a0)               ; Anything in this slot ?
             beq.s     .Exit
             move.b    d0,Object_slot_number      ; Open item view window
             Push      Module,ItemView1_Mod
.Exit:       rts       

; ************* Object merchant - Sell item ***************
Sell_item:   
             Wait_4_unclick 
             lea.l     SellItem_Mod,a0
             jmp       Push_Module

SellItem_DisInit:      
             SetMesMin                      112,66,192,Code0002Sys
             move.l    #Lay3_PlusMes,PlusMes_info
             Push      PA,Lay3_PA
             Push      MA,L3_objects_area
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inventory_1_place_counter(a0),a1
             lea.l     Inv_data+360(a0),a0
             move.l    a0,Itemdata_ptr
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             HashMes   12                   ; Print message {12,#}
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

SellItem_DisExit:      
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3
             jsr       Erase_text_window
             Update_screen 
             Pop       PA
             Pop       MA
             rts       

SellItem_DisUpd:       
             jsr       Update_status_block
             jsr       Update_quantity_colours
             jsr       Display_gold
             rts       

; [ Player has selected object ]
;   IN : d0 - Slot number (.w)
; No registers are restored
SellItem_objselect:    
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
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     .Exit
             btst      #1,Item_stat_bits(a2)      ; Can it be sold ?
             beq.s     .Exit
             cmpi.w    #2,Price(a2)         ; Too cheap ?
             bmi.s     .Exit
             btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .Single
             cmpi.b    #1,(a1)              ; More as one ?
             bhi.s     .Multiple
.Single:     move.l    #1,ItemW_nr          ; One item
             Push      Module,SellReq_Mod
             rts       
.Multiple:   moveq.l   #0,d0                ; Set parameters
             move.b    (a1),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,SellMItem_Mod ; Requester
.Exit:       rts       

;*****************************************************************************
; [ Sell Multiple Item window module ]
;*****************************************************************************
SellMItem_DisInit:     
             movem.l   d0/d1/a0-a2/a6,-(sp)
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit        ; Make window
             movea.l   Itemslots_ptr,a1     ; Initialize registers
             movea.l   Itemdata_ptr,a2
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             movea.l   Off_screen,a6
             move.b    (a2),d0              ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             move.w    Name_word_nr(a2),d0  ; Print name of item
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             move.w    #32+17,d0            ; Set cursor
             move.w    #80+38+32,d1
             jsr       IG_Set_cursor
             moveq.l   #15,d0               ; Convert & print text
             lea.l     Code0002Sys,a1
             jsr       Convert_text_line
             lea.l     Line_buffer,a0
             jsr       IG_Print
             Update_screen 
             movem.l   (sp)+,d0/d1/a0-a2/a6
             rts       

; [ Player has entered how many items he wants to sell ]
; No registers are restored
SellMItem_Return:      
             tst.l     ItemW_nr             ; Any items ?
             bne.s     .Go_on
             Wait_4_unclick                 ; No, exit
             rts       
.Go_on:      Push      Module,SellReq_Mod
             rts       

;*****************************************************************************
; [ Sell item requester ]
;*****************************************************************************
SellReq_ModInit:       
             move.l    ItemW_nr,d6          ; Get number of objects
             movea.l   Itemdata_ptr,a1      ; Get pointer to item data
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #40,d0
             adda.w    d0,a1
             movea.l   Off_screen,a6
             Push      PA,Lay3_PA           ; Initialize text window
             jsr       Erase_text_window
             move.w    Name_word_nr(a1),d0  ; Print name of item
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             cmpi.w    #1,d6                ; More as one item ?
             beq.s     .Single
             lea.l     Multi_txt,a0         ; Print " x "
             jsr       IG_Print
             move.w    d6,d0                ; Convert number
             moveq.l   #2,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print it
.Single:     jsr       IG_Carriage_return
             move.l    a1,-(sp)             ; Print message {14}
             moveq.l   #14,d0
             lea.l     Code0002Sys,a1
             jsr       Convert_text_line
             movea.l   (sp)+,a1
             lea       Line_buffer,a0
             jsr       IG_Print
             jsr       IG_Carriage_return
             moveq.l   #0,d1                ; Get price
             move.w    Price(a1),d1
             divu.w    #3,d1                ; Calculate selling price
             movea.l   Current_active_char_data,a2
             moveq.l   #0,d2
             move.w    Attr_6_normal(a2),d2
             add.w     Attr_6_normal_magic(a2),d2
             divu.w    #10,d2
             mulu.w    Price(a1),d2
             divu.w    #100,d2
             add.l     d2,d1
             mulu.w    d6,d1                ; Calculate total price
             move.w    d1,Total_price
             move.l    d1,d0                ; Convert number
             moveq.l   #5,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add extra space
             clr.b     (a3)
             jsr       IG_Print             ; Print it
             lea.l     Gold_txt,a0          ; Print "GOLD"
             jsr       IG_Print
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #240,d0              ; Yes icon
             move.w    #81,d1
             lea.l     Control_icn+6912,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; No icon
             lea.l     Control_icn+7168,a0
             jsr       Blot_unmasked_block
             Update_screen 
             lea.l     SellReq_L2,a0        ; Object branch
             jsr       Set_layout_data
             Push      MA,Lay3_PlusMes      ; Install stuff
             rts       

SellReq_ModExit:       
             movea.l   Off_screen,a6        ; Erase text window
             jsr       Erase_text_window
             Update_screen 
             Pop       MA
             Pop       PA
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             Wait_4_unclick 
; ------------- All items sold ? -------------------------------------
             movea.l   Itemslots_ptr,a0     ; Check it out
             move.b    (a0)+,d0
             moveq.l   #11-1,d7
.Loop:       or.b      (a0)+,d0
             dbra      d7,.Loop
             tst.b     d0                   ; Well ?
             bne.s     .Exit
             Pop       Module               ; Yeah
.Exit:       rts       

; [ Player wants to sell ]
SellYes:     
             Wait_4_unclick 
             movea.l   Itemslots_ptr,a0     ; Get pointer to item slot
             movea.l   Itemdata_ptr,a1      ; & item data
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a0
             mulu.w    #40,d0
             adda.w    d0,a1
             movea.l   Current_active_char_data,a2
             move.l    ItemW_nr,d0          ; Get number of objects
             sub.b     d0,(a0)              ; Remove objects
             mulu.w    Weight(a1),d0        ; Remove weight
             sub.l     d0,Weight_normal(a2)
             move.w    Total_price,d0       ; Add gold
             add.w     d0,Places_gold
             movea.l   Off_screen,a6        ; Redraw objects
             jsr       Show_objects_LAY3
             Update_screen 
             jmp       Pop_Module

; ************* Object merchant - Buy item ****************
Buy_item:    
             Wait_4_unclick 
             lea.l     BuyItem_Mod,a0
             jmp       Push_Module

BuyItem_DisInit:       
             SetMesMin                      112,66,192,Code0003Sys
             move.l    #Lay3_PlusMes,PlusMes_info
             Push      PA,Lay3_PA
             Push      MA,L3_objects_area
             move.l    Waredat_ptr,Itemdata_ptr   ; Set object data
             move.l    Warecount_ptr,Itemslots_ptr
             movea.l   Off_screen,a6
             HashMes   21                   ; Print message {21,#}
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             rts       

BuyItem_DisExit:       
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3
             jsr       Erase_text_window
             Update_screen 
             Pop       PA
             Pop       MA
             rts       

; [ Player has selected object ]
;   IN : d0 - Slot number (.w)
; No registers are restored
; NOTE : This routine has three exit points !!!
BuyItem_objselect:     
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             beq       .Exit
             move.b    d0,Object_slot_number
             ext.w     d0                   ; Calculate pointers to item
             subq.w    #1,d0                ; data
             movea.l   Itemslots_ptr,a1
             movea.l   Itemdata_ptr,a2
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     .Exit
             move.w    Total_price,d1       ; Enough dough ?
             cmp.w     Places_gold,d1
             bgt.s     .Exit
             btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .One
             cmpi.b    #1,(a1)              ; Only one item ?
             bne.s     .Multiple
.One:        move.l    #1,ItemW_nr          ; One item
             Push      Module,BuyReq_Mod
             rts       
.Multiple:   moveq.l   #0,d1                ; How many can you buy ?
             move.w    Places_gold,d1
             divu.w    Total_price,d1
             cmpi.w    #1,d1                ; Only one ?
             beq.s     .One
             cmpi.w    #100,d1              ; Too much ?
             bmi.s     .Not2much
             moveq.l   #99,d1
.Not2much:   ext.l     d1                   ; How many do you want ?
             move.l    d1,Original_number
             clr.l     ItemW_nr
             Push      Module,BuyMItem_Mod
.Exit:       rts       

;*****************************************************************************
; [ Buy Multiple Item window module ]
;*****************************************************************************
BuyMItem_DisInit:      
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit        ; Make window
             movea.l   Itemslots_ptr,a1     ; Initialize registers
             movea.l   Itemdata_ptr,a2
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             movea.l   Off_screen,a6
             move.b    (a2),d0              ; Display object icon
             moveq.l   #0,d1
             jsr       INV2_Show_object
             move.w    #49+18,d0            ; Set cursor
             move.w    #80+18+32,d1
             jsr       IG_Set_cursor
             move.w    Name_word_nr(a2),d0  ; Print name of item
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             move.w    #32+17,d0            ; Set cursor
             move.w    #80+38+32,d1
             jsr       IG_Set_cursor
             moveq.l   #22,d0               ; Convert & print text
             lea.l     Code0003Sys,a1
             jsr       Convert_text_line
             lea.l     Line_buffer,a0
             jsr       IG_Print
             Update_screen 
             rts       

; [ Player has entered how many items he wants to buy ]
; No registers are restored
BuyMItem_Return:       
             tst.l     ItemW_nr             ; Any items ?
             bne.s     .Go_on
             Wait_4_unclick                 ; No, exit
             jmp       Pop_Module
.Go_on:      Push      Module,BuyReq_Mod    ; Are you sure ?
.Exit:       rts       

;*****************************************************************************
; [ Buy item requester ]
;*****************************************************************************
BuyReq_ModInit:        
             movea.l   Off_screen,a6
             Push      PA,Lay3_PA           ; Initialize text window
             jsr       Erase_text_window
             movea.l   Itemdata_ptr,a1      ; Get pointer to item data
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #40,d0
             adda.w    d0,a1
             move.w    Name_word_nr(a1),d0  ; Print name of item
             jsr       Get_word
             lea.l     Line_buffer,a0
             jsr       IG_Print
             move.l    ItemW_nr,d6          ; Get number of items
             cmpi.w    #1,d6                ; More than one ?
             beq.s     .Single
             lea.l     Multi_txt,a0         ; Print " x "
             jsr       IG_Print
             move.w    d6,d0                ; Convert number
             moveq.l   #2,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print it
.Single:     jsr       IG_Carriage_return
             moveq.l   #23,d0               ; Print message {23}
             lea.l     Code0003Sys,a1
             jsr       Convert_text_line
             lea       Line_buffer,a0
             jsr       IG_Print
             jsr       IG_Carriage_return
             move.w    Total_price,d0       ; Calculate total price
             mulu.w    d6,d0
             moveq.l   #5,d7                ; Convert number
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add extra space
             clr.b     (a3)
             jsr       IG_Print             ; Print it
             lea.l     Gold_txt,a0          ; Print "GOLD"
             jsr       IG_Print
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #240,d0              ; Yes icon
             move.w    #81,d1
             lea.l     Control_icn+6912,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; No icon
             lea.l     Control_icn+7168,a0
             jsr       Blot_unmasked_block
             Update_screen 
             lea.l     SellReq_L2,a0        ; Object branch
             jsr       Set_layout_data
             Push      MA,Lay3_PlusMes      ; Install stuff
             rts       

BuyReq_ModExit:        
             movea.l   Off_screen,a6        ; Erase text window
             jsr       Erase_text_window
             Update_screen 
             Pop       MA
             Pop       PA
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             Wait_4_unclick 
; ------------- All bought ? -----------------------------------------
             movea.l   Warecount_ptr,a0     ; Check it out
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             Pop       Module               ; Yeah
.Exit:       rts       

; [ Player wants to buy ]
BuyYes:      
             Wait_4_unclick 
             movea.l   Itemslots_ptr,a0     ; Get pointer to item slot
             movea.l   Itemdata_ptr,a1      ; & item data
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a0
             mulu.w    #40,d0
             adda.w    d0,a1
             moveq.l   #1,d1
             btst      #2,Item_stat_bits(a1)      ; Multiple item ?
             beq       .Continue
             cmpi.b    #1,(a0)              ; More as one in slot ?
             bhi.s     .Multiple
             move.l    d1,ItemW_nr
; ------------- Search for a slot already containing this item -------
.Multiple:   lea.l     Sold_slots,a4
             lea.l     Sold_data,a5
             move.w    Item_ID(a1),d0
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
             cmpi.b    #-1,(a0)             ; Infinite slot ?
             beq       .Multiple
             sub.b     d2,(a0)              ; Remove item(s)
             bra       .Multiple
; ------------- Search for a free slot then transfer the item --------
.Continue:   lea.l     Sold_slots,a4
             lea.l     Sold_data,a5
             moveq.l   #12-1,d7
.Loop2:      tst.b     (a4)                 ; Free slot ?
             beq.s     .Do_it
             addq.l    #1,a4                ; Next slot
             lea.l     40(a5),a5
             dbra      d7,.Loop2
             bra       .Exit
.Do_it:      add.b     d1,(a4)              ; Fill slot
             moveq.l   #20-1,d7             ; Copy item data
.Loop3:      move.w    (a1)+,(a5)+
             dbra      d7,.Loop3
             lea.l     -40(a1),a1
             cmpi.b    #-1,(a0)             ; Infinite slot ?
             beq.s     .Infinity
             sub.b     d1,(a0)              ; Remove item(s)
.Infinity:   move.l    ItemW_nr,d0          ; Pay the price
             mulu.w    Total_price,d0
             sub.w     d0,Places_gold
             movea.l   Off_screen,a6        ; Redraw objects
             jsr       Show_objects_LAY3
             Update_screen 
.Exit:       jmp       Pop_Module

; ************* Object merchant - Transfer item ***********
Transfer_item_MOBJC:   
             lea.l     TIMOBJC_Mod,a0
             jmp       Push_Module

TIMOBJC_DisInit:       
             movem.l   d0/a6,-(sp)
             SetMesMin                      112,66,192,Code0001Sys
             Push      MA,Lay3_L2           ; Mouse in object area
             movea.l   Off_screen,a6        ; Print message {4,-}
             MesMin    4
             Update_screen 
             Wait_4_unclick 
             movem.l   (sp)+,d0/a6
             rts       

Do_TIMOBJC:  
             Wait_4_unclick 
             tst.b     d0                   ; Any slot selected ?
             bne.s     .A_slot
.Exit:       jmp       Pop_Module
.A_slot:     move.b    d0,Object_slot_number
             lea.l     Sold_slots,a1
             lea.l     Sold_data,a2
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a1
             mulu.w    #40,d0
             adda.w    d0,a2
             tst.b     (a1)                 ; Any object in this slot ?
             beq.s     .Exit
             .LOCAL 
; ------------- Do the transfer --------------------------------------
             moveq.l   #-1,d1               ; Default non-multiple
             btst      #2,Item_stat_bits(a2)      ; Multiple item ?
             beq.s     .Single
             cmpi.b    #1,(a1)              ; More as one ?
             bhi.s     .Multiple
             move.w    Item_ID(a2),d1
.Single:     moveq.l   #0,d0                ; Get parameters
             move.w    Weight(a2),d0
             moveq.l   #1,d2
             jmp       MOBJC_TI_2
.Multiple:   moveq.l   #0,d0                ; Set parameters
             move.b    (a1),d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TMI_MOBJC_Mod ; Requester
             rts       

;*****************************************************************************
; [ Transfer Multiple Item window module ]
;*****************************************************************************
TMI_MOBJC_DisInit:     
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
             lea.l     Sold_slots-1,a2
             lea.l     Sold_data-40,a3
             adda.w    d0,a2
             mulu.w    #40,d0
             adda.w    d0,a3
             movea.l   Off_screen,a6
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

TMI_MOBJC_Return:      
             lea.l     Sold_data-40,a0      ; Get pointer to object data
             move.b    Object_slot_number,d0
             ext.w     d0
             mulu.w    #40,d0
             adda.w    d0,a0
             move.l    ItemW_nr,d0          ; Get parameters
             bne.s     .Not_zero
             jmp       Pop_Module
.Not_zero:   mulu.w    Weight(a0),d0
             move.w    Item_ID(a0),d1
; WATCH IT !!! ROUTINE CONTINUES !!!

;*****************************************************************************
; [ Transfer Item - part II ]
;   IN : d0 - Weight of transferred object(s) (.l)
;        d1 - Object ID / -1  when not multiple item (.w)
; No registers are restored
;*****************************************************************************
MOBJC_TI_2:  
             suba.l    a0,a0                ; Scan for victims
             jsr       Scan_4_transfer_victims
             bne.s     .Go                  ; Anyone interested ?
             PlusMes   5                    ; No, print message {5,+}
             Pop       Module
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             lea.l     Sold_data,a0         ; Select transfer victim
             move.b    Object_slot_number,d0
             ext.w     d0
             mulu.w    #40,d0
             move.b    -40(a0,d0.w),TIVS_Icon_nr
             move.l    #MOBJC_TI_3,TIVS_Ptr
             lea.l     TIVS2_Mod,a0
             move.w    #24,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       rts       

;*****************************************************************************
; [ Transfer Item - part III ]
;   IN : a0 - Pointer to victim's character data (.l)
; No registers are restored
;*****************************************************************************
MOBJC_TI_3:  
             lea.l     Sold_slots-1,a2      ; Initialize registers
             lea.l     Sold_data-40,a3
             move.b    Object_slot_number,d0
             ext.w     d0
             adda.w    d0,a2
             mulu.w    #40,d0
             adda.w    d0,a3

; ------------- REGISTER CONTENTS ------------------------------------
;  a0 - Pointer to victim's character data (.l)
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
             add.b     d1,(a4)              ; Fill slot
             moveq.l   #20-1,d7             ; Copy item data
.Loop3:      move.w    (a3)+,(a5)+
             dbra      d7,.Loop3
             lea.l     -40(a3),a3
             sub.b     d1,(a2)              ; Remove item(s)
             bne.s     .Skip
             lea.l     Door_object_pos_list-4,a0  ; Erase object icon
             moveq.l   #0,d0
             move.b    Object_slot_number,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a0
             move.w    (a0)+,d0
             move.w    (a0)+,d1
             lea.l     Layout_icn+9856,a0
             movea.l   Off_screen,a6
             jsr       Put_unmasked_block
             Update_screen 
             bra.s     .Go_on
.Skip:       cmpi.b    #1,(a2)              ; Remove quantity ?
             bne.s     .Go_on
             lea.l     Door_object_pos_list-4,a0  ; Erase object icon
             moveq.l   #0,d0
             move.b    Object_slot_number,d0
             add.w     d0,d0
             add.w     d0,d0
             adda.w    d0,a0
             move.w    (a0)+,d0
             move.w    (a0)+,d1
             lea.l     Layout_icn+9856,a0
             movea.l   Off_screen,a6
             jsr       Put_unmasked_block
             lea.l     Objects_icn,a0       ; Redraw object icon
             moveq.l   #0,d2
             move.b    (a3),d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block
             Update_screen 
.Go_on:      lea.l     Sold_slots,a0        ; All transferred ?
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             tst.l     (a0)+
             bne.s     .Exit
             Pop       Module
.Exit:       rts       

;*****************************************************************************
; [ Display name + message - Sell item ]
; Changed registers : d0,d1,d2,a0,a1,a6
;*****************************************************************************
Show3_object_name:     
             tst.b     d0                   ; Any object selected ?
             beq       .Exit
             movea.l   Itemdata_ptr,a0
             movea.l   Itemslots_ptr,a1
             ext.w     d0                   ; Any object there ?
             tst.b     -1(a1,d0.w)
             beq       .Exit
             mulu.w    #40,d0               ; Get item data
             lea.l     -40(a0,d0.w),a0
             cmpi.b    #17,Item_type(a0)    ; Is it a monster item ?
             beq.s     .Exit
             move.w    Name_word_nr(a0),d0  ; Get number of word
             cmp.w     Object_name_nr,d0    ; Already printed ?
             beq       .Exit
             move.w    d0,Object_name_nr
             btst      #1,Item_stat_bits(a0)      ; Can it be sold ?
             beq.s     .No_sell
             moveq.l   #0,d1                ; Get price
             move.w    Price(a0),d1
             cmpi.w    #2,d1                ; Too cheap ?
             bpl.s     .Go_on
.No_sell:    movea.l   Off_screen,a6        ; I don't want that junk!
             MesMin    13
             Update_screen 
.Go_on:      move.b    #2,Print_objname_flag      ; Print
.Exit:       rts       

Upd3_objname_erase:    
             tst.b     Erase_objname_flag   ; Erase anything ?
             beq       .Exit
             movea.l   Off_screen,a6        ; Erase message
             jsr       Erase_message_minus
             move.w    #112,d0              ; Erase text
             move.w    #73,d1
             move.w    #112+192-1,d2
             move.w    #73+6,d3
             move.w    #2,d6
             jsr       Draw_box
             subq.b    #1,Erase_objname_flag      ; Count down
             clr.w     Object_name_nr
.Exit:       rts       

;*****************************************************************************
; [ Display name + message - Buy item ]
; Changed registers : d0,d1,d2,a0,a1,a2,a6
;*****************************************************************************
Show4_object_name:     
             tst.b     d0                   ; Any object selected ?
             beq       .Exit
             movea.l   Itemdata_ptr,a0
             movea.l   Itemslots_ptr,a1
             ext.w     d0                   ; Any object there ?
             tst.b     -1(a1,d0.w)
             beq       .Exit
             mulu.w    #40,d0               ; Get item data
             lea.l     -40(a0,d0.w),a0
             move.w    Name_word_nr(a0),d0  ; Get number of word
             cmp.w     Object_name_nr,d0    ; Already printed ?
             beq       .Exit
             move.w    d0,Object_name_nr
             moveq.l   #0,d1                ; Calculate price
             move.w    Price(a0),d1
             movea.l   Current_active_char_data,a2
             moveq.l   #0,d2
             move.w    Attr_6_normal(a2),d2
             add.w     Attr_6_normal_magic(a2),d2
             divu.w    #10,d2
             mulu.w    Price(a0),d2
             divu.w    #100,d2
             sub.l     d2,d1
             move.w    d1,Total_price       ; Store
             cmp.w     Places_gold,d1       ; Enough dough ?
             bls.s     .Go_on
             movea.l   Off_screen,a6        ; You can't afford it !
             MesMin    24
             Update_screen 
.Go_on:      move.b    #2,Print_objname_flag      ; Print
.Exit:       rts       

Upd4_objname_print:    
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
             move.w    #73+14,d3
             move.w    #2,d6
             movea.l   Off_screen,a6
             jsr       Draw_box
             move.w    #192,d2              ; Print word
             lea.l     Line_buffer,a0
             jsr       Print_centered_string
             moveq.l   #0,d0                ; Convert price
             move.w    Total_price,d0
             moveq.l   #5,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.w    #112,d0              ; Print price
             move.w    #73+7,d1
             move.w    #192,d2
             jsr       Print_centered_string
             subq.b    #1,Print_objname_flag      ; Count down
.Exit:       rts       

.Init_string:          .DC.b 1,15,2,-1,0
             .EVEN 

Upd4_objname_erase:    
             tst.b     Erase_objname_flag   ; Erase anything ?
             beq       .Exit
             movea.l   Off_screen,a6        ; Erase message
             jsr       Erase_message_minus
             move.w    #112,d0              ; Erase text
             move.w    #73,d1
             move.w    #112+192-1,d2
             move.w    #73+14,d3
             move.w    #2,d6
             jsr       Draw_box
             subq.b    #1,Erase_objname_flag      ; Count down
             clr.w     Object_name_nr
.Exit:       rts       

;*****************************************************************************
; [ Food merchant event ]
;*****************************************************************************
MerchFOOD_DisUpd:      
             jsr       Update_status_block  ; Update status block
             lea.l     MFOOD_CIL,a0         ; Update control icons
             lea.l     MFOODCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             move.w    Places_food,d0       ; Update food
             moveq.l   #"0",d1
             moveq.l   #4,d7
             lea.l     GoldDis_text+1,a0
             movea.l   a0,a3
             jsr       RConvert_number
             move.w    #240,d0              ; Print food
             move.w    #113+8,d1
             move.w    #64,d2
             movea.l   Off_screen,a6
             jsr       Print_centered_string
             rts       

MerchFOOD_DisInit:     
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             move.w    #240,d0              ; Print "FOOD"
             move.w    #113,d1
             move.w    #64,d2
             lea.l     Food_txt,a0
             jsr       Print_centered_string
             movea.l   Placedat_ptr,a0      ; Get price of 1 food
             move.w    (a0),Total_price
             lea.l     MFOOD_CIL,a0         ; Show control icons
             jsr       MFOODCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Push      PA,Lay3_PA           ; Start
             jsr       Init_RText
             moveq.l   #16,d0               ; Add message {16}
             lea.l     Code0004Sys,a1
             jsr       Add_encoded_2_RText
             moveq.l   #0,d0                ; Get price of 1 food
             move.w    Total_price,d0
             moveq.l   #5,d7                ; Convert number
             lea.l     Number_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add extra space
             clr.b     (a3)
             jsr       Add_ASCII_2_RText    ; Add it
             lea.l     Gold_txt,a0          ; Add "GOLD"
             jsr       Add_ASCII_2_RText
             movea.l   RText_ptr,a0         ; Print text
             move.w    Nr_of_chars,d0
             move.w    Lines_in_text,d1
             bra.s     .Entry2
.Loop2:      jsr       IG_Print
             jsr       IG_Carriage_return
             lea.l     1(a0,d0.w),a0
.Entry2:     dbra      d1,.Loop2
             jsr       Exit_RText           ; End
             Pop       PA
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MFOODCIL_evaluate:     
             bclr      #7,3(a0)             ; Enable all icons
             bclr      #7,4(a0)
             bclr      #7,5(a0)
             move.w    Total_price,d0       ; Enough money for 1 ration ?
             cmp.w     Places_gold,d0
             bls.s     .Ok1
             bset      #7,3(a0)             ; Disable {Buy food}
.Ok1:        tst.w     Places_food          ; Any food left ?
             bne.s     .Ok2
             bset      #7,4(a0)             ; Disable {Transfer food}
             bset      #7,5(a0)             ; Disable {Divide food}
.Ok2:        jsr       Places_CIL_evaluate
             rts       

; ************* Food merchant - Transfer food *************
MFOOD_Transfer_food:   
             SetMesMin                      112,63,192,Code0001Sys
             movea.l   Off_screen,a6        ; Print message {7,-}
             MesMin    7
             Update_screen 
             Wait_4_unclick 
             moveq.l   #0,d0                ; Set parameters
             move.w    Places_food,d0
             move.l    d0,Original_number
             clr.l     ItemW_nr
             Push      Module,TFMFOOD_Mod   ; Requester
             rts       

;*****************************************************************************
; [ Transfer Food window module ]
;*****************************************************************************
TFMFOOD_Return:        
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
             Pop       Module
             bra.s     .Exit
.Go:         jsr       Show_transfer_victims
             move.l    #Do_TFMFOOD,TIVS_Ptr ; Select transfer victim
             lea.l     TIVS2_Mod,a0
             move.w    #26,Mouse_ptr(a0)
             jsr       Push_Module
.Exit:       rts       

; [ Transfer the food ]
;   IN : a0 - Pointer to victim's character data (.l)
Do_TFMFOOD:  
             move.l    ItemW_nr,d0          ; Transfer food rations
             add.w     d0,Food_rations(a0)
             sub.w     d0,Places_food
             mulu.w    #Food_weight,d0      ; Adjust weight
             add.l     d0,Weight_normal(a0)
             rts       

; ************* Food merchant - Divide food ***************
MFOOD_Divide_food:     
             moveq.l   #0,d0                ; Get food
             move.w    Places_food,d0
             jsr       Divide_food          ; Divide it
             move.w    d0,Places_food       ; Store remaining food
             rts       

; ************* Food merchant - Buy food ******************
Buy_food:    
             Wait_4_unclick 
             moveq.l   #0,d1                ; How many can you buy ?
             move.w    Places_gold,d1
             divu.w    Total_price,d1
             cmpi.w    #99,d1               ; Too much ?
             bmi.s     .Not2much
             moveq.l   #99,d1
.Not2much:   ext.l     d1                   ; Store
             move.l    d1,Original_number
             clr.l     ItemW_nr
             lea.l     BuyFood_Mod,a0       ; How many do you want ?
             jmp       Push_Module

;*****************************************************************************
; [ Buy Food window module ]
;*****************************************************************************
BuyFood_DisInit:       
             SetMesMin                      112,63,192,Code0002Sys
             move.w    #First_add,Adding    ; Reset add value
             moveq.l   #15,d0               ; Set print colours
             jsr       IG_Set_ink
             moveq.l   #2,d0
             jsr       IG_Set_paper
             jsr       ItemW_DisInit        ; Make window
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
             moveq.l   #22,d0               ; Convert text
             lea.l     Code0003Sys,a1
             jsr       Convert_text_line
             lea.l     Line_buffer,a0       ; Print line
             jsr       IG_Print
             Update_screen 
             rts       

; [ Player has entered how many food rations he wants to buy ]
; No registers are restored
BuyFood_Return:        
             Wait_4_unclick                 ; No, exit
             tst.l     ItemW_nr             ; Any rations ?
             beq.s     .Exit
             Push      Module,BuyFoodReq_Mod      ; Are you sure ?
.Exit:       rts       

;*****************************************************************************
; [ Buy food requester ]
;*****************************************************************************
BuyFoodReq_ModInit:    
             movea.l   Off_screen,a6
             Push      PA,Lay3_PA           ; Initialize text window
             jsr       Erase_text_window
             lea.l     Food_txt,a0          ; Print word
             jsr       IG_Print
             move.l    ItemW_nr,d6          ; Get number of items
             cmpi.w    #1,d6                ; More than one ?
             beq.s     .Single
             lea.l     Multi_txt,a0         ; Print " x "
             jsr       IG_Print
             move.w    d6,d0                ; Convert number
             moveq.l   #2,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             jsr       IG_Print             ; Print it
.Single:     jsr       IG_Carriage_return
             moveq.l   #23,d0               ; Print message {23}
             lea.l     Code0003Sys,a1
             jsr       Convert_text_line
             lea       Line_buffer,a0
             jsr       IG_Print
             jsr       IG_Carriage_return
             moveq.l   #0,d0                ; Calculate total price
             move.w    Total_price,d0
             mulu.w    d6,d0
             moveq.l   #5,d7                ; Convert number
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add extra space
             clr.b     (a3)
             jsr       IG_Print             ; Print it
             lea.l     Gold_txt,a0          ; Print "GOLD"
             jsr       IG_Print
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #240,d0              ; Yes icon
             move.w    #81,d1
             lea.l     Control_icn+6912,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; No icon
             lea.l     Control_icn+7168,a0
             jsr       Blot_unmasked_block
             Update_screen 
             lea.l     SellReq_L2,a0        ; Object branch
             jsr       Set_layout_data
             Push      MA,Lay3_PlusMes      ; Install stuff
             rts       

; [ Player wants to buy food ]
BuyFoodYes:  
             move.l    ItemW_nr,d0          ; Pay the price
             move.l    d0,d1
             mulu.w    Total_price,d1
             sub.w     d1,Places_gold
             add.w     d0,Places_food       ; Buy food
             jmp       Pop_Module

;*****************************************************************************
; [ Divide food ]
;   IN : d0 - Number of food rations (.w)
;  OUT : d0 - Remaining food rations (.w)
; Changed registers : d0
;*****************************************************************************
Divide_food: 
             movem.l   d1-d3/d6/d7/a0-a2,-(sp)
             ext.l     d0
             beq       .Exit                ; Any food ?
             move.l    d0,d3
; ------------- Calculate potential food demand ----------------------
             lea.l     Chard_ptrs,a0        ; Initialize registers
             lea.l     Divide_gold_workspace,a1
             moveq.l   #0,d6
             moveq.l   #6-1,d7
.Loop1:      moveq.l   #0,d0                ; Zero food
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
             divu.w    #Food_weight,d0
             move.w    Food_rations(a2),d1  ; Not too much ?
             add.w     d0,d1
             bvc.s     .Next1
             move.w    #32767,d0
             sub.w     Food_rations(a2),d0
.Next1:      tst.w     d0                   ; Want any food ?
             beq.s     .Skip1
             addq.w    #1,d6                ; Count!
.Skip1:      move.w    d0,(a1)+             ; Store potential food
             addq.l    #4,a0                ; Next character
             dbra      d7,.Loop1
; ------------- Divide the food --------------------------------------
             tst.w     d6                   ; Anyone interested ?
             beq.s     .Exit
             move.l    d3,d0
.Again:      lea.l     -24(a0),a0
             lea.l     -12(a1),a1
             moveq.l   #6-1,d7
.Loop2:      move.w    (a1),d1              ; Want any ?
             beq.s     .Next2
             movea.l   (a0),a2              ; Get character data
             move.l    d0,d2                ; Calculate divided amount
             divu.w    d6,d2
             tst.w     d2                   ; Zero ?
             bne.s     .Skip2
             move.l    d0,d2                ; Divide remainder!
.Skip2:      cmp.w     d2,d1                ; Want enough ?
             bpl.s     .Enough
             sub.w     d1,(a1)              ; Divide food
             bne.s     .Notzero1
             subq.w    #1,d6
.Notzero1:   sub.w     d1,d0
             add.w     d1,Food_rations(a2)
             mulu.w    #Food_weight,d1
             add.l     d1,Weight_normal(a2)
             bra.s     .Next2
.Enough:     sub.w     d2,(a1)
             bne.s     .Notzero2
             subq.w    #1,d6
.Notzero2:   sub.w     d2,d0
             add.w     d2,Food_rations(a2)
             mulu.w    #Food_weight,d2
             add.l     d2,Weight_normal(a2)
.Next2:      addq.l    #4,a0                ; Next character
             addq.l    #2,a1
             dbra      d7,.Loop2
             tst.w     d0                   ; All food gone ?
             beq.s     .Exit
             tst.w     d6                   ; Everyone fully satisfied ?
             bne.s     .Again
.Exit:       movem.l   (sp)+,d1-d3/d6/d7/a0-a2
             rts       

;*****************************************************************************
; [ Horse merchant event ]
;*****************************************************************************
MerchHORSE_DisUpd:     
             jsr       Update_status_block  ; Update status block
             lea.l     MHORSE_CIL,a0        ; Update control icons
             lea.l     MHORSECIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

MerchHORSE_DisInit:    
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             jsr       Check_trans_creation
             movea.l   Placedat_ptr,a1      ; Calculate total price
             move.w    (a1),d0
             mulu.w    Nr_members,d0
             move.w    d0,Total_price
             lea.l     MHORSE_CIL,a0        ; Show control icons
             jsr       MHORSECIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MHORSECIL_evaluate:    
             movem.l   d0/d7/a1,-(sp)
             bclr      #7,3(a0)             ; Enable {Buy horses}
             tst.b     Trans_created        ; Already created ?
             bne.s     .Deac
             move.w    Places_gold,d0       ; Enough gold ?
             cmp.w     Total_price,d0
             bpl.s     .Ok
.Deac:       bset      #7,3(a0)             ; Disable {Buy horses}
.Ok:         jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d7/a1
             rts       

; ************* Horse merchant - Buy horses ***************
Buy_horses:  
             Wait_4_unclick 
             Push      Module,BuyHORSEReq_Mod
             rts       

;*****************************************************************************
; [ Buy horse requester ]
;*****************************************************************************
BuyHORSEReq_ModInit:   
             move.l    #Code0002Sys,Textfile_ptr
             moveq.l   #19,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to buy horses ]
BuyHORSEYes: 
             jsr       Create_transport     ; Make horse
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             move.l    #Lay3_PlusMes,PlusMes_info ; Bought!
             move.l    #Code0002Sys,Textfile_ptr
             PlusMes   20
             Pop       Module
.Exit:       rts       

;*****************************************************************************
; [ Raft merchant event ]
;*****************************************************************************
MerchRAFT_DisUpd:      
             jsr       Update_status_block  ; Update status block
             lea.l     MRAFT_CIL,a0         ; Update control icons
             lea.l     MRAFTCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

MerchRAFT_DisInit:     
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             movea.l   Placedat_ptr,a1      ; Calculate total price
             move.w    (a1),d0
             move.w    d0,Total_price
             jsr       Check_trans_creation
             lea.l     MRAFT_CIL,a0         ; Show control icons
             jsr       MRAFTCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MRAFTCIL_evaluate:     
             movem.l   d0/d7/a1,-(sp)
             bclr      #7,3(a0)             ; Enable {Buy raft}
             tst.b     Trans_created        ; Already created ?
             bne.s     .Deac
             move.w    Places_gold,d0       ; Enough gold ?
             cmp.w     Total_price,d0
             bpl.s     .Ok
.Deac:       bset      #7,3(a0)             ; Disable {Buy raft}
.Ok:         jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d7/a1
             rts       

; ************* Raft merchant - Buy raft ******************
Buy_raft:    
             Wait_4_unclick 
             Push      Module,BuyRAFTReq_Mod
             rts       

;*****************************************************************************
; [ Buy raft requester ]
;*****************************************************************************
BuyRAFTReq_ModInit:    
             move.l    #Code0003Sys,Textfile_ptr
             moveq.l   #1,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to buy a raft ]
BuyRAFTYes:  
             jsr       Create_transport     ; Make raft
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             move.l    #Lay3_PlusMes,PlusMes_info ; Bought!
             move.l    #Code0003Sys,Textfile_ptr
             PlusMes   2
             Pop       Module
.Exit:       rts       

;*****************************************************************************
; [ Ship merchant event ]
;*****************************************************************************
MerchSHIP_DisUpd:      
             jsr       Update_status_block  ; Update status block
             lea.l     MSHIP_CIL,a0         ; Update control icons
             lea.l     MSHIPCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

MerchSHIP_DisInit:     
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             movea.l   Placedat_ptr,a1      ; Calculate total price
             move.w    (a1),d0
             move.w    d0,Total_price
             jsr       Check_trans_creation
             lea.l     MSHIP_CIL,a0         ; Show control icons
             jsr       MSHIPCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MSHIPCIL_evaluate:     
             movem.l   d0/d7/a1,-(sp)
             bclr      #7,3(a0)             ; Enable {Buy ship}
             tst.b     Trans_created        ; Already created ?
             bne.s     .Deac
             move.w    Places_gold,d0       ; Enough gold ?
             cmp.w     Total_price,d0
             bpl.s     .Ok
.Deac:       bset      #7,3(a0)             ; Disable {Buy ship}
.Ok:         jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d7/a1
             rts       

; ************* Ship merchant - Buy ship ******************
Buy_ship:    
             Wait_4_unclick 
             Push      Module,BuySHIPReq_Mod
             rts       

;*****************************************************************************
; [ Buy ship requester ]
;*****************************************************************************
BuySHIPReq_ModInit:    
             move.l    #Code0003Sys,Textfile_ptr
             moveq.l   #3,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to buy a ship ]
BuySHIPYes:  
             jsr       Create_transport     ; Make ship
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             move.l    #Lay3_PlusMes,PlusMes_info ; Bought!
             move.l    #Code0003Sys,Textfile_ptr
             PlusMes   4
             Pop       Module
.Exit:       rts       

;*****************************************************************************
; [ Create transport ]
; All registers are restored
;*****************************************************************************
Create_transport:      
             movem.l   d0/d7/a0/a1,-(sp)
             lea.l     Trans_T,a0           ; Find free transport slot
             moveq.l   #30-1,d7
.Loop:       tst.b     0(a0,d7.w)           ; Free ?
             beq.s     .Yay
             subq.w    #1,d7
             bpl.s     .Loop
             ERROR     "[ Create_transport ] : No slot free !!!"
             bra       .Exit
.Yay:        movea.l   Placedat_ptr,a1      ; Make ship
             move.w    8(a1),d0             ; Set transport type
             move.b    d0,0(a0,d7.w)
             move.w    2(a1),d0             ; Set X-coordinate
             move.b    d0,30(a0,d7.w)
             move.w    4(a1),d0             ; Set Y-coordinate
             move.b    d0,60(a0,d7.w)
             lea.l     90(a0,d7.w),a0       ; Set map number
             move.w    6(a1),0(a0,d7.w)
             st        Trans_created        ; Signal
.Exit:       movem.l   (sp)+,d0/d7/a0/a1
             rts       

;*****************************************************************************
; [ Check if transport has already been created / no more slots are free ]
; All registers are restored
;*****************************************************************************
Check_trans_creation:  
             movem.l   d0-d2/d7/a0/a1,-(sp)
             movea.l   Placedat_ptr,a0      ; Load coordinates & map nr.
             move.w    2(a0),d0
             move.w    4(a0),d1
             move.w    6(a0),d2
             lea.l     Trans_T,a0           ; Initialize registers
             lea.l     90(a0),a1
             moveq.l   #30-1,d7
.Loop1:      tst.b     (a0)                 ; Any there ?
             beq.s     .Next
             cmp.w     (a1),d2              ; Map OK ?
             bne.s     .Next
             cmp.b     30(a0),d0            ; Coordinates OK ?
             bne.s     .Next
             cmp.b     60(a0),d1
             bne.s     .Next
             st        Trans_created        ; Signal
             bra.s     .Exit
.Next:       addq.l    #1,a0                ; Next
             addq.l    #2,a1
             dbra      d7,.Loop1
             sf        Trans_created        ; Signal
.Exit:       lea.l     Trans_T,a0           ; Any slots free ?
             move.b    (a0)+,d0
             moveq.l   #30-2,d7
.Loop2:      and.b     (a0)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Well ?
             sne       Trans_created
             movem.l   (sp)+,d0-d2/d7/a0/a1
             rts       

;*****************************************************************************
; [ Transport buy requester routines ]
;*****************************************************************************
;   IN : d0 - Message number (.w)
BuyTRANSReq_ModInit:   
             movea.l   Off_screen,a6
             Push      MA,Lay3_PlusMes
             Push      PA,Lay3_PA           ; Initialize text window
             jsr       Erase_text_window
             movea.l   Textfile_ptr,a1      ; Print message
             jsr       Convert_text_line
             lea       Line_buffer,a0
             jsr       IG_Print
             jsr       IG_Carriage_return
             move.w    Total_price,d0       ; Convert number
             moveq.l   #5,d7
             lea.l     Line_buffer,a0
             movea.l   a0,a3
             jsr       LConvert_number
             move.b    #" ",(a3)+           ; Add extra space
             clr.b     (a3)
             jsr       IG_Print             ; Print it
             lea.l     Gold_txt,a0          ; Print "GOLD"
             jsr       IG_Print
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #240,d0              ; Yes icon
             move.w    #81,d1
             lea.l     Control_icn+6912,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; No icon
             lea.l     Control_icn+7168,a0
             jsr       Blot_unmasked_block
             Update_screen 
             lea.l     SellReq_L2,a0        ; Object branch
             jsr       Set_layout_data
             rts       

BuyTRANSReq_ModExit:   
             movea.l   Off_screen,a6        ; Erase text window
             jsr       Erase_text_window
             Update_screen 
             Pop       MA
             Pop       PA
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             Wait_4_unclick 
             rts       

BuyTRANSReq_DisUpd:    
             jsr       Update_status_block
             jsr       Display_gold
             rts       

;*****************************************************************************
; [ Healer event ]
;*****************************************************************************
Healer_DisUpd:         
             jsr       Update_status_block  ; Update status block
             lea.l     Healer_CIL,a0        ; Update control icons
             lea.l     HealerCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

Healer_ModInit:        
             move.l    Current_active_char_data,Current_healer_victim
             move.w    Active_member,Healer_victim_nr
             jmp       Places_ModInit

Healer_DisInit:        
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
; ------------- Display body & mind conditions -----------------------
             jsr       Display_BodyMind
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             .LOCAL 
; ------------- Rest of display --------------------------------------
             lea.l     Healer_CIL,a0        ; Show control icons
             jsr       HealerCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             lea.l     XLay3_target_hbl,a1  ; Copy palette & fade in
             movem.l   Lay3_target_hbl+2,d0-d7
             movem.l   d0-d7,2(a1)
             jmp       Fade_lay3

Healer_DisExit:        
             move.w    Healer_victim_nr,d5
             move.w    d5,d4                ; Calculate X-coordinate
             mulu.w    #48,d4
             movea.l   Current_healer_victim,a4   ; Restore portrait
             movea.l   Off_screen,a6
             jsr       Display_portrait
             Update_screen 
             jmp       Fadeout_lay3

HealerCIL_evaluate:    
             movem.l   d7/a1/a2,-(sp)
             bclr      #7,3(a0)             ; Enable {Remove curse}
             movea.l   Current_healer_victim,a1   ; Any cursed objects ?
             lea.l     Inv_data(a1),a2
             lea.l     Neck_place_counter(a1),a1
             moveq.l   #9-1,d7
.Loop:       tst.b     (a1)+                ; Any object there ?
             beq.s     .Next
             btst      #0,Item_stat_bits(a2)      ; Is it cursed ?
             bne.s     .Ok
.Next:       lea.l     40(a2),a2            ; Next object
             dbra      d7,.Loop
             bset      #7,3(a0)             ; Disable {Remove curse}
.Ok:         jsr       Places_CIL_evaluate
             movem.l   (sp)+,d7/a1/a2
             rts       

; ************* Healer - Remove curse *********************
Healer_Remove_curse:   
             movea.l   Current_healer_victim,a1   ; Count cursed objects
             lea.l     Inv_data(a1),a2
             lea.l     Neck_place_counter(a1),a1
             lea.l     Cursed_slots,a3
             moveq.l   #0,d0
             clr.l     (a3)+                ; Clear slots
             clr.l     (a3)+
             clr.b     (a3)
             lea.l     -8(a3),a3
             moveq.l   #9-1,d7
.Loop:       tst.b     (a1)+                ; Any object there ?
             beq.s     .Next
             btst      #0,Item_stat_bits(a2)      ; Is it cursed ?
             beq.s     .Next
             st        (a3)                 ; Set flag
             addq.w    #1,d0                ; Count
.Next:       lea.l     40(a2),a2            ; Next object
             addq.l    #1,a3
             dbra      d7,.Loop
             move.w    d0,Nr_cursed_objects
             movea.l   Placedat_ptr,a0      ; Store price
             moveq.l   #0,d1
             move.w    20(a0),d1
             mulu.w    d1,d0
             move.w    d0,Total_price
             cmp.w     Places_gold,d0       ; Enough dough ?
             ble.s     .Ok
             move.l    #Lay3_PlusMes,PlusMes_info ; Print message {22,+}
             move.l    #Code0002Sys,Textfile_ptr
             PlusMes   22
             bra       .Exit
.Ok:         move.w    d0,Total_price       ; Store price
             Push      Module,RemCurseReq_Mod
.Exit:       rts       

; ************* Healer - Heal condition *******************
Heal_condition:        
             tst.b     d0                   ; Any slot ?
             beq       .Exit
             move.b    d0,Object_slot_number      ; Store slot number
             lea.l     Sold_slots,a0        ; Calculate pointers
             lea.l     Sold_data,a1
             ext.w     d0
             subq.w    #1,d0
             adda.w    d0,a0
             mulu.w    #40,d0
             adda.w    d0,a1
             tst.b     (a0)                 ; Slot filled ?
             beq       .Exit
             Wait_4_unclick 
             movea.l   Placedat_ptr,a0      ; Get price
             moveq.l   #0,d0
             move.b    1(a1),d0
             move.b    .Price_indices(pc,d0.w),d0
             move.w    0(a0,d0.w),d0
             cmp.w     Places_gold,d0       ; Enough dough ?
             ble.s     .Ok
             move.l    #Lay3_PlusMes,PlusMes_info ; Print message {22,+}
             move.l    #Code0002Sys,Textfile_ptr
             PlusMes   22
             bra       .Exit
.Ok:         move.w    d0,Total_price       ; Store price
             Push      Module,HealCondReq_Mod
.Exit:       rts       

.Price_indices:        
             .DC.b -1,10,-1,-1,12,-1,-1,-1
             .DC.b 0,2,4,6,8,14,16,18
             .EVEN 

;*****************************************************************************
; [ Heal condition requester ]
;*****************************************************************************
HealCondReq_ModInit:   
             move.l    #Code0002Sys,Textfile_ptr
             moveq.l   #24,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to heal condition ]
HealCondYes: 
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             lea.l     Sold_data-40,a0      ; Get pointer to item data
             move.b    Object_slot_number,d0
             ext.w     d0
             mulu.w    #40,d0
             move.b    1(a0,d0.w),d0        ; Get condition number
             movea.l   Current_healer_victim,a0   ; Heal condition
             move.w    Body_conditions(a0),d1
             bclr      d0,d1
             move.w    d1,Body_conditions(a0)
             cmpi.w    #13,d0               ; Resurrection ?
             bmi.s     .No
             move.w    Healer_victim_nr,d0  ; Yay!
             jsr       Resurrection
.No:         movea.l   Off_screen,a6        ; Update display
             jsr       Display_BodyMind
             Update_screen 
             Wait_4_unclick                 ; Exit
             jmp       Pop_Module

;*****************************************************************************
; [ Remove curse requester ]
;*****************************************************************************
RemCurseReq_ModInit:   
             move.l    #Code0002Sys,Textfile_ptr
             moveq.l   #23,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to remove curse ]
RemCurseYes: 
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             Wait_4_unclick                 ; Exit requester
             Pop       Module
             jsr       Exit_display         ; Remove it!
             Push      Module,RemCurse_Mod
             rts       

;*****************************************************************************
; [ Remove cursed objects ]
;*****************************************************************************
RemCurse_DisInit:      
             jsr       Mouse_off
             jsr       Inv2_DisInit         ; Show Inventory II
             moveq.l   #50,d0               ; Wait 1 second
             jsr       Delay
             lea.l     Cursed_slots,a0      ; Initialize registers
             movea.l   Current_healer_victim,a1
             lea.l     Neck_place_counter(a1),a2
             lea.l     Inv_data(a1),a3
             moveq.l   #1,d0
             moveq.l   #9-1,d7
.Loop:       tst.b     (a0)+                ; Cursed ?
             beq.s     .Next
             clr.b     (a2)                 ; Remove object
             moveq.l   #0,d2
             move.w    Weight(a3),d2
             sub.l     d2,Weight_normal(a1)
             move.l    d0,-(sp)
             moveq.l   #0,d2                ; Get icon numbers
             moveq.l   #0,d3
             move.b    (a3),d2
             lea.l     Erase_icon,a4
             move.b    -1(a4,d0.w),d3
             lea.l     Object_pos_list-4,a4 ; Get coordinates
             add.w     d0,d0
             add.w     d0,d0
             move.w    2(a4,d0.w),d1
             move.w    0(a4,d0.w),d0
             jsr       Show_item_destruction      ; Destroy
             move.l    (sp)+,d0
.Next:       addq.w    #1,d0                ; Next object
             addq.l    #1,a2
             lea.l     40(a3),a3
             dbra      d7,.Loop
             moveq.l   #50,d0               ; Wait 1 second
             jsr       Delay
             Pop       Module               ; Exit
             jsr       Mouse_on
             jmp       Init_display

;*****************************************************************************
; [ Show object destruction animation ]
;   IN : d0 - X-coordinate (.w)
;        d1 - Y-coordinate (.w)
;        d2 - Number of object icon (.w)
;        d3 - Number of empty icon (.w)
; All registers are restored
;*****************************************************************************
Show_item_destruction: 
             movem.l   d0-d2/d7/a0-a4/a6,-(sp)
             lea.l     Objects_icn,a1       ; Calculate graphics address
             ext.w     d2                   ; of object icon
             lsl.w     #7,d2
             adda.w    d2,a1
             lea.l     Layout_icn-128,a2    ; Calculate graphics address
             ext.w     d3                   ; of empty icon
             lsl.w     #7,d3
             adda.w    d3,a2
             lea.l     Curse_anim,a3
             lea.l     Layout_icn+9856,a4
             moveq.l   #8-1,d7
.Loop1:      movea.l   Off_screen,a6
             movea.l   a4,a0                ; Empty icon
             jsr       Put_unmasked_block
             movea.l   a1,a0                ; Object icon
             jsr       Put_masked_block
             movea.l   a3,a0                ; Animation frame
             jsr       Put_masked_block
             jsr       Switch_screen        ; Wait
             .REPT 3
             jsr       My_vsync
             .ENDR 
             lea.l     128(a3),a3           ; Next frame
             dbra      d7,.Loop1
             moveq.l   #8-1,d7
.Loop2:      movea.l   Off_screen,a6
             movea.l   a2,a0                ; Empty icon
             jsr       Put_unmasked_block
             movea.l   a3,a0                ; Animation frame
             jsr       Put_masked_block
             jsr       Switch_screen        ; Wait
             .REPT 3
             jsr       My_vsync
             .ENDR 
             lea.l     128(a3),a3           ; Next frame
             dbra      d7,.Loop2
             movea.l   Off_screen,a6        ; Last empty icon
             movea.l   a2,a0
             jsr       Put_unmasked_block
             Update_screen 
             movem.l   (sp)+,d0-d2/d7/a0-a4/a6
             rts       

;*****************************************************************************
; [ Display body/mind conditions ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Display_BodyMind:      
             movem.l   d0-d2/d6/d7/a0-a3,-(sp)
             move.l    #0,d1                ; Initialize registers
             movea.l   Current_healer_victim,a0
             move.w    Body_conditions(a0),d6
             lea.l     BodyMind_Distribution,a0
             lea.l     Sold_slots,a1
             lea.l     Sold_data,a2
             lea.l     Misc_dat+Body_names,a3
             clr.l     (a1)+                ; Clear slots
             clr.l     (a1)+
             clr.l     (a1)
             lea.l     -8(a1),a1
             moveq.l   #13-1,d7
.Loop:       move.b    (a0),d0              ; Healable condition ?
             bmi.s     .Next
             btst      d0,d6                ; Condition on ?
             beq.s     .Next
             move.b    #1,(a1)+             ; Fill slot
             move.b    1(a0),(a2)           ; Set icon number
             move.b    d0,1(a2)             ; Set condition bit number
             move.w    (a3),Name_word_nr(a2)      ; Set name word index
             lea.l     40(a2),a2
.Next:       addq.l    #2,a0                ; Next condition
             addq.l    #2,a3
             dbra      d7,.Loop
.Exit:       .LOCAL 
; ------------- Display body/mind conditions -------------------------
             lea.l     Sold_data,a1         ; Show "objects"
             lea.l     Door_object_pos_list,a2
             lea.l     Sold_slots,a3
             moveq.l   #12-1,d7
.Loop:       move.w    (a2)+,d0             ; Get coordinates
             move.w    (a2)+,d1
             lea.l     Layout_icn+9856,a0   ; Erase object
             jsr       Put_unmasked_block
             tst.b     (a3)+                ; Anything there ?
             beq.s     .Next
             lea.l     Status_icn,a0        ; Calculate graphics address
             move.b    (a1),d2
             ext.w     d2
             lsl.w     #7,d2
             adda.w    d2,a0
             jsr       Put_masked_block     ; Display object
.Next:       lea.l     40(a1),a1            ; Next object
             dbra      d7,.Loop
             movem.l   (sp)+,d0-d2/d6/d7/a0-a3
             rts       

;*****************************************************************************
; [ Left mouse-button clicked on party member - Healer ]
; All registers are restored
;*****************************************************************************
Healer_Member_left:    
             andi.l    #$0000ff00,d0        ; Get member number
             beq.s     .Exit
             lsr.w     #8,d0
             cmp.w     Healer_victim_nr,d0  ; Same ?
             beq.s     .Exit
             lea.l     Chard_ptrs-4,a0      ; Get pointer to character
             move.w    d0,d1                ; data
             add.w     d1,d1
             add.w     d1,d1
             adda.w    d1,a0
             tst.l     (a0)                 ; Anyone there ?
             beq.s     .Exit
             move.w    Healer_victim_nr,d5  ; Get old & set new
             move.w    d0,Healer_victim_nr
             move.w    d5,d4                ; Calculate X-coordinate
             mulu.w    #48,d4
             movea.l   Current_healer_victim,a4   ; Restore portrait
             movea.l   Off_screen,a6
             jsr       Display_portrait
             move.l    (a0),Current_healer_victim ; Set new
             movea.l   Off_screen,a6        ; Update body/mind conditions
             jsr       Display_BodyMind
             Update_screen 
.Exit:       rts       

;*****************************************************************************
; [ Display Ankh ]
;*****************************************************************************
Display_Ankh:          
             move.w    Healer_victim_nr,d0  ; Calculate X-coordinate
             mulu.w    #48,d0
             subi.w    #32,d0
             moveq.l   #1,d1                ; Display Ankh
             moveq.l   #2,d6
             moveq.l   #32,d7
             lea.l     Status_icn+3072,a0
             movea.l   Off_screen,a6
             jsr       Blot_masked_block
             rts       

;*****************************************************************************
; [ Resurrect person ]
;   IN : d0 - Number of character (.w)
;        a0 - Pointer to character data (.l)
; All registers are restored
;*****************************************************************************
Resurrection:          
             movem.l   d0/d4/d5/a0/a6,-(sp)
             move.w    #1,Life_points_normal(a0)  ; ONE hitpoint

             DIAG_ON 
             PRINT     .Text
             jsr       Wait_4_key
             DIAG_OFF 

             lea.l     Char_status_icons,a0 ; Remove cross icon
             clr.b     -1(a0,d0.w)
             jsr       Force_char_update    ; Update
             movem.l   (sp)+,d0/d4/d5/a0/a6
             rts       

.Text:       .DC.b "The healer puts his hand on the dead persons's forehead.",13
             .DC.b "White light pulses down his arm and all watch in awe",13
             .DC.b "as life returns to the once cold body. The resurrected",13
             .DC.b "person opens his eyes and asks 'What's for dinner ?'",0
             .EVEN 

;*****************************************************************************
; [ Magic merchant ]
;*****************************************************************************
MerchMAGIC_DisUpd:     
             jsr       Update_status_block  ; Update status block
             lea.l     MMAGIC_CIL,a0        ; Update control icons
             lea.l     MMAGICCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             jsr       Update_quantity_colours
             rts       

MerchMAGIC_DisInit:    
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             move.l    #Code0002Sys,Textfile_ptr
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             lea.l     MMAGIC_CIL,a0        ; Show control icons
             jsr       MMAGICCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             jsr       Show_objects_LAY3    ; Display objects
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

MMAGICCIL_evaluate:    
             movem.l   d0/d7/a1,-(sp)
             bclr      #7,(a0)              ; Enable {Buy item}
             bclr      #7,5(a0)             ; Enable {Transfer item}
; ------------- Can one buy an object ? ------------------------------
             tst.w     Places_gold          ; Any gold ?
             beq.s     .Deac
             movea.l   Warecount_ptr,a1
             move.l    (a1)+,d0             ; Anything ?
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             beq.s     .Deac
             lea.l     Sold_slots,a1        ; Any slot free ?
             move.b    (a1)+,d0
             moveq.l   #11-1,d7
.Loop2:      and.b     (a1)+,d0
             dbra      d7,.Loop2
             tst.b     d0                   ; Well ?
             beq.s     .Not_empty2
.Deac:       bset      #7,(a0)              ; Disable {Buy item}
; ------------- Can one transfer an object ? -------------------------
.Not_empty2: lea.l     Sold_slots,a1
             move.l    (a1)+,d0             ; Anything ?
             or.l      (a1)+,d0
             or.l      (a1)+,d0
             bne.s     .Not_empty3
             bset      #7,5(a0)             ; Disable {Transfer item}
.Not_empty3: jsr       Places_CIL_evaluate
             movem.l   (sp)+,d0/d7/a1
             rts       

;*****************************************************************************
; [ Sage ]
;*****************************************************************************
Sage_DisUpd: 
             jsr       Update_status_block  ; Update status block
             lea.l     Sage_CIL,a0          ; Update control icons
             lea.l     SageCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

Sage_DisInit:          
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             jsr       List_body_items      ; Install object data
             move.l    #Sold_data,Itemdata_ptr
             move.l    #Sold_slots,Itemslots_ptr
             jsr       Show_objects_LAY3
             sf        Body_backpack
             lea.l     Sage_CIL,a0          ; Show control icons
             jsr       SageCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

SageCIL_evaluate:      
             tst.b     Body_backpack
             beq.s     .Backpack
             bclr      #7,(a0)              ; Enable {Show body items}
             bset      #7,3(a0)             ; Disable {Show backpack items}
             bra.s     .Exit
.Backpack:   bset      #7,(a0)              ; Disable {Show body items}
             bclr      #7,3(a0)             ; Enable {Show backpack items}
.Exit:       jsr       Places_CIL_evaluate
             rts       

; ************* Sage - show body items ********************
Show_body_items:       
             move.l    #Sold_data,Itemdata_ptr    ; Install object data
             move.l    #Sold_slots,Itemslots_ptr
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3
             Update_screen 
             not.b     Body_backpack
             rts       

; ************* Sage - show backpack items ****************
Show_backpack_items:   
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inv_data+360(a0),a1
             move.l    a1,Itemdata_ptr
             lea.l     Inventory_1_place_counter(a0),a1
             move.l    a1,Itemslots_ptr
             movea.l   Off_screen,a6
             jsr       Show_objects_LAY3
             Update_screen 
             not.b     Body_backpack
             rts       

; ************* Sage - Lore items *************************
Lore_item:   
             tst.b     d0                   ; Any slot ?
             beq       .Exit
             movea.l   Itemslots_ptr,a0     ; Get slot pointer
             ext.w     d0
             tst.b     -1(a0,d0.w)          ; Slot filled ?
             beq       .Exit
             tst.b     Body_backpack        ; Body or backpack ?
             beq.s     .Body
             addi.w    #9,d0
.Body:       move.b    d0,Object_slot_number
             Wait_4_unclick 
             movea.l   Current_active_char_data,a0          ; Get item data pointer
             lea.l     Inv_data-40(a0),a0
             mulu.w    #40,d0
             adda.w    d0,a0
             btst      #7,Item_stat_bits(a0)      ; Already lored ?
             beq.s     .No
             move.l    #Lay3_PlusMes,PlusMes_info ; Print message {22,+}
             move.l    #Code0003Sys,Textfile_ptr
             PlusMes   24
             bra       .Exit
.No:         movea.l   Placedat_ptr,a0      ; Get price
             move.w    (a0),d0
             cmp.w     Places_gold,d0       ; Enough dough ?
             ble.s     .Ok
             move.l    #Lay3_PlusMes,PlusMes_info ; Print message {22,+}
             move.l    #Code0002Sys,Textfile_ptr
             PlusMes   22
             bra       .Exit
.Ok:         move.w    d0,Total_price       ; Store price
             Push      Module,LoreItemReq_Mod
.Exit:       rts       

;*****************************************************************************
; [ Lore item requester ]
;*****************************************************************************
LoreItemReq_ModInit:   
             move.l    #Code0003Sys,Textfile_ptr
             moveq.l   #0,d0
             jmp       BuyTRANSReq_ModInit

; [ Player wants to lore item ]
LoreItemYes: 
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             movea.l   Current_active_char_data,a0          ; Get pointer to item data
             lea.l     Inv_data(a0),a0
             move.b    Object_slot_number,d0
             ext.w     d0
             subq.w    #1,d0
             mulu.w    #40,d0
             adda.w    d0,a0
             bset      #7,Item_stat_bits(a0)      ; Lore it!
             Wait_4_unclick 
             move.l    Current_active_char_data,Current_inventory_chardat_ptr
             Push      Module,ItemView1_Mod ; View item
             rts       

;*****************************************************************************
; [ Make list of body items ]
; All registers are restored
;*****************************************************************************
List_body_items:       
             movem.l   d6/d7/a0-a3,-(sp)
             movea.l   Current_active_char_data,a0          ; Initialize registers
             lea.l     Inv_data(a0),a1
             lea.l     Neck_place_counter(a0),a0
             lea.l     Sold_slots,a2
             lea.l     Sold_data,a3
             clr.l     (a2)+                ; Clear slots
             clr.l     (a2)+
             clr.l     (a2)
             lea.l     -8(a2),a2
             moveq.l   #9-1,d7
.Loop1:      tst.b     (a0)+                ; Slot filled ?
             beq.s     .Next
             cmpi.b    #17,Item_type(a1)    ; Is it a monster item ?
             beq.s     .Next
             move.b    #1,(a2)+             ; Fill slot
             moveq.l   #10-1,d6             ; Copy item data
.Loop2:      move.l    (a1)+,(a3)+
             dbra      d6,.Loop2
             bra.s     .Skip
.Next:       lea.l     40(a1),a1            ; Next item
             addq.l    #1,a2
             lea.l     40(a3),a3
.Skip:       dbra      d7,.Loop1
             movem.l   (sp)+,d6/d7/a0-a3
             rts       

;*****************************************************************************
; [ Left mouse-button clicked on party member - Sage ]
; All registers are restored
;*****************************************************************************
Sage_Member_left:      
             andi.l    #$0000ff00,d0        ; Get member number
             beq       .Exit
             lsr.w     #8,d0
             cmp.w     Active_member,d0     ; Same ?
             beq       .Exit
             lea.l     Chard_ptrs-4,a0      ; Get pointer to character
             move.w    d0,d1                ; data
             add.w     d1,d1
             add.w     d1,d1
             adda.w    d1,a0
             tst.l     (a0)                 ; Anyone there ?
             beq       .Exit
             movea.l   (a0),a1
             move.w    Body_conditions(a1),d1     ; Okay ?
             andi.w    #$e506,d1
             bne       .Exit
             move.w    d0,Active_member     ; Set new
             move.l    a1,Current_active_char_data
             jsr       List_body_items      ; List body items
             tst.b     Body_backpack        ; Body or backpack ?
             beq.s     .Body
             movea.l   Current_active_char_data,a0          ; Install object data
             lea.l     Inv_data+360(a0),a1
             move.l    a1,Itemdata_ptr
             lea.l     Inventory_1_place_counter(a0),a1
             move.l    a1,Itemslots_ptr
.Body:       movea.l   Off_screen,a6        ; Show backpack items
             jsr       Show_objects_LAY3
             Update_screen 
.Exit:       rts       

;*****************************************************************************
; [ Inn ]
;*****************************************************************************
Inn_DisUpd:  
             jsr       Update_status_block  ; Update status block
             lea.l     Inn_CIL,a0           ; Update control icons
             lea.l     InnCIL_evaluate,a1
             jsr       Update_control_icons
             jsr       Display_gold         ; Update gold
             rts       

Inn_DisInit: 
             sf        Room_rented          ; Clear flag
             move.l    #Lay3_PlusMes,PlusMes_info ; Set message parameters
             movea.l   Off_screen,a6
             moveq.l   #3,d0                ; Show layout 3
             jsr       Show_layout
             jsr       Display_80x80_picture      ; Show picture
             jsr       Places_DisInit       ; Print headline & "GOLD"
             movea.l   Placedat_ptr,a0      ; Calculate total price
             move.w    (a0),d0
             mulu.w    Nr_members,d0
             move.w    d0,Total_price
             lea.l     Inn_CIL,a0           ; Show control icons
             jsr       InnCIL_evaluate
             move.l    a0,Control_list_ptr
             jsr       Show_control_icons
             Update_screen 
             lea.l     Lay3_L2,a0           ; Set object branch
             jsr       Set_layout_data
             jmp       Fadein_lay3          ; Fade in

InnCIL_evaluate:       
             bclr      #7,3(a0)             ; Enable {Guestroom}
             tst.b     Room_rented          ; Already rented ?
             bne.s     .Deac
             move.w    Total_price,d0       ; Enough dough ?
             cmp.w     Places_gold,d0
             ble.s     .Ok
.Deac:       bset      #7,3(a0)             ; Disable {Guestroom}
.Ok:         jsr       Places_CIL_evaluate
             rts       

; ************* Inn - Guestroom ***************************
Guestroom:   
             Wait_4_unclick 
             Push      Module,GuestroomReq_Mod
             rts       

;*****************************************************************************
; [ Guestroom requester ]
;*****************************************************************************
GuestroomReq_ModInit:  
             moveq.l   #6,d0
             move.l    #Code0003Sys,Textfile_ptr
             jmp       BuyTRANSReq_ModInit

; [ Player wants a guestroom ]
GuestroomYes:          
             move.w    Total_price,d0       ; Remove gold
             sub.w     d0,Places_gold
             st        Inn_flag             ; Camp
             st        Room_rented
             Wait_4_unclick 
             jsr       Exit_display
             jmp       Pop_Module

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
GoldDis_text:          .DC.b "01234",0
Make_level_txt:        .DC.b "01%",0
Bonus_txt:   .DC.b "BONUS : 01%",0
Multi_txt:   .DC.b " x ",0
             .EVEN 
Guild_CIL:   .DC.b 52,56,30,53,56,56,31,50,18
             .EVEN 
             .DC.l Join_guild,0,Exit_PLACES
             .DC.l Make_level,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MOBJC_CIL:   .DC.b 54,56,30,55,35,33,31,50,18
             .EVEN 
             .DC.l Buy_item,0,Exit_PLACES
             .DC.l Sell_item,View_item_MOBJC,Transfer_item_MOBJC
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MFOOD_CIL:   .DC.b 56,56,30,64,51,20,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Buy_food,MFOOD_Divide_food,MFOOD_Transfer_food
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MHORSE_CIL:  .DC.b 56,56,30,5,56,56,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Buy_horses,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MRAFT_CIL:   .DC.b 56,56,30,6,56,56,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Buy_raft,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MSHIP_CIL:   .DC.b 56,56,30,22,56,56,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Buy_ship,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
Healer_CIL:  .DC.b 56,56,30,12,56,56,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Healer_Remove_curse,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
MMAGIC_CIL:  .DC.b 54,56,30,56,56,33,31,50,18
             .EVEN 
             .DC.l Buy_item,0,Exit_PLACES
             .DC.l 0,0,Transfer_item_MOBJC
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
Sage_CIL:    .DC.b 9,56,30,29,56,56,31,50,18
             .EVEN 
             .DC.l Show_body_items,0,Exit_PLACES
             .DC.l Show_backpack_items,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES
Inn_CIL:     .DC.b 56,56,30,19,56,56,31,50,18
             .EVEN 
             .DC.l 0,0,Exit_PLACES
             .DC.l Guestroom,0,0
             .DC.l Pool_gold_PLACES,Divide_gold_PLACES,Transfer_gold_PLACES

PlacesExit_MA:         .DC.w 64,64+159,96,96+47
PlacesExit_PA:         .DC.w 64,96,160,48,15,2

XLay3_target_hbl:      
             .DC.w 0
             .DCB.w 16,0                    ; 80x80 picture palette
             .DC.w 0
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200     ; Status palette
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
BodyMind_Distribution: 
             .DC.b 8,9,9,10,10,11,11,12,12,13,13,0,14,0,15,0
             .DC.b -1,0,1,15,-1,0,-1,0,4,18


             .BSS 
Place_nr:    .DS.w 1
Places_gold: .DS.w 1
Placedat_ptr:          .DS.l 1
Placetext_ptr:         .DS.l 1
Make_level_offsets:    .DS.b 10
Possible_level_offsets:                     .DS.b 10
Exit_on:     .DS.b 1
Room_rented: .DS.b 1
Trans_created:         .DS.b 1
Body_backpack:         .DS.b 1
Cursed_slots:          .DS.b 9
             .EVEN 
Remaining_offset:      .DS.w 1
Warecount_ptr:         .DS.l 1
Sold_data:   .DS.w 12*20
Sold_slots:  .DS.b 12
Total_price: .DS.w 1
Places_food: .DS.w 1
Nr_cursed_objects:     .DS.w 1
Current_healer_victim: .DS.l 1
Healer_victim_nr:      .DS.w 1

             .SECTION 5,DATA
Waredat_filename:      .DC.b 13,'WARESDAT.AMB',0
             .EVEN 

             .SECTION 6,BSS 
Waredat_ptr: .DS.l 1

             .SECTION 7,DATA
; SKILL SELECT WINDOW : 1st layer
SkillW_L1:   .DC.w 0,127,8,77               ; Skills area
             .DC.b 1
             .EVEN 
             .DC.l .C2,SkillW_L2
.C2:         .DC.w 0,31,80,95               ; Exit icon
             .DC.b 2
             .EVEN 
             .DC.l 0,0

; SKILL SELECT WINDOW : 2nd layer
SkillW_L2:   .DC.w 0,127,8,14
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 0,127,15,21
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 0,127,22,28
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 0,127,29,35
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 0,127,36,42
             .DC.b 5
             .EVEN 
             .DC.l .C6,0
.C6:         .DC.w 0,127,43,49
             .DC.b 6
             .EVEN 
             .DC.l .C7,0
.C7:         .DC.w 0,127,50,56
             .DC.b 7
             .EVEN 
             .DC.l .C8,0
.C8:         .DC.w 0,127,57,63
             .DC.b 8
             .EVEN 
             .DC.l .C9,0
.C9:         .DC.w 0,127,64,70
             .DC.b 9
             .EVEN 
             .DC.l .C10,0
.C10:        .DC.w 0,127,71,77
             .DC.b 10
             .EVEN 
             .DC.l 0,0

; PLACES EXIT WINDOW : 1st layer
PlacesExit_L1:         
             .DC.w 16,47,32,47
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 48,79,32,47
             .DC.b 2
             .EVEN 
             .DC.l 0,0

; SELL REQUESTER : 2nd layer
SellReq_L2:  .DC.w 240,271,81,97            ; Yes icon
             .DC.b 1
             .EVEN 
             .DC.l .C2,0
.C2:         .DC.w 272,303,81,97            ; No icon
             .DC.b 2
             .EVEN 
             .DC.l 0,0


             .END 


















