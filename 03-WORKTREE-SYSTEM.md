# 🌿 Git Worktree System - Desarrollo Paralelo sin Conflictos

## 🎯 Qué son los Git Worktrees

Los worktrees permiten tener **múltiples ramas checked out simultáneamente en diferentes directorios**, compartiendo el mismo repositorio git.

### Ventajas

✅ **Trabajo simultáneo** en múltiples features sin cambiar de rama
✅ **Cero conflictos** entre branches durante desarrollo
✅ **Múltiples agentes Claude** trabajando en paralelo
✅ **Tests y builds** corriendo simultáneamente
✅ **Context switching rápido** sin stash/commit temporal

### Estructura Típica

```
proyecto/
├── proyecto-main/           # Rama main (coordinación)
├── proyecto-backend/        # feature/backend
├── proyecto-frontend/       # feature/frontend
└── proyecto-infra/          # feature/infra

Todos comparten el mismo .git (en proyecto-main/)
```

---

## 🚀 Setup de Worktrees (Automatizado)

### Opción 1: Con init-project.sh (Recomendado)

```bash
# El script crea TODO automáticamente
bash context/templates/init-project.sh --name mi-proyecto

# ✅ Genera:
# - mi-proyecto-main/        (main branch)
# - mi-proyecto-backend/     (feature/backend)
# - mi-proyecto-frontend/    (feature/frontend)
# - mi-proyecto-infra/       (feature/infra)
```

### Opción 2: Manual (Para proyectos existentes)

```bash
# En el directorio del proyecto principal
cd mi-proyecto-main/

# Crear worktree para backend
git worktree add ../mi-proyecto-backend -b feature/backend

# Crear worktree para frontend
git worktree add ../mi-proyecto-frontend -b feature/frontend

# Crear worktree para infra
git worktree add ../mi-proyecto-infra -b feature/infra

# Listar worktrees creados
git worktree list
```

---

## 👥 Asignación de Agentes por Worktree

### Contexto Específico por Agente

Cada worktree tiene su propio `CLAUDE.md` con:
- ✅ Archivos que PUEDE modificar
- ✅ Archivos que DEBE consultar antes de modificar
- ✅ Archivos PROHIBIDOS
- ✅ Prefijo de commits
- ✅ Referencias a documentación relevante

### Worktree 1: Main (Coordinador)

**Directorio:** `proyecto-main/`
**Rama:** `main`
**Rol:** Coordinación y revisión

**Responsabilidades:**
- Revisar Pull Requests
- Merge de features a main
- Coordinación entre agentes
- Mantenimiento de documentación

**NO hace:**
- Desarrollo directo de features
- Modificación de código sin PR

**CLAUDE.md generado:**
```markdown
# Proyecto - Main Branch

**Rol:** Coordinador y Revisor

## Responsabilidades
- Revisar PRs de otros worktrees
- Mergear features aprobadas
- Mantener docs actualizados

## Restricciones
- NO desarrollar features directamente
- NO mergear sin revisión
- Acceso completo solo para lectura y merge
```

### Worktree 2: Backend

**Directorio:** `proyecto-backend/`
**Rama:** `feature/backend`
**Rol:** Desarrollador Backend

**Archivos PERMITIDOS (🟢):**
- `backend/**`
- `Dockerfile.backend`
- `requirements.txt`
- `scripts/entrypoint.sh`

**Archivos CONSULTA (🟡):**
- `docker-compose.yml` (propiedad de infra)
- `.env` (compartido)

**Archivos PROHIBIDOS (🔴):**
- `frontend/**`
- `nginx.conf`
- Cualquier archivo fuera del proyecto

**Prefijo commits:** `backend:`

**CLAUDE.md generado:**
```markdown
# Proyecto - Backend Agent

**Directorio:** proyecto-backend/
**Rama:** feature/backend

## Stack
- Django 5.x + PostgreSQL
- Fase 2: FastAPI (cuando necesario)

## Archivos Permitidos 🟢
- backend/**
- Dockerfile.backend
- requirements.txt

## Archivos Consulta 🟡
- docker-compose.yml
- .env

## Archivos Prohibidos 🔴
- frontend/**
- nginx.conf

## Comandos
git commit -m "backend: descripción"
git push origin feature/backend
```

