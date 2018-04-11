#include <reg932.inc>

cseg at 0

	mov 0xA4, #0 ;set Port 2 - bidirectional
	mov 0x91, #0 ;set Port 1 - bidirectional
	mov 0x84, #0 ;set Port 0 - bidirectoinal

	mov r0,#0

loop:
	mov c, p0.3 ;sw8
	jnc up; jump if press to inc
	cjne r0, #10h, noover; if it doesn't equal 15+1 jump over 15+1 convert
	sjmp over; is over must wrap
noover:
	mov c, p2.2 ;sw9
	jnc down; jump if press to dec
	cjne r0, #0FFh, nounder; if it doesn't equal 0-1 jump over 0-1 convert
	sjmp under; is under must wrap
nounder:	 
    sjmp lights; update lights
up:
	setb p0.3; reset switch ? may work idk
	inc r0; increment counter
	sjmp lights; update lights						 
down:
	setb p2.2; rest switch ? may work idk
	dec r0; decrement counter
	sjmp lights; update lights
lights:
	mov a, r0; move counter val to acc
	cpl a; invert for lights
	rrc a; send last bit to carry for use
	mov p1.6, c; set light 0
	rrc a; send last bit to carry for use
	mov p0.6, c; set light 1
	rrc a; send last bit to carry for use
	mov p0.5, c; set light 2
	rrc a; send last bit to carry for use
	mov p2.4, c; set light 3
	sjmp loop; return to loop
over:
	mov r0, #00h; reset counter to 0
	sjmp sound; play sound
under:
	mov r0, #0Fh; reset counter to 15
	sjmp sound; play sound
sound:
	; Do sound here
	mov TMOD, #02h
	mov TH0, #205
	mov TL0, #205
	setb p1.7; I think this is the speaker
	clr p2.5;
	setb TR0
back:
	jnb TF0, back
	clr p1.7
	clr p2.5
	clr TR0
	clr TF0
	sjmp lights; update lights
end