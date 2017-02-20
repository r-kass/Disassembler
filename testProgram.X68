*-----------------------------------------------------------
* Title      : Test program
* Written by : Jesse Llona
* Date       : 2/5/2017
* Description: To be loaded into memory in order to be decoded
*-----------------------------------------------------------


    * CMP
    CMP.B   D1,D2
    CMP.W   D1,D2
    CMP.L   D1,D2
    
    * CLR
    CLR.B   D1
    CLR.W   D1
    CLR.L   D1

    * AND
    AND.B   D1,D2
    AND.W   D1,D2
    AND.L   D1,D2
    
    * OR
    OR.B    D1,D2
    OR.W    D1,D2
    OR.L    D1,D2
    
    * ADD commands
    ADD.B  #$12,D0
    ADD.B  D1,D0
    
    ADD.W  #$1234,D0
    ADD.W  D1,D0
    
    ADD.L  #$12345678,D0
    ADD.L  D1,D0

    * ADDQ
    ADDQ.B  #5,D1
    ADDQ.W  #5,D1
    ADDQ.L  #5,D1
    
    * ADDI
    ADD.B   #4,D1
    ADD.W   #4,D1
    ADD.L   #4,D1
    
    * SUB
    SUB.B   D1,D2
    SUB.W   D1,D2
    SUB.L   D1,D2
    
    * MOVE commands
    MOVE.B  #$12,D0
    MOVE.B  D1,D0
    
    MOVE.W  #$1234,D0
    MOVE.W  D1,D0
    
    MOVE.L  #$12345678,D0
    MOVE.L  D1,D0
    
    MOVE.W  $2002(PC),D0
    
    * MOVEA commands    
    MOVEA.W #$1234,A0
    MOVEA.W D0,A0
    
    MOVEA.L #$12345678,A0
    MOVEA.L D0,A0
    
    * ADDA
    ADDA.W    A1,A2
    ADDA.L    A2,A2
    
    * MOVEM commands (this may be the hardest to decode)
    MOVEM   D0-D7/A1-A4,EXIT    ;loads all the listed registers to memory at exit 
    
    * MOVEQ commands
    MOVEQ   #$12,D0

    * MULS
    MULS    D1,D2
    
    * DIVU 
    DIVU    D1,D2
    
    * LEA
    LEA     $1000,A1
    
    * LSL
    LSL.B    #2,D1
    LSL.W    #2,D1
    LSL.L    #2,D1
    
    * LSR
    LSR.B    #2,D1
    LSR.W    #2,D1
    LSR.L    #2,D1
    
    * ASL
    ASL.B   #2,D1
    ASL.W   #2,D1
    ASL.L   #2,D1
    
    * ASR
    ASR.B   #2,D1
    ASR.W   #2,D1
    ASR.L   #2,D1
    
    * ROL
    ROL.B   #2,D1
    ROL.W   #2,D1
    ROL.L   #2,D1
    
    * ROR
    ROR.B   #2,D1
    ROR.W   #2,D1
    ROR.L   #2,D1

    * Bcc
    Bcc.W   MAIN
    Bcc.L   MAIN
    
    * JSR
    JSR     subroutine
    
    * NOP
    NOP

    BRA     MAIN
    
subroutine:

    * RTS
    RTS    

    

* Put program code here


* Put variables and constants here












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
