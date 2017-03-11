*-----------------------------------------------------------
* Title      : A disassembler
* Written by : Jesse Llona, Ruby Kassala
* Date       : I don't know the date. All I know now is assembly.
* Description: It disassembles things
*-----------------------------------------------------------
    ORG     $7E00 ; this is where the test program will be loaded into memory
START:
    LEA     WELCOMEMESSAGEP1,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    LEA     WELCOMEMESSAGEP2,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    JSR     SETUPOUTPUTBUFFER ; first instruction of program
    BRA     MAIN
    
   INCLUDE     'demo_test.X68' ; run the testProgram Subroutine
     
    ORG     $1000 ; this is where the rest of the code will be loaded into memory
 

MAIN
    MOVE.L      #0,LINESPRINTED
* Put program code here
    LEA         AskInputS,A1      ; to store user input in A1
    JSR         moveA1ToBuffer    ; to store in buffer to print
    JSR         printBuffer       ; to print from buffer

    
    ; get start location input
    LEA         inputSpace,A1
    MOVE.B      #2,D0
    TRAP        #15
    CMP.B       #8,D1             ; check if input is 8 digits
    BNE         not8digits        ; branch if input is not 8 digits

    MOVEA.L     A1,A3             ; copy address
    MOVEA.L     A1,A2
    ADDA.L      D1,A2             ; add D1 data to address 2
    JSR         ASCII2HEXP1       ; convert A2 to hex
    MOVEA.L     A3,A1             ; convert A1 to hex
    CLR.L       D2
    JSR         ASCII2HEXP2

    CMP.L       #$1000,D2         ; compare D2 to 1000
    BLT         noStartOverlap    ; if less then 1000, no start overlap
    JSR         checkOverlap      ; else, check for overlap

; already checked for start overlap
noStartOverlap:
    MOVE.L      D2,A5             ; start decoding at user input

    LEA         AskInputE,A1
    JSR         moveA1ToBuffer
    JSR         printBuffer

    ; get end location input
    LEA         inputSpace,A1
    MOVE.B      #2,D0
    TRAP        #15
    CMP.B       #8,D1
    BNE         not8digits        ; if ending address is not 8 digits

    MOVEA.L     A1,A3             ; copy addresses
    MOVEA.L     A1,A2
    ADDA.L      D1,A2             ; add D1 to A2
    JSR         ASCII2HEXP1       ; convert A2 to hex
    MOVEA.L     A3,A1
    CLR.L       D2
    JSR         ASCII2HEXP2       ; convert A1 to hex

    

    CMP.L       #$1000,D2         ; if less than 1000, no end overlap
    BLT         noEndOverlap
    JSR         checkOverlap      ; else, check for overlap

noEndOverlap:
    ANDI.L      #$0000FFFF,D2     ; store in D2 to save in address
    MOVE.L      D2,A3
    MOVE.L      A5,A2

    ; if input is invalid, JSR to message then `MAIN`
    CMP.L       A2,A3
    BLT         startNotBeforeEnd
    SUB.L       #2,A2

    LEA         newLine,A1        ; to print a new line through buffer
    JSR         moveA1ToBuffer
    JSR         printBuffer

    LEA         endSpace,A4
    MOVE.L      A3,(A4)
    LEA         startSpace,A4
    MOVE.L      A2,(A4)

    BRA         LOOP

checkOverlap:
    LEA         EXIT,A4
    CMP.L       D2,A4             ; compare to find if overlap exists
    BGT         printOverlap
    RTS         ; will using this as a subroutine cause errors if RTS isn't reached

printOverlap:
    MOVE.L     #$0,(SP)           ; zero stack pointer
    LEA        overlapMsg,A1      ; print overlap using buffer
    JSR        moveA1ToBuffer
    JSR        printBuffer
    BRA        MAIN

startNotBeforeEnd:
    LEA        endb4start,A1      ; print end before start warning message
    JSR        moveA1ToBuffer
    JSR        printBuffer
    BRA        MAIN

not8digits:
    LEA         wronglength,A1    ; print message for incorrect length
    JSR         moveA1ToBuffer
    JSR         printBuffer
    BRA         MAIN

