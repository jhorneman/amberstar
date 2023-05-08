
;      There stands our future
;       There can be no denying
;        Simple as A B C D."
;   I'm Running, Yes, 1987

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   - I am assuming that files which couldn't be opened don't need to be
;     closed.
;   - {Read_bytes.l} contains the length of the most recently loaded file.

             .XDEF Init_file,Load_subfile,Load_file,Save_file
             .XDEF Exist_file,Read_bytes,Save_subfile

             .XREF Reallocate_memory,File_allocate
             .XREF Push_Mptr,Pop_Mptr

             .XREF DI_Error
             .XREF DI_Print,Clear_screen,ON_Diag_screen
             .XREF OFF_Diag_screen,DI_Cursor_home,Screen_base

             .PATH 'E:\MAIN\'
             .PATH 'E:\NUCLEUS\'
             .INCLUDE 'CONST5X.IS'
             .INCLUDE 'MACRO4X.IS'

Max_subfiles           = 255                ; Maximum number of subfiles
Safety_factor          = 2048

             .MACRO START_TIMER_C
             move.w    sr,-(sp)             ; Save SR
             ori.w     #$700,sr             ; Block all interrupts
             ori.b     #$20,MFP_Ierb        ; Enable Timer C
             move.w    (sp)+,sr             ; Restore SR
             .ENDM 
             .MACRO STOP_TIMER_C
             move.w    sr,-(sp)             ; Save SR
             ori.w     #$700,sr             ; Block all interrupts
             andi.b    #$df,MFP_Ierb        ; Disable Timer C
             move.w    (sp)+,sr             ; Restore SR
             .ENDM 
             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; Strings in separate segment
             .TEXT 
             .ENDM 
             .MACRO Push type,ptr
             .IF \!ptr=9
             lea.l     \ptr,a0
             .ELSE 
             move.w    \ptr,d0
             .ENDIF 
{"jsr Push_",\type}
             .ENDM 
             .MACRO Pop type
{"jsr Pop_",\type}
             .ENDM 

             .MACRO XERROR error_msg,filename
             lea.l     .\~ET,a1             ; Call special error routine
             lea.l     \2,a2
             jsr       XError
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; Strings in separate segment
             .TEXT 
             .ENDM 

             .TEXT 
;*****************************************************************************
; [ File routines initialization ]
; All registers are restored
;*****************************************************************************
Init_file:   
             movem.l   d0-d2/a0-a2,-(sp)
             START_TIMER_C 
             D_SETPATH                      #Amberfile_path ; Set Amberfile path
             tst.l     d0                   ; Succesful ?
             beq.s     .Ok
             ERROR     "[ Init_file ] :  Amberfile folder wasn't found !!!"
             bra.s     .Exit
.Ok:         F_GETDTA  ; Get DTA address
             move.l    d0,DTA_ptr
.Exit:       STOP_TIMER_C 
             movem.l   (sp)+,d0-d2/a0-a2
             rts       

;*****************************************************************************
; [ Check if a file exists ]
;   IN : a0 - Pointer to pathname of file (.l)
;  OUT :     zero - File doesn't exist
;        non-zero - File exists
; All registers are restored
;*****************************************************************************
Exist_file:  
             movem.l   d0-d2/a0-a2,-(sp)
             addq.l    #1,a0                ; Skip file type
             START_TIMER_C                  ; Fill DTA
             F_SFIRST  #0,a0
             STOP_TIMER_C 
             cmpi.l    #-33,d0              ; Well ?
             movem.l   (sp)+,d0-d2/a0-a2
             rts       

;*****************************************************************************
; [ Load subfile from Amberfile ]
;   IN : d0 - Subfile number (starting at 1 !!!) (.w)
;        a0 - Pointer to filename of Amberfile (.l)
;  OUT : a0 - Pointer to buffer with subfile (.l)
; Changed registers : a0
;*****************************************************************************
Load_subfile:          
             movem.l   d0-d7/a1-a4,-(sp)
             subq.w    #1,d0
             bpl.s     .Ok_0
             XERROR    "[ Load_subfile ] : Zero not allowed !!!",1(a0)
             bra       .Exit2
; ------------- Check if the file has already been loaded ------------
.Ok_0:       move.w    d0,d1
             move.b    (a0)+,d0
             movea.l   a0,a4                ; Protect filename
             jsr       Reallocate_memory
             cmpa.l    #0,a0                ; Already present ?
             bne       .Exit2
             move.w    d1,d6
