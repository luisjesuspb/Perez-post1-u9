; ISRTIME.ASM - Medicion de intervalos mediante interrupcion de timer INT 1Ch (IRQ0)
; Compila: nasm -f bin ISRTIME.ASM -o ISRTIME.COM

[BITS 16]
[ORG 0x100]

start:
    MOV AX, 351Ch
    INT 21h
    MOV [old_1c], BX
    MOV [old_1c+2], ES

    CLI
    MOV DX, timer_isr
    MOV AX, 251Ch
    INT 21h
    STI

    MOV AH, 09h
    MOV DX, msg_inicio
    INT 21h

    MOV AH, 08h
    INT 21h

    CLI
    MOV BX, [ticks]
    PUSH DS
    MOV DX, [old_1c]
    MOV DS, [old_1c+2]
    MOV AX, 251Ch
    INT 21h
    POP DS
    STI

    MOV AH, 09h
    MOV DX, msg_res
    INT 21h

    MOV CX, 4
.hex_loop:
    ROL BX, 4
    MOV DL, BL
    AND DL, 0Fh
    ADD DL, '0'
    CMP DL, '9'
    JBE .print_hex
    ADD DL, 7
.print_hex:
    MOV AH, 02h
    INT 21h
    LOOP .hex_loop

    MOV AH, 09h
    MOV DX, msg_fin
    INT 21h

    MOV AH, 4Ch
    INT 21h

timer_isr:
    INC WORD [CS:ticks]
    JMP FAR [CS:old_1c]

old_1c     DD 0
ticks      DW 0
msg_inicio DB 'Timer INT 1Ch activo (18.2 ticks/s). Espera ~2s y presiona cualquier tecla...', 0Dh, 0Ah, '$'
msg_res    DB 'Ticks transcurridos (hex): ', '$'
msg_fin    DB 'h. Vector INT 1Ch restaurado.', 0Dh, 0Ah, '$'
