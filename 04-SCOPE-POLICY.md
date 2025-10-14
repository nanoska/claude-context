# 🔒 Scope Policy - Restricciones de Acceso a Directorios

## 🎯 Regla de Oro

**NUNCA acceder a directorios fuera del proyecto root sin consultar explícitamente al usuario con justificación clara y visible.**

---

## 📍 ¿Qué es el "Proyecto Root"?

El proyecto root es el directorio base donde vive el proyecto actual.

### Ejemplo de Jerarquía

```
/home/nano/nahue/satori/porfolio/portfolio-apps/     ← Portfolio (fuera de alcance)
└── mi-proyecto/                                      ← Tu proyecto root ✅
    ├── mi-proyecto-main/                             ← Worktree main ✅
    ├── mi-proyecto-backend/                          ← Worktree backend ✅
    ├── mi-proyecto-frontend/                         ← Worktree frontend ✅
    └── mi-proyecto-infra/                            ← Worktree infra ✅
```

**Tu alcance:** Dentro de `mi-proyecto/` y sus subdirectorios
**Fuera de alcance:** `portfolio-apps/`, `porfolio/`, otros proyectos

---

## 🚦 Niveles de Acceso

### Nivel 1: Acceso Libre 🟢 (Verde)

Puedes leer y escribir **sin restricciones ni consultas**.

**Alcance:**
- Tu worktree asignado
- Ejemplo: Desde `proyecto-backend/`, puedes modificar `backend/**`

**Criterio:**
```bash
if [[ $FILE == $(pwd)/* ]]; then
  echo "🟢 ACCESO LIBRE"
fi
```

**Acciones permitidas:**
- Read, Write, Edit, Execute
- Commits, pushes
- Crear/eliminar archivos

### Nivel 2: Acceso con Consulta 🟡 (Amarillo)

Puedes **LEER libremente**, pero **DEBES CONSULTAR antes de MODIFICAR**.

**Alcance:**
- Archivos compartidos del proyecto (docker-compose.yml, .env)
- Otros worktrees del mismo proyecto
- Ejemplo: Desde `backend/`, leer `../frontend/` para coordinación

**Criterio:**
```bash
if [[ $FILE == $PROJECT_ROOT/* ]] && [[ $FILE != $(pwd)/* ]]; then
  echo "🟡 LECTURA LIBRE, CONSULTA PARA MODIFICAR"
fi
```

**Formato de consulta:**

```markdown
🟡 CONSULTA REQUERIDA

**Archivo:** docker-compose.yml
**Acción:** write (modificar)
**Motivo:** Necesito agregar variable DB_POOL_SIZE para optimizar backend
**Impacto:** Afecta a infra agent (dueño del archivo)
**Alternativa:** Usar valor por defecto (menos óptimo)

¿Apruebas esta modificación?
```

### Nivel 3: Acceso Prohibido 🔴 (Rojo)

**SIEMPRE consultar** antes de acceder (incluso para leer).

**Alcance:**
- Directorios fuera del proyecto root
- Ejemplo: `../../otro-proyecto/`, `/home/nano/nahue/satori/porfolio/CLAUDE.md`
- Archivos del sistema (`/etc/`, `/usr/`, etc.)

**Criterio:**
```bash
if [[ $FILE != $PROJECT_ROOT/* ]]; then
  echo "🔴 ACCESO EXTERNO - CONSULTA OBLIGATORIA"
fi
```

**Formato de consulta obligatoria:**

```markdown
🔴 SOLICITUD DE ACCESO EXTERNO

**Archivo solicitado:** /home/nano/nahue/satori/porfolio/CLAUDE.md

**Motivo:** Necesito leer las convenciones generales del portfolio
           para aplicar el mismo estilo de documentación en este
           proyecto y mantener consistencia.

**Alternativa considerada:** Podría crear documentación desde cero,
           pero sería inconsistente con otros proyectos del portfolio
           y perdería tiempo duplicando información existente.

**Acción:** read (solo lectura)

**Impacto:** Ninguno - solo lectura de referencia

¿Apruebas este acceso? (sí/no)
```

