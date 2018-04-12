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
	mov c, p0.0
	jnc display_parity

;	mov c, p2.3
;	jnc countdown

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
	sjmp delay_s
under:
	mov r4, #0fh
	sjmp delay_s

lights:
	mov a, r4; move counter val to acc
	cpl a; invert for lights		       
	mov c, 0e0h
	mov p1.6, c; set light 0
	mov c, 0e1h		
	mov p0.6, c; set light 1
	mov c, 0e2h		
	mov p0.5, c; set light 2
	mov c, 0e3h	
	mov p2.4, c; set light 3
	sjmp loop; return to loop

;-----CHAU--------------------------------------------------
display_parity:
	mov a, r4
	mov r0, #0 ;increment per 1 bit
	mov r7, #4 ;decrement counter
loop_parity:
	rrc a
	jc up_parity
	djnz r7, loop_parity
parity_zero:
	mov a, r0
	mov c, 0e0h
	jc odd_parity
	sjmp even_parity
	
up_parity:
	inc r0
	djnz r7, loop_parity
	sjmp parity_zero

odd_parity:
	clr p2.7
	acall delay
	setb p2.7
	sjmp loop

even_parity:
	clr p0.4
	acall delay
	setb p0.4
	sjmp loop
;-----------------------------------------------------------

delay_s:
	mov r0, #255
sound:
	; Do sound here
	mov TMOD, #00010000b
	mov TL1, #-614
	mov TH1, #-614 shr 8
	setb TR1
here:
	jnb TF1, here
	cpl p1.7
	clr TR1
	clr TF1
	djnz r0, sound
	sjmp lights

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