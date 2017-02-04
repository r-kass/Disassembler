*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA         EXIT,A2      ; exit will be replaced by the value given by user input 
    MOVE.L      #$4E72,(A2)  ; loads the value of NOP into memory for testing purposes
    ; TODO: save the value of PC
    ; print the binary of the next command
    MOVE.L      (A2)+,D1     ; D1 now has the word opcode and A2 points any data associated with this command)
    MOVE.B      #15,D0
    MOVE.B      #2,D2
    TRAP        #15          ; TODO print msb even if it's zero
    
    
    CMP         #$4E72,D1
    BEQ         NOP
    
NOP:
    
    ; TODO: go to value of pc before 
    SIMHALT             ; halt simulator
unknown DC.B    'unknown',0
* Put variables and constants here
EXIT:
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
