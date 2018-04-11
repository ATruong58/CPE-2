#include <reg932.inc>

cseg at 0

	mov 0xA4, #0 ;set Port 2 - bidirectional
	mov 0x91, #0 ;set Port 1 - bidirectional
	mov 0x84, #0 ;set Port 0 - bidirectoinal

	mov r0,#0

loop:
	mov c, p0.3 ;sw8
	jnc up
	cjne r0, #0Fh, noover
	sjmp over
noover:
	mov c, p2.2 ;sw9
	jnc down
	cjne r0, #0FFh, nounder
	sjmp under
nounder:	 
    sjmp loop	
up:
	inc r0
	sjmp loop						 
down:
	dec r0 
	sjmp loop
over:
	mov r0, #0
	sjmp sound
under:
	mov r0, #0
	sjmp sound
sound:
	; Do sound here
	ljmp loop
end