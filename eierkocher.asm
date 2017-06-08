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

LJMP start

start:
LJMP process

process:
LJMP end

end:
LJMP start