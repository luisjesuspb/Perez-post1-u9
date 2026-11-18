; MULTI_ST.ASM - Polling combinado de Teclado (64h) y LPT1 (379h)
; Compila: nasm -f bin MULTI_ST.ASM -o MULTI_ST.COM

[BITS 16]
[ORG 0x100]

KB_STAT     EQU 64h
KB_DATA     EQU 60h
LPT_STAT    EQU 379h

start:
    CLI
.vaciar:
    IN  AL, KB_STAT
    TEST AL, 01h
    JZ  .poll_multi
    IN  AL, KB_DATA
    JMP .vaciar

.poll_multi:
    ; Leer estado de teclado (bit 0 = OBF)
    IN  AL, KB_STAT
    AND AL, 01h         ; aislar evento teclado (01h si listo, 00h si no)
    MOV BL, AL

    ; Leer estado de LPT1 (bit 7 = /BUSY -> 1 si libre)
    MOV DX, LPT_STAT
    IN  AL, DX
    AND AL, 80h         ; aislar evento LPT1 (80h si libre, 00h si ocupado)

    ; Combinar ambos eventos con OR
    OR  AL, BL
    JZ  .poll_multi     ; si ambos son 0, repetir polling

    ; Evaluar cual evento disparo primero
    TEST BL, 01h
    JNZ .evento_kb

    ; Evento LPT1 listo
    STI
    MOV AH, 09h
    MOV DX, msg_lpt
    INT 21h
    JMP .fin

.evento_kb:
    IN  AL, KB_DATA     ; consumir scancode
    STI
    MOV AH, 09h
    MOV DX, msg_kb
    INT 21h

.fin:
    MOV AH, 4Ch
    INT 21h

msg_kb  DB 'Evento detectado: Teclado listo (OBF=1 en puerto 64h).', 0Dh, 0Ah, '$'
msg_lpt DB 'Evento detectado: LPT1 listo (/BUSY=1 en puerto 379h).', 0Dh, 0Ah, '$'
