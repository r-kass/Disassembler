*-----------------------------------------------------------
* Title      : EA portion of disassembler
* Written by : Jesse Llona, Ruby Kassala
* Date       : 2017.03.09
* Description:  The following functions are called from the
*               Opcode.X68 file to disassemble EA portion.
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

; the following decodes EA for general cases

DECODEEA:
    MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
    CLR.L   D3
    BRA DECODEEASIMPLE

*----------------------------START GENERAL CASES-------------------------------*

DECODEEASIMPLE:
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



EADECMODE:; loop to compare all EA modes

       MOVE.L  #$0, D4   ; counter for loop
       CMP.B   #%000, D1 ; data register direct
       BEQ    EAMODE000

       CMP.B  #%001, D1  ; address register direct
       BEQ    EAMODE001

       CMP.B  #%010, D1   ; address register indirect
       BEQ    EAMODE010

       CMP.B  #%011, D1   ; address register indirect with postincrement
       BEQ    EAMODE011

       CMP.B  #%100, D1   ; address register indirect with predecrement
       BEQ    EAMODE100

       CMP    #%111, D1   ; absolute data addressing
       BEQ    EAMODE111

       BRA     EAERROR

; to print only last 3 bits for mode 000
PRINTLAST3ANDCONT100:
        MOVE.W  (A2),D2
        ANDI.W  #7,D2                   ; bitmsk
        MOVE.L  D2,BIN2A_VAL            ; to convert to acii
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT100ADDQ

; to print only last 3 bits for mode 010
PRINTLAST3ANDCONT010:
        MOVE.W  (A2),D2                 ; copy address in A2
        ANDI.W  #7,D2                   ; bitmask
        MOVE.L  D2,BIN2A_VAL            ; convert
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT010ADDQ

; to print only last 3 bits for mode 011
PRINTLAST3ANDCONT011:
        MOVE.W  (A2),D2                 ; copy address in A2
        ANDI.W  #7,D2                   ; bitmask
        MOVE.L  D2,BIN2A_VAL            ; convert
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     CONT011ADDQ

; to print only last 3 bits and exit
PRINTLAST3ANDEXIT:
        MOVE.W  (A2),D2                 ; copy address in A2
        ANDI.W  #7,D2                   ; bitmask
        MOVE.L  D2,BIN2A_VAL            ; convert
        MOVE.L  #4,BIN2A_COUNT
        JSR     BIN2A_CONVERT
        LEA     BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER
        BRA     EAEXIT

EAMODE000:  ; data register direct
        BRA     ADDQEA000           ; special case for ADDQ
