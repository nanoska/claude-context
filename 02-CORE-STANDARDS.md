# 📚 Core Standards - Stack Completo y Estándares de Desarrollo

Este archivo consolidado contiene TODOS los estándares tecnológicos, arquitectónicos y de diseño en un solo lugar.

---

## 📦 Stack Tecnológico Completo

### Backend: Arquitectura Híbrida Django + FastAPI

#### Fase 1: Django Puro (Inicio del Proyecto)

**Stack:**
- **Django 5.x**: Models, admin, ORM, migrations
- **Django REST Framework**: Serializers, ViewSets
- **PostgreSQL**: Base de datos principal
- **python-dotenv**: Variables de entorno

**Cuándo usar:**
- ✅ Proyecto en etapa MVP
- ✅ Enfoque en CRUD básico
- ✅ Admin panel importante
- ✅ Sincronización suficiente

**Estructura:**
```
backend/
├── config/                    # Django settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── app_name/                  # Django apps
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   ├── admin.py
│   └── tests.py
└── manage.py
```

**Comandos típicos:**
```bash
python manage.py runserver              # Puerto 8000
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

#### Fase 2: Django + FastAPI (Evolución)

**Stack adicional:**
- **FastAPI**: Endpoints async, WebSockets
- **Uvicorn**: ASGI server
- **Pydantic**: Validación moderna

**Cuándo migrar a Fase 2:**
- ✅ Necesitas endpoints asíncronos
- ✅ WebSockets / Server-Sent Events
- ✅ Alto volumen de requests concurrentes
- ✅ Integración con APIs externas async
- ✅ Performance crítica en endpoints específicos

**Estructura híbrida:**
```
backend/
├── config/                    # Django settings
├── app_name/                  # Django apps (models, admin)
├── api/                       # FastAPI app
│   ├── main.py               # FastAPI entry point
│   ├── routers/
│   │   ├── users.py
│   │   └── products.py
│   ├── models/               # Pydantic models
│   ├── services/             # Business logic
│   └── dependencies.py       # FastAPI dependencies
└── manage.py                  # Django CLI
```

**Comandos en Fase 2:**
```bash
# Django (puerto 8000)
python manage.py runserver

# FastAPI (puerto 8001)
uvicorn api.main:app --reload --port 8001

# En producción: Nginx balanceará entre ambos
```

**Ejemplo de integración:**

```python
# Django maneja: Models + Admin
# backend/products/models.py
from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField()

# FastAPI maneja: API async
# backend/api/routers/products.py
from fastapi import APIRouter
from django.apps import apps

router = APIRouter()

@router.get("/products/")
async def list_products():
    Product = apps.get_model('products', 'Product')
    products = await sync_to_async(list)(Product.objects.all())
    return products
```

**Justificación de arquitectura híbrida:**
- ✅ Django: Admin robusto, ORM maduro
- ✅ FastAPI: Performance, async, modern API
- ✅ Mejor de ambos mundos

---

### Frontend: React 18 + TypeScript + Tailwind

**Stack obligatorio:**
- **React 18.2+**: Framework principal
- **TypeScript 4.9+**: Tipado estático
- **Tailwind CSS v4**: Utility-first styling
- **React Router v7**: Client-side routing
- **Axios**: HTTP client con interceptors JWT

**Stack recomendado:**
- **shadcn/ui**: Componentes vía MCP (primera opción)
- **React Hook Form**: Manejo de formularios
- **Zod**: Validación de schemas
- **TanStack Query**: Data fetching y cache

**Estructura:**
```
frontend/
├── src/
│   ├── components/
│   │   ├── ui/               # shadcn components
│   │   └── features/         # Feature components
│   ├── pages/                # Page components
│   ├── services/
│   │   └── api.ts           # Axios instance
│   ├── hooks/                # Custom hooks
│   ├── types/                # TypeScript types
│   ├── utils/                # Utility functions
│   ├── App.tsx
│   └── main.tsx
├── public/
├── package.json
└── tailwind.config.ts
```

**Comandos típicos:**
```bash
npm start                      # Dev server (puerto 3000)
npm run build                  # Production build
npm test                       # Tests
```

---

### Infraestructura: Docker + Nginx + PostgreSQL

#### Desarrollo (docker-compose.yml)

**Servicios:**
- **PostgreSQL 15**: Base de datos (puerto 5432)
- **Backend**: Django/FastAPI (puerto 8000)
- **Frontend**: React dev server (puerto 3000)
- **Nginx**: Reverse proxy (puerto 8080)

**Características dev:**
- ✅ Hot-reload habilitado
- ✅ DEBUG=True
- ✅ Volúmenes montados para edición en vivo
- ✅ Logs verbose
- ✅ SQLite opcional para desarrollo rápido

```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  backend:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./backend:/app        # Hot-reload
    ports:
      - "8000:8000"
    depends_on:
      - db
