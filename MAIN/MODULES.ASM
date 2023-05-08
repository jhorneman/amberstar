
; Modules
; Written by J.Horneman (In Tune With The Universe)
; Start : 4-7-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "Rejoice forward out this feeling
;     The white eagle soars
;    He goes round and round and round
;     Until the early winds of change."
;   Rejoice, Yes, 1978

             .MACRO Standard_keys
             .DC.l $00ff0000,$00010000,Exit_all
             .IF Debug=1
             .DC.l $00ff0000,$00620000,Help
             .DC.l $00ff0000,$003b0000,Status_F1
             .DC.l $00ff0000,$003c0000,Status_F2
             .DC.l $00ff0000,$003d0000,Status_F3
             .DC.l $00ff0000,$003e0000,Status_F4
             .DC.l $00ff0000,$003f0000,Status_F5
             .DC.l $00ff0000,$00400000,Status_F6
             .DC.l $00ff0000,$00410000,Status_F7
             .DC.l $00ff0000,$00430000,Status_F9
             .DC.l $00ff0000,$00440000,Status_F0
             .ENDIF 
             .ENDM 

             .TEXT 
Basic_DisUpd:          jsr                  Update_status_block
             rts       

             .DATA 
Basic_VblQ:  .DC.l Erase_mouse
             .DC.l Feedb_off
             .DC.l Feedb_on
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0
Basic_ScrQ:  .DC.l Show_updated_status_block
             .DC.l Update_CIL
             .DC.l Update_damage_magic
             .DC.l AutoIcon_switch
             .DC.l 0
Basic_Kev:   Standard_keys 
             .DC.l 0

Map_VblQ:    .DC.l Erase_mouse
             .DC.l Feedb_off
             .DC.l Feedb_on
             .DC.l Draw_mouse
             .DC.l Realtime_step
             .DC.l TimeAutoIcon
             .DC.l 0
Map_ScrQ:    .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Reset_mouse
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l Overweight_check
             .DC.l 0

Map_Kev:     .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             .DC.l $00ff0000,$00720000,Switch_control_icons
             Standard_keys 
             .IF Debug=1
             .DC.l $00ff0000,$00420000,Status_F8  ; In map only !!!
             .ENDIF 
             .DC.l 0

Map_Mev:     .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $04ffff00,$04020100,Switch_control_icons
             .DC.l $00ffff00,$00020200,Change_mouse
             .DC.l $02ffff00,$02020200,Move_mouse
             .DC.l 0

Wait_Kev:    .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0
Wait_Mev:    .DC.l $04000000,$04000000,Pop_Module
             .DC.l $08000000,$08000000,Pop_Module
             .DC.l 0

Double_Kev:  .DC.l $00ff0000,$00390000,Double_Pop
             Standard_keys 
             .DC.l 0
Double_Mev:  .DC.l $04000000,$04000000,Double_Pop
             .DC.l $08000000,$08000000,Double_Pop
             .DC.l 0

; ************* Buffer module *****************************
Buffer_Mod:  .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l Exit_program
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Buffer module.",0
             .EVEN 

; ************* 2D Wilderness map *************************
W2map_Mod:   .DC.l W2_DisUpd
             .DC.l Map_VblQ
             .DC.l Map_ScrQ
             .DC.l Map_Mev
             .DC.l Map_Kev
             .DC.l W2_ModInit
             .DC.l W2_ModExit
             .DC.l W2_DisInit
             .DC.l W2_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "2D Wilderness map.",0
             .EVEN 

; ************* 2D City map *******************************
C2map_Mod:   .DC.l C2_DisUpd
             .DC.l Map_VblQ
             .DC.l Map_ScrQ
             .DC.l Map_Mev
             .DC.l Map_Kev
             .DC.l C2_ModInit
             .DC.l C2_ModExit
             .DC.l C2_DisInit
             .DC.l C2_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "2D City map.",0
             .EVEN 

; ************* 3D Dungeon map ****************************
D3map_Mod:   .DC.l D3_DisUpd
             .DC.l Map_VblQ
             .DC.l Map_ScrQ
             .DC.l Map_Mev
             .DC.l Map_Kev
             .DC.l D3_ModInit
             .DC.l D3_ModExit
             .DC.l D3_DisInit
             .DC.l D3_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "3D Dungeon map.",0
             .EVEN 

