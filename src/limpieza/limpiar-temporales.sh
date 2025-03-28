#!/bin/bash

DIRECTORIO_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVO_LOG="$DIRECTORIO_ACTUAL/limpieza.log"
echo "[$(date)] Iniciando limpieza de archivos temporales y logs" >>"$ARCHIVO_LOG"

limpiar_directorio() {
    local directorio=$1
    local dias=$2
    if [ -d "$directorio" ]; then
        {
            echo "Limpiando archivos en $directorio con más de $dias días..."
            find "$directorio" -type f -mtime +"$dias" -exec rm -f {} \; 2>&1
            echo "Limpieza en $directorio completada."
        } >>"$ARCHIVO_LOG"
    else
        echo "Directorio $directorio no encontrado. Saltando." >>"$ARCHIVO_LOG"
    fi
}

limpiar_directorio "/tmp" 7
limpiar_directorio "/var/tmp" 7

if [ -d "/var/log" ]; then
    {
        echo "Limpiando logs antiguos en /var/log con más de 30 días..."
        find /var/log -type f -mtime +30 ! -name "*.gz" ! -name "*.xz" -exec rm -f {} \; 2>&1
        echo "Limpieza de logs en /var/log completada."
    } >>"$ARCHIVO_LOG"
else
    echo "/var/log no encontrado. Saltando limpieza de logs." >>"$ARCHIVO_LOG"
fi

for directorio_usuario in /home/*; do
    if [ -d "$directorio_usuario/.cache" ]; then
        limpiar_directorio "$directorio_usuario/.cache" 30
    fi
done

echo "[$(date)] Limpieza completada." >>"$ARCHIVO_LOG"