```

#### Producción (docker-compose.prod.yml)

**Características prod:**
- ✅ Multi-stage builds
- ✅ DEBUG=False
- ✅ Static files servidos por Nginx
- ✅ Gunicorn/Uvicorn workers optimizados
- ✅ Healthchecks habilitados
- ✅ Secrets management
- ✅ Logs estructurados

```yaml
services:
  backend:
    image: proyecto-backend:prod
    command: gunicorn config.wsgi:application --workers 4
    environment:
      DEBUG: "False"
    # Sin volúmenes montados
```

#### ¿Por qué Nginx?

**Ventajas:**
- ✅ SSL/TLS termination
- ✅ Sirve static files eficientemente
- ✅ Reverse proxy con load balancing
- ✅ Compresión gzip
- ✅ Caché de assets
- ✅ Rate limiting
- ✅ Producción-ready

**Alternativas consideradas:**
- ❌ Traefik: Más complejo para proyectos simples
- ❌ Apache: Menos performante
- ❌ Sin proxy: No recomendado en producción

#### ¿Por qué PostgreSQL?

**Ventajas:**
- ✅ JSON/JSONB support nativo
- ✅ Extensions (pgvector, postgis, uuid)
- ✅ ACID compliant
- ✅ Excelente integración con Django
- ✅ Full-text search
- ✅ Mejor que MySQL para Django ORM

**Alternativas consideradas:**
- ⚠️ SQLite: Solo para desarrollo/prototipos
- ❌ MySQL: Menos features, problemas con Django
- ⚠️ MongoDB: Solo si realmente necesitas NoSQL

---

## 🎨 Design System - UI/UX Excelente

### Principios de Diseño

1. **Sombras sutiles** - Jerarquía visual sin agresividad
2. **Bordes suaves** - UI moderna y amigable
3. **Transiciones fluidas** - Feedback visual instantáneo
4. **Espaciado consistente** - Ritmo visual predecible
5. **Accesibilidad primero** - WCAG 2.1 AA mínimo

### Design Tokens (Tailwind Config)

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      // Sombras sutiles
      boxShadow: {
        'subtle': '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
        'soft': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        'medium': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        'elevated': '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
      },

      // Bordes redondeados
      borderRadius: {
        'card': '0.75rem',      // 12px - Cards, containers
        'button': '0.5rem',      // 8px - Botones
        'input': '0.375rem',     // 6px - Inputs, selects
        'modal': '1rem',         // 16px - Modales, dialogs
        'pill': '9999px',        // Badges, pills
      },

      // Espaciado consistente
      spacing: {
        'section': '4rem',       // 64px - Entre secciones
        'card': '1.5rem',        // 24px - Padding de cards
        'gutter': '1rem',        // 16px - Espacio entre elementos
      },

      // Transiciones
      transitionDuration: {
        'fast': '150ms',
        'normal': '250ms',
        'slow': '350ms',
      },

      transitionTimingFunction: {
        'smooth': 'cubic-bezier(0.4, 0, 0.2, 1)',
        'bounce': 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
      },

      // Colores accesibles (ejemplo)
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        // ... más colores
      },
    },
  },
};
```