; ************* 3D City map *******************************
C3map_Mod:   .DC.l C3_DisUpd
             .DC.l Map_VblQ
             .DC.l Map_ScrQ
             .DC.l Map_Mev
             .DC.l Map_Kev
             .DC.l C3_ModInit
             .DC.l C3_ModExit
             .DC.l C3_DisInit
             .DC.l C3_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "3D City map.",0
             .EVEN 

; ************* 2D Eye action *****************************
Eye2D_Mod:   .DC.l 0   ; Copy from previous module
             .DC.l Map_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 17

.ID:         .DC.b "2D Eye action.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$00390000,Eye_exit
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $0c000000,$08000000,Eye_clicked
             .DC.l $0c000000,$04000000,Eye_exit
             .DC.l 0

; ************* 80x80 pics ********************************
Pic80_Mod:   .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l P80_ModInit
             .DC.l P80_ModExit
             .DC.l P80_DisInit
             .DC.l P80_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "80x80 picture.",0
             .EVEN 

; ************* Text window *******************************
TxtW_Mod:    .DC.l Basic_DisUpd
             .DC.l .VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l TxtW_ModInit
             .DC.l TxtW_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Text window.",0
             .EVEN 
.VblQ:       .DC.l Erase_mouse
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0
.Mev:        .DC.l $04000000,$04000000,Pop_Module
             .DC.l 0

; ************* Transfer Item Victim Select ***************

TIVS_Mev:    .DC.l $08ff0000,$08010000,TIVS_Action
             .DC.l $04ff0000,$04010000,Pop_Module
             .DC.l 0
TIVS_VblQ:   .DC.l Erase_mouse
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0

TIVS1_Mod:   .DC.l TIVS_DisUpd
             .DC.l TIVS_VblQ
             .DC.l .ScrQ
             .DC.l TIVS_Mev
             .DC.l Wait_Kev
             .DC.l TIVS_ModInit
             .DC.l TIVS_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 24  ; User defined
.ID:         .DC.b "Transfer Item Victim Select 1.",0
             .EVEN 

.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l AutoIcon_switch
             .DC.l 0

TIVS2_Mod:   .DC.l TIVS_DisUpd
             .DC.l TIVS_VblQ
             .DC.l Basic_ScrQ
             .DC.l TIVS_Mev
             .DC.l Wait_Kev
             .DC.l TIVS_ModInit
             .DC.l TIVS_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 24  ; User defined
.ID:         .DC.b "Transfer Item Victim Select 2.",0
             .EVEN 

; ************* Inventory I *******************************
Inv1_Mod:    .DC.l Inv1_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Inv1_ModInit
             .DC.l Inv1_ModExit
             .DC.l Inv1_DisInit
             .DC.l Inv1_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory I.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Inv1_Mright
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Inventory II ******************************
Inv2_Mod:    .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Inv2_DisInit
             .DC.l Inv2_DisExit
             .DC.l Inv2_DisInit
             .DC.l Inv2_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Upd_objname_print
             .DC.l Upd_objname_erase
             .DC.l Update_CIL
             .DC.l Update_weight
             .DC.l Update_character_info
             .DC.l AutoIcon_switch
             .DC.l Overweight_check
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Inv2_Mright
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $0cffff00,$08020200,Unequip_item
             .DC.l $0cffff00,$08020300,Equip_item
             .DC.l $0fffff00,$00020200,Show_object_name
             .DC.l $0fffff00,$00020300,Show_object_name
             .DC.l $0f000000,$00000000,Erase_object_name
             .DC.l 0
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Inventory II - Drop item ******************
Inv2_ScrQ:   .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Upd_objname_print
             .DC.l Upd_objname_erase
             .DC.l AutoIcon_switch
             .DC.l 0

DropItem_Mod:          .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l Inv2_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l DropItem_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - Drop item.",0
             .EVEN 

.Mev:        .DC.l $0fffff00,$00020200,Show_object_name
             .DC.l $0fffff00,$00020300,Show_object_name
             .DC.l $0cffff00,$08020300,Do_DropItem
             .DC.l $0f000000,$00000000,Erase_object_name
             .DC.l $0c000000,$04000000,Exit_DropItem
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Exit_DropItem
             Standard_keys 
             .DC.l 0

