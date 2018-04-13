#include <reg932.inc>

cseg at 0

	mov 0xA4, #0
	mov 0x91, #0
	mov 0x84, #0

	mov r4, #0 ;start the counter at 0	
	mov r5, #0
	mov r6, #0
loop:
	mov c, p0.3 ;detect if increment switch was pressed
	jnc up ;jump to increment 
	mov c, p2.2 ;detect if decrement switch was pressed
	jnc down ;jump to decrement

	mov c, p0.0 ;Chau: Check if display parity switch was pressed
	jnc display_parity ;if parity switch pressed jump to function to display parity

	mov c, p2.0
	jnc ladd_jmp
	mov c, p0.1
	jnc ladd2_jmp
	mov c, p2.3
	jnc rand_jmp
	sjmp loop
up:
	setb p0.3 ;reset switch
	inc r4 ;increment counter
	acall delay ;delay in order to display correct value
	cjne r4, #10h, lights ;jump to display lights if no roll over
	sjmp over ;if check for no roll over is not true, jump to deal with this
down:
	setb p2.2
	dec r4 ;decrement counter
	acall delay ;delay to display correct value
	cjne r4, #0ffh, lights ;jump to display lights if no roll over
	sjmp under ;deal with roll over if check for no roll over was not true
over:
	mov r4, #00h ;set counter to 0 since its rolling-over
	sjmp delay_s ;jump to create sound
under:
	mov r4, #0fh ;set counter to 15 since its rolling-under
	sjmp delay_s ;jump to create sound

rand_jmp:
	ljmp rand


ladd_jmp:
	ljmp ladd
ladd2_jmp:
	ljmp ladd2
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
;-------ALAN----------------------------------------------------
;Display register 5 on the binary subject which contain teh added value
lightsa:
	mov a, r5; move r5 val to acc
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
;-------------------------------------------------------

;-----CHAU--------------------------------------------------
display_parity:
	mov a, r4 ;move current counter to ACC
	mov r0, #0 ;a count for number of 1 bits
	mov r7, #4 ;decreasing count for number of bits read to find parity
			   ;only dealing with 4 bit words  so the count only need to read 4 bits
loop_parity:
	rrc a ;rotate right and save bit 0 to carry bit 
	jc up_parity ;jump to increase 1 bits
	djnz r7, loop_parity ;loop in order to read the right amount bits
parity_zero:
;determins even or odd
	mov a, r0 ;put the number of 1 bits into acc
	mov c, 0e0h ;make carry bit acc.0
	jc odd_parity ;if carry bit is 1, its an odd parity
	ljmp even_parity ;if carry bit is 0, go to even parity
	
up_parity:
	inc r0 ;increment number of 1 bits
	djnz r7, loop_parity ;go back to reading more bits if it has not been don 4 times
	ljmp parity_zero ;if we've read 4 bits, go to determine odd or even

odd_parity:
;turns on the green light LED3 as long as parity switch is pressed
	clr p2.7
	acall delay
	setb p2.7
	ljmp loop ;go back to detecting switches

even_parity:
;turns on second red light LED6 as long as parity switch is pressed
	clr p0.4
	acall delay
	setb p0.4
	ljmp loop ;go back to detecting switches
;-----------------------------------------------------------

delay_s:
	mov r0, #255 ;allow for continuous square wave
sound:
	; Do sound here
	mov TMOD, #00010000b ;timer 1 16 bit mode
	mov TL1, #-614
	mov TH1, #-614 shr 8 ;preload
	setb TR1 ;turn on timer 1
here:
	jnb TF1, here ;wait for overflow
	cpl p1.7 ;toggle speaker
	clr TR1 ;turn off timer 1
	clr TF1 ;clear overflow flag
	djnz r0, sound ;send continous square wave to make sound longer
	ljmp lights ;jump to display the new counter value after rolling over
;------ALAN--------------------------------------------------
ladd:
	mov a, r4; move counter value to a 
	acall delay
	mov r5, a
	ljmp loop;jump back to loop for user to choose second number to add
ladd2:
	mov a,r4; move coutner value to a
	acall delay
	mov r6, a; store the 2nd number in register 6
	mov a,r5;move r5 to a
	acall delay; delay to correctly display and store number
	add a, r6;add the two numver 
	mov r5, a;move the result in r5
	ljmp lightsa;move to this function to display the register on the
		    ;device
;--------------------------------------------------------------
;-----Cash--------------------------------------------------
rand:
	clr p2.7; turn on indicator light
	inc r4; increment count
	cjne r4, #10h, next; reset if we make it to 15
	mov r4, #00h; 
next:
	mov c, p1.4; check for stop
	setb p2.7; turn off indicator light
	jnc light_jmp; jump if we stopped
	sjmp rand; otherwise keep incrementing 
;-----------------------------------------------------------

light_jmp:
	ljmp lights
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
