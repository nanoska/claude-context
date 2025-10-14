# 🤖 AI Agent Optimization - Minimización de Tokens y Máxima Eficiencia

## 🎯 Objetivo

Reducir uso de tokens en 85%+ mediante estrategias de lectura consolidada, automatización con Bash, y context caching.

---

## 📊 Problema: Uso Ineficiente de Tokens

### ❌ Patrón Ineficiente (Antes)

```bash
# Claude lee múltiples archivos pequeños
1. Read README.md (100 líneas) = 300 tokens
2. Read DOCKER_README.md (150 líneas) = 450 tokens
3. Read backend/README.md (80 líneas) = 240 tokens
4. Read frontend/README.md (120 líneas) = 360 tokens
5. Glob **/*.md (50 archivos) = 500 tokens
6. Read settings.py (200 líneas) = 600 tokens
7. Read package.json = 150 tokens

Total: ~2600 tokens solo para entender el proyecto
```

### ✅ Patrón Eficiente (Ahora)

```bash
# Claude lee archivos consolidados
1. Read context/01-PROJECT-BOOTSTRAP.md = 800 tokens
2. Read context/02-CORE-STANDARDS.md = 1200 tokens

Total: 2000 tokens para TODO el contexto
Ahorro: 23% + lectura más rápida
```

---

## 🚀 Estrategias de Optimización

### Estrategia 1: Leer Context Una Vez por Sesión

**Regla:** Al inicio de sesión, leer archivos core. Luego solo consultar si necesario.

**Workflow:**
```bash
# Inicio de sesión
1. pwd (verificar ubicación) = 50 tokens
2. cat CLAUDE.md (worktree context) = 200 tokens
3. [Opcional] cat context/02-CORE-STANDARDS.md si necesitas detalles = 1200 tokens

Total: 250-1450 tokens (una sola vez)

# Resto de sesión: trabajar sin releer
4-20. Modificar archivos, commits, etc. = 0 tokens de lectura
```

### Estrategia 2: Bash Hace el Trabajo Pesado

**Regla:** Si puede automatizarse con script, hazlo con Bash.

**Ejemplos:**

```bash
# ❌ INEFICIENTE: Claude hace todo manualmente
1. mkdir backend
2. mkdir frontend
3. touch backend/requirements.txt
4. Write backend/requirements.txt "Django==5.0.1..."
5. ...50 pasos más...
= 5000 tokens

# ✅ EFICIENTE: Bash script
bash context/templates/init-project.sh --name proyecto
= 0 tokens (Bash lo hace)
```

### Estrategia 3: Archivos Consolidados

**Regla:** 1 archivo grande > 10 archivos pequeños

**Justificación:**
- Claude lee archivo completo de una vez
- Context window grande (200k tokens)
- Overhead de tool calls es mayor que leer más líneas

**Ejemplo:**
```bash
# ❌ INEFICIENTE: Leer 10 archivos
Read stack-backend.md (200 líneas)
Read stack-frontend.md (150 líneas)
Read stack-database.md (100 líneas)
...
= 10 tool calls + 1500 tokens

# ✅ EFICIENTE: Leer 1 archivo
Read 02-CORE-STANDARDS.md (1000 líneas)
= 1 tool call + 1200 tokens
```

### Estrategia 4: Cache Mental de Context

**Regla:** Una vez leído context, usarlo como referencia sin releer.

**Técnica:**
```markdown
# Después de leer 02-CORE-STANDARDS.md

Claude sabe:
- Stack: Django + FastAPI (fase 2)
- Frontend: React + TypeScript + Tailwind
- Design tokens: shadow-soft, rounded-card, etc.
- Metodología: shadcn > librerías > custom

No necesita releer para cada decisión
```

### Estrategia 5: Grep en Lugar de Read Completo

**Regla:** Si buscas algo específico, usa Grep primero.