### Worktree 3: Frontend

**Directorio:** `proyecto-frontend/`
**Rama:** `feature/frontend`
**Rol:** Desarrollador Frontend

**Archivos PERMITIDOS (🟢):**
- `frontend/**`
- `Dockerfile.frontend`
- `package.json`
- `tailwind.config.ts`
- `tsconfig.json`

**Archivos CONSULTA (🟡):**
- `.env` (para REACT_APP_* vars)

**Archivos PROHIBIDOS (🔴):**
- `backend/**`
- `docker-compose.yml`
- `nginx.conf`

**Prefijo commits:** `frontend:`

**Metodología especial:**
- Usar shadcn/ui vía MCP
- Aplicar design tokens de 02-CORE-STANDARDS.md
- TypeScript strict mode

**CLAUDE.md generado:**
```markdown
# Proyecto - Frontend Agent

**Directorio:** proyecto-frontend/
**Rama:** feature/frontend

## Stack
- React 18 + TypeScript + Tailwind
- shadcn/ui (primera opción)

## Archivos Permitidos 🟢
- frontend/**
- Dockerfile.frontend
- package.json

## Archivos Prohibidos 🔴
- backend/**
- docker-compose.yml

## Comandos
git commit -m "frontend: descripción"
git push origin feature/frontend

## Design Tokens
Ver: context/02-CORE-STANDARDS.md sección Design System
- shadow-soft, shadow-medium
- rounded-card, rounded-button
```

### Worktree 4: Infra

**Directorio:** `proyecto-infra/`
**Rama:** `feature/infra`
**Rol:** DevOps

**Archivos PERMITIDOS (🟢):**
- `docker-compose.yml`
- `docker-compose.prod.yml`
- `nginx.conf`
- `nginx-frontend.conf`
- `scripts/**`
- `Dockerfile.*`

**Archivos CONSULTA (🟡):**
- `.env` (define variables)
- `backend/config/settings.py` (para entender env vars)

**Archivos PROHIBIDOS (🔴):**
- `backend/` (lógica de negocio)
- `frontend/src/` (componentes)

**Prefijo commits:** `infra:`

**CLAUDE.md generado:**
```markdown
# Proyecto - Infrastructure Agent

**Directorio:** proyecto-infra/
**Rama:** feature/infra

## Stack
- Docker + Docker Compose
- Nginx + PostgreSQL

## Archivos Permitidos 🟢
- docker-compose*.yml
- nginx*.conf
- scripts/**
- Dockerfile.*

## Archivos Prohibidos 🔴
- backend/ (lógica)
- frontend/src/ (componentes)

## Comandos
git commit -m "infra: descripción"
git push origin feature/infra
```

---

## 🔄 Workflow de Desarrollo

### Desarrollo Paralelo (Típico)

```bash
# Agente Backend (en proyecto-backend/)
cd proyecto-backend/
# Modifica backend/models.py, backend/views.py
git add backend/
git commit -m "backend: add user authentication"
git push origin feature/backend

# Simultáneamente, Agente Frontend (en proyecto-frontend/)
cd proyecto-frontend/
# Modifica frontend/src/pages/LoginPage.tsx
git add frontend/
git commit -m "frontend: add login form"
git push origin feature/frontend

# Simultáneamente, Agente Infra (en proyecto-infra/)
cd proyecto-infra/
# Modifica docker-compose.yml
git add docker-compose.yml
git commit -m "infra: add redis service"
git push origin feature/infra

# ✅ Los 3 trabajan en paralelo sin conflictos
```

### Sincronización con Main

Cada agente debe actualizar su rama con cambios de main periódicamente:

```bash
# En proyecto-backend/
git fetch origin
git merge origin/main

# Si hay conflictos, resolver y commitear
git add .
git commit -m "backend: merge main"
```

### Crear Pull Request