; ------------- Open the Amberfile -----------------------------------
             START_TIMER_C 
             Push      Mptr,#15             ; Disk pointer
             movea.l   a4,a0                ; Open file
             F_OPEN    #0,a0
             tst.l     d0                   ; Succesful ?
             bpl.s     .Ok_1
             XERROR    "[ Load_subfile ] : Could not open Amberfile !!!",(a4)
             bra       .Exit
.Ok_1:       move.w    d0,d7                ; Protect handle
; ------------- Read the Amberfile header ----------------------------
             F_READ    #Header_buffer,#6,d7 ; Read header
             cmpi.l    #"AMBR",Header_buffer      ; Is it an Amberfile ?
             beq.s     .Ok_2
             cmpi.l    #"AMPC",Header_buffer      ; Is it packed ?
             beq.s     .Ok_2
             XERROR    "[ Load_subfile ] : This is not an Amberfile !!!",(a4)
             bra       .Exit
.Ok_2:       move.w    Header_buffer+4,d5   ; Load number of subfiles
             cmp.w     d5,d6                ; Legal input ?
             bmi.s     .Ok_3
             XERROR    "[ Load_subfile ] : Illegal input !!!",(a4)
             bra       .Exit
.Ok_3:       
; ------------- REGISTER CONTENTS ------------------------------------
;  d5 - Number of subfiles in current Amberfile (.w)
;  d6 - Number of desired subfile (.w)
;  d7 - Handle of current Amberfile (.w)
;  a4 - Pointer to filename (.l)

; ------------- Read all subfile lengths -----------------------------
             ext.l     d5
             lsl.l     #2,d5
             lea.l     Subfile_lengths,a3   ; Read ALL subfile lengths
             F_READ    a3,d5,d7
             addq.l    #6,d5                ; Length of header
             move.w    d6,d0
             bra.s     .Entry
.Loop:       add.l     (a3)+,d5             ; Add subfile length
.Entry:      dbra      d0,.Loop             ; Next subfile

             cmpi.l    #"AMBR",Header_buffer      ; Packed or unpacked ?
             bne       .Packed

; ------------- REGISTER CONTENTS ------------------------------------
;  d5 - Offset to desired subfile (.l)
;  d6 - Number of desired subfile (.l)
;  d7 - Handle of current Amberfile (.w)
;  a3 - Pointer to length of desired subfile (.l)
;  a4 - Pointer to filename (.l)

             move.b    -1(a4),d0            ; Allocate file memory
             move.l    (a3),d1
             move.w    d6,d2
             jsr       File_allocate
             move.l    (a3),d4              ; Load length of subfile
             movea.l   a1,a3                ; Protect buffer pointer
             F_SEEK    #0,d7,d5             ; Seek file pointer
             F_READ    a3,d4,d7             ; Read subfile
             move.l    d0,Read_bytes
             bra       .Exit
.Packed:     
             F_SEEK    #0,d7,d5             ; Read header
             F_READ    #Header_buffer,#8,d7
             F_SEEK    #1,d7,#-8
             move.b    -1(a4),d0            ; Allocate file memory
             move.l    Header_buffer+4,d1
             andi.l    #$00ffffff,d1
             addi.l    #Safety_factor,d1
             move.w    d6,d2
             jsr       File_allocate
             move.l    (a3),d4              ; Load length of subfile
             movea.l   a1,a3                ; Protect buffer pointer
             F_READ    a3,d4,d7             ; Read subfile
             movea.l   a3,a0                ; Unpack
             jsr       Decompress
             move.l    Header_buffer+4,d0   ; Return unused memory
             andi.l    #$00ffffff,d0
             move.l    d0,Read_bytes
             jsr       Shrink_memory
.Exit:       F_CLOSE   d7
             Pop       Mptr
             STOP_TIMER_C 
             movea.l   a3,a0
.Exit2:      movem.l   (sp)+,d0-d7/a1-a4
             rts       

;*****************************************************************************
; [ Load a normal file ]
;   IN : a0 - Pointer to pathname of file (.l)
;  OUT : a0 - Pointer to buffer with file (.l)
; Changed registers : a0
;*****************************************************************************
Load_file:   
             movem.l   d0-d3/d7/a1-a3,-(sp)
