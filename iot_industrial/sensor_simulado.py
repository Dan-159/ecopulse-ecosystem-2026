import requests
import time
import random

# CONFIGURACIÓN
API_URL = "http://localhost:8000/lecturas/"
ID_ZONA = 1  # ID de la estación registrada en la DB
ID_ZONA_SENSOR = 1  # ID del sensor de esa zona registrado en la DB

# Configuración para obtener el token de autenticación
LOGIN_URL = "http://localhost:8000/auth/login" 
form_data = {"username": "admin_fisi", "password": "ecopulse2026"}  
token_recibido = requests.post(LOGIN_URL, data=form_data)
TOKEN = token_recibido.json().get("access_token") 
#Recordar que el token tiene una duración limitada (30 min)

def leer_sensor_emulado():
    return round(random.uniform(10.5, 65.0), 2)

def enviar_telemetria():
    print(f"--- Iniciando lecturas del sensor {ID_ZONA_SENSOR} de la Estación {ID_ZONA} ---")
    
    while True:
        valor = leer_sensor_emulado()
        payload = {
            "id_zona": ID_ZONA,
            "id_zona_sensor": ID_ZONA_SENSOR,
            "valor": valor
        }
        headers = {
            "Authorization": f"Bearer {TOKEN}"
        }

        try:
            response = requests.post(API_URL, json=payload, headers=headers)
            if response.status_code == 201:
                if(valor > 50):
                    print(f"[ALERTA] Umbral de contaminación superado: {valor}")
                else:
                    print(f"[OK] Lectura enviada: {valor}")
            else:
                print(f"[ERROR] Código: {response.status_code}")
        except Exception as e:
            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")

        # Tiempo entre cada lectura 
        if(valor > 50):
            time.sleep(2)
        else:
            time.sleep(10)

if __name__ == "__main__":
    enviar_telemetria()