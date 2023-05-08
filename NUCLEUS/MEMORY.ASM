
; Memory Manager II (Real hatred is timeless)
; Written by J.Horneman (In Tune With The Universe)
; Start : 6-7-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

;   "High the memory carry on
;     While the moments start to linger
;      Sail away among your dreams
;       The strength regains in between our time
;        The strength regains in between our time"
;   The Remembering / High The Memory, Yes, 1973

             .XDEF Init_memory,Next_generation
             .XDEF Allocate_memory,Reallocate_memory
             .XDEF File_allocate,Kill_memory,Free_memory,Shrink_memory
             .XDEF Size_of_free_memory

             .XDEF Memory_list,Memlist_end

             .XREF DI_Error

             .PATH 'E:\MAIN\'
             .INCLUDE 'CONST5X.IS'

             .MACRO ERROR error_msg
             lea.l     .\~ET,a1             ; Call error routine
             jsr       DI_Error
             .SECTION 4,DATA
.\~ET:       .DC.b \1,13,0                  ; String in DATA segment
             .TEXT 
             .ENDM 

Max_memblocks          = 1000               ; Maximum number of allocated blocks
Minimum_mem  = 100*1024                     ; Minimum amount of memory needed

;*****************************************************************************
; [ Initialize memory manager ]
;   IN : a0 - Pointer to basepage (.l)
; All registers are restored
;*****************************************************************************
Init_memory: 
             movem.l   d0/d1/a0,-(sp)
             move.l    P_bbase(a0),d0       ; Calculate start of TPA
             add.l     P_blen(a0),d0
             move.l    d0,Start_of_free_memory
             move.l    P_hitpa(a0),d1       ; Calculate size of memory
             sub.l     d0,d1
             cmpi.l    #Minimum_mem,d1      ; Is it enough ?
             bpl.s     .Enough
             ERROR     "[ Init_memory ] : Not enough memory !!!"
             bra.s     .Exit
.Enough:     move.l    d1,Size_of_free_memory
             lea.l     Memory_list,a0       ; Initialize the memory list
             move.l    d0,(a0)+
             move.l    d1,(a0)+
             move.w    #$8000,(a0)
             addq.l    #4,a0
             move.l    a0,Memlist_end
.Exit:       movem.l   (sp)+,d0/d1/a0
             rts       

;*****************************************************************************
; [ Next generation ]
; All registers are restored
;*****************************************************************************
Next_generation:       
             movem.l   d0/d1/a0/a1,-(sp)
             lea.l     Memory_list,a0       ; Ptr = Start
             movea.l   Memlist_end,a1
             moveq.l   #$3f,d0
             bra       .Entry
.Loop:       btst.b    #7,8(a0)             ; Allocated ?
             beq.s     .Next
             move.b    d0,d1                ; Is it a file ?
             and.b     8(a0),d1
             beq.s     .Next
             moveq.l   #0,d1                ; Decrease priority
             move.b    9(a0),d1
             subq.w    #8,d1
             bmi.s     .Next
             move.b    d1,9(a0)
.Next:       lea.l     12(a0),a0            ; Increase Ptr
.Entry:      cmpa.l    a1,a0                ; While Ptr < End
             bmi.s     .Loop
.Overflow:   movem.l   (sp)+,d0/d1/a0/a1
             rts       

;*****************************************************************************
; [ Remove allocated memory ]
;   IN : a0 - Pointer to memory block (.l)
; All registers are restored
;*****************************************************************************
Kill_memory: 
             movem.l   d0/a1/a2,-(sp)
             lea.l     Memory_list,a1       ; Ptr = Start
             movea.l   Memlist_end,a2
             bra.s     .Entry
.Loop:       btst      #7,8(a1)             ; Allocated ?
             bne.s     .Next
             cmpa.l    (a1),a0              ; Found ?
             bne.s     .Next
             move.l    #$80000000,8(a1)     ; De-allocated memory block
             move.l    4(a1),d0             ; Update
             add.l     d0,Size_of_free_memory
             bra.s     .Exit
