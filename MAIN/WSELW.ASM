
; Word Select Window
; Written by J.Horneman
; Start : 18-9-1991

             .TEXT 
WSelW_ModInit:         
             movem.l   d0-d7/a0-a6,-(sp)
             sf        No_word_entered
; ------------- Make list of known words -----------------------------
             move.l    #5000*2,d0           ; Make word buffer
             jsr       Allocate_memory
             move.l    a1,Word_list_ptr
             lea.l     WD,a0                ; Initialize registers
             moveq.l   #0,d0
             moveq.l   #1,d1
             moveq.l   #1,d2
             moveq.l   #0,d3
             move.w    #5000-1,d7
.Loop:       btst      d1,0(a0,d0.w)        ; Word known ?
             beq.s     .Zero
             move.w    d2,(a1)+             ; Store word number
             addq.w    #1,d3
.Zero:       addq.w    #1,d1                ; Next bit
             cmpi.w    #8,d1
             bmi.s     .Ok
             moveq.l   #0,d1
             addq.w    #1,d0
.Ok:         addq.w    #1,d2
             dbra      d7,.Loop
             tst.w     d3                   ; Know any words ?
             beq       No_words_known
             moveq.l   #0,d0                ; Return unused memory
             move.w    d3,d0
             add.l     d0,d0
             movea.l   Word_list_ptr,a0
             jsr       Shrink_memory
             move.w    d3,Nr_of_known_words ; Store results
             .LOCAL 
; ------------- Convert list to text ---------------------------------
             move.w    #21,d0               ; Make text buffer
             mulu.w    d3,d0
             jsr       Allocate_memory
             move.l    a1,Text_buffer
             movea.l   Word_list_ptr,a2
             subq.w    #1,d3
.Loop1:      movea.l   a1,a3
             move.w    (a2)+,d0             ; Get pointer to word
             jsr       Find_word
             moveq.l   #0,d0                ; Get length of word
             move.b    (a0)+,d0
             subq.w    #1,d0                ; !!! REMOVE LATER !!!
             bra.s     .Entry2
.Loop2:      move.b    (a0)+,(a3)+          ; Copy word
.Entry2:     dbra      d0,.Loop2
             clr.b     (a3)                 ; Insert EOL
             lea.l     21(a1),a1            ; Next word
             dbra      d3,.Loop1
             movea.l   Word_list_ptr,a0     ; Free memory
             jsr       Free_memory
             cmpi.w    #1,Nr_of_known_words ; Only one word ?
             beq.s     .No_sort
             jsr       Sort_word_list       ; Sort words
.No_sort:    .LOCAL 
; ------------- Make graphics buffer ---------------------------------
             moveq.l   #15,d0               ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #-1,d0
             jsr       IG_Set_paper
             move.w    #448,d0              ; Make graphics buffer
             mulu.w    Nr_of_known_words,d0
             jsr       Allocate_memory
             move.l    a1,Text_graphics_buffer
             move.l    #7*160,d0            ; Make line graphics buffer
             jsr       Allocate_memory
             movea.l   a1,a6
             moveq.l   #0,d0                ; Initialize registers
             moveq.l   #0,d1
             move.w    #128-1,d2
             moveq.l   #7-1,d3
             moveq.l   #3,d4
             move.w    Nr_of_known_words,d5
             subq.w    #1,d5
             moveq.l   #8,d6
             moveq.l   #7,d7
             movea.l   Text_buffer,a0
             movea.l   Text_graphics_buffer,a1
             lea.l     3,a2
.Loop:       exg.l     d4,d6                ; Clear line graphics buffer
             jsr       Draw_box
             exg.l     d4,d6
             exg.l     d0,a2                ; Set cursor at (3,0)
             jsr       IG_Set_cursor
             exg.l     d0,a2
             jsr       IG_Print             ; Print text on fake screen
             exg.l     a0,a1                ; Copy line to graphics buffer
             jsr       Get2_block
             exg.l     a0,a1
             lea.l     21(a0),a0            ; Next line
             lea.l     448(a1),a1
             dbra      d5,.Loop
             .LOCAL 
