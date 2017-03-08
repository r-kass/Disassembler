*-----------------------------------------------------------
* Title      : EA portion of disassembler
* Written by : Jesse Llona, Ruby Kassala
* Date       : 2017.03.09
* Description: Disassembles things


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
    CLR.L   D3
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

       BRA     EAERROR

PRINTLAST3ANDCONT100:
         MOVE.W  (A2),D2
        ANDI.W  #7,D2
        MOVE.L  D2,BIN2A_VAL
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT100ADDQ

PRINTLAST3ANDCONT010:
        MOVE.W  (A2),D2
        ANDI.W  #7,D2
        MOVE.L  D2,BIN2A_VAL
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT010ADDQ
  
PRINTLAST3ANDCONT011:
        MOVE.W  (A2),D2
        ANDI.W  #7,D2
        MOVE.L  D2,BIN2A_VAL
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT011ADDQ
  
PRINTLAST3ANDEXIT:
        MOVE.W  (A2),D2
        ANDI.W  #7,D2
        MOVE.L  D2,BIN2A_VAL
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     EAEXIT

EAMODE000: *-------------------- Data register direct -------------------------------
        BRA     ADDQEA000
NOTADDQ000:
        LEA     DATA_REG, A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDEXIT
        
        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     RETURNEA
        
        LEA      COMMA,A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B    #1,D7
        BEQ      PRINTA000
        
        
        SUB.L   #4,D3
        PEA     END000(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
        RTS
END000:
        SUB.L   #2,A2
        BRA EAEXIT
        
CONTMODE000:     
        JSR     MOVEA1TOBUFFER
         
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER

       ; CMP.B    #2,D7
       ; BEQ      MOVEEA
        BRA EAEXIT                    ; branch to exit   

PRINTA000:
        LEA     ADD_REG,A1
        BRA     CONTMODE000

        
EAMODE001: *-------------------- Address register direct -------------------------------
        BRA     ADDQEA001
NOTADDQ001:
        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDEXIT

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     EAEXIT

        CMP.B   #100,D7
        BEQ     EAEXIT

        LEA      COMMA,A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B    #1,D7
        BEQ      PRINTA001
        CMP.B    #2,D7
        
        SUB.L   #4,D3
        PEA     END001(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END001:
        SUB.L   #2,A2
        BRA EAEXIT
CONTMODE001:     
        JSR     MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER

        BRA EAEXIT                    ; branch to exit   

PRINTA001:
        LEA     ADD_REG,A1
        BRA     CONTMODE000
     


EAMODE010: *--------- Address register indirect: sends address value ----------------
        BRA     ADDQEA010
NOTADDQ010:

        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER  
        
        ; eamode001 ---------
        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDCONT010


        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER
        ; --------------------
CONT010ADDQ

        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER 
  
        
        CMP.B   #3,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT
  
  
        LEA     COMMA,A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #1,D7
        BEQ     PRINTA010
        
        
        SUB.L   #4,D3
        PEA     END010(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END010:
        SUB.L   #2,A2
        BRA EAEXIT                    ; branch to exit   
    
CONTMODE010:     
        JSR     MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        
        BRA EAEXIT   
 
PRINTA010:
        LEA     ADD_REG,A1
        BRA     CONTMODE010

EAMODE011: * --------- Address register indirect with post increment ----------------
        BRA     ADDQEA011
NOTADDQ011:

        ; eamode010 ---------

        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER  
        
        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDCONT011
        
        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT
        LEA      BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

CONT011ADDQ:
        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER 
 
        ; --------------------

        LEA     PLUS_SIGN, A1
        JSR     MOVEA1TOBUFFER    
    
        CMP.B   #3,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT


        LEA     COMMA,A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #1,D7
        BEQ     PRINTA011

        
        SUB.L   #4,D3
        PEA     END011(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END011:
        SUB.L   #2,A2
        BRA EAEXIT          

CONTMODE011:     
        JSR     MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER

         BRA EAEXIT   

PRINTA011:
        LEA     ADD_REG,A1
        BRA     CONTMODE011

EAMODE100: *--------- Address register indirect with pre decrement ---------------
        BRA     ADDQEA100
NOTADDQ100:
        LEA     MINUS_SIGN, A1
        JSR     MOVEA1TOBUFFER  
        
        ; eamode010 ---------

        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER  
        
        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDCONT100
        
        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER
CONT100ADDQ
        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER 
        
        CMP.B   #3,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT
 
        LEA     COMMA,A1
        JSR     MOVEA1TOBUFFER
        
        CMP.B   #1,D7
        BEQ     PRINTA100
        
        SUB.L   #4,D3
        PEA     END100(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END100:
        SUB.L   #2,A2
        BRA EAEXIT          

CONTMODE100:     
        JSR     MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
    
         BRA EAEXIT   

PRINTA100:
        LEA     ADD_REG,A1
        BRA     CONTMODE011

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


ADDQEA100:
      CMP.B   #3,D7
      BNE     NOTADDQ100
      MOVE.W  #$100,D6
      BRA     ADDQEA

ADDQEA011:
      CMP.B   #3,D7
      BNE     NOTADDQ011
      MOVE.W  #$011,D6
      BRA     ADDQEA

ADDQEA010:
      CMP.B   #3,D7
      BNE     NOTADDQ010
      MOVE.W  #$010,D6
      BRA     ADDQEA
    
ADDQEA001:
      CMP.B   #3,D7
      BNE     NOTADDQ001
      MOVE.W  #$001,D6
      BRA     ADDQEA
    
ADDQEA000:
      CMP.B   #3,D7
      BNE     NOTADDQ000
      MOVE.W  #$000,D6
      BRA     ADDQEA
ADDQEA:

      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER
      
      MOVE.W  (A2),D2
      ANDI.W  #$0E00,D2
      LSR.W   #8,D2
      LSR.W   #1,D2
      
      MOVE.L  D2,BIN2A_VAL
      MOVE.L  #4,BIN2A_COUNT
      JSR     BIN2A_CONVERT
      
      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #100,D7
      BEQ     EAEXIT
      
      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.W   #$000,D6
      BEQ     NOTADDQ000
      CMP.W   #$010,D6
      BEQ     NOTADDQ010
      CMP.W   #$011,D6
      BEQ     NOTADDQ011
      CMP.W   #$100,D6
      BEQ     NOTADDQ100
      CMP.W   #$001,D6
      BEQ     NOTADDQ001
           
RETURNEA:
      MOVE.B  #0,RETURNATEND
      RTS      


    
IMMED100 ; branch
      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER   
        
      LEA     DOLLAR_SIGN, A1 ;immediate data - hex
      JSR     MOVEA1TOBUFFER
      
      CLR.L   D5
      MOVE.W  (A2),D4
      ROL.W   #4,D4
      ANDI.W  #$0003,D4          
      CMP.B   #3,D4      ;if 1- word; if 2- long
      BEQ     WORDIMMED
      CMP.B   #1,D4
      BEQ     BIMMED
      BRA     LONGIMMED
      
BIMMED:
            
      
WORDIMMED
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM   (A7)+,A2  
      
      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6
        
      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT

      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #100,D7
      BEQ     EAEXIT
      
      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      ;MOVE.B  #2,D3
      CMP.W   #1,D7
      BEQ     PRINTIMMEDA
      
      SUB.W   #2,A2
      JSR     DECODEIMEDREGS
      

      ADDA.W  #2, A2  ; move along 32 bit extension
      

      BRA     EAEXIT                  ; branch to exit   
      

LONGIMMED
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #4,(A2)
      MOVEM   (A7)+,A2
      
      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.L  (A2),D6
        
      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #32, BIN2A_COUNT
      JSR     BIN2A_CONVERT

      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #100,D7
      BEQ     EAEXIT      
      
      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      ;MOVE.B  #4,D3
      CMP.W   #1,D7
      BEQ     PRINTIMMEDA

      
      CMP.B   #1,D7
      BEQ     PRINTALONGIMMED
      
      
      ADD.L   #2,D3
      SUB.W   #2,A2
      JSR     DECODEIMEDREGS
      

      ADDA.W  #6, A2  ; move along 32 bit extension
      

      BRA     EAEXIT                    ; branch to exit   

PRINTIMMEDA:
      
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   D3,(A2)
      MOVEM   (A7)+,A2

      SUB.L   #2,A2
      LEA     ADD_REG,A1
      JSR     MOVEA1TOBUFFER
      MOVE.W   (A2),D2
      LSR.W    #8,D2
      LSR.W    #1,D2
      ANDI.W   #$0007,D2
      MOVE.L   D2, BIN2A_VAL
      MOVE.L   #4, BIN2A_COUNT
      JSR      BIN2A_CONVERT
      
      LEA      BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
    
      BRA EAEXIT   


PRINTALONGIMMED:
      SUB.L   #2,A2
      LEA     ADD_REG,A1

      JSR     MOVEA1TOBUFFER
      MOVE.W   (A2),D2
      LSR.W    #8,D2
      LSR.W    #1,D2
      ANDI.W   #$0007,D2
      MOVE.L   D2, BIN2A_VAL
      MOVE.L   #4, BIN2A_COUNT
      JSR      BIN2A_CONVERT
        
      LEA      BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
  
      MOVEM     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)
      MOVEM     (A7)+,A2
        
      BRA EAEXIT  

DECODEIMEDREGS:
      MOVE.W    (A2),D2
      ANDI.W    #$01C0,D2
      
      PEA       DONELONG(PC) ; GO TO DONECHECKING AFTER RTS
      CMP.W     #0,D2      
      BEQ       PRINTDR
      CMP.W     #$0200,D2
      BEQ       PRINTAR
      CMP.W     #$0080,D2
      BEQ       PRINTADDDEREF
      CMP.W     #$00C0,D2
      BEQ       PRINTADDPOSTINC
      CMP.W     #$0100, D2
      BEQ       PRINTADDPREDEC 
      CMP.W     #$01C0,D2
      BEQ       PRINTMEMADD

PRINTMEMADD
      MOVEM     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)
      MOVEM     (A7)+,A2
      
      LEA       DOLLAR_SIGN,A1
      JSR       MOVEA1TOBUFFER
      
      MOVE.W    (A2),D2
      ANDI.W    #$0E00,D2
      CMP.W     #$0200,D2
      BEQ       PRINTMEMADDLONG
      
      ADD.L     D3,A2
      ADD.L     #4,A2           ;2??????????????????????????????????
      MOVE.W    (A2),D2
      MOVE.L    D2,BIN2A_VAL
      MOVE.L    #16,BIN2A_COUNT    
      JSR       BIN2A_CONVERT
      
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER

      RTS
  
PRINTMEMADDLONG:
      MOVEM     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)
      MOVEM     (A7)+,A2

      ADD.L     D3,A2
      ADD.L     #4,A2           ;2??????????????????????????????????
      MOVE.L    (A2),D2
      MOVE.L    D2,BIN2A_VAL
      MOVE.L    #32,BIN2A_COUNT    
      JSR       BIN2A_CONVERT
      
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER
    
      ADD.L     #4,A2

      RTS

    
PRINTADDPOSTINC   
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      LEA       PLUS_SIGN,A1
      JSR       MOVEA1TOBUFFER
      RTS  
PRINTADDPREDEC   
      LEA       MINUS_SIGN,A1
      JSR       MOVEA1TOBUFFER
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      RTS  

  
PRINTNUM:
      MOVE.W    (A2),D2
      ANDI.W    #$0E00,D2
      LSR.W     #8,D2
      LSR.W     #1,D2
      
      MOVE.L    D2,BIN2A_VAL
      MOVE.L    #4,BIN2A_COUNT
      JSR       BIN2A_CONVERT
      
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER
      RTS

PRINTADDDEREF:
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER

      
      JSR       PRINTNUM
      
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      RTS

PRINTAR:
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      RTS         
   
PRINTDR:
      LEA       DATA_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      RTS 

DONELONG:
      ADD.L     #4,A2
      BRA       EAEXIT

D2FILL:
      MOVE.W  #8,D2
      RTS

ADDQSHORT000:

      LEA     POUND,A1
      JSR     MOVEA1TOBUFFER
      
      CLR.L   D2
      MOVE.W  (A2),D2
      ROL.W   #7,D2
      ANDI.W  #7,D2
      
      PEA     RETAQS(PC)
      CMP.W   #0,D2
      BEQ     D2FILL
RETAQS  
      
      MOVE.L  D2,BIN2A_VAL
      MOVE.L  #4,BIN2A_COUNT
      JSR     BIN2A_CONVERT
      
      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #100,D7
      BEQ     EAEXIT      
      
      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      LEA     DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER
      
      ADD.L   #2,A2
      CLR.L   D2
      MOVE.W  (A2),D2
      MOVE.L  D2,BIN2A_VAL
      MOVE.L  #16,BIN2A_COUNT
      JSR     BIN2A_CONVERT
      
      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      BRA     EAEXIT


SHORT000 ; branch
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM   (A7)+,A2

      CMP.B   #3,D7
      BEQ     ADDQSHORT000
      
      LEA     DOLLAR_SIGN, A1 ; hex
      JSR     MOVEA1TOBUFFER 
      
      ADD.L   D3,A2
      ADDA.W  #2, A2 ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6  
      MOVE.L  #0, BIN2A_VAL      
      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT


      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      CMP.W     #101,D7
      BEQ       EAEXIT

      CMP.B   #100,D7
      BEQ     EAEXIT

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #1,D7
      BEQ     PRINTAABS_IMD
      
      SUB.L   #2,D3
      SUB.W   #2,A2
      JSR     DECODEREGS

      ;SUB.W   #2,A2
      ;ADDA.W  #2, A2  ; move along 16 bit extension

      BRA     EAEXIT                    ; branch to exit   

PRINTAABS_IMD:

        SUB.L   #2,A2
        LEA     ADD_REG,A1

        JSR     MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT
        
        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
    
        BRA EAEXIT   

ADDQLONG001:

      LEA     POUND,A1
      JSR     MOVEA1TOBUFFER
      
      CLR.L   D2
      MOVE.W  (A2),D2
      ROL.W   #7,D2
      ANDI.W  #7,D2
      PEA     RETAQL(PC)
      CMP.W   #0,D2
      BEQ     D2FILL
RETAQL      
      MOVE.L  D2,BIN2A_VAL
      MOVE.L  #4,BIN2A_COUNT
      JSR     BIN2A_CONVERT
      
      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER
      
      CMP.B   #100,D7
      BEQ     EAEXIT      
      
      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      LEA     DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER
      
      ADD.L   #2,A2
      CLR.L   D2
      MOVE.L  (A2),D2
      MOVE.L  D2,BIN2A_VAL
      MOVE.L  #32,BIN2A_COUNT
      JSR     BIN2A_CONVERT
      
      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      BRA     EAEXIT
        

LONG001 ; branch
      MOVEM     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #4,(A2)
      MOVEM     (A7)+,A2
      
      CMP.B   #3,D7
      BEQ     ADDQLONG001
      
      ADDA.L    #2,A2
      
      LEA       DOLLAR_SIGN, A1 ; hex
      JSR       MOVEA1TOBUFFER
      
      ADD.L     D3,A2
      ;ADDA.W    #2, A2 ; read following word from memory

      MOVE.L    (A2),D6
      MOVE.L    D6, BIN2A_VAL  
      MOVE.L    #32, BIN2A_COUNT
      JSR       BIN2A_CONVERT
    
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER
    
      CMP.W     #101,D7
      BEQ       EAEXIT

      CMP.B   #100,D7
      BEQ     EAEXIT
    
      LEA       COMMA,A1
      JSR       MOVEA1TOBUFFER
        
      CMP.B   #1,D7
      BEQ     PRINTAABS_IMD

      ;MOVE.L    #2,D3
      SUB.W     #2,A2
      JSR       DECODEREGS


      ADDA.W    #2, A2 

      BRA       EAEXIT                    ; branch to exit   

DECODEREGS:

      ADD.L     #2,D3
      MOVE.W    (A2),D2
      ANDI.W    #$01C0,D2
      
      PEA       DONEREGS(PC) ; GO TO DONECHECKING AFTER RTS
      CMP.W     #0,D2      
      BEQ       PRINTDR
      CMP.W     #$0200,D2
      BEQ       PRINTAR
      CMP.W     #$0080,D2
      BEQ       PRINTADDDEREF
      CMP.W     #$0080,D2
      BEQ       PRINTA
      CMP.W     #$00C0,D2 
      BEQ       PRINTAPOSTI
      CMP.W     #$0100,D2 
      BEQ       PRINTAPRED
      CMP.W     #$01C0,D2
      BEQ       PRINTMEMADD

      

      MOVE.W  (A2),D6  
      MOVE.W  #4, D5
      JSR     BIN2A_CONVERT

PRINTAPRED:
      LEA       MINUS_SIGN,A1
      JSR       MOVEA1TOBUFFER
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      RTS  

PRINTAPOSTI:
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      LEA       PLUS_SIGN,A1
      JSR       MOVEA1TOBUFFER
      RTS  

      BRA       EAEXIT                    ; branch to exit   

PRINTA:
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      RTS  

DONEREGS:
      
      ;JSR       PRINTNUM
      ADD.L     #2,A2
      BRA       EAEXIT

EAERROR:
      LEA     EAERRORMSG, A1
      JSR     MOVEA1TOBUFFER
      RTS   

*-----------------------------SPECIAL SNOWFLAKES-------------------------------*

*-----------------------------MOVEM SUBROUTINES-------------------------------*

DECODEMOVEMEA:

        ;MOVEM.L D0-D7/A1/A3-A6,-(A7)
       MOVEM    A2,-(A7)
       LEA      startSpace,A2
       ADD.L    #2,(A2)
       MOVEM    (A7)+,A2 
MOVEMSET            DS.B 0 ; 0 if set bits, else 1
       
       MOVE.B      #1,RETURNATEND
       LEA      MOVEMSET,A5
       MOVE.B   #0,(A5)
       ;MOVE.B  #0,MOVEMMEMCOUNT
       ;MOVE.B  #0,MOVEMCOUNT
       ;MOVE.B  #0,MOVEMDIRECTION      
       
       MOVE.W   (A2)+,D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BEQ      MOVEMEA
       ;MOVE.B   #$1,MOVEMDIRECTION
       ;BRA      MOVEMEAMEM
        
MOVEMEAMEM:
       ADD.L   #2,A2
       move.b  #101,D7
       JSR     DECODEEA
        
*       LEA     COMMA,A1
*       JSR     MOVEA1TOBUFFER
*              
       SUB.W    #4,A2
       MOVE.W   (A2),D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BEQ      MOVEMEXIT
       
       LEA      COMMA,A1
       JSR     MOVEA1TOBUFFER
       
MOVEMEA:
       MOVE.L  startSpace,A2
       ADD.L   #2,A2  
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
       SUB.W    #4,A2
       MOVE.W   (A2)+,D3     ; opcode
       ANDI.W   #$0400, D3
       CMPI.W   #$0, D3
       BNE      MOVEMEXIT

       
       LEA      COMMA,A1
       JSR     MOVEA1TOBUFFER
       BRA      MOVEMEAMEM

;MOVEMCOMMAM
       ;CMP.B    #0, MOVEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMCOUNT
       ;LEA      COMMA,A1
       ;JSR     MOVEA1TOBUFFER
       ;BRA      MOVEMEAMEM
       
;MOVEMCOMMAR
       ;CMP.B    #0, MOVEMMEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMMEMCOUNT
       ;LEA      COMMA,A1
       ;JSR     MOVEA1TOBUFFER
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
      JSR     MOVEA1TOBUFFER

      MOVE.L   D4,D6   ; copy count to D6
      SUBI.L   #1, D6
      
      MOVE.L   D6, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER


      BRA      MOVEMEALOOP


PRINTMOVEMA:
      LEA     ADD_REG, A1

      JSR     MOVEA1TOBUFFER

      MOVE.L  D4,D6   ; copy count to D6
      SUBI.L  #9, D6
      
      MOVE.L   D6, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER


      BRA MOVEMEALOOP

PRINTSLASH

      LEA     SLASH, A1
      JSR     MOVEA1TOBUFFER
      BRA     PRINTMOVEM2

MOVEMEXIT:
      
      
      LEA     NEWLINE,A1
      JSR     MOVEA1TOBUFFER
      JSR     PRINTBUFFER
        
      ADDA.L  #4,A2
      BRA     LOOP
*-----------------------------END MOVEM SUBROUTINES-------------------------------*
      
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
      
      JSR     MOVEA1TOBUFFER

      BRA EAEXIT      
      
MOVEQEA: ;special case 
      MOVEM.L D0-D7/A1/A3-A6,-(A7)
      LEA       POUND,A1
      JSR       MOVEA1TOBUFFER

      LEA       DOLLAR_SIGN,A1
      JSR       MOVEA1TOBUFFER

      CLR.L     D1
      MOVE.W    (A2),D1  ; only move last byte
      ANDI.W    #$00FF,D1
      MOVE.L    D1,BIN2A_VAL
      MOVE.L    #8,BIN2A_COUNT
      JSR       BIN2A_CONVERT  
        
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER
      
      LEA       COMMA,A1
      JSR       MOVEA1TOBUFFER

      LEA       DATA_REG,A1
      JSR       MOVEA1TOBUFFER

      MOVE.W    (A2),D1
      ANDI.W    #$0E00,D1
      LSR.W     #8,D1
      LSR.W     #1,D1
      
      MOVE.L    D1,BIN2A_VAL
      MOVE.L    #4,BIN2A_COUNT
      JSR       BIN2A_CONVERT
      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER
      
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
*      JSR     MOVEA1TOBUFFER
* 
*      BRA     EAEXIT        


PRINTADDIWORD:
      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM   (A7)+,A2
      
      MOVE.L  (A2),BIN2A_VAL  
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT


      LEA      POUND,A1
      JSR     MOVEA1TOBUFFER
      
      LEA      DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER
      
  *   ADDA.W   #4, A1 
      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER
      
      LEA      COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      MOVE.L   #2,D3
      MOVE.B   #101,D7
      JSR DECODEEASIMPLE
      
      ADDA.L   #2,A2
        
      BRA     EAEXIT     

PRINTADDILONG: 
      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
      MOVEM   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #4,(A2)
      MOVEM   (A7)+,A2
     
      ADDA.W  #2,A2
      MOVE.L  (A2),BIN2A_VAL
      SUBA.W  #2,A2  
      MOVE.L  #32, BIN2A_COUNT
      JSR     BIN2A_CONVERT

  *   ADDA.W   #8, A1 
      LEA      POUND,A1
      JSR     MOVEA1TOBUFFER
      
      LEA      DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER
      
  *   ADDA.W   #4, A1 
      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER
      
      LEA      COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      MOVE.L   #4,D3
      MOVE.B   #101,D7
      JSR DECODEEASIMPLE
      
      ADDA.L   #4,A2


      BRA     EAEXIT     

PRINTROTATIONEA:
      MOVEM.L D0-D7/A1/A3-A6,-(A7)
      MOVE.W  (A2),D2
      ANDI.W  #$0020,D2
      CMPI.W  #0,D2
      BEQ     PRINTROTPOUND
      LEA     DATA_REG,A1
      JSR     MOVEA1TOBUFFER
      
CONTROTEA:
      MOVE.W   (A2),D2
      ANDI.W   #$0E00,D2
      LSR.W    #8,D2
      LSR.W    #1,D2
      
      MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER
      
      LEA      COMMA,A1
      JSR     MOVEA1TOBUFFER
      
      LEA     DATA_REG,A1
      JSR     MOVEA1TOBUFFER

      MOVE.W  (A2),D2
      ANDI.W  #$0005,D2

   ;   ADDI.W  #1, D2

      MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits 
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER

      BRA      EAEXIT

PRINTROTPOUND:
      LEA    POUND,A1
      JSR     MOVEA1TOBUFFER
      
      BRA CONTROTEA



EAEXIT: ; SET ERROR FLAG TODO
        MOVEM.L (A7)+,D0-D7/A1/A3-A6 ; put everything back on the stack
        MOVE.L  #0,D7
        
        CMP.B   #1,RETURNATEND
        BEQ     RETURNEA

        
        LEA     NEWLINE,A1
        JSR     MOVEA1TOBUFFER
        JSR     PRINTBUFFER
        
        
        
        BRA     LOOP                  ; return to sender

*---------------BINARY TO ASCII CONVERSION -------------------------------
BIN2A_VAL    DS.L 32  ; input number for our conversion
BIN2A_BUFFER DS.B 256 ; buffer for ascii data
BIN2A_COUNT  DS.L 32  ; number of bits to convert (must be div by 4)

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
