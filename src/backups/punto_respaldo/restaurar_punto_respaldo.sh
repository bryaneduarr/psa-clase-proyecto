#!/bin/bash

# Definir variables
DIR_RESPALDO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/respaldo/respaldo_puntos"
ARCHIVO_LOG="$DIR_RESPALDO/restauracion.log"

# Verificar si hay respaldos disponibles
RESPALDOS=("$DIR_RESPALDO"/puntoRespaldo_*.tar.zst)

if [ ${#RESPALDOS[@]} -eq 0 ]; then
    echo "No hay puntos de respaldo disponibles." | tee -a "$ARCHIVO_LOG"
    exit 1
fi

# Mostrar los respaldos disponibles
echo "Puntos de respaldo disponibles:"
for i in "${!RESPALDOS[@]}"; do
    echo "[$i] ${RESPALDOS[$i]}"
done

# Pedir al usuario que elija un respaldo
read -r -p "Seleccione el número del respaldo a restaurar: " SELECCION

# Verificar si la selección es válida
if [[ ! "$SELECCION" =~ ^[0-9]+$ ]] || [ "$SELECCION" -ge "${#RESPALDOS[@]}" ]; then
    echo "Selección inválida." | tee -a "$ARCHIVO_LOG"
    exit 1
fi

ARCHIVO_A_RESTAURAR="${RESPALDOS[$SELECCION]}"
echo "Restaurando desde: $ARCHIVO_A_RESTAURAR" | tee -a "$ARCHIVO_LOG"

# Pedir confirmación antes de proceder
read -r -p "¿Seguro que quieres restaurar este punto de respaldo? (s/n): " CONFIRMACION
if [[ "$CONFIRMACION" != "s" && "$CONFIRMACION" != "S" ]]; then
    echo "Operación cancelada." | tee -a "$ARCHIVO_LOG"
    exit 0
fi

# Montar el sistema de archivos
echo "Montando sistema y restaurando archivos..." | tee -a "$ARCHIVO_LOG"
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

if tar -I 'zstd' -xf "$ARCHIVO_A_RESTAURAR" -C /mnt 2>>"$ARCHIVO_LOG"; then
    echo "Restauración completada con éxito." | tee -a "$ARCHIVO_LOG"
else
    echo "Error durante la restauración." | tee -a "$ARCHIVO_LOG"
    exit 1
fi

# Reinstalar GRUB si es necesario
read -r -p "¿Quieres reinstalar GRUB? (s/n): " REINSTALAR_GRUB
if [[ "$REINSTALAR_GRUB" == "s" || "$REINSTALAR_GRUB" == "S" ]]; then
    read -r -p "Ingresa el dispositivo de instalación de GRUB (ejemplo: /dev/sda): " DISPOSITIVO_GRUB
    chroot /mnt grub-install "$DISPOSITIVO_GRUB"
    chroot /mnt update-grub
    echo "GRUB reinstalado correctamente." | tee -a "$ARCHIVO_LOG"
fi

echo "Proceso de restauración finalizado. Reiniciando el sistema..." | tee -a "$ARCHIVO_LOG"
reboot