---

## 🛡️ Validación Automática

### Script: verify-scope.sh

Antes de acceder a cualquier archivo, ejecuta:

```bash
bash context/templates/verify-scope.sh <archivo> <tipo-agente>

# Ejemplos:
bash verify-scope.sh backend/models.py backend
# → 🟢 ACCESO PERMITIDO

bash verify-scope.sh docker-compose.yml backend
# → 🟡 CONSULTA REQUERIDA

bash verify-scope.sh /home/user/otro-proyecto/file.py backend
# → 🔴 ACCESO EXTERNO DETECTADO
```

### Validación Mental (Algoritmo)

Antes de cada Read/Write/Edit, ejecuta mentalmente:

```python
def check_access(file_path, agent_type, action):
    current_dir = os.getcwd()
    project_root = find_git_root() or current_dir
    abs_path = os.path.abspath(file_path)

    # Nivel 1: Dentro de mi worktree
    if abs_path.startswith(current_dir):
        return "🟢 ACCESO LIBRE"

    # Nivel 2: Dentro del proyecto pero otro worktree
    elif abs_path.startswith(project_root):
        if action == "read":
            return "🟢 LECTURA PERMITIDA"
        else:
            return "🟡 CONSULTA REQUERIDA PARA MODIFICAR"

    # Nivel 3: Fuera del proyecto
    else:
        return "🔴 CONSULTA OBLIGATORIA"
```

---

## 🎯 Detección de Proyecto Root

### Método 1: Git Repository

```bash
# Detectar automáticamente
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$PROJECT_ROOT" ]; then
  # No hay git, usar directorio actual
  PROJECT_ROOT=$(pwd)
fi

echo "📍 Tu proyecto root es: $PROJECT_ROOT"
echo "🔒 No accedas fuera de este directorio sin consultar"
```

### Método 2: Variable de Entorno

El `init-project.sh` puede configurar:

```bash
export PROJECT_ROOT="/home/nano/nahue/satori/porfolio/portfolio-apps/mi-proyecto"
```

### Método 3: Archivo Marker

Buscar `CLAUDE.md` en directorios superiores:

```bash
find_project_root() {
  local dir=$(pwd)
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/CLAUDE.md" ]]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo $(pwd)  # Fallback
}
```

---

## 📋 Casos Especiales

### Caso 1: Context Directory (context/)

**Regla:**
- ✅ **Lectura SIEMPRE permitida** (es documentación de referencia)
- ❌ **Modificación PROHIBIDA** sin aprobación explícita

**Justificación:**
- Context es la fuente de verdad
- Cambios deben ser coordinados
- Afecta a todos los proyectos

**Ejemplo:**

```bash
# ✅ PERMITIDO
cat context/02-CORE-STANDARDS.md

# 🔴 PROHIBIDO sin consulta
vim context/02-CORE-STANDARDS.md
```

### Caso 2: Worktrees Hermanos

**Regla:**
- ✅ **Lectura permitida** para coordinación
- 🟡 **Modificación requiere consulta** (propiedad de otro agente)

**Ejemplo:**

```bash
# Desde proyecto-backend/

# ✅ PERMITIDO: Leer para entender integración
cat ../proyecto-frontend/src/services/api.ts

# 🟡 CONSULTA: Modificar archivo de otro worktree
echo "🟡 CONSULTA REQUERIDA
Archivo: ../proyecto-frontend/src/services/api.ts
Motivo: Necesito agregar endpoint /api/v2/users que frontend debe consumir
¿Apruebo modificar archivo de frontend desde backend?"
```

### Caso 3: Archivos Compartidos del Proyecto

**Archivos típicamente compartidos:**
- `docker-compose.yml` (propiedad: infra)
- `.env` (configuración global)
- `README.md` (documentación)
- `package.json` (dependencias)
- `requirements.txt` (dependencias)