; ************* Multiple Item Drop window *****************
ItemW_Mev:   .DC.l $08ffff00,$08010100,ItemW_1Up
             .DC.l $08ffff00,$08010200,ItemW_1Down
             .DC.l $02ffff00,$02010100,ItemW_Up
             .DC.l $02ffff00,$02010200,ItemW_Down
             .DC.l $02ffff00,$02010300,Pop_Module
             .DC.l $20000000,$20000000,Clear_adding
             .DC.l $20000000,$20000000,Clear_adding
             .DC.l 0
ItemW_Kev:   .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

DropMItem_Mod:         
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l DropMItem_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l DropMItem_Return
             .DC.w 0

.ID:         .DC.b "Inventory II - Multiple Item Drop window.",0
             .EVEN 

; ************* Inventory II - Use item *******************
UseItem_Mod: .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l Inv2_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l UseItem_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - Use item.",0
             .EVEN 
.Mev:        .DC.l $0fffff00,$00020200,Show_object_name
             .DC.l $0fffff00,$00020300,Show_object_name
             .DC.l $0cffff00,$08020200,Use_body_item
             .DC.l $0cffff00,$08020300,Use_backpack_item
             .DC.l $0f000000,$00000000,Erase_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Inventory II - View item ******************
ViewItem_Mod:          .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l Inv2_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l ViewItem_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - View item.",0
             .EVEN 
.Mev:        .DC.l $0fffff00,$00020200,Show_object_name
             .DC.l $0fffff00,$00020300,Show_object_name
             .DC.l $0cffff00,$08020200,Do_view_body_item
             .DC.l $0cffff00,$08020300,Do_view_backpack_item
             .DC.l $0f000000,$00000000,Erase_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Inventory II - Item view window 1 *********
ItemView1_Mod:         
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Double_Kev
             .DC.l ItemViewW1_DisInit
             .DC.l Window_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - Item view window.",0
             .EVEN 
.Mev:        .DC.l $04000000,$04000000,Double_Pop
             .DC.l $08ff0000,$08010000,Open_ExtraW
             .DC.l 0

; ************* Inventory II - Item view window 2 *********
ItemView2_Mod:         
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l Wait_Mev
             .DC.l Wait_Kev
             .DC.l ItemViewW2_DisInit
             .DC.l ItemViewW2_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - Extended item view window.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_CIL
             .DC.l Update_damage_magic
             .DC.l AutoIcon_switch
             .DC.l Accursed_blink
             .DC.l 0

; ************* Inventory II - Transfer item **************
TransferItem_Mod:      
             .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l Inv2_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l TransferItem_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inventory II - Transfer item.",0
             .EVEN 
.Mev:        .DC.l $0fffff00,$00020200,Show_object_name
             .DC.l $0fffff00,$00020300,Show_object_name
             .DC.l $0cffff00,$08020300,Do_TransferItem
             .DC.l $0f000000,$00000000,Erase_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Multiple Item Transfer window *************
TransMItem_Mod:        
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TransMItem_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TransMItem_Return
             .DC.w 0

.ID:         .DC.b "Inventory II - Multiple Item Transfer window.",0
             .EVEN 

; ************* Gold Transfer window **********************
TransGold_Mod:         
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TransGold_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TransGold_Return
             .DC.w 0

.ID:         .DC.b "Inventory II - Gold Transfer window.",0
             .EVEN 

; ************* Food Transfer window **********************
TransFood_Mod:         
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TransFood_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TransFood_Return
             .DC.w 0

.ID:         .DC.b "Inventory II - Food Transfer window.",0
             .EVEN 

; ************* Door event ********************************
Door_Mod:    .DC.l Door_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Door_ModInit
             .DC.l Door_ModExit
             .DC.l Door_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Open door.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0

; ************* Open door - Use Item **********************
UseItemDoor_Mod:       
             .DC.l UseItemDoor_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l UseItemDoor_DisInit
             .DC.l UseItemDoor_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Open door - Use item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,UseItemDoor_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Item Found events *************************

Chest_Kev:   .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