.Next:       lea.l     12(a1),a1            ; Increase Ptr
.Entry:      cmpa.l    a2,a1                ; While Ptr < End
             bmi.s     .Loop
             ERROR     "[ Kill_memory ] : Memory wasn't allocated !!!"
.Exit:       movem.l   (sp)+,d0/a1/a2
             rts       

;*****************************************************************************
; [ Return allocated memory ]
;   IN : a0 - Pointer to memory block (.l)
; All registers are restored
;*****************************************************************************
Free_memory: 
             movem.l   d0/a1/a2,-(sp)
             lea.l     Memory_list,a1       ; Ptr = Start
             movea.l   Memlist_end,a2
             bra.s     .Entry
.Loop:       btst      #7,8(a1)             ; Allocated ?
             bne.s     .Next
             cmpa.l    (a1),a0              ; Found ?
             bne.s     .Next
             bset      #7,8(a1)             ; De-allocate
             move.l    4(a1),d0             ; Update
             add.l     d0,Size_of_free_memory
             bra.s     .Exit
.Next:       lea.l     12(a1),a1            ; Increase Ptr
.Entry:      cmpa.l    a2,a1                ; While Ptr < End
             bmi.s     .Loop
             ERROR     "[ Free_memory ] : Memory wasn't allocated !!!"
.Exit:       movem.l   (sp)+,d0/a1/a2
             rts       

;*****************************************************************************
; [ Shrink allocated memory ]
;   IN : d0 - New size of memory block (.w)
;        a0 - Pointer to memory block (.l)
; All registers are restored
;*****************************************************************************
Shrink_memory:         
             movem.l   d0/a1/a2,-(sp)
             addq.l    #1,d0                ; Force word boundary
             andi.b    #$fe,d0
             lea.l     Memory_list,a1       ; Ptr = Start
             movea.l   Memlist_end,a2
             bra.s     .Entry
.Loop:       btst      #7,8(a1)             ; Allocated ?
             bne.s     .Next
             cmpa.l    (a1),a0              ; Found ?
             bne.s     .Next
             move.l    d0,d1                ; Split memory block
             lea.l     (a1),a0
             jsr       Split_memory_block
             move.l    d0,4(a0)             ; Set size of first block
             move.l    12+4(a0),d0          ; Update
             add.l     d0,Size_of_free_memory
             bra.s     .Exit
.Next:       lea.l     12(a1),a1            ; Increase Ptr
.Entry:      cmpa.l    a2,a1                ; While Ptr < End
             bmi.s     .Loop
             ERROR     "[ Shrink_memory ] : Memory wasn't allocated !!!"
.Exit:       movem.l   (sp)+,d0/a1/a2
             rts       

;*****************************************************************************
; [ Re-allocate memory ]
;   IN : d0 - File type (.b)
;        d1 - Subfile number (.w)
;  OUT : a0 - 0 -> No success (.l)
;             ? -> Pointer to file (.l)
; Changed registers : a0
;*****************************************************************************
Reallocate_memory:     
             movem.l   d0-d2/a1,-(sp)
             lsl.w     #8,d0                ; Create criterium
             swap.w    d0
             move.w    d1,d0
             move.l    #$3f00ffff,d1        ; Mask
             lea.l     Memory_list,a0       ; Ptr = Start
             movea.l   Memlist_end,a1
             bra.s     .Entry
.Loop:       move.l    d1,d2                ; Get info
             and.l     8(a0),d2
             cmp.l     d0,d2                ; Found it ?
             beq.s     .Found
             lea.l     12(a0),a0            ; Increase Ptr
.Entry:      cmpa.l    a1,a0                ; While Ptr < End
             bmi.s     .Loop
             suba.l    a0,a0                ; Indicate no success
             bra.s     .Exit
