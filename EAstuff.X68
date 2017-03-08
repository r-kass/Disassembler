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
    BRA DECODEEASIMPLE

; input is 16 bits in (A2)
; branch to appropriate mode subroutine

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



EADECMODE: ; loop to compare all EA modes

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


EAMODE000: ; data register direct
        JSR     ADDQEA

        LEA      DATA_REG, A1
        JSR      MOVEA1TOBUFFER

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR      MOVEA1TOBUFFER

        CMP.B    #100,D7
        BEQ      EAEXIT
        CMP.B    #101,D7
        BEQ      RETURNEA

        LEA      COMMA,A1
        JSR      MOVEA1TOBUFFER

        CMP.B    #1,D7            ; match to D7 value set in opcode
        BEQ      PRINTA000

        LEA      DATA_REG, A1     ; print D for data register

CONTMODE000:
        JSR     MOVEA1TOBUFFER

        MOVE.W   (A2),D2
        LSR.W    #8,D2
        LSR.W    #1,D2
        ANDI.W   #$0007,D2        ; check last 3 bits by mask
        MOVE.L   D2, BIN2A_VAL
        MOVE.L   #4, BIN2A_COUNT
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR      MOVEA1TOBUFFER

       ; CMP.B    #2,D7           ; match to D7 value set in opcode
       ; BEQ      MOVEEA
        BRA EAEXIT                ; branch to exit

PRINTA000:
        LEA      ADD_REG,A1
        BRA      CONTMODE000


EAMODE001: ; address register direct

        LEA      ADD_REG, A1
        JSR      MOVEA1TOBUFFER

        MOVE.L   D2, BIN2A_VAL    ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT  ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER, A1
        JSR      MOVEA1TOBUFFER

        LEA      COMMA,A1         ; send comma to buffer
        JSR      MOVEA1TOBUFFER

        CMP.B    #1,D7            ; match to D7 value set in opcode
        BEQ      PRINTA001
        CMP.B    #2,D7            ; match to D7 value set in opcode
        LEA      DATA_REG, A1

CONTMODE001: ; continuation of mode 001

        JSR      MOVEA1TOBUFFER
        MOVE.W   (A2),D2
        LSR.W    #8,D2            ; left shift 9 bits
        LSR.W    #1,D2
        ANDI.W   #$0007,D2        ; get last three bits of D2
        MOVE.L   D2, BIN2A_VAL    ; send D2 to be converted
        MOVE.L   #4, BIN2A_COUNT  ; specify 4 bits to be converted
        JSR      BIN2A_CONVERT

        LEA      BIN2A_BUFFER,A1
        JSR      MOVEA1TOBUFFER

        BRA EAEXIT                ; branch to exit

PRINTA001: ; to load to buffer to print

        LEA     ADD_REG,A1
        BRA     CONTMODE000



EAMODE010: ; address register indirect: sends address value

        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER

        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA     BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER

        BRA EAEXIT                    ; branch to exit



EAMODE011: ;address register indirect with post increment


        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER

        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA     BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER

        LEA     PLUS_SIGN, A1
        JSR     MOVEA1TOBUFFER

        BRA EAEXIT                ; branch to exit


EAMODE100: ; address register indirect with pre decrement

        LEA     MINUS_SIGN, A1
        JSR     MOVEA1TOBUFFER

        LEA     PARENTHESIS_1, A1
        JSR     MOVEA1TOBUFFER

        LEA     ADD_REG, A1
        JSR     MOVEA1TOBUFFER

        MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
        MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
        JSR      BIN2A_CONVERT

        LEA     BIN2A_BUFFER, A1
        JSR     MOVEA1TOBUFFER

        LEA     PARENTHESIS_2, A1
        JSR     MOVEA1TOBUFFER

        BRA EAEXIT                    ; branch to exit


EAMODE111: ; absolute short, long
      CMP.B   #%100, D2
      BEQ     IMMED100                ; immediate data
      CMP.B   #%000, D2
      BEQ     SHORT000                ; short length
      CMP.B   #%001, D2
      BEQ     LONG001                 ; long length
      CMP.B   #%010, D2
      BEQ     EAEXIT                  ; branch to exit
      CMP.B   #%011, D2
      BEQ     EAEXIT                  ; branch to exit
      CMP.B   #%101, D2
      BEQ     EAEXIT                  ; branch to exit
      CMP.B   #%110, D2
      BEQ     EAEXIT                  ; branch to exit
      CMP.B   #%111, D2
      BEQ     EAEXIT                  ; branch to exit

