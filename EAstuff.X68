*-----------------------------------------------------------
* Title      : EA portion of disassembler
* Written by : Jesse Llona, Ruby Kassala
* Date       : 2017.03.09
* Description: Disassembles things
* 
* TODO:
* add when merging with opcode: ADDI print immediate data that comes after -DONE
*                               MOVEQ #immediatevalue, Dn - DONE
*                               MOVEM word, register list mask
*                               Bcc dispacement and add displacement word - DONE
*
*   will be called from print functions in Opcode to be handled
*   differently 
* 
* The following functions are called from the Opcode.X68 file to disassemble 
* EA portion. The following OpCodes are considered special cases and are handled 
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

    
**************TESTING TINGS***********************
    MOVE.L #$48F9101E, TESTLOC      ; temp EA code - SHOULD PRINT: A1
    LEA     TESTLOC, A2       ; load the address pointer
    MOVEA.L #$01000000,A7   ; init the stack pointer
    JSR     MOVEMEA
    SIMHALT
    
TESTLOC DS.L   1           ; store the EA code here
**************TESTING TINGS***********************

DECODEEA:
    MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
    BRA DECODEEASIMPLE


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
        JSR     ADDQEA

        LEA     DATA_REG, A1
        MOVE.B  #14,D0
        TRAP    #15

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        MOVE.B   #14,D0
        TRAP     #15

        CMP.B   #100,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     RETURNEA
        
        LEA      COMMA,A1
        TRAP     #15
        
        CMP.B    #1,D7
        BEQ      PRINTA000
        
        LEA      DATA_REG, A1
        
CONTMODE000:     
        TRAP     #15
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        MOVE.B   #14,D0
        TRAP     #15

       ; CMP.B    #2,D7
       ; BEQ      MOVEEA
        BRA EAEXIT                    ; branch to exit   

PRINTA000:
        LEA     ADD_REG,A1
        BRA     CONTMODE000

        
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

              LEA      COMMA,A1
        TRAP     #15
        
        CMP.B    #1,D7
        BEQ      PRINTA001
        CMP.B    #2,D7
        LEA      DATA_REG, A1
CONTMODE001:     
        TRAP     #15
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        MOVE.B   #14,D0
        TRAP     #15

        BRA EAEXIT                    ; branch to exit   

PRINTA001:
        LEA     ADD_REG,A1
        BRA     CONTMODE000
     


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
      CMP.B   #%010, D2
      BEQ     EAEXIT                    ; branch to exit 
      CMP.B   #%011, D2
      BEQ     EAEXIT                    ; branch to exit   
      CMP.B   #%101, D2
      BEQ     EAEXIT                    ; branch to exit   
      CMP.B   #%110, D2
      BEQ     EAEXIT                    ; branch to exit   
      CMP.B   #%111, D2
      BEQ     EAEXIT                    ; branch to exit   

ADDQEA:
      CMP.B   #3,D7
      BNE     RETURNEA

      LEA     POUND, A1
      MOVE.B  #14,D0
      TRAP    #15
      
      MOVE.W  (A2),D2
      ANDI.W  #$0E00,D2
      LSR.W   #8,D2
      LSR.W   #1,D2
      
      MOVE.B  D2,D1
      MOVE.B  #3,D0
      TRAP    #15
      
      LEA     COMMA,A1
      MOVE.B  #14,D0
      TRAP    #15
      
      MOVE.B  #100,D7

RETURNEA:
      RTS      


    
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
      MOVE.L  #0, BIN2A_VAL      
      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT


      LEA     BIN2A_BUFFER,A1
      MOVE.B  #14,D0
      TRAP    #15

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

*-----------------------------SPECIAL SNOWFLAKES-------------------------------*

*-----------------------------MOVEM SUBROUTINES-------------------------------*
MOVEMSET            DS.B 0 ; 0 if set bits, else 1
DECODEMOVEMEA:
       MOVE.B  #0,MOVEMSET
       ;MOVE.B  #0,MOVEMMEMCOUNT
       ;MOVE.B  #0,MOVEMCOUNT
       ;MOVE.B  #0,MOVEMDIRECTION      
       MOVEM.L D0-D7/A1/A3-A6,-(A7)
       MOVE.W   (A2)+,D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BEQ      MOVEMEA
       ;MOVE.B   #$1,MOVEMDIRECTION
       ;BRA      MOVEMEAMEM
        
MOVEMEAMEM:

        
       ;CMPI.W   #$1, MOVEMMEMCOUNT 
       ;BEQ      MOVEMEXIT
       ;MOVE.B    #1,MOVEMMEMCOUNT
       MOVEA.W  A2, A3
       ADDA.W   #4, A3
       MOVE.L   #32,BIN2A_COUNT
       MOVE.W   (A3),D7
       MOVE.L   D7,BIN2A_VAL
       JSR      BIN2A_CONVERT       
       
       LEA      BIN2A_BUFFER,A1
       MOVE.B   #14,D0
       TRAP     #15
       
       SUB.W    #2,A2
       MOVE.W   (A2)+,D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BEQ      MOVEMEXIT
       
       LEA      COMMA,A1
       TRAP     #15
       