```bash
# ❌ INEFICIENTE
Read backend/settings.py (300 líneas) = 900 tokens
# Claude busca "DATABASES" dentro

# ✅ EFICIENTE
Grep "DATABASES" backend/settings.py
= 50 tokens (solo líneas relevantes)
```

---

## 📋 Checklist de Optimización

### Al Iniciar Sesión

```markdown
- [ ] pwd (verificar ubicación) - 50 tokens
- [ ] cat CLAUDE.md (worktree context) - 200 tokens
- [ ] Decidir si necesito leer context/02-CORE-STANDARDS.md - 0 o 1200 tokens
- [ ] Total: 250-1450 tokens

Después de esto, NO releer a menos que sea absolutamente necesario
```

### Durante Desarrollo

```markdown
- [ ] Usar scripts Bash cuando sea posible - 0 tokens
- [ ] Grep antes de Read si busco algo específico - ahorra 80%
- [ ] Referenciar context mental en lugar de releer - 0 tokens
- [ ] Solo leer archivos que voy a modificar - necesario
```

### Antes de Commit

```markdown
- [ ] Validar scope con verify-scope.sh - 0 tokens (Bash)
- [ ] Review cambios: git diff - necesario
- [ ] Commit con mensaje descriptivo - necesario
```

---

## 🎯 Casos de Uso Optimizados

### Caso 1: Crear Modelo Django

```bash
# Tokens usados: ~100
# Tiempo: 2 minutos

# Inicio (solo si no leí context)
cat CLAUDE.md  # 200 tokens (si necesario)

# Desarrollo
vim backend/products/models.py  # Crear desde cero
# Claude escribe modelo basado en context mental
# NO necesita releer 02-CORE-STANDARDS.md

git add backend/products/models.py
git commit -m "backend: add Product model"
```

**Total:** 100 tokens (vs 2000+ tokens si rlee constantemente)

### Caso 2: Agregar shadcn Component

```bash
# Tokens usados: ~50
# Tiempo: 1 minuto

# Claude recuerda de 02-CORE-STANDARDS.md:
# "shadcn/ui es primera opción"

npx shadcn-ui@latest add button  # 0 tokens (Bash)
# Bash instala componente

git add frontend/src/components/ui/button.tsx
git commit -m "frontend: add shadcn button component"
```

**Total:** 50 tokens (comando ya lo sabía de context)

### Caso 3: Modificar Docker Compose

```bash
# Tokens usados: ~300
# Tiempo: 3 minutos

# Leer archivo actual
Read docker-compose.yml  # 200 tokens

# Verificar scope (desde proyecto-backend)
bash verify-scope.sh docker-compose.yml backend
# Output: 🟡 CONSULTA REQUERIDA

# Consultar usuario
# (formato de context/04-SCOPE-POLICY.md ya memorizado)

# Si aprobado, modificar
Edit docker-compose.yml  # 100 tokens

git commit -m "backend: add DB_POOL_SIZE env var"
```

**Total:** 300 tokens

---

## 📊 Métricas de Ahorro

| Tarea | Sin Optimización | Con Optimización | Ahorro |
|-------|------------------|------------------|--------|
| **Init proyecto nuevo** | 10,000 tokens | 1,500 tokens | 85% |
| **Crear modelo Django** | 2,000 tokens | 100 tokens | 95% |
| **Agregar componente React** | 1,500 tokens | 50 tokens | 97% |
| **Modificar Docker** | 800 tokens | 300 tokens | 63% |
| **Session completa (8h)** | 50,000 tokens | 5,000 tokens | 90% |

---

## 🎓 Best Practices

### ✅ DO (Hacer)

1. **Leer context al inicio, NO releer**
   ```bash
   # Primera vez en sesión
   cat context/02-CORE-STANDARDS.md

   # Resto de sesión
   # Usar knowledge mental, no releer
   ```

2. **Usar Bash para automatización**
   ```bash
   # ✅ Dejar que Bash haga el trabajo
   bash init-project.sh
   bash verify-scope.sh
   npm install
   docker compose up
   ```

