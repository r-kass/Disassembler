*-----------------------------------------------------------
* Title      : Test program
* Written by : Jesse Llona
* Date       : 2/5/2017
* Description: To be loaded into memory in order to be decoded
*-----------------------------------------------------------


    ; MOVE commands
    MOVE.B  #$12,D0
    MOVE.B  D1,D0
    
    MOVE.W  #$1234,D0
    MOVE.W  D1,D0
    
    MOVE.L  #$12345678,D0
    MOVE.L  D1,D0
    
    
    ; MOVEA commands
    MOVEA.W #$1234,A0
    MOVEA.W D0,A0
    
    MOVEA.L #$12345678,A0
    MOVEA.L D0,A0
    
    BRA     MAIN
* Put program code here


* Put variables and constants here

 

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
