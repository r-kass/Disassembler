*-----------------------------------------------------------
* Title      : EA stuff
* Written by :
* Date       :
* Description: 
* 
* TODO:
* add when merging with opcode: ADDI print immediate data that comes after
*                               MOVEQ #immediatevalue, Dn
*                               MOVEM word, register list mask
*                               Bcc dispacement and add displacement word
*
*   will be called from print functions in Opcode to be handled
*   differently 
* 
* 
*
*EAMODES
*
*       JMP      EAMODE000  ; Data register direct
*       JMP      EAMODE001  ; Address register direct
*       JMP      EAMODE010  ; Address register indirect
*       JMP      EAMODE011  ; Address register indirect with postincrement
*       JMP      EAMODE100  ; Address register indirect with predecrement
*       JMP      EAMODE111  ; Absolute data addressing [short, long]
*
*EAREGISTERS
*
*       JMP      EAREG000   ; Absolute data addressing [short, long]
*       JMP      EAREG100   ; Immediate add

    ORG    $1000
    
START:                    ; first instruction of program


**************TESTING TINGS***********************
    MOVE.W  #$0009, TESTLOC      ; temp EA code - SHOULD PRINT: A1
    LEA     TESTLOC, A2       ; load the address pointer
    MOVEA.L #$01000000,A7   ; init the stack pointer
    JSR     DECODEEA
    SIMHALT
    
TESTLOC DS.W   1           ; store the EA code here
**************TESTING TINGS***********************

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
        
        ; mode is now in D1
        ; register is now in D2

*TODO
*DECODEEASPECIAL: FOR STRANGE CASES

EADECMODE: *--------------Loop to compare all EAModes-----------------

************* assumes A1 is available ********************

       MOVE.L  #$0, D4   ; counter for loop
       CMP.B   #%000, D1
       BEQ    EAMODE000

       CMP.B  #%001, D1
       BEQ    EAMODE001
        
       CMP.B  #%010, D1
       BEQ    EAMODE010
       
       CMP.B  #%011, D1
       BEQ    EAMODE011

       CMP.B  #%100, D1
       BEQ    EAMODE100 

       CMP    #%111, D1
       BEQ    EAMODE111

       ADD.L   #$1, D4    ; increment counter
       CMPI.L  #$7, D4    ; break loop here 
       BEQ     EAERROR    
       BRA     EADECMODE


EAMODE000: *-------------------- Data register direct -------------------------------
        LEA     DATA_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        BRA EAEXIT                    ; branch to exit   

EAMODE001: *-------------------- Address register direct -------------------------------

        LEA     ADD_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        BRA EAEXIT      


EAMODE010: *--------- Address register indirect: sends address value ----------------

        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        ; eamode001 ---------
        LEA     ADD_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15
        ; --------------------

        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15  
  
        BRA EAEXIT                    ; branch to exit   
 


EAMODE011: * --------- Address register indirect with post increment ----------------


        ; eamode010 ---------

        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        LEA     ADD_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15  
 
        ; --------------------

        LEA     PLUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    

        BRA EAEXIT                    ; branch to exit   
 

EAMODE100: *--------- Address register indirect with pre decrement ---------------

        LEA     MINUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        ; eamode010 ---------

        LEA     PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        LEA     ADD_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        LEA     PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15  
 
        ; --------------------
        
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
      
      CLR.L   D5
      MOVE.B  (A2),D4          
      CMP.B   #1,D4      ;if 1- word; if 2- long
      BEQ     WORDIMMED
      BRA     LONGIMMED
      
WORDIMMED
      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6  
      MOVE.W  #4, D5
      JSR     BIN2A_CONVERT

      ADDA.W  #2, A1  ; move along 32 bit extension

      BRA     EAEXIT                    ; branch to exit   
      

LONGIMMED

      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6  
      MOVE.W  #8, D5
      JSR     BIN2A_CONVERT

      ADDA.W  #4, A1  ; move along 32 bit extension

      BRA     EAEXIT                    ; branch to exit   




SHORT000 ; branch
      LEA     DOLLAR_SIGN, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6  
      MOVE.W  #4, D5
      JSR     BIN2A_CONVERT

      ADDA.W  #2, A1  ; move along 32 bit extension

      BRA     EAEXIT                    ; branch to exit   



LONG001 ; branch
      LEA     DOLLAR_SIGN, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #2, A2 ; read following word from memory

      MOVE.W  (A2),D6  
      MOVE.W  #8, D5
      JSR     BIN2A_CONVERT

      ADDA.W  #4, A1 

      BRA     EAEXIT                    ; branch to exit   


EAERROR:
      LEA     EAERRORMSG, A1
      MOVE.B  #13,D0
      TRAP    #15
      BRA     EAEXIT   


EAEXIT: ; SET ERROR FLAG TODO
        MOVEM.L (A7)+, D0-D7/A1/A3-A6 ; put everything back on the stack
        RTS                         ; return to sender

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
        ANDI.L   #$7, D1  ; cut the crap
        ADDI.L   #$30, D1 ; convert to ascii
        
        MOVE.B   D1, (A0)+ ; write character and increment buffer pointer
        CMPI.L   #0, D2    ; check if counter is 0
        BEQ      BIN2A_EXIT
        BRA      BIN2A_LOOP
        
BIN2A_EXIT:
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
ADD_REG             DC.B        'A', 0

EAERRORMSG          DC.B	    'Invalid Mode',0


* Put variables and constants here

    END    START        ; last line of source

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
