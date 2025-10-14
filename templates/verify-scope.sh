#!/bin/bash
# verify-scope.sh - Valida si un archivo está en el alcance permitido
# Uso: ./verify-scope.sh <archivo> <tipo-agente>
# Tipos: backend, frontend, infra, main

FILE_PATH="$1"
AGENT_TYPE="$2"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Validar argumentos
if [ -z "$FILE_PATH" ] || [ -z "$AGENT_TYPE" ]; then
  echo -e "${RED}Uso: $0 <archivo> <tipo-agente>${NC}"
  echo "Tipos válidos: backend, frontend, infra, main"
  exit 1
fi

# Detectar proyecto root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT=$(pwd)
fi

# Convertir a ruta absoluta
if [[ "$FILE_PATH" == /* ]]; then
  ABSOLUTE_PATH="$FILE_PATH"
else
  ABSOLUTE_PATH="$(cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd)/$(basename "$FILE_PATH")"
fi

# Si no se pudo resolver, intentar con realpath
if [ -z "$ABSOLUTE_PATH" ] || [ "$ABSOLUTE_PATH" == "/$(basename "$FILE_PATH")" ]; then
  ABSOLUTE_PATH="$FILE_PATH"
fi

# Función para verificar si path contiene substring
contains() {
  [[ "$1" == *"$2"* ]]
}

echo ""
echo "🔍 Verificando acceso..."
echo "📁 Archivo: $FILE_PATH"
echo "🤖 Agente: $AGENT_TYPE"
echo "📍 Proyecto root: $PROJECT_ROOT"
echo ""

# Verificar si está dentro del proyecto
if ! contains "$ABSOLUTE_PATH" "$PROJECT_ROOT"; then
  echo -e "${RED}🔴 ACCESO EXTERNO DETECTADO${NC}"
  echo ""
  echo "El archivo está FUERA del proyecto root."
  echo ""
  echo "Debes usar el protocolo de consulta de context/04-SCOPE-POLICY.md:"
  echo ""
  echo "🔴 SOLICITUD DE ACCESO EXTERNO"
  echo ""
  echo "**Archivo solicitado:** $ABSOLUTE_PATH"
  echo "**Motivo:** [Explicar por qué necesitas este archivo]"
  echo "**Alternativa considerada:** [¿Hay otra forma?]"
  echo "**Acción:** [read/write]"
  echo ""
  exit 3
fi

# Verificar según tipo de agente
case $AGENT_TYPE in
  backend)
    # Permitidos: backend/, Dockerfile.backend, requirements.txt, scripts/entrypoint.sh
    if contains "$FILE_PATH" "backend/" || \
       contains "$FILE_PATH" "Dockerfile.backend" || \
       contains "$FILE_PATH" "requirements.txt" || \
       contains "$FILE_PATH" "scripts/entrypoint.sh"; then
      echo -e "${GREEN}🟢 ACCESO PERMITIDO${NC}"
      echo "Archivo dentro de tu alcance como backend agent"
      exit 0

    # Consulta: docker-compose.yml, .env
    elif contains "$FILE_PATH" "docker-compose" || \
         contains "$FILE_PATH" ".env"; then
      echo -e "${YELLOW}🟡 CONSULTA REQUERIDA${NC}"
      echo ""
      echo "Archivo compartido detectado."
      echo "Puedes LEER libremente, pero DEBES CONSULTAR antes de MODIFICAR."
      echo ""
      echo "Formato de consulta:"
      echo ""
      echo "🟡 CONSULTA REQUERIDA"
      echo ""
      echo "**Archivo:** $FILE_PATH"
      echo "**Acción:** write (modificar)"
      echo "**Motivo:** [Explicar por qué necesitas modificar]"
      echo "**Impacto:** [A quién afecta]"
      echo "**Alternativa:** [¿Hay otra opción?]"
      echo ""
      echo "¿Apruebas? (sí/no)"
      echo ""
      exit 1

    # Prohibido: frontend/, nginx.conf
    else
      echo -e "${RED}🔴 ACCESO PROHIBIDO${NC}"
      echo ""
      echo "Archivo fuera de tu alcance como backend agent."
      echo ""
      echo "Archivos permitidos:"
      echo "  - backend/**"
      echo "  - Dockerfile.backend"
      echo "  - requirements.txt"
      echo "  - scripts/entrypoint.sh"
      echo ""
      echo "DEBES consultar al usuario antes de acceder."
      echo ""
      exit 2
    fi
    ;;

  frontend)
    # Permitidos: frontend/, Dockerfile.frontend, package.json, tsconfig.json
    if contains "$FILE_PATH" "frontend/" || \
       contains "$FILE_PATH" "Dockerfile.frontend" || \
       contains "$FILE_PATH" "package.json" || \
       contains "$FILE_PATH" "tsconfig.json" || \
       contains "$FILE_PATH" "tailwind.config"; then
      echo -e "${GREEN}🟢 ACCESO PERMITIDO${NC}"
      echo "Archivo dentro de tu alcance como frontend agent"
      exit 0

    # Consulta: .env
    elif contains "$FILE_PATH" ".env"; then
      echo -e "${YELLOW}🟡 CONSULTA REQUERIDA${NC}"
      echo ""
      echo "Archivo compartido (.env)."
      echo "Puedes LEER para REACT_APP_* vars."
      echo "CONSULTA antes de MODIFICAR."
      echo ""
      exit 1

    # Prohibido: backend/, docker-compose.yml, nginx.conf
    else
      echo -e "${RED}🔴 ACCESO PROHIBIDO${NC}"
      echo ""
      echo "Archivo fuera de tu alcance como frontend agent."
      echo ""
      echo "Archivos permitidos:"
      echo "  - frontend/**"
      echo "  - Dockerfile.frontend"
      echo "  - package.json"
      echo "  - tsconfig.json"
      echo ""
      echo "DEBES consultar al usuario antes de acceder."
      echo ""
      exit 2
    fi
    ;;

  infra)
    # Permitidos: docker-compose, nginx, scripts, Dockerfile.*
    if contains "$FILE_PATH" "docker-compose" || \
       contains "$FILE_PATH" "nginx" || \
       contains "$FILE_PATH" "scripts/" || \
       contains "$FILE_PATH" "Dockerfile"; then
      echo -e "${GREEN}🟢 ACCESO PERMITIDO${NC}"
      echo "Archivo dentro de tu alcance como infra agent"
      exit 0

    # Consulta: .env, backend/config/settings.py (para entender env vars)
    elif contains "$FILE_PATH" ".env" || \
         contains "$FILE_PATH" "backend/config/settings.py"; then
      echo -e "${YELLOW}🟡 CONSULTA REQUERIDA${NC}"
      echo ""
      echo "Archivo compartido o de configuración."
      echo "Puedes LEER para entender configuración."
      echo "CONSULTA antes de MODIFICAR."
      echo ""
      exit 1

    # Prohibido: backend/models, frontend/src
    else
      echo -e "${RED}🔴 ACCESO PROHIBIDO${NC}"
      echo ""
      echo "Archivo fuera de tu alcance como infra agent."
      echo ""
      echo "Archivos permitidos:"
      echo "  - docker-compose*.yml"
      echo "  - nginx*.conf"
      echo "  - scripts/**"
      echo "  - Dockerfile.*"
      echo ""
      echo "DEBES consultar al usuario antes de acceder."
      echo ""
      exit 2
    fi
    ;;

  main)
    # Main tiene acceso completo para revisión
    echo -e "${GREEN}🟢 ACCESO PERMITIDO${NC}"
    echo "Main agent tiene acceso completo para revisión y coordinación"
    exit 0
    ;;

  *)
    echo -e "${RED}Tipo de agente inválido: $AGENT_TYPE${NC}"
    echo "Tipos válidos: backend, frontend, infra, main"
    exit 1
    ;;
esac
