
; Window routines
; Written by J.Horneman (In Tune With The Universe)
; Start : 31-1-1991

;   "If you could see all the roads I have travelled
;     Towards some unusable last equilibrium
;      Run like an athlete and die like a
;       Dead beaten speed freak
;        An answer to all of the answers to - Yes."
;   Tempus Fugit, Yes, 1980

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

             .XDEF Open_window,Close_window

Max_windows  = 2       ; Maximum number of windows

             .PATH 'E:\MAIN\'
             .PATH 'E:\LAYOUT\'
             .INCLUDE 'XREFS.IS'

             .TEXT 
;*****************************************************************************
; [ Open window routine ]
;   IN : d0 - Top left X-coordinate (.w)
;        d1 - Top left Y-coordinate (.w)
;        d2 -  Width of window in units of 16 pixels (.w)
;        d3 - Height of window in units of 16 pixels (.w)
;        d6 - 0 = Dark, 1 = Light (.w)
;        a0 - Pointer to object branch / 0 (.l)
;  OUT : d0 - Window handle (.w)
; Changed registers : d0
;*****************************************************************************
Open_window: 
             movem.l   d1-d7/a0-a2/a6,-(sp)
             jsr       Mouse_off
; ------------- Allocate memory for window data & drawing buffer -----
             move.w    d2,d4                ; Calculate size of window
             mulu.w    d3,d4                ; data
             lsl.l     #7,d4
             addi.l    #Wind_back,d4
             move.w    d0,-(sp)             ; Make buffer
             move.l    d4,d0
             jsr       Allocate_memory
             lea.l     (a1),a2
             move.w    (sp)+,d0
; ------------- Enter window data ------------------------------------
             move.w    d0,Wind_X(a2)        ; Enter size & position
             move.w    d1,Wind_Y(a2)
             move.w    d2,Wind_width(a2)
             move.w    d3,Wind_height(a2)
             move.l    a0,Wind_branch(a2)
             moveq.l   #16,d4               ; Calculate window area
             add.w     d0,d4
             move.w    d4,Wind_area(a2)     ; Minimum X
             moveq.l   #-2,d5
             add.w     d2,d5
             lsl.w     #4,d5
             add.w     d5,d4
             subq.w    #1,d4
             move.w    d4,Wind_area+2(a2)   ; Maximum X
             moveq.l   #16,d4
             add.w     d1,d4
             move.w    d4,Wind_area+4(a2)   ; Minimum Y
             moveq.l   #-2,d5
             add.w     d3,d5
             lsl.w     #4,d5
             add.w     d5,d4
             subq.w    #1,d4
             move.w    d4,Wind_area+6(a2)   ; Maximum Y
             tst.w     d6                   ; Get window icon base
             bne.s     .Light
             moveq.l   #3,d6                ; Dark window
             lea.l     Wind1_icons,a1
             bra.s     .Continue
.Light:      moveq.l   #2,d6                ; Light window
             lea.l     Wind2_icons,a1
.Continue:   
; ------------- REGISTER CONTENTS ------------------------------------
;   d0 - Leftmost X-coordinate of window (.w)
;   d1 -  Topmost Y-coordinate of window (.w)
;   d2 -  Width of window (.w)
;   d3 - Height of window (.w)
;   d6 - Window colour (.w)
;   a1 - Pointer to window icons (.l)
;   a2 - Pointer to window data (.l)

; ------------- Save background --------------------------------------
             move.w    d6,-(sp)
             move.w    d2,d6
             move.w    d3,d7
             lsl.w     #4,d7
             subq.w    #8,d7
             lea.l     Wind_back(a2),a0
             movea.l   Screen_base,a6
             jsr       Get2_block
             move.w    (sp)+,d6
             jsr       Copy_screen
; ------------- Draw border of window --------------------------------
             lea.l     (a1),a0
             movea.l   Off_screen,a6
             subq.w    #4,d2                ; Adjust counters
             subq.w    #4,d3
             move.w    d0,d4                ; Save coordinates
             move.w    d1,d5
             jsr       Put_masked_block     ; Draw first column
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Draw_vertical_border
             jsr       Put_masked_block
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d0               ; Draw second column
             exg.l     d1,d5
             lea.l     128(a0),a0
             jsr       Put_masked_block
             exg.l     d1,d5
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d0               ; Draw middle columns
             exg.l     d1,d5
             lea.l     128(a0),a0
             jsr       Draw_horizontal_border
             move.w    d4,d0
             addi.w    #32,d0
             exg.l     d1,d5
             jsr       Draw_horizontal_border
             exg.l     d1,d5                ; Draw penultimate column
             jsr       Put_masked_block
             exg.l     d1,d5
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d0               ; Draw last column
             exg.l     d1,d5
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Put_masked_block
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Draw_vertical_border
             jsr       Put_masked_block
             addi.w    #16,d1
             lea.l     128(a0),a0
             jsr       Put_masked_block
