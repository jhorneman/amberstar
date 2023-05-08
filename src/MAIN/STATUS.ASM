
; Amberstar status screen
; Written by J.Horneman (In Tune With The Universe)
; Start : 29-4-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "If time will allow
;     We will judge all who came
;      In the wake of our new age to stand for the frail
;       Don't kill the whale"
;   Don't kill the whale, Yes, 1978

             .MACRO DIAG_ON
             st        Time_lock            ; No time update
             movem.l   d0-d7/a0-a6,-(sp)    ; Save registers
             jsr       ON_Diag_screen       ; Diagnostic screen setup
             jsr       DI_Cursor_home
             movea.l   Screen_base,a6
             .ENDM 

             .MACRO DIAG_OFF
             jsr       OFF_Diag_screen      ; Exit diagnostic screen
             movem.l   (sp)+,d0-d7/a0-a6    ; Restore registers
             sf        Time_lock            ; Resume time update
             .ENDM 

             .MACRO PRINT msg
             .IF \'1>0
             lea.l     .\~TXT,a0            ; Direct string
             .SECTION 4,DATA
.\~TXT:      .DC.b \1,13,0
             .TEXT 
             .ELSE 
             lea.l     \1,a0                ; Indirect
             .ENDIF 
             jsr       DI_Print
             .ENDM 

             .MACRO PRINTNR msg,sys,size,value
             .IF \?1
             .IF \'1>0
             lea.l     .\~TXT,a0            ; Direct string
             .SECTION 4,DATA
.\~TXT:      .DC.b \msg,0
             .TEXT 
             .ELSE 
             lea.l     \msg,a0              ; Indirect
             .ENDIF 
             jsr       DI_Print
             .ENDIF 
{"move.",\size,\value,",d0"}
{"jsr DI_",\sys,\size,"_print"}
             .ENDM 

             .MACRO INPUT msg
             lea.l     .\~TXT,a0            ; Print text
             jsr       DI_Input
             .SECTION 4,DATA
.\~TXT:      .DC.b \msg,0                   ; Strings in separate segment
             .TEXT 
             .ENDM 

             .MACRO CR
             jsr       DI_Carriage_return   ; Carriage return
             .ENDM 

             .TEXT 
;*****************************************************************************
Help:        
             DIAG_ON 
             lea.l     Help_msg,a0          ; Print help message
             jsr       DI_Print
             jsr       Wait_4_key
             DIAG_OFF 
             rts                            ; Return

;*****************************************************************************
Status_F1:   
             DIAG_ON 
             PRINT     "[ AMBERSTAR STATUS SCREEN ]"        ; Header
             PRINTNR   "  Map number : ",Dec,w,Map_nr       ; Status display
             CR 
             PRINTNR   "X coordinate : ",Dec,w,Map_Xcoord
             CR 
             PRINTNR   "Y coordinate : ",Dec,w,Map_Ycoord
             CR 
             CR 
             PRINTNR   "View direction : ",Dec,w,View_direction
             CR 
             PRINTNR   "   Travel mode : ",Dec,w,Travel_mode
             CR 
             cmpi.b    #1,Current_map_type  ; Wilderness ?
             bne.s     .Skip
             CR 
             PRINTNR   "World X : ",Dec,w,World_X
             CR 
             PRINTNR   "World Y : ",Dec,w,World_Y
             CR 
.Skip:       CR 
             PRINTNR   "  Year : ",Dec,w,Year
             CR 
             PRINTNR   " Month : ",Dec,w,Month
             CR 
             PRINTNR   "   Day : ",Dec,w,Day
             CR 
             PRINTNR   "  Hour : ",Dec,w,Hour
             CR 
             PRINTNR   "Minute : ",Dec,w,Minute
             CR 
             PRINTNR   " Frame : ",Dec,w,Frame
             CR 
             CR 
             PRINTNR   "Number of members in party : ",Dec,w,Nr_members
             CR 
             CR 
             PRINT     "[ Press any key to exit ]"          ; Footer
             jsr       Wait_4_key
             DIAG_OFF 
             rts                            ; Return