```bash
# Desde el worktree correspondiente
cd proyecto-backend/

# Crear PR con gh CLI
gh pr create \
  --base main \
  --head feature/backend \
  --title "Backend: User Authentication" \
  --body "Implements JWT authentication for users"

# O usar UI de GitHub
```

### Merge de PR (Coordinador)

```bash
# En proyecto-main/
cd proyecto-main/

# Listar PRs pendientes
gh pr list

# Revisar PR específico
gh pr view 1
gh pr diff 1

# Aprobar y mergear
gh pr review 1 --approve
gh pr merge 1 --squash

# Actualizar main local
git pull origin main
```

---

## 🤝 Coordinación entre Agentes

### Estrategia 1: Comunicación via Issues/PRs (Recomendado)

```bash
# Backend necesita que Frontend agregue endpoint
gh issue create \
  --title "Frontend: Call new /api/users/me endpoint" \
  --body "Backend expuso endpoint en feature/backend. Frontend debe consumirlo" \
  --assignee frontend-agent
```

### Estrategia 2: Archivo de Status

Crear `AGENT_STATUS.md` en main:

```markdown
## Status de Agentes - 2025-10-13 10:00

### Backend Agent
- ✅ Completado: User authentication
- 🔄 En progreso: Product CRUD
- ⏸️ Bloqueado: Esperando Redis (infra)

### Frontend Agent
- ✅ Completado: Login page
- 🔄 En progreso: Product list
- 📋 Pendiente: Conectar con backend API

### Infra Agent
- ✅ Completado: Nginx config
- 🔄 En progreso: Redis setup
- 📋 Pendiente: Production deployment
```

Cada agente actualiza su sección antes de terminar sesión.

### Estrategia 3: Commits Descriptivos

```bash
# Backend comunica via commit message
git commit -m "backend: add GET /api/products endpoint

Frontend should call this endpoint with auth token.
Returns paginated list of products.

Example:
GET /api/products?page=1&limit=10
Authorization: Bearer <token>"
```

Frontend lee el log:
```bash
git log origin/feature/backend --oneline -10
```

---

## 📋 Comandos Esenciales

### Listar Worktrees

```bash
cd proyecto-main/
git worktree list

# Output:
# /path/proyecto-main     [main]
# /path/proyecto-backend  [feature/backend]
# /path/proyecto-frontend [feature/frontend]
# /path/proyecto-infra    [feature/infra]
```

### Eliminar Worktree

```bash
cd proyecto-main/

# Método 1: Si el directorio existe
git worktree remove ../proyecto-backend

# Método 2: Si ya eliminaste el directorio manualmente
git worktree prune
```

### Ver Cambios entre Ramas

```bash
# Ver qué cambió en backend vs main
git diff main...feature/backend

# Ver archivos modificados
git diff --name-only main...feature/backend
```

### Cambiar de Worktree

```bash
# NO uses 'cd' dentro del mismo worktree
# Abre nueva terminal y navega

# Terminal 1: Backend
cd proyecto-backend/

# Terminal 2: Frontend
cd proyecto-frontend/

# Terminal 3: Main (coordinación)
cd proyecto-main/
```

---

## ⚠️ Restricciones y Protecciones

### Validación Antes de Commit

Cada worktree tiene script de validación:

```bash
# Antes de modificar archivo, verificar alcance
bash verify-scope.sh backend/models.py backend

# Output: 🟢 ACCESO PERMITIDO
# o
# Output: 🔴 ACCESO PROHIBIDO - Consultar usuario
```

### Hook Pre-commit

El `init-project.sh` instala hook que valida alcance:

```bash
# Si intentas commitear archivo fuera de alcance
git add frontend/src/App.tsx  # (desde proyecto-backend)
git commit -m "modificar frontend"

# Output: ❌ Commit bloqueado: Archivo fuera de alcance
```

### Protocolo de Consulta

Si necesitas modificar archivo fuera de alcance:

```markdown
🔴 SOLICITUD DE ACCESO

**Archivo:** docker-compose.yml
**Desde worktree:** proyecto-backend
**Motivo:** Necesito agregar variable de entorno DB_POOL_SIZE para backend
**Alternativa:** Podría usar variable por defecto, pero necesito optimizar pool
**Acción:** write (modificar)

¿Apruebas? (sí/no)
```

