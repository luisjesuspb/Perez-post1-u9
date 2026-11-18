; ISRCHAIN.ASM - Encadenamiento de ISR (INT 09h) hacia el handler original del BIOS
; Compila: nasm -f bin ISRCHAIN.ASM -o ISRCHAIN.COM

[BITS 16]
[ORG 0x100]

start:
    MOV AX, 3509h
    INT 21h
    MOV [old_isr], BX
    MOV [old_isr+2], ES

    CLI
    MOV DX, chain_isr
    MOV AX, 2509h
    INT 21h
    STI

    MOV AH, 09h
    MOV DX, msg_inicio
    INT 21h

.leer_teclas:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JNE .leer_teclas

    CLI
    PUSH DS
    MOV DX, [old_isr]
    MOV DS, [old_isr+2]
    MOV AX, 2509h
    INT 21h
    POP DS
    STI

    MOV AH, 09h
    MOV DX, msg_fin
    INT 21h

    MOV AH, 4Ch
    INT 21h

chain_isr:
    PUSH AX
    PUSH ES

    INC BYTE [CS:irq_count]
    MOV AX, 0B800h
    MOV ES, AX
    MOV AL, [CS:irq_count]
    AND AL, 0Fh
    ADD AL, '0'
    CMP AL, '9'
    JBE .mostrar
    ADD AL, 7
.mostrar:
    MOV [ES:158], AL
    MOV BYTE [ES:159], 2Fh

    POP ES
    POP AX
    JMP FAR [CS:old_isr]

old_isr    DD 0
irq_count  DB 0
msg_inicio DB 'ISR encadenada activa (indicador verde arriba a la derecha). Escribe algo y pulsa ENTER:', 0Dh, 0Ah, '$'
msg_fin    DB 0Dh, 0Ah, 'ISR desencadenada y vector INT 09h restaurado.', 0Dh, 0Ah, '$'
