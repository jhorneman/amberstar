
; 3D Dungeon map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 17-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "Let's get our hearts together
;     And as before, and like before
;      We'll do again"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :
;   -

             .TEXT 
;*****************************************************************************
; [ Initialize 3D dungeon map ] TYPE 2
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
D3_ModInit:  
             Pop       MA
             move.l    a5,Mapd_ptr          ; Store pointer to map data
             jsr       Prepare_3D_map
             jsr       Init_persons         ; Initialize character handler
             jsr       D3_DisInit
             jsr       Event_handler        ; Handle first event
             rts       

;*****************************************************************************
; [ Initialize 3D dungeon display ] TYPE 2
; All registers are restored
;*****************************************************************************
D3_DisInit:  
             movea.l   Mapd_ptr,a5          ; Get pointer to map data
             jsr       Set_spell_area
; ------------- Initialize display -----------------------------------
             movea.l   Off_screen,a6        ; Get screen base
             moveq.l   #5,d0                ; Show 2D map layout
             jsr       Show_layout
             jsr       Print_headline
             move.l    #M3_CIL,First_CIL_ptr      ; Display control icons
             jsr       Handle_CIL
             jsr       Show_control_icons
             jsr       D3_DisUpd            ; Display 3D map
             Update_screen 
; ------------- Various installations --------------------------------
             sf        Time_lock
             lea.l     Lay5_c1,a0           ; Object branch
             jsr       Set_layout_data
             move.l    #M3_CIL+10,Mousemove_ptr   ; Mouse actions
; ------------- Fade-in display --------------------------------------
             movea.l   Colpall_ptrs,a0      ; Convert IFF-palette
             lea.l     Pal_buffer,a1
             jsr       IFF_pal_convert
             lea.l     Subfade1,a2          ; Fade in
.Again:      lea.l     Hbl_D3_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_D3,a0      ; Fade
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_D3_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ Exit 3D dungeon map ]
; All registers are restored
;*****************************************************************************
D3_ModExit:  
             jsr       Clear_persons_buffer
             jsr       Exit_automap
             movea.l   Mapd_ptr,a0          ; Free memory
             jsr       Free_memory
             lea.l     Labblock_ptrs,a1
             move.w    Nr_labblocks,d7
.Loop:       movea.l   (a1)+,a0
             jsr       Free_memory
             dbra      d7,.Loop
             movea.l   Ceiling_ptr,a0
             jsr       Free_memory
             movea.l   Floor_ptr,a0
             jsr       Free_memory
             movea.l   Colpall_ptrs,a0
             jsr       Free_memory
             movea.l   Maptext_ptr,a0
             jsr       Free_memory
             jsr       Next_generation
             rts       

;*****************************************************************************
; [ Exit 3D dungeon map display]
; All registers are restored
;*****************************************************************************
D3_DisExit:  
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_D3_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_D3,a0      ; Fade palette
             jsr       Fade_pal
             bne.s     .Again
             lea.l     Hbl_D3_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ Display 3D dungeon ]
; All registers are restored
;*****************************************************************************
D3_DisUpd:   
             movem.l   d0-d3/d6/d7/a0/a6,-(sp)
             jsr       Cut_from_3D_map      ; Cut from 3D map
; ------------- Display ceiling & floor ------------------------------
             move.w    Map_Xcoord,d2        ; Calculate mirror flag
             move.w    Map_Ycoord,d3
             eor.w     d3,d2
             andi.w    #$1,d2
             movea.l   Off_screen,a6        ; Get screen base
             movea.l   Ceiling_ptr,a0       ; Get pointer to ceiling
             lea.l     Bg_elements+4(a0),a0
             moveq.l   #Topleft_X,d0        ; Display ceiling
             moveq.l   #Topleft_Y,d1
             move.w    (a0)+,d6
             addq.w    #1,d6
             lsr.w     #4,d6
             move.w    (a0)+,d7
             addq.w    #1,d7
             addq.l    #2,a0
             tst.w     d2                   ; Mirror ?
             bne.s     .Mirror_1
             jsr       Blot_unmasked_block
             bra.s     .Cont_1
.Mirror_1:   jsr       Blot_mirrored_unmasked_block
.Cont_1:     movea.l   Floor_ptr,a0         ; Get pointer to floor
             lea.l     Bg_elements+4(a0),a0
             add.w     d7,d1                ; Display floor
             move.w    (a0)+,d6
             addq.w    #1,d6
             lsr.w     #4,d6
             move.w    (a0)+,d7
             addq.w    #1,d7
             addq.l    #2,a0
             tst.w     d2                   ; Mirror ?
             beq.s     .Mirror_2
             jsr       Blot_unmasked_block
             bra.s     .Cont_2
.Mirror_2:   jsr       Blot_mirrored_unmasked_block
.Cont_2:     .LOCAL 
             tst.b     Pause_Upd            ; Start combat ?
             bne.s     .Skip
             jsr       ThreeD_char_handler  ; Handle persons
.Skip:       jsr       Build_3D_map         ; Build 3D map
             jsr       Update_map_CIL
             tst.b     CombatReq            ; Start combat ?
             beq.s     .Exit
             Push      Module,CombatReq_Mod
.Exit:       movem.l   (sp)+,d0-d3/d6/d7/a0/a6
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .SECTION 8,DATA
Hbl_D3_map:  .DC.w $ff00                    ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
             .DC.b 36,0
Below_pal_D3:          .DCB.w 16,0
             .DC.w 0

             .END 
















