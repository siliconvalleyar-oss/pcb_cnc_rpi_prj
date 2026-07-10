# CNC PIC32 — Controladora CNC

Controladora CNC basada en **PIC32MX795F512L** (TQFP-100) con drivers de motores paso a paso **A4988** (Pololu breakout, x5), conectividad **Zigbee** (MRF24J40MA), display **OLED** I2C y programación/debug por **FT232BM**.

## Características

- Microcontrolador PIC32MX795F512L — MIPS32 MC4K core a 80 MHz
- 5 drivers A4988 (STEP/DIR/ENABLE) para motores paso a paso
- Módulo Zigbee MRF24J40MA (SPI4)
- Display OLED ST7789 (I2C)
- USB-UART vía FT232BM para debug/programación
- USB OTG (PIC32)
- 73 pines I/O funcionales de 100

## Arquitectura

```
FT232BM ──UART──> PIC32MX795 ──SPI──> MRF24J40MA (Zigbee)
                      │
                    I2C ────> OLED ST7789
                      │
                 STEP/DIR ──> A4988 x5 (Motores)
```

## Esquemáticos jerárquicos (KiCad)

| Archivo | Descripción |
|---------|-------------|
| `cnc_pic32.kicad_sch` | Hoja raíz |
| `mcu.kicad_sch` | PIC32MX795F512L |
| `power.kicad_sch` | Alimentación (3.3V, 5V, 12V) |
| `ft232.kicad_sch` | FT232BM (USB-UART) |
| `pololu.kicad_sch` | Drivers A4988 x5 |
| `oled.kicad_sch` | Display OLED I2C |
| `zigbee.kicad_sch` | Módulo MRF24J40MA |

## BOM — 109 componentes

48 resistencias, 30 capacitores, 12 conectores, 5 drivers A4988, 3 ICs, 2 reguladores LM1117-3.3, 2 jumpers, 2 diodos, 2 inductores, 1 MOSFET 2N7002, 1 cristal 6 MHz, 1 switch

## Net classes

| Clase | Track Width | Clearance |
|-------|-------------|-----------|
| 12V   | 3 mm        | 0.5 mm    |
| 5V    | 1 mm        | 0.3 mm    |
| 3.3V  | 0.762 mm    | 0.2 mm    |
| Señales | 0.508 mm  | 0.382 mm  |

## Interfaces

USB OTG, USB-UART (FT232), I2C (OLED), SPI4 (Zigbee), ICSP, JTAG, 5× STEP/DIR/ENABLE

## Herramientas

- **KiCad** 10.0 (formato s-expression 2026)
- **MPLAB X / XC32** — firmware

## Estado del proyecto

Ver [docs/TODO.md](docs/TODO.md) para tareas pendientes.
