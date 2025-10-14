# 🚀 Project Bootstrap - Inicialización Automática de Proyectos

## 🎯 Objetivo

Este documento explica cómo inicializar proyectos completos con **un solo comando**, automatizando 90% del trabajo de setup y permitiendo que Claude se enfoque en personalización del dominio.

## 📦 ¿Qué incluye el Bootstrap Automático?

El script `init-project.sh` crea automáticamente:

✅ Estructura completa de directorios (backend/, frontend/, scripts/)
✅ Repositorio Git inicializado
✅ 3 Worktrees listos (feature/backend, feature/frontend, feature/infra)
✅ CLAUDE.md específico por worktree con restricciones
✅ Docker Compose para dev y prod
✅ Dockerfiles optimizados
✅ Scripts de entrypoint
✅ .gitignore estándar
✅ .env template
✅ requirements.txt base (Django + FastAPI)
✅ package.json base (React + TypeScript)
✅ Commit inicial en todas las ramas

**Tiempo de ejecución:** ~10 segundos

## 🚀 Uso Básico

### Para Claude: Iniciar Nuevo Proyecto

Cuando el usuario dice: **"Quiero crear un proyecto de [dominio]"**

**Tu workflow:**

```bash
# 1. Verificar directorio actual (debe ser portfolio-apps/)
pwd
# Output esperado: /home/nano/nahue/satori/porfolio/portfolio-apps/

# 2. Ejecutar script de bootstrap
bash context/templates/init-project.sh \
  --name nombre-proyecto \
  --description "Descripción breve del proyecto"

# 3. Esperar a que el script termine (10 segundos)
# El script hace TODO el trabajo pesado

# 4. Verificar estructura creada
ls -la nombre-proyecto-main/

# 5. Ahora SÍ, personalizar según dominio
# (Esto es lo único que Claude debe hacer manualmente)
```

### Ejemplo Completo

**Usuario dice:**
> "Quiero crear un sistema de gestión de inventario para mi tienda"

**Claude responde:**

```bash
# Inicializo el proyecto automáticamente
bash context/templates/init-project.sh \
  --name inventory-system \
  --description "Sistema de gestión de inventario para tienda"

# ✅ Script completado. Estructura creada:
# inventory-system-main/         (main branch)
# inventory-system-backend/      (feature/backend)
# inventory-system-frontend/     (feature/frontend)
# inventory-system-infra/        (feature/infra)

# Ahora personalizo modelos Django según tu dominio:
cd inventory-system-backend/backend/

# Creo app Django para productos
python manage.py startapp products

# Defino modelos específicos de inventario
# (Esto SÍ requiere conocimiento del dominio)
```

## 🗂️ Estructura Generada

Después de ejecutar el script, tendrás:

```
nombre-proyecto-main/
├── backend/
│   ├── config/
│   │   ├── __init__.py
│   │   ├── settings.py (con PostgreSQL configurado)
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── requirements.txt (Django + FastAPI + PostgreSQL)
│   └── manage.py
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── services/
│   ├── public/
│   └── package.json (React + TypeScript + Tailwind)
├── scripts/
│   └── entrypoint.sh (inicialización backend)
├── docker-compose.yml (modo desarrollo)
├── docker-compose.prod.yml (modo producción)
├── Dockerfile.backend
├── Dockerfile.frontend
├── nginx.conf
├── nginx-frontend.conf
├── .env (con variables por defecto)
├── .gitignore
└── CLAUDE.md (contexto para main)

nombre-proyecto-backend/ (worktree)
├── [mismo contenido que main]
└── CLAUDE.md (contexto específico backend)

nombre-proyecto-frontend/ (worktree)
├── [mismo contenido que main]
└── CLAUDE.md (contexto específico frontend)

nombre-proyecto-infra/ (worktree)
├── [mismo contenido que main]
└── CLAUDE.md (contexto específico infra)
```

## 🤖 Workflow para Claude

### Paso 1: Leer Context (Una vez)

```bash
# Solo necesitas leer esto una vez por sesión
cat context/01-PROJECT-BOOTSTRAP.md  # Este archivo
```

**Tokens:** ~800

