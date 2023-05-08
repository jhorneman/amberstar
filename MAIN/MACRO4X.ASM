
; Macros IV
; Written by J.Horneman (In Tune With The Universe)

; ********************************
; *    Edited especially for     *
; *      A M B E R S T A R       *
; * ½ 1991 Thalion Software GmbH *
; ********************************

;************************************************************
; General OS-call macros
;************************************************************

             .MACRO GEMDOS function,tidy    ; Gemdos call
             move.w    #\function,-(sp)
             trap      #1
             .IF \tidy>8
             lea.l     \tidy(sp),sp
             .ELSE 
             addq.l    #\tidy,sp
             .ENDIF 
             .ENDM 

             .MACRO BIOS function,tidy      ; Bios call
             move.w    #\function,-(sp)
             trap      #13
             .IF \tidy>8
             lea.l     \tidy(sp),sp
             .ELSE 
             addq.l    #\tidy,sp
             .ENDIF 
             .ENDM 

             .MACRO XBIOS function,tidy     ; Xbios call
             move.w    #\function,-(sp)
             trap      #14
             .IF \tidy>8
             lea.l     \tidy(sp),sp
             .ELSE 
             addq.l    #\tidy,sp
             .ENDIF 
             .ENDM 

;************************************************************
; GEMDOS macros
;************************************************************

             .MACRO P_TERM_0                ; End process
             GEMDOS    0,2
             .ENDM 

             .MACRO C_CONIN                 ; Read character from standard I/O
             GEMDOS    1,2
             .ENDM 

             .MACRO C_CONOUT char           ; Write character to standard I/O
             move.w    \char,-(sp)
             GEMDOS    2,4
             .ENDM 

             .MACRO C_AUXIN                 ; Read character from auxiliary port
             GEMDOS    3,2
             .ENDM 

             .MACRO C_AUXOUT char           ; Write character to standard aux device
             move.w    \char,-(sp)
             GEMDOS    4,4
             .ENDM 

             .MACRO C_PRNOUT char           ; Write character to standard print device
             move.w    \char,-(sp)
             GEMDOS    5,4
             .ENDM 

             .MACRO C_RAWIO parm            ; Raw I/O to standard input/output
             move.w    \parm,-(sp)
             GEMDOS    6,4
             .ENDM 

             .MACRO C_RAWCIN                ; Raw input from standard input
             GEMDOS    7,2
             .ENDM 

             .MACRO C_NECIN                 ; Read a character from standard input
             GEMDOS    8,2
             .ENDM 

             .MACRO C_CONWS addr            ; Write string to standard output
             move.l    \addr,-(sp)
             GEMDOS    9,6
             .ENDM 

             .MACRO C_CONRS addr            ; Read edited string from standard input
             move.l    \addr,-(sp)
             GEMDOS    $a,6
             .ENDM 

             .MACRO C_CONIS                 ; Check status of standard input
             GEMDOS    $b,2
             .ENDM 

             .MACRO D_SETDRV driv           ; Set default drive
             move.w    \driv,-(sp)
             GEMDOS    $e,4
             .ENDM 

             .MACRO C_CONOS                 ; Check status of standard output
             GEMDOS    $10,2
             .ENDM 

             .MACRO C_PRNOS                 ; Check status of standard print device
             GEMDOS    $11,2
             .ENDM 

             .MACRO C_AUXIS                 ; Check status of standard aux device i/p
             GEMDOS    $12,2
             .ENDM 

             .MACRO C_AUXOS                 ; Check status of standard aux deivce o/p
             GEMDOS    $13,2
             .ENDM 

             .MACRO D_GETDRV                ; Get current drive
             GEMDOS    $19,2
             .ENDM 

             .MACRO F_SETDTA addr           ; Set disk transfer address
             move.l    \addr,-(sp)
             GEMDOS    $1a,2
             .ENDM 

             .MACRO T_GETDATE               ; Get date
             GEMDOS    $2a,2
             .ENDM 

             .MACRO T_SETDATE date          ; Set date
             move.w    \date,-(sp)
             GEMDOS    $2b,4
             .ENDM 

             .MACRO T_GETTIME               ; Get time
             GEMDOS    $2c,2
             .ENDM 

             .MACRO T_SETTIME time          ; Set time
             move.w    \time,-(sp)
             GEMDOS    $2d,4
             .ENDM 

             .MACRO F_GETDTA                ; Get disk transfer address
             GEMDOS    $2f,2
             .ENDM 

             .MACRO S_VERSION               ; Get version no.
             GEMDOS    $30,2
             .ENDM 

             .MACRO P_TERMRES exit,keep     ; Terminate and stay resident
             move.w    \exit,-(sp)
             move.l    \keep,-(sp)
             GEMDOS    $31,8
             .ENDM 

             .MACRO D_FREE driv,info        ; Get drive free space
             move.w    \driv,-(sp)
             move.l    \info,-(sp)
             GEMDOS    $36,8
             .ENDM 

             .MACRO D_CREATE path           ; Create a subdirectory
             move.l    \path,-(sp)
             GEMDOS    $39,6
             .ENDM 

             .MACRO D_DELETE path           ; Delete a subdirectory
             move.l    \path,-(sp)
             GEMDOS    $3a,6
             .ENDM 

             .MACRO D_SETPATH path          ; Set current directory
             move.l    \path,-(sp)
             GEMDOS    $3b,6
             .ENDM 

             .MACRO F_CREATE attr,path      ; Create a file
             move.w    \attr,-(sp)
             move.l    \path,-(sp)
             GEMDOS    $3c,8
             .ENDM 

             .MACRO F_OPEN attr,path        ; Open a file
             move.w    \attr,-(sp)
             move.l    \path,-(sp)
             GEMDOS    $3d,8
             .ENDM 

             .MACRO F_CLOSE hndl            ; Close file
             move.w    \hndl,-(sp)
             GEMDOS    $3e,4
             .ENDM 

             .MACRO F_READ buff,byts,hndl   ; Read file
             move.l    \buff,-(sp)
             move.l    \byts,-(sp)
             move.w    \hndl,-(sp)
             GEMDOS    $3f,12
             .ENDM 

             .MACRO F_WRITE buff,byts,hndl  ; Write file
             move.l    \buff,-(sp)
             move.l    \byts,-(sp)
             move.w    \hndl,-(sp)
             GEMDOS    $40,12
             .ENDM 

             .MACRO F_DELETE path           ; Delete a file
             move.l    \path,-(sp)
             GEMDOS    $41,6
             .ENDM 

             .MACRO F_SEEK fmod,hndl,nbyt   ; Seek file pointer
             move.w    \fmod,-(sp)
             move.w    \hndl,-(sp)
             move.l    \nbyt,-(sp)
             GEMDOS    $42,10
             .ENDM 

             .MACRO F_ATTRIB attr,wrt,path  ; Get/set file attributes
             move.w    \attr,-(sp)
             move.w    \wrt,-(sp)
             move.l    \path,-(sp)
             GEMDOS    $43,10
             .ENDM 

             .MACRO F_DUP shnd              ; Duplicate file handle
             move.w    \shnd,-(sp)
             GEMDOS    $45,4
             .ENDM 

             .MACRO F_FORCE shnd,nhnd       ; Force point file handle
             move.w    \shnd,-(sp)
             move.w    \nhnd,-(sp)
             GEMDOS    $46,6
             .ENDM 

             .MACRO D_GETPATH driv,path     ; Get current directory
             move.w    \driv,-(sp)
             move.l    \path,-(sp)
             GEMDOS    $47,8
             .ENDM 

             .MACRO M_ALLOC nbyt            ; Allocate memory
             move.l    \nbyt,-(sp)
             GEMDOS    $48,6
             .ENDM 

             .MACRO M_FREE frad             ; Free allocated memory
             move.l    \frad,-(sp)
             GEMDOS    $49,6
             .ENDM 

             .MACRO M_SHRINK rmem,mmem      ; Shrink size of allocated memory
             move.l    \rmem,-(sp)
             move.l    \mmem,-(sp)
             clr.w     -(sp)
             GEMDOS    $4a,12
             .ENDM 

             .MACRO P_EXEC penv,pcmd,path,mode    ; Load or execute a process
             move.l    \penv,-(sp)
             move.l    \pcmd,-(sp)
             move.l    \path,-(sp)
             move.w    \mode,-(sp)
             GEMDOS    $4b,16
             .ENDM 

             .MACRO P_TERM stat             ; Terminate process
             move.w    \stat,-(sp)
             GEMDOS    $4c,4
             .ENDM 

             .MACRO F_SFIRST satt,path      ; Search for 1st occurence filespec
             move.w    \satt,-(sp)
             move.l    \path,-(sp)
             GEMDOS    $4e,8
             .ENDM 

             .MACRO F_SNEXT                 ; Search for next occurrence filespec
             GEMDOS    $4f,2
             .ENDM 

             .MACRO F_RENAME pth2,pth1      ; Rename a file
             move.l    \pth2,-(sp)
             move.l    \pth1,-(sp)
             clr.w     -(sp)
             GEMDOS    $56,12
             .ENDM 

             .MACRO F_DATIME info,hndl,buff ; Get/set file date and time stamp
             move.w    \info,-(sp)
             move.w    \hndl,-(sp)
             move.l    \buff,-(sp)
             GEMDOS    $57,10
             .ENDM 

             .MACRO SMODE stck              ; Set/get supervisor/user mode
             move.l    \stck,-(sp)
             GEMDOS    $20,6
             .ENDM 

