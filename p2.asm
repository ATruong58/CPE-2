#include <reg932.inc>

cseg at 0

	mov 0xA4, #0 ;set Port 2 - bidirectional
	mov 0x91, #0 ;set Port 1 - bidirectional
	mov 0x84, #0 ;set Port 0 - bidirectoinal

	mov A,#0
	mov r0,A

loop:
	mov c, p0.3 ;sw8
	jnc up
	mov c, p2.2 ;sw9
	jnc down 
    sjmp loop
	
up:
	mov A,r0
	add A,#01h
	mov r0,A
	sjmp loop						 
	
down:
	mov A,r0
	subb A,#01h
	mov r0,A
	sjmp loop


end