; ------------- Check if the file has already been loaded ------------
             lea.l     1(a0),a3             ; Protect filename
             move.b    (a0)+,d0
             beq.s     .Skip
             moveq.l   #0,d1
             jsr       Reallocate_memory
             cmpa.l    #0,a0                ; Already present ?
             bne       .Exit2
; ------------- Get file length --------------------------------------
.Skip:       START_TIMER_C 
             Push      Mptr,#15             ; Disk pointer
             F_SFIRST  #0,a3                ; Fill DTA
             movea.l   DTA_ptr,a0           ; Get length of file
             move.l    26(a0),d3

; ------------- REGISTER CONTENTS ------------------------------------
;  d3 - File length (.l)
;  a3 - Pointer to filename (.l)

             move.b    -1(a3),d0            ; Allocate file memory
             move.l    d3,d1
             moveq.l   #0,d2
             jsr       File_allocate
             exg.l     a1,a3                ; Protect buffer address
             F_OPEN    #0,a1                ; Open file
             tst.l     d0                   ; Succesful ?
             bpl.s     .Ok
             XERROR    "[ Load_file ] : Could not open file !!!",(a1)
             bra       .Exit
.Ok:         move.w    d0,d7                ; Protect handle
             F_READ    a3,d3,d7             ; Read file
             move.l    d0,Read_bytes
             F_CLOSE   d7                   ; Close file
             movea.l   a3,a0                ; Copy to output register
.Exit:       Pop       Mptr
             STOP_TIMER_C 
.Exit2:      movem.l   (sp)+,d0-d3/d7/a1-a3
             rts       

;*****************************************************************************
; [ Save a file ]
;   IN : d0 - Length of file (.l)
;        a0 - Pointer to pathname of file (.l)
;        a1 - Pointer to buffer with file (.l)
; All registers are restored
;*****************************************************************************
Save_file:   
             movem.l   d0-d2/d6/d7/a0-a3,-(sp)
             move.l    d0,d7                ; Protect file length
             movea.l   a0,a3
             Push      Mptr,#15             ; Disk pointer
             START_TIMER_C 
             F_CREATE  #0,a0                ; Create file
             tst.l     d0
             bpl.s     .Ok1
             XERROR    "[ Save_file ] : Could not create file !!!",(a3)
             bra       .Exit
.Ok1:        move.l    d0,d6                ; Protect handle
             F_WRITE   a1,d7,d6             ; Write file
             tst.l     d0
             bpl.s     .Ok2
             XERROR    "[ Save_file ] : Could not write file !!! Disk full ?",(a3)
             bra       .Exit
.Ok2:        F_CLOSE   d6                   ; Close file
.Exit:       STOP_TIMER_C 
             Pop       Mptr
             movem.l   (sp)+,d0-d2/d6/d7/a0-a3
             rts       

;*****************************************************************************
; [ Save subfile to Amberfile ]
;   IN : d0 - Subfile number (starting at 1 !!!) (.w)
;        a0 - Pointer to filename of Amberfile (.l)
;        a1 - Pointer to buffer with file (.l)
; All registers are restored
;*****************************************************************************
Save_subfile:          
             movem.l   d0-d7/a0-a5,-(sp)
             subq.w    #1,d0
             bpl.s     .Ok_0
             XERROR    "[ Save_subfile ] : Zero not allowed !!!",1(a0)
             bra       .Exit2
.Ok_0:       move.w    d0,d6                ; Protect stuff
             lea.l     1(a0),a4
             movea.l   a1,a5
; ------------- Open the Amberfile -----------------------------------
             START_TIMER_C 
             Push      Mptr,#15             ; Disk pointer
             F_OPEN    #2,a4                ; Open file
             tst.l     d0                   ; Succesful ?
             bpl.s     .Ok_1
             XERROR    "[ Save_subfile ] : Could not open Amberfile !!!",(a4)
             bra       .Exit
.Ok_1:       move.w    d0,d7                ; Protect handle
; ------------- Read the Amberfile header ----------------------------
             F_READ    #Header_buffer,#6,d7 ; Read header
             cmpi.l    #"AMBR",Header_buffer      ; Is it an Amberfile ?
             beq.s     .Ok_2
             XERROR    "[ Save_subfile ] : This is not an unpacked Amberfile !!!",(a4)
             bra       .Exit