; ------------- Do stuff ---------------------------------------------
             move.w    Nr_of_known_words,d0 ; Store height of buffer
             mulu.w    #7,d0
             move.w    d0,Height_of_buffer
             move.w    #64,Width_of_buffer  ; Store width of buffer
             movea.l   a6,a0                ; Free memory
             jsr       Free_memory
             Push      PA,WSelW_PA
             move.w    #First_add,Adding    ; Reset
; ------------- Open a window ----------------------------------------
             moveq.l   #32,d0
             moveq.l   #40,d1
             moveq.l   #10,d2
             moveq.l   #10,d3
             moveq.l   #2,d4
             moveq.l   #1,d6
             lea.l     WSelW_L1,a0
             jsr       Open_window
             move.w    d0,WSelW_handle
; ------------- Fill window ------------------------------------------
             movea.l   Off_screen,a6
             moveq.l   #32+16,d0            ; Clear word area
             moveq.l   #40+16,d1
             move.w    d0,d2
             addi.w    #127,d2
             move.w    d1,d3
             addi.w    #111,d3
             moveq.l   #3,d6
             jsr       Draw_box
             moveq.l   #2,d6                ; Display icons
             moveq.l   #16,d7
             move.w    #32+16,d0            ; Input word
             move.w    #40+16+112,d1
             lea.l     Control_icn+4352,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; Up
             lea.l     Control_icn+256,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; Down
             lea.l     Control_icn+512,a0
             jsr       Blot_unmasked_block
             addi.w    #32,d0               ; Exit
             lea.l     Control_icn+7680,a0
             jsr       Blot_unmasked_block
             Update_screen 
No_words_known:        
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

WSelW_DisUpd:          
             move.w    Word_list_pos,d0     ; Refresh text window
             mulu.w    #7,d0
             movea.l   PA_sp,a5
             movea.l   (a5),a5
             movea.l   Off_screen,a6
             jsr       Refresh_text_window
             rts       

WSelW_ModExit:         
             Pop       PA
             movea.l   Text_buffer,a0       ; Free memory
             jsr       Free_memory
             movea.l   Text_graphics_buffer,a0
             jsr       Free_memory
             move.w    WSelW_handle,d0      ; Close window
             jsr       Close_window
             rts       

; [ Word select action ]
;   IN : d0 - Number of word slot (.w)
WordSelected:          
             lsr.w     #8,d0                ; Calculate index
             subq.w    #1,d0
             add.w     Word_list_pos,d0
             cmp.w     Nr_of_known_words,d0 ; Empty slot ?
             bpl.s     .Exit
             movea.l   Text_buffer,a0       ; Get pointer to word
             mulu.w    #21,d0
             adda.w    d0,a0
             jsr       Search_word          ; Search word
             move.w    d0,Found_word        ; Store & exit
             Pop       Module
.Exit:       rts       

; [ Input icon action ]
InputWord:   
             Push      Module,WordIn_Mod    ; Input word
             lea.l     Input_buffer,a0      ; Search word
             jsr       Search_word
             move.w    d0,Found_word        ; Store & exit
             jmp       Pop_Module

; [ Exit icon action ]
ExitWordSelect:        
             st        No_word_entered      ; No word entered!
             jsr       Pop_Module
             Wait_4_unclick 
             rts       

;*****************************************************************************
; [ Word list scroll routines ]
; Changed registers : d0,d1
;*****************************************************************************
WordSel_1Up: 
             moveq.l   #1,d0                ; Scroll up 1
             jmp       WordSel_UP

WordSel_1Down:         
             moveq.l   #1,d0                ; Scroll down 1
             jmp       WordSel_DOWN

WordSel_8Up: 
             moveq.l   #8,d0                ; Scroll up 8
             jmp       WordSel_UP