ClosedChest_Mod:       
             .DC.l ClosedChest_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Chest_Kev
             .DC.l ClosedChest_ModInit
             .DC.l ClosedChest_ModExit
             .DC.l ClosedChest_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Closed chest event.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0

OpenedChest_Mod:       
             .DC.l OpenedChest_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Chest_Kev
             .DC.l OpenedChest_ModInit
             .DC.l OpenedChest_ModExit
             .DC.l OpenedChest_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Opened chest event.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Update_CIL
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Closed chest - Use Item *******************
UseItemChest_Mod:      
             .DC.l UseItemDoor_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l UseItemDoor_DisInit
             .DC.l UseItemDoor_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Closed chest - Use item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,UseItemChest_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Opened chest - Transfer Item **************
TIChest_Mod: 
             .DC.l OpenedChest_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l TIChest_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Opened chest - Transfer item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0cffff00,$08020200,Do_TIChest
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Opened chest - Gold Transfer window *******
TransGoldCHEST_Mod:    
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TGCHEST_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TGCHEST_Return
             .DC.w 0

.ID:         .DC.b "Opened chest - Gold Transfer window.",0
             .EVEN 

; ************* Riddle-mouth event ************************
RiddleM_Mod: .DC.l RiddleM_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l RiddleM_ModInit
             .DC.l RiddleM_ModExit
             .DC.l RiddleM_DisInit
             .DC.l RiddleM_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Riddle mouth.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0

; ************* Scrolling Text module *********************
ScrollTxt_Mod:         
             .DC.l 0
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l Mr_Blue_Sky
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Scrolling text."
             .EVEN 

; ************* Word input window *************************
WordIn_Mod:  
             .DC.l 0
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l Do_WordIn
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Word input window.",0
             .EVEN 

; ************* Word Select window ************************
WSelW_Mod:   
             .DC.l WSelW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l WSelW_ModInit
             .DC.l WSelW_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Word select window.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,WordSelected
             .DC.l $02ff0000,$02020000,InputWord
             .DC.l $02ff0000,$02050000,ExitWordSelect
             .DC.l $0cff0000,$04030000,WordSel_8Up
             .DC.l $0cff0000,$04040000,WordSel_8Down
             .DC.l $03ff0000,$01030000,WordSel_X8Up
             .DC.l $03ff0000,$01040000,WordSel_X8Down
             .DC.l $0cff0000,$08030000,WordSel_1Up
             .DC.l $0cff0000,$08040000,WordSel_1Down
             .DC.l $03ff0000,$02030000,WordSel_X1Up
             .DC.l $03ff0000,$02040000,WordSel_X1Down
             .DC.l $10000000,$10000000,Clear_adding
             .DC.l $20000000,$20000000,Clear_adding
             .DC.l 0

; ************* Places events *****************************
Places_Mev:  .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0
Places_Kev:  .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

Guild_Mod:   
             .DC.l Guild_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l Guild_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Guild.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,Guild_Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0

MerchOBJC_Mod:         
             .DC.l MerchOBJC_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchOBJC_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Object merchant.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l Display2_quantities
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

MerchFOOD_Mod:         
             .DC.l MerchFOOD_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Places_Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchFOOD_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Food merchant.",0
             .EVEN 

MerchHORSE_Mod:        
             .DC.l MerchHORSE_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Places_Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchHORSE_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Horse merchant.",0
             .EVEN 

Healer_Mod:  
             .DC.l Healer_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Places_Kev
             .DC.l Healer_ModInit
             .DC.l Places_ModExit
             .DC.l Healer_DisInit
             .DC.l Healer_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Healer.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l Display_Ankh
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Healer_Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $02ffff00,$02020200,Heal_condition
             .DC.l 0

Sage_Mod:    
             .DC.l Sage_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l Sage_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Sage.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Sage_Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $02ffff00,$02020200,Lore_item
             .DC.l 0

MerchRAFT_Mod:         
             .DC.l MerchRAFT_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Places_Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchRAFT_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Raft merchant.",0
             .EVEN 

MerchSHIP_Mod:         
             .DC.l MerchSHIP_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Places_Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchSHIP_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Ship merchant.",0
             .EVEN 

Inn_Mod:     
             .DC.l Inn_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Places_Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l Inn_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Inn.",0
             .EVEN 