ASCII2HEXP1:    ; decodes ASCII data between A1 and A2 (not including the value at A2)
    CMP.L       A1,A2             ; if A2 is less than A1 return
    BLE         RETURN

    CMP.B       #$30,(A1)         ; to convert to hex
    BLT         InvalidHexNumber  ; if less than 30, not valid hex number
    CMP.B       #$46,(A1)
    BGT         InvalidHexNumber  ; if greater than 46, not valid as hex

    CMP.B       #$39,(A1)
    BGT         LT41check

CONVERT:
    CMP.B       #$39,(A1)
    BLE         SUB0x30           ; subtract 30 for conversion
    SUB.B       #$37,(A1)+
    JSR         ASCII2HEXP1       ; jump to beginning

SUB0x30:
    SUB.B       #$30,(A1)+
    JSR         ASCII2HEXP1

RETURN:
    RTS

LT41check:
    CMP.B       #$41,(A1)         ; check if less than 41
    BLT         InvalidHexNumber
    BRA         CONVERT           ; branch to convert if valid

InvalidHexNumber:
    LEA         InvalidHex,A1     ; load invalid hex message
    JSR         moveA1ToBuffer    ; print message through buffer
    JSR         printBuffer
    BRA         MAIN

ASCII2HEXP2:
    ADD.B      (A1)+,D2           ; add post increment of A1 to D2
    CMP.L       A1,A2
    BLE         RETURN            ; return if A1 less than or equal to A2
    LSL.L       #4,D2             ; shift left four bits
    BRA         ASCII2HEXP2

LOOP:
    CLR.L       D5
    MOVE.B      #0,RETURNATEND
    LEA         startSpace,A2
    ADD.L       #2,(A2)
    MOVE.L      (A2),A2
        
    LEA         endSpace,A3
    MOVE.L      (A3),A3


    ; check loop conditions
    CMP.L       A3,A2
    BGE         FINISHED

    ; print the memory of the next command
    MOVE.L      A2,D3
    MOVE.L      D3,BIN2A_VAL
    MOVE.L      #32,BIN2A_COUNT
    JSR         BIN2A_CONVERT
    LEA         BIN2A_BUFFER,A1
    JSR         MOVEA1TOBUFFER
    LEA         TABmsg,A1
    JSR         MOVEA1TOBUFFER      
    
    
*    MOVE.W      (A2),D3
*    MOVE.L      D3,BIN2A_VAL      ; load value to conversion
*    MOVE.L      #16,BIN2A_COUNT   ; load number of bits to subroutine
*    JSR         BIN2A_CONVERT     ; branch to subroutine
*
*    LEA         BIN2A_BUFFER,A1   ; print from subroutine
*    JSR         moveA1ToBuffer
*

    BRA         DECODE

DECODE:

            ; check RTS and NOP
            MOVE.W  (A2),D2          ; decode in D2
            CMP.W   #$4E75,D2        ; RTS code is constant
            BEQ     printRts
            CMP.W   #$4E71,D2        ; NOP code is constant
            BEQ     printNop

            ; check JSR
            ANDI    #$FFC0,D2        ; mask to compare value
            CMP.W   #$4E80,D2
            BEQ     printJsr

            ; check Bcc
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$6000,D2
            BEQ     printBcc

            ; check CLR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$FF00,D2         ; mask to compare value
            CMP.W   #$4200,D2
            BEQ     printClr

            ; check DIVU
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2         ; mask to compare value
            CMP.W   #$80C0,D2
            BEQ     printDIVU

            ; check MULS
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2         ; mask to compare value
            CMP.W   #$C1C0,D2
            BEQ     printMULS

            ; check LEA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F1C0,D2         ; mask to compare value
            CMP.W   #$41C0,D2
            BEQ     printLEA

            ; check MOVEQ
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F100,D2         ; mask to compare value
            CMP.W   #$7000,D2
            BEQ     printMoveQ


            ; check MOVEM   example: MOVEM.L   D0-D7/A1-A4,$FFFE (or .W)
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$FB80,D2         ; mask to compare value
            CMP.W   #$4880,D2
            BEQ     PRINTMOVEM

            ; check MOVEA   movea if 00xx xxx0 01xx xxxx
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$3000,D2         ; mask to compare value
            CMP.W   #$0000,D2         ; if size code is 0, it's not a movea
            BEQ     AFTERMOVEA

            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$C1C0,D2         ; mask to compare value
            CMP.W   #$0040,D2
            BEQ     printMOVEA