.Ok_2:       move.w    Header_buffer+4,d5   ; Load number of subfiles
             cmp.w     d5,d6                ; Legal input ?
             bmi.s     .Ok_3
             XERROR    "[ Save_subfile ] : Illegal input !!!",(a4)
             bra       .Exit

; ------------- REGISTER CONTENTS ------------------------------------
;  d5 - Number of subfiles in current Amberfile (.w)
;  d6 - Number of desired subfile (.w)
;  d7 - Handle of current Amberfile (.w)
;  a4 - Pointer to filename (.l)
;  a5 - Pointer to buffer with file (.l)

; ------------- Read all subfile lengths -----------------------------
.Ok_3:       ext.l     d5
             lsl.l     #2,d5
             lea.l     Subfile_lengths,a3   ; Read ALL subfile lengths
             F_READ    a3,d5,d7
             addq.l    #6,d5                ; Length of header
             move.w    d6,d0
             bra.s     .Entry
.Loop:       add.l     (a3)+,d5             ; Add subfile length
.Entry:      dbra      d0,.Loop             ; Next subfile

; ------------- REGISTER CONTENTS ------------------------------------
;  d5 - Offset to desired subfile (.l)
;  d6 - Number of desired subfile (.l)
;  d7 - Handle of current Amberfile (.w)
;  a3 - Pointer to length of desired subfile (.l)
;  a4 - Pointer to filename (.l)
;  a5 - Pointer to buffer with file (.l)

             move.l    (a3),d4              ; Load length of subfile
             F_SEEK    #0,d7,d5             ; Seek file pointer
             F_WRITE   a5,d4,d7             ; Write subfile
             tst.l     d0
             bpl.s     .Exit
             XERROR    "[ Save_subfile ] : Could not write file !!! Disk full ?",(a4)
.Exit:       F_CLOSE   d7
             Pop       Mptr
             STOP_TIMER_C 
.Exit2:      movem.l   (sp)+,d0-d7/a0-a5
             rts       

;*****************************************************************************
; [ Decompress ]
;   IN : a0 - Pointer to packed file (.l)
; All registers are restored
;*****************************************************************************
Decompress:  
             movem.l   d0-d7/a0-a6,-(sp)
             move.l    #Safety_factor,d0
             jsr       .Do_it
             movem.l   (sp)+,d0-d7/a0-a6
             rts       

.Do_it:      .IBYTES 'EXPANDER.IMG'
             .EVEN 

;*****************************************************************************
; [ Special error ]
;   IN : a1 - Pointer to error text (.l)
;        a2 - Pointer to pathname (.l)
; All registers are restored
;*****************************************************************************
XError:      
             movem.l   d0-d7/a0-a6,-(sp)    ; Save registers
             jsr       ON_Diag_screen       ; Diagnostic screen setup
             jsr       DI_Cursor_home
             movea.l   Screen_base,a6
             lea.l     Error_msg1,a0        ; Print
             jsr       DI_Print
             movea.l   a1,a0
             jsr       DI_Print
             lea.l     XError_msg,a0
             jsr       DI_Print
             movea.l   a2,a0
             jsr       DI_Print
             lea.l     Error_msg2,a0
             jsr       DI_Print
             jsr       Wait_4_key
             cmpi.b    #"x",d0              ; Exit on 'x'
             bne.s     .Exit
             illegal 
.Exit:       jsr       OFF_Diag_screen      ; Exit diagnostic screen
             movem.l   (sp)+,d0-d7/a0-a6    ; Restore registers
             rts       

             .SECTION 4,DATA
Error_msg1:  .DC.b 3,2,1," !!! An ERROR has occurred !!! ",13,13,2,3,1,0
Error_msg2:  .DC.b 13,13,3,2,1," Press any key to continue...  ",2,0
XError_msg:  .DC.b 13,"Filename : ",0

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .DATA 
Amberfile_path:        .DC.b "\AMBRFILE\",0
             .EVEN 

             .BSS 
Read_bytes:  .DS.l 1
DTA_ptr:     .DS.l 1   ; Pointer to DTA
Header_buffer:         
             .DS.l 1   ; Magic longword "AMBR"/"AMPC"
             .DS.w 1   ; Number of subfiles in this Amberfile
             .DS.w 1
Subfile_lengths:       .DS.l Max_subfiles

             .END 



















