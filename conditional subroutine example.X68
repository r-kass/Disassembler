*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here


    move.b  #4,D0
    
    pea     enterRoutine(pc)
    cmp.b   #4,D0
enterRoutine
    beq     Subroutine


Subroutine
    rts


    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