;*****************************************************************************
Status_F2:   
             jmp       Show_memory

;*****************************************************************************
Status_F3:   
             DIAG_ON 
             PRINT     "[ VIEW FREE MEMORY ]"     ; Header
             CR 
             PRINTNR   "        Size of free memory : ",Dec,l,Size_of_free_memory
             CR 
             move.l    Total_size,d0
             sub.l     Size_of_free_memory,d0
             move.l    d0,d1
             PRINTNR   "                Memory used : ",Dec,l,d0
             CR 
             CR 
             movea.l   Basepage,a1
             PRINTNR   "       Size of TEXT segment : ",Dec,l,P_tlen(a1)
             CR 
             PRINTNR   "       Size of DATA segment : ",Dec,l,P_dlen(a1)
             CR 
             PRINTNR   "       Size of  BSS segment : ",Dec,l,P_blen(a1)
             CR 
             CR 
             move.l    #256,d0
             add.l     P_tlen(a1),d0
             add.l     P_dlen(a1),d0
             add.l     P_blen(a1),d0
             PRINTNR   "      Total size of program : ",Dec,l,d0
             CR 
             CR 
             add.l     d1,d0
             PRINTNR   "Total amount of memory used : ",Dec,l,d0
             CR 
             CR 
             PRINT     "[ Press any key to exit ]"          ; Footer
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

;*****************************************************************************
Status_F4:   
             DIAG_ON 
             PRINT     "[ VIEW MODIFICATION INFO ]"         ; Header
             CR 
             move.w    Nr_of_modifications,d7
             PRINTNR   "Number of modifications : ",Dec,w,d7
             CR 
             CR 
             movea.l   Modifications_ptr,a1
             bra.s     .Entry
.Loop:       PRINTNR   "> ",Dec,w,(a1)+
             PRINTNR   ",",Dec,b,(a1)+
             PRINTNR   ",",Dec,b,(a1)+
             PRINTNR   ",",Dec,w,(a1)+
             CR 
.Entry:      dbra      d7,.Loop
             CR 
             PRINT     "[ Press any key to exit ]"          ; Footer
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

;*****************************************************************************
Status_F5:   
             DIAG_ON 
             PRINT     "[ VIEW MODULE STACK ]"    ; Header
             CR 
             lea.l     Module_stack,a1
             movea.l   Module_sp,a2
             bra.s     .Entry
.Loop:       movea.l   IDString_ptr(a1),a0  ; Print ID string
             jsr       DI_Print
             CR 
             lea.l     ModuleDataSize(a1),a1      ; Next module
.Entry:      cmpa.l    a1,a2
             bhi.s     .Loop
             PRINT     .Blue
             movea.l   IDString_ptr(a1),a0  ; Print last ID string
             jsr       DI_Print
             PRINT     .White
             CR 
             PRINT     "[ Press any key to exit ]"          ; Footer
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

.Blue:       .DC.b 3,2,0
.White:      .DC.b " <- ACTIVE.",3,1,13,0
             .EVEN 

;*****************************************************************************
Status_F6:   
             DIAG_ON 
             PRINT     "[ INCREASE EXPERIENCE POINTS ]"     ; Header
             CR 
             movea.l   Current_active_char_data,a1
             PRINTNR   "Current experience points : ",Dec,l,Experience_points(a1)
             CR 
.Again1:     INPUT     "Enter extra amount : "
             tst.l     d0                   ; Error check
             bmi.s     .Exit
             beq.s     .Again1
             add.l     d0,Experience_points(a1)   ; Store
.Exit:       DIAG_OFF 
             rts                            ; Return

;*****************************************************************************
Status_F7:   
             jsr       Exit_display
             Push      Module,Minimap_Mod
             rts       

;*****************************************************************************
Status_F8:   
             DIAG_ON 
             PRINT     "[ CHANGE MAP ]"     ; Header
             CR 
.Again:      INPUT     "Enter new map : "
             tst.l     d0                   ; Error check
             bmi.s     .Exit
             beq.s     .Again
             move.w    d0,New_map
             DIAG_OFF 
             jsr       Exit_map             ; Change map
             move.w    New_map,Map_nr
             move.w    #7,Map_Xcoord
             move.w    #7,Map_Ycoord
             move.w    #0,View_direction
             jsr       Init_map
             rts       