### Aplicación Práctica

**Card Component:**
```tsx
// ✅ CORRECTO: Usar design tokens
<div className="
  bg-white
  rounded-card
  shadow-soft
  p-card
  transition-all duration-normal
  hover:shadow-medium
">
  <h3 className="text-lg font-semibold">Card Title</h3>
  <p className="text-gray-600">Content here</p>
</div>
```

**Button Component:**
```tsx
// ✅ CORRECTO: Botón con tokens
<button className="
  px-6 py-3
  rounded-button
  shadow-subtle
  bg-primary-600
  text-white
  transition-all duration-fast
  hover:bg-primary-700
  hover:shadow-soft
  active:scale-95
">
  Click Me
</button>
```

**Input Component:**
```tsx
// ✅ CORRECTO: Input consistente
<input className="
  w-full
  px-4 py-2
  rounded-input
  border border-gray-300
  transition-colors duration-fast
  focus:ring-2 focus:ring-primary-500
  focus:border-transparent
" />
```

---

## 💻 Estrategia de Generación de Código

### Regla de Oro: Minimizar Código Propio

**Decision Tree:**

```
¿Necesito un componente/feature?
  ↓
¿Existe en shadcn/ui (via MCP)?
  → SÍ → Usar shadcn ✅ (Primera opción siempre)
  ↓ NO
¿Existe en Radix UI?
  → SÍ → Usar Radix primitivos ✅
  ↓ NO
¿Existe librería establecida?
  → SÍ → Instalar librería ✅
  ↓ NO
¿Puedo adaptar componente existente?
  → SÍ → Adaptar código ✅
  ↓ NO
Código custom MÍNIMO → Documentar BIEN ⚠️
```

### Jerarquía de Componentes

**Prioridad 1: shadcn/ui (vía MCP)**
```bash
# Instalar componente shadcn
npx shadcn-ui@latest add button
npx shadcn-ui@latest add form
npx shadcn-ui@latest add dialog
```

**Ventajas shadcn:**
- ✅ Código en tu proyecto (no dependencia externa)
- ✅ Totalmente customizable
- ✅ Accesible por defecto (Radix UI)
- ✅ TypeScript nativo
- ✅ Tailwind CSS integrado

**Prioridad 2: Radix UI Primitives**

Cuando shadcn no tiene el componente exacto:

```bash
npm install @radix-ui/react-slider
npm install @radix-ui/react-tooltip
```

**Prioridad 3: Librerías especializadas**

```bash
# Formularios
npm install react-hook-form zod

# Data tables
npm install @tanstack/react-table

# Charts
npm install recharts

# Dates
npm install date-fns
```

**Última opción: Código custom**

Solo cuando NO existe solución:
- Documenta por qué es custom
- Hazlo mínimo y reutilizable
- Tipado TypeScript completo

### Ejemplos Prácticos

#### ✅ CORRECTO: Usar shadcn

```tsx
// Formulario con shadcn + react-hook-form
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const formSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export function LoginForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  })

  function onSubmit(values: z.infer<typeof formSchema>) {
    console.log(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-gutter">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

#### ❌ INCORRECTO: Custom form desde cero

```tsx
// NO HACER ESTO - Reinventar la rueda
const [email, setEmail] = useState('')
const [emailError, setEmailError] = useState('')

const validateEmail = (email: string) => {
  // Custom validation logic...
}

return (
  <form>
    <input
      value={email}
      onChange={e => {
        setEmail(e.target.value)
        validateEmail(e.target.value)
      }}
    />
    {emailError && <span>{emailError}</span>}
  </form>
)
```

#### ✅ CORRECTO: Tabla con TanStack Table

```tsx
import { useReactTable, getCoreRowModel } from '@tanstack/react-table'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table"

