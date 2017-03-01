*-----------------------------------------------------------
* Title      : EA stuff
* Written by :
* Date       :
* Description: right now, does not handle data from RTS
* NOP, Bcc
* ADDI, MOVEM?
* MOVEQ?
*
* Key for edits:
*   - assumptions made: **************assumption*************
*   - to complete: 
*
*   will be called from print functions in Opcode to be handled
*   differently (specifically for BRA, NOP, MOVEQ)
*
*EAMODES
*
*       JMP      EAMODE000  ; Data register direct
*       JMP      EAMODE001  ; Address register direct
*       JMP      EAMODE010  ; Address register indirect
*       JMP      EAMODE011  ; Address register indirect with postincrement
*       JMP      EAMODE100  ; Address register indirect with predecrement
*       JMP      EAMODE101  ; Address register indirect with displacement
*       JMP      EAMODE110  ; Address register indirect with index [8-bit, base]
*                           ; Memory indirect [postindexed, preindexed]
*       JMP      EAMODE111  ; Absolute data addressing [short, long]
*
*EAREGISTERS
*
*       JMP      EAREG000   ; Absolute data addressing [short, long]
*       JMP      EAREG100   ; Immediate add-----------------
    ORG    $1000
    
START:                    ; first instruction of program
    MOVE.W  #$0007, LLA   ; TEMPORARY EA CODE
    LEA     LLA, A2       ; load the address pointer
    MOVEA.L #$01000000,A7 ; init the stack pointer
    JSR     DECODEEA
    SIMHALT
    
LLA DS.W   1           ; store the EA code here

DECODEEA:
    MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things


DECODEEASIMPLE: * --------------Decode recieved 6 bits ----------------
        ; for all except BRA, NOP, MOVEQ, ADDI, MOVEM, Bcc
        ; data curently in (A2)
        
        CLR.W   D1
        MOVE.W  (A2),D1      ; get copy of all 16 bits
        MOVE.W  (A2),D2      ; copy for register bits 

        ANDI.L #$0038, D1    ; bitmask thingy
        LSR.L  #3, D1        ; shifting by three bits for the mode
        ANDI.L #$0007, D2    ; bitmask thingy

        BRA     EADECMODE
*       LSL.W   #13, D2      ; bits shifted out to focus on last 3 bits

        
        ; mode is now in D1
        ; register is now in D2

*TODO
*DECODEEASPECIAL: FOR STRANGE CASES

EADECMODE: *--------------Loop to compare all EAModes-----------------

************* assumes A1 is available ********************

       MOVE.L  #$0, D4   ; counter for loop
       CMP    #%000, D1
       BEQ    EAMODE000

       CMP    #%001, D1
       BEQ    EAMODE001
        
       CMP    #%010, D1
       BEQ    EAMODE010
       
       CMP    #%011, D1
       BEQ    EAMODE011

       CMP    #%100, D1
       BEQ    EAMODE100

      * CMP    #%101, D1
      * BEQ    EAMODE101

       CMP    #%111, D1
       BEQ    EAMODE111

       ADD.L   #$1, D4    ; increment counter
       CMPI.L  #$7, D4    ; break loop here 
   *   BEQ     EAERROR    ; TODO ******************PUT THIS BACK *****************************
       BRA     EADECMODE


EAMODE000: *-------------------- Data register direct -------------------------------
        LEA     DATA_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      CONVERTTOASCII
        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        BRA EAEXIT                    ; branch to exit   
 ; doesn't work with beq, use BRA (right before your addi above)
        
EAMODE001: *------- Address register direct : send address register to buffer -------
     *   LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   
        BRA EAEXIT                    ; branch to exit   


EAMODE010: *--------- Address register indirect: sends address value ----------------

        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
      *  LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        
        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15  
  
        BRA EAEXIT                    ; branch to exit   
 


