#!/usr/bin/env python3
"""
Excel to CSV Converter
======================

Herramienta para convertir archivos Excel (.xlsx) a archivos CSV,
exportando cada hoja como un archivo CSV separado.

Uso:
    python excel_to_csv.py <archivo.xlsx> [output_dir]

Argumentos:
    archivo.xlsx : Ruta al archivo Excel a convertir
    output_dir   : (Opcional) Directorio de salida para los CSV
                   Por defecto: mismo directorio que el archivo Excel

Ejemplo:
    python excel_to_csv.py datos.xlsx
    python excel_to_csv.py datos.xlsx /ruta/output/

Salida:
    Para un archivo "datos.xlsx" con hojas "Sheet1", "Sheet2":
    - datos (Sheet1 sheet).csv
    - datos (Sheet2 sheet).csv

Dependencias:
    - openpyxl (pip install openpyxl)
    - pandas (pip install pandas)

Autor: Claude Code
Fecha: 2025-10-14
"""

import sys
import os
from pathlib import Path
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def convert_excel_to_csv(excel_path, output_dir=None):
    """
    Convierte un archivo Excel a múltiples archivos CSV (uno por hoja).

    Args:
        excel_path (str): Ruta al archivo Excel
        output_dir (str, optional): Directorio de salida. Por defecto, mismo que el Excel.

    Returns:
        list: Lista de rutas de los archivos CSV generados

    Raises:
        FileNotFoundError: Si el archivo Excel no existe
        ImportError: Si faltan las librerías necesarias
    """
    try:
        import pandas as pd
    except ImportError:
        logger.error("Error: pandas no está instalado. Ejecuta: pip install pandas openpyxl")
        sys.exit(1)

    # Validar que el archivo existe
    excel_path = Path(excel_path)
    if not excel_path.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {excel_path}")

    # Determinar directorio de salida
    if output_dir is None:
        output_dir = excel_path.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

    # Nombre base del archivo (sin extensión)
    base_name = excel_path.stem

    logger.info(f"Leyendo archivo: {excel_path}")
    logger.info(f"Directorio de salida: {output_dir}")

    # Leer todas las hojas del Excel
    try:
        excel_file = pd.ExcelFile(excel_path, engine='openpyxl')
        sheet_names = excel_file.sheet_names
        logger.info(f"Hojas encontradas: {len(sheet_names)}")
    except Exception as e:
        logger.error(f"Error al leer el archivo Excel: {e}")
        sys.exit(1)

    csv_files = []

    # Convertir cada hoja a CSV
    for i, sheet_name in enumerate(sheet_names, 1):
        logger.info(f"[{i}/{len(sheet_names)}] Procesando hoja: '{sheet_name}'")

        try:
            # Leer la hoja
            df = pd.read_excel(excel_file, sheet_name=sheet_name)

            # Construir nombre del archivo CSV
            # Formato: "nombre_archivo (nombre_hoja sheet).csv"
            csv_filename = f"{base_name} ({sheet_name} sheet).csv"
            csv_path = output_dir / csv_filename

            # Guardar como CSV
            df.to_csv(csv_path, index=False, encoding='utf-8')

            csv_files.append(str(csv_path))
            logger.info(f"    ✓ Exportado: {csv_filename} ({len(df)} filas, {len(df.columns)} columnas)")

        except Exception as e:
            logger.error(f"    ✗ Error al procesar '{sheet_name}': {e}")
            continue

    logger.info(f"\n{'='*60}")
    logger.info(f"Conversión completada: {len(csv_files)} archivos CSV generados")
    logger.info(f"{'='*60}\n")

    return csv_files


def main():
    """Función principal para ejecutar desde línea de comandos."""

    # Verificar argumentos
    if len(sys.argv) < 2:
        print("Error: Debes proporcionar la ruta al archivo Excel")
        print(f"\nUso: {sys.argv[0]} <archivo.xlsx> [output_dir]")
        print(f"\nEjemplo:")
        print(f"  {sys.argv[0]} datos.xlsx")
        print(f"  {sys.argv[0]} datos.xlsx /ruta/salida/")
        sys.exit(1)

    excel_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        csv_files = convert_excel_to_csv(excel_path, output_dir)

        print("\nArchivos generados:")
        for csv_file in csv_files:
            print(f"  • {csv_file}")

    except Exception as e:
        logger.error(f"Error durante la conversión: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