MOVEMEA:  
       CLR.W   D7
       MOVE.W  (A2),D5   ; get copy of all 16 bits

       MOVE.L  #$0, D4   ; counter for loop
       ;CMPI.W  #$1, MOVEMCOUNT

MOVEMEALOOP:

       ADD.L   #$1, D4    ; increment counter
       CMPI.L  #$F, D4    ; break loop here
       BEQ     EXITMOVEMEALOOP
         
       LSR.W   #1, D5
       BCS     PRINTMOVEMEA               ;branch if a 1 is shifted out
       BRA     MOVEMEALOOP

EXITMOVEMEALOOP:
       SUB.W    #2,A2
       MOVE.W   (A2)+,D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BNE      MOVEMEXIT

       
       LEA      COMMA,A1
       MOVE.B   #14,D0
       TRAP     #15
       BRA      MOVEMEAMEM

;MOVEMCOMMAM
       ;CMP.B    #0, MOVEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMCOUNT
       ;LEA      COMMA,A1
       ;MOVE.B   #14,D0
       ;TRAP     #15
       ;BRA      MOVEMEAMEM
       
;MOVEMCOMMAR
       ;CMP.B    #0, MOVEMMEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMMEMCOUNT
       ;LEA      COMMA,A1
       ;MOVE.B   #14,D0
       ;TRAP     #15
       ;BRA      MOVEMEA       
       

PRINTMOVEMEA:
      CMPI.B   #1, MOVEMSET
      BEQ      PRINTSLASH
      
PRINTMOVEM2:
      MOVE.B   #1, MOVEMSET
      CMPI.L   #8, D4

      BLE      PRINTMOVEMD 
      BRA      PRINTMOVEMA
      
PRINTMOVEMD:
      LEA      DATA_REG, A1
      MOVE.B   #14,D0
      TRAP     #15

      MOVE.L   D4,D6   ; copy count to D6
      SUBI.L   #1, D6
      
      MOVE.W   D6,D1
      MOVE.B   #3,D0
      TRAP     #15

      BRA      MOVEMEALOOP


PRINTMOVEMA:
      LEA     ADD_REG, A1

      MOVE.B  #14,D0
      TRAP    #15

      MOVE.L  D4,D6   ; copy count to D6
      SUBI.L  #9, D6
      
      MOVE.B  D6,D1
      MOVE.B  #3,D0
      TRAP    #15

      BRA MOVEMEALOOP

PRINTSLASH

      LEA     SLASH, A1
      MOVE.B  #14,D0
      TRAP    #15
      BRA     PRINTMOVEM2

MOVEMEXIT:
      
      
      LEA     NEWLINE,A1
      MOVE.B  #14,D0
      TRAP    #15
      
      ADDA.L  #4,A2
      BRA     EAEXIT
*-----------------------------END MOVEA SUBROUTINES-------------------------------*
      
MOVEEA: 
      MOVE.W    (A2),D6
      LSR.W     #8,D6
      LSR.W     #1,D6
      ANDI.W    #0003,D6
      MOVE.W    D6,D5
      MOVE.W    (A2),D6
      LSR.W     #3,D6
      ANDI.W    #$003F,D6
      ADD.W     D5,D6
      MOVE.W    D6,(A2)
      MOVE.B    #100,D7
      BRA       DECODEEA
      
      
      
BCCEA: ;special case 

      MOVE.W    (A2),D6  ; only move last byte
      MOVE.B    D6,BIN2A_VAL
      MOVE.B    #8,BIN2A_COUNT
      
      MOVE.B    #14,D0
      TRAP      #15

      BRA EAEXIT      
      
MOVEQEA: ;special case 
      MOVEM.L D0-D7/A1/A3-A6,-(A7)
      LEA       POUND,A1
      MOVE.B    #14,D0
      TRAP      #15

      MOVE.W    (A2),D1  ; only move last byte
      ANDI.W    #$003F,D1
      MOVE.B    #3,D0

      TRAP      #15
      
      LEA       COMMA,A1
      MOVE.B    #14,D0
      TRAP      #15

      LEA       DATA_REG,A1
      TRAP      #15

      MOVE.W    (A2),D1
      ANDI.W    #$0E00,D1
      LSR.W     #8,D1
      LSR.W     #1,D1
      
      MOVE.B    #3,D0
      TRAP      #15
      
      BRA EAEXIT        