ADDQEA:
      CMP.B   #3,D7                   ; match to D7 value set in opcode
      BNE     RETURNEA

      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER

      MOVE.W  (A2),D2
      ANDI.W  #$0E00,D2               ; bitmask to isolate bits
      LSR.W   #8,D2                   ; rotate right 9 bits
      LSR.W   #1,D2

      MOVE.B  D2,D1
      MOVE.B  #3,D0
      TRAP    #15

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER

      MOVE.B  #100,D7

RETURNEA:
      RTS


IMMED100 ; immediate data
      LEA     POUND, A1
      JSR     MOVEA1TOBUFFER

      LEA     DOLLAR_SIGN, A1         ; immediate data - hex
      JSR     MOVEA1TOBUFFER

      CLR.L   D5
      MOVE.B  (A2),D4
      CMP.B   #1,D4                   ; if 1- word; if 2- long
      BEQ     WORDIMMED
      BRA     LONGIMMED

WORDIMMED ; word length data
      ADDA.W  #2, A2                  ; to read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6
      MOVE.W  #4, D5                  ; copy number of bits
      JSR     BIN2A_CONVERT

      ADDA.W  #2, A1                  ; move along 32 bit extension

      BRA     EAEXIT                  ; branch to exit


LONGIMMED ; long length data
      ADDA.W  #2, A2                  ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6
      MOVE.W  #8, D5
      JSR     BIN2A_CONVERT

      ADDA.W  #4, A1                  ; move along 32 bit extension

      BRA     EAEXIT                  ; branch to exit


SHORT000 ; branch
      LEA     DOLLAR_SIGN, A1         ; hex
      JSR     MOVEA1TOBUFFER

      ADDA.W  #2, A2                  ; read following word from memory
      CLR.L   D6

      MOVE.W  (A2),D6
      MOVE.L  #0, BIN2A_VAL
      MOVE.L  D6, BIN2A_VAL           ; clear value and load D6
      MOVE.L  #16, BIN2A_COUNT        ; number of bits to convert
      JSR     BIN2A_CONVERT

      LEA     BIN2A_BUFFER,A1
      JSR     MOVEA1TOBUFFER

      ADDA.W  #2, A1                  ; move along 32 bit extension

      BRA     EAEXIT                  ; branch to exit



LONG001 ; branch
      LEA     DOLLAR_SIGN, A1 ; hex
      JSR     MOVEA1TOBUFFER

      ADDA.W  #2, A2                  ; read following word from memory

      MOVE.W  (A2),D6
      MOVE.W  #8, D5                  ; copy number of bits
      JSR     BIN2A_CONVERT

      ADDA.W  #4, A1                  ; increment address by 4

      BRA     EAEXIT                  ; branch to exit


EAERROR: ; error function
      LEA     EAERRORMSG, A1
      JSR     MOVEA1TOBUFFER
      BRA     EAEXIT

*-----------------------------END GENERAL CASES-------------------------------*

*--------------------------------START MOVEA----------------------------------*

DECODEMOVEMEA:

       ;MOVEM.L D0-D7/A1/A3-A6,-(A7)

MOVEMSET:       DS.B 0 ; 0 if set bits, else 1  ;movem variable
       LEA      MOVEMSET,A5                     ; load into A5
       MOVE.B   #0,(A5)
       ;MOVE.B  #0,MOVEMMEMCOUNT
       ;MOVE.B  #0,MOVEMCOUNT
       ;MOVE.B  #0,MOVEMDIRECTION

       MOVE.W   (A2)+,D3                        ; opcode storage
       ANDI.W   #$0400, D3                      ; bitmask
       CMPI.W   #$0, D3                         ; if D bit is 0
       BEQ      MOVEMEA
       ;MOVE.B  #$1,MOVEMDIRECTION              ; else direction comes first
       ;BRA     MOVEMEAMEM

MOVEMEAMEM:

       ;CMPI.W  #$1, MOVEMMEMCOUNT
       ;BEQ     MOVEMEXIT
       ;MOVE.B  #1,MOVEMMEMCOUNT
       MOVEA.W  A2, A4                          ; copy address
       ADDA.W   #4, A4                          ; increment
       MOVE.L   #32,BIN2A_COUNT                 ; number of bits to convert
       MOVE.W   (A3),D7
       MOVE.L   D7,BIN2A_VAL                    ; value to convert
       JSR      BIN2A_CONVERT

       LEA      BIN2A_BUFFER,A1
       JSR      MOVEA1TOBUFFER

       SUB.W    #2,A2                           ; decrement A2
       MOVE.W   (A2)+,D3
       ANDI.W   #$0400, D3                      ; bitmask
       CMPI.W   #$0, D3                         ; if lone bit is 0
       BEQ      MOVEMEXIT                       ; exit MOVEM

       LEA      COMMA,A1
       JSR      MOVEA1TOBUFFER

