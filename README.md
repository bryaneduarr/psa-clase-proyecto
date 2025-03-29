# Scripts de Automatización para Sistemas Linux

Una colección de scripts Bash diseñados para automatizar tareas comunes de administración del sistema, incluyendo:

- Limpieza de archivos temporales
- Creación de copias de seguridad del sistema
- Análisis de registros

## Descripción

Este proyecto proporciona una interfaz centralizada basada en menús para ejecutar diversas tareas de mantenimiento del sistema mediante scripts de shell. Los scripts están organizados en módulos separados para diferentes funciones administrativas:

- **Limpieza de Archivos**: Eliminación automática de archivos temporales y registros antiguos
- **Copia de Seguridad del Sistema**: Creación y gestión de copias de seguridad de datos del sistema y del usuario
- **Análisis de Registros**: Escaneo y generación de informes automatizados de los registros del sistema para detectar problemas

## Uso

Ejecute el script del menú principal para acceder a todas las funciones:

```bash
cd src
bash menu.sh
```

_Cada script también puede ejecutarse individualmente si es necesario._

### Docker

Si utilizas [Docker](https://www.docker.com/), puede compilar y ejecutar la imagen con `docker-compose` con el siguiente comando:

```bash
docker-compose up -d
```

Para acceder al shell dentro del contenedor, puede usar el siguiente comando:

```bash
docker exec -it psa-proyecto-container /bin/bash
```

Para detener el contenedor, puede usar el siguiente comando:

```bash
docker-compose down
```

### Contenedores de desarrollo

Si utilizas [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) de [Visual Studio Code](https://code.visualstudio.com/), utiliza el editor de [Visual Studio Code](https://code.visualstudio.com/) y clona este repositorio con el comando:

```bash
git clone https://github.com/bryaneduarr/psa-clase-proyecto.git 
```

Una vez clonado este repositorio y abras [Visual Studio Code](https://code.visualstudio.com/), debería aparecer un mensaje que te pide que abras en el contenedor. También puedes buscar esta opción en la paleta de comandos integrada en el editor. Al aceptarla, se iniciará la construcción de la imagen y el proyecto.