AFTERMOVEA
            ; check ADDI
            MOVE.W  (A2),D2           ; store dereferenced address in D2
            ANDI.W  #$FF00,D2         ; mask to compare value
            CMP.W   #$0600,D2
            BEQ     printADDI

            ; check MOVE move if 00xx xxxx xxxx xxxx        NEEDS TO BE AFTER MOVEA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$3000,D2         ; mask to compare value
            CMP.W   #$0000,D2         ; if size code is 0, it's not a move
            BEQ     AFTERMOVE

            MOVE.W  (A2),D2
            ANDI.W  #$C000,D2         ; mask to compare value
            CMP.W   #$0000,D2
            BEQ     printMove
AFTERMOVE
            ; check ADDQ
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F100,D2         ; mask to compare value
            CMP.W   #$5000,D2
            BEQ     printADDQ

            ; check ADDA
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F0C0,D2         ; mask to compare value
            CMP.W   #$D0C0,D2
            BEQ     printADDA

            ; check SUB
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$9000,D2
            BEQ     printSUB

            ; check ADD
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$D000,D2
            BEQ     printADD

            ; check ROR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E018,D2
            BEQ     printROR

            ; check ROL
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E118,D2
            BEQ     printROL

            ; check ASR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E000,D2
            BEQ     printASR

            ; check ASL
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E100,D2
            BEQ     printASL

            ; check LSR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E008,D2
            BEQ     printLSR

            ; check LSL
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F118,D2         ; mask to compare value
            CMP.W   #$E108,D2
            BEQ     printLSL

            ; check OR
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$8000,D2
            BEQ     printOR

            ; check AND
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$C000,D2
            BEQ     printAND

            ; check CMP
            MOVE.W  (A2),D2           ; decode in D2
            ANDI.W  #$F000,D2         ; mask to compare value
            CMP.W   #$B000,D2
            BEQ     printCMP


printUNKNOWN:
            
printUnknownSize:
            JSR     setupOutputBuffer

            MOVE.L      A2,D3
            MOVE.L      D3,BIN2A_VAL
            MOVE.L      #32,BIN2A_COUNT
            JSR         BIN2A_CONVERT
            LEA         BIN2A_BUFFER,A1
            JSR         MOVEA1TOBUFFER
            LEA         TABmsg,A1
            JSR         MOVEA1TOBUFFER      
    

            LEA     DATA,A1 ; load unknown size message
            JSR     MOVEA1TOBUFFER    ; load buffer
            
            
            MOVE.W      (A2),D3
            MOVE.L      D3,BIN2A_VAL      ; load value to conversion
            MOVE.L      #16,BIN2A_COUNT   ; load number of bits to subroutine
            JSR         BIN2A_CONVERT     ; branch to subroutine

            LEA         BIN2A_BUFFER,A1   ; print from subroutine
            JSR         moveA1ToBuffer

            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER            
 
            JSR     PRINTBUFFER          
            
            BRA     LOOP

printSize:
            CMP.W   #$0000,D2         ; check if size is byte
            BEQ     printB
            CMP.W   #$0001,D2         ; check if size is word
            BEQ     printW
            CMP.W   #$0002,D2         ; check if size is long
            BEQ     printL
            BRA     printUnknownSize  ; else print unknown size

printCMP:
            LEA     CMPmsg,A1         ; load comparison message
            JSR     moveA1ToBuffer    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2         ; mask to find size
            LSR.W   #6,D2
            JSR     printSize
            
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #0,D2
            BNE     printReverse
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP



printAND:
            LEA     ANDmsg,A1         ; load and message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #0,D2
            BNE     printReverse
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP
         

printOR:
            LEA     ORmsg,A1          ; load or message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer
            
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #0,D2
            BNE     printReverse
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP

printReverse:
                        
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP

printLSL:
            LEA     LSLmsg,A1         ; load LSL message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            MOVE.B  #1,D7
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function


printLSR:
            LEA     LSRmsg,A1         ; load LSR message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function

printASL:
            LEA     ASLmsg,A1         ; load ASL message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function

printASR:
            LEA     ASRmsg,A1         ; load ASR message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function

printROL:
            LEA     ROLmsg,A1         ; load ROL message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function

printROR:
            LEA     RORmsg,A1         ; load ROR message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     PRINTROTATIONEA   ; prompt rotation EA function

printADD:
            LEA     ADDmsg,A1         ; load ADD message
            JSR     MOVEA1TOBUFFER    ; load A1 to buffer

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #0,D2
            BNE     printReverse
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP



