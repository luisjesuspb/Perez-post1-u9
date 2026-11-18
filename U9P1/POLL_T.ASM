; POLL_T.ASM ? Polling con timeout para el puerto de teclado
; Compila: nasm -f bin POLL_T.ASM -o POLL_T.COM

[BITS 16]
[ORG 0x100]

MAX_RETRY EQU 0005h

start:
    CLI
.vaciar:
    IN  AL, 64h
    TEST AL, 01h
    JZ  .iniciar_poll
    IN  AL, 60h
    JMP .vaciar

.iniciar_poll:
    MOV CX, MAX_RETRY

.poll:
    IN  AL, 64h
    TEST AL, 01h
    JNZ .dato_listo
    LOOP .poll

    STI
    MOV AH, 09h
    MOV DX, msg_timeout
    INT 21h
    JMP .fin

.dato_listo:
    IN  AL, 60h
    STI
    MOV AH, 02h
    MOV DL, AL
    INT 21h

.fin:
    MOV AH, 4Ch
    INT 21h

msg_timeout DB 'Timeout: sin respuesta del dispositivo', 0Dh, 0Ah, '$'
