---
name: cnc-pic32
description: Proyecto CNC con PIC32MX795F512L, drivers A4988, Zigbee MRF24J40, OLED y USB. Usar cuando se editen archivos KiCad (.kicad_pcb, .kicad_sch), se modifiquen layouts, componentes, esquematicos jerarquicos, o se resuelvan DRCs en este proyecto.
---

# CNC PIC32 — Skill del Proyecto

## Arquitectura del proyecto

### Esquematicos jerarquicos
- `cnc_pic32.kicad_sch` — raiz
- `mcu.kicad_sch` — PIC32MX795F512L
- `power.kicad_sch` — alimentacion (3.3V, 5V, 12V)
- `ft232.kicad_sch` — FT232BM (USB-UART)
  - `usb_conector_Ft232.kicad_sch` — conector USB
  - `osc_ft232.kicad_sch` — cristal FT232
  - `power_ft232.kicad_sch` — alimentacion FT232
  - `tp_ft232.kicad_sch` — test points FT232
- `pololu.kicad_sch` — drivers A4988 x5
- `oled.kicad_sch` — display OLED I2C
- `zigbee.kicad_sch` — modulo MRF24J40MA
- `oscilator.kicad_sch` — cristal principal
- `Usb_pic32.kicad_sch` — USB PIC32

### Clases de red (net classes)
| Clase      | Track Width | Clearance | Nets             |
|------------|-------------|-----------|------------------|
| Default    | 0.508 mm    | 0.382 mm  | todas las senales |
| Power_12V  | 3 mm        | 0.5 mm    | +12V             |
| Power_5V   | 1 mm        | 0.3 mm    | +5V              |
| Power_3V3  | 0.762 mm    | 0.2 mm    | +3.3V, +3V3      |

### BOM (109 componentes)
- 48 resistencias (0805/0603)
- 30 capacitores (0805)
- 12 conectores
- 5 drivers A4988
- 3 ICs (PIC32, FT232, MRF24J40)
- 2 reguladores LM1117-3.3
- 2 jumpers, 2 diodos, 2 inductores
- 1 MOSFET 2N7002, 1 cristal 6MHz, 1 switch

### PIC32 Pines libres
- Unico pin disponible: **RB4 (pin 21)** — 1 solo GPIO libre

## PCB Layout (cnc_pic32.kicad_pcb)

### Dimensiones del board
- **96mm x 96mm** con esquinas redondeadas radio 5mm
- Coordenadas: X(52-148), Y(26-122), centro=(100,74)
- Edge.Cuts: lineas + 4 arcos para esquinas redondeadas
- **NO usar `knockout`** en KiCad 10 PCB (solo valido en esquematicos)

### Componentes principales
- **U1 (PIC32MX795F512L)**: centrado en (100, 74)
- **U4 (MRF24J40MA Zigbee)**: posicion (110, 35)
  - Keepout zones: (93.56, 27.723) a (113.56, 44.723)
  - Mantener 5mm de clearance con bordes del board

### Formato de texto en PCB

#### F.Fab (silkscreen fabricacion)
```
(gr_text "TEXTO"
  (at 0 0 0)           // centrado en el board
  (layer "F.Fab")
  (uuid "...")
  (effects
    (font
      (size 0.5 0.5)   // 0.5mm tamano
      (thickness 0.15)  // 0.15mm grosor
    )
  )
)
```

#### Reference designators
```
(footprint ...
  (fp_text reference "R1"
    (at -2.0 0)        // posicion relativa al componente
    (layer "F.SilkS")
    (uuid "...")
    (effects
      (font
        (size 0.7 0.7)  // 0.7mm tamano
        (thickness 0.1)  // 0.1mm grosor
        (family "Arial") // siempre Arial
      )
    )
  )
)
```

#### SMD R/C Reference positioning
- Posicionar a **(-2.0, 0)** — lado izquierdo, 0.3mm separado del cuerpo del componente 0805
- Justify: `(justify left bottom)` para texto a la izquierda

### Reglas de diseno
- Track widths: 3mm (12V), 1mm (5V), 0.762mm (3.3V), 0.508mm (senales)
- Clearance default: 0.382mm
- Vias: 0.6mm diam / 0.4mm drill (default), 0.8mm/0.5mm (5V), 1.5mm/0.8mm (12V)

## Edicion de esquematicos KiCad 10

### Tipos de labels (importante: jerarquia)

#### `(label ...)` — Net label local
- Solo conecta dentro del sheet actual
- Sintaxis: `(label "NOMBRE" (at X Y angle) (effects ...) (uuid "..."))`

#### `(global_label ...)` — Net label global
- Conecta entre TODOS los sheets del proyecto
- Requiere `(shape input)`, `(property "Intersheetrefs" ...)`
- Sintaxis completa con Intersheetrefs

#### `(hierarchical_label ...)` — Label jerarquico
- Expone una senal como pin en el sheet symbol del padre
- Requiere `(shape input)` para funcionar
- La posicion determina donde aparece el pin en el sheet box del padre
- **NO requiere** Intersheetrefs

### Conversion de labels a hierarchical labels
Cuando se convierten labels a hierarchical labels:
1. Cambiar `(label ...)` por `(hierarchical_label "nombre" (shape input) ...)`
2. Mantener la misma posicion si esta en el endpoint del wire
3. Si el label estaba en un angulo de 180, mover al otro extremo del wire
4. Cambiar justify de `(justify right bottom)` a `(justify left)` o `(justify right)` segun orientacion
5. **Eliminar** cualquier `(global_label ...)` que este en la misma posicion (conflicto)

### Errores comunes en KiCad 10 PCB
- **`knockout`**: NO es valido en PCB text, solo en esquematicos. Causa error de parse.
- **Duplicate UUIDs**: Causa warning en DRC pero no bloquea
- **`fp_text` vs `fp_text_property`**: Usar `fp_text` para reference/value, no `fp_text_property`

## Git workflow
- Remote: `leoamayamarketing-bit/pcb_cnc_rpi_prj` (403 permission denied)
- Branch actual: `kicad_v10`
- Commits recientes: `42a93b5`, `56e6edb`, `982b61f`
- **Push bloqueado**: 403 permission denied para el remote actual

## DRC conocido
- 5 errores de short circuit
- 3 violaciones de clearance
- 226 pads sin conectar
- 6 warnings de library
- Prioridad: resolver shorts y clearance antes de routing final

## Archivos clave
- `cnc_pic32.kicad_pcb` — PCB layout
- `cnc_pic32.kicad_sch` — esquematico raiz
- `cnc_pic32.kicad_pro` — configuracion del proyecto
- `docs/DOCUMENTACION.md` — documentacion del proyecto
- `docs/TODO.md` — tareas pendientes
- `DRC.rpt` — reporte de DRC
