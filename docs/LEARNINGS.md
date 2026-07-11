# Aprendizajes del Proyecto

## Git Push — Credenciales y Token

### Problema
El push falla con `403 Permission denied` cuando se usa HTTPS con el remote `siliconvalleyar-oss/pcb_cnc_rpi_prj.git`.

### Causa
El credential helper de macOS (`osxkeychain`) almacena credenciales para el usuario `leoamayamarketing-bit`, pero ese usuario no tiene permisos de escritura en el repositorio `siliconvalleyar-oss`.

### Solución — Token en config global

El token de GitHub (`ghp_...`) está configurado en la **config global de git**:

```bash
# Verificar token (NO compartir estos datos)
git config --global --list | grep -i "user.password"
```

Salida:
```
user.password=ghp_XXXXXXX
user.name=siliconvalleyar-oss
user.email=siliconvalleyar@gmail.com
```

### Proceso de Push

```bash
# 1. Temporalmente configurar remote con token
git remote set-url origin https://siliconvalleyar-oss:<TOKEN>@github.com/siliconvalleyar-oss/pcb_cnc_rpi_prj.git

# 2. Push
git push origin kicad_v10 --tags

# 3. Limpiar remote (quitar token de la URL)
git remote set-url origin https://github.com/siliconvalleyar-oss/pcb_cnc_rpi_prj.git
```

**IMPORTANTE:** Siempre limpiar la URL después del push para no exponer el token.

### Verificación de credenciales

```bash
# Verificar remote actual
git remote -v

# Verificar usuario git
git config user.name
git config user.email

# Verificar acceso al remote
git ls-remote origin

# Verificar estado
git status
git log --oneline -5
```

## macOS Keychain

Las credenciales de GitHub se almacenan en:
```bash
security find-internet-password -s "github.com" -a "leoamayamarketing-bit"
```

Pero estas son para el usuario `leoamayamarketing-bit` (solo lectura en `siliconvalleyar-oss`).

## Version Tagging

```bash
# Ver último tag
git tag -l "v*" --sort=-version:refname | head -1

# Crear tag
git tag -a v1.0.X -m "descripcion"

# Push con tags
git push origin kicad_v10 --tags
```

## Git Config Global

Ubicación: `~/.config/git/config` o `~/.gitconfig`

```bash
# Ver configuración completa
git config --global --list

# Editar
git config --global --edit
```

## Licencias

### KiCad
- KiCad 10.0.4 usa **GPL v2+** (embebido en el binario)
- No incluye archivo LICENSE en el bundle macOS
- El archivo LICENSE del proyecto debe crearse manualmente

### Ubicación de archivos de licencia
- KiCad bundle: `/Applications/KiCad/KiCad.app/Contents/Resources/Licenses/`
- Solo contiene: `Python/LICENSE.txt` (PSF License)
- No hay licencia KiCad como archivo separado

### Proyecto
- `.gitignore` menciona `LICENSE` pero no existe
- Crear con `touch LICENSE` y agregar texto GPL v2+

## Errores Comunes

### 403 Permission denied
- Causa: usuario sin permisos de escritura
- Solución: usar token con permisos de push

### SSH Permission denied
- Causa: SSH key no configurada en la cuenta
- Solución: agregar `~/.ssh/id_ed25519.pub` en GitHub → Settings → SSH Keys

### KiCad parse error
- Causa: `knockout` no válido en PCB text
- Solución: eliminar `knockout` de los archivos .kicad_pcb
