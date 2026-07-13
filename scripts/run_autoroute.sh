#!/bin/bash
# ─────────────────────────────────────────────────────────
# run_autoroute.sh
# Autoruta el PCB con Freerouting usando solo Top y Bottom
# ─────────────────────────────────────────────────────────
# IMPORTANTE: FreeRouting v2.2.4 NO soporta --router.layers.routable
# El flag fue documentado para una versión futura. Para restringir
# a solo Top/Bottom, este script crea un DSN temporal sin capas
# internas antes de pasárselo a FreeRouting.
#
# Uso:
#   1. Desde KiCad: Archivo → Exportar → Specctra DSN...
#      Guarda como "freerouting.dsn" en la carpeta del proyecto.
#
#   2. Ejecuta este script:
#        ./scripts/run_autoroute.sh freerouting.dsn
#
#   3. En KiCad: Archivo → Importar → Specctra Session...
#      Selecciona "freerouting.ses"
# ─────────────────────────────────────────────────────────

DSN_FILE="${1:-freerouting.dsn}"
SES_FILE="${DSN_FILE%.dsn}.ses"
JAR_FILE="freerouting-2.2.4.jar"
MODIFIED_DSN="${DSN_FILE%.dsn}_2layer.dsn"

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Freerouting - Auto-ruteo solo Top & Bottom  ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════${NC}"

# ── Verificar Python3 (necesario para modificar DSN) ─────
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Se requiere python3 para modificar el DSN.${NC}"
    echo "  Instálalo: sudo apt install python3"
    exit 1
fi

# ── Verificar que existe el JAR ──────────────────────────
if [ ! -f "$JAR_FILE" ]; then
    echo -e "${RED}✗ No se encuentra $JAR_FILE${NC}"
    echo "  Descárgalo primero:"
    echo "  wget https://github.com/freerouting/freerouting/releases/download/v2.2.4/freerouting-2.2.4.jar"
    exit 1
fi

# ── Verificar que existe el DSN ──────────────────────────
if [ ! -f "$DSN_FILE" ]; then
    echo -e "${RED}✗ No se encuentra el archivo DSN: $DSN_FILE${NC}"
    echo "  Exporta el DSN desde KiCad: Archivo → Exportar → Specctra DSN..."
    exit 1
fi

echo -e "${YELLOW}📄 DSN:${NC} $DSN_FILE"
echo -e "${YELLOW}🎯 SES:${NC} $SES_FILE"
echo ""

# ── Detectar capas de cobre (signal) en el DSN ──────────
# En el DSN de KiCad, la definición de capa está en 2 líneas:
#   (layer F.Cu
#     (type signal)
# Así que buscamos solo las líneas con "(layer <nombre>"
echo -e "${YELLOW}🔍 Detectando capas de cobre en el DSN...${NC}"
LAYER_COUNT=$(grep -cP '^\s*\(layer\s+\w' "$DSN_FILE" 2>/dev/null)
LAYER_COUNT=${LAYER_COUNT:-0}

if [ "$LAYER_COUNT" -eq 0 ] 2>/dev/null; then
    echo -e "${YELLOW}⚠ No se pudo detectar automáticamente. Asumiendo 4 capas.${NC}"
    LAYER_COUNT=4
fi

echo -e "   Capas detectadas: ${GREEN}$LAYER_COUNT${NC}"