MOVEMEA:

       CLR.W   D7
       MOVE.W  (A2),D5                          ; get copy of all 16 bits

       MOVE.L  #$0, D4                          ; counter for loop
       ;CMPI.W  #$1, MOVEMCOUNT

MOVEMEALOOP:

       ADD.L   #$1, D4                          ; increment counter
       CMPI.L  #$F, D4                          ; break loop here
       BEQ     EXITMOVEMEALOOP

       LSR.W   #1, D5
       BCS     PRINTMOVEMEA                     ;branch if a 1 is shifted out
       BRA     MOVEMEALOOP

EXITMOVEMEALOOP:
       SUB.W    #2,A2
       MOVE.W   (A2)+,D3                        ; opcode
       ANDI.W   #$0400, D3                      ; mask bits to compare bit to 0
       CMPI.W   #$0, D3
       BNE      MOVEMEXIT

       LEA      COMMA,A1
       JSR      MOVEA1TOBUFFER
       BRA      MOVEMEAMEM

;MOVEMCOMMAM
       ;CMP.B    #0, MOVEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMCOUNT
       ;LEA      COMMA,A1
       ;JSR      MOVEA1TOBUFFER
       ;BRA      MOVEMEAMEM

;MOVEMCOMMAR
       ;CMP.B    #0, MOVEMMEMCOUNT
       ;BEQ      MOVEMEXIT
       ;MOVE.B   #1, MOVEMMEMCOUNT
       ;LEA      COMMA,A1
       ;JSR      MOVEA1TOBUFFER
       ;BRA      MOVEMEA

PRINTMOVEMEA: ; to check if ready to print
      CMPI.B   #1, MOVEMSET
      BEQ      PRINTSLASH

PRINTMOVEM2:   ; to check which direction to print
      MOVE.B   #1, MOVEMSET
      CMPI.L   #8, D4

      BLE      PRINTMOVEMD                        ; print Dn first
      BRA      PRINTMOVEMA                        ; print An first

PRINTMOVEMD:
      LEA      DATA_REG, A1
      JSR      MOVEA1TOBUFFER

      MOVE.L   D4,D6                              ; copy count to D6
      SUBI.L   #1, D6

      MOVE.L   D6, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER


      BRA      MOVEMEALOOP


PRINTMOVEMA:
      LEA      ADD_REG, A1

      JSR      MOVEA1TOBUFFER

      MOVE.L   D4,D6                                ; copy count to D6
      SUBI.L   #9, D6

      MOVE.L   D6, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER


      BRA      MOVEMEALOOP

PRINTSLASH

      LEA      SLASH, A1                             ; send slash to buffer
      JSR      MOVEA1TOBUFFER
      BRA      PRINTMOVEM2

MOVEMEXIT:

      LEA     NEWLINE,A1
      JSR     MOVEA1TOBUFFER
      JSR     PRINTBUFFER

      ADDA.L  #4,A2                                  ; increment address by 4
      BRA     LOOP

*---------------------------END MOVEM SUBROUTINES-----------------------------*
*----------------------------START SPECIAL CASES------------------------------*

MOVEEA:
      MOVE.W    (A2),D6                           ; move address in A2 to D6
      LSR.W     #8,D6                             ; rotate right 9 bits
      LSR.W     #1,D6
      ANDI.W    #0003,D6                          ; bitmask
      MOVE.W    D6,D5                             ; copy D8
      MOVE.W    (A2),D6
      LSR.W     #3,D6                             ; shift right by 3
      ANDI.W    #$003F,D6                         ; mask D6
      ADD.W     D5,D6
      MOVE.W    D6,(A2)
      MOVE.B    #100,D7
      BRA       DECODEEA                          ; branch back to decode


BCCEA: ; special case

      MOVE.W    (A2),D6                           ; only move last byte
      MOVE.B    D6,BIN2A_VAL
      MOVE.B    #8,BIN2A_COUNT

      JSR       MOVEA1TOBUFFER

      BRA       EAEXIT

MOVEQEA: ;special case

      MOVEM.L   D0-D7/A1/A3-A6,-(A7)              ; pop off stack pointer
      LEA       POUND,A1
      JSR       MOVEA1TOBUFFER

      MOVE.W    (A2),D1                           ; only move last byte
      ANDI.W    #$003F,D1
      MOVE.B    #3,D0
      TRAP      #15

      LEA       COMMA,A1
      JSR       MOVEA1TOBUFFER

      LEA       DATA_REG,A1
      JSR       MOVEA1TOBUFFER

      MOVE.W    (A2),D1
      ANDI.W    #$0E00,D1                           ; bitmask
      LSR.W     #8,D1                               ; shift 9 bits
      LSR.W     #1,D1

      MOVE.B    #3,D0
      TRAP      #15

      BRA EAEXIT

