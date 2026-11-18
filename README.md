# Unidad 9: Entrada y Salida Avanzados (Arquitectura de Computadores)

Repositorio de laboratorio en ensamblador x86 de 16 bits (NASM 2.16.03 sobre DOSBox 0.74) enfocado en comunicación directa con controladores de E/S mediante **E/S programada (Polling)** e **Interrupciones de Hardware (PIC 8259A / IVT)**.

---

## Parte 1: E/S Programada y Polling (`U9P1/`)

### 1. Programas Implementados
* **`TECL.ASM` (`TECL.COM`)**: Lectura directa del *scancode* desde el puerto de datos `60h` del controlador Intel 8042 tras verificar `OBF=1` (bit 0) en el registro de estado `64h`, mostrando el valor en hexadecimal.
* **`POLL_T.ASM` (`POLL_T.COM`)**: Sondeo acotado por tiempo mediante `CX` (`MAX_RETRY = 0005h` con `LOOP`) para evitar bloqueos indefinidos cuando no hay respuesta del dispositivo.
* **`LPT1_IO.ASM` (`LPT1_IO.COM`)**: Transmisión de `'A'` (`41h`) por el puerto paralelo `LPT1` bajo el protocolo Centronics: verificación de `/BUSY=1` (bit 7 de `379h`), escritura en `378h` y pulso `STROBE` (bit 0 de `37Ah`).
* **`MULTI_ST.ASM` (`MULTI_ST.COM`)**: Sondeo multiplexado simultáneo sobre el controlador 8042 (`64h`) y el puerto paralelo (`379h`), combinando máscaras mediante `OR` para atender el primer dispositivo listo sin monopolizar la CPU.

### 2. Decisiones Técnicas Parte 1
* **Aislamiento con `CLI`/`STI`**: Evita que `INT 09h` del BIOS consuma el *scancode* antes de que el bucle de *polling* detecte `OBF=1`.
* **Limpieza de búfer residual**: Drena el *break code* de la tecla `Enter` (`9Ch`) al iniciar el `.COM` para mediciones limpias de *timeout* y *polling* múltiple.
* **Nomenclatura compatible MS-DOS 8.3 y dispositivos reservados**: Se nombró `LPT1_IO` para evitar conflictos con el dispositivo reservado `LPT1` (`\\.\LPT1`), y se respetó el límite 8.3 de MS-DOS en todos los binarios.

---

## Parte 2: Interrupciones de Hardware — PIC 8259A e IVT (`U9P2/`)

### 1. Programas Implementados
* **`ISR_KB.ASM` (`ISR_KB.COM`)**: Reemplazo temporal del vector `INT 09h` (`IRQ1`) mediante los servicios DOS `35h` y `25h`. Lee el *scancode* en `60h`, actualiza un contador directo en memoria de video (`0B800h`), envía `Non-Specific EOI` (`20h`) al PIC maestro (`20h`) y restaura el vector original al pulsar `ESC`.
* **`MASK_KB.ASM` (`MASK_KB.COM`)**: Manipulación directa del *Interrupt Mask Register* (IMR, puerto `21h`) del PIC 8259A para enmascarar `IRQ1` (`OR AL, 02h`) durante 3 segundos medidos con *ticks* del BIOS (`0040h:006Ch`) y desenmascararla (`AND AL, 0FDh`) tras drenar el 8042.
* **`ISRCHAIN.ASM` (`ISRCHAIN.COM`)**: Encadenamiento de `INT 09h` (*ISR Chaining*). Actualiza un indicador visual en `0B800h` sin leer `60h` ni emitir `EOI`, delegando la ejecución mediante `JMP FAR` a la rutina original del BIOS.
* **`ISRTIME.ASM` (`ISRTIME.COM`)**: Enganche de la interrupción periódica `INT 1Ch` (`IRQ0`, 18.2 *ticks*/s) para medir sin *polling* el intervalo exacto en *ticks* hasta la pulsación de una tecla.

---

## Comparativa: E/S Programada (Polling) vs. Interrupciones

| Criterio | E/S Programada (Polling — Parte 1) | Interrupciones (PIC 8259A / IVT — Parte 2) |
| :--- | :--- | :--- |
| **Uso de CPU** | Alto (espera activa en bucles `IN`/`TEST`/`JZ`). | Mínimo (CPU libre hasta que `IRQ` dispara la ISR). |
| **Latencia** | Depende de la frecuencia del bucle de sondeo. | Determinista e inmediata ante señal eléctrica `IRQ`. |
| **Complejidad** | Baja; flujo secuencial sin cambio de contexto. | Mayor; requiere preservar registros, `IRET`, `EOI` y restaurar IVT. |
| **Control de prioridad** | Definido por el orden de evaluación en software (`OR`). | Gestionado por hardware en el PIC 8259A (`IRQ0` > `IRQ1`) y el IMR (`21h`). |

---

## Evidencias (`capturas/`)
* **Checkpoint 1 (`TECL`):** `p1_cp1_1_tecl_ejecucion.png`, `p1_cp1_2_tecl_dir.png`
* **Checkpoint 2 (`POLL_T`):** `p1_cp2_1_poll_timeout.png`, `p1_cp2_2_poll_dir.png`
* **Checkpoint 3 (`LPT1_IO`):** `p1_cp3_1_lpt1_ejecucion.png`, `p1_cp3_2_lpt1_dir.png`
* **Checkpoint 4 (`MULTI_ST`):** `p1_cp4_1_multi_ejecucion.png`, `p1_cp4_2_multi_dir.png`
* **Checkpoint 5 (Docs P1):** `p1_cp5_1_git_log.png`, `p1_cp5_2_readme_estructura.png`
* **Checkpoint 6 (`ISR_KB`):** `p2_cp6_1_isr_kb_ejecucion.png`, `p2_cp6_2_isr_kb_dir.png`
* **Checkpoint 7 (`MASK_KB`):** `p2_cp7_1_mask_kb_ejecucion.png`, `p2_cp7_2_mask_kb_dir.png`
* **Checkpoint 8 (`ISRCHAIN`):** `p2_cp8_1_isr_chain_ejecucion.png`, `p2_cp8_2_isr_chain_dir.png`
* **Checkpoint 9 (`ISRTIME`):** `p2_cp9_1_isr_time_ejecucion.png`, `p2_cp9_2_isr_time_dir.png`
* **Checkpoint 10 (Cierre):** `p2_cp10_1_git_log_final.png`, `p2_cp10_2_github_repo.png`
