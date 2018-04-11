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
    sjmp lights	
up:
	mov p0.3, #0
	inc r0
	sjmp lights						 
down:
	mov p2.2, #0
	dec r0 
	sjmp lights
lights:
	mov a, r0
	cpl a; setup for turning on lights
	rrc a; send last bit to carry for use
	mov p1.6, c
	rrc a; send last bit to carry for use
	mov p0.6, c
	rrc a; send last bit to carry for use
	mov p0.5, c
	rrc a; send last bit to carry for use
	mov p2.4, c
	sjmp loop
over:
	mov r0, #0
	sjmp sound
under:
	mov r0, #0
	sjmp sound
sound:
	; Do sound here
	sjmp lights
end