
; eXternal REFerences & special macros
; Written by J.Horneman (In Tune With The Universe)
; Start : 18-2-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;*****************************************************************************
; Nucleus functions
;*****************************************************************************
; File functions
             .XREF Init_file,Load_subfile,Load_file,Save_file
             .XREF Exist_file,Read_bytes
; Colour fade functions
             .XREF Fade_pal,List_fade,Hbl_outfade
             .XREF Hbl_fade,Subfade1,Subfade2
; Diagnostic functions
             .XREF DI_Error,ON_Diag_screen,OFF_Diag_screen
             .XREF Init_DI_print,DI_Print,DI_Input
             .XREF DI_Cursor_home,DI_Carriage_return,DI_Backspace
             .XREF DI_Hexb_print,DI_Hexw_print,DI_Hexl_print
             .XREF DI_Decb_print,DI_Decw_print,DI_Decl_print
; Graphic functions
             .XREF Init_gfx,Coord_convert,Draw_box
             .XREF Put_unmasked_block,Put_masked_block
             .XREF Blot_unmasked_block,Blot_masked_block
             .XREF Blit_unmasked_block,Blit_masked_block
             .XREF Duplicate_block,Get2_block
; HBL functions
             .XREF HBL_on,HBL_off,Update_HBL
             .XREF HBL_handler,HBL_flag
             .XREF User_HBL_list,Copy_HBL_list
; Interrupt functions
             .XREF IFF_pal_convert,Random
             .XREF Save_computer,Init_computer,Restore_computer
             .XREF Old_screen,Vbl_count
; Mouse & keyboard functions
             .XREF Init_kbd,Draw_mouse,Erase_mouse
             .XREF Push_Mptr,Pop_Mptr,Change_Mptr
             .XREF Push_MA,Pop_MA,Mouse_on,Mouse_off
             .XREF Read_key,Wait_4_key
             .XREF Mouse_X,Mouse_Y,X_trespass,Y_trespass,Mouse_dX,Mouse_dY
             .XREF Mouse_button_state,Mouse_click_state,Mouse_unclick_state
             .XREF UDMPTR,My_mouse
; Memory functions
             .XREF Init_memory,Next_generation
             .XREF Allocate_memory,Reallocate_memory
             .XREF File_allocate,Kill_memory,Free_memory,Shrink_memory
             .XREF Size_of_free_memory
; Numerical functions
             .XREF Hex_convert,Dec_convert
; Screen handling routines
             .XREF Init_screen,Clear_screen,Copy_screen
             .XREF Set_screen,Switch_screen,My_vsync
             .XREF Off_screen,On_screen,Screen_base
; In-game printing functions
             .XREF IG_Cursor_home,IG_Carriage_return,IG_Backspace
             .XREF IG_Set_ink,IG_Set_paper,IG_Set_cursor
             .XREF IG_Print,PArea

;*****************************************************************************
; In-game routines
;*****************************************************************************
; Object find routines
             .XREF Find_object,Push_Root,Pop_Root,Set_layout_data
             .XREF Translate_object_branch
; Window routines
             .XREF Open_window,Close_window,Blend_block
; Graphics
             .XREF Bot_corners,Bot_masks
             .XREF Topblk_mid,Topblk_left,Topblk_right,Topblk_top,Topblk_bot
             .XREF Daynight_icn,Layout_icn,Control_icn,Status_icn,Objects_icn
             .XREF Chequered,Feedback,Layouts
             .XREF Skull_portrait,Red_bar,Blue_bar
             .XREF Swordshield,RiddleM_graphics,Curse_anim
             .XREF Tactic_icn,Automap_icn,Ouch
             .XREF Day_pal,Night_pal,Dawndusk_pal
; Data files
             .XREF Race_dat,Class_dat,Misc_dat,Spell_dat,Place_dat
             .XREF Code0001Sys,Code0002Sys,Code0003Sys,Code0004Sys
             .XREF Code0005Sys,Code0006Sys,Code0007Sys,Code0008Sys
             .XREF Shadow_table

;*****************************************************************************

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; Strings in separate segment
             .TEXT 
             .ENDM 

             .MACRO Push type,ptr
             .IF \!ptr=9
             lea.l     \ptr,a0              ; If not IMMEDIATE !!!
             .ELSE 
             move.w    \ptr,d0
             .ENDIF 
{"jsr Push_",\type}
             .ENDM 

             .MACRO Pop type
{"jsr Pop_",\type}
             .ENDM 

             .MACRO Wait_4_unclick
.\~Wait:     btst      #1,Mouse_button_state      ; Left mouse button released ?
             bne.s     .\~Wait
             clr.b     Mouse_click_state
             .ENDM 

; Useless macro for EXT.l-ing address register
; Trick by Christian Jungen
;.MACRO exta
;.IF \!1=2
;movea.w    \1,\1                    ; Extend address register
;.ELSE
;.FAIL      ; Fail if input is not an address register
;.ENDIF
;.ENDM

             .MACRO Update_screen
             jsr       Switch_screen
             jsr       Copy_screen
             .ENDM 

             .END 











