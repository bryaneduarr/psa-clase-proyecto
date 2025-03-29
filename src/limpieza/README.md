# Limpieza de archivos

El script `limpiar-temporales.sh` automatiza la limpieza de:

- Archivos en `/tmp` y `/var/tmp` con más de 7 días en el sistema
- Archivos de registro en `/var/log` con más de 30 días en el sistema
- Archivos de caché en los directorios personales del usuario con más de 30 días en el sistema
