*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

; if code has a subcode (like ADD has ADDA) check for subcode (ADDA) first


            MOVE.W  CMPmask,D1      ; move the mask into memory
            MOVE.W  #$BE06,D2
            AND.W   D2,D1       ; and the input data with the mask
            CMP.W   CMPmask,D1      ; if the result is equal to the mask, then that's the command
            BEQ     printCmp
continue:
            BRA     EXIT
printCmp:
            LEA     CMPmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; decode size
            MOVE.W  D2,D1
            ROR.W   #2,D1
            MOVE.B  sizeLmask,D2
            AND.W   D2,D1
            CMP.B   sizeLmask,D1
            BEQ     printL
            
            MOVE.B  sizeWmask,D2
            AND.W   D2,D1
            CMP.B   sizeWmask,D1
            BEQ     printW
            
            MOVE.B  sizeBmask,D2
            AND.W   D2,D1
            CMP.B   sizeBmask,D1
            BEQ     printB
            
            BRA     continue    ;redundant in this file
printL:
            LEA     Lmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue
            
printW:
            LEA     Wmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue
            
printB:
            LEA     Bmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue


    SIMHALT             ; halt simulator

* Put variables and constants here
;unsure
ADDQmask    DC.W    $5000
MOVEAmask   DC.W    $0040
ADDAmask    DC.W    $D0C0
MOVEMmask   DC.W    $4880
MOVEQmask   DC.W    $7000
MULSmask    DC.W    $C1C0    
DIVUmask    DC.W    $80C0
LEAmask     DC.W    $41C0

;sure
CMPmask     DC.W    $B000
CLRmask     DC.W    $4200
ANDmask     DC.W    $C000
ORmask      DC.W    $8000
ADDmask     DC.W    $D000
ADDImask    DC.W    $0600
SUBmask     DC.W    $9000
MOVEmask    DC.W    $0000
LSRmask     DC.W    $E2C0
LSLmask     DC.W    $E3C0
ASRmask     DC.W    $E0C0
ASLmask     DC.w    $E1C0
RORmask     DC.W    $E6C0
ROLmask     DC.W    $E7C0
Bccmask     DC.W    $6000
JSRmask     DC.W    $4E80
RTSmask     DC.W    $4E75
NOPmask     DC.W    $4E71

sizeLmask   DC.B    $80            
sizeWmask   DC.B    $40
sizeBmask   DC.B    $00

smallSizeW  DC.B    $00
smallSizeL  DC.B    $80

moveSizeL   DC.B    $80
moveSizeW   DC.B    $C0
moveSizeB   DC.B    $40

  
;strings
Lmsg        DC.B    'L',0
Wmsg        DC.B    'W',0
Bmsg        DC.B    'B',0
CMPmsg      DC.B    'CMP.',0

EXIT:
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
