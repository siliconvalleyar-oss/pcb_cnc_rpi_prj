
## Cambiar fuentes de F.Silkscreen

Para cambiar únicamente las fuentes de la capa `F.Silkscreen` a Arial con tamaño 0.8mm y grosor 0.12mm sin romper la estructura del archivo `.kicad_pcb`:

```python
import re
p = 'archivo.kicad_pcb'
with open(p, encoding='utf-8') as f:
    s = f.read()

new_font = '''(font
					(face "Arial")
					(size 0.8 0.8)
					(thickness 0.12)
				)'''

result = []
i = 0
n = len(s)
while i < n:
    if s.startswith('(font', i):
        ctx = s[max(0,i-400):i]
        if '"F.SilkS"' in ctx and '"B.SilkS"' not in ctx:
            depth = 0; j = i; in_str=False; sc=None
            while j < n:
                ch = s[j]
                if in_str:
                    if ch == '\\': j+=2; continue
                    if ch == sc: in_str=False; sc=None
                    j+=1; continue
                if ch in ('"', "'"): in_str=True; sc=ch; j+=1; continue
                if ch == '(': depth += 1
                elif ch == ')':
                    depth -= 1
                    if depth == 0:
                        end = j+1; break
                j += 1
            else: break
            result.append(new_font)
            i = end
            continue
    result.append(s[i]); i += 1

with open(p, 'w', encoding='utf-8') as f:
    f.write(''.join(result))
```

Importante:
- Siempre hacer backup antes: `cp archivo.kicad_pcb archivo.kicad_pcb.bak`
- Solo reemplazar bloques `(font ...)` con contexto `F.SilkS` (no `B.SilkS`)
- Usar balanceo de paréntesis para no romper el archivo
- Verificar paréntesis: `python3 -c "s=open('archivo.kicad_pcb').read(); print(s.count('('),s.count(')'))"`
