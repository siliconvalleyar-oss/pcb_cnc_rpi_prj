# CNC PIC32 — Tareas Pendientes

## Rutado del PCB
- [x] Definir clases de red (net classes): power, power5V, power3V3, motor, usb_differential, signal, rf
- [x] Eliminar referencias duplicadas C7 y JP1 (huérfanos en PCB)
- [x] Generar DSN para Freerouting
- [x] Corregir script run_autoroute.sh para restringir a Top/Bottom (v2.2.4 no soporta --router.layers.routable)
- [ ] Rutar con Freerouting (usar ./scripts/run_autoroute.sh)
- [ ] Definir reglas de bus routing para Freerouting (USB, I2C, SPI)
- [ ] Ajustar differential pairs USB manualmente en KiCad
- [ ] Rutar pistas de potencia (12V, 5V, GND) con el ancho asignado
- [ ] Rutar pistas de señales (3.3V, I2C, SPI, UART, GPIO)
- [ ] Verificar clearance y espaciado entre pistas
- [ ] Agregar planos de tierra (GND pour) en ambas caras

## Esquematico
- [ ] Verificar que todos los componentes tienen valor asignado (109 componentes OK)
- [ ] Revisar el pin libre RB4 (pin 21 del PIC32) — asignar o dejar como reserva
- [ ] Documentar conexiones de alimentaci n en el esquematico

## Microcontrolador PIC32MX795F512L
- [x] Identificar pines conectados vs libres
- [x] Solo RB4 (pin 21) disponible sin conectar
- [ ] Decidir uso del pin RB4 (GPIO adicional, interrupci n externa, etc.)

## Interfaces / Perif ricos
- [ ] USB OTG — verificar protecci n ESD y terminaci n
- [ ] I2C (OLED + sensores) — pull-ups verificados
- [ ] SPI (MRF24J40 Zigbee) — verificar integridad de se al
- [ ] UARTs (FT232, RP2040, debug) — cruce TX/RX verificado
- [ ] Stepper drivers (A4988 x5) — verificar conexiones STEP/DIR/ENABLE

## BOM / Componentes
- [x] Generar BOM completo (109 componentes)
- [x] Todos los resistores tienen valor
- [ ] Verificar voltaje y corriente de los reguladores LM1117-3.3 (U3, U5)
- [ ] Confirmar footprint de todos los componentes

## Fabricaci n
- [ ] Verificar reglas de dise o (DRC)
- [ ] Generar archivos Gerber
- [ ] Generar archivos de taladro (Excellon)
- [ ] Revisar plano de fabricaci n (Edge.Cuts, dimensiones)
- [ ] Cotizar con fabricante

## Firmware
- [ ] Configurar osciladores (primario 8MHz, secundario 32.768kHz)
- [ ] Configurar perif ricos: USB, I2C, SPI, UART, GPIO
- [ ] Inicializar stepper drivers (A4988)
- [ ] Comunicaci n con MRF24J40 (Zigbee)
- [ ] Control de OLED por I2C
- [ ] Interfaz USB (FT232)
- [ ] Protocolo de control CNC (G-code?)
