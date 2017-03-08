To find out if there’s extra data after word opcode look at address mode. If it’s `111` that means that imediat data is being used. If it’s 111 you can look at the size used in the command and then know where the next code starts

Byte indexes are based on the least significant byte being byte 0


### Commands with data at the end:
___TODO: write test code and verify these___


| Command | size info |
|:-------:|:---------:|
|MOVE     | size is bits 14 and 15, can have up to a long at the end|
|MOVEA    | size is bits 14 and 15, can have up to a long at the end can be differentiated from move because bits 8 through 6 are always 001|
|MOVEQ    | always has a long at the end __(?)__|
|MOVEM    | word of Register List Mask|
|ADD      | size is bits 6 and 7, can have up to long of data at the end|
|ADDA     | size is bit 8 can have word or long at the end|
|ADDI     | size is bits 6 and 7, up to a long of immediate at the end|
|ADDQ     | size is bits 6 and 7, up to a long at the end __(?)__ |
|SUB      | size is bits 6 and 7, up to a long at the end __(?)__ |
|MULS     | word at end __(?)__|
|DIVU     | word at end __(?)__|
|LEA      | long at end __(?)__|
|CLR      | size is bits 6 and 7, up to long at the end|
|AND      | size is bits 6 and 7, up to long at the end|
|OR       | size is bits 6 and 7, up to long at the end|
|LSx      | none __(?)__|
|ASx      | none __(?)__|
|ROx      | none __(?)__|
|CMP      | up to long at end __(?)__|
|BCC      | up to word at end __(?)__|
|JSR      | none __(?)__|
|RTS      | none __(?)__|
