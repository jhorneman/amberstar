
; Combat screen
; Written by M.Bittner
; Start : 15-10-1991

; ********************************
; *    This file is a part of    *
; *       A M B E R S T A R      *
; * © 1991 Thalion Software GmbH *
; ********************************

; NOTES :
;   -

             .TEXT 
;*****************************************************************************
; [ Combat screen - Module Init ]
; No registers are restored
;*****************************************************************************
Combat_ModInit:        
             jmp       Init_display

;*****************************************************************************
; [ Combat screen - Module Exit ]
; No registers are restored
;*****************************************************************************
Combat_ModExit:        
             jsr       Exit_display
             jmp       Pop_Module

;*****************************************************************************
; [ Combat screen - Display Init ]
; No registers are restored
;*****************************************************************************
Combat_DisInit:        
             DIAG_ON 
             PRINT     "Insert combat screen here..."
             jsr       Wait_4_key
             DIAG_OFF 
             rts       

;*****************************************************************************
; [ Combat screen - Display Exit ]
; No registers are restored
;*****************************************************************************
Combat_DisExit:        
             rts       

;*****************************************************************************
; [ Combat screen - Display Update ]
; No registers are restored
;*****************************************************************************
Combat_DisUpd:         
             rts       

             .BSS 
mongroup_nr: .DS.w 1
comback_nr:  .DS.w 1

             .END 















