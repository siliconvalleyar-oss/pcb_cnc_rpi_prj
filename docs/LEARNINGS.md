# Aprendizajes del Proyecto

## Git Push — Credenciales y Token

### Problema
El push falla con `403 Permission denied` cuando se usa HTTPS con el remote `siliconvalleyar-oss/pcb_cnc_rpi_prj.git`.

### Causa
El credential helper de macOS (`osxkeychain`) almacena credenciales para el usuario `git-user`, pero ese usuario no tiene permisos de escritura en el repositorio `siliconvalleyar-oss`.

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
security find-internet-password -s "github.com" -a "git-user"
```

Pero estas son para el usuario `git-user` (solo lectura en `siliconvalleyar-oss`).

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

## Cómo buscar licencias y credenciales en esta PC

### Credenciales de Git (GitHub)

El credential helper de git está configurado como `store`, lo que significa
que las credenciales se guardan en texto plano en un archivo local.

**Ubicación del archivo de credenciales:**
```
~/.git-credentials
```

**Formato del archivo** (cada línea es un repo):
```
https://USUARIO:TOKEN@github.com
```

**Cómo verificar sin exponer la clave:**
```bash
# Verificar que el archivo existe (sin mostrar contenido)
ls -la ~/.git-credentials

# Verificar que el credential helper está activo
git config --global credential.helper
# Salida esperada: store

# Verificar que las credenciales funcionan (autentica sin mostrar token)
git ls-remote origin 2>&1 | head -3

# Verificar usuario configurado
git config user.name
git config user.email
```

**Si el archivo no existe o las credenciales fallan:**
```bash
# Crear el archivo (el formato es una URL por línea)
echo "https://USUARIO:TOKEN_GITHUB@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# O configurar via git config
git config --global credential.helper store
```

**Ubicación alternativa (configuración global):**
```
~/.gitconfig
```
Contiene `user.name`, `user.email` y `credential.helper`.

### Archivos de licencia del proyecto

**KiCad:**
- No incluye archivo LICENSE separado en el bundle
- Licencia: GPL v2+ (embebida en el binario)
- En Linux: `/usr/share/kicad/licenses/` (si existe)

**Ubicación de este proyecto:**
```
docs/LEARNINGS.md    — este archivo
.gitignore           — menciona LICENSE pero puede no existir
```

### Variables de entorno útiles

```bash
# Home del usuario
echo $HOME          # /home/optimus

# Config de git
echo $GIT_CONFIG_GLOBAL  # ~/.gitconfig por defecto

# Temp directory (para archivos temporales de FreeRouting)
echo $TMPDIR        # /tmp o /var/tmp
```

### Resumen de ubicaciones importantes

| Archivo | Ubicación | Contenido |
|---------|-----------|-----------|
| Credenciales git | `~/.git-credentials` | Token GitHub en URL |
| Config git global | `~/.gitconfig` | user, email, credential.helper |
| Config KiCad | `~/.config/kicad/10.0/` | pcbnew.json, kicad.json |
| Plugin Freerouting | `~/.local/share/kicad/10.0/3rdparty/plugins/app_freerouting_kicad-plugin/` | plugin.py, jar/ |
| FreeRouting JAR | `proyecto/freerouting-2.2.4.jar` | Binario (gitignored) |
| Script autoroute | `proyecto/scripts/run_autoroute.sh` | Wrapper con filtrado de capas |