*PRINTADDIBYTE:
*      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
*
*      ADDA.W  #1, A2 ; read following word from memory
*     
*      MOVE.W  (A2),BIN2A_VAL  
*      MOVE.W  #4, BIN2A_COUNT
*      JSR     BIN2A_CONVERT
*
*  *   ADDA.W   #2, A1 
*      LEA      BIN2A_BUFFER, A1
*      MOVE.B   #14,D0
*      TRAP     #15
*
* 
*      BRA     EAEXIT        


PRINTADDIWORD:
      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things

      
      MOVE.L  (A2),BIN2A_VAL  
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT


      LEA      POUND,A1
      MOVE.B   #14,D0
      TRAP     #15
      
      LEA      DOLLAR_SIGN,A1
      TRAP     #15
      
  *   ADDA.W   #4, A1 
      LEA      BIN2A_BUFFER, A1
      MOVE.B   #14,D0
      TRAP     #15
      
      LEA      COMMA,A1
      TRAP     #15
      
      MOVE.B   #101,D7
      JSR DECODEEASIMPLE
      
      ADDA.L   #2,A2
        
      BRA     EAEXIT     

PRINTADDILONG: 
      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things

      ADDA.W  #2,A2
      MOVE.L  (A2),BIN2A_VAL
      SUBA.W  #2,A2  
      MOVE.L  #32, BIN2A_COUNT
      JSR     BIN2A_CONVERT

  *   ADDA.W   #8, A1 
      LEA      POUND,A1
      MOVE.B   #14,D0
      TRAP     #15
      
      LEA      DOLLAR_SIGN,A1
      TRAP     #15
      
  *   ADDA.W   #4, A1 
      LEA      BIN2A_BUFFER, A1
      MOVE.B   #14,D0
      TRAP     #15
      
      LEA      COMMA,A1
      TRAP     #15
      
      MOVE.B   #101,D7
      JSR DECODEEASIMPLE
      
      ADDA.L   #4,A2


      BRA     EAEXIT     


EAEXIT: ; SET ERROR FLAG TODO
        MOVEM.L (A7)+,D0-D7/A1/A3-A6 ; put everything back on the stack
        MOVE.L  #0,D7
        LEA     NEWLINE,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        BRA     LOOP                  ; return to sender

*---------------BINARY TO ASCII CONVERSION -------------------------------
BIN2A_VAL    DS.L 1  ; input number for our conversion
BIN2A_BUFFER DS.B 16 ; buffer for ascii data
BIN2A_COUNT  DS.L 1  ; number of bits to convert (must be div by 4)

BIN2A_CONVERT: 
        MOVEM.L  D0-D7/A0-A6, -(A7)     
        
        MOVE.L   BIN2A_COUNT, D2    ; shift count
        LEA      BIN2A_BUFFER, A0   ; load buffer into A0

BIN2A_LOOP:
        SUB.L    #4, D2     ; decrement by 
        MOVE.L   BIN2A_VAL,D1 ; copy the input value
        LSR.L    D2, D1
        ANDI.L   #$F, D1  ; truncate
        CMP.B    #10, D1
        BGE      BIGNUM
        ADDI.L   #$30, D1 
        
BIN2A_LOOP2
        MOVE.B   D1, (A0)+ ; write character and increment buffer pointer
        CMPI.W   #0, D2    ; check if counter is 0
        BEQ      BIN2A_EXIT
        BRA      BIN2A_LOOP
        
BIN2A_EXIT:
        MOVE.B   #0, (A0)+ ; null terminate and increment buffer pointer
        MOVEM.L  (A7)+, D0-D7/A0-A6
        RTS
        
BIGNUM 
        ADDI.L   #$37,D1
        BRA      BIN2A_LOOP2

*------------------------------------------------------------------------

*---------------------- Symbols ----------------------------
CR                  EQU         $0D
LF                  EQU         $0A

;MOVEMMEMCOUNT       DS.B 0 ; 0 if memory is already printed, otherwise 1
;MOVEMCOUNT          DS.B 0 ; 0 if other stuff is already printed, otherwise 1
;MOVEMDIRECTION      DS.B 0

NEWLINE             DC.B        CR,LF,0
PARENTHESIS_1       DC.B        '(', 0
PARENTHESIS_2       DC.B        ')', 0
PLUS_SIGN           DC.B        '+', 0
MINUS_SIGN          DC.B        '-', 0
COMMA               DC.B        ',', 0
DOLLAR_SIGN         DC.B        '$', 0
POUND               DC.B        '#', 0
SLASH               DC.B        '/', 0

DATA_REG            DC.B        'D', 0
ADD_REG             DC.B        'A', 0

EAERRORMSG          DC.B	    'Invalid Mode',0


* Put variables and constants here

  ;  END    START        ; last line of source
*~Font name~Courier New~
  







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