### Paso 2: Ejecutar Bootstrap (Bash lo hace todo)

```bash
# El script hace el 90% del trabajo
bash context/templates/init-project.sh --name mi-proyecto
```

**Tiempo:** 10 segundos
**Tokens usados por Claude:** 0 (Bash lo ejecuta)

### Paso 3: Personalizar Dominio (Trabajo de Claude)

```bash
# Ahora SÍ trabajas en personalización
cd mi-proyecto-backend/backend/

# Crear apps Django específicas del dominio
python manage.py startapp usuarios
python manage.py startapp productos
python manage.py startapp ventas

# Definir modelos según requerimientos del usuario
```

**Tokens:** Solo los necesarios para lógica de negocio

### Comparación: Con vs Sin Bootstrap

#### ❌ SIN Bootstrap (Método antiguo)

```bash
# Claude debe hacer TODO manualmente:
1. mkdir -p proyecto/{backend,frontend,scripts} (50 tokens)
2. Crear requirements.txt (200 tokens)
3. Crear package.json (300 tokens)
4. Crear settings.py (500 tokens)
5. Configurar Docker (800 tokens)
6. Crear git repo (100 tokens)
7. Setup worktrees (400 tokens)
8. Generar CLAUDE.md x4 (600 tokens)
9. ... más configuración ...

Total: ~5000 tokens + 30 minutos
```

#### ✅ CON Bootstrap (Método nuevo)

```bash
# Claude solo ejecuta:
1. bash init-project.sh --name proyecto (0 tokens - Bash lo hace)
2. Personalizar modelos Django (300 tokens)

Total: ~300 tokens + 3 minutos
```

**Ahorro:** 94% tokens, 90% tiempo

## 📋 Parámetros del Script

### Parámetros Obligatorios

```bash
--name <nombre-proyecto>
```

### Parámetros Opcionales

```bash
--description "<descripción del proyecto>"
```

### Ejemplos

```bash
# Mínimo
bash context/templates/init-project.sh --name blog-platform

# Con descripción
bash context/templates/init-project.sh \
  --name ecommerce-system \
  --description "Plataforma de comercio electrónico con pagos integrados"

# Proyecto complejo
bash context/templates/init-project.sh \
  --name hospital-management \
  --description "Sistema de gestión hospitalaria con módulos de pacientes, citas y facturación"
```

## 🎯 Qué Personalizar Después del Bootstrap

### Backend (nombre-proyecto-backend/)

**Lo que el script YA configuró:**
✅ Django 5.x instalado
✅ PostgreSQL configurado
✅ FastAPI listo para fase 2
✅ Migrations iniciales
✅ Admin configurado
✅ CORS habilitado
✅ JWT preparado

**Lo que DEBES personalizar:**
1. Crear apps Django según dominio (`python manage.py startapp`)
2. Definir modelos específicos
3. Crear serializers DRF
4. Configurar endpoints específicos
5. Agregar lógica de negocio

### Frontend (nombre-proyecto-frontend/)

**Lo que el script YA configuró:**
✅ React 18 + TypeScript
✅ Tailwind CSS configurado
✅ React Router instalado
✅ Axios configurado
✅ Estructura de carpetas

**Lo que DEBES personalizar:**
1. Crear componentes según diseño
2. Definir páginas/rutas específicas
3. Implementar lógica de UI
4. Aplicar design system
5. Conectar con API

### Infraestructura (nombre-proyecto-infra/)

**Lo que el script YA configuró:**
✅ Docker Compose dev + prod
✅ Nginx configurado
✅ PostgreSQL 15
✅ Healthchecks
✅ Volúmenes

**Lo que DEBES personalizar:**
1. Ajustar puertos si hay conflictos
2. Configurar variables de entorno específicas
3. Optimizar configs de nginx según tráfico
4. Agregar servicios adicionales (Redis, Celery, etc.)

## 🔄 Flujo Completo: Del Request a Producción

### Fase 1: Inicialización (10 segundos)

```bash
Usuario: "Quiero un sistema de reservas de hotel"

Claude:
1. bash context/templates/init-project.sh --name hotel-booking
2. ✅ Proyecto base generado
```