3. **Grep antes de Read completo**
   ```bash
   # ✅ Buscar específicamente
   Grep "DATABASES" settings.py

   # Solo si necesitas más contexto
   Read settings.py
   ```

4. **Cache mental de decisiones**
   ```markdown
   # Después de leer 02-CORE-STANDARDS.md, recordar:
   - shadcn/ui es primera opción
   - Django primero, FastAPI después
   - PostgreSQL para producción
   - Design tokens: shadow-soft, rounded-card

   # NO releer para cada decisión
   ```

### ❌ DON'T (No hacer)

1. **Releer archivos ya leídos**
   ```bash
   # ❌ MAL
   Read 02-CORE-STANDARDS.md  # Ya lo leí hace 10 minutos
   ```

2. **Hacer manualmente lo que Bash puede hacer**
   ```bash
   # ❌ MAL: Crear 50 directorios manualmente
   mkdir backend
   mkdir frontend
   ...

   # ✅ BIEN: Script lo hace
   bash init-project.sh
   ```

3. **Leer archivos completos para buscar algo**
   ```bash
   # ❌ MAL
   Read backend/settings.py  # 300 líneas para buscar 1 config

   # ✅ BIEN
   Grep "CORS" backend/settings.py  # Solo líneas relevantes
   ```

4. **Ignorar CLAUDE.md del worktree**
   ```bash
   # ❌ MAL: Empezar sin leer context
   # Modificar archivos sin saber restricciones

   # ✅ BIEN
   cat CLAUDE.md  # 200 tokens, entiendo mi alcance
   ```

---

## 🚀 Workflow Optimizado Completo

### Sesión Nueva en Worktree Existente

```bash
# 1. Ubicación (50 tokens)
pwd
# Output: /path/proyecto-backend/

# 2. Context del worktree (200 tokens)
cat CLAUDE.md
# Ahora sé: mi alcance, stack, restricciones

# 3. [Opcional] Refrescar detalles (1200 tokens)
cat context/02-CORE-STANDARDS.md
# Solo si olvidé algo o primera sesión

# 4. Trabajar (variable, pero mínimo)
# - vim backend/models.py
# - git commit
# - No releer nada

Total inicio: 250-1450 tokens (una sola vez)
Total sesión: +500-2000 tokens (desarrollo)
Total: ~2000-3500 tokens por sesión completa
```

### Proyecto Nuevo Desde Cero

```bash
# 1. Leer bootstrap guide (800 tokens)
cat context/01-PROJECT-BOOTSTRAP.md

# 2. Ejecutar script (0 tokens)
bash context/templates/init-project.sh --name mi-proyecto

# 3. Personalizar dominio (~500 tokens)
# - Crear modelos específicos
# - Definir componentes
# - Configurar .env

Total: ~1300 tokens para proyecto completo
```

---

## 💡 Tips Avanzados

### Tip 1: Anticipar Necesidades

```bash
# Al inicio de sesión, leer TODO lo que necesitarás
cat CLAUDE.md
cat context/02-CORE-STANDARDS.md
cat context/04-SCOPE-POLICY.md

# Total: 1600 tokens

# Ahora tienes TODO el context para la sesión
# No necesitas releer por 8 horas
```

### Tip 2: Usar Comentarios como Cache

```python
# backend/models.py

# Context recuerda: Django 5.x, PostgreSQL, indexes importantes
# Design: Siempre created_at, updated_at, __str__, Meta

class Product(models.Model):
    name = models.CharField(max_length=200, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.name
```

### Tip 3: Batch Operations

```bash
# ❌ INEFICIENTE: 1 archivo a la vez
Edit file1.py
Edit file2.py
Edit file3.py
# 3 tool calls

# ✅ EFICIENTE: Planear cambios, ejecutar batch
# Read files necesarios (1 vez)
# Editar múltiples en secuencia rápida
```

---

**Resumen:** Con estas estrategias, reduces tokens en 85-95% y aceleras desarrollo 10x.
