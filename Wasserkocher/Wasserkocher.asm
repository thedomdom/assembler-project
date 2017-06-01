; Initialisierung
org 00h
ajmp init

; Variablen
;-----------------
; P0.0 - Taster
; P0.1 - Hupe
; P2 - Temperatur (Wunschtemp)
; R0 - Temperatursensor
; R1 - Wassermenge
; P1 - Display
;-----------------
; Hauptprogramm
;-----------------
	;Aliases
	temp_current equ R0
	temp_max equ P2
	taster equ P0.0
	hupe equ P0.1
	heizstab equ P0.2
	water_current equ R1
	water_min equ R2
	is_active equ P0.3
	hupe_count equ R3
	tempsensor_dq equ P0.4
	tempsensor_clk equ P0.5
	tempsensor_rst equ P0.6
	tempsensor_com equ P3.2
	tempsensor_low equ P3.3
	tempsensor_high equ P3.4
	;------------------------------------

init:
	;Simulation
	mov water_current,#75 ;Wassermenge = 75 dl
	mov water_min, #50 ;Wassermenge
	mov hupe_count, #0
	mov temp_max, #100
	clr heizstab ;Disable Heizstab
	clr is_active
	clr hupe
	jmp main

writemaxtemp:
	mov a, #01h ;Send the command to write the max temperature
	call sendcommand
	mov a, temp_max;Write temp max to the sensor (max 127°C and min -128°C)
	call senddata
	ret

writemintemp:
	mov a, #02h ;Send Minimal Temp
	call sendcommand
	mov a, #128
	call senddata
	ret

readtemp:
	mov a, #170 ; Read current temp
	call sendcommand
	call getdata
	mov temp_current,a
	clr a
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

inits:
	clr heizstab ;Disable Heizstab
	clr is_active
	clr hupe
	;Initialize the sensor
	call resetsensor
	call sensortick
	call writemaxtemp
	call writemintemp
	setb is_active
	jmp main

main:
	jb taster, disable
	jnb is_active, inits
	call auslesen

	;check temperature
	jb tempsensor_high, disable

	;check water
	mov A, water_min
	clr cy ;Don't forget to reset that motherfucker
	subb A, water_current
	clr A
	jnb cy,disable
	clr cy

	call erhitzen
	call zeigen
	jmp main

; Lies derzeitige FÃ¼llmenge und Temperatur aus
;-----------------
auslesen:
	call readtemp
	RET

disable:
	clr heizstab ; deaktiviere Heizstab
	clr is_active
	jb taster,main
	mov hupe_count,#10
	call signal
	;clr taster Mechanisch !!!!
	jmp main

erhitzen:
	setb heizstab
	ret
signal:
	setb hupe ;aktiviere Hupe
	djnz hupe_count, signal
	clr hupe
	ret
zeigen:
	mov DPTR,#TABLE
	mov a,temp_current ; aktuelle Temperatur
	mov b, #0ah
	div ab
	mov r6, a; save a
	movc a,@a+dptr
	mov r4, a ; Stelle 1
	mov a, r6; restore a
	xch a,b
	movc a,@a+dptr
	mov r5, a ; Stelle 2
	call display
	ret;
;;;;;;Display - Ausgabe auf den Port P1 - aktivieren mit Port P3.0 und P3.1
display:
	; letzte Ziffer
	mov P1, r5
	clr P3.0
	setb P3.0
	; vorletzte Ziffer
	mov P1, r4
	clr p3.1
	setb P3.1
	ret ; return
;;;;;

org 300h
table:
DB 11000000b
DB 11111001b, 10100100b, 10110000b
DB 10011001b, 10010010b, 10000010b
DB 11111000b, 10000000b, 10010000b
end


end
