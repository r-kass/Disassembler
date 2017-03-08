*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

        MOVE.B  #1,D1
        LSR.B   #1,D1
        BCS     HERE

        MOVEM.L D0,EXIT
        MOVEM.L D0-D1,EXIT
        MOVEM.L D0-D2,EXIT
        MOVEM.L D0-D3,EXIT
        MOVEM.L D0-D4,EXIT
        MOVEM.L D0-D5,EXIT
        MOVEM.L D0-D6,EXIT
        MOVEM.L D0-D7,EXIT
HERE:    
        MOVEM.L D1,EXIT
        MOVEM.L D1-D2,EXIT
        MOVEM.L D1-D3,EXIT
        MOVEM.L D1-D4,EXIT
        MOVEM.L D1-D5,EXIT
        MOVEM.L D1-D6,EXIT
        MOVEM.L D1-D7,EXIT
        
        MOVEM.L D2,EXIT
        MOVEM.L D2-D3,EXIT
        MOVEM.L D2-D4,EXIT
        MOVEM.L D2-D5,EXIT
        MOVEM.L D2-D6,EXIT
        MOVEM.L D2-D7,EXIT
        
        MOVEM.L D3,EXIT
        MOVEM.L D3-D4,EXIT
        MOVEM.L D3-D5,EXIT
        MOVEM.L D3-D6,EXIT
        MOVEM.L D3-D7,EXIT
        
        MOVEM.L D4,EXIT
        MOVEM.L D4-D5,EXIT
        MOVEM.L D4-D6,EXIT
        MOVEM.L D4-D7,EXIT
        
        MOVEM.L D5,EXIT
        MOVEM.L D5-D6,EXIT
        MOVEM.L D5-D7,EXIT
        
        MOVEM.L D6,EXIT
        MOVEM.L D6-D7,EXIT
        
        MOVEM.L D7,EXIT
        
        MOVEM.L EXIT,A0-A3/D0-D3
        
        
        MOVE.W  #$F2CA,D3

        MOVE.L  D3,BIN2A_VAL
        MOVE.L  #16,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        
        LEA     BIN2A_BUFFER,A1
        MOVE.B  #14,D0
        TRAP    #15


        BRA EXIT

BIN2A_VAL    DS.L 1  ; input number for our conversion
BIN2A_BUFFER DS.B 16 ; buffer for ascii data
BIN2A_COUNT  DS.L 1  ; number of bits to convert (must be div by 4)

BIN2A_CONVERT: 
        MOVEM.L  D0-D7/A0-A6, -(A7)     
        
        MOVE.L   BIN2A_COUNT, D2    ; shift count
        LEA      BIN2A_BUFFER, A0   ; load buffer into A0

BIN2A_LOOP:
        SUB.L    #4, D2     ; decrement by 4
        MOVE.L   BIN2A_VAL, D1 ; copy the input value
        LSR.L    D2, D1
        ANDI.L   #$F, D1  ; cut the crap
        CMP.B    #10,D1
        BGE      thingy      

        ADDI.L   #$30, D1 ; convert to ascii
BACK:        
        MOVE.B   D1, (A0)+ ; write character and increment buffer pointer
        CMPI.L   #0, D2    ; check if counter is 0
        BEQ      BIN2A_EXIT
        BRA      BIN2A_LOOP
        
BIN2A_EXIT:
        MOVE.B   #0, (A0)+ ; null terminate and increment buffer pointer
        MOVEM.L  (A7)+, D0-D7/A0-A6
        RTS
thingy:
        ADDI.L  #$37,D1
        BRA     BACK

    SIMHALT             ; halt simulator

* Put variables and constants here
EXIT:
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