.Exit:       DIAG_OFF 
             rts       

;*****************************************************************************
Status_F9:   
             DIAG_ON 
             PRINT     "[ SAVE NEO PICTURE ]"     ; Header
             CR 
             INPUT     "Enter 4-digit identifier ('AMBR????.NEO') : "
             CR 
             tst.w     d0
             bmi       .Exit
             move.w    #"0",d1              ; Insert number in filenames
             moveq.l   #4,d7
             lea.l     Picture_filename+4,a3
             jsr       RConvert_number
             lea.l     Raster_filename+4,a3
             jsr       RConvert_number
; ------------- Make & save picture file -----------------------------
             PRINT     "Creating picture..."
             CR 
             move.l    #32128,d0            ; Make buffer
             jsr       Allocate_memory
             movea.l   a1,a2
             moveq.l   #32-1,d7             ; Clear first 128 bytes
.Loop1:      clr.l     (a1)+
             dbra      d7,.Loop1
             movea.l   User_HBL_list,a1     ; Copy palette
             addq.l    #2,a1
             movem.l   (a1),d0-d7
             movem.l   d0-d7,4(a2)
             move.l    #"NEO!",124(a2)      ; Insert magic longword
             moveq.l   #0,d0                ; Copy screen to file buffer
             moveq.l   #0,d1
             moveq.l   #20,d6
             move.w    #200,d7
             movea.l   On_screen,a0
             lea.l     128(a2),a1
             jsr       Duplicate_block
             move.l    #32128,d0            ; Save file
             lea.l     Picture_filename,a0
             movea.l   a2,a1
             jsr       Save_file
             PRINT     "Picture has been saved."
             CR 
             movea.l   a2,a0                ; De-allocate file buffer
             jsr       Free_memory
; ------------- Make & save raster file ------------------------------
             PRINT     "Creating raster file..."
             CR 
             move.l    #6800,d0             ; Make buffer
             jsr       Allocate_memory
             movea.l   a1,a2
             movea.l   a1,a0                ; Clear buffer
             move.w    #1700-1,d7
.Loop2:      clr.l     (a0)+
             dbra      d7,.Loop2
             movea.l   User_HBL_list,a0     ; Get pointer to HBL list
             addq.l    #2,a0
             move.w    #0,(a1)+             ; Write first Y-offset
             bra.s     .Entry
.Again:      tst.w     (a0)                 ; End of list ?
             beq.s     .End
             moveq.l   #0,d0                ; Write Y-offset
             move.b    (a0)+,d0
             move.w    d0,(a1)+
             tst.b     (a0)+                ; Palette or single colour ?
             bne.s     .Single
.Entry:      moveq.l   #8-1,d7              ; Write palette
.Loop3:      move.l    (a0)+,(a1)+
             dbra      d7,.Loop3
             bra.s     .Again
.Single:     movea.l   a1,a3                ; Copy previous palette
             moveq.l   #8-1,d7
.Loop4:      move.l    -34(a3),(a3)+
             dbra      d7,.Loop4
             move.w    (a0)+,d0             ; Write altered colour
             add.w     d0,d0
             move.w    (a0)+,0(a1,d0.w)
             lea.l     32(a1),a1
             bra.s     .Again
.End:        move.l    #6800,d0             ; Save file
             lea.l     Raster_filename,a0
             movea.l   a2,a1
             jsr       Save_file
             PRINT     "Raster-file has been saved."
             CR 
             movea.l   a2,a0                ; De-allocate file buffer
             jsr       Free_memory
             PRINT     "[ Press any key to exit ]"          ; Footer
             jsr       Wait_4_key
.Exit:       DIAG_OFF 
             rts       

;*****************************************************************************
Status_F0:   
             move.w    Travel_mode,d0
             tst.w     d0                   ; Toggle superchicken mode
             beq.s     .On
             moveq.l   #0,d0
             bra.s     .Exit