EAMODE011: * --------- Address register indirect with post increment ----------------

        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    

     *   LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15    

        LEA     PLUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    

        BRA EAEXIT                    ; branch to exit   
 

EAMODE100: *--------- Address register indirect with pre decrement ---------------

        LEA     MINUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    

    *    LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15    

        BRA EAEXIT                    ; branch to exit   
 

EAMODE111: * ------------ Absolute short, long ---------------------------------                                
      CMP.B   #%100, D2
      BEQ     IMMED100        
      CMP.B   #%000, D2
      BEQ     SHORT000
      CMP.B   #%001, D2
      BEQ     LONG001
      CMP.B   #%011, D2
      BEQ     EAEXIT                    ; branch to exit   
        
      CMP.B   #%101, D2
      BEQ     EAEXIT                    ; branch to exit   

      CMP.B   #%110, D2
      BEQ     EAEXIT                    ; branch to exit   

      CMP.B   #%111, D2
      BEQ     EAEXIT                    ; branch to exit   

    
IMMED100 ; branch
      LEA     POUND, A1
      MOVE.B  #14,D0
      TRAP    #15    
        
      LEA     DOLLAR_SIGN, A1 ;immediate data - hex
      MOVE.B  #14,D0
      TRAP    #15    
      
      ***TODO finish  


SHORT000 ; branch
      LEA     DOLLAR_SIGN, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #2, A2 ; read following word from memory
      ADDA.W  #2, A1 ; increment address
      MOVE.W  (A3),D6  
      MOVE.W  #4, D5
      
      ;TODO CONVERT TO HEX AND PRINT
      
      BRA EAEXIT                    ; branch to exit   


LONG001 ; branch
      LEA     DOLLAR_SIGN, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #4, A2 ; read following word from memory
      ADDA.W  #4, A1 ; increment address
      MOVE.W  (A3),D6  
      MOVE.W  #8, D5
      
      ;TODO CONVERT TO HEX AND PRINT
      
      BRA EAEXIT                    ; branch to exit   

EAERROR:
      BRA EAEXIT        ; TODO set error flag


EAEXIT:
        MOVEM.L (A7)+, D0-D7/A1/A3-A6 ; put everything back on the stack
        RTS                         ; return to sender

BIN2A_VAL    DS.L 1  ; input number for our conversion
BIN2A_BUFFER DS.B 16 ; buffer for ascii data
BIN2A_COUNT  DS.L 1  ; number of bits to convert (must be div by 4)

CONVERTTOASCII: 
        MOVEM.L  D0-D7/A0-A6, -(A7)     
        
        MOVE.L   BIN2A_COUNT, D2    ; shift count
        LEA      BIN2A_BUFFER, A0   ; load buffer into A0

BIN2A_LOOP
        SUB.L    #4, D2     ; decrement by 4
        MOVE.L   BIN2A_VAL, D1 ; copy the input value
        LSR.L    D2, D1
        ANDI.L   #$7, D1  ; cut the crap
        ADDI.L   #$30, D1 ; convert to ascii
        
        MOVE.B   D1, (A0)+ ; write character and increment buffer pointer
        CMPI.L   #0, D2    ; check if counter is 0
        BEQ      BIN2A_EXIT
        BRA      BIN2A_LOOP
        
BIN2A_EXIT
        MOVE.B   #0, (A0)+ ; null terminate and increment buffer pointer
        MOVEM.L  (A7)+, D0-D7/A0-A6
        RTS

*---------------------- Symbols ----------------------------

PARENTHESIS_1       DC.B        '(', 0
PARENTHESIS_2       DC.B        ')', 0
PLUS_SIGN           DC.B        '+', 0
MINUS_SIGN          DC.B        '-', 0
COMMA               DC.B        ',', 0
DOLLAR_SIGN         DC.B        '$', 0
POUND               DC.B        '#', 0

DATA_REG            DC.B        'D', 0



* Put variables and constants here

    END    START        ; last line of source

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
