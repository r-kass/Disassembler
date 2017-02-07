*-----------------------------------------------------------
* Title      : EA stuff
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

* direct to subroutine for size, then dest register, then 


* -------------- SUBROUTINE DIRECTORS ---------------

*       JMP      EAMODE000  ; Data register direct
*       JMP      EAMODE001  ; Address register direct
*       JMP      EAMODE010  ; Address register indirect
*       JMP      EAMODE011  ; Address register indirect with postincrement
*       JMP      EAMODE100  ; Address register indirect with predecrement
*       JMP      EAMODE101  ; Address register indirect with displacement
*       JMP      EAMODE110  ; Address register indirect with index [8-bit, base]
                            ; Memory indirect [postindexed, preindexed]
*       JMP      EAMODE111  ; Absolute data addressing [short, long]
*       JMP      EAREG000   ; Absolute data addressing [short, long]
*       JMP      EAREG100   ; Immediate addressing

*EAMODE000: 

*EAMODE001:

*EAMODE010:

*EAMODE011:

*EAMODE100:

*EAMODE101:

*EAMODE110:

    *8BIT  ;branch

    *BASE  ;branch
    
    *MIPOSTINDEX    ;branch
    
    *MIPREINDEX     ;branch

*EAMODE111: 

    *ADSHORT ;branch

    *ADLONG ;branch
    
*EAREG000:

    *SHORT ;branch

    *LONG ;branch

*EAREG100 


* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