**Regla:**
- ✅ **Lectura permitida**
- 🟡 **Modificación requiere consulta al dueño**

**Ejemplo:**

```markdown
🟡 CONSULTA - Archivo Compartido

**Archivo:** docker-compose.yml
**Dueño:** infra agent
**Solicita:** backend agent
**Motivo:** Necesito agregar variable DB_MAX_CONNECTIONS=100
**Impacto:** Configuración de base de datos
**Alternativa:** Usar valor por defecto (50 connections, insuficiente)

@infra-agent ¿Apruebas este cambio?
```

### Caso 4: Archivos del Sistema

**Ejemplos:**
- `/etc/hosts`
- `/usr/local/bin/`
- `/var/log/`
- `~/.bashrc`

**Regla:**
- 🔴 **SIEMPRE PROHIBIDO** a menos que sea absolutamente necesario
- Requiere justificación **muy robusta**

**Ejemplo de solicitud válida:**

```markdown
🔴 SOLICITUD DE ACCESO AL SISTEMA

**Archivo:** /etc/hosts
**Motivo:** Necesito agregar entrada para testing de dominio local
          en desarrollo: 127.0.0.1 mi-proyecto.local
**Alternativa:** Usar localhost:8000 (menos realista para testing)
**Riesgo:** Bajo - solo agrega alias local
**Reversible:** Sí - puedo eliminar entrada después

¿Apruebas? (sí/no)
```

---

## 🎨 Formato Visual de Consultas

### Template Completo de Consulta (Copiar y Pegar)

```markdown
🔴 SOLICITUD DE ACCESO EXTERNO

**📁 Archivo solicitado:**
[Ruta absoluta del archivo]

**🎯 Motivo:**
[Explicación clara de POR QUÉ necesitas acceder a este archivo.
Debe ser convincente y demostrar que no hay alternativa mejor.]

**🔄 Alternativa considerada:**
[¿Qué otra opción evaluaste? ¿Por qué no funciona?
Demostrar que pensaste en otras soluciones.]

**⚡ Acción:**
[ ] read (solo lectura)
[ ] write (modificar)
[ ] execute (ejecutar)

**💥 Impacto:**
[¿Qué puede romperse? ¿A quién afecta? ¿Es reversible?]

**⏰ Urgencia:**
[ ] Crítico - bloqueado sin esto
[ ] Alto - mejora significativa
[ ] Medio - nice to have
[ ] Bajo - optimización

---

**Esperando aprobación del usuario...**
```

### Ejemplos de Consultas Bien Formadas

#### Ejemplo 1: Lectura de Config Externa

```markdown
🔴 SOLICITUD DE ACCESO EXTERNO

**📁 Archivo solicitado:**
/home/nano/nahue/satori/porfolio/CLAUDE.md

**🎯 Motivo:**
Necesito leer las convenciones de commit messages usadas en otros
proyectos del portfolio para mantener consistencia. El proyecto actual
no tiene documentación de convenciones y quiero aplicar el estándar ya
establecido en lugar de inventar uno nuevo.

**🔄 Alternativa considerada:**
Crear convenciones desde cero, pero sería inconsistente con el resto
del portfolio y generaría fragmentación de estándares.

**⚡ Acción:**
[x] read (solo lectura)

**💥 Impacto:**
Ninguno - solo lectura de referencia. No modifico nada externo.

**⏰ Urgencia:**
[ ] Medio - mejora calidad de commits

---

¿Apruebas este acceso? (sí/no)
```

#### Ejemplo 2: Modificación Justificada

