; ISR_KB.ASM - Rutina de Servicio de Interrupcion (ISR) personalizada para IRQ1 (INT 09h)
; Compila: nasm -f bin ISR_KB.ASM -o ISR_KB.COM

[BITS 16]
[ORG 0x100]

start:
    ; Guardar vector original de INT 09h usando DOS (AH=35h, AL=09h)
    MOV AX, 3509h
    INT 21h
    MOV [old_off], BX
    MOV [old_seg], ES

    ; Instalar nuestra ISR en INT 09h (AH=25h, AL=09h, DS:DX = nueva_isr)
    CLI
    MOV DX, nueva_isr
    MOV AX, 2509h
    INT 21h
    STI

    MOV AH, 09h
    MOV DX, msg_inicio
    INT 21h

.esperar_esc:
    CMP BYTE [salir], 1
    JNE .esperar_esc

    ; Restaurar vector original de INT 09h antes de salir
    CLI
    PUSH DS
    MOV DX, [old_off]
    MOV DS, [old_seg]
    MOV AX, 2509h
    INT 21h
    POP DS
    STI

    MOV AH, 09h
    MOV DX, msg_fin
    INT 21h

    MOV AH, 4Ch
    INT 21h

; --- Handler personalizado de IRQ1 (INT 09h) ---
nueva_isr:
    PUSH AX
    PUSH BX
    PUSH ES

    IN  AL, 60h             ; leer scancode del controlador 8042
    CMP AL, 01h             ; comprobar si es tecla ESC (scancode 01h)
    JNE .contar
    MOV BYTE [CS:salir], 1

.contar:
    ; Ignorar break codes (bit 7 = 1) para contar solo pulsaciones
    TEST AL, 80h
    JNZ .eoi

    INC BYTE [CS:contador]
    ; Mostrar contador directamente en memoria de video (fila 0, col 78)
    MOV AX, 0B800h
    MOV ES, AX
    MOV AL, [CS:contador]
    ADD AL, '0'
    MOV [ES:156], AL        ; caracter ASCII en esquina superior derecha
    MOV BYTE [ES:157], 1Eh  ; atributo amarillo sobre azul

.eoi:
    MOV AL, 20h             ; comando Non-Specific EOI
    OUT 20h, AL             ; enviar EOI al PIC 8259A maestro

    POP ES
    POP BX
    POP AX
    IRET

old_off  DW 0
old_seg  DW 0
contador DB 0
salir    DB 0
msg_inicio DB 'ISR INT 09h instalada. Presiona 5 teclas (mira arriba a la derecha) y ESC para salir...', 0Dh, 0Ah, '$'
msg_fin    DB 'Vector INT 09h restaurado correctamente.', 0Dh, 0Ah, '$'
