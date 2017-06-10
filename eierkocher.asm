; Eierkocher
; (Projekt Systemnahe Programmierung)
; Tom Bendrath, Dominik Wunderlich, Enrico Kaack und Torben Krieger

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
	temp_max equ 22H
	active equ R0
	timer equ R1
	timer_seconds equ R6
	timer_minutes equ R7

; Assignment
	MOV IN0, #00H
	MOV OUT0, #00H
	; Initialize LEDs
	SETB active_led_out
	SETB horn_out
	SETB heating_out

	; Initialize internals
	MOV active, #00H
	MOV timer, #00H

	MOV temp_max, #100
	; reset timer
	mov timer_minutes, #03h ; minutes
	mov timer_seconds, #00h ; seconds

	; Initialize temperature sensor
	CALL resetsensor
	CALL sensortick
	CALL writemaxtemp

; Timer initialization
	mov IE, #10010010b ; timer freischalten
	mov TMOD, #00000010b ; mode des timers 2 = auto reload

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

	; If active --> checktemp
	CJNE active, #00H, checktemp
	; Else if button pressed --> setactive
	JB button_in, setactive
	; Else --> read
	JMP init

setactive:
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
	; Set timer to started
	MOV timer, #0FFh
	; start timer
	mov tl0, #0c0h ; working #0C0h
	mov th0, #0c0h ; working #0C0h
	setb tr0 ; startet timer
	JMP output
	

output:

;	Move output register
	MOV P2, OUT0
	
	LJMP read


;----------------------------------------------------
; Timer interrupt
;----------------------------------------------------

timerinterrupt:
	; decrement timer
	; if seconds > 0 --> decr_seconds
	cjne timer_seconds, #0h, decr_seconds
	; else --> decr_minutes
	JMP decr_minutes

decr_seconds:
	dec r6
	JMP set_segments

decr_minutes:
	mov r6, #3Ch
	dec r7
	JMP set_segments

set_segments:
	ret


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

org 300h
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b