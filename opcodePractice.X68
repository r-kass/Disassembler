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
            
            INCLUDE 'testProgram.X68'
            CLR.L   D0
            CLR.L   D1
            CLR.L   D2
            CLR.L   D3
            CLR.L   D4
            CLR.L   D5
            CLR.L   D6
            CLR.L   D7
            MOVEA.L #0,A0
            MOVEA.L #0,A1
            MOVEA.L #0,A2
            MOVEA.L #0,A3
            MOVEA.L #0,A4
            MOVEA.L #0,A5
            MOVEA.L #0,A6

            ;CMP.L     D2,D3
            MOVE.W    #$1000,A2      ; loads the instruction opcode into (A2) ($1000 because the ORG is $1000)
DECODE:          
            ; check RTS and NOP
            MOVE.W  (A2),D2           ; decode in D2
            CMP.W   #$4E75,D2        ; RTS code is constant, as is NOP code
            BEQ     printRts
            CMP.W   #$4E71,D2
            BEQ     printNop
            
            ; check JSR
            ANDI    #$FFC0,D2
            CMP.W   #$4E80,D2
            BEQ     printJsr
            
            ; check Bcc
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2
            CMP.W   #$6000,D2
            BEQ     printBcc
            
            ; check CLR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$FF00,D2
            CMP.W   #$4200,D2
            BEQ     printClr
            
            ; check DIVU
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2
            CMP.W   #$80C0,D2
            BEQ     verifyDIVU
afterDIVU:
            ; check MULS
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2
            CMP.W   #$C1C0,D2
            BEQ     verifyMULS
afterMULS:
            ; check LEA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2
            CMP.W   #$41C0,D2
            BEQ     verifyLEA
afterLEA:
            ; check MOVEQ
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F100,D2
            CMP.W   #$7000,D2
            BEQ     printMoveQ
            
            
            ; check MOVEM   example: MOVEM.L   D0-D7/A1-A4,$FFFE (or .W)
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$FB80,D2
            CMP.W   #$4880,D2
            BEQ     verifyMOVEM
afterMOVEM:
            ; check MOVEA   movea if 00xx xxx0 01xx xxxx
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$3000,D2
            CMP.W   #$0000,D2         ; if size code is 0, it's not a movea
            BEQ     afterMOVE
            
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$C1C0,D2
            CMP.W   #$0040,D2
            BEQ     verifyMOVEA     
afterMOVEA:
            ; check MOVE move if 00xx xxxx xxxx xxxx        NEEDS TO BE AFTER MOVEA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$3000,D2
            CMP.W   #$0000,D2         ; if size code is 0, it's not a move
            BEQ     afterMOVE
            
            MOVE.W  (A2),D2
            ANDI.W  #$C000,D2
            CMP.W   #$0000,D2
            BEQ     printMove
afterMOVE:
            ; check ADDQ
            MOVE.W  (A2),D2
            ANDI.W  #$F100,D2
            CMP.W   #$5000,D2
            BEQ     printADDQ
            
            ; check ADDA
            MOVE.W  (A2),D2
            ANDI.W  #$F0C0,D2
            CMP.W   #$D0C0,D2
            BEQ     printADDA
            
            ; check SUB
            MOVE.W  (A2),D2
            ANDI.W  #$F000,D2
            CMP.W   #$9000,D2
            BEQ     printSUB
            
            ; check ADDI
            MOVE.W  (A2),D2
            ANDI.W  #$FF00,D2
            CMP.W   #$0600,D2
            BEQ     printADDI
            
            ; check ADD
            MOVE.W  (A2),D2
            ANDI.W  #$F000,D2
            CMP.W   #$D000,D2
            BEQ     printADD
            
            ; check ROR
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E018,D2
            BEQ     printROR
            
            ; check ROL
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E118,D2
            BEQ     printROL
            
            ; check ASR
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E000,D2
            BEQ     printASR
            
            ; check ASL
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E100,D2
            BEQ     printASL
            
            ; check LSR
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E008,D2
            BEQ     printLSR
            
            ; check LSL
            MOVE.W  (A2),D2
            ANDI.W  #$F118,D2
            CMP.W   #$E108,D2
            BEQ     printLSL
            
            ; check OR
            MOVE.W  (A2),D2
            ANDI.W  #$F000,D2
            CMP.W   #$8000,D2
            BEQ     printOR
            
            ; check AND
            MOVE.W  (A2),D2
            ANDI.W  #$F000,D2
            CMP.W   #$C000,D2
            BEQ     printAND
            
            ; check CMP
            MOVE.W  (A2),D2
            ANDI.W  #$F000,D2
            CMP.W   #$B000,D2
            BEQ     printCMP
            