WordSel_8Down:         
             moveq.l   #8,d0                ; Scroll down 8
             jmp       WordSel_DOWN

WordSel_X1Up:          
             move.w    Adding,d0            ; Scroll up exp.
             lsr.w     #8,d0
             jsr       WordSel_UP
             jmp       Inc_adding

WordSel_X1Down:        
             move.w    Adding,d0            ; Scroll down exp.
             lsr.w     #8,d0
             jsr       WordSel_DOWN
             jmp       Inc_adding

WordSel_X8Up:          
             move.w    Adding,d0            ; Scroll up exp. x 8
             lsr.w     #5,d0
             andi.w    #$fff8,d0
             jsr       WordSel_UP
             jmp       Inc_adding

WordSel_X8Down:        
             move.w    Adding,d0            ; Scroll down exp. x 8
             lsr.w     #5,d0
             andi.w    #$fff8,d0
             jsr       WordSel_DOWN
             jmp       Inc_adding

; [ Scroll up ]
;   IN : d0 - Up offset (.w)
; Changed registers : d1
WordSel_UP:  
             move.w    Word_list_pos,d1     ; Scroll up
             sub.w     d0,d1
             bpl.s     .Skip                ; Too far ?
             moveq.l   #0,d1                ; Reset
             move.w    #First_add,Adding
.Skip:       move.w    d1,Word_list_pos
             rts       

; [ Scroll down ]
;   IN : d0 - Down offset (.w)
; Changed registers : d1
WordSel_DOWN:          
             move.w    Word_list_pos,d1     ; Scroll down
             add.w     d0,d1
             cmp.w     Nr_of_known_words,d1 ; Too far ?
             bmi.s     .Skip
             move.w    Nr_of_known_words,d1 ; Reset
             subq.w    #1,d1
             move.w    #First_add,Adding
.Skip:       move.w    d1,Word_list_pos
             rts       

;*****************************************************************************
; [ Sort known word list - using Shellsort ]
; All registers are restored
; Thanks to M.Bittner
;*****************************************************************************
Sort_word_list:        
             movem.l   d0-d3/d5/d6/a0,-(sp)
             movea.l   Text_buffer,a0       ; Initialize registers
             lea.l     -21(a0),a0
             move.w    Nr_of_known_words,d1 ; For T = INT(N/2) To 1
             lsr.w     #1,d1
             mulu.w    #21,d1
             move.w    Nr_of_known_words,d0 ;  X = N-T
             mulu.w    #21,d0
             sub.w     d1,d0
.Loop1:      moveq.l   #0,d2                ;  For K = 0 To T-1
.Loop2:      move.w    d2,d3                ;   For I = K+1 To N-T Step T
             addi.w    #21,d3
.Loop3:      move.w    d3,d5                ;    If (I) > (I+T)
             add.w     d1,d5
             move.w    d3,d6
             jsr       Compare_words
             bgt.s     .Next3
             jsr       Swap_words           ;    Then Swap (I),(I+T)
.Next3:      add.w     d1,d3                ;   Next I
             cmp.w     d0,d3
             ble.s     .Loop3
             addi.w    #21,d2               ;  Next K
             cmp.w     d1,d2
             bmi.s     .Loop2
             addi.w    #21,d0               ; Next T
             subi.w    #21,d1
             bne.s     .Loop1
             movem.l   (sp)+,d0-d3/d5/d6/a0
             rts       

; d0 = N-T
; d1 = T
; d2 = K
; d3 = I

; [ Compare two words ]
;   IN : d5 - Source index (.w)
;        d6 - Destination index (.w)
;  OUT : eq - Source = Destination
;        hi - Source > Destination
;        mi - Source < Destination
; All registers are restored
Compare_words:         
             movem.l   d0/d7/a0/a1,-(sp)
             lea.l     0(a0,d6.w),a1        ; Calculate absolute pointers
             lea.l     0(a0,d5.w),a0
             moveq.l   #0,d7
