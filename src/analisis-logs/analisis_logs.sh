#!/bin/bash

DIR_ANALISIS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/analisis-logs"
ARCHIVO_ANALISIS="$DIR_ANALISIS/analisis_logs.txt"
ARCHIVO_LOG="$DIR_ANALISIS/registro_analisis.log"

ARCHIVOS_LOG=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/kern.log"
    "/var/log/dpkg.log"
    "/var/log/messages"
    "/var/log/daemon.log"
    "/var/log/boot.log"
    "/var/log/cron.log"
)

PALABRAS_CLAVE=("error" "warning" "fail" "critical" "alert" "advertencia" "fallo" "critico" "alerta")

if [ ! -d "$DIR_ANALISIS" ]; then
    mkdir -p "$DIR_ANALISIS"
    echo "[$(date)] Creando directorio de análisis: $DIR_ANALISIS" >>"$ARCHIVO_LOG"
fi

: >"$ARCHIVO_ANALISIS"
echo "[$(date)] Análisis de logs iniciado" >>"$ARCHIVO_LOG"

resaltar_palabras_clave() {
    awk -v palabras_clave="${PALABRAS_CLAVE[*]}" '
    BEGIN { split(palabras_clave, pc, " "); }
    { linea = $0;
      for (i in pc) gsub(pc[i], "\033[1;31m" pc[i] "\033[0m", linea);
      print linea;
    }'
}

for ARCHIVO in "${ARCHIVOS_LOG[@]}"; do
    if [ -f "$ARCHIVO" ]; then
        echo "Analizando $ARCHIVO" >>"$ARCHIVO_ANALISIS"

        for palabra in "${PALABRAS_CLAVE[@]}"; do
            conteo=$(grep -ci "$palabra" "$ARCHIVO")
            echo "$palabra: $conteo coincidencias" >>"$ARCHIVO_ANALISIS"
        done
        {
            echo "Entradas relevantes:"
            grep -E "${PALABRAS_CLAVE[*]}" "$ARCHIVO" | resaltar_palabras_clave
            echo ""
        } >>"$ARCHIVO_ANALISIS"
    else
        echo "[$(date)] Archivo no encontrado: $ARCHIVO" >>"$ARCHIVO_LOG"
    fi
done

echo "[$(date)] Análisis de logs completado. Resultados en $ARCHIVO_ANALISIS" >>"$ARCHIVO_LOG"