NOTADDQ000:                         ; if not ADDQ branch - general case
        LEA     DATA_REG, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDEXIT

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR      MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     RETURNEA

        LEA     COMMA,A1              ; send comma to buffer
        JSR     MOVEA1TOBUFFER

        PEA     CONTINMODE000V2(PC)   ; push ea onto stack
        CMP.B   #4,D7
        BEQ     PRINTDEA

        CMP.B    #1,D7
        BEQ      PRINTA000

        SUB.L   #4,D3
        PEA     END000(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS            ; decode registers if modes are completed
        RTS

END000:
        SUB.L   #2,A2
        BRA EAEXIT

CONTMODE000:
        JSR     MOVEA1TOBUFFER

CONTINMODE000V2:
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2            ; check last 3 bits by mask
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR      MOVEA1TOBUFFER

       ; CMP.B    #2,D7               ; match to D7 value set in opcode
       ; BEQ      MOVEEA
        BRA EAEXIT                    ; branch to exit

PRINTA000:
        LEA     ADD_REG,A1
        BRA     CONTMODE000

PRINTDEA:                             ; print D and RTS
        LEA       DATA_REG, A1
        JSR       MOVEA1TOBUFFER
        RTS

EAMODE001:  ; address register direct
        BRA     ADDQEA001
NOTADDQ001:
        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     PRINTLAST3ANDEXIT

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA     BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        CMP.B   #3,D7
        BEQ     EAEXIT

        CMP.B   #100,D7         ; match D7 to value set in opcode
        BEQ     EAEXIT          ; exit if EA is completed

        LEA      COMMA,A1
        JSR     MOVEA1TOBUFFER

        PEA     CONTINMODE001V2(PC)
        CMP.B   #4,D7
        BEQ     PRINTDEA

        CMP.B    #1,D7          ; match D7 to value set in opcode
        BEQ      PRINTA001
        CMP.B    #2,D7

        SUB.L   #4,D3
        PEA     END001(PC)
        CMP.B   #2,D7           ; match D7 to value set in opcode
        BEQ     DECODEREGS
END001:
        SUB.L   #2,A2           ; end address register direct
        BRA EAEXIT
CONTMODE001:
        JSR     MOVEA1TOBUFFER

CONTINMODE001V2:
        MOVE.W   (A2),D2        ; subroutine helper for buffer storage
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR      MOVEA1TOBUFFER

        BRA EAEXIT                    ; branch to exit

PRINTA001:
        LEA     ADD_REG,A1            ; print A without RTS
        BRA     CONTMODE000



EAMODE010: ; address register indirect: sends address value
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


        CMP.B   #3,D7                 ; not supported
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT


        LEA     COMMA,A1
        JSR     MOVEA1TOBUFFER

        PEA     CONTINMODE010V2(PC)
        CMP.B   #4,D7
        BEQ     PRINTDEA

        CMP.B   #1,D7
        BEQ     PRINTA010


        SUB.L   #4,D3
        PEA     END010(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS            ; if D7 flag is equal to 2, decode reg
END010:
        SUB.L   #2,A2
        BRA EAEXIT                    ; branch to exit

CONTMODE010:
        JSR     MOVEA1TOBUFFER

CONTINMODE010V2:
        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2            ; bitmask
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR      MOVEA1TOBUFFER

        BRA EAEXIT

PRINTA010:
        LEA     ADD_REG,A1
        BRA     CONTMODE010

EAMODE011:
        BRA     ADDQEA011
NOTADDQ011: ;address register indirect with post increment

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

        PEA     CONTINMODE011V2(PC)
        CMP.B   #4,D7
        BEQ     PRINTDEA

        CMP.B   #1,D7
        BEQ     PRINTA011

        SUB.L   #4,D3
        PEA     END011(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END011:
        SUB.L   #2,A2                 ; move address back by 2
        BRA EAEXIT                    ; before exiting

CONTMODE011:
        JSR     MOVEA1TOBUFFER
CONTINMODE011V2:
        MOVE.W   (A2),D2
        LSR.W    #8,D2              ; shift right by 9
        LSR.W    #1,D2
        ANDI.W   #$0007,D2
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR     MOVEA1TOBUFFER

         BRA EAEXIT

PRINTA011: ;address register indirect with post increment
        LEA     ADD_REG,A1
        BRA     CONTMODE011

EAMODE100: ; address register indirect with pre decrement
        BRA     ADDQEA100
NOTADDQ100:                          ; normal case
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

        CMP.B   #3,D7           ; not supported
        BEQ     EAEXIT
        CMP.B   #101,D7
        BEQ     EAEXIT
        CMP.B   #100,D7
        BEQ     EAEXIT

        LEA     COMMA,A1
        JSR     MOVEA1TOBUFFER

        PEA     CONTINMODE100V2(PC)
        CMP.B   #4,D7
        BEQ     PRINTDEA

        CMP.B   #1,D7
        BEQ     PRINTA100

        SUB.L   #4,D3
        PEA     END100(PC)
        CMP.B   #2,D7
        BEQ     DECODEREGS
END100:
        SUB.L   #2,A2           ; move back by 2
        BRA EAEXIT

CONTMODE100:
        JSR     MOVEA1TOBUFFER

CONTINMODE100V2:
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
      BEQ     IMMED100                  ; immediate data
      CMP.B   #%000, D2
      BEQ     SHORT000                  ; short length
      CMP.B   #%001, D2
      BEQ     LONG001                   ; long length
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
      CMP.B   #3,D7                     ; match to D7 value set in opcode
      BNE     NOTADDQ100
      MOVE.W  #$100,D6
      BRA     ADDQEA

ADDQEA011:                              ; following branches check if ADD Q
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
ADDQEA:                                 ; perform ADDQ special case for EA

      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER

      MOVE.W  (A2),D2
      ANDI.W  #$0E00,D2
      LSR.W   #8,D2                     ; shift right by 8 bits
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

      CMP.W   #$000,D6                 ; compare bits to see where to branch
      BEQ     NOTADDQ000
      CMP.W   #$010,D6
      BEQ     NOTADDQ010
      CMP.W   #$011,D6
      BEQ     NOTADDQ011
      CMP.W   #$100,D6
      BEQ     NOTADDQ100
      CMP.W   #$001,D6
      BEQ     NOTADDQ001

RETURNEA:    ; to be used by EA branches to return to sender
      MOVE.B  #0,RETURNATEND
      RTS



IMMED100 ; immediate data
      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER

      LEA     DOLLAR_SIGN, A1 ;immediate data - hex
      JSR     MOVEA1TOBUFFER

      CLR.L   D5
      MOVE.W  (A2),D4


      PEA     BACKTOIMMED100(PC)
      CMP.W   #4,D7
      BEQ     ROLBACK4

BACKTOIMMED100
      ROL.W   #4,D4
      ANDI.W  #$0007,D4
      CMP.B   #4,D4      ;if 1- word; if 2- long
      BEQ     WORDIMMED
      CMP.B   #1,D4
      BEQ     LONGIMMED
      BRA     BIMMED
ROLBACK4:
      ROR.W   #4,D4
      RTS


BIMMED: ; does same as word
WORDIMMED
      MOVEM.L   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM.L   (A7)+,A2

      ADDA.W  #2, A2           ;  read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6

      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT ; copy number of bits
      JSR     BIN2A_CONVERT

      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      CMP.B   #100,D7
      BEQ     EAEXIT

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER

      SUB.W   #2,A2             ; move pointer back
      PEA     CONTINWORDIMMED(PC)
      CMP.B   #4,D7
      BEQ     PRINTDR           ; print D with branch
CONTINWORDIMMED
      CMP.B   #4,D7
      BEQ     EAEXIT
      ;MOVE.B  #2,D3
      CMP.W   #1,D7
      BEQ     PRINTIMMEDA


      JSR     DECODEIMEDREGS


      ADDA.W  #2, A2  ; move along 32 bit extension


      BRA     EAEXIT                  ; branch to exit


LONGIMMED
      MOVEM.L   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #4,(A2)       ; read following long from memory
      MOVEM.L   (A7)+,A2

      ADDA.W  #2, A2        ; move along A2
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

      SUB.W   #2,A2

      PEA     CONTINLONGIMMED(PC)
      CMP.B   #4,D7
      BEQ     PRINTDR

CONTINLONGIMMED
      CMP.B   #4,D7                 ; check with flag bit
      BEQ     EAEXIT

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

      MOVEM.L   A2,-(A7)            ; predecrement A7 before movem
      LEA     startSpace,A2       ; load start to A2
      ADD.L   D3,(A2)
      MOVEM.L   (A7)+,A2

      SUB.L   #2,A2
      LEA     ADD_REG,A1          ; to print A
      JSR     MOVEA1TOBUFFER
      MOVE.W   (A2),D2            ; copy data to D2
      LSR.W    #8,D2              ; shift right by 9
      LSR.W    #1,D2
      ANDI.W   #$0007,D2
      MOVE.L   D2, BIN2A_VAL
      MOVE.L   #4, BIN2A_COUNT
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER,A1
      JSR      MOVEA1TOBUFFER

      BRA EAEXIT


PRINTALONGIMMED:
      SUB.L   #2,A2             ; read following word from memory
      LEA     ADD_REG,A1

      JSR     MOVEA1TOBUFFER
      MOVE.W   (A2),D2
      LSR.W    #8,D2
      LSR.W    #1,D2
      ANDI.W   #$0007,D2        ; bitmask
      MOVE.L   D2, BIN2A_VAL
      MOVE.L   #4, BIN2A_COUNT
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      MOVEM.L     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)         ; add 2 to address of A2
      MOVEM.L     (A7)+,A2

      BRA EAEXIT

DECODEIMEDREGS:
      MOVE.W    (A2),D2
      ANDI.W    #$01C0,D2       ; mask

      PEA       DONELONG(PC)    ; go to donechecking after rts
      CMP.W     #0,D2           ; check if data reg
      BEQ       PRINTDR
      CMP.W     #$0200,D2       ; check if A
      BEQ       PRINTAR
      CMP.W     #$0080,D2       ; check if address reg
      BEQ       PRINTADDDEREF
      CMP.W     #$00C0,D2       ; check if post increment
      BEQ       PRINTADDPOSTINC
      CMP.W     #$0100, D2      ; check if pre decrement
      BEQ       PRINTADDPREDEC
      CMP.W     #$01C0,D2       ; check if immediate
      BEQ       PRINTMEMADD

; print immediate data with dollar sign using buffer
PRINTMEMADD
      MOVEM.L     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)
      MOVEM.L     (A7)+,A2

      LEA       DOLLAR_SIGN,A1
      JSR       MOVEA1TOBUFFER

      MOVE.W    (A2),D2
      ANDI.W    #$0E00,D2
      CMP.W     #$0200,D2
      BEQ       PRINTMEMADDLONG

      ADD.L     D3,A2
      ADD.L     #4,A2
      MOVE.W    (A2),D2
      MOVE.L    D2,BIN2A_VAL
      MOVE.L    #16,BIN2A_COUNT
      JSR       BIN2A_CONVERT

      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER

      RTS

; prints longword of data
PRINTMEMADDLONG:
      MOVEM.L     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #2,(A2)
      MOVEM.L     (A7)+,A2

      ADD.L     D3,A2
      ADD.L     #4,A2
      MOVE.L    (A2),D2
      MOVE.L    D2,BIN2A_VAL
      MOVE.L    #32,BIN2A_COUNT
      JSR       BIN2A_CONVERT

      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER

      ADD.L     #4,A2

      RTS

; prints post increment
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

; prints pre decrement
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

; prints number value
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

; prints address reference
PRINTADDDEREF:
      LEA       PARENTHESIS_1,A1
      JSR       MOVEA1TOBUFFER

      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER


      JSR       PRINTNUM

      LEA       PARENTHESIS_2,A1
      JSR       MOVEA1TOBUFFER
      RTS

; prints address register
PRINTAR:
      LEA       ADD_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      RTS

; prints direct register
PRINTDR:
      LEA       DATA_REG,A1
      JSR       MOVEA1TOBUFFER
      JSR       PRINTNUM
      RTS

; after longword
DONELONG:
      ADD.L     #4,A2
      BRA       EAEXIT

; fill D2 with 1111
D2FILL:
      MOVE.W  #8,D2
      RTS

; add Q for word length
ADDQSHORT000:

      LEA     POUND,A1
      JSR     MOVEA1TOBUFFER

      CLR.L   D2
      MOVE.W  (A2),D2         ; copy into D2
      ROL.W   #7,D2
      ANDI.W  #7,D2

      PEA     RETAQS(PC)
      CMP.W   #0,D2
      BEQ     D2FILL          ; fill with 1111

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
      MOVEM.L   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM.L   (A7)+,A2

      CMP.B   #3,D7
      BEQ     ADDQSHORT000

      LEA     DOLLAR_SIGN, A1 ; hex
      JSR     MOVEA1TOBUFFER

      ADD.L   D3,A2
      ADDA.W  #2, A2          ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6
      MOVE.L  #0, BIN2A_VAL   ; clear value and load D6
      MOVE.L  D6, BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT ; number of bits to convert
      JSR     BIN2A_CONVERT


      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      CMP.W     #101,D7       ; check if stuff to decode
      BEQ       EAEXIT

      CMP.B   #100,D7
      BEQ     EAEXIT

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER

      SUB.L   #2,A2
      PEA     CONTINSHORT000(PC)
      CMP.B   #4,D7
      BEQ     PRINTDR

CONTINSHORT000:
*      SUB.L   #2,A2
      CMP.B   #4,D7
      BEQ     EAEXIT

      CMP.B   #1,D7
      BEQ     PRINTAABS_IMD       ; print absolute immediate

      SUB.L   #2,D3
      JSR     DECODEREGS

      ;SUB.W   #2,A2
      ;ADDA.W  #2, A2  ; move along 16 bit extension

      BRA     EAEXIT                    ; branch to exit
*
*PRINTLAST3ANDEXIT
*        CLR.L   D2
*        MOVE.W  (A2),D2
*        AND.W   #$0007,D2
*        MOVE.L  D2,BIN2A_BUFFER
*        MOVE.L  #4,BIN2A_COUNT
*        JSR     BIN2A_CONVERT
*        LEA     BIN2A_BUFFER,A1
*        JSR     MOVEA1TOBUFFER
*        BRA     EAEXIT

PRINTAABS_IMD:              ; absolute immediate

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
      MOVEM.L     A2,-(A7)
      LEA       startSpace,A2
      ADD.L     #4,(A2)
      MOVEM.L     (A7)+,A2

      CMP.B   #3,D7
      BEQ     ADDQLONG001

      ADDA.L    #2,A2

      LEA       DOLLAR_SIGN, A1 ; hex
      JSR       MOVEA1TOBUFFER

      ADD.L     D3,A2
      ;ADDA.W    #2, A2         ; read following word from memory

      MOVE.L    (A2),D6
      MOVE.L    D6, BIN2A_VAL
      MOVE.L    #32, BIN2A_COUNT
      JSR       BIN2A_CONVERT

      LEA       BIN2A_BUFFER,A1
      JSR       MOVEA1TOBUFFER

      CMP.W     #101,D7
      BEQ       EAEXIT

      CMP.B     #100,D7
      BEQ       EAEXIT

      LEA       COMMA,A1
      JSR       MOVEA1TOBUFFER

      SUB.W     #2,A2
      PEA       CONTINLONG001(PC)
      CMP.B     #4,D7
      BEQ       PRINTDR

CONTINLONG001:

      CMP.B    #4,D7
      BEQ      EAEXIT

      CMP.B    #1,D7
      BEQ      PRINTAABS_IMD

      ;MOVE.L   #2,D3
      JSR       DECODEREGS


      ADDA.W    #2, A2

      BRA       EAEXIT                    ; branch to exit

DECODEREGS:

      ADD.L     #2,D3
      MOVE.W    (A2),D2
      ANDI.W    #$01C0,D2

      PEA       DONEREGS(PC) ; GO TO DONECHECKING AFTER RTS
      CMP.W     #0,D2        ; check if data register
      BEQ       PRINTDR
      CMP.W     #$0200,D2    ; check if address register
      BEQ       PRINTAR
      CMP.W     #$0080,D2    ; check if address reference
      BEQ       PRINTADDDEREF
      CMP.W     #$0080,D2    ; to print A
      BEQ       PRINTA
      CMP.W     #$00C0,D2    ; check if post increment
      BEQ       PRINTAPOSTI
      CMP.W     #$0100,D2    ; check if pre-decrement
      BEQ       PRINTAPRED
      CMP.W     #$01C0,D2    ; check if immediate address
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
      BRA       printUNKNOWN
MOVEMSET            DS.B 2 ; 0 if set bits, else 1

*-----------------------------END GENERAL CASES-------------------------------*
*-------------------------------SPECIAL CASES---------------------------------*
FLIPA2WORD:                           ; to change calue to word
        MOVEM.L D0-D7,-(A7)
        MOVE.W  (A2),D2
        MOVE.L  #0,D3
        MOVE.L  #0,D0
FLIPA2WORDLOOP:
        LSR.W   #1,D2
        BCS     ADDTOD3FORFLIP
CONTINUEFLIPA2WORDLOOP:              ; loop through to add to A2 address
        LSL.W   #1,D3

        ADD.L   #1,D0
        CMP.L   #$F,D0
        BLT     FLIPA2WORDLOOP

        MOVE.W  D3,(A2)

        MOVEM.L (A7)+,D0-D7
        RTS

ADDTOD3FORFLIP:
        ADD.W   #1,D3
        BRA      CONTINUEFLIPA2WORDLOOP

DECODEMOVEMEA:
        ADD.L   #2,startSpace
        MOVEM.L D0-D7/A1/A3-A6,-(A7)
        MOVE.W   (A2),D3                ; opcode
        ANDI.W   #$0400, D3             ; mask
        CMPI.W   #$0, D3
        BEQ      MOVEMREGTOMEM
        BRA      MOVEMMEMTOREG

MOVEMREGTOMEM
        ADD.L    #2,A2
        JSR      FLIPA2WORD
        JSR      MOVEMEAREGS
        SUB.L    #2,A2

        LEA      COMMA,A1
        JSR      MOVEA1TOBUFFER

        SUB.L    #2,A2                  ; subtract
        MOVE.W   (A2),D2
        JSR      MOVEMEAMEMORY
        BRA      EAEXIT

MOVEMMEMTOREG

        MOVE.W   (A2),D2                ; copy into D2
        JSR      MOVEMEAMEMORY

        LEA      COMMA,A1
        JSR      MOVEA1TOBUFFER

        ADD.L   #2,A2
        JSR      MOVEMEAREGS


        BRA      EAEXIT
*       MOVE.B      #1,RETURNATEND
*       LEA      MOVEMSET,A5
*       MOVE.B   #0,(A5)
*       ;MOVE.B  #0,MOVEMMEMCOUNT
*       ;MOVE.B  #0,MOVEMCOUNT
*       ;MOVE.B  #0,MOVEMDIRECTION
*
*       MOVE.W   (A2)+,D3     ; opcode
*       ANDI.W   #$0400, D3
*       CMPI.W   #$0, D3
*       BEQ      MOVEMEA
*       ;MOVE.B   #$1,MOVEMDIRECTION
*       ;BRA      MOVEMEAMEM
*
MOVEMEAMEMORY:
        JSR     GETLHS
        RTS
*       SUB.L   #2,A2
*       move.b  #101,D7
*       MOVE.W  (A2),D3
*       JSR     DECODEMOVEMEA
*       JSR     MOVEA1TOBUFFER
*       BRA     EAEXIT
**       LEA     COMMA,A1
**       JSR     MOVEA1TOBUFFER
**
*       SUB.W    #4,A2
*       MOVE.W   (A2),D3     ; opcode
*       ANDI.W   #$0400, D3
*       CMPI.W   #$0, D3
*       BEQ      MOVEMEXIT
*
*       LEA      COMMA,A1
*       JSR     MOVEA1TOBUFFER
*
MOVEMEAREGS:
*       MOVE.L  startSpace,A2

       CLR.W   D7
       MOVE.W  (A2),D5                      ; get copy of all 16 bits
       ADD.L   #2,A2
       MOVE.L  #$0, D4                      ; counter for loop
*
MOVEMEALOOP:
*
       ADD.L   #$1, D4                      ; increment counter
       CMPI.L  #$10, D4                      ; break loop here
       BGT     EXITMOVEMEALOOP
*
       LSR.W   #1, D5
       BCS     PRINTMOVEMEAREG               ;branch if a 1 is shifted out
       BRA     MOVEMEALOOP
*
EXITMOVEMEALOOP:
        RTS

PRINTMOVEMEAREG:
      CMPI.B   #1, MOVEMSET
      BEQ      PRINTSLASH
*
PRINTMOVEM2:
      MOVE.B   #1, MOVEMSET
      CMPI.L   #8, D4

      BLE      PRINTMOVEMD
      BRA      PRINTMOVEMA

PRINTSLASH

      LEA     SLASH, A1
      JSR     MOVEA1TOBUFFER
      BRA     PRINTMOVEM2

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
*
*
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
*

*
*MOVEMEXIT:
*
*
*      LEA     NEWLINE,A1
*      JSR     MOVEA1TOBUFFER
*      JSR     PRINTBUFFER
*
*      ADDA.L  #4,A2
*      BRA     LOOP
*
*DECODEMOVEMTHINGY:
*      SUB.L   #4,A2
*      NOP

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

      MOVE.W    (A2),D6           ; only move last byte
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
      MOVE.W    (A2),D1           ; only move last byte
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
      ANDI.W    #$0E00,D1         ; mask to compare and shift bits
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
      MOVEM.L   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #2,(A2)
      MOVEM.L   (A7)+,A2

      MOVE.L  (A2),BIN2A_VAL
      MOVE.L  #16, BIN2A_COUNT
      JSR     BIN2A_CONVERT


      LEA      POUND,A1
      JSR      MOVEA1TOBUFFER

      LEA      DOLLAR_SIGN,A1
      JSR      MOVEA1TOBUFFER

  *   ADDA.W   #4, A1
      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER

      LEA      COMMA,A1
      JSR      MOVEA1TOBUFFER

      MOVE.L   #2,D3
      MOVE.B   #101,D7
      JSR      DECODEEASIMPLE

      ADDA.L   #2,A2

      BRA     EAEXIT

PRINTADDILONG:
      MOVEM.L D0-D7/A1/A3-A6,-(A7) ; back up all the things
      MOVEM.L   A2,-(A7)
      LEA     startSpace,A2
      ADD.L   #4,(A2)
      MOVEM.L   (A7)+,A2

      ADDA.W  #2,A2                 ; increment to address reg
      MOVE.L  (A2),BIN2A_VAL
      SUBA.W  #2,A2
      MOVE.L  #32, BIN2A_COUNT
      JSR     BIN2A_CONVERT

  *   ADDA.W   #8, A1
      LEA      POUND,A1
      JSR      MOVEA1TOBUFFER

      LEA      DOLLAR_SIGN,A1
      JSR      MOVEA1TOBUFFER

  *   ADDA.W   #4, A1
      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER

      LEA      COMMA,A1
      JSR      MOVEA1TOBUFFER

      MOVE.L   #4,D3
      MOVE.B   #101,D7
      JSR      DECODEEASIMPLE

      ADDA.L   #4,A2


      BRA      EAEXIT

PRINTROTATIONEA:
      MOVEM.L D0-D7/A1/A3-A6,-(A7)
      MOVE.W  (A2),D2
      ANDI.W  #$0020,D2           ; mask to compare
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
      JSR      MOVEA1TOBUFFER

      BRA      EAEXIT

PRINTROTPOUND:
      LEA      POUND,A1
      JSR      MOVEA1TOBUFFER

      BRA     CONTROTEA



EAEXIT: ; SET ERROR FLAG TODO
        MOVEM.L (A7)+,D0-D7/A1/A3-A6 ; put everything back on the stack
        MOVE.L  #0,D7

        CMP.B   #1,RETURNATEND
        BEQ     RETURNEA


        LEA     NEWLINE,A1
        JSR     MOVEA1TOBUFFER
        JSR     PRINTBUFFER



        BRA     LOOP                  ; return to sender

*-----------------------------END SPECIAL CASES-------------------------------*

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


GETLHS: ; ASSUMES OPCODE IS IN D2
       MOVEM.L  D0-D7/A0-A6, -(A7)
       MOVE.W   D2,D3
       LSR.W    #3,D3       ; Last 3 bits of D3 are mode
       ANDI.L   #$0007,D2   ; Last 3 bits of D2 are reg
       ANDI.L   #$0007,D3

       CMP.W    #%000,D3
       BEQ      PRINTD
       CMP.W    #%001,D3
       BEQ      PRINTAD
       CMP.W    #%010,D3
       BEQ      PRINTADDRESS
       CMP.W    #%011,D3
       BEQ      PRINTADDRESS_W_POSTINC
       CMP.W    #%100,D3
       BEQ      PRINTADDRESS_W_PREDEC
       CMP.W    #%111,D3
       BEQ      ABSORIMD
       BRA      EAFAILED

*--------------------- PRINT FUNCTIONS ------------------------------
; all functions take care of stack pointer and send relevant
; data to buffer to save for printing

PRINTD: ; print D for data register
       LEA      DATA_REG,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   D2,BIN2A_VAL
       MOVE.L   #4,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

PRINTAD: ; print a for address register
       LEA      ADD_REG,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   D2,BIN2A_VAL
       MOVE.L   #4,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

PRINTADDRESS:
       LEA      PARENTHESIS_1,A1
       JSR      MOVEA1TOBUFFER

       LEA      ADD_REG,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   D2,BIN2A_VAL
       MOVE.L   #4,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       LEA      PARENTHESIS_2,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

PRINTADDRESS_W_POSTINC:
       LEA      PARENTHESIS_1,A1
       JSR      MOVEA1TOBUFFER

       LEA      ADD_REG,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   D2,BIN2A_VAL
       MOVE.L   #4,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       LEA      PARENTHESIS_2,A1
       JSR      MOVEA1TOBUFFER

       LEA      PLUS_SIGN,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

PRINTADDRESS_W_PREDEC:
       LEA      MINUS_SIGN,A1
       JSR      MOVEA1TOBUFFER

       LEA      PARENTHESIS_1,A1
       JSR      MOVEA1TOBUFFER

       LEA      ADD_REG,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   D2,BIN2A_VAL
       MOVE.L   #4,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       LEA      PARENTHESIS_2,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

*--------------------- END PRINT FUNCTIONS ------------------------------

ABSORIMD:
       CMP.W    #%000,D2   ; absolute mode 000
       BEQ      ABS000
       CMP.W    #%001,D2   ; absolute mode 001
       BEQ      ABS001
       CMP.W    #%100,D2
       BEQ      ABS100     ; absolute mode 100
       BRA      EAFAILED
ABS000
       MOVEM.L    A2,-(A7)
       LEA      startSpace,A2   ; load start to A2
       ADD.L    #2,(A2)
       MOVEM.L    (A7)+,A2

       ;ADD.L    D5,A2
       ADD.L    #2,A2
       LEA      DOLLAR_SIGN,A1
       JSR      MOVEA1TOBUFFER

       MOVE.W   (A2),D4
       MOVE.L   D4,BIN2A_VAL
       MOVE.L   #16,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6 ; push back to stack pointer
       RTS
ABS001
       MOVEM.L    A2,-(A7)
       LEA      startSpace,A2
       ADD.L    #4,(A2)
       MOVEM.L    (A7)+,A2

       ;ADD.L    D5,A2
       ADD.L    #2,A2
       LEA      DOLLAR_SIGN,A1
       JSR      MOVEA1TOBUFFER

       MOVE.L   (A2),D4
       MOVE.L   D4,BIN2A_VAL
       MOVE.L   #32,BIN2A_COUNT
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS
ABS100:
       MOVEM.L    D1/A2,-(A7)
       MOVE.L   #2,D1
       ADD.L    D5,D1
       LEA      startSpace,A2
       ADD.L    D1,(A2)
       MOVEM.L    (A7)+,D1/A2

       LEA      POUND,A1
       JSR      MOVEA1TOBUFFER


       ADD.L    D5,A2
       ADD.L    #2,A2
       LEA      DOLLAR_SIGN,A1
       JSR      MOVEA1TOBUFFER

       MOVE.W   (A2),D4
       MOVE.L   D4,BIN2A_VAL
       JSR      BINCOUNTSIZE
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       MOVEM.L  (A7)+, D0-D7/A0-A6
       RTS

BINCOUNTSIZE:
       CMP.W    #0,D5             ; check if 0
       BEQ      MAKECOUNT16
       MOVE.L   #32,BIN2A_COUNT
       RTS

MAKECOUNT16
       MOVE.L   #16,BIN2A_COUNT
       RTS

EAFAILED:
       JSR      SETUPOUTPUTBUFFER

*       LEA      EAERRORMSG,A1
*       JSR      MOVEA1TOBUFFER

       JSR      PRINTBUFFER
       MOVEM.L  (A7)+, D0-D7/A0-A6
       BRA      LOOP
*------------------------------------------------------------------------

*---------------------- Symbols ----------------------------
CR                  EQU         $0D
LF                  EQU         $0A

;MOVEMMEMCOUNT       DS.B 0 ; 0 if memory is already printed, otherwise 1
;MOVEMCOUNT          DS.B 0 ; 0 if other stuff is already printed, otherwise 1
;MOVEMDIRECTION      DS.B 0
*NEWLINE             DC.B        CR,LF,0
*PARENTHESIS_1       DC.B        '(', 0
*PARENTHESIS_2       DC.B        ')', 0
*PLUS_SIGN           DC.B        '+', 0
*MINUS_SIGN          DC.B        '-', 0
*COMMA               DC.B        ',', 0
*DOLLAR_SIGN         DC.B        '$', 0
*POUND               DC.B        '#', 0
*SLASH               DC.B        '/', 0
*
*DATA_REG            DC.B        'D', 0
*ADD_REG             DC.B        'A', 0


* Put variables and constants here

  ;  END    START        ; last line of source
*~Font name~Courier New~







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