*PRINTADDIBYTE:
*
*      MOVEM.L D0-D7/A1/A3-A6,-(A7)               ; back up all the things
*
*      ADDA.W  #1, A2                    ; read following word from memory
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

      MOVEM.L D0-D7/A1/A3-A6,-(A7)                 ; back up all the things


      MOVE.L  (A2),BIN2A_VAL                       ; value to convert
      MOVE.L  #16, BIN2A_COUNT                     ; number bits to convert
      JSR     BIN2A_CONVERT


      LEA     POUND,A1
      JSR     MOVEA1TOBUFFER

      LEA     DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER

  *   ADDA.W  #4, A1
      LEA     BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER

      MOVE.B  #101,D7
      JSR     DECODEEASIMPLE

      ADDA.L  #2,A2                                 ; increment A2 by 2

      BRA     EAEXIT

PRINTADDILONG:

      MOVEM.L D0-D7/A1/A3-A6,-(A7)                  ; back up all the things

      ADDA.W  #2,A2                                 ; add 2 to address
      MOVE.L  (A2),BIN2A_VAL
      SUBA.W  #2,A2
      MOVE.L  #32, BIN2A_COUNT                      ; 32 bits to convert
      JSR     BIN2A_CONVERT

  *   ADDA.W  #8, A1
      LEA     POUND,A1
      JSR     MOVEA1TOBUFFER

      LEA     DOLLAR_SIGN,A1
      JSR     MOVEA1TOBUFFER

  *   ADDA.W  #4, A1
      LEA     BIN2A_BUFFER, A1
      JSR     MOVEA1TOBUFFER

      LEA     COMMA,A1
      JSR     MOVEA1TOBUFFER

      MOVE.B  #101,D7
      JSR     DECODEEASIMPLE

      ADDA.L  #4,A2                                  ; increment address by 4


      BRA     EAEXIT

PRINTROTATIONEA:  ; special case

      MOVEM.L D0-D7/A1/A3-A6,-(A7)                   ; stack pointer
      MOVE.W  (A2),D2                                ; to decode into D2
      ANDI.W  #$0020,D2
      CMPI.W  #0,D2
      BEQ     PRINTROTPOUND                          ; to print pound sign
      LEA     DATA_REG,A1
      JSR     MOVEA1TOBUFFER                         ; prepare to print

CONTROTEA:
      MOVE.W   (A2),D2
      ANDI.W   #$0E00,D2
      LSR.W    #8,D2
      LSR.W    #1,D2

      MOVE.L   D2, BIN2A_VAL   ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT ; converting one digit, 4 bits
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER

      LEA      COMMA,A1
      JSR      MOVEA1TOBUFFER

      LEA      DATA_REG,A1
      JSR      MOVEA1TOBUFFER

      MOVE.W   (A2),D2          ; to decode into D2
      ANDI.W   #$0005,D2        ; bitmask

   ;   ADDI.W  #1, D2

      MOVE.L   D2, BIN2A_VAL    ; put register value in conversion subroutine
      MOVE.L   #4, BIN2A_COUNT  ; converting one digit, 4 bits
      JSR      BIN2A_CONVERT

      LEA      BIN2A_BUFFER, A1
      JSR      MOVEA1TOBUFFER

      BRA      EAEXIT

PRINTROTPOUND:
      LEA      POUND,A1
      JSR      MOVEA1TOBUFFER
      BRA      CONTROTEA

*----------------------------END SPECIAL CASES------------------------------*

EAEXIT:
        MOVEM.L (A7)+,D0-D7/A1/A3-A6 ; put everything back on the stack
        MOVE.L  #0,D7
        LEA     NEWLINE,A1
        JSR     MOVEA1TOBUFFER
        JSR     PRINTBUFFER

        BRA     LOOP                  ; return to sender

*-----------------------------BINARY TO ASCII--------------------------------*
BIN2A_VAL    DS.L 32  ; input number for our conversion
BIN2A_BUFFER DS.B 256 ; buffer for ascii data
BIN2A_COUNT  DS.L 32  ; number of bits to convert (must be div by 4)

BIN2A_CONVERT:
        MOVEM.L  D0-D7/A0-A6, -(A7)

        MOVE.L   BIN2A_COUNT, D2    ; shift count
        LEA      BIN2A_BUFFER, A0   ; load buffer into A0

BIN2A_LOOP:
        SUB.L    #4, D2             ; decrement by
        MOVE.L   BIN2A_VAL,D1       ; copy the input value
        LSR.L    D2, D1
        ANDI.L   #$F, D1            ; truncate
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

*--------------------------END BINARY TO ASCII-----------------------------*

*--------------------------------SYMBOLS-----------------------------------*

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

*----------------------------END SYMBOLS-----------------------------------*


  ;  END    START        ; last line of source
*~Font name~Courier New~











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
