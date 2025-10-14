#!/bin/bash
# init-project.sh - Bootstrap automático de proyectos full-stack
# Uso: ./init-project.sh --name proyecto-nombre [--description "Descripción"]

set -e  # Exit on error

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Variables
PROJECT_NAME=""
DESCRIPTION=""

# Parse argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Uso: $0 --name <nombre-proyecto> [--description <descripción>]${NC}"
      exit 1
      ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: --name es requerido${NC}"
  echo "Uso: $0 --name <nombre-proyecto> [--description <descripción>]"
  exit 1
fi

echo -e "${BLUE}🚀 Inicializando proyecto: $PROJECT_NAME${NC}"
echo ""

# 1. Crear directorio principal y estructura
echo -e "${YELLOW}📁 Creando estructura de directorios...${NC}"
mkdir -p "${PROJECT_NAME}-main"/{backend/config,frontend/src,scripts,docs}

cd "${PROJECT_NAME}-main"

# 2. Inicializar git
echo -e "${YELLOW}🔧 Inicializando repositorio git...${NC}"
git init -b main

# 3. Crear .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
db.sqlite3

# Django
*.log
local_settings.py

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
build/
.DS_Store

# Environment
.env
.env.local

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Docker
.dockerignore

# OS
.DS_Store
Thumbs.db
EOF

# 4. Crear backend/requirements.txt
cat > backend/requirements.txt << 'EOF'
Django==5.0.1
djangorestframework==3.14.0
psycopg2-binary==2.9.9
python-dotenv==1.0.0
PyJWT==2.8.0
django-cors-headers==4.3.1
gunicorn==21.2.0
# FastAPI (Fase 2)
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
EOF

# 5. Crear backend/manage.py
cat > backend/manage.py << 'EOF'
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
EOF
chmod +x backend/manage.py

# 6. Crear backend/config/__init__.py
touch backend/config/__init__.py

# 7. Crear backend/config/settings.py (básico)
cat > backend/config/settings.py << 'EOF'
from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-change-this-in-production')
DEBUG = os.environ.get('DEBUG', 'True') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '*').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'postgres'),
        'USER': os.environ.get('DB_USER', 'postgres'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'postgres'),
        'HOST': os.environ.get('DB_HOST', 'db'),
        'PORT': os.environ.get('DB_PORT', '5432'),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
]
CORS_ALLOW_CREDENTIALS = True
EOF

# 8. Crear backend/config/urls.py
cat > backend/config/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
]
EOF

# 9. Crear backend/config/wsgi.py
cat > backend/config/wsgi.py << 'EOF'
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
application = get_wsgi_application()
EOF

# 10. Crear frontend/package.json
cat > frontend/package.json << 'EOF'
{
  "name": "frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.9.5",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@types/node": "^20.0.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": ["react-app"]
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
EOF

# 11. Crear frontend/tsconfig.json
cat > frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowJs": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true
  },
  "include": ["src"]
}
EOF

# 12. Crear .env
cat > .env << 'EOF'
# Django
SECRET_KEY=django-insecure-dev-key-change-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=db
DB_PORT=5432

# Frontend
REACT_APP_API_URL=http://localhost:8000/api
EOF

# 13. Crear scripts/entrypoint.sh
cat > scripts/entrypoint.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando backend..."
sleep 2

echo "📦 Aplicando migraciones..."
python manage.py migrate

echo "👤 Creando superusuario..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('✅ Superusuario creado: admin/admin123')
else:
    print('✅ Superusuario ya existe')
"

echo "📁 Recopilando archivos estáticos..."
python manage.py collectstatic --noinput

echo "🚀 Iniciando servidor Django..."
python manage.py runserver 0.0.0.0:8000
EOF
chmod +x scripts/entrypoint.sh

# 14. Crear Dockerfile.backend
cat > Dockerfile.backend << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    postgresql-client \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .
RUN mkdir -p staticfiles

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

CMD ["/entrypoint.sh"]
EOF

# 15. Crear Dockerfile.frontend
cat > Dockerfile.frontend << 'EOF'
FROM node:18-alpine as builder

WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# 16. Crear docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    environment:
      - SECRET_KEY=django-insecure-dev-key
      - DEBUG=True
      - DB_NAME=postgres
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_HOST=db
      - DB_PORT=5432
    volumes:
      - ./backend:/app
      - static_volume:/app/staticfiles
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
    command: ["/entrypoint.sh"]

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
  static_volume:

networks:
  default:
    name: ${PROJECT_NAME}_network
EOF

# 17. README básico
cat > README.md << EOF
# ${PROJECT_NAME}

${DESCRIPTION}

## Stack

- **Backend:** Django 5.x + PostgreSQL
- **Frontend:** React 18 + TypeScript
- **Infraestructura:** Docker + Nginx

## Quick Start

\`\`\`bash
docker compose up -d
\`\`\`

- Backend: http://localhost:8000
- Frontend: http://localhost:3000
- Admin: http://localhost:8000/admin (admin/admin123)

## Desarrollo

Ver context/01-PROJECT-BOOTSTRAP.md para guía completa.
EOF

# 18. Commit inicial
git add .
git commit -m "chore: initial project structure"

# 19. Crear worktrees
echo -e "${YELLOW}🌿 Creando worktrees...${NC}"

# Crear ramas
git checkout -b feature/backend
git checkout -b feature/frontend
git checkout -b feature/infra
git checkout main

# Crear worktrees
git worktree add ../${PROJECT_NAME}-backend feature/backend
git worktree add ../${PROJECT_NAME}-frontend feature/frontend
git worktree add ../${PROJECT_NAME}-infra feature/infra

# 20. Generar CLAUDE.md para cada worktree
echo -e "${YELLOW}📝 Generando contexto para cada worktree...${NC}"

# CLAUDE.md para main
cat > CLAUDE.md << EOF
# ${PROJECT_NAME} - Main Branch

**Directorio:** ${PROJECT_NAME}-main/
**Rama:** main
**Rol:** Coordinador y Revisor

## Responsabilidades
- Revisar PRs de otros worktrees
- Mergear features aprobadas
- Mantener documentación actualizada

## Restricciones
- NO desarrollar features directamente en main
- Solo merge después de revisión apropiada
- Acceso completo de lectura, escritura solo via PR

## Comandos Útiles
\`\`\`bash
gh pr list                    # Ver PRs pendientes
gh pr view <number>           # Ver PR específico
gh pr merge <number> --squash # Mergear PR
git pull origin main          # Actualizar main
\`\`\`

## Scope Policy
Ver: context/04-SCOPE-POLICY.md
EOF

# CLAUDE.md para backend
cat > ../${PROJECT_NAME}-backend/CLAUDE.md << EOF
# ${PROJECT_NAME} - Backend Agent

**Directorio:** ${PROJECT_NAME}-backend/
**Rama:** feature/backend
**Rol:** Desarrollador Backend

## Tu Stack
- Django 5.x (models, admin, ORM)
- PostgreSQL 15
- Django REST Framework
- Fase 2: FastAPI (cuando necesario)

## Archivos PERMITIDOS 🟢
- backend/**
- Dockerfile.backend
- requirements.txt
- scripts/entrypoint.sh

## Archivos CONSULTA 🟡
- docker-compose.yml (propiedad de infra)
- .env (compartido)

## Archivos PROHIBIDOS 🔴
- frontend/** (propiedad de frontend agent)
- nginx*.conf (propiedad de infra agent)

## Metodología
1. Leer: context/02-CORE-STANDARDS.md (sección Backend)
2. Django primero, FastAPI solo si necesario
3. Prefijo commits: "backend: "

## Validación de Scope
\`\`\`bash
bash context/templates/verify-scope.sh <archivo> backend
\`\`\`

## Comandos
\`\`\`bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver

git add backend/
git commit -m "backend: descripción"
git push origin feature/backend
\`\`\`

## Scope Policy
Ver: context/04-SCOPE-POLICY.md
Proyecto root: ${PWD}/..
EOF

# CLAUDE.md para frontend
cat > ../${PROJECT_NAME}-frontend/CLAUDE.md << EOF
# ${PROJECT_NAME} - Frontend Agent

**Directorio:** ${PROJECT_NAME}-frontend/
**Rama:** feature/frontend
**Rol:** Desarrollador Frontend

## Tu Stack
- React 18 + TypeScript
- Tailwind CSS v4
- shadcn/ui (vía MCP - primera opción)
- React Router v7

## Archivos PERMITIDOS 🟢
- frontend/**
- Dockerfile.frontend
- package.json
- tsconfig.json
- tailwind.config.ts

## Archivos CONSULTA 🟡
- .env (para REACT_APP_* vars)

## Archivos PROHIBIDOS 🔴
- backend/** (propiedad de backend agent)
- docker-compose.yml (propiedad de infra agent)

## Metodología
1. Leer: context/02-CORE-STANDARDS.md (sección Frontend + Design System)
2. SIEMPRE usar shadcn/ui primero (vía MCP)
3. Aplicar design tokens (shadow-soft, rounded-card, etc.)
4. Prefijo commits: "frontend: "

## Design Tokens
\`\`\`
Sombras: shadow-subtle, shadow-soft, shadow-medium, shadow-elevated
Bordes: rounded-card (12px), rounded-button (8px), rounded-input (6px)
Transiciones: duration-fast (150ms), duration-normal (250ms)
\`\`\`

## Comandos
\`\`\`bash
npm install
npm start                     # Dev server
npm run build                 # Production build

npx shadcn-ui@latest add <component>  # Agregar componente

git add frontend/
git commit -m "frontend: descripción"
git push origin feature/frontend
\`\`\`

## Scope Policy
Ver: context/04-SCOPE-POLICY.md
Proyecto root: ${PWD}/..
EOF

# CLAUDE.md para infra
cat > ../${PROJECT_NAME}-infra/CLAUDE.md << EOF
# ${PROJECT_NAME} - Infrastructure Agent

**Directorio:** ${PROJECT_NAME}-infra/
**Rama:** feature/infra
**Rol:** DevOps Engineer

## Tu Stack
- Docker + Docker Compose
- Nginx (reverse proxy)
- PostgreSQL 15

## Archivos PERMITIDOS 🟢
- docker-compose.yml
- docker-compose.prod.yml
- nginx*.conf
- scripts/**
- Dockerfile.*
- .dockerignore

## Archivos CONSULTA 🟡
- .env (defines variables)
- backend/config/settings.py (para entender env vars)

## Archivos PROHIBIDOS 🔴
- backend/** (lógica de negocio)
- frontend/src/** (componentes React)

## Metodología
1. Leer: context/02-CORE-STANDARDS.md (sección Infraestructura)
2. Dev: docker-compose.yml (hot-reload, DEBUG=True)
3. Prod: docker-compose.prod.yml (optimizado, multi-stage)
4. Prefijo commits: "infra: "

## Comandos
\`\`\`bash
docker compose up -d          # Iniciar servicios
docker compose down -v        # Detener y limpiar
docker compose logs -f        # Ver logs
docker compose build --no-cache  # Rebuild completo

git add docker-compose.yml nginx.conf
git commit -m "infra: descripción"
git push origin feature/infra
\`\`\`

## Scope Policy
Ver: context/04-SCOPE-POLICY.md
Proyecto root: ${PWD}/..
EOF

# Fin
echo ""
echo -e "${GREEN}✅ Proyecto '${PROJECT_NAME}' inicializado exitosamente!${NC}"
echo ""
echo -e "${BLUE}📁 Estructura creada:${NC}"
echo "   - ${PROJECT_NAME}-main/         (rama main - coordinador)"
echo "   - ${PROJECT_NAME}-backend/      (feature/backend)"
echo "   - ${PROJECT_NAME}-frontend/     (feature/frontend)"
echo "   - ${PROJECT_NAME}-infra/        (feature/infra)"
echo ""
echo -e "${BLUE}🤖 Próximos pasos para Claude:${NC}"
echo "   1. Leer: context/01-PROJECT-BOOTSTRAP.md"
echo "   2. Personalizar modelos Django según dominio"
echo "   3. Ajustar frontend según requerimientos"
echo "   4. docker compose up -d"
echo ""
if [ -n "$DESCRIPTION" ]; then
  echo -e "${BLUE}📖 Descripción:${NC} ${DESCRIPTION}"
  echo ""
fi
echo -e "${GREEN}¡Listo para desarrollar!${NC}"