printADDI:
            LEA     ADDImsg,A1
            JSR     MOVEA1TOBUFFER

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printADDISize     ; branch to print size
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     startSpace,A2
            MOVE.L  (A2),A2
            MOVE.W  (A2),D2
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR     PRINTBUFFER
            
            ADD.L   #2,startSpace
            
            BRA     LOOP
            

printADDISIZE:
            CMP.W   #$0000,D2
            BEQ     printBaddi        ; byte length
            CMP.W   #$0001,D2
            BEQ     printWaddi        ; word length
            CMP.W   #$0002,D2
            BEQ     printLaddi        ; long length
            BRA     LOOP


printSUB:

            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            CMP.W   #$00C0,D2
            BEQ     printUNKNOWN

            LEA     SUBmsg,A1
            JSR     MOVEA1TOBUFFER

            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            
            MOVE.W  (A2),D2
            ANDI.W  #$0100,D2
            CMP.W   #0,D2
            BNE     printReverse
            
            MOVE.W  (A2),D2
            ANDI.W  #$003F,D2
            JSR     GETLHS
            
            LEA     COMMA,A1
            JSR     MOVEA1TOBUFFER
            
            
            MOVE.W  (A2),D2
            ROL.W   #7,D2
            ANDI.W  #7,D2
            MOVE.W  #0000,D3
            ADD.W   D2,D3
            MOVE.W  D3,D2
            
            JSR     GETLHS
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            JSR      PRINTBUFFER
            BRA      LOOP



printADDA:
            LEA     ADDAmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.B  #1,D7
            ; check size
            MOVE.W  (A2),D2           ; decode in D2
            LSR.W   #8,D2
            ANDI.W  #1,D2
            CMP.W   #0,D2
            BEQ     PRINTADDAW
            LEA     Lmsg,A1
            JSR     MOVEA1TOBUFFER


            BRA     DECODEEA          ; prompt general EA decode function
PRINTADDAW:
            LEA     Wmsg,A1
            JSR     MOVEA1TOBUFFER
            BRA     DECODEEA          ; prompt general EA decode function

printADDQ:
            LEA     ADDQmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.L  #3,D7
            ; check size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     DECODEEA          ; prompt general EA decode function

printMove:
            LEA     MOVEmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.B  #2,D7

            ; check size
            MOVE.W  (A2),D2           ; decode in D2
            JSR     printSize2
            BRA     DECODEEA          ; prompt general EA decode function




printMovem:
            LEA     MOVEMmsg,A1
            JSR     MOVEA1TOBUFFER

            ; check size
            MOVE.W  (A2),D2           ; decode in D2
            LSR.W   #6,D2
            ANDI.W  #1,D2
            CMP.W   #0,D2
            BEQ     printMovemW
            LEA     Lmsg,A1
            JSR     MOVEA1TOBUFFER
            BRA     DECODEMOVEMEA     ; prompt MOVEM EA decode function

printMovemW:
            LEA     Wmsg,A1           ; move word length message to buffer
            JSR     MOVEA1TOBUFFER
            BRA     DECODEMOVEMEA     ; branch to decode MOVEM EA function

printMoveq:
            LEA     MOVEQmsg,A1
            JSR     MOVEA1TOBUFFER
            BRA     MOVEQEA           ; branch to decode MOVEQ EA function

printLEA:
            LEA     LEAmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.L  #1,D7
            BRA     DECODEEA          ; branch to decode general EA function

printMuls:
            LEA     MULSmsg,A1
            JSR     MOVEA1TOBUFFER
            MOVE.L  #4,D7
            BRA     DECODEEA          ; branch to decode general EA function

printDivu:
            LEA     DIVUmsg,A1
            JSR     MOVEA1TOBUFFER
            
            MOVE.L  #4,D7
            BRA     DECODEEA          ; branch to decode general EA function

printClr:
            LEA     CLRmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.B  #100,D7
            ; decode size
            MOVE.W  (A2),D2
            ANDI.W  #$00C0,D2
            LSR.W   #6,D2
            JSR     printSize
            BRA     DECODEEA          ; branch to decode general EA function

