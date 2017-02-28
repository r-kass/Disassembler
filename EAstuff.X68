*-----------------------------------------------------------
* Title      : EA stuff
* Written by :
* Date       :
* Description: right now, does not handle data from RTS, NOP, MOVEQ
* ADDI, MOVEM, Bcc?
* 
* Key for edits:
*   - assumptions made: **************assumption*************
*   - to complete: 
*
*   will be called from print functions in Opcode to be handled
*   differently (specifically for RTS, NOP, MOVEQ)
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
*       JMP      EAREG100   ; Immediate addressing
*

*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

DECODEEASIMPLE: * -----------------Decode recieved 6 bits ----------------
        ; for all except RTS, NOP, MOVEQ, ADDI, MOVEM, Bcc
        ; data curently in (A2)
        
        CLR.W   D1
        MOVE.W  (A2),D1      ; get copy of all 16 bits
        MOVE.W  (A2),D2
        LSL.W   #10, D1       ; bits shifted out to focus on bits 11-13
        LSR.W   #3, D1
        BRA     EADECMODE
        LSL.W   #13, D2       ; bits shifted out to focus on last 3 bits
        
        ; mode is now in D1
        ; register is now in D2

*TODO
*DECODEEASPECIAL:

EADECMODE: *--------------Loop to compare all EAModes-----------------

************* assumes A1 is available ********************

       LEA    #$0, A1   ; counter for loop
       CMP    D1, #%0000000000000000
       BEQ    EAMODE000

       CMP    D1, #%0010000000000000
       BEQ    EAMODE001
        
       CMP    D1, #%0100000000000000
       BEQ    EAMODE010
       
       CMP    D1, #%0110000000000000
       BEQ    EAMODE011

       CMP    D1, #%1000000000000000
       BEQ    EAMODE100

       CMP    D1, #%1010000000000000
       BEQ    EAMODE101

       CMP    D1, #%1110000000000000
       BEQ    EAMODE111

       ADDI.B  #$1, A1    ; increment counter
       CMPI    #$7,A1     ; break loop here 
       BEQ     ERROR      ; TODO
       BRA     EADECLOOP


EAMODE000: *------- Data register direct -------------
        LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   
        RTS
        
EAMODE001: *------- Address register direct : send address register to buffer -------
        LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   
        RTS

EAMODE010: *--------- Address register indirect: sends address value ----------------

        LEA     #PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        
        LEA     #PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15  
  
        RTS 


EAMODE011: * --------- Address register indirect with post increment ----------------

        LEA     #PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    

        LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        LEA #PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15    

        LEA  #PLUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    

        RTS 

EAMODE100: *--------- Address register indirect with pre decrement ---------------

        LEA     #MINUS_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        LEA     #PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    

        LEA     D1, A1
        MOVE.B  #14,D0
        TRAP    #15   

        LEA #PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15    

        RTS 

********************************TODO***********************************************
EAMODE101: *----------  Address register indirect with displacement -----------------
        LEA  #DOLLAR_SIGN, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        ; TODO: how to get 8-bit extension word?
        MOVE.L  D1, D3       ; place in D3
        CLR.L   D4
        MOVE.B  #4, D4       ; store number of bytes 
        
        ; TODO convert to ASCII - branch
        ; TODO move hex value to address reg
        ; TODO store hex to buffer
        
        LEA  #PARENTHESIS_1, A1
        MOVE.B  #14,D0
        TRAP    #15    

        ;store address in buffer
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        LEA #COMMA, A1
        MOVE.B  #14,D0
        TRAP    #15    
        
        ; get index register
        MOVE.L   D5, D1         ; store value in D1- TODO check if D5 is correct
        ANDI     #$F000, D1     ; get first byte only to evaluate
        ASL.L    #$1000, D1     ; shift to the farthest right
        ASL.L    #$0100, D1     ; get first bit
        ;TODO send byte to buffer
     
        ;TODO see if word or long
        MOVE.L   D5, D1 
        ANDI     #$0F00, D1     ; get byte that represents size
        ASL.L    #$1000, D1     ; shift to farthest right
        CMPI.B   #0, D1         ; compare to see if the length is word
        ; TODO store in buffer??
        *** BEQ     ???
*        ; TODO what to do if other size? flag?
        
        ;TODO ADD DATA TYPES TO BUFFER
        
        
        LEA  #PARENTHESIS_2, A1
        MOVE.B  #14,D0
        TRAP    #15    

********************************TODO***********************************************
EAMODE110: *-------Address reg indirect with index [8-bit, base];Memory indirect [postindexed, preindexed] ---
    
    ; i dont think i need these
    *8BIT  ;branch
    *BASE  ;branch
    *MIPOSTINDEX    ;branch
    *MIPREINDEX     ;branch
    

EAMODE111: * ------------ Absolute short, long ---------------------------------                                
      CMP.B   #%100, D2
      BEQ     100IMMED        
      CMP.B   #%000, D2
      BEQ     000SHORT
      CMP.B   #%001, D2
      BEQ     001LONG
      CMP.B   #%011, D2
      RTS        
      CMP.B   #%101, D2
      RTS
      CMP.B   #%110, D2
      RTS
      CMP.B   #%111, D2
      RTS
    
100IMMED ; branch
      LEA     #POUND, A1
      MOVE.B  #14,D0
      TRAP    #15    
        
      LEA     #DOLLAR, A1 ;immediate data - hex
      MOVE.B  #14,D0
      TRAP    #15    
      
      ***TODO finish  


000SHORT ; branch
      LEA     #DOLLAR, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #2, A2 ; read following word from memory
      ADDA.W  #2, A1 ; increment address
      MOVE.W  (A3),D6  
      MOVE.W  #4, D5
      
      ;TODO CONVERT TO HEX AND PRINT
      
      RTS
      
     

001LONG ; branch
      LEA     #DOLLAR, A1 ; hex
      MOVE.B  #14,D0
      TRAP    #15  
      
      ADDA.W  #4, A2 ; read following word from memory
      ADDA.W  #4, A1 ; increment address
      MOVE.W  (A3),D6  
      MOVE.W  #8, D5
      
      ;TODO CONVERT TO HEX AND PRINT
      
      RTS
      


*---------------------- Symbols ----------------------------

PARENTHESIS_1       DC.B        '(', 0
PARENTHESIS_2       DC.B        ')', 0
PLUS_SIGN           DC.B        '+', 0
MINUS_SIGN          DC.B        '-', 0
COMMA               DC.B        ',', 0
DOLLAR_SIGN         DC.B        '$', 0
POUND               DC.B        '#', 0

* Put variables and constants here

    END    START        ; last line of source

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
