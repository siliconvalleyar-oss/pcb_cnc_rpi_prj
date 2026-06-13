---
name: cnc-pic32
description: Proyecto CNC con PIC32MX795F512L, drivers A4988, Zigbee MRF24J40, OLED y USB
---

# CNC PIC32 — Skill del Proyecto

## Esquematicos jerarquicos
- `cnc_pic32.kicad_sch` — raiz
- `mcu.kicad_sch` — PIC32MX795F512L
- `power.kicad_sch` — alimentacion (3.3V, 5V, 12V)
- `ft232.kicad_sch` — FT232BM (USB-UART)
- `pololu.kicad_sch` — drivers A4988 x5
- `oled.kicad_sch` — display OLED I2C
- `zigbee.kicad_sch` — modulo MRF24J40MA

## Clases de red (net classes)
| Clase      | Track Width | Clearance | Nets             |
|------------|-------------|-----------|------------------|
| Default    | 0.508 mm    | 0.382 mm  | todas las senales |
| Power_12V  | 3 mm        | 0.5 mm    | +12V             |
| Power_5V   | 1 mm        | 0.3 mm    | +5V              |
| Power_3V3  | 0.762 mm    | 0.2 mm    | +3.3V, +3V3      |

## BOM (109 componentes)
- 48 resistencias (0805/0603)
- 30 capacitores (0805)
- 12 conectores
- 5 drivers A4988
- 3 ICs (PIC32, FT232, MRF24J40)
- 2 reguladores LM1117-3.3
- 2 jumpers, 2 diodos, 2 inductores
- 1 MOSFET 2N7002, 1 cristal 6MHz, 1 switch

## PIC32 Pines libres
- Unico pin disponible: **RB4 (pin 21)** — 1 solo GPIO libre

## Reglas de diseno
- Track widths: 3mm (12V), 1mm (5V), 0.762mm (3.3V), 0.508mm (senales)
- Clearance default: 0.382mm
- Vias: 0.6mm diam / 0.4mm drill (default), 0.8mm/0.5mm (5V), 1.5mm/0.8mm (12V)

## Archivos clave
- `cnc_pic32.kicad_pcb` — PCB layout
- `cnc_pic32.kicad_sch` — esquematico raiz
- `cnc_pic32.kicad_pro` — configuracion del proyecto
- `DOCUMENTACION.md` — documentacion del proyecto
- `TODO.md` — tareas pendientes
