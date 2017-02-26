*-----------------------------------------------------------
* Title      : A disassembler
* Written by : Jesse Llona, Ruby Kassal
* Date       : I don't know the date. All I know now is assembly.
* Description: It dissasbles things
*-----------------------------------------------------------
    ORG     $2000 ; this is where the test program will be loaded into memory
START:                  ; first instruction of program
    BRA     MAIN
    INCLUDE 'testProgram.X68' ; run the testProgram Subroutine
    
    ORG     $1000 ; this is where the rest of the code will be loaded into memory
MAIN
* Put program code here
    LEA         AskInputS,A1
    MOVE.B      #13,D0
    TRAP        #15
    
    
    ; get start location input
    LEA         inputSpace,A1
    MOVE.B      #2,D0
    TRAP        #15
    CMP.B       #8,D1
    BNE         not8digits

    MOVEA.L     A1,A3
    MOVEA.L     A1,A2
    ADDA.L      D1,A2
    JSR         ASCII2HEXP1
    MOVEA.L     A3,A1
    JSR         ASCII2HEXP2

    CMP.L       #$1000,D2
    BLT         noStartOverlap
    JSR         checkOverlap

noStartOverlap:    
    MOVE.L      D2,A5     ; start decoding at user input
    
    LEA         AskInputE,A1
    MOVE.B      #13,D0
    TRAP        #15
    
    ; get end location input
    LEA         inputSpace,A1
    MOVE.B      #2,D0
    TRAP        #15
    CMP.B       #8,D1
    BNE         not8digits

    MOVEA.L     A1,A3
    MOVEA.L     A1,A2
    ADDA.L      D1,A2
    JSR         ASCII2HEXP1
    MOVEA.L     A3,A1
    JSR         ASCII2HEXP2
    
    CMP.L       #$1000,D2
    BLT         noEndOverlap
    JSR         checkOverlap
    
noEndOverlap:    
    ANDI.L      #$0000FFFF,D2
    MOVE.L      D2,A3
    MOVE.L      A5,A2
    ; if input is invalad, JSR to message then `MAIN`          
    CMP.L       A2,A3
    BLT         startNotBeforeEnd
    SUB.L       #2,A2
    
    LEA         newLine,A1
    MOVE.B      #13,D0
    TRAP        #15
    
    BRA         LOOP

checkOverlap:
    LEA      EXIT,A4
    CMP.L    D2,A4
    BGT      printOverlap
    RTS      ; will using this as a subroutine cause errors if RTS isn't reached?

printOverlap
    MOVE.L  #$0,(SP)
    LEA     overlapMsg,A1
    MOVE.B  #14,D0
    TRAP    #15
    BRA     MAIN

startNotBeforeEnd:
    LEA        endb4start,A1
    MOVE.B     #14,D0
    TRAP       #15 
    BRA        MAIN
    
not8digits:
    LEA         wronglength,A1
    MOVE.B      #13,D0
    TRAP        #15
    BRA         MAIN

ASCII2HEXP1:      ; decodes ASCII data between A1 and A2 (not including the value at A2)
    CMP.L       A1,A2
    BLE         RETURN
    
    CMP.B       #$30,(A1)
    BLT         InvalidHexNumber
    CMP.B       #$46,(A1)
    BGT         InvalidHexNumber
    
    CMP.B       #$39,(A1)
    BGT         LT41check

CONVERT:    
    CMP.B       #$39,(A1)
    BLE         SUB0x30
    SUB.B       #$37,(A1)+
    JSR         ASCII2HEXP1

SUB0x30:
    SUB.B       #$30,(A1)+
    JSR         ASCII2HEXP1
    
RETURN:
    RTS
    
LT41check:
    CMP.B       #$41,(A1)
    BLT         InvalidHexNumber
    BRA         CONVERT

InvalidHexNumber:
    LEA         InvalidHex,A1
    MOVE.B      #13,D0
    TRAP        #15
    BRA         MAIN    
    
ASCII2HEXP2:
    ADD.B      (A1)+,D2 
    CMP.L       A1,A2
    BLE         RETURN
    LSL.L       #4,D2
    BRA         ASCII2HEXP2
    
LOOP:
    ADDA.L      #$2,A2 ; this is assuming we load user input's start location -2 into A2 the first time
    
    ; check loop conditions
    CMP         A3,A2    ; change #$207C to end address GET RID OF ()+ ONCE WE HAVE EA
    BGE         EXIT  
    
    ; print the binary of the next command
    MOVE.W      (A2),D1
    MOVE.B      #15,D0
    MOVE.B      #16,D2
    TRAP        #15          ; TODO print msb even if it's zero


    BRA         DECODE
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
            BEQ     printDIVU
            
