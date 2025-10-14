# 🛠️ Herramientas Disponibles

Este archivo documenta las herramientas y scripts utilitarios disponibles en el directorio `context/tools/`.

---

## 📋 Índice de Herramientas

| Herramienta | Descripción | Lenguaje | Dependencias |
|-------------|-------------|----------|--------------|
| `excel_to_csv.py` | Convierte archivos Excel a CSV (una hoja → un CSV) | Python 3 | pandas, openpyxl |

---

## 📊 excel_to_csv.py

### Descripción

Script Python para convertir archivos Excel (.xlsx) a múltiples archivos CSV, exportando cada hoja del libro como un archivo CSV separado.

**Caso de uso principal:** Cuando necesitas analizar datos de archivos Excel complejos con múltiples hojas y prefieres trabajar con archivos CSV más simples.

### Uso

```bash
python context/tools/excel_to_csv.py <archivo.xlsx> [output_dir]
```

**Parámetros:**
- `archivo.xlsx` (requerido): Ruta al archivo Excel a convertir
- `output_dir` (opcional): Directorio donde guardar los CSV. Por defecto: mismo directorio que el Excel

### Ejemplos

#### Ejemplo 1: Conversión básica

```bash
python context/tools/excel_to_csv.py docs/inputs/datos.xlsx
```

**Salida:**
```
datos (Sheet1 sheet).csv
datos (Sheet2 sheet).csv
datos (Sheet3 sheet).csv
```

#### Ejemplo 2: Especificar directorio de salida

```bash
python context/tools/excel_to_csv.py docs/inputs/propuesta.xlsx docs/outputs/csv/
```

**Salida en `docs/outputs/csv/`:**
```
propuesta (Horarios AD sheet).csv
propuesta (Materias sheet).csv
propuesta (Aulas sheet).csv
```

#### Ejemplo 3: Caso real del proyecto

```bash
# Convertir el archivo principal de planificación
python context/tools/excel_to_csv.py "docs/inputs/2. Nueva propuesta 22-sept.xlsx"

# Resultado en docs/inputs/:
# ✓ 2. Nueva propuesta 22-sept (Horarios AD 1SEM sheet).csv
# ✓ 2. Nueva propuesta 22-sept (LAE sheet).csv
# ✓ 2. Nueva propuesta 22-sept (ND sheet).csv
# ✓ 2. Nueva propuesta 22-sept (LAE Ajustado sheet).csv
# ✓ 2. Nueva propuesta 22-sept (ND ajustado sheet).csv
```

### Formato de Salida

Los archivos CSV generados siguen este patrón de nomenclatura:

```
{nombre_archivo_original} ({nombre_hoja} sheet).csv
```

**Características:**
- Encoding: UTF-8
- Delimitador: `,` (coma)
- Sin índice de fila
- Cabeceras incluidas (primera fila)

### Output del Script

El script muestra información detallada durante la ejecución:

```
2025-10-14 20:25:30 - INFO - Leyendo archivo: docs/inputs/datos.xlsx
2025-10-14 20:25:30 - INFO - Directorio de salida: docs/inputs
2025-10-14 20:25:30 - INFO - Hojas encontradas: 3
2025-10-14 20:25:30 - INFO - [1/3] Procesando hoja: 'Sheet1'
2025-10-14 20:25:30 - INFO -     ✓ Exportado: datos (Sheet1 sheet).csv (150 filas, 10 columnas)
2025-10-14 20:25:31 - INFO - [2/3] Procesando hoja: 'Sheet2'
2025-10-14 20:25:31 - INFO -     ✓ Exportado: datos (Sheet2 sheet).csv (75 filas, 8 columnas)
2025-10-14 20:25:31 - INFO - [3/3] Procesando hoja: 'Sheet3'
2025-10-14 20:25:31 - INFO -     ✓ Exportado: datos (Sheet3 sheet).csv (200 filas, 12 columnas)
2025-10-14 20:25:31 - INFO -
============================================================
2025-10-14 20:25:31 - INFO - Conversión completada: 3 archivos CSV generados
2025-10-14 20:25:31 - INFO - ============================================================
```