printBcc:
            LEA     Bccmsg,A1
            JSR     MOVEA1TOBUFFER

            JSR     decodeCondition   ; jump to subroutine

            LEA     DOLLAR_SIGN,A1    ; load dollar sign to buffer to print
            JSR     MOVEA1TOBUFFER

            ADDA.L  #2,A2             ; increment A2 by two
            MOVE.L  (A2),D3           ; load data in A2 to D3
            LSL.L   #8,D3
            LSL.L   #8,D3
            LSR.L   #8,D3
            LSR.L   #8,D3
            MOVE.L  D3,BIN2A_VAL      ; convert D3
            MOVE.L  #16,BIN2A_COUNT   ; number of bits to convert
            JSR     BIN2A_CONVERT

            LEA     BIN2A_BUFFER,A1
            JSR     MOVEA1TOBUFFER

            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            JSR     PRINTBUFFER

            BRA     LOOP              ; start over to decode next
printJsr:
            LEA     JSRmsg,A1
            JSR     MOVEA1TOBUFFER
            
            MOVE.B  #101,D7
            
            BRA     DECODEEA

printNop:
            LEA     NOPmsg,A1         ; load NOP message
            JSR     MOVEA1TOBUFFER

            LEA     NEWLINE,A1        ; load new line
            JSR     MOVEA1TOBUFFER

            JSR     PRINTBUFFER       ; print buffer
            BRA     LOOP              ; start from top to decode next

printRts:
            LEA     RTSmsg,A1
            JSR     MOVEA1TOBUFFER

*            LEA     NEWLINE,A1
*            JSR     MOVEA1TOBUFFER

            JSR     PRINTBUFFER
            BRA     LOOP

printMovea:
            LEA     MOVEAmsg,A1
            JSR     MOVEA1TOBUFFER

            MOVE.L  #1,D7
            ;decode size
            MOVE.W  (A2),D2           ; decode in D2
            JSR     printSize2
            BRA     DECODEEA          ; branch to general decode EA function

; to print size
printSize2:
            ANDI.W  #$3000,D2
            CMP.W   #$1000,D2         ; byte
            BEQ     printB
            CMP.W   #$3000,D2         ; word
            BEQ     printW
            CMP.W   #$2000,D2         ; long
            BEQ     printL
            CMP.W   #$0000,D2         ; unknown size
            BEQ     printUnknownSize

; the following functions load message into A1 which is loaded into buffer
printL:
            MOVE.L #2,D5
            LEA    Lmsg,A1
            JSR    MOVEA1TOBUFFER
            RTS

printW:
            LEA     Wmsg,A1
            JSR     MOVEA1TOBUFFER
            RTS

printB:
            LEA     Bmsg,A1
            JSR     MOVEA1TOBUFFER
            RTS

printLaddi:
            LEA     Lmsg,A1
            JSR     MOVEA1TOBUFFER
            MOVE.L  #32,BIN2A_COUNT
            
            LEA     DOLLAR_SIGN,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     POUND,A1
            JSR     MOVEA1TOBUFFER
            
            CLR.L   D2
            ADD.L   #2,A2
            MOVE.L  (A2),D2
            MOVE.L  D2,BIN2A_VAL
            JSR     BIN2A_CONVERT
            SUB.L   #2,A2
            
            LEA     BIN2A_BUFFER,A1
            JSR     MOVEA1TOBUFFER
            
            RTS

printWaddi:
            LEA     Wmsg,A1
            JSR     MOVEA1TOBUFFER
            MOVE.L  #16,BIN2A_COUNT
            
            LEA     DOLLAR_SIGN,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     POUND,A1
            JSR     MOVEA1TOBUFFER
            
            CLR.L   D2
            ADD.L   #2,A2
            MOVE.W  (A2),D2
            MOVE.L  D2,BIN2A_VAL
            JSR     BIN2A_CONVERT
            SUB.L   #2,A2
            
            LEA     BIN2A_BUFFER,A1
            JSR     MOVEA1TOBUFFER
            
            RTS

printBaddi:
            LEA     Bmsg,A1
            JSR     MOVEA1TOBUFFER
            MOVE.L  #16,BIN2A_COUNT
            
            LEA     DOLLAR_SIGN,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     POUND,A1
            JSR     MOVEA1TOBUFFER
            
            CLR.L   D2
            ADD.L   #2,A2
            MOVE.W  (A2),D2
            MOVE.L  D2,BIN2A_VAL
            JSR     BIN2A_CONVERT
            
            SUB.L   #2,A2
            
            LEA     BIN2A_BUFFER,A1
            JSR     MOVEA1TOBUFFER
            
            RTS