;************************************************************
; BIOS macros
;************************************************************

             .MACRO GETMPB pmpb             ; Get/fill a memory parameter block
             move.l    \pmpb,-(sp)
             BIOS      0,6
             .ENDM 

             .MACRO BCONSTAT dev            ; Return character_device input status
             move.w    \dev,-(sp)
             BIOS      1,4
             .ENDM 

             .MACRO BCONIN dev              ; Input character from device
             move.w    \dev,-(sp)
             BIOS      2,4
             .ENDM 

             .MACRO BCONOUT char,dev        ; Output character to device
             move.w    \char,-(sp)
             move.w    \dev,-(sp)
             BIOS      3,6
             .ENDM 

             .MACRO RWABS driv,recn,secn,buf,rwfl ; Read/write logical sectors on a device
             move.w    \driv,-(sp)
             move.w    \recn,-(sp)
             move.w    \secn,-(sp)
             move.l    \buff,-(sp)
             move.w    \rwfl,-(sp)
             BIOS      4,14
             .ENDM 

             .MACRO SETEXC vec,vecn         ; Set exception vector
             move.l    \vec,-(sp)
             move.w    \vecn,-(sp)
             BIOS      5,8
             .ENDM 

             .MACRO TICKCAL                 ; Return system elapsed time ms
             BIOS      6,2
             .ENDM 

             .MACRO GETBPB driv             ; Get BIOS parameter block pointer
             move.w    \driv,-(sp)
             BIOS      7,4
             .ENDM 

             .MACRO BCOSTAT dev             ; Return device char output status
             move.w    \dev,-(sp)
             BIOS      8,4
             .ENDM 

             .MACRO MEDIACH driv            ; Get media status
             move.w    \driv,-(sp)
             BIOS      9,4
             .ENDM 

             .MACRO DRVMAP                  ; Get bitmap of drives
             BIOS      $a,2
             .ENDM 

             .MACRO KBSHIFT mode            ; Set keyboard shift bits
             move.w    \mode,-(sp)
             BIOS      $b,4
             .ENDM 