---

## 🎯 Templates de Prompts por Worktree

### Template: Backend Agent

```
# CONTEXTO
Directorio: proyecto-backend/
Rama: feature/backend
Rol: Backend Developer

# RESTRICCIONES
Archivos permitidos: backend/**, Dockerfile.backend, requirements.txt
Archivos prohibidos: frontend/**, nginx.conf
Prefijo commits: "backend: "

# TAREAS
1. [Tarea específica del usuario]
2. [Más tareas...]

# STACK
- Django 5.x + PostgreSQL
- FastAPI en fase 2 (si necesario)
- Ver: context/02-CORE-STANDARDS.md

# VALIDACIÓN
Antes de modificar archivo:
bash verify-scope.sh <archivo> backend
```

### Template: Frontend Agent

```
# CONTEXTO
Directorio: proyecto-frontend/
Rama: feature/frontend
Rol: Frontend Developer

# RESTRICCIONES
Archivos permitidos: frontend/**, Dockerfile.frontend, package.json
Archivos prohibidos: backend/**, docker-compose.yml
Prefijo commits: "frontend: "

# TAREAS
1. [Tarea específica del usuario]
2. [Más tareas...]

# STACK
- React 18 + TypeScript + Tailwind
- shadcn/ui vía MCP (primera opción)
- Design tokens: context/02-CORE-STANDARDS.md

# METODOLOGÍA
1. ¿Existe en shadcn? → Usar shadcn
2. ¿Existe librería? → Instalar
3. ¿Custom necesario? → Mínimo y documentado
```

### Template: Infra Agent

```
# CONTEXTO
Directorio: proyecto-infra/
Rama: feature/infra
Rol: DevOps Engineer

# RESTRICCIONES
Archivos permitidos: docker-compose*.yml, nginx*.conf, scripts/**, Dockerfile.*
Archivos prohibidos: backend/**, frontend/src/**
Prefijo commits: "infra: "

# TAREAS
1. [Tarea específica del usuario]
2. [Más tareas...]

# STACK
- Docker Compose (dev + prod)
- Nginx reverse proxy
- PostgreSQL 15

# CONFIGURACIÓN
- Dev: Hot-reload, DEBUG=True
- Prod: Multi-stage, optimizado
```

---

## 🚨 Troubleshooting

### Error: "worktree already exists"

```bash
cd proyecto-main/
git worktree prune
git worktree add ../proyecto-backend feature/backend
```

### Error: "cannot lock ref"

```bash
cd proyecto-main/
rm .git/refs/heads/feature/backend.lock
```

### Conflicto: Dos agentes modificaron mismo archivo

```bash
# Identificar conflicto
git status

# Resolver manualmente
vim archivo-conflictivo.py

# Buscar markers de conflicto:
# <<<<<<< HEAD
# código de tu rama
# =======
# código de otra rama
# >>>>>>> origin/main

# Resolver, luego:
git add archivo-conflictivo.py
git commit -m "backend: resolve merge conflict"
```

### Worktree desincronizado con remote

```bash
cd proyecto-backend/
git fetch origin
git reset --hard origin/feature/backend
```

---

## 📊 Ventajas vs Branches Tradicionales

| Aspecto | Branches Tradicionales | Worktrees |
|---------|----------------------|-----------|
| **Cambio de contexto** | `git checkout` (lento) | `cd` (instantáneo) |
| **Múltiples features** | 1 a la vez | Todas en paralelo |
| **Agentes Claude** | 1 agente secuencial | 3-4 agentes paralelos |
| **Build + dev simultáneo** | ❌ No | ✅ Sí |
| **Stash requerido** | ✅ Frecuente | ❌ Nunca |
| **Conflictos durante dev** | ⚠️ Posibles | ✅ Imposibles |

---

**Próximo paso:** Leer `04-SCOPE-POLICY.md` para entender restricciones de acceso a directorios.