; ------------- Fill window ------------------------------------------
             move.w    Wind_X(a2),d0        ; Get first coordinate pair
             move.w    Wind_Y(a2),d1
             addi.w    #16,d0
             addi.w    #16,d1
             addq.w    #2,d2                ; Calculate second coordinate
             addq.w    #2,d3                ; pair
             lsl.w     #4,d2
             lsl.w     #4,d3
             add.w     d0,d2
             add.w     d1,d3
             subq.w    #1,d2
             subq.w    #1,d3
             jsr       Draw_box
             jsr       Switch_screen        ; Display window
             jsr       Copy_screen
; ------------- Various installations --------------------------------
             lea.l     Wind_area(a2),a0     ; No macro !!
             jsr       Push_MA
             move.l    Wind_branch(a2),d0   ; Translate & install branch
             beq.s     .Zero
             movea.l   d0,a0
             moveq.l   #16,d0
             moveq.l   #16,d1
             add.w     Wind_X(a2),d0
             add.w     Wind_Y(a2),d1
             jsr       Translate_object_branch
             jsr       Push_Root
; ------------- Insert window in list --------------------------------
.Zero:       lea.l     Window_list,a0       ; Find window handle
             moveq.l   #Max_windows-1,d7
.Loop:       tst.l     (a0)+                ; Free slot ?
             dbeq      d7,.Loop
             tst.w     d7                   ; Found one ?
             bpl.s     .No_error
             ERROR     "[ Open_window ] : No more windows can be opened !!!"
             bra.s     .Exit
.No_error:   move.l    a2,-(a0)             ; Insert pointer in slot
             suba.l    #Window_list,a0
             move.l    a0,d0
             lsr.w     #2,d0
; ------------- Exit -------------------------------------------------
.Exit:       jsr       Mouse_on
             movem.l   (sp)+,d1-d7/a0-a2/a6
             rts       

; [ Draw horizontal border of icons ]
;   d0 - X-coordinate (.w)
;   d1 - Y-coordinate (.w)
;   d2 - Counter (.w)
;   a0 - Pointer to graphics (.l)
;   a6 - Screen base (.l)
; Changed registers : d1,a0
Draw_horizontal_border:                     
             move.l    d2,-(sp)
             bra.s     .Entry
.Loop:       jsr       Put_masked_block
             addi.w    #16,d0
.Entry:      dbra      d2,.Loop
             lea.l     128(a0),a0
             move.l    (sp)+,d2
             rts       

; [ Draw vertical border of icons ]
;   d0 - X-coordinate (.w)
;   d1 - Y-coordinate (.w)
;   d3 - Counter (.w)
;   a0 - Pointer to graphics (.l)
;   a6 - Screen base (.l)
; Changed registers : d1,a0
Draw_vertical_border:  
             move.l    d3,-(sp)
             bra.s     .Entry
.Loop:       jsr       Put_masked_block
             addi.w    #16,d1
.Entry:      dbra      d3,.Loop
             lea.l     128(a0),a0
             move.l    (sp)+,d3
             rts       

;*****************************************************************************
; [ Close window routine ]
;   IN : d0 - Window number (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Close_window:          
             movem.l   d0/d1/d6/d7/a0/a1/a6,-(sp)
             jsr       Mouse_off
             lea.l     Window_list,a0       ; Get pointer to window data
             lsl.w     #2,d0
             adda.w    d0,a0
             tst.l     (a0)
             bne.s     .Ok
             ERROR     "[ Close_window ] :  Illegal window handle !!!"
             bra       .Exit
.Ok:         movea.l   (a0),a1              ; Get pointer
             clr.l     (a0)                 ; Clear slot
; ------------- Restore background -----------------------------------
             move.w    Wind_X(a1),d0
             move.w    Wind_Y(a1),d1
             move.w    Wind_width(a1),d6
             move.w    Wind_height(a1),d7
             lsl.w     #4,d7
             subq.w    #8,d7
             lea.l     Wind_back(a1),a0
             movea.l   Off_screen,a6
             jsr       Blot_unmasked_block
             jsr       Switch_screen
             jsr       Copy_screen
; ------------- Various de-installations -----------------------------
             Pop       MA
             move.l    Wind_branch(a1),d0   ; Remove & de-translate branch
             beq.s     .Zero
             Pop       Root
             movea.l   d0,a0
             moveq.l   #16,d0
             moveq.l   #16,d1
             add.w     Wind_X(a1),d0
             add.w     Wind_Y(a1),d1
             neg.w     d0
             neg.w     d1
             jsr       Translate_object_branch
.Zero:       lea.l     (a1),a0              ; Free memory block
             jsr       Free_memory
.Exit:       jsr       Mouse_on
             movem.l   (sp)+,d0/d1/d6/d7/a0/a1/a6
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .ABS 0
Wind_X:      .DS.w 1
Wind_Y:      .DS.w 1
Wind_width:  .DS.w 1   ; Measured in units of 16 pixels
Wind_height: .DS.w 1
Wind_area:   .DS.w 4
Wind_branch: .DS.l 1
Wind_back:   

             .DATA 
Wind1_icons: .IBYTES 'WINDOW.ICN'           ; Colour 3
Wind2_icons: .IBYTES 'WINDOW2.ICN'          ; Colour 2

             .BSS 
Window_list: .DS.l Max_windows

             .END 