;         BIOS device codes :

;         0  Printer/parallel port
;         1  RS232 port
;         2  Screen (VT-52)
;         3  Midi
;         4  Keyboard
;         5  Screen (raw ASCII)

;************************************************************
; XBIOS macros
;************************************************************

             .MACRO INITMOUS vect,para,type ; Initialize mouse packet handler
             move.l    \vect,-(sp)
             move.l    \para,(sp)
             move.w    \type,-(sp)
             XBIOS     0,12
             .ENDM 

             .MACRO SSBRK numb              ; Reserve block of memory at high RAM
             move.w    \numb,-(sp)
             XBIOS     1,4
             .ENDM 

             .MACRO _PHYSBASE               ; Get screen physical base address
             XBIOS     2,2
             .ENDM 

             .MACRO _LOGBASE                ; Get screen logical base address
             XBIOS     3,2
             .ENDM 

             .MACRO _GETREZ                 ; Get screen resolution
             XBIOS     4,2
             .ENDM 

             .MACRO _SETSCREEN rez,ploc,lloc      ; Set screen parameters
             move.w    \rez,-(sp)
             move.l    \ploc,-(sp)
             move.l    \lloc,-(sp)
             XBIOS     5,12
             .ENDM 

             .MACRO _SETPALETTE palp        ; Set palette
             move.l    \palp,-(sp)
             XBIOS     6,6
             .ENDM 

             .MACRO _SETCOLOR colr,coln     ; Set colour
             move.w    \colr,-(sp)
             move.w    \coln,-(sp)
             XBIOS     7,6
             .ENDM 

             .MACRO _FLOPRD secn,sidn,trkn,stsc,devn,buff   ; Read sectors from a floppy drive
             move.w    \secn,-(sp)
             move.w    \sidn,-(sp)
             move.w    \trkn,-(sp)
             move.w    \stsc,-(sp)
             move.w    \devn,-(sp)
             clr.l     -(sp)
             move.l    \buff,-(sp)
             XBIOS     8,20
             .ENDM 

             .MACRO _FLOPWR secn,sidn,trkn,stsc,devn,buff   ; Write sectors from a floppy drive
             move.w    \secn,-(sp)
             move.w    \sidn,-(sp)
             move.w    \trkn,-(sp)
             move.w    \stsc,-(sp)
             move.w    \devn,-(sp)
             clr.l     -(sp)
             move.l    \buff,-(sp)
             XBIOS     9,20
             .ENDM 

             .MACRO _FLOPFMT fcod,intl,sidn,trkn,sptk,devn,buff       ; Format a floppy disk
             move.w    \fcod,-(sp)
             move.l    #$87654321,-(sp)
             move.w    \intl,-(sp)
             move.w    \sidn,-(sp)
             move.w    \trkn,-(sp)
             move.w    \sptk,-(sp)
             move.w    \devn,-(sp)
             clr.l     -(sp)
             move.l    \buff,-(sp)
             XBIOS     $a,26
             .ENDM 

             .MACRO MIDIWS pntr,cnt         ; Write a string to MIDI port
             move.l    \pntr,-(sp)
             move.w    \cnt,-(sp)
             XBIOS     $c,8
             .ENDM 

             .MACRO _MFPINT vect,intn       ; Set MFP interrupt
             move.l    \vect,-(sp)
             move.w    \intn,-(sp)
             XBIOS     $d,8
             .ENDM 

             .MACRO IOREC devn              ; Get pointer to serial device i/p brpb
             move.w    \devn,-(sp)
             XBIOS     $e,4
             .ENDM 

             .MACRO RSCONF scr,tsr,rsr,usr,flow,baud        ; Configure RS232 port
             move.w    \scr,-(sp)
             move.w    \tsr,-(sp)
             move.w    \rsr,-(sp)
             move.w    \usr,-(sp)
             move.w    \flow,-(sp)
             move.w    \baud,-(sp)
             XBIOS     $f,14
             .ENDM 

             .MACRO KEYTBL capl,shft,unsh   ; Set/get keyboard translation table pointer
             move.l    \capl,-(sp)
             move.l    \shft,-(sp)
             move.l    \unsh,-(sp)
             XBIOS     $10,14
             .ENDM 

             .MACRO _RANDOM                 ; Get 24-bit pseudo random number
             XBIOS     $11,2
             .ENDM 

             .MACRO _PROTOBT exfl,dskt,sern,buf   ; Prototype a boot sector image
             move.w    \exfl,-(sp)
             move.w    \dskt,-(sp)
             move.l    \sern,-(sp)
             move.l    \buf,-(sp)
             XBIOS     $12,14
             .ENDM 

             .MACRO _FLOPVER secn,sidn,trkn,stsc,devn,buff  ; Verify sectors from a floppy drive
             move.w    \secn,-(sp)
             move.w    \sidn,-(sp)
             move.w    \trkn,-(sp)
             move.w    \stsc,-(sp)
             move.w    \devn,-(sp)
             clr.l     -(sp)
             move.l    \buff,-(sp)
             XBIOS     $13,20
             .ENDM 

             .MACRO SCRDMP                  ; Dump screen to printer
             XBIOS     $14,2
             .ENDM 

             .MACRO CURSCONF rate,attr      ; Set/get cursor blink rate & attributes
             move.w    \rate,-(sp)
             move.w    \attr,-(sp)
             XBIOS     $15,6
             .ENDM 

             .MACRO SETTIME date            ; Set IKBD time and date
             move.l    \date,-(sp)
             XBIOS     $16,6
             .ENDM 

             .MACRO GETTIME                 ; Get IKBD 32-bit format date & time
             XBIOS     $17,2
             .ENDM 

             .MACRO BIOSKEY                 ; Restore power up keyboard setting
             XBIOS     $18,2
             .ENDM 

             .MACRO IKBDWS pntr,nch         ; Write a string to IKBD
             move.l    \pntr,-(sp)
             move.w    \nch,-(sp)
             XBIOS     $19,8
             .ENDM 

             .MACRO JDISINT intn            ; Disable a MK68901 interrupt
             move.w    \intn,-(sp)
             XBIOS     $1a,4
             .ENDM 

             .MACRO JENABINT intn           ; Enable a MK68901 interrupt
             move.w    \intn,-(sp)
             XBIOS     $1b,4
             .ENDM 

             .MACRO GIACCESS regn,data      ; Read/write a soundchip register
             move.w    \regn,-(sp)
             move.w    \data,-(sp)
             XBIOS     $1c,6
             .ENDM 

             .MACRO OFFGIBIT bitn           ; Atomically set PORT A bit to zero
             move.w    \bitn,-(sp)
             XBIOS     $1d,4
             .ENDM 

             .MACRO ONGIBIT bitn            ; Atomically set PORT A bit to one
             move.w    \bitn,-(sp)
             XBIOS     $1e,4
             .ENDM 

             .MACRO XBTIMER vec,data,cntl,timr    ; Provide a control timing facility
             move.l    \vec,-(sp)
             move.w    \data,-(sp)
             move.w    \cntl,-(sp)
             move.w    \timr,-(sp)
             XBIOS     $1f,12
             .ENDM 

             .MACRO DOSOUND ptr             ; Produce a sound
             move.l    \ptr,-(sp)
             XBIOS     $20,6
             .ENDM 

             .MACRO SETPRT conf             ; Get/set printer configuration byte
             move.w    \conf,-(sp)
             XBIOS     $21,4
             .ENDM 

             .MACRO KBDVBASE                ; Return pointer to strucutre base
             XBIOS     $22,2
             .ENDM 

             .MACRO KBRATE rept,init        ; Get/set keyboard repeat rate
             move.w    \rept,-(sp)
             move.w    \init,-(sp)
             XBIOS     $23,6
             .ENDM 

             .MACRO _PRTBLK ptr             ; Hard copy routine
             move.l    \prt,-(sp)
             XBIOS     $24,6
             .ENDM 

             .MACRO VSYNC                   ; Wait till next vblank and return
             XBIOS     $25,2
             .ENDM 

             .MACRO SUPERX code             ; Execute code in supervisor mode
             move.l    \code,-(sp)
             XBIOS     $26,6
             .ENDM 

             .MACRO PUNTAES                 ; Switch off AES, when not in ROM
             XBIOS     $27,2
             .ENDM 

             .MACRO BLITMODE flag           ; Get/set blitter status
             move.w    \flag,-(sp)
             XBIOS     $40,4
             .ENDM 

;************************************************************
; Personal macros
;************************************************************

             .MACRO illegal                 ; Missing instruction
             .DC.w %0100101011111100
             .ENDM 

             .END 

