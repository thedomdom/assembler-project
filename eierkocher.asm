; Eierkocher 
; (Projekt Systemnahe Programmierung)
; Tom Bendrath, Dominik Wunderlich, Enrico Kaack und Torben Krieger 

CSEG AT 0H
LJMP init
ORG 100H

; --------------------------
; init
; --------------------------
init:
; Variablen
;-----------------
; P0.0 - Taster
; P0.1 - Hupe
; P2 - Temperatur (Wunschtemp)
; R0 - Temperatursensor
; R1 - Wassermenge
; P1 - Display
	;Aliases
	; input
	IN0 equ 20H
	temp_high equ IN0.0
	button equ IN0.1
	; output
	OUT0 equ 21H
	horn equ OUT0.0
	heating equ OUT0.1
	active equ OUT0.2
	; IO tempsensor
	tempsensor_dq equ P1.0
	tempsensor_clk equ P1.1
	tempsensor_rst equ P1.2
	tempsensor_com equ P1.3
	tempsensor_low equ P1.4
	tempsensor_high equ P1.5
	; internal
	temp_max equ R1
	timer equ R2
	timer_max equ R3
	is_active equ R4

	MOV IN0, #00H
	MOV OUT0, #00H
	
	MOV timer, #00H
	
	MOV temp_max, #100
	MOV timer_max, #100 ; TODO set right time here
	call resetsensor
	call sensortick
	CALL writemaxtemp
	
LJMP start

start:
MOV IN0, P0
MOV c, tempsensor_high
MOV temp_high, c
MOV P3, IN0
LJMP process

process:
LJMP end

end:
LJMP start


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