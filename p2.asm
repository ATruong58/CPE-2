#include <reg932.inc>

cseg at 0

	mov 0xA4, #0
	mov 0x91, #0
	mov 0x84, #0

	mov r4, #0

loop:
	mov c, p0.3
	jnc up
	mov c, p2.2
	jnc down
	sjmp loop

up:
	setb p0.3
	inc r4
	acall delay
	cjne r4, #10h, lights
	sjmp over
down:
	setb p2.2
	dec r4
	acall delay
	cjne r4, #0ffh, lights
	sjmp under
over:
	mov r4, #00h
	acall delay_s
	sjmp lights
under:
	mov r4, #0fh
	acall delay_s
	sjmp lights


lights:
	mov a, r4; move counter val to acc
	cpl a; invert for lights
	mov c, 0e0h
	;rrc a; send last bit to carry for use
	mov p1.6, c; set light 0
	mov c, 0e1h
	mov p0.6, c; set light 1
	mov c, 0e2h
	mov p0.5, c; set light 2
	mov c, 0e3h
	mov p2.4, c; set light 3
	sjmp loop; return to loop
	
sound:
	; Do sound here
	mov TMOD, #02h
	mov TH0, #255
	mov TL0, #255
	setb p1.7; I think this is the speaker
	clr p2.5;
	setb TR0
back:
	jnb TF0, back
	clr p1.7
	setb p2.5
	clr TR0
	clr TF0
	sjmp lights

delay_s:
	mov r0, 255
	setb p1.7
d_loop_s:
	mov r1, 255
d_loop2_s:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	djnz r1, d_loop2_s
	djnz r0, d_loop_s
	clr p1.7
	ret
		
delay:
	mov r0, 255
d_loop:
	mov r1, 255
d_loop2:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	djnz r1, d_loop2
	djnz r0, d_loop
	ret

end