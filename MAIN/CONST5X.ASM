
; Essential Constants V
; Written by J.Horneman (In Tune With The Universe)

; Escape variable
Pigs_can_fly           = 0

;  Memory register
Mem_conf     = $ffff8004

;  Display registers
Vbase_Hi     = $ffff8201
Vbase_Lo     = $ffff8203
Vcount_Hi    = $ffff8205
Vcount_Mid   = $ffff8207
Vcount_Lo    = $ffff8209
Sync_mode    = $ffff820a
Colour_0     = $ffff8240
Colour_1     = $ffff8242
Colour_2     = $ffff8244
Colour_3     = $ffff8246
Colour_4     = $ffff8248
Colour_5     = $ffff824a
Colour_6     = $ffff824c
Colour_7     = $ffff824e
Colour_8     = $ffff8250
Colour_9     = $ffff8252
Colour_10    = $ffff8254
Colour_11    = $ffff8256
Colour_12    = $ffff8258
Colour_13    = $ffff825a
Colour_14    = $ffff825c
Colour_15    = $ffff825e
Shift_mode   = $ffff8260

;  DMA registers
Diskctrl     = $ffff8604
Dma_mode     = $ffff8606
Dmabase_Hi   = $ffff8609
Dmabase_Mid  = $ffff860b
Dmabase_Lo   = $ffff860d

;  FDC registers
Command_R    = $80
Status_R     = $80
Track_R      = $82
Sector_R     = $84
Data_R       = $86

;  Soundchip registers
PSG_Select   = $ffff8800
PSG_Read     = $ffff8800
PSG_Write    = $ffff8802

;  MFP registers
MFP_Base     = $fffffa00
MFP_Gpio     = $fffffa01
MFP_Aer      = $fffffa03
MFP_Ddr      = $fffffa05
MFP_Iera     = $fffffa07
MFP_Ierb     = $fffffa09
MFP_Ipra     = $fffffa0b
MFP_Iprb     = $fffffa0d
MFP_Isra     = $fffffa0f
MFP_Isrb     = $fffffa11
MFP_Imra     = $fffffa13
MFP_Imrb     = $fffffa15
MFP_vecbase  = $fffffa17
MFP_Tacr     = $fffffa19
MFP_Tbcr     = $fffffa1b
MFP_Tcdcr    = $fffffa1d
MFP_Tadr     = $fffffa1f
MFP_Tbdr     = $fffffa21
MFP_Tcdr     = $fffffa23
MFP_Tddr     = $fffffa25
MFP_scr      = $fffffa27
MFP_ucr      = $fffffa29
MFP_rsr      = $fffffa2b
MFP_tsr      = $fffffa2d
MFP_udr      = $fffffa2f

;  ACIA registers
Ikbd_Ctrl    = $fffffc00
Ikbd_Data    = $fffffc02
Midi_Ctrl    = $fffffc04
Midi_Data    = $fffffc06

;  Exception vectors
Bus_Rvec     = $8
Address_Rvec           = $c
Illegal_Rvec           = $10
Div_0_Rvec   = $14
CHK_vec      = $18
TRAPV_vec    = $1c
Priv_Rvec    = $20
Trace_vec    = $24
Line_A_vec   = $28
Line_F_vec   = $2c
Spurious_vec           = $60

;  Automatic interrupt-vectors
HBI_vec      = $68
VBI_vec      = $70
MFP_vec      = $78
NMI_vec      = $7c

;  Trap vectors
Trap_0_vec   = $80
Trap_1_vec   = $84
Trap_2_vec   = $88
Trap_3_vec   = $8c
Trap_4_vec   = $90
Trap_5_vec   = $94
Trap_6_vec   = $98
Trap_7_vec   = $9c
Trap_8_vec   = $a0
Trap_9_vec   = $a4
Trap_10_vec  = $a8
Trap_11_vec  = $ac
Trap_12_vec  = $b0
Trap_13_vec  = $b4
Trap_14_vec  = $b8
Trap_15_vec  = $bc