.Found:      bclr      #7,8(a0)             ; Reallocate
             move.l    4(a0),d0             ; Update
             sub.l     d0,Size_of_free_memory
             ori.b     #7*8,9(a0)           ; Top priority
             movea.l   (a0),a0              ; Get pointer to actual file
.Exit:       movem.l   (sp)+,d0-d2/a1
             rts       

;*****************************************************************************
; [ Allocate memory for a file ]
;   IN : d0 - File type (.b)
;        d1 - Size of requested memory block (.l)
;        d2 - Subfile number (.w)
;  OUT : a1 - Pointer to free memory (.l)
; Changed registers : a1
; NOTE : - All memory blocks with a priority LOWER OR EQUAL to the maximum
;          priority are allocated
;*****************************************************************************
File_allocate:         
             movem.l   d0-d3/d7/a0,-(sp)
             addq.l    #1,d1                ; Force word boundary
             andi.b    #$fe,d1
             cmp.l     Size_of_free_memory,d1     ; Enough memory ?
             bls       .Ok
             ERROR     "[ File_allocate ] : Out of memory !!!"
             bra       .Exit

; Priorities 0-7 !!!
.Priority:   .DC.b 0,0,7,1,4,0,3,3,1,0,4,2,1,1,7,2
             .DC.b 3,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0
             .DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             .DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             .EVEN 
.Ok:         swap.w    d2                   ; Create identifier
             move.b    d0,d2
             lsl.w     #8,d2
             ext.w     d0
             move.b    .Priority(pc,d0.w),d0
             ori.b     #7*8,d0              ; Top generation
             move.b    d0,d2
             swap.w    d2
             ext.w     d0

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Priority (.w)
;  d1 - Size of requested memory block (.l)
;  d2 - Identifier (.l)

             jsr       Scan_memory
             cmp.l     4(a0),d1             ; Perfect fit ?
             beq.s     .Continue
             jsr       Split_memory_block
.Continue:   move.l    d1,4(a0)             ; Set block length
             move.l    d2,8(a0)             ; Set file type & priority
             sub.l     d1,Size_of_free_memory     ; Adapt size
             movea.l   (a0),a1              ; Get pointer to actual memory
.Exit:       movem.l   (sp)+,d0-d3/d7/a0
             rts       

;*****************************************************************************
; [ Allocate a memory block ]
;   IN : d0 - Size of requested memory block (.l)
;  OUT : a1 - Pointer to free memory (.l)
; Changed registers : a1
;*****************************************************************************
Allocate_memory:       
             movem.l   d0/d1/d7/a0,-(sp)
             move.l    d0,d1
             addq.l    #1,d1                ; Force word boundary
             andi.b    #$fe,d1
             cmp.l     Size_of_free_memory,d1     ; Enough memory ?
             bls.s     .Ok
             ERROR     "[ Allocate_memory ] : Out of memory !!!"
             bra       .Exit
.Ok:         jsr       Scan_memory
             cmp.l     4(a0),d1             ; Perfect fit ?
             beq.s     .Continue
             jsr       Split_memory_block
.Continue:   move.l    d1,4(a0)             ; Set block length
             clr.w     8(a0)                ; Set file type & priority
             sub.l     d1,Size_of_free_memory     ; Adapt size
             movea.l   (a0),a1              ; Get pointer to actual memory
.Exit:       movem.l   (sp)+,d0/d1/d7/a0
             rts       

;*****************************************************************************
; [ Scan for free memory ]
;   IN : d1 - Size of requested memory block (.l)
;  OUT : a0 - Pointer to memory list entry (.l)
; Changed registers : a0
;*****************************************************************************
Scan_memory: 
             move.l    d0,-(sp)
             moveq.l   #0,d0                ; Initial priority
.Loop:       jsr       Connect_memory       ; Connect
             jsr       Find_free_memory     ; Find
             cmpa.l    #0,a0                ; Success ?
             bne.s     .Exit
             addq.b    #1,d0                ; Increase maximum priority
             bne.s     .Loop
             ERROR     "[ Scan_memory ] : Garbage collection required !!!"
