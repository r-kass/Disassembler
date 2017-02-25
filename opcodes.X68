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
    LEA         $2000,A2     ; $2000 is hardcoded as the location where the test code will be. This needs to be updated to have user input 

LOOP:
    ; print the binary of the next command
    MOVE.W      (A2)+,D1     ; D1 now has the word opcode and A2 points any data associated with this command)
    MOVE.B      #15,D0
    MOVE.B      #2,D2
    TRAP        #15          ; TODO print msb even if it's zero
    ; compare value in D1.W to known opcodes TODO: this will need to be more sophisticated, and not take an entire word at a time
    CMP         #$4E71,D1
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
    CMP         #$2028,A2
    BLT         LOOP    
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
