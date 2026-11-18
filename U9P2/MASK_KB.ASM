; MASK_KB.ASM - Enmascaramiento y desenmascaramiento de IRQ1 en el PIC 8259A (puerto 21h)
; Compila: nasm -f bin MASK_KB.ASM -o MASK_KB.COM

[BITS 16]
[ORG 0x100]

PIC1_DATA   EQU 21h     ; Interrupt Mask Register (IMR) del PIC maestro

start:
    MOV AH, 09h
    MOV DX, msg_enmascarar
    INT 21h

    ; Leer IMR actual, guardar y enmascarar bit 1 (IRQ1 = teclado)
    IN  AL, PIC1_DATA
    MOV [imr_orig], AL
    OR  AL, 02h         ; bit 1 = 1 -> IRQ1 enmascarada (deshabilitada)
    OUT PIC1_DATA, AL

    ; Esperar ~3 segundos usando ticks del BIOS (0040h:006Ch, 18.2 ticks/s -> 55 ticks)
    ; IRQ0 (timer) sigue activa aunque IRQ1 (teclado) este bloqueada
    MOV AX, 0040h
    MOV ES, AX
    MOV BX, [ES:006Ch]
    ADD BX, 55          ; ~3 segundos

.esperar_ticks:
    MOV AX, [ES:006Ch]
    CMP AX, BX
    JB  .esperar_ticks

    ; Vaciar cualquier scancode que el 8042 retuvo mientras IRQ1 estaba enmascarada
.drenar_8042:
    IN  AL, 64h
    TEST AL, 01h
    JZ  .restaurar_imr
    IN  AL, 60h
    JMP .drenar_8042

.restaurar_imr:
    ; Desenmascarar IRQ1 restaurando bit 1 = 0
    IN  AL, PIC1_DATA
    AND AL, 0FDh        ; bit 1 = 0 -> IRQ1 habilitada nuevamente
    OUT PIC1_DATA, AL

    MOV AH, 09h
    MOV DX, msg_restaurado
    INT 21h

    MOV AH, 4Ch
    INT 21h

imr_orig       DB 0
msg_enmascarar DB 'IRQ1 enmascarada en IMR (puerto 21h, bit 1=1). Teclado bloqueado por 3s...', 0Dh, 0Ah, '$'
msg_restaurado DB 'IRQ1 desenmascarada (bit 1=0). Teclado habilitado nuevamente.', 0Dh, 0Ah, '$'
