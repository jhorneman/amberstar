
; Various datafiles

             .XDEF Race_dat,Class_dat,Misc_dat,Spell_dat,Place_dat
             .XDEF Code0001Sys,Code0002Sys,Code0003Sys,Code0004Sys
             .XDEF Code0005Sys,Code0006Sys,Code0007Sys,Code0008Sys
             .XDEF Shadow_table

             .PATH 'E:\MAIN\DATA\'
             .PATH 'E:\MAIN\MAP\'

             .DATA 
             .EVEN 
Race_dat:    .IBYTES 'RACE_DAT.DAT'
Class_dat:   .IBYTES 'CLASSDAT.DAT'
Misc_dat:    .IBYTES 'MISC_DAT.DAT'
Spell_dat:   .IBYTES 'SPELLDAT.DAT'
Place_dat:   .IBYTES 'PLACELST.DAT'
Code0001Sys: .IBYTES 'CODE0001.SYS'
Code0002Sys: .IBYTES 'CODE0002.SYS'
Code0003Sys: .IBYTES 'CODE0003.SYS'
Code0004Sys: .IBYTES 'CODE0004.SYS'
Code0005Sys: .IBYTES 'CODE0005.SYS'
Code0006Sys: .IBYTES 'CODE0006.SYS'
Code0007Sys: .IBYTES 'CODE0007.SYS'
Code0008Sys: .IBYTES 'CODE0008.SYS'
; This is the shadow table.
Shadow_table:          .IBYTES 'SHADOW.DAT'

             .END 

