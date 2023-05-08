
; Word handling
; Written by J.Horneman
; Start : 11-5-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * Ω 1991 Thalion Software GmbH *
; ********************************

;   "Lost on a wave and then after
;     Dream on on to the Heart of the Sunrise
;      SHARP - DISTANCE
;       How can the wind with it's arms all around me
;        Lost in the city"
;   Heart Of The Sunrise, Yes, 1972

; Notes :
;   - [ Init_dictionary ] assumes that the dictionary exists and doesn't
;     contain more than 32 x 160 = 5120 words.
;   - [ Find_word ] assumes the searched word exists!!
;   - Words with a length greater or equal to the line's length, can't be
;     wrapped because the last space can't be found.
;   - The correct size of {Line_buffer} isn't known !!!
;   - The Opening Bracket "(" is a special case !!!
;   - There shouldn't be more than 20 paragraphs.
;   - If the text is too long, a crash may occur due to an overflow in the
;     mouse Y-coordinate. See {Scroll_MA}.

Language     = 3       ; 1 - English, 2 - French, 3 - German
Nr_Endpuncts           = 8                  ; Number of punctuation characters
OpenBracket  = 1580
CarrReturn   = 1576
ParaMark     = 1577
Max_textblock_size     = 1000*21
Max_PA       = 16

             .MACRO MesMin nr
             move.w    #\1,d0
             jsr       Minus_message
             .ENDM 

             .MACRO SetMesMin x,y,w,ptr
             move.w    #\1,Mesmin_X         ; Set message (-) parameters
             move.w    #\2,Mesmin_Y
             move.w    #\3,Mesmin_Wd
             move.l    #\4,Textfile_ptr
             .ENDM 

             .MACRO PlusMes nr
             move.w    #\1,d0
             jsr       Plus_message
             .ENDM 

             .MACRO HashMes nr
             move.w    #\1,d0
             jsr       Hash_message
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ Hash Message ]
;   IN : d0 - Message number (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Hash_message:          
             movem.l   d0/d2/d7/a0,-(sp)
             movea.l   PlusMes_info,a0      ; Install print area
             addq.l    #8,a0
             jsr       Push_PA
             jsr       Erase_text_window    ; Erase previous text
             move.w    Nr_of_chars,d2       ; Convert text
             movea.l   Textfile_ptr,a1
             jsr       Prepare_text_block
             movea.l   Text_buffer,a0       ; Print text
             move.w    Nr_of_chars,d0
             addq.w    #1,d0
             move.w    Lines_in_text,d7
             subq.w    #1,d7
.Loop:       jsr       IG_Print
             jsr       IG_Carriage_return
             adda.w    d0,a0
             dbra      d7,.Loop
             Pop       PA                   ; Remove print area
             movea.l   Text_buffer,a0       ; Free memory
             jsr       Free_memory
             movem.l   (sp)+,d0/d2/d7/a0
             rts       

;*****************************************************************************
; [ Print centered string ]
;   IN : d0 - Top-left X-coordinate of print area (.w)
;        d1 - Top-left Y-coordinate of print area (.w)
;        d2 - Width of print area (.w)
;        a0 - Pointer to string (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Print_centered_string: 
             movem.l   d0-d2/d6/d7,-(sp)
             move.l    a0,-(sp)
             moveq.l   #0,d7                ; Get number of characters
.Loop:       tst.b     (a0)+                ; in string
             beq.s     .End
             cmpi.b    #32,-1(a0)           ; Filter control characters
             bmi.s     .Loop
             addq.l    #1,d7
             bra.s     .Loop
.End:        movea.l   (sp)+,a0
             move.w    d7,d6                ; Multiply number of
             add.w     d7,d7                ; characters by 6
             add.w     d6,d7
             add.w     d7,d7
             sub.w     d7,d2                ; Adjust X-coordinate
             bmi.s     .Skip
             asr.w     #1,d2
             add.w     d2,d0
.Skip:       jsr       IG_Set_cursor        ; Set cursor & print
             jsr       IG_Print
             movem.l   (sp)+,d0-d2/d6/d7
             rts       

;*****************************************************************************
; [ Plus Message ]
;   IN : d0 - Message number (.w)
; All registers are restored
;*****************************************************************************
Plus_message:          
             movem.l   a0/a1,-(sp)
             movea.l   PlusMes_info,a0      ; Print text
             jsr       Push_MA
             addq.l    #8,a0
             jsr       Push_PA
             movea.l   Textfile_ptr,a1
             jsr       Mr_Blue_Sky
             Pop       MA
             Pop       PA
             movem.l   (sp)+,a0/a1
             rts       

;*****************************************************************************
; [ Print message (-) in text window ]
;   IN : d0 - Number of message (.w)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Minus_message:         
             movem.l   d0-d2/a0/a1,-(sp)
             movea.l   Textfile_ptr,a1      ; Convert text
             jsr       Convert_text_line
             lea.l     .Init_string,a0      ; Set colours
             jsr       IG_Print
             jsr       Erase_message_minus  ; Erase previous text
             move.w    Mesmin_X,d0          ; Get area size
             move.w    Mesmin_Y,d1
             move.w    Mesmin_Wd,d2
             lea.l     Line_buffer,a0       ; Print line
             jsr       Print_centered_string
             movem.l   (sp)+,d0-d2/a0/a1
             rts       

.Init_string:          .DC.b 1,15,2,2,0     ; Ink 15,Paper 2
             .EVEN 

; [ Erase message (-) area ]
;   IN : a6 - Screen base (.l)
; All registers are restored
Erase_message_minus:   
             movem.l   d0-d3/d6,-(sp)
             move.w    Mesmin_X,d0          ; Get coordinates of text area
             move.w    Mesmin_Y,d1
             move.w    d0,d2
             add.w     Mesmin_Wd,d2
             subq.w    #1,d2
             move.w    d1,d3
             addi.w    #15-1,d3
             move.w    #2,d6                ; Erase area
             jsr       Draw_box
             movem.l   (sp)+,d0-d3/d6
             rts       

;*****************************************************************************
; [ Initialize dictionary ]
; All registers are restored
;*****************************************************************************
Init_dictionary:       
             movem.l   d0/d7/a0/a1,-(sp)
; ------------- Load dictionary --------------------------------------

             move.l    #4000,d0             ; Allocate buffer zone
             jsr       Allocate_memory
             movea.l   a1,a0
             lsr.w     #2,d0
             subq.w    #1,d0
.Loopy:      clr.l     (a0)+
             dbra      d0,.Loopy
             move.l    a1,DangerZone

             lea.l     Dictionary_filename,a0
             jsr       Load_file
             move.l    a0,Dictionary_ptr
; ------------- Create a list of pointers to every 32nd word ---------
             addq.l    #2,a0                ; Skip word
             lea.l     Tween_word_indices,a1
             move.l    a0,(a1)+             ; Store first pointer
             moveq.l   #0,d0
.Again:      moveq.l   #32-1,d7
.Loop:       move.b    (a0),d0              ; End of dictionary ?
             beq.s     .Exit
             adda.w    d0,a0                ; Next word
             dbra      d7,.Loop
             move.l    a0,(a1)+             ; Store pointer
             bra.s     .Again
.Exit:       movem.l   (sp)+,d0/d7/a0/a1
             rts       

;*****************************************************************************
; [ Initialize map texts ]
; All registers are restored
;*****************************************************************************
Init_maptexts:         
             movem.l   d0/a0,-(sp)
             lea.l     Maptext_filename,a0  ; Load map texts
             move.w    Map_nr,d0
             jsr       Load_subfile
             move.l    a0,Maptext_ptr
             movem.l   (sp)+,d0/a0
             rts       

;*****************************************************************************
; [ Find a word in the current dictionary ]
;   IN : d0 - Number of word (.w)
;  OUT : a0 - Pointer to word (.l)
; Changed registers : a0
;*****************************************************************************
Find_word:   
             movem.l   d0/d1,-(sp)
             move.w    d0,d1
             lsr.w     #3,d1                ; Divide by 32
             andi.w    #$fffc,d1            ; Multiply by 4
             lea.l     Tween_word_indices,a0      ; Get tween word index
             movea.l   0(a0,d1.w),a0
             andi.w    #$1f,d0              ; Number MOD 32
             moveq.l   #0,d1
             bra.s     .Entry
.Loop:       move.b    (a0),d1              ; Get length
             adda.w    d1,a0                ; Next word
.Entry:      dbra      d0,.Loop
             movem.l   (sp)+,d0/d1
             rts       

;*****************************************************************************
; [ Convert one line of text ]
;   IN : d0 - Number of text block (.w)
;        a1 - Pointer to text file (.l)
; All registers are restored
;*****************************************************************************
Convert_text_line:     
             movem.l   d0-d2/d6/d7/a0-a3,-(sp)
             jsr       Calc_textblock_address
             lea.l     Line_buffer,a2
             move.w    (a1)+,d0             ; Get first word
             bra.s     .Next1
.Loop1:      jsr       Find_word
             moveq.l   #0,d6                ; Get length of word
             move.b    (a0)+,d6
             subq.w    #1,d6                ; !!! REMOVE LATER !!!
             add.w     d6,d1                ; Add to length
             bra.s     .Entry2
.Loop2:      move.b    (a0)+,(a2)+          ; Copy word

             tst.w     d6
             bpl.s     .Entry2
             illegal 

.Entry2:     dbra      d6,.Loop2
             move.w    (a1)+,d0             ; Get next word
             lea.l     EndPuncts,a3         ; Search list
             moveq.l   #Nr_Endpuncts-1,d6
.Loop3:      cmp.w     (a3)+,d0
             beq.s     .Next1
             dbra      d6,.Loop3
             move.b    #" ",(a2)+           ; Insert space
.Next1:      dbra      d7,.Loop1            ; Next word
             move.b    #0,-(a2)             ; Insert EOL
             movem.l   (sp)+,d0-d2/d6/d7/a0-a3
             rts       

;*****************************************************************************
; [ Calculate text block address & length ]
;   IN : d0 - Number of text block (.w)
;        a1 - Pointer to text file (.l)
;  OUT : d7 - Number of words in text block (.w)
;        a1 - Pointer to start of text block (.l)
; Changed registers : d0,d1,d6,d7,a1
;*****************************************************************************
Calc_textblock_address:                     
             moveq.l   #0,d1                ; Get number of text blocks
             move.b    (a1),d1
             cmp.w     d1,d0                ; Legal ?
             bmi.s     .Ok
             ERROR     "[ Calc_textblock_address ] : Illegal textblock number !!!"
             bra       .Exit
.Ok:         addq.l    #2,a1                ; Skip word
             add.w     d0,d0                ; Get offset
             move.w    0(a1,d0.w),d6
             move.w    2(a1,d0.w),d7        ; Get length of text-block
             sub.w     d6,d7
             add.w     d6,d1                ; Get pointer to text block
             add.w     d1,d1
             adda.w    d1,a1
             addq.l    #2,a1
.Exit:       rts       

;*****************************************************************************
; [ Prepare scrolling ]
;   IN : a5 - Pointer to PA descriptor (.l)
; All registers are restored
;*****************************************************************************
Prepare_scrolling:     
             movem.l   d0-d7/a0-a3/a5/a6,-(sp)
             move.w    PA_Ink(a5),d0        ; Set ink & paper
             jsr       IG_Set_ink
             moveq.l   #-1,d0
             jsr       IG_Set_paper
; ------------- Make buffers -----------------------------------------
             move.w    Nr_of_chars,d0       ; Get width of graphics buffer
             mulu.w    #6,d0
             addi.w    #15,d0
             andi.w    #$fff0,d0
             lsr.w     #1,d0
             move.w    Lines_in_text,d1     ; Get height of graphics buffer
             mulu.w    #7,d1
             move.w    d1,Height_of_buffer  ; Store
             mulu.w    d1,d0                ; Calculate size
             jsr       Allocate_memory      ; Make graphics buffer
             move.l    a1,Text_graphics_buffer
             move.l    #7*160,d0            ; Make line graphics buffer
             jsr       Allocate_memory
             move.l    a1,Line_graphics_buffer
; ------------- Convert text to graphics -----------------------------
             moveq.l   #0,d0                ; Initialize registers
             moveq.l   #0,d1
             move.w    Nr_of_chars,d2
             movea.w   d2,a2
             addq.w    #1,a2
             mulu.w    #6,d2
             move.w    d2,d5
             addi.w    #15,d5
             andi.w    #$fff0,d5
             lsr.w     #1,d5
             move.w    d5,Width_of_buffer   ; Store
             mulu.w    #7,d5
             movea.w   d5,a3
             addi.w    #15,d2
             move.w    d2,d6
             lsr.w     #4,d6
             andi.w    #$fff0,d2
             subq.w    #1,d2
             moveq.l   #7-1,d3
             move.w    PA_Paper(a5),d4
             move.w    Lines_in_text,d5
             subq.w    #1,d5
             moveq.l   #7,d7
             movea.l   Text_buffer,a0
             movea.l   Text_graphics_buffer,a1
             movea.l   Line_graphics_buffer,a6

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - 0 (.l)
;  d1 - 0 (.l)
;  d2 - Width of graphics buffer in pixels - 1 (.w)
;  d3 - 7-1 (.l)
;  d4 - Paper colour (.w)
;  d5 - Number of lines in text - 1 (.w)
;  d6 - Width of graphics buffer in columns (.w)
;  d7 - 7 (.l)
;  a0 - Pointer to text buffer (.l)
;  a1 - Pointer to graphics buffer (.l)
;  a2 - Offset to next line in text buffer (.w)
;  a3 - Offset to next line in graphics buffer (.w)
;  a5 - Pointer to PA descriptor (.l)
;  a6 - Pointer to line graphics buffer (.l)

.Loop:       exg.l     d4,d6                ; Clear line graphics buffer
             jsr       Draw_box
             exg.l     d4,d6
             jsr       IG_Set_cursor        ; Set cursor at (0,0)
             jsr       IG_Print             ; Print text on fake screen
             exg.l     a0,a1                ; Copy line to graphics buffer
             jsr       Get2_block
             exg.l     a0,a1
             adda.w    a2,a0                ; Next line
             adda.w    a3,a1
             dbra      d5,.Loop
; ------------- Free memory ------------------------------------------
             movea.l   Text_buffer,a0       ; Free memory
             jsr       Free_memory
             movea.l   Line_graphics_buffer,a0
             jsr       Free_memory
             movem.l   (sp)+,d0-d7/a0-a3/a5/a6
             rts       

;*****************************************************************************
; [ Refresh text window ]
;   IN : d0 - Vertical offset (.w)
;        a5 - Pointer to PA descriptor (.l)
;        a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Refresh_text_window:   
             movem.l   d0-d3/d6/d7/a0,-(sp)
             movea.l   Text_graphics_buffer,a0
; ------------- Scroll in ? ------------------------------------------
             tst.w     d0                   ; Well ?
             bpl.s     .Ok_1
             move.w    d0,d3                ; Erase top rectangle
             neg.w     d3
             move.w    PA_X(a5),d0
             move.w    PA_Y(a5),d1
             move.w    d0,d2
             add.w     d1,d3
             add.w     PA_Wd(a5),d2
             subq.w    #1,d2
             subq.w    #1,d3
             move.w    PA_Paper(a5),d6
             jsr       Draw_box
             move.w    d3,d1                ; Adjust Y-coordinate
             addq.w    #1,d1
             move.w    PA_Y(a5),d7
             add.w     PA_Ht(a5),d7         ; Calculate height
             sub.w     d3,d7
             subq.w    #1,d7
             bra.s     .Continue
; ------------- Completely out ? -------------------------------------
.Ok_1:       move.w    Height_of_buffer,d1  ; Well ?
             subq.w    #1,d1
             cmp.w     d1,d0
             bmi.s     .Ok_2
             jsr       Erase_text_window
             bra       .Exit
; ------------- Scroll out ? -----------------------------------------
.Ok_2:       move.w    Width_of_buffer,d2   ; Calculate graphics address
             ext.l     d2
             mulu.w    d0,d2
             adda.l    d2,a0
             move.w    PA_Ht(a5),d7         ; Calculate height
             move.w    d0,d1
             add.w     d7,d1
             cmp.w     Height_of_buffer,d1  ; Well ?
             bmi.s     .Ok_3
             move.w    Height_of_buffer,d7
             sub.w     d0,d7
             bmi.s     .Exit
             subq.w    #1,d7
             move.w    PA_X(a5),d0          ; Load top-left coordinates
             move.w    PA_Y(a5),d1
             move.w    d0,d2                ; Clear bottom rectangle
             add.w     PA_Wd(a5),d2
             subq.w    #1,d2
             move.w    d1,d3
             add.w     PA_Ht(a5),d3
             subq.w    #1,d3
             add.w     d7,d1
             move.w    PA_Paper(a5),d6
             jsr       Draw_box
.Ok_3:       move.w    PA_X(a5),d0          ; Load top-left coordinates
             move.w    PA_Y(a5),d1
.Continue:   move.w    Width_of_buffer,d6   ; Calculate number of columns
             lsr.w     #3,d6
             jsr       Blot_unmasked_block  ; Do your thang
.Exit:       movem.l   (sp)+,d0-d3/d6/d7/a0
             rts       

;*****************************************************************************
; [ Erase text window ]
;   IN : a6 - Screen base (.l)
; All registers are restored
;*****************************************************************************
Erase_text_window:     
             movem.l   d0-d3/d6/a5,-(sp)
             movea.l   PA_sp,a5             ; Get pointer to PA
             movea.l   (a5),a5
             move.w    PA_X(a5),d0          ; Get area size
             move.w    PA_Y(a5),d1
             move.w    d0,d2
             move.w    d1,d3
             add.w     PA_Wd(a5),d2
             add.w     PA_Ht(a5),d3
             subq.w    #1,d2
             subq.w    #1,d3
             move.w    PA_Paper(a5),d6      ; Clear rectangle
             jsr       Draw_box
             movem.l   (sp)+,d0-d3/d6/a5
             rts       

;*****************************************************************************
; [ Push new PA ]
;   IN : a0 - Pointer to PA descriptor (.l)
; All registers are restored
;*****************************************************************************
Push_PA:     
             movem.l   d0/a1,-(sp)
             movea.l   PA_sp,a1             ; Increase PA sp
             addq.l    #4,a1
             cmpa.l    #End_of_PA_stack,a1
             bmi.s     .Not_full
             ERROR     "[ Push_PA ] : PA Stack overflow !!!"
             bra       .Exit
.Not_full:   move.l    a0,(a1)              ; Store new PA descriptor
             move.l    a1,PA_sp             ; Store new sp
             jsr       Init_PA              ; Initialize new PA
.Exit:       movem.l   (sp)+,d0/a1
             rts       

;*****************************************************************************
; [ Pop current PA ]
; All registers are restored
;*****************************************************************************
Pop_PA:      
             movem.l   a0/a1,-(sp)
             movea.l   PA_sp,a1             ; Decrease PA sp
             cmpa.l    #PA_Stack,a1
             bpl.s     .Not_empty
             ERROR     "[ Pop_PA ] : PA Stack underflow !!!"
             bra       .Exit
.Not_empty:  subq.l    #4,a1
             move.l    a1,PA_sp             ; Store new sp
             movea.l   (a1),a0              ; Initialize old PA
             jsr       Init_PA
.Exit:       movem.l   (sp)+,a0/a1
             rts       

; [ Initialize PA variables ]
;   IN : a0 - Pointer to PA (.l)
; Changed registers : d0,a1
Init_PA:     
             moveq.l   #0,d0                ; Calculate variables
             move.w    PA_Wd(a0),d0
             divu.w    #6,d0
             move.w    d0,Nr_of_chars
             moveq.l   #0,d0
             move.w    PA_Ht(a0),d0
             divu.w    #7,d0
             move.w    d0,Nr_of_lines
             lea.l     PArea,a1             ; Set print area
             move.w    PA_X(a0),d0
             move.w    d0,(a1)+
             add.w     PA_Wd(a0),d0
             subq.w    #1,d0
             move.w    d0,(a1)+
             move.w    PA_Y(a0),d0
             move.w    d0,(a1)+
             add.w     PA_Ht(a0),d0
             subq.w    #1,d0
             move.w    d0,(a1)
             move.w    PA_X(a0),d0          ; Set cursor
             move.w    PA_Y(a0),d1
             jsr       IG_Set_cursor
             move.w    PA_Ink(a0),d0        ; Set ink & paper
             jsr       IG_Set_ink
             move.w    PA_Paper(a0),d0
             jsr       IG_Set_paper
             rts       

;*****************************************************************************
; [ Prepare a block of text ]
;   IN : d0 - Number of text block (.w)
;        d2 - Number of characters per line (.w)
;        a1 - Pointer to text file (.l)
; All registers are restored
;*****************************************************************************
Prepare_text_block:    
             movem.l   d0-d3/d7/a0-a5,-(sp)
             jsr       Calc_textblock_address     ; Get address of text block
             movea.l   a1,a3                ; Get pointer to text buffer
             move.l    #Max_textblock_size,d0
             jsr       Allocate_memory
             exg.l     a1,a3
             move.l    a3,Text_buffer
             lea.l     Line_buffer,a2
             lea.l     Paragraph_list,a4
             moveq.l   #0,d1                ; Clear counters
             moveq.l   #0,d3
             moveq.l   #0,d4
             moveq.l   #1,d5

; ------------- REGISTER CONTENTS ------------------------------------
;  d1 - Number of characters in current line (.w)
;  d2 - Maximum number of characters per line (.w)
;  d3 - Number of lines currently generated (.w)
;  d4 - Number of lines in current paragraph (.w)
;  d5 - Number of paragraphs currently generated (.w)
;  d7 - Number of words in text block (.w)
;  a1 - Pointer to start of text block (.l)
;  a2 - Pointer to actual position in text buffer (.l)
;  a3 - Pointer to start of current line in text buffer (.l)
;  a4 - Pointer to paragraph length list (.l)

             bra       .Next1
.Loop1:      move.w    (a1)+,d0             ; Get next word
             cmpi.w    #OpenBracket,d0      ; Opening bracket ?
             bne.s     .No_OB
             jsr       .Copy_word           ; Copy word
             bra       .Next1
.No_OB:      cmpi.w    #CarrReturn,d0       ; Carriage return ?
             bne.s     .No_CR
             jsr       .Carriage_return     ; New line
             lea.l     Line_buffer,a2
             bra       .Next1
.No_CR:      cmpi.w    #ParaMark,d0         ; Next paragraph ?
             bne.s     .No_para
             move.w    d4,(a4)+             ; Next paragraph
             moveq.l   #0,d4
             addq.w    #1,d5
             jsr       .Carriage_return     ; New line
             bra.s     .Next1
.No_para:    lea.l     EndPuncts,a5         ; Punctuation ?
             moveq.l   #Nr_Endpuncts-1,d6
.Loop2:      cmp.w     (a5)+,d0
             beq       .Punct
             dbra      d6,.Loop2
             jsr       .Copy_word           ; Copy word + space
             jsr       .Insert_space
             bra.s     .Next1
.Punct:      tst.w     d1                   ; Start of line ?
             beq.s     .Skip
             cmpi.b    #" ",-1(a2)          ; Previous character = space ?
             bne.s     .Skip
             subq.l    #1,a2                ; One character back
             subq.w    #1,d1
.Skip:       jsr       .Copy_word           ; Copy word + space
             jsr       .Insert_space
.Next1:      dbra      d7,.Loop1            ; Next word
             move.b    #0,(a2)              ; Insert EOL
             movea.l   a3,a0                ; Copy last line to text
             lea.l     Line_buffer,a2       ; buffer
.Loop3:      move.b    (a2)+,(a0)+
             tst.b     -1(a2)
             bne.s     .Loop3
             tst.w     d1                   ; Last line not empty ?
             beq.s     .Empty
             addq.w    #1,d3                ; Then one extra line
             addq.w    #1,d4
             lea.l     1(a3,d2.w),a3
.Empty:      move.w    d3,Lines_in_text     ; Store number if lines
             move.w    d4,(a4)+             ; Store number of paragraphs
             move.w    d5,Paras_in_text
             movea.l   Text_buffer,a0       ; Return unused memory
             suba.l    a0,a3
             move.l    a3,d0
             jsr       Shrink_memory
             movem.l   (sp)+,d0-d3/d7/a0-a5
             rts       

.Copy_word:  
             jsr       Find_word            ; Find word
             moveq.l   #0,d6                ; Get length of word
             move.b    (a0)+,d6
             subq.w    #1,d6
             add.w     d6,d1                ; Add to length of line
             bra.s     .Entry4
.Loop4:      move.b    (a0)+,(a2)+          ; Copy word
.Entry4:     dbra      d6,.Loop4
             rts       

.Insert_space:         
             move.b    #" ",(a2)+           ; Insert space
             addq.w    #1,d1
             cmp.w     d2,d1                ; Line too long ?
             bls.s     .Exit
             subq.l    #1,a2                ; Search for last space
.Seek:       cmpi.b    #" ",-(a2)
             bne.s     .Seek
             jsr       .Carriage_return     ; New line
             lea.l     Line_buffer,a0       ; Copy remainder of line
.Loop5:      move.b    (a2)+,(a0)+          ; to start of line buffer
             addq.l    #1,d1
             cmpi.b    #" ",-1(a2)
             bne.s     .Loop5
             movea.l   a0,a2
.Exit:       rts       

.Carriage_return:      
             move.b    #0,(a2)              ; Insert EOL
             movea.l   a3,a0                ; Copy line to text buffer
             lea.l     Line_buffer,a2
.Loop6:      move.b    (a2)+,(a0)+
             tst.b     -1(a2)
             bne.s     .Loop6
             moveq.l   #0,d1                ; New line
             addq.w    #1,d3
             addq.w    #1,d4
             lea.l     1(a3,d2.w),a3
             rts       

;*****************************************************************************
; [ Display & scroll a text ]
;   IN : d0 - Text number (.w)
;        a1 - Pointer to text file (.l)
; All registers are restored
;*****************************************************************************
Mr_Blue_Sky: 
             movem.l   d0-d7/a0-a6,-(sp)
; ------------- Prepare data & display -------------------------------
             move.w    Nr_of_chars,d2       ; Convert the text to ASCII
             jsr       Prepare_text_block
             movea.l   PA_sp,a5             ; Get pointer to PA descriptor
             movea.l   (a5),a5
             jsr       Prepare_scrolling    ; Convert ASCII to graphics
             movea.l   Off_screen,a6        ; Erase window
             jsr       Erase_text_window
             Update_screen 
; ------------- Scroll at all ? --------------------------------------
             move.w    PA_Ht(a5),d0         ; Does it fit ?
             cmp.w     Height_of_buffer,d0
             bmi.s     .Scroll
             moveq.l   #0,d0                ; Show text
             movea.l   Off_screen,a6
             jsr       Refresh_text_window
             Update_screen 
             jsr       Wait_4_user
             bra       Exit_Blue_Sky
; ------------- Scroll down ------------------------------------------
.Scroll:     lea.l     Paragraph_list,a0    ; Initialize registers
             move.w    PA_Ht(a5),d0
             neg.w     d0
             addq.w    #1,d0
             move.w    Nr_of_lines,d6
             move.w    Paras_in_text,d7
             subq.w    #1,d7
.Loop:       move.w    (a0)+,d2             ; Load length of paragraph
.Again:      cmp.w     d6,d2                ; Too large ?
             bhi.s     .Too_large
             move.w    d2,d1                ; Scroll remainder of
             jsr       Scroll_up            ; paragraph
             jsr       Wait_4_user
             bra.s     .Next
.Too_large:  move.w    d6,d1                ; Scroll full window
             jsr       Scroll_up
             jsr       Wait_4_user
             sub.w     d6,d2                ; Update
             bra.s     .Again
.Next:       dbra      d7,.Loop             ; Next paragraph
             .LOCAL 
; ------------- Free scrolling ---------------------------------------
             jsr       Mouse_off
             lea.l     Scroll_MA,a0         ; Make custom MA
             move.w    Height_of_buffer,d1
             subq.w    #1,d1
             move.w    d1,6(a0)
             jsr       Push_MA
             move.w    Height_of_buffer,d2  ; Initialize registers
             sub.w     PA_Ht(a5),d2
             move.w    Mouse_Y,d1
.Again:      movea.l   Off_screen,a6        ; Scroll
             jsr       Refresh_text_window
             jsr       Switch_screen
.Wait:       tst.b     Mouse_button_state   ; Mouse button pressed ?
             bne.s     .Exit
             move.w    Mouse_Y,d3           ; Update scroll factor
             move.w    d3,d4
             sub.w     d1,d4
             beq.s     .Wait
             move.w    d3,d1
             tst.w     d4                   ; Scroll up or down ?
             bmi.s     .Up
             add.w     d4,d0                ; Clip down
             cmp.w     d2,d0
             bmi.s     .Again
             move.w    d2,d0
             bra.s     .Again
.Up:         add.w     d4,d0                ; Clip up
             bpl.s     .Again
             moveq.l   #0,d0
             bra.s     .Again
; ------------- Restore ----------------------------------------------
.Exit:       Pop       MA
Exit_Blue_Sky:         
             movea.l   Off_screen,a6        ; Erase text
             jsr       Erase_text_window
             Update_screen 
             jsr       Mouse_on
             movea.l   Text_graphics_buffer,a0    ; Free memory
             jsr       Free_memory
             clr.b     Mouse_click_state    ; Aargh
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

; [ Wait for the user ]
; All registers are restored
Wait_4_user: 
             move.l    d0,-(sp)
             Push      Mptr,#16             ; Zzz
.Wait:       btst      #1,Mouse_button_state      ; Left mouse button clicked ?
             beq.s     .Wait
             Wait_4_unclick                 ; Release it
             Pop       Mptr                 ; Old mouse
             move.l    (sp)+,d0
             rts       

; [ Scroll the text up ]
;   IN : d0 - Start scroll position (.w)
;        d1 - Number of LINES to scroll (.w)
;  OUT : d0 - Updated scroll position (.w)
; Changed registers : d0
Scroll_up:   
             movem.l   d1/a6,-(sp)
             mulu.w    #7,d1
             add.w     d0,d1
.Again:      movea.l   Off_screen,a6        ; Refresh
             jsr       Refresh_text_window
             jsr       Switch_screen
             addq.w    #1,d0                ; Scroll down
             cmp.w     d1,d0                ; Ready ?
             bmi.s     .Again
             jsr       Copy_screen
             movem.l   (sp)+,d1/a6
             rts       

;*****************************************************************************
; [ Input a string ]
;   IN : d0 - Maximum length of input string (.w)
;        a6 - Screen base (.l)
; All registers are restored
; !!! WARNING !!! The print area can interfere with the input routine !!!
;*****************************************************************************
Input_string:          
             movem.l   d0/d1/d7/a0-a2,-(sp)
             lea.l     Input_buffer,a1      ; Initialize registers
             lea.l     Input_mask_table-32,a2
             move.w    d0,d1
             moveq.l   #0,d7
             lea.l     .FirstCursor(pc),a0  ; Print cursor
             jsr       IG_Print
.Again:      jsr       Wait_4_key           ; Read a key
             cmpi.b    #13,d0               ; Return ?
             beq       .Return
             swap.w    d0                   ; Backspace ?
             cmpi.b    #14,d0
             beq       .Backspace
             swap.w    d0
             cmp.w     d1,d7                ; Too much characters ?
             bpl.s     .Again
             andi.w    #$00ff,d0            ; Legal character ?
             cmpi.w    #32,d0
             bmi.s     .Again
             move.b    0(a2,d0.w),d0        ; Mask & translate
             andi.w    #$00ff,d0
             bmi.s     .Again
             lea.l     .Output_string(pc),a0      ; Print character
             move.b    d0,1(a0)
             jsr       IG_Print
             move.b    d0,0(a1,d7.w)        ; Store character
             addq.w    #1,d7                ; Next character
             bra.s     .Again
.Backspace:  tst.w     d7                   ; First digit ?
             beq       .Again
             lea.l     .Backspace_string(pc),a0   ; Print end string
             jsr       IG_Print
             subq.l    #1,d7                ; Previous digit
             bra.s     .Again
.Return:     lea.l     .End_string(pc),a0   ; Print end string
             jsr       IG_Print
             clr.b     0(a1,d7.w)           ; Insert end of word
             movem.l   (sp)+,d0/d1/d7/a0-a2
             rts       

.FirstCursor:          .DC.b "_",0
.Output_string:        .DC.b 14," _",0
.Backspace_string:     .DC.b 14,14,"_ ",14,0
.End_string: .DC.b 14," ",0
             .EVEN 

;*****************************************************************************
; [ Initialize random access text block ]
; All registers are restored
;*****************************************************************************
Init_RText:  
             movem.l   d0/a1,-(sp)
             move.w    #0,RText_X           ; Set parameters
             move.w    #0,RText_Y
             move.w    #0,Lines_in_text
             move.l    #Max_textblock_size,d0     ; Make text buffer
             jsr       Allocate_memory
             move.l    a1,RText_ptr
             clr.b     (a1)                 ; Insert EOL
             movem.l   (sp)+,d0/a1
             rts       

;*****************************************************************************
; [ Exit random access text block ]
; All registers are restored
;*****************************************************************************
Exit_RText:  
             move.l    a0,-(sp)
             movea.l   RText_ptr,a0         ; Remove text buffer
             jsr       Free_memory
             movea.l   (sp)+,a0
             rts       

;*****************************************************************************
; [ Add ASCII-text to random access text block ]
;   IN : a0 - Pointer to ASCII text (.l)
; All registers are restored
;*****************************************************************************
Add_ASCII_2_RText:     
             movem.l   d0-d3/a0-a3,-(sp)
             move.w    Nr_of_chars,d1       ; Load parameters
             move.w    RText_X,d2
             move.w    RText_Y,d3
             movea.l   RText_ptr,a1         ; Calculate text pointer
             move.w    d3,d0
             mulu.w    d1,d0
             adda.w    d0,a1
             adda.w    d3,a1
             move.l    a1,-(sp)             ; Copy 1st part of line in
             lea.l     Line_buffer,a2       ; buffer
             move.w    d2,d0
             bra.s     .Entry
.Loop:       move.b    (a1)+,(a2)+
.Entry:      dbra      d0,.Loop
             movea.l   (sp)+,a1
             .LOCAL 

; ------------- REGISTER CONTENTS ------------------------------------
;  d1 - Characters per line (.w)
;  d2 - Current X position (.w)
;  d3 - Current Y position (.w)
;  a0 - Pointer to ASCII-text (.l)
;  a1 - Pointer to start of current line in random access text (.l)
;  a2 - Pointer to current position in line buffer (.l)

.Again:      move.b    (a0)+,d0             ; End of text ?
             beq       .End
             cmpi.b    #13,d0               ; Carriage return ?
             bne.s     .No_CR
             jsr       .Carriage_return     ; New line
             lea.l     Line_buffer,a2
             bra       .Again
.No_CR:      move.b    d0,(a2)+             ; Copy character
             addq.w    #1,d2
             cmp.w     d1,d2                ; Line too long ?
             bls.s     .Again
             clr.b     (a2)                 ; Insert EOL
             subq.l    #1,a2                ; Search for last space
.Seek:       cmpi.b    #" ",-(a2)
             bne.s     .Seek
             jsr       .Carriage_return     ; New line
             lea.l     1(a2),a3             ; Copy remainder to start
             lea.l     Line_buffer,a2       ; of next line
.Loop1:      tst.b     (a3)
             beq.s     .Again
             move.b    (a3)+,(a2)+
             addq.w    #1,d2
             bra.s     .Loop1
.End:        move.w    d2,RText_X           ; Store new position
             move.w    d3,RText_Y
             tst.w     d2                   ; Anything left in last line ?
             beq.s     .Skip
             lea.l     Line_buffer,a0       ; Copy line to text buffer
             move.w    d2,d0
             subq.w    #1,d0
.Loop2:      move.b    (a0)+,(a1)+
             dbra      d0,.Loop2
             addq.w    #1,d3                ; One line more
.Skip:       clr.b     (a1)                 ; Insert EOL
             move.w    d3,Lines_in_text     ; Store new number of lines
             movem.l   (sp)+,d0-d3/a0-a3
             rts       

.Carriage_return:      
             move.l    a2,-(sp)
             move.b    #0,(a2)              ; Insert EOL
             lea.l     Line_buffer,a2       ; Copy line to text buffer
             movea.l   a1,a3
.Loop3:      move.b    (a2)+,(a3)+
             tst.b     -1(a2)
             bne.s     .Loop3
             moveq.l   #0,d2                ; New line
             addq.w    #1,d3
             lea.l     1(a1,d1.w),a1
             movea.l   (sp)+,a2
             rts       

;*****************************************************************************
; [ Add encoded text to random access text block ]
;   IN : d0 - Number of text block (.w)
;        a1 - Pointer to text file (.l)
; All registers are restored
;*****************************************************************************
Add_encoded_2_RText:   
             movem.l   d0/d1/d6/d7/a0-a3,-(sp)
             jsr       Calc_textblock_address     ; Get address of text block
             movea.l   a1,a2
             move.l    #Max_textblock_size,d0     ; Make text buffer
             jsr       Allocate_memory
             exg.l     a1,a2
             move.l    a2,Text_buffer
             bra       .Next1
.Loop1:      move.w    (a1)+,d0             ; Get next word
             cmpi.w    #OpenBracket,d0      ; Opening bracket ?
             bne.s     .No_OB
             jsr       .Copy_word           ; Copy word
             bra       .Next1
.No_OB:      cmpi.w    #CarrReturn,d0       ; Carriage return ?
             bne.s     .No_CR
             move.b    #13,(a2)+            ; Insert
             bra       .Next1
.No_CR:      lea.l     EndPuncts,a3         ; Punctuation ?
             moveq.l   #Nr_Endpuncts-1,d6
.Loop2:      cmp.w     (a3)+,d0
             beq.s     .Punct
             dbra      d6,.Loop2
             bra.s     .Skip
.Punct:      cmpi.b    #" ",-1(a2)          ; Previous character = space ?
             bne.s     .Skip
             subq.l    #1,a2                ; One character back
.Skip:       jsr       .Copy_word           ; Copy word + space
             move.b    #" ",(a2)+
.Next1:      dbra      d7,.Loop1            ; Next word
             clr.b     (a2)                 ; Insert EOL
             movea.l   Text_buffer,a0       ; Add to random access text
             jsr       Add_ASCII_2_RText
             jsr       Free_memory          ; Free memory
             movem.l   (sp)+,d0/d1/d6/d7/a0-a3
             rts       

.Copy_word:  jsr       Find_word            ; Find word
             moveq.l   #0,d6                ; Get length of word
             move.b    (a0)+,d6
             subq.w    #1,d6
             bra.s     .Entry3
.Loop3:      move.b    (a0)+,(a2)+          ; Copy word
.Entry3:     dbra      d6,.Loop3
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .ABS 0
PA_X:        .DS.w 1   ; PA data offsets
PA_Y:        .DS.w 1
PA_Wd:       .DS.w 1
PA_Ht:       .DS.w 1
PA_Ink:      .DS.w 1
PA_Paper:    .DS.w 1

             .DATA 
EndPuncts:   .DC.w 631,1581,1300,166,155,1302,170,743
PA_sp:       .DC.l PA_Stack
Scroll_MA:   .DC.w 0,0,0,0
Space:       .DC.b " ",0
Return:      .DC.b 13,0
             .EVEN 

; This list contains a {-1} for all illegal characters and a new ASCII-code
; for all legal characters. Codes 0 to 31 aren't included.
Input_mask_table:      
             .DC.b " "
             .DC.b -1,-1,-1,-1,-1,-1        ; !"#$%&
             .DC.b "'"
             .DC.b -1,-1,-1,-1,-1,-1,-1,-1  ; ()*+,-./
             .DC.b "0123456789"
             .DC.b -1,-1,-1,-1,-1,-1,-1     ; :;<=>?@
             .DC.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             .DC.b -1,-1,-1,-1,-1,-1        ; [\]^_`
             .DC.b "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             .DCB.b 6,-1                    ; {|}~Ä
             .DC.b "ö",-1,-1,"é"            ; ÅÇÉÑ
             .DCB.b 9,-1                    ; Ö...ç
             .DC.b "é"
             .DCB.b 5,-1                    ; è...ì
             .DC.b "ô"
             .DCB.b 4,-1                    ; ï...ò
             .DC.b "ôö"
             .DCB.b 3,-1                    ; õ...ù
             .DC.b "û"
             .DCB.b 97,-1                   ; ü...ˇ
             .EVEN 


             .BSS 
Input_buffer:          .DS.b 50
             .EVEN 
Mesmin_X:    .DS.w 1   ; Message minus parameters
Mesmin_Y:    .DS.w 1
Mesmin_Wd:   .DS.w 1
PlusMes_info:          .DS.l 1              ; Pointer to message plus parameters
PlusMes_nr:  .DS.w 1

Paragraph_list:        .DS.w 20
Tween_word_indices:    .DS.l 160
Line_buffer: .DS.b 256
Number_buffer:         .DS.b 64
             .EVEN 
DangerZone:: .DS.l 1

PA_Stack:    .DS.l Max_PA                   ; Print Area stack
End_of_PA_stack:       

Textfile_ptr:          .DS.l 1
Nr_of_chars: .DS.w 1   ; Dimensions of scroll window
Nr_of_lines: .DS.w 1
Lines_in_text:         .DS.w 1              ; Lines in current text
Paras_in_text:         .DS.w 1              ; Paragraphs in current text
Width_of_buffer:       .DS.w 1              ; Dimensions of graphics buffer
Height_of_buffer:      .DS.w 1
Text_buffer: .DS.l 1   ; Text buffer address
Text_graphics_buffer:  .DS.l 1              ; Graphics buffer address
Line_graphics_buffer:  .DS.l 1              ; Line buffer address
Scroll_pos:  .DS.w 1

RText_width: .DS.w 1   ; Random access text variables
RText_X:     .DS.w 1
RText_Y:     .DS.w 1
RText_ptr:   .DS.l 1


             .SECTION 5,DATA
             .IF Language=1
Dictionary_filename:   .DC.b 14,'DICTIONA.ENG',0
             .ENDIF 
             .IF Language=2
Dictionary_filename:   .DC.b 14,'DICTIONA.FRA',0
             .ENDIF 
             .IF Language=3
Dictionary_filename:   .DC.b 14,'DICTIONA.GER',0
             .ENDIF 

Maptext_filename:      .DC.b 10,'MAPTEXT.AMB',0
             .EVEN 

             .SECTION 6,BSS 
Dictionary_ptr:        .DS.l 1
Maptext_ptr: .DS.l 1

             .END 















