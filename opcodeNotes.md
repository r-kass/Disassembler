To find out if there’s extra data after word opcode look at address mode. If it’s `111` that means that imediat data is being used. If it’s 111 you can look at the size used in the command and then know where the next code starts

Byte indexes are based on the least significant byte being byte 0

### Commands with data at the end:
1. __MOVE__		size is bits 14 and 15, can have up to a long at the end
2. __MOVEA__	size is bits 14 and 15, can have up to a long at the end can be differentiated from move because bits 8 through 6 are always 001
3. MOVEQ	always has a long at the end (?)
4. MOVEM	word of Register List Mask
5. ADD		size is bits 6 and 7, can have up to long of data at the end
6. ADDA		