MerchMAGIC_Mod:        
             .DC.l MerchMAGIC_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Places_Kev
             .DC.l Places_ModInit
             .DC.l Places_ModExit
             .DC.l MerchMAGIC_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Places event - Magic merchant.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l AutoIcon_switch
             .DC.l Display2_quantities
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Places - General actions ******************
TransGoldPLACES_Mod:   
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TGCHEST_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TGPLACES_Return
             .DC.w 0

.ID:         .DC.b "Places event - Gold Transfer window.",0
             .EVEN 

; ************* Riddlemouth message ***********************
RiddleMes_Mod:         
             .DC.l 0
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l RiddleMes
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Riddlemouth message.",0
             .EVEN 

; ************* Skill Select window ***********************
SkillW_Mod:  
             .DC.l SkillW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l SkillW_ModInit
             .DC.l SkillW_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Skill select window.",0
             .EVEN 
.Mev:        .DC.l $0cff0000,$04010000,Dec_skill
             .DC.l $0cff0000,$08010000,Inc_skill
             .DC.l $02ff0000,$02020000,Exit_SkillW
             .DC.l 0

; ************* 2D Mouth action ***************************
Mouth2D_Mod: .DC.l 0   ; Copy from previous module
             .DC.l Map_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 18

.ID:         .DC.b "2D Mouth action.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$00390000,Eye_exit
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $0c000000,$08000000,Mouth_clicked
             .DC.l $0c000000,$04000000,Eye_exit
             .DC.l 0

; ************* Object merchant - Sell item **************************
SellItem_Mod:          
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l SellItem_DisInit
             .DC.l SellItem_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Object merchant - Sell item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd3_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,SellItem_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show3_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Multiple Item Sell window *****************
SellMItem_Mod:         
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l SellMItem_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l SellMItem_Return
             .DC.w 0

.ID:         .DC.b "Object merchant - Multiple Item Sell window.",0
             .EVEN 

; ************* Sell requester ****************************
SellReq_Mod: 
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l SellReq_ModInit
             .DC.l SellReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Object merchant - Sell requester.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,SellYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Object merchant - Buy item ****************
BuyItem_Mod: 
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l BuyItem_DisInit
             .DC.l BuyItem_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Object merchant - Buy item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd4_objname_print
             .DC.l Upd4_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,BuyItem_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show4_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* Multiple Item Buy window ******************
BuyMItem_Mod:          
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l BuyMItem_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l BuyMItem_Return
             .DC.w 0

.ID:         .DC.b "Object merchant - Multiple Item Buy window.",0
             .EVEN 

; ************* Buy requester *****************************
BuyReq_Mod:  
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l BuyReq_ModInit
             .DC.l BuyReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Object merchant - Buy requester.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,BuyYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Object merchant - Transfer Item ***********
TIMOBJC_Mod: 
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l TIMOBJC_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Object merchant - Transfer item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0cffff00,$08020200,Do_TIMOBJC
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Object merchant - Multiple Item Transfer **
TMI_MOBJC_Mod:         
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TMI_MOBJC_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TMI_MOBJC_Return
             .DC.w 0

.ID:         .DC.b "Object merchant - Multiple Item Transfer window.",0
             .EVEN 

; ************* Buy horse requester ***********************
BuyHORSEReq_Mod:       
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l BuyHORSEReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Horse merchant - Buy requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,BuyHORSEYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Buy raft requester ************************
BuyRAFTReq_Mod:        
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l BuyRAFTReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Raft merchant - Buy requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,BuyRAFTYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Buy ship requester ************************
BuySHIPReq_Mod:        
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l BuySHIPReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Ship merchant - Buy requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,BuySHIPYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Heal condition requester ******************
HealCondReq_Mod:       
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l HealCondReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Healer - Heal condition requester.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l AutoIcon_switch
             .DC.l Display_Ankh
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,HealCondYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Remove curse requester ********************
RemCurseReq_Mod:       
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l RemCurseReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Healer - Remove curse requester.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l AutoIcon_switch
             .DC.l Display_Ankh
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,RemCurseYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Remove cursed objects *********************
RemCurse_Mod:          .DC.l 0
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l 0
             .DC.l 0
             .DC.l RemCurse_DisInit
             .DC.l Inv2_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Remove cursed objects.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Update_weight
             .DC.l Update_character_info
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0

