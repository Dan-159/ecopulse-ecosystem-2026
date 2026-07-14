import paho.mqtt.client as mqtt
import json
import time
import random
# Simulación de un sensor de la zona 3, 
# publicando datos cada 10 segundos en el tópico "fisi/ecopulse/zona/3"
BROKER = "broker.hivemq.com" # Broker público para pruebas
PORT = 1883
ID_ZONA = 3
TOPIC = f"fisi/ecopulse/zona/{ID_ZONA}"

client = mqtt.Client()
client.connect(BROKER, PORT)

print("🚀 Sensor MQTT iniciado")
print(f"📡 Publicando en: {TOPIC}")

try:
    while True:

        payload = {
            "lectura_de_co2": round(random.randint(400, 1300), 2),  #400-1200
            "lectura_de_nox": round(random.randint(0, 120), 2),     #0-100
            "lectura_de_pm25": round(random.randint(0, 160), 2),    #0-150
            "timestamp": time.time()
        }

        resultado = client.publish(TOPIC,json.dumps(payload))

        # Verificar si la publicación fue exitosa
        if resultado.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"📤 Enviado por MQTT: {payload}")
        else:
            print(
                f"⚠️ Error al publicar mensaje "
                f"(código {resultado.rc})"
            )
        
        time.sleep(10)

except KeyboardInterrupt:
    print("\n🛑 Deteniendo sensor...")

finally:
    client.disconnect()
    print("✅ Desconectado del broker")
