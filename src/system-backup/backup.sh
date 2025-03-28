#!/bin/bash

DIR_RESPALDO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/respaldo/"
ARCHIVO_LOG="$DIR_RESPALDO/backup.log"

FECHA_ACTUAL=$(date +%Y%m%d_%H%M%S)

ARCHIVO_RESPALDO="$DIR_RESPALDO/backup_$FECHA_ACTUAL.tar.zst"

if [ ! -d "$DIR_RESPALDO" ]; then
    mkdir -p "$DIR_RESPALDO"
    echo "[$(date)] Creando directorio de respaldo: $DIR_RESPALDO" >>"$ARCHIVO_LOG"
fi

echo "[$(date)] Iniciando copia de seguridad..." >>"$ARCHIVO_LOG"
if tar --exclude='/root/.cache' \
    --exclude="$DIR_RESPALDO" \
    --exclude='/root/tmp' \
    -I 'zstd -9' \
    -cf "$ARCHIVO_RESPALDO" /root 2>>"$ARCHIVO_LOG"; then
    echo "[$(date)] Copia de seguridad realizada con éxito: $ARCHIVO_RESPALDO" >>"$ARCHIVO_LOG"
else
    echo "[$(date)] Error al realizar la copia de seguridad" >>"$ARCHIVO_LOG"
fi

CONTEO_RESPALDOS=$(find "$DIR_RESPALDO"/backup_*.tar.zst | wc -l)

if [ "$CONTEO_RESPALDOS" -gt 5 ]; then
    echo "[$(date)] Limpiando respaldos antiguos..." >>"$ARCHIVO_LOG"
    find "$DIR_RESPALDO"/backup_*.tar.zst | tail -n +6 | xargs rm -f
    echo "[$(date)] Respaldos antiguos eliminados. Se mantienen los últimos 5." >>"$ARCHIVO_LOG"
fi

echo "[$(date)] Tarea de copia de seguridad completada." >>"$ARCHIVO_LOG"
