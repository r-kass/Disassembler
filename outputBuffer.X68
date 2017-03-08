*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

* Put program code here
; USAGE EXAMPLE
*    jsr setupOutputBuffer
*
*    move.l #1,A0
*    move.l #2,A1 ; simulate using them up and clearing them
*    move.l #3,A2
*    move.l #4,A3
*    move.l #5,A4
*    move.l #6,A5
*    move.l #7,A6
*    
*    lea     msg,A1
*    jsr     moveA1ToBuffer
*
*    lea     msg2,A1
*    jsr     moveA1ToBuffer
*    
*    
*    jsr     printBuffer
*    
*    
*    lea     msg3,A1
*    jsr     moveA1ToBuffer
*    
*    lea     msg4,A1
*    jsr     moveA1ToBuffer
*    
*    jsr     printBuffer
*    BRA     EXIT
printBuffer:
    movem.l D0-D7/A0/A2-A6,-(A7)
    lea     outputBuffer,A1
    move.b  #14,D0
    Trap    #15
    jsr     setupOutputBuffer
    movem.l (A7)+,D0-D7/A0/A2-A6
    rts

setupOutputBuffer:           ; should be called at start of program
    movem.l D0-D7/A0/A2-A6,-(A7)
    lea     outputBuffer,A0  ; important setup
    lea     outputPointer,A1 ; important setup
    move.l  A0,(A1)          ; outputPointer is setup
    movem.l (A7)+,D0-D7/A0/A2-A6
    rts

moveA1ToBuffer
    movem.l D0-D7/A0/A2-A6,-(A7)
    lea     outputPointer,A0
    move.l  (A0),A0             ; where outputPointer is pointing is in A0

stringToBuffer
    move.b  (A1)+,(A0)+
    cmp.b   #0,(A1)
    beq     returnBuf
    bra     stringToBuffer
    
returnBuf
    move.b  #0,(A0)
    lea     outputPointer,A1
    move.l  A0,(A1)
    movem.l (A7)+,D0-D7/A0/A2-A6
    rts   
    
    
*    move.b  #4,D0
*    
*    pea     enterRoutine(pc)
*    cmp.b   #4,D0
*enterRoutine
*    beq     Subroutine
*
*
*Subroutine
*    rts


    SIMHALT             ; halt simulator

* Put variables and constants here 
CR              EQU     $0D
LF              EQU     $0A

outputBuffer    DS.L    256
outputPointer   DS.L    32
*msg             DC.B    'hello',0
*msg2            DC.B    ' world',CR,LF,0
*msg3            DC.B    'gb',0
*msg4            DC.B    ' wrld',CR,LF,0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