.Loop:       move.b    0(a0,d7.w),d0        ; Compare character
             cmp.b     0(a1,d7.w),d0
             bne.s     .Exit
             addq.w    #1,d7                ; Next character
             cmpi.w    #20,d7
             bmi.s     .Loop
             cmp.w     d0,d0                ; Set flags
.Exit:       movem.l   (sp)+,d0/d7/a0/a1
             rts       

; [ Swap two words ]
;   IN : d5 - Source index (.w)
;        d6 - Destination index (.w)
; All registers are restored
Swap_words:  
             movem.l   d0/d7/a0/a1,-(sp)
             lea.l     0(a0,d6.w),a1        ; Calculate absolute pointers
             lea.l     0(a0,d5.w),a0
             moveq.l   #20-1,d7
.Loop:       move.b    (a0),d0              ; Copy 20 characters
             move.b    (a1),(a0)+
             move.b    d0,(a1)+
             dbra      d7,.Loop
             movem.l   (sp)+,d0/d7/a0/a1
             rts       

;*****************************************************************************
; [ Search word in dictionary ]
;   IN : a0 - Pointer to word (.l)
;  OUT : d0 - Word number / 0 - not found (.w)
; Changed registers : d0
;*****************************************************************************
Search_word: 
             movem.l   d4-d7/a1-a3,-(sp)
             movea.l   a0,a1                ; Get length of word
             moveq.l   #-1,d4
.Again:      addq.w    #1,d4
             tst.b     (a1)+
             bne.s     .Again
             movea.l   Dictionary_ptr,a1    ; Get number of words
             moveq.l   #0,d0
             move.w    (a1)+,d7
             subq.w    #1,d7
.Loop1:      moveq.l   #0,d6                ; Get length of word
             move.b    (a1)+,d6
             subq.w    #1,d6
             move.w    d6,d5                ; Duplicate length of word
             movea.l   a0,a2                ; Duplicate pointers
             movea.l   a1,a3
             bra.s     .Entry2
.Loop2:      cmpm.b    (a2)+,(a3)+          ; Compare words
             bne.s     .Next1
.Entry2:     dbra      d6,.Loop2
             cmp.w     d4,d5                ; Right length ?
             beq.s     .Found
.Next1:      addq.w    #1,d0                ; Next word
             adda.w    d5,a1
             dbra      d7,.Loop1
             moveq.l   #0,d0                ; Word doesn't exist
.Found:      movem.l   (sp)+,d4-d7/a1-a3
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
WSelW_PA:    .DC.w 32+16,40+16,128,112,15,3

             .BSS 
No_word_entered:       .DS.b 1              ; Set if EXIT-icon was clicked
             .EVEN 
Found_word:  .DS.w 1   ; Contains ID of word / 0 if unknown
WSelW_handle:          .DS.w 1
Word_list_ptr:         .DS.l 1
Nr_of_known_words:     .DS.w 1
Word_list_pos:         .DS.w 1

             .SECTION 7,DATA
; WORD SELECT WINDOW : 1st layer
WSelW_L1:    .DC.w 0,127,0,111              ; Word area
             .DC.b 1
             .EVEN 
             .DC.l .C2,WSelW_L2
.C2:         .DC.w 0,31,112,127             ; Input icon
             .DC.b 2
             .EVEN 
             .DC.l .C3,0
.C3:         .DC.w 32,63,112,127            ; Up icon
             .DC.b 3
             .EVEN 
             .DC.l .C4,0
.C4:         .DC.w 64,95,112,127            ; Down icon
             .DC.b 4
             .EVEN 
             .DC.l .C5,0
.C5:         .DC.w 96,127,112,127           ; Exit icon
             .DC.b 5
             .EVEN 
             .DC.l 0,0

; WORD SELECT WINDOW : 2nd layer
WSelW_L2:    .DC.w 0,127,0,6                ; Words
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



