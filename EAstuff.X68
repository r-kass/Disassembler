*-----------------------------------------------------------
* Title      : EA stuff
* Written by :
* Date       :
* Description: (1) recieve 6 bits 
*                   - length
*                   - mode 
*                   - register
*              (2) prepare for display 
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

* -----------------Decode recieved 6 bits ----------------
* assumes A0 available and data is currently in D0
        
        CLR.L   A0
*       LEA     EAMODES,A0  ; store reference for comparison
        MOVE.L  D0, D2      ; get copy of all 6 bits
        ASR.W   #3, D2      ; bits shifted out to focus on 3 bits

* loop to compare all eamodes

EADECLOOP
       LEA    #$0, A1   ; counter for loop
       CMP    D2, $000
       BEQ    EAMODE000

       CMP    D2, $001
       BEQ    EAMODE001
        
       CMP    D2, $010
       BEQ    EAMODE010
       
       CMP    D2, $011
       BEQ    EAMODE011

       CMP    D2, $100
       BEQ    EAMODE100

       CMP    D2, $101
       BEQ    EAMODE101

       CMP    D2, $111
       BEQ    EAMODE111

       ADDI.B  #$1, A1    ; increment counter
       CMPI    #$7,A1     ; break loop here 
       BEQ     ERROR      ; EXCEPTION                        ;???????????????????
       BRA     EADECLOOP


* -------------- EA MODES AND REGISTERS ---------------
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


EAMODE000: *------- Data register direct : send data directly to buffer -------------
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 
        RTS 
        
EAMODE001: *------- Address register direct : send address register to buffer -------
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 
        RTS 

EAMODE010: *--------- Address register indirect: sends address value ----------------

        ; TODO take care of first parenthesis
         *** MOVE.W  #PARENTHESIS_1, ??

        
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
         *** MOVE.W  #PARENTHESIS_2, ??

        RTS 


EAMODE011: * --------- Address register indirect with post increment ----------------

        ; TODO take care of first parenthesis
         *** MOVE.W  #PARENTHESIS_1, ??

        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
         *** MOVE.W  #PARENTHESIS_2, ??

        ; TODO take care of plus sign
         *** MOVE.W  #PLUS_SIGN, ??

        RTS 

EAMODE100: *--------- Address register indirect with pre decrement ---------------

        ; TODO take care of minus sign
         *** MOVE.W  #MINUS_SIGN, ??
        
        ; TODO take care of first parenthesis
         *** MOVE.W  #PARENTHESIS_1, ??

        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
         *** MOVE.W  #PARENTHESIS_2, ??

        RTS 


EAMODE101: *----------  Address register indirect with displacement -----------------
        ; TODO get dollar sign
        *** MOVE.W  #DOLLAR_SIGN, ??
        
        ; TODO: how to get 8-bit extension word?
        MOVE.L  D1, D3       ; place in D3
        CLR.L   D4
        MOVE.B  #4, D4       ; store number of bytes 
        
        ; TODO convert to ASCII - branch??
        ; TODO move hex value to address reg
        ; TODO store hex to buffer
        
        ;TODO get open parentheses
        *** MOVE.W  #PARENTHESIS_1, ??

        ;store address in buffer
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ;TODO get comma sign
        
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
        
        
        ;TODO get close parentheses
        *** MOVE.W  #PARENTHESIS_2, ??


*EAMODE110: *-------Address reg indirect with index [8-bit, base];Memory indirect [postindexed, preindexed] ---
    
    ; i dont think i need these? idk
    *8BIT  ;branch
    *BASE  ;branch
    *MIPOSTINDEX    ;branch
    *MIPREINDEX     ;branch
    
*EAMODE111: 

    *ADSHORT ;branch

    *ADLONG ;branch
    
    
    
    
    
    
*EAREG000:

    *WORD ;branch

    *LONG ;branch


    ; TODO STACK POINTER?
    
    ; TODO get dollar sign
        *** MOVE.W  #DOLLAR_SIGN, ??
    
    ; TODO get word data, back up to D4
    
    CLR.L   D3      
    MOVE.B  #4, D3  ; get length of hex value
    ;TODO convert to ASCII
    
    
    ;TODO add to buffer
    
    ; pop from stack pointer
    
    RTS
    


*EAREG100 









*ERROR HANDLING?
*BUFFERMESSENGER?





*---------------------- Symbols ----------------------------

PARENTHESIS_1       DC.B        '(', 0
PARENTHESIS_2       DC.B        ')', 0
PLUS_SIGN           DC.B        '+', 0
MINUS_SIGN          DC.B        '-', 0
COMMA               DC.B        ',', 0
DOLLAR_SIGN         DC.B        '$', 0

* Put variables and constants here

    END    START        ; last line of source

    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