continue:
            ADDA.W  #2,A2
            BRA     DECODE
            BRA     EXIT

printCMP:
            LEA     CMPmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

        
printAND:
            LEA     ANDmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

    
printOR:
            LEA     ORmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL
            
printLSL:
            LEA     LSLmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL


printLSR:
            LEA     LSRmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

printASL:
            LEA     ASLmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

printASR:
            LEA     ASRmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

printROL:
            LEA     ROLmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL
            
printROR:
            LEA     RORmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL
            
printADD:
            LEA     ADDmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL
            
            
printADDI:
            LEA     ADDImsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL


printSUB:
            LEA     SUBmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            BRA     printL

printADDA:
            LEA     ADDAmsg,A1
            MOVE.B  #14,D0
            TRAP    #15

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #$0100,D2
            BEQ     printL
            BRA     printW

printADDQ:
            LEA     ADDQmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            CMp.W   #$0080,D2
            BEQ     printL
            
printMove:
            LEA     MOVEmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2           ; decode in D2
            LSL.W   #2,D2
            ANDI.W  #$C000,D2
            ROL.W   #2,D2
            CMP.B   #1,D2
            BEQ     printB
            CMP.B   #3,D2
            BEQ     printW
            CMP.B   #2,D2
            BEQ     printL



printMovem:
            LEA     MOVEMmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; check size
            MOVE.W  (A2),D2           ; decode in D2
            LSR.W   #7,D2
            Bcc     printW
            BRA     printL

printMoveq:
            LEA     MOVEQmsg,A1
            MOVE.B  #15,D0
            TRAP    #15
            BRA     continue

printLEA:
            LEA     LEAmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     continue

printMuls:
            LEA     MULSmsg,A1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA     continue

printDivu:
            LEA     DIVUmsg,A1
            MOVE.B  #15,D0
            TRAP    #15
            
            BRA     continue

printClr:
            LEA     CLRmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; decode size
            MOVE.W  (A2),D2           ; decode in D2
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
            MOVE.W  (A2),D2           ; decode in D2
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
verifyMOVEA:
            MOVE.W  (A2),D2           ; decode in D2
            LSR.W   #2,D2
            ANDI.B  #$10,D2
            CMP.B   #$10,D2
            BEQ     printMovea
            BRA     afterMOVEA 

            
verifyMOVEM:
            MOVE.W  (A2),D2           ; decode in D2
            LSR.W   #3,D2
            ANDI.B  #$10,D2
            CMP.B   #$10,D2
            BEQ     printMovem
            BRA     afterMOVEM 
         
verifyLEA:
            MOVE.W  (A2),D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$01C0,D2
            CMP.W   #$01C0,D2
            BEQ     printLEA
            BRA     afterLEA
         
verifyMULS:
            MOVE.W  (A2),D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$01C0,D2
            CMP.W   #$01C0,D2

            BEQ     printMuls
            BRA     afterMULS


         
verifyDIVU:
            MOVE.W  (A2),D2           ; decode in D2
            LSL.W   #7,D2
            LSR.W   #7,D2
            ANDI.W  #$00C0,D2
            CMP.W   #$00C0,D2
            BEQ     printDivu
            BRA     afterDIVU



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
ADDImsg     DC.B    'ADDI.',0
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