; ************* Select active character *******************
ActSel_Mod:  .DC.l ActSel_DisUpd
             .DC.l .VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l ActSel_ModInit
             .DC.l ActSel_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "New active character select.",0
             .EVEN 
.VblQ:       .DC.l Erase_mouse
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0

; ************* Lore item requester ***********************
LoreItemReq_Mod:       
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l LoreItemReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Sage - Lore item requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,LoreItemYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Guestroom requester ***********************
GuestroomReq_Mod:      
             .DC.l BuyTRANSReq_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l GuestroomReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Inn - Guestroom requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,GuestroomYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Automapper ********************************
Automap_Mod: .DC.l Automap_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Automap_ModInit
             .DC.l Automap_ModExit
             .DC.l Automap_DisInit
             .DC.l Automap_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Automapper.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0

; ************* Dialogue screen ***************************
Dialogue_Mod:          .DC.l Dialogue_DisUpd
             .DC.l .VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Dialogue_ModInit
             .DC.l Dialogue_ModExit
             .DC.l Dialogue_DisInit
             .DC.l Dialogue_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Dialogue screen.",0
             .EVEN 
.VblQ:       .DC.l Erase_mouse
             .DC.l Feedb_off
             .DC.l Feedb_on
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_CIL
             .DC.l Update_damage_magic
             .DC.l AutoIcon_switch
             .DC.l Upd5_objname_print
             .DC.l Upd5_objname_erase
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Dialogue - Transfer Item ******************
TIDIA_Mod:   
             .DC.l Dialogue_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l TIDIA_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Dialogue - Transfer item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd5_objname_print
             .DC.l Upd5_objname_erase
             .DC.l Update_CIL
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0cffff00,$08020200,Do_TIDIA
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Dialogue - Show Item **********************
ShowItem_Mod:          
             .DC.l ShowItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l ShowItem_DisInit
             .DC.l ShowItem_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Dialogue - Show item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd5_objname_print
             .DC.l Upd5_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,ShowItem_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Dialogue - Give Item **********************
GiveItem_Mod:          
             .DC.l ShowItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l GiveItem_DisInit
             .DC.l ShowItem_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Dialogue - Give item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd5_objname_print
             .DC.l Upd5_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,GiveItem_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Dialogue - Give Gold **********************
DIATransGold_Mod:      
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TGCHEST_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l DIATG_Return
             .DC.w 0

.ID:         .DC.b "Dialogue - Give gold window.",0
             .EVEN 

; ************* Dialogue - Give Food **********************
DIATransFood_Mod:      
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TransFood_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l DIATF_Return
             .DC.w 0

.ID:         .DC.b "Dialogue - Give food window.",0
             .EVEN 

; ************* Dialogue - Drop Item **********************
DIADropItem_Mod:       
             .DC.l Dialogue_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l DIADropItem_DisInit
             .DC.l Transparent_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Dialogue - Drop item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd5_objname_print
             .DC.l Upd5_objname_erase
             .DC.l Update_CIL
             .DC.l AutoIcon_switch
             .DC.l 0
.Mev:        .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0cffff00,$08020200,Do_DIADropItem
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l $0c000000,$04000000,Pop_Module
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Options menu ******************************
Options_Mod: 
             .DC.l Options_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Options_DisInit
             .DC.l Options_DisExit
             .DC.l Options_DisInit
             .DC.l Options_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Options menu.",0
             .EVEN 

.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Camp screen *******************************
Camp_Mod:    
             .DC.l Camp_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Camp_ModInit
             .DC.l Camp_ModExit
             .DC.l Camp_DisInit
             .DC.l Fadeout_lay3
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Camp screen.",0
             .EVEN 

.Mev:        .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l 0
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Camp - Learn spell ************************
LearnSpell_Mod:        
             .DC.l Camp_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l LearnSpell_DisInit
             .DC.l LearnSpell_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0
.ID:         .DC.b "Camp - Learn spell.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,LearnSpell_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Pop_Module
             Standard_keys 
             .DC.l 0

; ************* Magic - Spell class select window *********
SCSelW_Mod:  
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l SCSelW_DisInit
             .DC.l SCSelW_DisExit
             .DC.l SCSelW_DisInit
             .DC.l SCSelW_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Spell class select window.",0
             .EVEN 