```markdown
🟡 CONSULTA - Archivo Compartido

**📁 Archivo:** docker-compose.yml

**🎯 Motivo:**
Backend necesita aumentar `DB_POOL_SIZE` de 20 a 50 conexiones porque
bajo carga (>100 usuarios concurrentes) el pool se agota y genera
timeouts. Logs muestran "connection pool exhausted" cada 2 minutos.

**🔄 Alternativa considerada:**
Optimizar queries para usar menos conexiones, pero ya están optimizadas
(con select_related, prefetch_related). El problema es volumen real.

**⚡ Acción:**
[x] write (modificar)

**💥 Impacto:**
Afecta a infra agent (dueño del archivo). Incrementa uso de memoria en
PostgreSQL (~2MB por conexión = +60MB total). Servidor tiene 8GB RAM,
impacto aceptable.

**⏰ Urgencia:**
[x] Alto - afecta performance en producción

---

¿Apruebas este cambio? (sí/no)
```

---

## 🚨 Qué Hacer Si Violaste el Scope

### Si cometiste el error SIN consultar:

1. **DETENTE inmediatamente**
2. **Revierte el cambio** si es posible
3. **Informa al usuario**

```markdown
⚠️ ERROR DE SCOPE DETECTADO

**Qué hice:**
Modifiqué [archivo] fuera de mi alcance sin consultar.

**Por qué fue error:**
[Explicar por qué violó policy]

**Acción correctiva:**
1. Revertí el cambio: git checkout [archivo]
2. Solicito aprobación apropiadamente:
   [Usar template de consulta]

**Aprendizaje:**
En futuro, verificaré alcance ANTES de modificar con:
bash verify-scope.sh [archivo] [agente]
```

### Si el usuario rechaza la solicitud:

1. **Acata la decisión** sin discutir
2. **Busca alternativa** dentro de tu alcance
3. **Pregunta si hay otra forma** de lograr el objetivo

```markdown
✅ Entendido - Acceso denegado

**Buscaré alternativa:**
[Describir plan B que no requiere acceso externo]

**Si no hay alternativa:**
¿Existe otra forma de lograr [objetivo] sin acceder a [archivo]?
```

---

## 📊 Matriz de Decisión Rápida

| Situación | Nivel | Acción |
|-----------|-------|--------|
| Archivo en mi worktree | 🟢 | Acceso libre |
| Archivo compartido (leer) | 🟢 | Lectura libre |
| Archivo compartido (modificar) | 🟡 | Consultar con formato |
| Archivo otro worktree (leer) | 🟢 | Lectura libre |
| Archivo otro worktree (modificar) | 🟡 | Consultar con formato |
| Archivo fuera del proyecto | 🔴 | Consulta obligatoria con justificación robusta |
| context/ (leer) | 🟢 | Siempre permitido |
| context/ (modificar) | 🔴 | Prohibido sin aprobación |
| /etc/, /usr/ (sistema) | 🔴 | Casi siempre prohibido |

---

## 🎓 Mejores Prácticas

### ✅ DO (Hacer)

1. **Verificar ANTES de acceder**
   ```bash
   bash verify-scope.sh [archivo] [tipo-agente]
   ```

2. **Justificar claramente**
   - Explicar el "por qué", no solo el "qué"
   - Demostrar que consideraste alternativas

3. **Usar formato visual**
   - Emojis 🟢🟡🔴 para visibilidad
   - Template completo para consultas

4. **Respetar decisiones**
   - Si usuario dice no, buscar alternativa

### ❌ DON'T (No hacer)

1. **Acceder sin verificar**
   - ❌ Asumir que tienes permiso
   - ❌ "Pedir perdón en lugar de permiso"

2. **Consultas vagas**
   - ❌ "¿Puedo modificar este archivo?"
   - ✅ "¿Puedo modificar X para Y porque Z?"

3. **Ignorar niveles**
   - ❌ Tratar 🟡 como 🟢
   - ❌ Tratar 🔴 como 🟡

4. **Justificaciones débiles**
   - ❌ "Sería más fácil así"
   - ✅ "Es la única forma de lograr X sin Y"

---

**Próximo paso:** Leer `05-BEST-PRACTICES.md` para prácticas específicas por tecnología.
