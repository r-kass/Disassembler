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

 loop to compare to all eamodes

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
* I guess i don't need these anymore.... idk
*EAMODES
*
*       JMP      EAMODE000  ; Data register direct
*       JMP      EAMODE001  ; Address register direct
*       JMP      EAMODE010  ; Address register indirect
*       JMP      EAMODE011  ; Address register indirect with postincrement
*       JMP      EAMODE100  ; Address register indirect with predecrement
*       JMP      EAMODE101  ; Address register indirect with displacement
*       JMP      EAMODE110  ; Address register indirect with index [8-bit, base]
*                            ; Memory indirect [postindexed, preindexed]
*       JMP      EAMODE111  ; Absolute data addressing [short, long]
*
*EAREGISTERS
*
*       JMP      EAREG000   ; Absolute data addressing [short, long]
*       JMP      EAREG100   ; Immediate addressing
*


*EAMODE000: ------- Data register direct : send data directly to buffer -------------
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 
        RTS 
        
*EAMODE001: ------- Address register direct : send address register to buffer -------
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 
        RTS 

*EAMODE010: --------- Address register indirect: sends address value ----------------

        ; TODO take care of first parenthesis
        
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
        
        RTS 


*EAMODE011: --------- Address register indirect with post increment ----------------

        ; TODO take care of first parenthesis
        
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
        
        ; TODO take care of plus sign
        
        RTS 

*EAMODE100: --------- Address register indirect with pre decrement ---------------

        ; TODO take care of minus sign
        
        ; TODO take care of first parenthesis
        
        MOVE     D2, D1
        ANDI     #$111, D0     ; compares to 111 to get register value
        BSR      bufferMessanger  :send data??? i think this is I/O stuff 

        ; TODO take care of last perenthesis
        
        RTS 


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

*ERROR ???????????
*BUFFERMESSENGER ???????????



* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
