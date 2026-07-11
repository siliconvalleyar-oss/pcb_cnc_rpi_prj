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
  - `usb_conector_Ft232.kicad_sch` — conector USB (J4, J5, J15)
  - `osc_ft232.kicad_sch` — cristal FT232
  - `power_ft232.kicad_sch` — alimentacion FT232
  - `tp_ft232.kicad_sch` — test points FT232 (J6-J16, J18)
- `pololu.kicad_sch` — drivers A4988 x5 (A1-A5), conector J17
- `oled.kicad_sch` — display OLED I2C
- `zigbee.kicad_sch` — modulo MRF24J40MA
- `oscilator.kicad_sch` — cristal principal
- `Usb_pic32.kicad_sch` — USB PIC32 (J18, TP17)

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
- **J2 (USB Mini-B)**: posicion (61.1975, 29.268) — desbloqueado
- **U3 (LQFP-32)**: posicion (62, 40, rot90) — desbloqueado

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

### Sheet pins en el padre
- Los sheet pins en el padre deben coincidir EXACTAMENTE con los hierarchical labels del hijo
- Formato: `(pin "nombre" input (at X Y angle) (uuid "...") (effects ...))`
- Los pins se colocan en los bordes del sheet box
- El sheet box debe ser lo suficientemente grande para contener todos los pins

### Pololu sheet — 5 drivers A4988
Cada Pololu (A1-A5) tiene 5 signals individuales:
- `reset_N`, `sleep_N`, `enable_N`, `step_N`, `dir_N` (donde N = 1-5)

**Posiciones de los Pololos:**
| Ref | Centro X | Pin X (left) | Label X |
|-----|----------|-------------|---------|
| A1  | 78.74    | 68.58       | 63.50   |
| A2  | 119.38   | 109.22      | 104.14  |
| A3  | 153.67   | 143.51      | 138.43  |
| A4  | 193.04   | 182.88      | 177.80  |
| A5  | 227.33   | 217.17      | 212.09  |

**Pin offsets del Pololu A4988 (relativo al centro):**
- RESET:  (-10.16, +10.16) → pin 13
- SLEEP:  (-10.16, +7.62)  → pin 14
- ENABLE: (-10.16, +2.54)  → pin 9
- STEP:   (-10.16, 0)      → pin 15
- DIR:    (-10.16, -2.54)  → pin 16

**Formato del hierarchical label:**
```
(hierarchical_label "reset_1"
  (shape input)
  (at 63.50 74.93 180)
  (effects
    (font
      (size 1.27 1.27)
    )
    (justify right)
  )
  (uuid "...")
)
```

**Formato del wire:**
```
(wire
  (pts
    (xy 63.50 74.93) (xy 68.58 74.93)
  )
  (stroke
    (width 0)
    (type default)
  )
  (uuid "...")
)
```

**Sheet box en el padre:**
- Posicion: (96.52, 166.37)
- Size: (54.61, 66.04) — 25 pins x 2.54mm + margen
- 25 sheet pins en el borde izquierdo (x=96.52)

### Errores comunes en KiCad 10 PCB
- **`knockout`**: NO es valido en PCB text, solo en esquematicos. Causa error de parse.
- **Duplicate UUIDs**: Causa warning en DRC pero no bloquea
- **`fp_text` vs `fp_text_property`**: Usar `fp_text` para reference/value, no `fp_text_property`

### Footprints del proyecto
- **Library** (custom): `/Users/bee/Documents/KiCad/Ohers_&_Olds/rpi_z_tft/Library.pretty`
- **fp-lib-table**: una sola libreria "Library"
- Footprints disponibles en Library:
  - `connector_pin1` — pin de prueba individual
  - `PinHeader_1x06_P2.54mm_Vertical` — header 6 pines
  - `SW_SPST_CK_RS282G05A3` — switch SMD
  - `SW_Push_1P1T_NO_6x6mm_H9.5mm` — pushbutton (NO usar, reemplazado)

### Asignacion de footprints
| Componente | Footprint anterior | Footprint actual |
|------------|-------------------|------------------|
| J6-J16 (test points) | kiC:pad_0508 | Library:connector_pin1 |
| J18 (tp_ft232) | kiC:pad_0508 | Library:connector_pin1 |
| J4, J15 (usb_conector_Ft232) | kiC:Pin_D1.5mmx1mm | Library:connector_pin1 |
| TP17 (Usb_pic32) | kiC:Pin_D1.5mmx1mm | Library:connector_pin1 |
| J17 (pololu) | kiC:PinHeader_1x06_P2.54mm_Vertical | Library:PinHeader_1x06_P2.54mm_Vertical |
| SW1-SW5 (buttons) | kiC:SW_Push_1P1T_NO_6x6mm_H9.5mm | Button_Switch_SMD:SW_SPST_CK_RS282G05A3 |
| J5 (USB) | pin "6" en schematic | pin "SH" (match footprint) |
| J18 (USB) | pin "6" en schematic | pin "SH" (match footprint) |

### USB Mini-B — pin naming
- El footprint `USB_Mini-B_Wuerth_65100516121_Horizontal` tiene pads 1-5 + "SH" (shield)
- El symbol `USB_B_Mini` tiene pin "6" para shield
- **Fix**: Renombrar pin `"6"` → `"SH"` en el schematic para matchear el footprint

