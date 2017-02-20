*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

; if code has a subcode (like ADD has ADDA) check for subcode (ADDA) first
            

            ; opcode to decode here
            MOVE.B    $10,D5 
            
DECODE:
            MOVE.W    $1000,D7      ; loads the instruction opcode into D7 ($1000 because the ORG is $1000)
            
            ; check RTS and NOP
            MOVE.W  D7,D2           ; decode in D2
            CMP.W   $4E75,D2        ; RTS code is constant, as is NOP code
            BEQ     printRts
            CMP.W   4E71,D2
            BEQ     printNop
            
            ; check JSR
            LSR.L   #6,D2           ; TODO: use masking instead of shifting
            LSL.L   #6,D2
            CMP.W   JSRcode,D2
            BEQ     printJsr
            
            ; check Bcc
            MOVE.W  D7,D2           ; decode in D2
            LSR.L   #6,D2
            LSR.L   #6,D2
            LSL.L   #6,D2
            LSL.L   #6,D2
            CMP.W   Bcccode,D2
            BEQ     printBcc
            
            ; check CLR
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSL.W   #8,D2
            CMP.W   CLRcode,D2
            BEQ     printClr
            
            ; check DIVU
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSR.W   #4,D2
            LSL.W   #8,D2
            LSL.W   #4,D2
            CMP.W   #$8000,D2
            BEQ     verifyDIVU
afterDIVU:
            ; check MULS
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSR.W   #4,D2
            LSL.W   #8,D2
            LSL.W   #4,D2
            CMP.W   #$C000,D2
            BEQ     verifyMULS
afterMULS:
            ; check LEA
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSR.W   #4,D2
            LSL.W   #8,D2
            LSL.W   #4,D2
            CMP.W   #$4000,D2
            BEQ     verifyLEA
afterLEA:
            ; check MOVEQ
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSR.W   #4,D2
            LSL.W   #8,D2
            LSL.W   #4,D2
            CMP.W   #$7000,D2
            BEQ     printMoveQ
            
            
            ; check MOVEM   example: MOVEM.L   D0-D7/A1-A4,$FFFE (or .W)
            MOVE.W  D7,D2           ; decode in D2
            ANDI.W  #$4800,D2
            CMP.W   #$4800,D2
            BEQ     verifyMOVEM
afterMOVEM:
            ; check MOVEA   movea if 00xx xxx0 01xx xxxx
            MOVE.W  D7,D2           ; decode in D2
            ANDI.W  #$C000,D2
            CMP.W   #$0000,D2
            BEQ     verifyMOVEA     
afterMOVEA:
            ; check MOVE move if 00xx xxxx xxxx xxxx        NEEDS TO BE AFTER MOVEA
            MOVE.W  D7,D2           ; decode in D2
            ANDI.W  #$C000,D2
            CMP.W   #$0000,D2
            BEQ     printMove




continue:
            BRA     EXIT

verifyMOVEA:
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #2,D2
            ANDI.B  #$10,D2
            CMP.B   #$10,D2
            BEQ     printMovea
            BRA     afterMOVEA 

            
verifyMOVEM:
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #3,D2
            ANDI.B  #$10,D2
            CMP.B   #$10,D2
            BEQ     printMovem
            BRA     afterMOVEM 
         
verifyLEA:
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$01C0,D2
            CMP.W   #$01C0,D2
            BEQ     printLEA
            BRA     afterLEA
         
verifyMULS:
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$01C0,D2
            CMP.W   #$01C0,D2

            BEQ     printMuls
            BRA     afterMULS


         
verifyDIVU:
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$00C0,D2
            CMP.W   #$00C0,D2
            BEQ     printDivu
            BRA     afterDIVU

printMove:
            LEA     MOVEmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #2,D2
            ANDI.W  #$C000,D2
            ROL.W   #2,D2
            CMP.B   #1,D2
            BEQ     printB
            CMP.B   #3,D2
            BEQ     printW
            CMP.B   #2,D2
            BEQ     printL

printAdda:
            LEA     ADDAmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #8,D2
            LSR.W   #1,D2
            Bcc     printW
            BRA     printL
            

printMovem:
            LEA     MOVEMmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  D7,D2           ; decode in D2
            LSR.W   #7,D2
            Bcc     printW
            BRA     printL

printMoveq:
            LEA     MOVEQmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     continue

printLEA:
            LEA     LEAmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     continue

printMuls:
            LEA     MULSmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            BRA     continue

printDivu:
            LEA     DIVUmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            BRA     continue

printClr:
            LEA     CLRmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; decode size
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #8,D2
            LSR.W   #8,D2
            LSR.W   #6,D2
            CMP.B   sizeLmask,D2
            BEQ     printL  
            CMP.B   sizeWmask,D2
            BEQ     printW
            CMP.B   sizeBmask,D2
            BEQ     printB
 

            BRA     continue
printBcc:
            LEA     Bccmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     continue       
         
printJsr:
            LEA     JSRmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue         
         
printNop:
            LEA     NOPmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue
   
printRts:
            LEA     RTSmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     continue

printMovea:
            LEA     MOVEAmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ;decode size
            MOVE.W  D7,D2           ; decode in D2
            LSL.W   #2,D2
            ANDI.W  #$C000,D2
            ROL.W   #2,D2
            CMP.B   #3,D2
            BEQ     printW
            CMP.B   #2,D2
            BEQ     printL
            
            BRA     continue

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
LEAcode     DC.W    $41C0

;sure
CMPmask     DC.W    $B000
CLRcode     DC.W    $4200
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
RORcode     DC.W    $E400
ROLcode     DC.W    $E500
Bcccode     DC.W    $6000
JSRcode     DC.W    $4E80
RTScode     DC.W    $4E75
NOPcode     DC.W    $4E71

sizeLmask   DC.B    $2            
sizeWmask   DC.B    $1
sizeBmask   DC.B    $0

smallSizeW  DC.B    $0
smallSizeL  DC.B    $1

moveSizeL   DC.B    $2
moveSizeW   DC.B    $3
moveSizeB   DC.B    $1

  
;strings
Lmsg        DC.B    'L',0
Wmsg        DC.B    'W',0
Bmsg        DC.B    'B',0

ADDQmsg     DC.B    'ADDQ.',0
MOVEAmsg    DC.B    'MOVEA.',0
ADDAmsg     DC.B    'ADDA.',0
MOVEMmsg    DC.B    'MOVEM.',0
MOVEQmsg    DC.B    'MOVEQ',0
MULSmsg     DC.B    'MULS',0
DIVUmsg     DC.B    'DIVU',0
LEAmsg      DC.B    'LEA',0
CMPmsg      DC.B    'CMP.',0
CLRmsg      DC.B    'CLR.',0
ANDmsg      DC.B    'AND.',0
ORmsg       DC.B    'OR.',0
ADDmsg      DC.B    'ADD.',0
SUBmsg      DC.B    'SUB.',0
MOVEmsg     DC.B    'MOVE.',0
LSRmsg      DC.B    'LSR.',0
LSLmsg      DC.B    'LSL.',0
ASRmsg      DC.B    'ASR.',0
ASLmsg      DC.B    'ASL.',0
RORmsg      DC.B    'ROR.',0
ROLmsg      DC.B    'ROL.',0
Bccmsg      DC.B    'Bcc',0
JSRmsg      DC.B    'JSR',0
RTSmsg      DC.B    'RTS',0
NOPmsg      DC.B    'NOP',0

EXIT:
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