; the following uses bit masks to compare and decode condition
decodeCondition:

            MOVEM.L   A2,-(A7)
            LEA     startSpace,A2
            ADD.L   #2,(A2)
            MOVEM.L   (A7)+,A2

            MOVE.W  (A2),D2
            ANDI.W  #$0F00,D2
            CMP.W   #$0200,D2
            BEQ     printHI
            CMP.W   #$0300,D2
            BEQ     printLS
            CMP.W   #$0400,D2
            BEQ     printCC
            CMP.W   #$0500,D2
            BEQ     printCS
            CMP.W   #$0600,D2
            BEQ     printNE
            CMP.W   #$0700,D2
            BEQ     printEQ
            CMP.W   #$0800,D2
            BEQ     printVC
            CMP.W   #$0900,D2
            BEQ     printVS
            CMP.W   #$0A00,D2
            BEQ     printPL
            CMP.W   #$0B00,D2
            BEQ     printMI
            CMP.W   #$0C00,D2
            BEQ     printGE
            CMP.W   #$0D00,D2
            BEQ     printLT
            CMP.W   #$0E00,D2
            BEQ     printGT
            CMP.W   #$0F00,D2
            BEQ     printLE


; the following are loading more messages to buffer to print
printHI:
            LEA     HImsg,A1
            JSR     MOVEA1TOBUFFER

*            LEA     NEWLINE,A1
*            MOVE.B  #14,D0
*            TRAP    #15
*
            RTS

printLS:
            LEA     LSmsg,A1
            JSR     MOVEA1TOBUFFER
            RTS

printCC:
            LEA     CCmsg,A1
            JSR     MOVEA1TOBUFFER


            RTS

printCS:
            LEA     CSmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printNE:
            LEA     NEmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printEQ:
            LEA     EQmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printVC:
            LEA     VCmsg,A1
            JSR     MOVEA1TOBUFFER


            RTS

printVS:
            LEA     VSmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printPL:
            LEA     PLmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printMI:
            LEA     MImsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printGE:
            LEA     GEmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printLT:
            LEA     LTmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printGT:
            LEA     GTmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS

printLE:
            LEA     LEmsg,A1
            JSR     MOVEA1TOBUFFER



            RTS


FINISHED:
            LEA     FINISHEDMSG1,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     FINISHEDMSG2,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     FINISHEDMSG1,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
            
            LEA     NEWLINE,A1
            JSR     MOVEA1TOBUFFER
ASKGOAGAIN            
            LEA     goAgain,A1
            JSR     MOVEA1TOBUFFER
            
            JSR     PRINTBUFFER
            
            LEA     inputSpace,A1
            MOVE.B  #2,D0
            TRAP    #15
           
            CMP.B   #$79,(A1)
            BEQ     MAIN
            CMP.B   #$59,(A1)
            BEQ     MAIN
            CMP.B   #$6E,(A1)
            BEQ     EXIT
            CMP.B   #$4E,(A1)
            BEQ     EXIT
            
           
            BRA     ASKGOAGAIN            
               INCLUDE     'EAstuff.X68'           ; include effective address file
               INCLUDE     'outputBuffer.X68'      ; include buffer file
      
            SIMHALT
HT              EQU     $09
CR              EQU     $0D
LF              EQU     $0A


CR              EQU     $0D
LF              EQU     $0A

NEWLINE             DC.B        CR,LF,0
PARENTHESIS_1       DC.B        '(', 0
PARENTHESIS_2       DC.B        ')', 0
PLUS_SIGN           DC.B        '+', 0
MINUS_SIGN          DC.B        '-', 0
COMMA               DC.B        ',', 0
DOLLAR_SIGN         DC.B        '$', 0
POUND               DC.B        '#', 0
SLASH               DC.B        '/', 0

DATA_REG            DC.B        'D', 0
ADD_REG             DC.B        'A', 0


EAERRORMSG          DC.B        HT,'EA ERROR',CR,LF,0

; the following are string and character definitions

AskInputS       DC.B    'Input the 8 digit address of first command in hexadecimal:',CR,LF,0
AskInputE       DC.B    'Input the 8 digit address of last command:',CR,LF,0
InvalidHex      DC.B    'Invalid hexidecimal number, try again.',CR,LF,'(TIP: use all caps E00for letters)',CR,LF,0
endb4start      DC.B    'End address is not after start address, try again.',CR,LF,0
wronglength     DC.B    'Input was not 8 digits, try again.',CR,LF,'(TIP: add leading 0s if needed)',CR,LF,0
overlapMsg      DC.B    'This overlaps with the disassembler, try again.',CR,LF,0

