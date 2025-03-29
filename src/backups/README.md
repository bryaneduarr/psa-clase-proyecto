# Sistema de copias de seguridad

Hay tres scripts de copia de seguridad disponibles:

## backup.sh

Crea copias de seguridad comprimidas de los datos del usuario con las siguientes características:

- Utiliza compresión zstd para un almacenamiento eficiente
- Mantiene un conjunto rotatorio de las 5 copias de seguridad más recientes
- Registra todas las operaciones de copia de seguridad

## backup_so.sh

Crea copias de seguridad completas del sistema con:

- Conservación de las 3 copias de seguridad más recientes del sistema
- No realiza copia de archivos temporales e inecesarios
- Registro de todas las operaciones de copia de seguridad

## restaurar_punto_respaldo.sh

Proporciona una interfaz interactiva para:

- Seleccionar entre los puntos de copia de seguridad disponibles
- Restaurar un sistema desde una copia de seguridad
- Opcionalmente, reinstalar el gestor de arranque (GRUB)