;  MFP interrupt-vectors
Busy_vec     = $100
RS232_DCD_vec          = $104
RS232_CTS_vec          = $108
Blit_done_vec          = $10c
Timer_D_vec  = $110
Timer_C_vec  = $114
MKB_vec      = $118
FDC_vec      = $11c
Timer_B_vec  = $120
RS232_txerr_vec        = $124
RS232_txbufmt_vec      = $128
RS232_rxerr_vec        = $12c
RS232_rxbuffl_vec      = $130
Timer_A_vec  = $134
RS232_ring_vec         = $138
Mono_vec     = $13c

; System Variables
Proc_lives   = $380
Proc_dregs   = $384
Proc_aregs   = $3a4
Proc_enum    = $3c4
Proc_usp     = $3c8
Proc_stk     = $3cc
Etv_timer    = $400
Etv_critic   = $404
Etv_term     = $408
Etv_xtra     = $40c
Memvalid     = $420
Memcntlr     = $424
Resvalid     = $426
Resvector    = $42a
Phystop      = $42e
_Membot      = $432
_Memtop      = $436
Memval2      = $43a
Flock        = $43e
Seekrate     = $440
_Timr_ms     = $442
_Fverify     = $444
_Bootdev     = $446
Palmode      = $448
Defshiftmd   = $44a
Sshiftmd     = $44c
_V_bas_ad    = $44e
Vblsem       = $452
Nvbls        = $454
_Vblqueue    = $456
Colorptr     = $45a
Screenpt     = $45e
_Vbclock     = $462
_Frclock     = $466
Hdv_init     = $46a
Swv_vec      = $46e
Hdv_bpb      = $472
Hdv_rw       = $476
Hdv_boot     = $47a
Hdv_mediach  = $47e
_Cmdload     = $482
Conterm      = $484
Trp14ret     = $486
Criticret    = $48a
Themd        = $48e
_____md      = $49e
Savptr       = $4a2
_Nflops      = $4a6
Con_state    = $4a8
Save_row     = $4ac
Sav_context  = $4ae
_Bufl        = $4b2
_Hz_200      = $4ba
The_env      = $4be
_Drvbits     = $4c2
_Dskbufp     = $4c6
_Autopath    = $4ca
_Vbl_list    = $4ce
_Dumpflg     = $4ee
_Prtabt      = $4f0
_Sysbase     = $4f2
_Shell_p     = $4f6
End_os       = $4fa
Exec_os      = $4fe
Scr_dump     = $502
Prv_lsto     = $506
Prv_lst      = $50a
Prv_auxo     = $50e
Prv_aux      = $512

; Device numbers
PRT          = 0       ; Printer
AUX          = 1       ; RS-232
CON          = 2       ; Console (VT-52 emulator)
MIDI         = 3       ; MIDI
IKBD         = 4       ; Keyboard
RAWCON       = 5       ; Console (raw)

; Basepage offsets (from Scheibenkleister II)
             .ABS 0
P_lowtpa:    .DS.l 1
P_hitpa:     .DS.l 1
P_tbase:     .DS.l 1
P_tlen:      .DS.l 1
P_dbase:     .DS.l 1
P_dlen:      .DS.l 1
P_bbase:     .DS.l 1
P_blen:      .DS.l 1
P_dta:       .DS.l 1
P_parent:    .DS.l 1
             .DS.l 1
P_env:       .DS.l 1
P_devx:      .DS.b 6
             .DS.b 1   ; Unused
P_defdrv:    .DS.b 1
             .DS.l 2   ; Reserved
P_drvx:      .DS.b 16
             .DS.l 6   ; Reserved
P_d0:        .DS.l 1
P_a3:        .DS.l 1
P_a4:        .DS.l 1
P_a5:        .DS.l 1
P_a6:        .DS.l 1
P_reg:       .DS.l 1
P_cmdcnt:    .DS.b 1
P_cmdlin:    .DS.b 127

             .END 