# ── Si hay más de 2 capas, crear DSN modificado ──────────
# FreeRouting v2.2.4 NO soporta --router.layers.routable.
# Solución: eliminar las capas internas del DSN para que
# FreeRouting solo vea Top (F.Cu) y Bottom (B.Cu).
if [ "$LAYER_COUNT" -gt 2 ]; then
    echo -e "${YELLOW}⚠ Board tiene $LAYER_COUNT capas de cobre.${NC}"
    echo -e "${YELLOW}  Creando DSN temporal con solo Top (F.Cu) y Bottom (B.Cu)...${NC}"

    # Identificar capas internas (no F.Cu, no B.Cu — las últimas 2)
    # Extraer nombres de capas en orden
    LAYERS=($(grep -oP '^\s*\(layer\s+\K\S+' "$DSN_FILE" | head -n "$LAYER_COUNT"))
    FIRST="${LAYERS[0]}"
    LAST="${LAYERS[$((${#LAYERS[@]}-1))]}"

    echo -e "   Capa frontal: ${GREEN}$FIRST${NC}"
    echo -e "   Capa trasera: ${GREEN}$LAST${NC}"

    # Crear lista de capas internas a eliminar
    INNER_LAYERS=()
    for layer in "${LAYERS[@]}"; do
        if [ "$layer" != "$FIRST" ] && [ "$layer" != "$LAST" ]; then
            INNER_LAYERS+=("$layer")
        fi
    done

    if [ ${#INNER_LAYERS[@]} -gt 0 ]; then
        echo -e "   Capas internas a eliminar: ${RED}${INNER_LAYERS[*]}${NC}"

        # Copiar DSN y eliminar bloques de capas internas
        cp "$DSN_FILE" "$MODIFIED_DSN"

        for layer in "${INNER_LAYERS[@]}"; do
            # Eliminar el bloque (layer <name> ...) Y todas las referencias
            # a esa capa en keepouts, padstacks, etc.
            python3 -c "
import re, sys

layer_name = sys.argv[1]
dsn_file = sys.argv[2]

with open(dsn_file, 'r') as f:
    content = f.read()

# 1. Eliminar bloque (layer <name> ...)
pattern = r'\(\s*layer\s+' + re.escape(layer_name) + r'\s'
while True:
    match = re.search(pattern, content)
    if not match:
        break
    pos = match.start()
    depth = 0
    i = pos
    while i < len(content):
        if content[i] == '(':
            depth += 1
        elif content[i] == ')':
            depth -= 1
            if depth == 0:
                content = content[:pos] + content[i+1:]
                break
        i += 1

# 2. Eliminar líneas que contienen la referencia a la capa eliminada
# (keepout zones, padstack layer lists, etc.)
lines = content.split('\n')
filtered = []
skip_depth = 0
for line in lines:
    if skip_depth > 0:
        skip_depth += line.count('(') - line.count(')')
        if skip_depth <= 0:
            skip_depth = 0
        continue
    # Si la línea menciona la capa eliminada dentro de un scope
    if layer_name in line and '(layer' not in line:
        # Verificar si es un scope completo o múltiples líneas
        open_p = line.count('(')
        close_p = line.count(')')
        if open_p > close_p:
            skip_depth = open_p - close_p
            continue
        elif open_p == 0 and close_p == 0:
            continue  # línea suelta con referencia
        else:
            continue  # línea con más cierres que aperturas
    filtered.append(line)
content = '\n'.join(filtered)

with open(dsn_file, 'w') as f:
    f.write(content)
" "$layer" "$MODIFIED_DSN"
            echo -e "   ✓ Eliminada capa: $layer"
        done

        # Actualizar definición de via: cambiar rango [0-N] a [0-1]
        ORIG_VIA_MAX=$(($LAYER_COUNT - 1))
        sed -i "s/Via\[0-${ORIG_VIA_MAX}\]/Via[0-1]/g" "$MODIFIED_DSN"

        DSN_TO_ROUTE="$MODIFIED_DSN"
        echo -e "${GREEN}   DSN modificado: $MODIFIED_DSN${NC}"
    fi
else
    echo -e "${GREEN}✓ Board ya tiene solo 2 capas. Usando DSN original.${NC}"
    DSN_TO_ROUTE="$DSN_FILE"
fi

echo ""

# ── Ejecutar Freerouting ─────────────────────────────────
echo -e "${GREEN}🚀 Ejecutando Freerouting (máx 20 pases, 4 hilos)...${NC}"
echo ""

java -jar "$JAR_FILE" \
    -de "$DSN_TO_ROUTE" \
    -do "$SES_FILE" \
    -mp 20 \
    -mt 4 \
    --gui.enabled=false \
    --logging.file.enabled=false

EXIT_CODE=$?
echo ""

# ── Limpiar archivo temporal ─────────────────────────────
if [ -f "$MODIFIED_DSN" ]; then
    rm -f "$MODIFIED_DSN"
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Auto-ruteo completado exitosamente${NC}"
    echo -e "${GREEN}   Archivo generado: $SES_FILE${NC}"
    echo ""
    echo -e "${YELLOW}📥 Para importar en KiCad:${NC}"
    echo "   Archivo → Importar → Specctra Session..."
    echo "   Selecciona: $SES_FILE"
    echo ""
    echo -e "${YELLOW}⚠ Nota: Las pistas solo están en F.Cu y B.Cu.${NC}"
    echo "  Las capas internas (In1.Cu, In2.Cu) quedan sin rutear."
    echo "  Si necesitas planos de tierra en capas internas,"
    echo "  agrégalos manualmente en KiCad después del routing."
else
    echo -e "${RED}✗ Freerouting terminó con código $EXIT_CODE${NC}"
    echo "  Revisa los mensajes de error arriba."
fi