### Instalación de Dependencias

```bash
pip install pandas openpyxl
```

O si estás trabajando en el backend del proyecto:

```bash
cd backend
source venv/bin/activate  # si usas virtualenv
pip install pandas openpyxl
```

### Manejo de Errores

El script valida y maneja los siguientes casos:

| Error | Descripción | Solución |
|-------|-------------|----------|
| `FileNotFoundError` | El archivo Excel no existe | Verifica la ruta |
| `ImportError` | Faltan pandas u openpyxl | Ejecuta `pip install pandas openpyxl` |
| `PermissionError` | Sin permisos para escribir | Verifica permisos del directorio destino |
| `ValueError` | Excel corrupto o formato inválido | Verifica que el archivo sea un Excel válido |

### Casos de Uso en el Proyecto

#### 1. Análisis de Planificación

Cuando recibes un archivo Excel con múltiples hojas de planificación:

```bash
python context/tools/excel_to_csv.py "docs/inputs/Nueva propuesta.xlsx" docs/inputs/
```

Luego puedes analizar cada hoja individualmente con herramientas como `grep`, `awk`, o leerlas en scripts Python/pandas.

#### 2. Preparación de Datos para Scripts de Carga

Antes de ejecutar scripts como `load_materias.py` o `load_aulas.py`:

```bash
# 1. Convertir Excel a CSV
python context/tools/excel_to_csv.py docs/inputs/materias.xlsx

# 2. Usar CSV en script de carga
python backend/scripts/load_materias.py "docs/inputs/materias (Materias sheet).csv"
```

#### 3. Inspección Rápida de Datos

Para explorar rápidamente el contenido de un Excel sin abrirlo:

```bash
# Convertir a CSV
python context/tools/excel_to_csv.py archivo.xlsx

# Ver primeras líneas
head "archivo (Sheet1 sheet).csv"

# Buscar patrones
grep "LAE" "archivo (Sheet1 sheet).csv"
```

### Limitaciones

- **Solo archivos .xlsx**: No soporta formatos antiguos como .xls (usar LibreOffice/Excel para convertir primero)
- **Sin formato**: No preserva colores, bordes, fórmulas (solo valores calculados)
- **Memoria**: Archivos muy grandes (>100MB) pueden ser lentos, procesar por partes si es necesario

### Alternativas

Si necesitas más control sobre el proceso de conversión, puedes usar pandas directamente:

```python
import pandas as pd

# Leer hoja específica
df = pd.read_excel('datos.xlsx', sheet_name='Horarios')

# Guardar con opciones personalizadas
df.to_csv('salida.csv', sep=';', encoding='latin1', index=False)
```

---

## 🔧 Agregar Nuevas Herramientas

Para agregar una nueva herramienta a esta colección:

1. **Crear el script** en `context/tools/`
2. **Hacerlo ejecutable** (si aplica): `chmod +x script.py`
3. **Documentarlo aquí** siguiendo el formato:
   - Descripción
   - Uso
   - Ejemplos
   - Dependencias
   - Casos de uso
4. **Actualizar la tabla de índice** al inicio de este archivo

### Template de Documentación

```markdown
## 🔧 nombre_herramienta.ext

### Descripción
Breve descripción de qué hace la herramienta.

### Uso
```bash
comando ejemplo
```

### Ejemplos
...

### Dependencias
- dependencia1
- dependencia2

### Casos de Uso en el Proyecto
1. Caso 1
2. Caso 2
```

---

## 📚 Referencias

- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [Openpyxl Documentation](https://openpyxl.readthedocs.io/)

---

**Última actualización:** 2025-10-14
**Mantenido por:** Sistema de contexto UdeSA Cursos
