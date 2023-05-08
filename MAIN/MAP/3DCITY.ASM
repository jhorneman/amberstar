
; 3D City map routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 17-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;   "To know there's so many ways
;     The force of nature prevails
;      I lay down, I lay down and I pray"
;   Let's Pretend, Anderson, Bruford, Wakeman & Howe, 1989

; NOTES :
;   - The sky colour routines assume a day has 24 hours.

             .TEXT 
;*****************************************************************************
; [ Initialize 3D city map ] TYPE 3
;   IN : a5 - Pointer to map data (.l)
; All registers are restored
;*****************************************************************************
C3_ModInit:  
             Pop       MA
             move.l    a5,Mapd_ptr          ; Store pointer to map data
             jsr       Prepare_3D_map
; ------------- Initialize palettes ----------------------------------
             movea.l   Colpall_ptrs,a0      ; Convert IFF-palette
             lea.l     Skypal_buffer,a1
             jsr       IFF_pal_convert
             move.w    22(a1),d0            ; Restore colour 11
             move.w    d0,Old_11
             move.w    d0,Day_pal+166
             move.w    d0,Dawndusk_pal+166
             move.w    d0,Night_pal+166
; ------------- Determine sky graphics & colours ---------------------
             movea.l   Ceiling_ptr,a0       ; Get sky graphics pointers
             lea.l     Bg_elements(a0),a0
             movea.l   a0,a1
             adda.l    (a1)+,a1
             addq.l    #4,a0                ; Skip lengths
             addq.l    #4,a1
             lea.l     Night_pal,a2         ; Night colours
             move.w    Hour,d0              ; Get current hour
             cmpi.w    #6,d0                ; Start of dawn ?
             bmi.s     .End
             cmpi.w    #8,d0                ; End of dawn ?
             bpl.s     .Not_1
             lea.l     Dawndusk_pal,a2      ; Dawn colours
             bra.s     .End
.Not_1:      cmpi.w    #18,d0               ; Start of dusk ?
             bpl.s     .Not_2
             lea.l     Day_pal,a2           ; Day colours
             exg.l     a0,a1                ; Clouds
             bra.s     .End
.Not_2:      cmpi.w    #20,d0               ; End of dusk ?
             bpl.s     .End
             lea.l     Dawndusk_pal,a2      ; Dusk colours
             exg.l     a0,a1                ; Clouds
.End:        move.l    a0,Sky_ptr           ; Store sky parameters
             lea.l     Skypal_buffer+32,a0  ; Copy colours
             lea.l     Sky_pal_C3+4,a1
             moveq.l   #83-1,d7
.Loop_2:     move.w    (a2),(a0)+           ; Copy
             move.w    (a2)+,(a1)
             addq.l    #6,a1
             dbra      d7,.Loop_2
             jsr       Init_persons         ; Initialize character handler
             jsr       C3_DisInit
             jsr       Event_handler        ; Handle first event
.Exit:       rts       

;*****************************************************************************
; [ Initialize 3D city map display ] TYPE 3
; All registers are restored
;*****************************************************************************
C3_DisInit:  
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
             jsr       C3_DisUpd            ; Display 3D map
             Update_screen 
; ------------- Various installations --------------------------------
             sf        Time_lock
             lea.l     Lay5_c1,a0           ; Object branch
             jsr       Set_layout_data
             move.l    #M3_CIL+10,Mousemove_ptr   ; Mouse actions
; ------------- Fade-in display --------------------------------------
             lea.l     Skypal_buffer,a1     ; Fade in
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_C3_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_C3,a0      ; Fade
             jsr       List_fade
             bne.s     .Again
             lea.l     Hbl_C3_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ Exit 3D city map ]
; All registers are restored
;*****************************************************************************
C3_ModExit:  
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
; [ Exit 3D city map display ]
; All registers are restored
;*****************************************************************************
C3_DisExit:  
             lea.l     Void,a1              ; Fade out
             lea.l     Subfade1,a2
.Again:      lea.l     Hbl_C3_map,a0        ; Update palettes
             jsr       Update_HBL
             jsr       My_vsync             ; Wait 2 Vbl's
             jsr       My_vsync
             lea.l     Below_pal_C3,a0      ; Fade palette
             jsr       Hbl_outfade
             bne.s     .Again
             lea.l     Hbl_C3_map,a0        ; Update palettes
             jsr       Update_HBL
             rts       

;*****************************************************************************
; [ Display 3D city ]
; All registers are restored
;*****************************************************************************
C3_DisUpd:   
             movem.l   d0-d3/d6/d7/a0/a6,-(sp)
             jsr       C3_time_evaluate     ; Re-evaluate
             jsr       Cut_from_3D_map      ; Cut from 3D map