Lmsg            DC.B    'L',HT,HT,0
Wmsg            DC.B    'W',HT,HT,0
Bmsg            DC.B    'B',HT,HT,0

TABmsg          DC.B    HT,0



welcomeMessageP1  DC.B    '*-----------------------------------------------------------',CR,LF,'* Title      : A disassembler',CR,LF,'* Written by : Jesse Llona, Ruby Kassala',CR,LF,'* Date       : I dont know the date. All I know now is assembly.',0
welcomeMessageP2  DC.B  CR,LF,'* Description: It disassembles things',CR,LF,'*-----------------------------------------------------------',CR,LF,0  
pressEnter      DC.B    '(press enter to continue)',0
DATA            DC.B    HT,'DATA  ',HT,HT,'$',0
UNKNOWNmsg      DC.B    HT,'INVALED',CR,LF,0
ADDQmsg         DC.B    HT,'ADDQ.',0
ADDImsg         DC.B    HT,'ADDI.',0
MOVEAmsg        DC.B    HT,'MOVEA.',0
ADDAmsg         DC.B    HT,'ADDA.',0
MOVEMmsg        DC.B    HT,'MOVEM.',0
MOVEQmsg        DC.B    HT,'MOVEQ ',HT,HT,0
MULSmsg         DC.B    HT,'MULS ',HT,HT,0
DIVUmsg         DC.B    HT,'DIVU ',HT,HT,0
LEAmsg          DC.B    HT,'LEA  ',HT,HT,0
CMPmsg          DC.B    HT,'CMP.',0
CLRmsg          DC.B    HT,'CLR.',0
ANDmsg          DC.B    HT,'AND.',0
ORmsg           DC.B    HT,'OR.',0
ADDmsg          DC.B    HT,'ADD.',0
SUBmsg          DC.B    HT,'SUB.',0
MOVEmsg         DC.B    HT,'MOVE.',0
LSRmsg          DC.B    HT,'LSR.',0
LSLmsg          DC.B    HT,'LSL.',0
ASRmsg          DC.B    HT,'ASR.',0
ASLmsg          DC.B    HT,'ASL.',0
RORmsg          DC.B    HT,'ROR.',0
ROLmsg          DC.B    HT,'ROL.',0
Bccmsg          DC.B    HT,'B',0
JSRmsg          DC.B    HT,'JSR  ',HT,HT,0
RTSmsg          DC.B    HT,'RTS',CR,LF,0
NOPmsg          DC.B    HT,'NOP',0
HImsg           DC.B    'HI  ',HT,HT,0
LSmsg           DC.B    'LS  ',HT,HT,0
CCmsg           DC.B    'CC  ',HT,HT,0
CSmsg           DC.B    'CS  ',HT,HT,0
NEmsg           DC.B    'NE  ',HT,HT,0
EQmsg           DC.B    'EQ  ',HT,HT,0
VCmsg           DC.B    'VC  ',HT,HT,0
VSmsg           DC.B    'VS  ',HT,HT,0
PLmsg           DC.B    'PL  ',HT,HT,0
MImsg           DC.B    'MI  ',HT,HT,0
GEmsg           DC.B    'GE  ',HT,HT,0
LTmsg           DC.B    'LT  ',HT,HT,0
GTmsg           DC.B    'GT  ',HT,HT,0
LEmsg           DC.B    'LE  ',HT,HT,0
GoAgain         DC.B    'Would you like to go again? (y/n)',CR,LF,0

FINISHEDMSG1     DC.B    '*-----------------------------FINISHED!!!-------------------------------*',CR,LF,0
FINISHEDMSG2     DC.B    'CONGRATULATIONS, YOU HAVE SUCCESFULLY SURVIVED WATCHING OUR DISASSEMBLER',CR,LF,'(AND ALSO HARDWARE, THATS A BIGGER DEAL) ENJOY SOME IMAGINARY COOKIES!!!!',CR,LF,0

outputBuffer    DS.L    256
outputPointer   DS.L    32
RETURNATEND     DS.B        2
endSpace        DS.L    32 
startSpace      DS.L    32

inputSpace      DS.L    64

linesPrinted    DS.L    32
    
EXIT:
    END    START        ; last line of source































*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