.Exit:       move.l    (sp)+,d0
             rts       

;*****************************************************************************
; [ Split a memory block ]
;   IN : d1 - Size of first block (.l)
;        a0 - Pointer to memory list entry (.l)
; All registers are restored
; NOTE : Size of first block must still be set !!!
;*****************************************************************************
Split_memory_block:    
             move.l    a0,-(sp)
             lea.l     12(a0),a0            ; Increase Ptr
             jsr       Insert_memblock      ; Insert
             move.l    -12(a0),(a0)         ; Initialize 2nd block
             move.l    4-12(a0),4(a0)
             move.w    #$8000,8(a0)
             add.l     d1,(a0)
             sub.l     d1,4(a0)
             movea.l   (sp)+,a0
             rts       

;*****************************************************************************
; [ Find a block of free memory ]
;   IN : d0 - Maximum priority (.w)
;        d1 - Size of requested memory block (.l)
;  OUT : a0 - 0 -> No success (.l)
;             ? -> Pointer to memory list entry (.l)
; Changed registers : a0
; NOTE : - All memory blocks with a priority LOWER OR EQUAL to the maximum
;          priority are found
;*****************************************************************************
Find_free_memory:      
             move.l    a1,-(sp)
             lea.l     Memory_list,a0       ; Ptr = Start
             movea.l   Memlist_end,a1
             bra       .Entry
.Loop:       btst      #7,8(a0)             ; Deallocated ?
             beq.s     .Next
             cmp.b     9(a0),d0             ; Priority lower or equal ?
             bmi.s     .Next
             cmp.l     4(a0),d1             ; Large enough ?
             bls.s     .Exit
.Next:       lea.l     12(a0),a0            ; Increase Ptr
.Entry:      cmpa.l    a1,a0                ; While Ptr < End
             bmi.s     .Loop
             suba.l    a0,a0                ; Indicate no success
.Exit:       movea.l   (sp)+,a1
             rts       

;*****************************************************************************
; [ Connect all consecutive free memory blocks ]
;   IN : d0 - Maximum priority (.w)
; All registers are restored
; NOTE : - All memory blocks with a priority LOWER OR EQUAL to the maximum
;          priority are connected
;*****************************************************************************
Connect_memory:        
             movem.l   d0/d1/a0/a1,-(sp)
             lea.l     Memory_list,a0       ; Ptr1 = Start
             bra       .Entry1
.Loop1:      btst      #7,8(a0)             ; Deallocated ?
             beq       .Next1
             cmp.b     9(a0),d0             ; Priority lower or equal ?
             bmi       .Next1
; ------------- Search for consecutive free memory blocks ------------
             moveq.l   #-1,d1               ; Counter = 0
             lea.l     12(a0),a1            ; Ptr2 = Ptr1 + 1
             bra.s     .Entry2
.Loop2:      addq.w    #1,d1                ; Increase Counter
             btst      #7,8(a1)             ; Deallocated ?
             beq       .End2
             cmp.b     9(a1),d0             ; Priority lower or equal ?
             bmi       .End2
             lea.l     12(a1),a1            ; Increase Ptr2
.Entry2:     cmpa.l    Memlist_end,a1       ; While Ptr2 < End
             bmi.s     .Loop2
.End2:       tst.w     d1                   ; Counter = 0 ?
             beq       .Next1

; ------------- REGISTER CONTENTS ------------------------------------
;  d0 - Maximum priority (.w)
;  d1 - Number of consecutive free memory blocks (.w)
;  a0 - Pointer to first free memory block (.l)
;  a1 - Pointer to first NON-free memory block after a0 (.l)

; ------------- Create one large memory block ------------------------
             move.l    a1,-(sp)             ; Save Ptr2
             move.l    4(a0),d1             ; Get length
             bra.s     .Entry3