; ------------- Display ceiling & floor ------------------------------
             move.w    Map_Xcoord,d2        ; Calculate mirror flag
             move.w    Map_Ycoord,d3
             eor.w     d3,d2
             andi.w    #$1,d2
             movea.l   Off_screen,a6        ; Get screen base
             movea.l   Sky_ptr,a0           ; Get pointer to ceiling
             moveq.l   #Topleft_X,d0        ; Display ceiling
             moveq.l   #Topleft_Y,d1
             move.w    (a0)+,d6
             addq.w    #1,d6
             lsr.w     #4,d6
             move.w    (a0)+,d7
             addq.w    #1,d7
             addq.l    #2,a0
             btst      #0,View_direction+1  ; Mirror ?
             bne.s     .Mirror
             jsr       Blot_unmasked_block
             bra.s     .Cont
.Mirror:     jsr       Blot_mirrored_unmasked_block
.Cont:       .LOCAL 
             movea.l   Floor_ptr,a0         ; Get pointer to floor
             lea.l     Bg_elements+4(a0),a0
             add.w     d7,d1                ; Display floor
             move.w    (a0)+,d6
             addq.w    #1,d6
             lsr.w     #4,d6
             move.w    (a0)+,d7
             addq.w    #1,d7
             addq.l    #2,a0
             tst.w     d2                   ; Mirror ?
             beq.s     .Mirror
             jsr       Blot_unmasked_block
             bra.s     .Cont
.Mirror:     jsr       Blot_mirrored_unmasked_block
.Cont:       .LOCAL 
             tst.b     Pause_Upd
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
; [ Re-evaluate light & ceiling ]
; All registers are restored
; !!! WARNING !!! This routine assumes the sky parameters were already set !!!
;*****************************************************************************
C3_time_evaluate:      
             movem.l   d0/a0-a2,-(sp)
             tst.b     Blending             ; Blending ?
             beq.s     .Check
             lea.l     Sky_pal_C3,a0        ; Load blend parameters
             movea.l   Blend_ptr,a1
             lea.l     Subfade1,a2
             jsr       List_fade            ; Blend
             sne       Blending             ; Blending complete ?
             bne.s     .Skip
             lea.l     Skypal_buffer+32,a0  ; Copy colours
             moveq.l   #83-1,d7
.Loop:       move.w    (a1)+,(a0)+
             dbra      d7,.Loop
.Skip:       lea.l     Hbl_C3_map,a0        ; Set new palettes
             jsr       Update_HBL
             bra       .Exit
.Check:      move.w    Hour,d0              ; What time is it ?
             cmpi.w    #6,d0                ; Start of dawn ?
             bne.s     .Not_1
             move.l    #Dawndusk_pal,Blend_ptr    ; Blend dawn colours
             st        Blending
             bra       .Exit
.Not_1:      cmpi.w    #8,d0                ; End of dawn ?
             bne.s     .Not_2
             movea.l   Ceiling_ptr,a0       ; Set sky graphics pointer
             lea.l     Bg_elements(a0),a0   ;  to clouds
             adda.l    (a0)+,a0
             addq.l    #4,a0
             move.l    a0,Sky_ptr
             move.l    #Day_pal,Blend_ptr   ; Blend day colours
             st        Blending
             bra.s     .Exit
.Not_2:      cmpi.w    #18,d0               ; Start of dusk ?
             bne.s     .Not_3
             move.l    #Dawndusk_pal,Blend_ptr    ; Blend dusk colours
             st        Blending
             bra.s     .Exit
.Not_3:      cmpi.w    #20,d0               ; End of dusk ?
             bne.s     .Exit
             movea.l   Ceiling_ptr,a0       ; Set sky graphics pointer
             lea.l     Bg_elements+4(a0),a0 ;  to stars
             move.l    a0,Sky_ptr
             move.l    #Night_pal,Blend_ptr ; Blend night colours
             st        Blending
.Exit:       movem.l   (sp)+,d0/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
Blending:    .DS.b 1   ; Blend flag
             .EVEN 
Blend_ptr:   .DS.l 1   ; Pointer to current target colours
Sky_ptr:     .DS.l 1   ; Pointer to correct ceiling block
Skypal_buffer:         .DS.w 99             ; Palette buffer
Old_11:      .DS.w 1

             .SECTION 8,DATA
Hbl_C3_map:  .DC.w $ff00                    ; Dummy word
             .DC.w 0,$750,$333,$222,$111,$742,$631,$200
             .DC.w $566,$345,$754,$643,$532,$421,$310,$765
Below_pal_C3:          .DC.b 36,0
             .DCB.w 16,0                    ; Second palette
Sky_pal_C3:  
y            set 48
             .REPT 83
             .DC.b y,-1                     ; Sky colours
             .DC.w 11
             .DC.w 0
y            set y+1
             .ENDR 
             .DC.b y+1,-1                   ; Colour 11 restoration
             .DC.w 11
             .DC.w 0
             .DC.w 0   ; Sentinel

             .END 




















