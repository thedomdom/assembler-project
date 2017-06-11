; Eierkocher
; (Projekt Systemnahe Programmierung)
; Tom Bendrath, Dominik Wunderlich, Enrico Kaack und Torben Krieger

org 00h
CSEG AT 0H
LJMP init
cseg at 100h

ORG 0bh
call timerinterrupt
RETI

; --------------------------
; start
; --------------------------
ORG 20h
init:
; Definitions
        ; P0 - Inputs
		; P0.1 - Button
	; P1 - Temperature Sensor
	; P2 - LEDS
	; P3 - 4x7 Segments Display
	

	; input
	IN0 equ 20H
	temp_high_in equ IN0.0
	button_in equ IN0.1
	
	; output
	OUT0 equ 21H
	active_led_out equ OUT0.0
	horn_out equ OUT0.1
	heating_out equ OUT0.2
	
	; IO tempsensor
	tempsensor_dq equ P1.0
	tempsensor_clk equ P1.1
	tempsensor_rst equ P1.2
	tempsensor_com equ P1.3
	tempsensor_low equ P1.4
	tempsensor_high equ P1.5

	; internal
		; maximum temp
		temp_max equ 22H

		;booleans
		active equ R0
		timer equ R1

		; time
		timer_seconds equ R6
		timer_minutes equ R7

		;digits
		digit_0 equ 30H
		digit_1 equ 31H
		digit_2 equ 32H
		digit_3 equ 33H

; Timer initialization
	mov IE, #10010010b ; timer freischalten
	mov TMOD, #00000010b ; mode des timers 2 = auto reload
	
; Assignments
	MOV IN0, #00H
	MOV OUT0, #0FFH
	; Initialize LEDs
;	SETB active_led_out
;	SETB horn_out
;	SETB heating_out

	; Initialize internals
	MOV active, #00H
	MOV timer, #00H

	MOV temp_max, #100

; Temperature sensor initialization
	CALL resetsensor
	CALL sensortick
	CALL writemaxtemp

; --> read
	LJMP read

read:
	; read button
	MOV c, P0.1
	CPL c
	MOV button_in, c
	; read temp_high
	MOV c, tempsensor_high
	MOV temp_high_in, c
	; --> checkactive
	JMP checkactive


checkactive:
	; If active --> checktemp
	CJNE active, #00H, checktemp
	; Else if button pressed --> setactive
	JB button_in, setactive
	; Else --> read
	JMP output

setactive:
	; deactivate horn
	SETB horn_out
	;active = 1111 1111
	MOV active, #0FFh
	; activate active LED
	CLR active_led_out
	; --> checktemp
	JMP checktemp

checktemp:
	; if temperature > 100 deg --> timer
	JB temp_high_in, checktimer
	; else --> heat
	JMP heat

heat:
	; Activate heating
	CLR heating_out
	; --> output
	JMP output

checktimer:
	; Deactivate Heating
	SETB heating_out
	; if timer started --> output
	CJNE timer, #00H, output
	; else --> starttimer
	JMP starttimer

starttimer:
	; reset time
	mov timer_minutes, #0 ; minutes
	mov timer_seconds, #10 ; seconds
	; start timer
	mov tl0, #0c0h ; working #0C0h
	mov th0, #0c0h ; working #0C0h
	setb tr0
	; Set timer to started
	MOV timer, #0FFh
	; --> output
	JMP output
	

output:

	; Move output register
	MOV P2, OUT0
	; --> read
	LJMP read

;----------------------------------------------------
; Timer interrupt
;----------------------------------------------------

timerinterrupt:
	; decrement timer
	; if seconds > 0 --> decr_seconds
	cjne timer_seconds, #0h, decr_seconds
	; else if minutes > 0 --> decr_minutes
	cjne timer_minutes, #0h, decr_minutes
	; else --> stoptimer
	JMP stoptimer

decr_seconds:
	dec timer_seconds
	JMP set_segments