afterDIVU:
            ; check MULS
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2
            CMP.W   #$C1C0,D2
            BEQ     printMULS

afterMULS:
            ; check LEA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2
            CMP.W   #$41C0,D2
            BEQ     printLEA

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

afterMOVEM:
            ; check MOVEA   movea if 00xx xxx0 01xx xxxx
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$3000,D2
            CMP.W   #$0000,D2         ; if size code is 0, it's not a movea
            BEQ     afterMOVE
            
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$C1C0,D2
            CMP.W   #$0040,D2
            BEQ     printMOVEA

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
            
            
printUNKNOWN:
            LEA     UNKNOWNmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP            
            
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
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP

printLEA:
            LEA     LEAmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP

printMuls:
            LEA     MULSmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            
            BRA     LOOP

printDivu:
            LEA     DIVUmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            
            BRA     LOOP

printClr:
            LEA     CLRmsg,A1
            MOVE.B  #14,D0
            TRAP    #15
            
            ; decode size
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$00C0,D2
            CMP.W   #$0000,D2
            BEQ     printB
            CMP.W   #$0040,D2
            BEQ     printW
            CMP.W   #$0080,D2
            BEQ     printL

printBcc:
            LEA     Bccmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP
         
printJsr:
            LEA     JSRmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP
         
printNop:
            LEA     NOPmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP
   
printRts:
            LEA     RTSmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP

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
            


printL:
            LEA     Lmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP
            
printW:
            LEA     Wmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP
            
printB:
            LEA     Bmsg,A1
            MOVE.B  #13,D0
            TRAP    #15
            BRA     LOOP


HT          EQU     $09
CR          EQU     $0D
LF          EQU     $0A

AskInputS       DC.B    'Input the 8 digit address of first command in hexadecimal:',CR,LF,0
AskInputE       DC.B    'Input the 8 digit address of last command:',CR,LF,0
InvalidHex      DC.B    'Invalid hexidecimal number, try again.',CR,LF,'(TIP: use all caps for letters)',CR,LF,0
endb4start      DC.B    'End address is not after start address, try again.',CR,LF,0
wronglength     DC.B    'Input was not 8 digits, try again.',CR,LF,'(TIP: add leading 0s if needed)',CR,LF,0
overlapMsg      DC.B    'This overlaps with the disassembler, try again.',CR,LF,0
newLine         DC.B    CR,LF,0

Lmsg        DC.B    'L',CR,LF,0
Wmsg        DC.B    'W',CR,LF,0
Bmsg        DC.B    'B',CR,LF,0

UNKNOWNmsg  DC.B    HT,'INVALED',CR,LF,0
ADDQmsg     DC.B    HT,'ADDQ.',0
ADDImsg     DC.B    HT,'ADDI.',0
MOVEAmsg    DC.B    HT,'MOVEA.',0
ADDAmsg     DC.B    HT,'ADDA.',0
MOVEMmsg    DC.B    HT,'MOVEM.',0
MOVEQmsg    DC.B    HT,'MOVEQ',CR,LF,0
MULSmsg     DC.B    HT,'MULS',CR,LF,0
DIVUmsg     DC.B    HT,'DIVU',CR,LF,0
LEAmsg      DC.B    HT,'LEA',CR,LF,0
CMPmsg      DC.B    HT,'CMP.',0
CLRmsg      DC.B    HT,'CLR.',0
ANDmsg      DC.B    HT,'AND.',0
ORmsg       DC.B    HT,'OR.',0
ADDmsg      DC.B    HT,'ADD.',0
SUBmsg      DC.B    HT,'SUB.',0
MOVEmsg     DC.B    HT,'MOVE.',0
LSRmsg      DC.B    HT,'LSR.',0
LSLmsg      DC.B    HT,'LSL.',0
ASRmsg      DC.B    HT,'ASR.',0
ASLmsg      DC.B    HT,'ASL.',0
RORmsg      DC.B    HT,'ROR.',0
ROLmsg      DC.B    HT,'ROL.',0
Bccmsg      DC.B    HT,'Bcc',CR,LF,0
JSRmsg      DC.B    HT,'JSR',CR,LF,0
RTSmsg      DC.B    HT,'RTS',CR,LF,0
NOPmsg      DC.B    HT,'NOP',CR,LF,0

inputSpace  DC.B    '',0            ; don't put any variables after this. or anything at all. IT'S IMPORTANT THAT THIS IS THE END, OK!?!?!?

EXIT:
    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
