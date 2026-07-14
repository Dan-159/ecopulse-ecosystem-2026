import time
import json
import random
import threading
import paho.mqtt.client as mqtt

BROKER = "broker.hivemq.com"
PORT = 1883
ZONAS = [1, 2, 3]

shutdown_event = threading.Event()

def simular_sensor(id_zona):
    topic = f"fisi/ecopulse/zona/{id_zona}"
    
    client = mqtt.Client()
    client.connect(BROKER, PORT)
    
    print(f"📡 [Zona {id_zona}] Conectado y publicando en: {topic}")
    
    try:
        while not shutdown_event.is_set():
            payload = {
                "lectura_de_co2": round(random.randint(400, 1300), 2),
                "lectura_de_nox": round(random.randint(0, 120), 2),
                "lectura_de_pm25": round(random.randint(0, 160), 2),
                "timestamp": time.time()
            }

            resultado = client.publish(topic, json.dumps(payload))
            if resultado.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"📤 [Zona {id_zona}] Enviado: {payload}")
            else:
                print(f"⚠️ [Zona {id_zona}] Error al publicar")
            
            
            for _ in range(20):
                if shutdown_event.is_set():
                    break
                time.sleep(0.5)
            
    except Exception as e:
        print(f"❌ Error en Zona {id_zona}: {e}")
    finally:
        client.disconnect()
        print(f"✅ [Zona {id_zona}] Desconectado del broker de manera segura")

if __name__ == "__main__":
    hilos = []
    print("🚀 Iniciando simulación multihilo para todas las zonas...")
    
    for zona in ZONAS:
        hilo = threading.Thread(target=simular_sensor, args=(zona,))
        hilo.start()
        hilos.append(hilo)
        time.sleep(0.5)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Deteniendo todos los sensores... Por favor, espera a que se desconecten.")
        shutdown_event.set()
        
        for hilo in hilos:
            hilo.join()
            
        print("🏁 Simulación finalizada por completo.")