decr_minutes:
	; set seconds to 60
	mov timer_seconds, #59
	; decrement minutes
	dec timer_minutes
	JMP set_segments

stoptimer:
	; Deactivate Heating
	SETB heating_out
	; horn
	CLR horn_out
	;active = 0000 0000
	MOV active, #00h
	; deactivate active LED
	SETB active_led_out
	; stop timer
	clr tr0
	; Set timer to stopped
	MOV timer, #00h
	; --> set_segments
	JMP set_segments

set_segments:
	; seconds
;	mov DPTR, #table
;	mov a, R6
;	mov b, #0ah
;	div ab
;	mov R2, a
;	movc a,@a+dptr
;	mov digit_1, a
;	mov a, r2
;	xch a,b
;	movc a, @a+dptr
;	mov digit_0, a
;	; minutes
;	mov a, R7
;	mov b, #0ah
;	div ab
;	mov R2, a
;	movc a,@a+dptr
;	mov digit_3, a
;	mov a, r2
;	xch a,b
;	movc a, @a+dptr
;	mov digit_2, a

	; Display digits
	CALL display
	; --> JUMP back to Iterrupt
	ret

display:
    mov P3, digit_0
    clr P2.4
    setb P2.4

    mov P3, digit_1
    clr P2.5
    setb P2.5

    mov P3, digit_2
    clr P2.6
    setb P2.6

    mov P3, digit_3
    clr P2.7
    setb P2.7

    ret

; Table for Digits
;org 300h
;table:
;DB 11000000b
;DB 11111001b, 10100100b, 10110000b
;DB 10011001b, 10010010b, 10000010b
;DB 11111000b, 10000000b, 10010000b
;end

;----------------------------------------------------
; util for temp. sensor handling
;----------------------------------------------------
writemaxtemp:
	mov a, #01h ;Send the command to write the max temperature
	call sendcommand
	mov a, temp_max;Write temp max to the sensor (max 127°C and min -128°C)
	call senddata
	ret

;Send command in register a to sensor
sendcommand:
	call resetsensor
	mov c, a.0
	mov tempsensor_dq, c
	call sensortick
	mov c, a.1
	mov tempsensor_dq, c
	call sensortick
	mov c, a.2
	mov tempsensor_dq, c
	call sensortick
	mov c, a.3
	mov tempsensor_dq, c
	call sensortick
	mov c, a.4
	mov tempsensor_dq, c
	call sensortick
	mov c, a.5
	mov tempsensor_dq, c
	call sensortick
	mov c, a.6
	mov tempsensor_dq, c
	call sensortick
	mov c, a.7
	mov tempsensor_dq, c
	call sensortick
	clr a
	clr c
	ret
;Send data in register a to (Sensor expects 9 bit)
senddata:
	clr tempsensor_dq
	call sensortick
	mov c, a.0
	mov tempsensor_dq, c
	call sensortick
	mov c, a.1
	mov tempsensor_dq, c
	call sensortick
	mov c, a.2
	mov tempsensor_dq, c
	call sensortick
	mov c, a.3
	mov tempsensor_dq, c
	call sensortick
	mov c, a.4
	mov tempsensor_dq, c
	call sensortick
	mov c, a.5
	mov tempsensor_dq, c
	call sensortick
	mov c, a.6
	mov tempsensor_dq, c
	call sensortick
	mov c, a.7
	mov tempsensor_dq, c
	call sensortick
	clr c
	clr a
	ret

getdata:
	clr a
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.0, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.1, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.2, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.3, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.4, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.5, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.6, c
	setb tempsensor_clk
	clr tempsensor_clk
	mov c, tempsensor_dq
	mov a.7, c
	clr c
	ret

resetsensor:
	clr tempsensor_rst
	setb tempsensor_rst
	ret

sensortick:
	setb tempsensor_clk
	clr tempsensor_clk
	ret

end