export function DataTable({ data, columns }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map(headerGroup => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map(header => (
              <TableHead key={header.id}>
                {header.renderHeader()}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {/* rows */}
      </TableBody>
    </Table>
  )
}
```

---

## 📁 Arquitectura de Proyecto

### Estructura Backend Completa

```
backend/
├── config/                          # Django project config
│   ├── settings.py                  # Settings con env vars
│   ├── urls.py                      # URL routing
│   ├── wsgi.py                      # WSGI entry
│   └── asgi.py                      # ASGI entry (FastAPI)
├── core/                            # Shared utilities
│   ├── middleware.py
│   ├── permissions.py
│   └── utils.py
├── users/                           # Django app: Users
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   ├── admin.py
│   ├── tests.py
│   └── migrations/
├── api/                             # FastAPI app (Fase 2)
│   ├── main.py
│   ├── routers/
│   │   ├── users.py
│   │   └── products.py
│   ├── models.py                    # Pydantic models
│   └── dependencies.py
├── static/                          # Static files
├── media/                           # User uploads
├── staticfiles/                     # Collected static
├── requirements.txt
├── pytest.ini
└── manage.py
```

### Estructura Frontend Completa

```
frontend/
├── src/
│   ├── components/
│   │   ├── ui/                      # shadcn components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   └── form.tsx
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Sidebar.tsx
│   │   └── features/                # Feature components
│   │       ├── auth/
│   │       └── products/
│   ├── pages/                       # Route pages
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   └── ProductsPage.tsx
│   ├── services/
│   │   └── api.ts                   # Axios instance + interceptors
│   ├── hooks/                       # Custom React hooks
│   │   ├── useAuth.ts
│   │   └── useProducts.ts
│   ├── types/                       # TypeScript types
│   │   └── index.ts
│   ├── utils/                       # Utilities
│   │   └── formatters.ts
│   ├── lib/                         # Library configs
│   │   └── utils.ts                 # cn() helper
│   ├── App.tsx                      # Root component
│   ├── main.tsx                     # Entry point
│   └── vite-env.d.ts
├── public/
│   ├── index.html
│   └── assets/
├── package.json
├── tailwind.config.ts
├── tsconfig.json
└── vite.config.ts
```

---

## 🔐 Seguridad y Autenticación

### Backend: JWT Authentication

```python
# Django settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

# Endpoints
POST /api/auth/token/        # Login (get tokens)
POST /api/auth/token/refresh/ # Refresh access token
POST /api/auth/logout/        # Logout
```

### Frontend: Axios Interceptor

```typescript
// services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
});

// Request interceptor: Add JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor: Handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refresh_token');
        const { data } = await axios.post('/api/auth/token/refresh/', {
          refresh: refreshToken,
        });

        localStorage.setItem('access_token', data.access);
        originalRequest.headers.Authorization = `Bearer ${data.access}`;

        return api(originalRequest);
      } catch (refreshError) {
        // Redirect to login
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

---

## 📊 Resumen de Decisiones Técnicas

| Categoría | Elección | Justificación |
|-----------|----------|---------------|
| **Backend Inicial** | Django 5.x | Admin robusto, ORM maduro, rápido MVP |
| **Backend Evolución** | + FastAPI | Async, performance, modern API |
| **Base de Datos** | PostgreSQL 15 | Features, JSON, extensiones |
| **Frontend Framework** | React 18 | Ecosistema maduro, hiring pool |
| **Lenguaje Frontend** | TypeScript | Type safety, mejor DX |
| **Styling** | Tailwind CSS v4 | Utility-first, rápido, customizable |
| **Componentes** | shadcn/ui | Customizable, accesible, en tu repo |
| **Reverse Proxy** | Nginx | Performance, SSL, static files |
| **Containerización** | Docker Compose | Dev/prod parity, fácil setup |

---

**Próximo paso:** Leer `03-WORKTREE-SYSTEM.md` para workflow de git y coordinación entre agentes.