### Fase 2: Personalización Backend (10 minutos)

```bash
Claude (en hotel-booking-backend):
1. python manage.py startapp reservations
2. python manage.py startapp hotels
3. Definir models: Hotel, Room, Reservation, Guest
4. Crear serializers y views
5. git commit -m "backend: add reservations models"
```

### Fase 3: Personalización Frontend (20 minutos)

```bash
Claude (en hotel-booking-frontend):
1. Crear components: HotelCard, RoomSelector, BookingForm
2. Definir pages: HomePage, HotelDetailPage, CheckoutPage
3. Conectar con API backend
4. Aplicar design tokens
5. git commit -m "frontend: add booking flow"
```

### Fase 4: Deploy (5 minutos)

```bash
Claude (en hotel-booking-infra):
1. Ajustar docker-compose.prod.yml
2. Configurar variables de producción
3. git commit -m "infra: production ready"
4. docker compose -f docker-compose.prod.yml up -d
```

**Total:** 45 minutos de desarrollo (vs 2-3 horas sin bootstrap)

## 📊 Optimización de Tokens

### Estrategia: Leer Una Vez, Reutilizar Siempre

```markdown
Primera sesión de Claude:
1. Lee context/01-PROJECT-BOOTSTRAP.md (~800 tokens)
2. Lee context/02-CORE-STANDARDS.md (~1200 tokens)
3. Total contexto inicial: ~2000 tokens

Sesiones siguientes:
1. Lee solo CLAUDE.md del worktree (~200 tokens)
2. Consulta 02-CORE-STANDARDS.md si necesita (~300 tokens)
3. Total por sesión: ~500 tokens

Ahorro acumulado: 75% en sesiones subsecuentes
```

## ⚠️ Limitaciones del Bootstrap

**Lo que el script NO puede hacer:**

❌ Definir lógica de negocio específica
❌ Crear modelos de dominio (requiere entender el dominio)
❌ Diseñar UI específica (requiere requerimientos visuales)
❌ Implementar features únicas del proyecto
❌ Configurar integraciones externas (Stripe, Twilio, etc.)

**Esto es trabajo de Claude** (con input del usuario)

## 🎓 Best Practices

### 1. Siempre Usar Bootstrap para Proyectos Nuevos

```bash
# ✅ CORRECTO
bash context/templates/init-project.sh --name nuevo-proyecto

# ❌ INCORRECTO (perder tiempo haciendo setup manual)
mkdir backend frontend
touch requirements.txt
# ... 50 pasos más ...
```

### 2. Leer Context Solo Una Vez por Sesión

```bash
# ✅ CORRECTO
# Leer al inicio de sesión, luego solo trabajar
cat context/01-PROJECT-BOOTSTRAP.md

# ❌ INCORRECTO (releer constantemente)
# Cada vez que necesitas algo, releer todo
```

### 3. Trabajar en Worktree Correcto

```bash
# ✅ CORRECTO
cd proyecto-backend && vim backend/models.py

# ❌ INCORRECTO (trabajar desde main)
cd proyecto-main && vim backend/models.py
```

## 🚨 Troubleshooting

### Problema: Script falla al crear worktrees

```bash
# Solución: Limpiar worktrees previos
cd proyecto-main
git worktree prune
bash ../context/templates/init-project.sh --name proyecto
```

### Problema: Puerto 5432 (PostgreSQL) ya en uso

```bash
# Solución: Cambiar puerto en docker-compose.yml
ports:
  - "5433:5432"  # Usar otro puerto local
```

### Problema: Permisos de ejecución en scripts

```bash
# Solución: Dar permisos
chmod +x context/templates/init-project.sh
chmod +x scripts/entrypoint.sh
```

## 📚 Recursos Relacionados

- `02-CORE-STANDARDS.md` - Stack y arquitectura detallada
- `03-WORKTREE-SYSTEM.md` - Workflow de worktrees
- `04-SCOPE-POLICY.md` - Restricciones de acceso
- `templates/init-project.sh` - Script de bootstrap

---

**Próximo paso:** Leer `02-CORE-STANDARDS.md` para entender el stack tecnológico completo.
