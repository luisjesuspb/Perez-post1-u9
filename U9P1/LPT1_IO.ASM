; LPT1_IO.ASM - Escritura de un byte al puerto paralelo LPT1 (protocolo Centronics)
; Compila: nasm -f bin LPT1_IO.ASM -o LPT1_IO.COM

[BITS 16]
[ORG 0x100]

LPT_DATA    EQU 378h    ; Data Register
LPT_STAT    EQU 379h    ; Status Register (bit 7 = /BUSY: 1=libre, 0=ocupado)
LPT_CTRL    EQU 37Ah    ; Control Register (bit 0 = STROBE, bit 2 = /INIT)
MAX_WAIT    EQU 0FFFFh

start:
    ; Inicializar puerto: STROBE=0, /INIT=1 (04h)
    MOV DX, LPT_CTRL
    MOV AL, 04h
    OUT DX, AL

    ; Esperar a que la impresora este lista (bit 7 de 379h = 1)
    MOV CX, MAX_WAIT
.esperar_libre:
    MOV DX, LPT_STAT
    IN  AL, DX
    TEST AL, 80h        ; comprobar bit 7 (/BUSY)
    JNZ .enviar_byte    ; si bit 7 = 1, impresora libre
    LOOP .esperar_libre

    ; Si expira espera sin impresora conectada
    MOV AH, 09h
    MOV DX, msg_busy
    INT 21h
    JMP .fin

.enviar_byte:
    ; 1. Colocar caracter 'A' (41h) en Data Port (378h)
    MOV DX, LPT_DATA
    MOV AL, 'A'
    OUT DX, AL

    ; 2. Activar STROBE (bit 0 = 1, manteniendo /INIT = 1 -> 05h)
    MOV DX, LPT_CTRL
    MOV AL, 05h
    OUT DX, AL

    ; 3. Retardo corto para estabilizar pulso STROBE
    MOV CX, 0010h
.delay:
    NOP
    LOOP .delay

    ; 4. Desactivar STROBE (volver a 04h)
    MOV AL, 04h
    OUT DX, AL

    ; Confirmar envio en pantalla
    MOV AH, 09h
    MOV DX, msg_ok
    INT 21h

.fin:
    MOV AH, 4Ch
    INT 21h

msg_ok   DB 'Byte 41h (A) enviado por LPT1 con pulso STROBE.', 0Dh, 0Ah, '$'
msg_busy DB 'Error: LPT1 ocupado (BUSY=0) tras timeout.', 0Dh, 0Ah, '$'
