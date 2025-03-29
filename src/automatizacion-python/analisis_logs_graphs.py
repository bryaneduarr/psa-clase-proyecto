import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import os
from email.message import EmailMessage
import smtplib
import subprocess

try:
    conn = mysql.connector.connect(
        user="iot_user", password="IotPass123!", host="localhost", database="logs"
    )
    if conn.is_connected():
        print("Conexión exitosa a la base de datos")
except mysql.connector.Error as e:
    print(f"Error al conectar con MySQL: {e}")
    exit()


def obtener_datos(query):
    df = pd.read_sql_query(query, conn)
    return df if not df.empty else None


# FRECUENCIA DE PALABRAS CLAVE (LOGS)
def grafico_frecuencia_palabras():
    query = """
        SELECT palabra_clave, COUNT(*) as total
        FROM registros_logs
        GROUP BY palabra_clave
        ORDER BY total DESC;
    """
    df = obtener_datos(query)
    if df is None:
        return

    plt.figure(figsize=(10, 6))
    plt.bar(df["palabra_clave"], df["total"], color="red", alpha=0.8)
    plt.xlabel("Palabras Clave")
    plt.ylabel("Cantidad de Ocurrencias")
    plt.title("Frecuencia de Palabras Clave en Logs")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig("/root/SistemasAbiertosI/analisis_logs/reportes/logs/logs_grafico.png")
    plt.show()


# TENDENCIA DE EVENTOS CRÍTICOS EN EL TIEMPO
def grafico_tendencia_errores():
    query = """
        SELECT DATE(fecha) as fecha, COUNT(*) as total
        FROM registros_logs
        WHERE palabra_clave IN ('error', 'critical', 'fail')
        GROUP BY DATE(fecha)
        ORDER BY fecha;
    """
    df = obtener_datos(query)
    if df is None:
        return

    plt.figure(figsize=(10, 5))
    plt.plot(
        df["fecha"], df["total"], marker="o", linestyle="-", color="red", alpha=0.8
    )
    plt.xlabel("Fecha")
    plt.ylabel("Cantidad de Errores")
    plt.title("Tendencia de Eventos Críticos en el Tiempo")
    plt.xticks(rotation=45)
    plt.grid()
    plt.tight_layout()
    plt.savefig(
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/tendencia_errores.png"
    )
    plt.show()


# DISTRIBUCIÓN DE ERRORES POR ARCHIVO LOG
def grafico_errores_por_archivo():
    query = """
        SELECT archivo_log, COUNT(*) as total
        FROM registros_logs
        GROUP BY archivo_log
        ORDER BY total DESC
        LIMIT 10;
    """
    df = obtener_datos(query)
    if df is None:
        return

    plt.figure(figsize=(10, 5))
    plt.barh(df["archivo_log"], df["total"], color="blue", alpha=0.8)
    plt.xlabel("Cantidad de Errores")
    plt.ylabel("Archivo de Log")
    plt.title("Distribución de Errores por Archivo de Log")
    plt.gca().invert_yaxis()
    plt.tight_layout()
    plt.savefig(
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/errores_por_archivo.png"
    )
    plt.show()


# TOP 5 IPS CON MÁS EVENTOS DE SEGURIDAD
def grafico_top_ips():
    query = """
        SELECT ip, COUNT(*) as total
        FROM registros_logs
        WHERE ip != '0.0.0.0'
        GROUP BY ip
        ORDER BY total DESC
        LIMIT 5;
    """
    df = obtener_datos(query)
    if df is None:
        return

    plt.figure(figsize=(8, 5))
    plt.pie(
        df["total"],
        labels=df["ip"],
        autopct="%1.1f%%",
        colors=["red", "orange", "yellow", "green", "blue"],
    )
    plt.title("Top 5 IPs con Más Eventos de Seguridad")
    plt.tight_layout()
    plt.savefig("/root/SistemasAbiertosI/analisis_logs/reportes/logs/top_ips.png")
    plt.show()


# ERRORES POR USUARIO
def grafico_errores_por_usuario():
    query = """
        SELECT usuario, COUNT(*) as total
        FROM registros_logs
        WHERE usuario != 'Desconocido'
        GROUP BY usuario
        ORDER BY total DESC
        LIMIT 10;
    """
    df = obtener_datos(query)
    if df is None:
        return

    plt.figure(figsize=(10, 5))
    plt.bar(df["usuario"], df["total"], color="purple", alpha=0.8)
    plt.xlabel("Usuario")
    plt.ylabel("Cantidad de Errores")
    plt.title("Errores por Usuario")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(
        "/root/SistemasAbiertosI/analisis_logs/reportes/errores_por_usuario.png"
    )
    plt.show()


grafico_frecuencia_palabras()
grafico_tendencia_errores()
grafico_errores_por_archivo()
grafico_top_ips()
grafico_errores_por_usuario()


def enviar_correo():
    archivos = [
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/logs_grafico.png",
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/tendencia_errores.png",
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/errores_por_archivo.png",
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/top_ips.png",
        "/root/SistemasAbiertosI/analisis_logs/reportes/logs/errores_por_usuario.png",
    ]

    destinatario = "saberxshido@gmail.com"
    asunto = "Reporte de Logs"
    cuerpo_mensaje = "Adjunto el reporte de logs del día."

    comando_mutt = ["mutt", "-s", asunto, destinatario]

    for archivo in archivos:
        comando_mutt.extend(["-a", archivo])

    try:
        subprocess.run(comando_mutt, input=cuerpo_mensaje.encode(), check=True)
        print("Correo enviado con éxito usando mutt.")
    except subprocess.CalledProcessError as e:
        print(f"Error al enviar el correo con mutt: {e}")


enviar_correo()