## Lock/Unlock en PCB Editor
- **Selection Filter** (esquina inferior derecha) → marcar **"Locked Items"**
- Con "Locked Items" habilitado: click derecho → Properties → desmarcar "Locked"
- O seleccionar + presionar `L` para toggle lock/unlock
- Sin "Locked Items" habilitado, no se pueden seleccionar componentes bloqueados

## Git workflow
- Remote: `siliconvalleyar-oss/pcb_cnc_rpi_prj`
- Branch actual: `kicad_v10`
- **Version tagging**: usar formato `v1.X.Y` (major.minor.patch). Tags en orden cronológico: v1.0.1→v1.1.10
- **Tag order**: v1.0.x = setup, v1.1.x = features/fixes
- **Push credentials**: `git config --global user.password` → token GitHub
- **Push workflow**:
  ```bash
  git remote set-url origin https://siliconvalleyar-oss:<TOKEN>@github.com/siliconvalleyar-oss/pcb_cnc_rpi_prj.git
  git push origin kicad_v10 --tags
  git remote set-url origin https://github.com/siliconvalleyar-oss/pcb_cnc_rpi_prj.git
  ```

### Comando para commit + tag
```bash
git add <files>
git commit -m "tipo: descripcion"
git tag -a v1.X.Y -m "descripcion del tag"
# push con token
```

## Reglas de ruteo (net classes)

| Net Class | Track Width | Via Ø | Drill | Clearance | Uso |
|-----------|-------------|-------|-------|-----------|-----|
| `power` | 1.27mm | 1.2mm | 0.7mm | 0.2mm | +12V, GND (high current) |
| `power5V` | 0.762mm | 1.2mm | 0.7mm | 0.2mm | +5V, V+_USB |
| `power3V3` | 0.508mm | 0.9mm | 0.5mm | 0.2mm | +3.3V, +3V3 |
| `motor` | 0.762mm | 0.9mm | 0.5mm | 0.2mm | A4988 coils (A1-A5) |
| `usb_differential` | 0.254mm | 0.6mm | 0.3mm | 0.15mm | USB D+/D- (matched pairs) |
| `signal` | 0.254mm | 0.6mm | 0.3mm | 0.127mm | MCU, FT232, IDC, I2C, SPI |
| `rf` | 3.62mm | 1.2mm | 0.7mm | 0.127mm | Zigbee MRF24J40 antenna |
| `Default` | 0.25mm | 0.8mm | 0.4mm | 0.127mm | Fallback |

### Asignacion de nets
- **power**: GND, +12V
- **power5V**: +5V, V+_USB, /Ft232/V+_USB, /Ft232/tp_ft232/+5v
- **power3V3**: +3V3, +3.3V
- **motor**: Net-(A1-A5-*), Net-(U3-AVCC), Net-(U3-~{SLEEP})
- **usb_differential**: /MCU/D+, /MCU/D-, Net-(J2-D+), Net-(J2-D-), Net-(J5-D+), Net-(J5-D-), Net-(J4-D-)
- **signal**: /MCU/*, /Ft232/*, /idc/*, RXD, TXD, RX_Rpi, TX_Rpi, SW_PWR
- **rf**: /RF, RF

### Track widths disponibles
0.127mm, 0.254mm, 0.508mm, 0.762mm, 1.0mm, 1.27mm, 1.5mm, 2.54mm, 3.0mm, 5.0mm

## DRC conocido
- **0 errores DRC** (sin shorts, sin violaciones de clearance)
- **306 pads sin conectar** — normal antes de routing
- **Duplicate references**: C7 y JP1 estaban duplicados en PCB (huérfanos) — corregido en v1.1.9
- **Freerouting**: requiere Java 25+ (instalar `brew install --cask temurin@25`)

### Freerouting workflow
1. En KiCad PCB Editor: `File → Export → Specctra DSN...`
2. Ejecutar Freerouting con el archivo DSN
3. Después del routing, importar de vuelta a KiCad
4. Ajustar differential pairs USB manualmente en KiCad

### Limitaciones Freerouting
- No tiene "bus routing" — cada net se rutea individualmente
- No hace matched-length automáticamente
- Para USB differential pairs: usar `Route → Interactive Differential Pair Tuning` en KiCad

## Tareas pendientes
- [ ] Definir reglas de bus routing (USB, I2C, SPI) para Freerouting
- [ ] Agregar GND pour pour plan
- [ ] Verificar clearance final tras routing

## Archivos clave
- `cnc_pic32.kicad_pcb` — PCB layout
- `cnc_pic32.kicad_sch` — esquematico raiz
- `cnc_pic32.kicad_pro` — configuracion del proyecto
- `pololu.kicad_sch` — 5 drivers A4988 + 25 hierarchical labels
- `tp_ft232.kicad_sch` — test points FT232
- `usb_conector_Ft232.kicad_sch` — USB FT232
- `Usb_pic32.kicad_sch` — USB PIC32
- `buttons.kicad_sch` — switches
- `docs/DOCUMENTACION.md` — documentacion del proyecto
- `docs/TODO.md` — tareas pendientes
- `DRC.rpt` — reporte de DRC
- `VERSION` — archivo de version