.Loop3:      add.l     4(a1),d1             ; Add length
.Entry3:     lea.l     -12(a1),a1           ; Decrease Ptr2
             cmpa.l    a0,a1                ; While Ptr2 > Ptr1
             bhi.s     .Loop3
.End3:       move.l    d1,4(a0)             ; Set new length
             move.w    #$8000,8(a0)         ; Free memory / Priority 0
; ------------- Tidy up the memory block list ------------------------
             lea.l     12(a0),a0            ; Increase Ptr1
             movea.l   (sp)+,a1             ; Restore Ptr2
             jsr       Delete_memblocks     ; Delete
             bra.s     .Entry1
; ------------- Next memory block ------------------------------------
.Next1:      lea.l     12(a0),a0            ; Increase Ptr1
.Entry1:     cmpa.l    Memlist_end,a0       ; While Ptr1 < End
             bmi.s     .Loop1
             movem.l   (sp)+,d0/d1/a0/a1
             rts       

;*****************************************************************************
; [ Insert a memory block ]
;   IN : a0 - Pointer to memory list (.l)
; All registers are restored
;*****************************************************************************
Insert_memblock:       
             movem.l   d0/d1/a1,-(sp)
             movea.l   Memlist_end,a1       ; Ptr = End
             bra.s     .Entry
.Loop:       move.l    -(a1),12(a1)         ; Copy (Ptr-1) -> (Ptr)
             move.l    -(a1),12(a1)
             move.l    -(a1),12(a1)
.Entry:      cmpa.l    a0,a1                ; While Ptr > Insert
             bpl.s     .Loop
             addi.l    #12,Memlist_end      ; Increase End
             movem.l   (sp)+,d0/d1/a1
             rts       

;*****************************************************************************
; [ Delete memory blocks ]
;   IN : a0 - Pointer to first item to be deleted (.l)
;        a1 - Pointer to first item to NOT be deleted (.l)
; All registers are restored
; NOTE : - This routine will delete everything FROM a0 UP TO a1 ([a0...a1>)
;*****************************************************************************
Delete_memblocks:      
             movem.l   d0/d1/a0-a2,-(sp)
             movea.l   Memlist_end,a2
             move.l    a1,d0                ; Decrease End
             sub.l     a0,d0
             bls.s     .Exit
             sub.l     d0,Memlist_end
             bra.s     .Entry
.Again:      move.l    (a1)+,(a0)+          ; Copy (Ptr1) -> (Ptr2)
             move.l    (a1)+,(a0)+          ; Increase Ptr1 & Ptr2
             move.l    (a1)+,(a0)+
.Entry:      cmpa.l    a2,a1                ; While Ptr1 < End
             bmi.s     .Again
.Exit:       movem.l   (sp)+,d0/d1/a0-a2
             rts       

;*****************************************************************************
; The DATA & BSS segments
;*****************************************************************************
             .BSS 
Start_of_free_memory:  .DS.l 1
Size_of_free_memory:   .DS.l 1
Memlist_end: .DS.l 1   ; Points to last entry + 1
Memory_list: .DS.l 3*Max_memblocks

; Memory list structure :
;    0 -  Start of memory block (.l)
;    4 - Length of memory block (.l)
;    8 - File type (.b)
;    9 - Priority  (.b)
;   10 - Subfile number (.w)

; File type structure :
; bit 0-4 :
;    0 - Memory block (NOT A FILE)
;    1 - Party data
;    2 - Icon data
;    3 - Character data
;    4 - Map data
;    5 - Lab data
;    6 - Lab blocks
;    7 - Backgrounds
;    8 - Colour palettes
;    9 - 80x80 Pics
;   10 - Map texts
;   11 - Chest data
;   12 - Monster data
;   13 - Merchant data
;   14 - Dictionary
;   15 - Combat backgrounds
;   16 - Monster graphics
;   17 - Automap file
;   18 - Textfile
; bit 6 :
;    RESERVED FOR AMIGA (Chip ram ?)
; bit 7 :
;    0 - Allocated
;    1 - Free