.Mev:        .DC.l $02ff0000,$02010000,ClassSelected
             .DC.l $04000000,$04000000,Exit_SCSelW
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Exit_SCSelW
             Standard_keys 
             .DC.l 0

; ************* Spell victim select ***********************
VictimSel_Mod:         
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l VictimSel_ModInit
             .DC.l VictimSel_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Spell victim select.",0
             .EVEN 
.Mev:        .DC.l $08ff0000,$08010000,Victim_clicked
             .DC.l $04ff0000,$04010000,Pop_Module
             .DC.l 0

; ************* Remove cursed object **********************
RemCurse2_Mod:         
             .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l RemCurse2_DisInit
             .DC.l RemCurse2_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Magic - Remove cursed object.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Update_weight
             .DC.l Update_character_info
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $0cffff00,$08020200,Do_RemCurse
             .DC.l $0c000000,$04000000,Exit_RemCurse
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Exit_RemCurse
             Standard_keys 
             .DC.l 0

; ************* Special text window ***********************
HearTxtW_Mod:          .DC.l Basic_DisUpd
             .DC.l .VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l HearTxtW_ModInit
             .DC.l TxtW_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Special text window.",0
             .EVEN 
.VblQ:       .DC.l Erase_mouse
             .DC.l Draw_mouse
             .DC.l TimeAutoIcon
             .DC.l 0
.Mev:        .DC.l $04000000,$04000000,Pop_Module
             .DC.l 0

; ************* Food merchant - Transfer food *************
TFMFOOD_Mod: 
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l TransFood_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l TFMFOOD_Return
             .DC.w 0

.ID:         .DC.b "Food merchant - Food Transfer window.",0
             .EVEN 

; ************* Buy food requester ************************
BuyFoodReq_Mod:        
             .DC.l MerchFOOD_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l BuyFoodReq_ModInit
             .DC.l BuyTRANSReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Food merchant - Buy requester.",0
             .EVEN 
.Mev:        .DC.l $02ffff00,$02020100,BuyFoodYes
             .DC.l $02ffff00,$02020200,Pop_Module
             .DC.l 0

; ************* Buy food **********************************
BuyFood_Mod: 
             .DC.l ItemW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l ItemW_Mev
             .DC.l ItemW_Kev
             .DC.l BuyFood_DisInit
             .DC.l ItemW_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l BuyFood_Return
             .DC.w 0

.ID:         .DC.b "Food merchant - Buy food.",0
             .EVEN 

; ************* Combat requester **************************
CombatReq_Mod:         
             .DC.l 0
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l CombatReq_ModInit
             .DC.l CombatReq_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Combat requester.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,CombatYes
             .DC.l $02ff0000,$02020000,CombatNo
             .DC.l 0

; ************* Combat screen *****************************
Combat_Mod:  .DC.l Combat_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l Wait_Mev                 ;.Mev
             .DC.l Wait_Kev                 ;.Kev
             .DC.l Combat_ModInit
             .DC.l Combat_ModExit
             .DC.l Combat_DisInit
             .DC.l Combat_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Combat screen.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0

; ************* Spell Select window ***********************
SpSelW_Mod:  
             .DC.l SpSelW_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l SpSelW_ModInit
             .DC.l SpSelW_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l Do_magic
             .DC.w 0

.ID:         .DC.b "Spell select window.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,SpellSelected
             .DC.l $02ff0000,$02040000,ExitSpellSelect
             .DC.l $0cff0000,$04020000,SpSel_8Up
             .DC.l $0cff0000,$04030000,SpSel_8Down
             .DC.l $03ff0000,$01020000,SpSel_X8Up
             .DC.l $03ff0000,$01030000,SpSel_X8Down
             .DC.l $0cff0000,$08020000,SpSel_1Up
             .DC.l $0cff0000,$08030000,SpSel_1Down
             .DC.l $03ff0000,$02020000,SpSel_X1Up
             .DC.l $03ff0000,$02030000,SpSel_X1Down
             .DC.l $10000000,$10000000,Clear_adding
             .DC.l $20000000,$20000000,Clear_adding
             .DC.l 0

