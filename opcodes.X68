*-----------------------------------------------------------
* Title      : more stuff
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG     $2000 ; this is where the test program will be loaded into memory
START:                  ; first instruction of program
    
    INCLUDE 'testProgram.X68' ; run the testProgram Subroutine
    
    ORG     $1000 ; this is where the rest of the code will be loaded into memory
MAIN
* Put program code here
    LEA         EXIT,A2      ; exit will be replaced by the value given by user input 
    MOVE.L      #$4E72,(A2)  ; loads the value of NOP into memory for testing purposes
    ; TODO: save the value of PC
    ; print the binary of the next command
    MOVE.L      (A2)+,D1     ; D1 now has the word opcode and A2 points any data associated with this command)
    MOVE.B      #15,D0
    MOVE.B      #2,D2
    TRAP        #15          ; TODO print msb even if it's zero
    
    ; compare value in D1.W to known opcodes TODO: this will need to be more sophisticated, and not take an entire word at a time
    CMP         #$4E72,D1
    BEQ         NOP
    ;TODO: more compares
    BRA         UNKNWON   
    
NOP:
    LEA         NOPmsg,A1
    MOVE.B      #13,D0
    TRAP        #15
    BRA         CONTINUE

UNKNWON: ;TODO: make this more sophsticated
    LEA         unknownMsg,A1
    MOVE.B      #13,D0
    TRAP        #15
    BRA         CONTINUE
    
CONTINUE    
    ; TODO: set A2 to value of pc, loop back to beginnin
    SIMHALT             ; halt simulator
TAB     EQU     $09

unknownMsg  DC.B    TAB,TAB,'unknown',0
NOPmsg      DC.B    TAB,TAB,'NOP',0
* Put variables and constants here
EXIT:
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
