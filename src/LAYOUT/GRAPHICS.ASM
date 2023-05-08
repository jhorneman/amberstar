
; Graphics for layouts

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

             .XDEF Bot_corners,Bot_masks
             .XDEF Topblk_mid,Topblk_left,Topblk_right,Topblk_top,Topblk_bot
             .XDEF Daynight_icn,Layout_icn,Control_icn,Status_icn,Objects_icn
             .XDEF Chequered,Feedback,Layouts
             .XDEF Skull_portrait,Red_bar,Blue_bar
             .XDEF Swordshield,RiddleM_graphics,Curse_anim
             .XDEF Tactic_icn,Automap_icn,Ouch
             .XDEF Day_pal,Night_pal,Dawndusk_pal

             .PATH 'E:\LAYOUT\'
             .PATH 'E:\MAIN\MAP\'

             .DATA 
; These are the left and right bottom corner elements for the lay-out
; (size 16 x 16), and their masks.
Bot_corners: .DC.w 0,$8000,0,0,0,$8000,0,0
             .DC.w $8000,$8000,0,0,$8000,$8000,0,0
             .DC.w $8000,$8000,0,0,0,0,$8000,0
             .DC.w 0,0,$8000,0,0,0,$8000,0
             .DC.w $4000,$4000,0,0,0,0,$4000,0
             .DC.w $2000,$2000,0,0,0,0,$2000,0
             .DC.w 0,0,$1000,0,$400,$400,$800,0
             .DC.w 0,0,$300,0,$62,$63,$94,0
             .DC.w $0001,$0001,0,0,0,0,$0001,0
             .DC.w 0,0,$0001,0,0,0,$0001,0
             .DC.w 0,0,$0001,0,0,0,$0001,0
             .DC.w $0001,$0001,0,0,0,0,$0001,0
             .DC.w $0002,$0002,0,0,0,0,$0002,0
             .DC.w $0004,$0004,0,0,0,0,$0004,0
             .DC.w 0,0,$0008,0,$0020,$0020,$0010,0
             .DC.w $0080,$0080,$0040,0,$4c00,$cc00,$3300,0
Bot_masks:   .DC.w $8000,$8000,$8000,$8000,$8000,$8000,$8000,$8000
             .DC.w $c000,$c000,$e000,$e000,$f000,$fc00,$ff00,$fff7
             .DC.w $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
             .DC.w $0003,$0003,$0007,$0007,$000f,$003f,$00ff,$ffff

; The graphics for the status block (size 320 x 36)
Topblk_mid:  .IBYTES 'SB_MID.IMG'           ; Middle part (size 16 x 36)
Topblk_left: .IBYTES 'SB_LEFT.IMG'          ; Left edge (size 16 x 36)
Topblk_right:          .IBYTES 'SB_RIGHT.IMG'     ; Right edge (16 x 36)
Topblk_top:  .IBYTES 'SB_TOP.IMG'           ; Top edge (size 16 x 1)
Topblk_bot:  .IBYTES 'SB_BOTT.IMG'          ; Bottom edge (size 16 x 1)

Layouts:     .IBYTES 'FRAME.001'            ; Layout data
             .IBYTES 'FRAME.002'
             .IBYTES 'FRAME.003'
             .IBYTES 'FRAME.004'
             .IBYTES 'FRAME.005'
             .IBYTES 'FRAME.006'
             .IBYTES 'FRAME.007'
             .IBYTES 'FRAME.008'
             .IBYTES 'FRAME.009'
             .IBYTES 'FRAME.010'
             .IBYTES 'FRAME.011'
Skull_portrait:        
             .IBYTES 'SKULL.IMG'            ; Size 32 x 34

Feedback:    .IBYTES 'FEEDBACK.IMG'         ; Feedback icon
Chequered:   .REPT 8
             .DC.l $5555,0,$5555,0          ; Chequered icon
             .DC.l $aaaa,0,$aaaa,0
             .ENDR 

Daynight_icn:          .IBYTES 'SPECIAL.ICN'      ; Special item graphics
Layout_icn:  .IBYTES 'LAYOUT.ICN'           ; Layout icon graphics
Control_icn: .REPT 32
             .DC.l $0000ffff,0              ; Empty icon
             .ENDR 
             .IBYTES 'CONTROL.ICN'          ; Control icon graphics
Status_icn:  .IBYTES 'STATUS.ICN'           ; Status icon graphics
Objects_icn: .IBYTES 'OBJECTS.ICN'          ; Object icon graphics

; These are the power-points & life-points bar graphics.
; The first line is shadow, the second is the actual bar.
; Left bar (power points)
Red_bar:     .DC.w $2000,$2000,$5e00,0
             .REPT 16
             .DC.w $7400,$800,$5e00,$400
             .ENDR 
; Right bar (life points)
Blue_bar:    .DC.w $10,$10,$2f,0
             .REPT 16
             .DC.w $2a,$6,$1,$38
             .ENDR 

; Sword & shield icons (16 x 10)
Swordshield: .IBYTES 'SWORD.IMG'
             .IBYTES 'SHIELD.IMG'
RiddleM_graphics:      
             .IBYTES 'RM_ANIMA.ICN'
Curse_anim:  .IBYTES 'CURSEANI.ICN'
Tactic_icn:  .IBYTES 'TAKTIK.ICN'
Automap_icn: .IBYTES 'AUTOMAP.ICN'
Ouch:        .IBYTES 'OUCH.IMG'
Day_pal:     .IBYTES 'DAY.PAL'
             .DC.w 0
Night_pal:   .IBYTES 'NIGHT.PAL'
             .DC.w 0
Dawndusk_pal:          .IBYTES 'DAWNDUSK.PAL'
             .DC.w 0

             .END 

