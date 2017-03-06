*-----------------------------------------------------------
* Title      : Test program
* Written by : Jesse Llona
* Date       : 2/5/2017
* Description: To be loaded into memory in order to be decoded
*-----------------------------------------------------------


    * CMP
    CMP.B   D1,D2 ;CMP.B	D1,D2
    CMP.W   D3,D4 ;CMP.W	D3,D4
    CMP.L   D1,D2 ;CMP.L	D1,D2
    
    * CLR
    CLR.B   D1 ;CLR.B	D1
    CLR.W   D1 ;CLR.W	D1
    CLR.L   D1 ;CLR.L	D1

    * AND
    AND.B   D1,D2 ;AND.B	D1,D2
    AND.W   D1,D2 ;AND.W	D1,D2
    AND.L   D1,D2 ;AND.L	D1,D2
    
    * OR
    OR.B    D1,D2 ;OR.B	D1,D2
    OR.W    D1,D2 ;OR.W	D1,D2
    OR.L    D1,D2 ;OR.L	D1,D2
    
    * ADD commands
    ;ADD.B  #$12,D0
    ADD.B  D1,D3 ;ADD.B	D1,D3
    
   ; ADD.W  #$1234,D0
    ADD.W  D1,D3 ;ADD.W	D1,D3
    
    ;ADD.L  #$12345678,D0
    ADD.L  D1,D3 ;ADD.L	D1,D3

    * ADDQ
    ADDQ.B  #5,D1 ;ADDQ.B	#5,D5
    ADDQ.W  #5,D1 ;ADDQ.W	#5,D5
    ADDQ.L  #5,D1 ;ADDQ.L	#5,D5
    
    * ADDI
    ADDI.B   #40,D1 ;
    ADDI.W   #40,D1 ;
    ADDI.L   #40,D1 ;
    
    * SUB
    SUB.B   D1,D2 ;
    SUB.W   D1,D2 ;
    SUB.L   D1,D2 ;
    
    * MOVE commands
    ;MOVE.B  #$12,D0
    MOVE.B  D1,D3 ;
    
   ; MOVE.W  #$1234,D0
    MOVE.W  D1,D3 ;
    
    ;MOVE.L  #$12345678,D0
    MOVE.L  D1,D3 ;
    
    ;MOVE.W  $2002(PC),D0
    
    * MOVEA commands    
   ; MOVEA.W #$1234,A0
    MOVEA.W A1,A3 ;
    
   ; MOVEA.L #$12345678,A0
    MOVEA.L A1,A3 ;
    
    * ADDA
    ADDA.W    A1,A2 ;
    ADDA.L    A2,A2 ;
    
    * MOVEM commands (this may be the hardest to decode)
    ;MOVEM.W   D0-D7/A1-A4,EXIT    ;loads all the listed registers to memory at exit 
    ;MOVEM.W   EXIT,D0-D7/A1-A4   ;loads all the listed registers to memory at exit 
    
    * MOVEQ commands
    MOVEQ   #$12,D3

    * MULS
    MULS    D1,D2
    
    * DIVU 
    DIVU    D1,D2
    
    * LEA
    LEA     $1000,A1
    
    * LSL
    LSL.B    D2,D1
    LSL.W    D2,D1
    LSL.L    D2,D1
    
    * LSR
    LSR.B    D2,D1
    LSR.W    D2,D1
    LSR.L    D2,D1
    
    * ASL
    ASL.B   D2,D1
    ASL.W   D2,D1
    ASL.L   D2,D1
    
    * ASR
    ASR.B   D2,D1
    ASR.W   D2,D1
    ASR.L   D2,D1
    
    * ROL
    ROL.B   D2,D1
    ROL.W   D2,D1
    ROL.L   D2,D1
    
    * ROR
    ROR.B   D2,D1
    ROR.W   D2,D1
    ROR.L   D2,D1

    * Bcc
    BHI     MAIN
    BLS     MAIN
    BCC     MAIN
    BCS     MAIN
    BNE     MAIN
    BEQ     MAIN
    BVC     MAIN
    BVS     MAIN
    BPL     MAIN
    BMI     MAIN
    BGE     MAIN
    BLT     MAIN
    BGT     MAIN
    BLE     SUBROUTINE
    
    
    * JSR
    JSR     MAIN
    
    * NOP
    NOP


    
subroutine:

    * RTS
    RTS    

    

* Put program code here
*
*
* Put variables and constants here
































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