.On:         moveq.l   #6,d0
.Exit:       jsr       Set_new_travel_mode
             rts       

;*****************************************************************************
; [ Show memory ]
; All registers are restored
;*****************************************************************************
Show_memory::          
             DIAG_ON 
             PRINT     .White
             lea.l     Memory_list,a1       ; Ptr = Start
             movea.l   Memlist_end,a2
.Loop:       btst      #7,8(a1)             ; Free or allocated ?
             bne.s     .Next
.Continue:   PRINTNR   ,Hex,l,0(a1)         ; Print start & length
             PRINTNR   ,Dec,l,4(a1)
             lea.l     Memory_types,a3      ; Print type
             moveq.l   #$7f,d0
             and.b     8(a1),d0
             add.w     d0,d0
             add.w     d0,d0
             movea.l   0(a3,d0.w),a3
             PRINT     (a3)
             tst.w     d0                   ; Memory block ?
             beq.s     .Skip
             move.w    10(a1),d0            ; Print subfile number
             addq.w    #1,d0
             PRINTNR   ,Dec,w,d0
.Skip:       CR 
.Next:       lea.l     12(a1),a1            ; Increase Ptr
             cmpa.l    a2,a1                ; While Ptr < End
             bmi.s     .Loop
.Exit:       jsr       Wait_4_key
             DIAG_OFF 
             rts       

.Blue:       .DC.b 3,2,0
.White:      .DC.b 3,1,0
             .EVEN 

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Picture_filename:      .DC.b "AMBRnnnn.NEO",0
Raster_filename:       .DC.b "AMBRnnnn.RST",0
Help_msg:    .DC.b 3,2,"AMBERSTAR",3,1," HELP SCREEN ",13,13
             .DC.b "[ Esc ] exits the program.",13,13
             .DC.b "The following diagnostic functions are available :",13,13
             .DC.b 3,2," [ F1 ]",3,1," - Status screen.",13
             .DC.b 3,2," [ F2 ]",3,1," - View allocated memory.",13
             .DC.b 3,2," [ F3 ]",3,1," - View free memory.",13
             .DC.b 3,2," [ F4 ]",3,1," - View modification info.",13
             .DC.b 3,2," [ F5 ]",3,1," - View module stack.",13
             .DC.b 3,2," [ F6 ]",3,1," - Increase experience points.",13
             .DC.b 3,2," [ F7 ]",3,1," - View map.",13
             .DC.b 3,2," [ F8 ]",3,1," - Change map.",13
             .DC.b 3,2," [ F9 ]",3,1," - Save NEO-picture.",13
             .DC.b 3,2,"[ F10 ]",3,1," - Alter/toggle travel mode.",13
             .DC.b 13,3,2,"Press any key to resume.",3,1,0
             .EVEN 
Memory_types:          .DC.l .Text00,.Text01,.Text02,.Text03,.Text04,.Text05
             .DC.l .Text06,.Text07,.Text08,.Text09,.Text10,.Text11
             .DC.l .Text12,.Text13,.Text14,.Text15,.Text16,.Text17
             .DC.l .Text18

.Text00:     .DC.b "Memory block  ",0
.Text01:     .DC.b "Party data",0
.Text02:     .DC.b "Icon data",0
.Text03:     .DC.b "Character data",0
.Text04:     .DC.b "Map data",0
.Text05:     .DC.b "Lab data",0
.Text06:     .DC.b "Lab block",0
.Text07:     .DC.b "Background",0
.Text08:     .DC.b "Colour palette",0
.Text09:     .DC.b "80x80 Pic",0
.Text10:     .DC.b "Map texts",0
.Text11:     .DC.b "Chest data",0
.Text12:     .DC.b "Monster data",0
.Text13:     .DC.b "Merchant data",0
.Text14:     .DC.b "Dictionary",0
.Text15:     .DC.b "Combat background",0
.Text16:     .DC.b "Monster graphics",0
.Text17:     .DC.b "Automap",0
.Text18:     .DC.b "Text file",0
             .EVEN 


             .BSS 
New_map:     .DS.w 1
Total_size:  .DS.l 1

             .END 







