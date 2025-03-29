#!/bin/bash

DIR_RESPALDO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/backups"
ARCHIVO_RESPALDO="$DIR_RESPALDO/backupSO_$FECHA_ACTUAL.tar.zst"
ARCHIVO_LOG="$DIR_RESPALDO/backupSO.log"

FECHA_ACTUAL=$(date +%Y%m%d_%H%M%S)

if [ ! -d "$DIR_RESPALDO" ]; then
    mkdir -p "$DIR_RESPALDO"
    echo "[$(date)] Creando directorio de respaldo: $DIR_RESPALDO" >>"$ARCHIVO_LOG"
fi

echo "[$(date)] Iniciando respaldo completo del sistema..." >>"$ARCHIVO_LOG"

if sudo tar --exclude="/proc" \
    --exclude="/sys" \
    --exclude="/dev" \
    --exclude="/run" \
    --exclude="/mnt" \
    --exclude="/media" \
    --exclude="/lost+found" \
    --exclude="$DIR_RESPALDO" \
    --exclude="/var/cache" \
    -I 'zstd -9' \
    -cf "$ARCHIVO_RESPALDO" / 2>>"$ARCHIVO_LOG"; then
    echo "[$(date)] Respaldo completo realizado con éxito: $ARCHIVO_RESPALDO" >>"$ARCHIVO_LOG"
else
    echo "[$(date)] Error al realizar la copia de seguridad" >>"$ARCHIVO_LOG"
    exit 1
fi

CONTEO_RESPALDOS=$(find "$DIR_RESPALDO"/backupSO_*.tar.zst | wc -l)
if [ "$CONTEO_RESPALDOS" -gt 3 ]; then
    echo "[$(date)] Eliminando respaldos antiguos..." >>"$ARCHIVO_LOG"
    find "$DIR_RESPALDO"/backupSO_*.tar.zst | tail -n +4 | xargs rm -f
    echo "[$(date)] Respaldos antiguos eliminados. Se mantienen los últimos 3." >>"$ARCHIVO_LOG"
fi

echo "[$(date)] Tarea de respaldo completo del sistema finalizada." >>"$ARCHIVO_LOG"
