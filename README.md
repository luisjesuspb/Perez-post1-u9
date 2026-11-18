# Unidad 9: Entrada y Salida Avanzados (Arquitectura de Computadores)

Repositorio de laboratorio en ensamblador x86 de 16 bits (NASM 2.16.03 sobre DOSBox 0.74) enfocado en comunicación directa con controladores de E/S mediante **E/S programada (Polling)** e **Interrupciones de Hardware (PIC 8259A / IVT)**.

---

## Parte 1: E/S Programada y Polling (`U9P1/`)

### 1. Resumen de Programas Implementados
* **`TECL.ASM` (`TECL.COM`)**: Lectura directa del *scancode* desde el puerto de datos `60h` del controlador de teclado Intel 8042 tras verificar el bit 0 (`OBF` — *Output Buffer Full*) en el registro de estado `64h`, mostrando el valor en hexadecimal.
* **`POLL_T.ASM` (`POLL_T.COM`)**: Implementación de sondeo acotado por tiempo mediante el registro `CX` (`MAX_RETRY = 0005h` con instrucción `LOOP`) para evitar bloqueos indefinidos cuando no hay respuesta del dispositivo.
* **`LPT1_IO.ASM` (`LPT1_IO.COM`)**: Transmisión de un carácter (`41h` / `'A'`) por el puerto paralelo `LPT1` siguiendo el protocolo Centronics: verificación de línea libre (`/BUSY`, bit 7 de `379h`), escritura en `378h` y generación de pulso `STROBE` (bit 0 de `37Ah`) con retardo por software.
* **`MULTI_ST.ASM` (`MULTI_ST.COM`)**: Sondeo multiplexado simultáneo sobre el controlador 8042 (`64h`) y el puerto paralelo (`379h`), combinando las máscaras de estado mediante la operación lógica `OR` para despachar el primer dispositivo listo sin monopolizar la CPU.

### 2. Decisiones Técnicas Relevantes
* **Aislamiento de interrupciones (`CLI`/`STI`)**: Durante el sondeo directo del puerto `64h/60h`, se deshabilitaron temporalmente las interrupciones enmascarables para evitar que la rutina `INT 09h` del BIOS consumiera el *scancode* antes de que el bucle de polling detectara `OBF=1`.
* **Limpieza de búfer residual**: Al lanzar programas `.COM` desde el intérprete de comandos, el *break code* de la tecla `Enter` (`9Ch`) permanece brevemente en el registro de salida del 8042; se incorporó una rutina de drenaje inicial para garantizar mediciones limpias de *timeout* y *polling* múltiple.
* **Evasión de dispositivos reservados de DOS/Windows**: Dado que `LPT1` es un nombre reservado del sistema operativo (`\\.\LPT1`), el módulo del puerto paralelo se nombró `LPT1_IO` para evitar colisiones de redirección de dispositivos durante la compilación y ejecución.

### 3. Evidencias Parte 1 (`capturas/`)
* **Checkpoint 1 (`TECL`):** `p1_cp1_1_tecl_ejecucion.png`, `p1_cp1_2_tecl_dir.png`
* **Checkpoint 2 (`POLL_T`):** `p1_cp2_1_poll_timeout.png`, `p1_cp2_2_poll_dir.png`
* **Checkpoint 3 (`LPT1_IO`):** `p1_cp3_1_lpt1_ejecucion.png`, `p1_cp3_2_lpt1_dir.png`
* **Checkpoint 4 (`MULTI_ST`):** `p1_cp4_1_multi_ejecucion.png`, `p1_cp4_2_multi_dir.png`
