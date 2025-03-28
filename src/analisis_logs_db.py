import os
import datetime
import csv
import mysql.connector
import re

DIR_ANALISIS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "analisis_logs")
ARCHIVO_ANALISIS = os.path.join(DIR_ANALISIS, "logs_analizados.csv")
ARCHIVO_LOG = os.path.join(DIR_ANALISIS, "registro_analisis.log")
ARCHIVO_ULTIMA_FECHA = os.path.join(DIR_ANALISIS, "ultima_fecha.txt")

DB_NAME = "logs"
DB_USER = "admin"
DB_PASS = "password"
ARCHIVOS_LOG = [
    "/var/log/syslog",
    "/var/log/auth.log",
    "/var/log/kern.log",
    "/var/log/secure",
    "/var/log/mysql/error.log",
    "/var/log/apache2/error.log",
    "/var/log/nginx/error.log",
]

PALABRAS_CLAVE = [
    "error",
    "warning",
    "fail",
    "critical",
    "alert",
    "denied",
    "blocked",
    "forbidden",
    "unauthorized",
]

os.makedirs(DIR_ANALISIS, exist_ok=True)

if os.path.exists(ARCHIVO_ULTIMA_FECHA):
    with open(ARCHIVO_ULTIMA_FECHA, "r") as f:
        ULTIMA_FECHA = f.read().strip()
else:
    ULTIMA_FECHA = "2000-01-01 00:00:00"

with open(ARCHIVO_LOG, "a") as log_file:
    log_file.write(
        f"[{datetime.datetime.now()}] Iniciando análisis desde {ULTIMA_FECHA}...\n"
    )

try:
    conn = mysql.connector.connect(
        host="localhost", user=DB_USER, password=DB_PASS, database=DB_NAME
    )
    cursor = conn.cursor()
except mysql.connector.Error as err:
    with open(ARCHIVO_LOG, "a") as log_file:
        log_file.write(f"Error MySQL: {err}\n")
    exit(1)

if not os.path.exists(ARCHIVO_ANALISIS):
    with open(ARCHIVO_ANALISIS, "w", newline="") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(
            ["Fecha", "Archivo", "Palabra_Clave", "Usuario", "IP", "Mensaje"]
        )


def analizar_log(archivo):
    if os.path.isfile(archivo):
        with open(ARCHIVO_LOG, "a") as log_file:
            log_file.write(f"Analizando {archivo}...\n")

        try:
            cmd = f"awk '$0 > \"{ULTIMA_FECHA}\"' {archivo}"
            nuevas_lineas = os.popen(cmd).read().splitlines()

            for linea in nuevas_lineas:
                palabra_encontrada = None
                for palabra_clave in PALABRAS_CLAVE:
                    if re.search(rf"\b{palabra_clave}\b", linea, re.IGNORECASE):
                        palabra_encontrada = palabra_clave
                        break

                if palabra_encontrada:
                    partes = linea.split()
                    fecha = " ".join(partes[:3]) if len(partes) > 3 else "Desconocido"

                    # usuario_match = re.search(r"user (\w+)", linea)
                    # usuario = usuario_match.group(1) if usuario_match else "Desconocido"
                    # Intentar capturar el usuario con múltiples patrones
                    usuario_match = re.search(r"user (\w+)", linea)  # Patrón básico

                    # Si no se encontró usuario, probar patrones más amplios
                    if not usuario_match:
                        usuario_match = re.search(
                            r"(?:User|user|usuario|session|account)[:=]?\s*([a-zA-Z0-9_\-]+)",
                            linea,
                        )

                    # Si sigue sin encontrar usuario, buscar errores específicos de MySQL o SSH
                    if not usuario_match:
                        if "mysql" in archivo.lower():
                            usuario_match = re.search(
                                r"Access denied for user '([^']+)'", linea
                            )
                        elif "auth.log" in archivo.lower():
                            usuario_match = re.search(
                                r"Failed password for (\w+)", linea
                            )

                    # Asignar el usuario encontrado o "Desconocido" si no se detectó ninguno
                    usuario = usuario_match.group(1) if usuario_match else "Desconocido"

                    ip_match = re.search(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", linea)
                    ip = ip_match.group(0) if ip_match else "0.0.0.0"

                    mensaje = " ".join(partes[3:]).replace('"', '\\"')

                    # Guardar en CSV
                    with open(ARCHIVO_ANALISIS, "a", newline="") as csv_file:
                        writer = csv.writer(csv_file)
                        writer.writerow(
                            [fecha, archivo, palabra_encontrada, usuario, ip, mensaje]
                        )

                    # Insertar en MySQL
                    query = "INSERT INTO registros_logs (archivo_log, palabra_clave, usuario, ip, mensaje) VALUES (%s, %s, %s, %s, %s)"
                    cursor.execute(
                        query, (archivo, palabra_encontrada, usuario, ip, mensaje)
                    )

        except Exception as e:
            with open(ARCHIVO_LOG, "a") as log_file:
                log_file.write(f"Error en {archivo}: {e}\n")


# Ejecutar análisis solo en registros nuevos
for archivo in ARCHIVOS_LOG:
    analizar_log(archivo)

# Guardar nueva fecha de análisis
nueva_fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
with open(ARCHIVO_ULTIMA_FECHA, "w") as f:
    f.write(nueva_fecha)

# Confirmar cambios en la base de datos
conn.commit()
cursor.close()
conn.close()

# Registrar fin del análisis
with open(ARCHIVO_LOG, "a") as log_file:
    log_file.write(
        f"[{datetime.datetime.now()}] Análisis completado. Resultados en {ARCHIVO_ANALISIS}\n"
    )

"""
# Enviar correo electrónico si `mail` está disponible
MAIL_CMD = "which mail"
if os.system(MAIL_CMD) == 0:
    os.system(f'echo "Adjunto el reporte de logs del día" | mail -s "Reporte de Logs" -A /root/SistemasAbiertosI/reportes/logs_grafico.png saberxshido@gmail.com')
else:
    with open(ARCHIVO_LOG, "a") as log_file:
        log_file.write("El comando 'mail' no está disponible.\n")
"""
# SELECT * FROM registros_logs
# ORDER BY fecha DESC
# LIMIT 20;
