#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LIMPIEZA_SCRIPT="$BASE_DIR/limpieza/limpiar_temporales.sh"
RESPALDO_SCRIPT="$BASE_DIR/backups/backup-usuario/backup.sh"
ANALISIS_SCRIPT="$BASE_DIR/analisisologs/analisis_logs.sh"

if [[ ! -f $LIMPIEZA_SCRIPT ]]; then
    echo "Error: No se encuentra $LIMPIEZA_SCRIPT"
    exit 1
fi
if [[ ! -f $RESPALDO_SCRIPT ]]; then
    echo "Error: No se encuentra $RESPALDO_SCRIPT"
    exit 1
fi
if [[ ! -f $ANALISIS_SCRIPT ]]; then
    echo "Error: No se encuentra $ANALISIS_SCRIPT"
    exit 1
fi

while true; do
    clear
    echo "============================="
    echo " Menú de Tareas Automatizadas"
    echo "============================="
    echo "1. Ejecutar limpieza de archivos temporales"
    echo "2. Ejecutar respaldo"
    echo "3. Ejecutar análisis de logs"
    echo "4. Salir"
    echo "============================="
    read -r -p "Seleccione una opción: " opcion

    case $opcion in
    1)
        echo "Ejecutando limpieza de archivos temporales..."
        bash "$LIMPIEZA_SCRIPT"
        echo "Limpieza de archivos temporales completada."
        read -r -p "Presione Enter para continuar..."
        ;;
    2)
        echo "Ejecutando copia de seguridad..."
        bash "$RESPALDO_SCRIPT"
        echo "Copia de seguridad completada."
        read -r -p "Presione Enter para continuar..."
        ;;
    3)
        echo "Ejecutando análisis de logs..."
        bash "$ANALISIS_SCRIPT"
        echo "Análisis de logs completado."
        read -r -p "Presione Enter para continuar..."
        ;;
    4)
        echo "Saliendo..."
        break
        ;;
    *)
        clear
        echo "Opción no válida. Inténtelo de nuevo."
        read -r -p "Presione Enter para continuar..."
        ;;
    esac
done