; ************* Save game *********************************
SaveGame_Mod:          
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l SaveGame_ModInit
             .DC.l SaveGame_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Save game.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,Portrait_selected
             .DC.l $02ff0000,$02020000,Do_SaveGame
             .DC.l $02ff0000,$02030000,Exit_SaveGame
             .DC.l 0

; ************* Magic Compass *****************************
MagicCompass_Mod:      
             .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l Wait_Mev
             .DC.l Wait_Kev
             .DC.l MagicComp_DisInit
             .DC.l MagicComp_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Magic compass window.",0
             .EVEN 

; ************* Lore object *******************************
Lore_Mod:    
             .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Lore_DisInit
             .DC.l RemCurse2_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Magic - Lore object.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Update_weight
             .DC.l Update_character_info
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $0cffff00,$08020200,Do_Lore
             .DC.l $0c000000,$04000000,Exit_RemCurse
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Exit_RemCurse
             Standard_keys 
             .DC.l 0

; ************* Gunk weapon *******************************
Gunk_Mod:    
             .DC.l Inv2_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Gunk_DisInit
             .DC.l RemCurse2_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Magic - Gunk weapon.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Display_quantities
             .DC.l Update_weight
             .DC.l Update_character_info
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $0cffff00,$08020200,Do_Gunk
             .DC.l $0c000000,$04000000,Exit_RemCurse
             .DC.l 0
.Kev:        .DC.l $00ff0000,$00390000,Exit_RemCurse
             Standard_keys 
             .DC.l 0

; ************* Minimap ***********************************
Minimap_Mod: .DC.l Minimap_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l .Kev
             .DC.l Minimap_ModInit
             .DC.l Minimap_ModExit
             .DC.l Minimap_DisInit
             .DC.l Minimap_DisExit
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Minimap.",0
             .EVEN 
.Kev:        .DC.l $00ff0000,$006d0000,Icon_7
             .DC.l $00ff0000,$006e0000,Icon_8
             .DC.l $00ff0000,$006f0000,Icon_9
             .DC.l $00ff0000,$006a0000,Icon_4
             .DC.l $00ff0000,$006b0000,Icon_5
             .DC.l $00ff0000,$006c0000,Icon_6
             .DC.l $00ff0000,$00670000,Icon_1
             .DC.l $00ff0000,$00680000,Icon_2
             .DC.l $00ff0000,$00690000,Icon_3
             Standard_keys 
             .DC.l 0
.Mev:        .DC.l $02ff0000,$02010000,Member_left
             .DC.l $01ff0000,$01010000,Member_right
             .DC.l $02ffff00,$02020100,Do_control_icons
             .DC.l 0

; ************* Object merchant - View item ***************
ViewItemMOBJC_Mod:     
             .DC.l SellItem_DisUpd
             .DC.l Basic_VblQ
             .DC.l .ScrQ
             .DC.l .Mev
             .DC.l Wait_Kev
             .DC.l ViewItemMOBJC_DisInit
             .DC.l BuyItem_DisExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "Object merchant - View item.",0
             .EVEN 
.ScrQ:       .DC.l Show_updated_status_block
             .DC.l Update_damage_magic
             .DC.l Upd2_objname_print
             .DC.l Upd2_objname_erase
             .DC.l Display2_quantities
             .DC.l AutoIcon_switch
             .DC.l Update_CIL
             .DC.l 0
.Mev:        .DC.l $02ffff00,$02020200,ViewItem_objselect
             .DC.l $04000000,$04000000,Pop_Module
             .DC.l $0fffff00,$00020200,Show2_object_name
             .DC.l $0f000000,$00000000,Erase2_object_name
             .DC.l 0

; ************* General requester *************************
Req_Mod:     .DC.l Basic_DisUpd
             .DC.l Basic_VblQ
             .DC.l Basic_ScrQ
             .DC.l .Mev
             .DC.l Basic_Kev
             .DC.l Req_ModInit
             .DC.l Req_ModExit
             .DC.l 0
             .DC.l 0
             .DC.l .ID
             .DC.l 0
             .DC.w 0

.ID:         .DC.b "General requester.",0
             .EVEN 
.Mev:        .DC.l $02ff0000,$02010000,Req_Yes
             .DC.l $02ff0000,$02020000,Pop_Module
             .DC.l 0

             .END 
















