extends Node2D

# CONFIGURACIÓN DEL ECOSISTEMA ECOPULSE
const BROKER_URL = "tcp://broker.hivemq.com:1883"
const ID_ZONA_OBJETIVO = 3

# Referencias a los nodos hijos observables en imagen_5.png
@onready var sprite_antena = $Sprite2D
@onready var label_indice = $Label
@onready var mqtt_node = $MQTT
@onready var particulas_smog = $CPUParticles2D

var topic_zona: String

func _ready() -> void:
	topic_zona = "fisi/ecopulse/zona/" + str(ID_ZONA_OBJETIVO)
	
	# Estado inicial de la interfaz visual
	label_indice.text = "Iniciando...\nZona " + str(ID_ZONA_OBJETIVO)
	sprite_antena.modulate = Color.WHITE 
	
	# Conectar las señales nativas definidas en tu mqtt.gd
	mqtt_node.broker_connected.connect(_on_broker_connected)
	mqtt_node.broker_connection_failed.connect(_on_broker_failed)
	mqtt_node.received_message.connect(_on_mqtt_message_received)
	
	# Intentar conexión usando el formato de URL que procesa tu RegEx interno
	print("[ECOPULSE] Conectando a: ", BROKER_URL)
	mqtt_node.connect_to_broker(BROKER_URL)
	particulas_smog.emitting = false
	
	# --- AJUSTES DE VISIBILIDAD PARA EL LABEL ---
	# 1. Cambiar el color del texto a Blanco Puro
	label_indice.add_theme_color_override("font_color", Color.WHITE)
	
	# 2. Activar un contorno Negro
	label_indice.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# 3. Definir el grosor del contorno (un grosor de 6 a 8 píxeles lo hace ultra visible)
	label_indice.add_theme_constant_override("outline_size", 8)

func _on_broker_connected() -> void:
	print("[ECOPULSE] ¡Conectado al Broker con éxito!")
	label_indice.text = "Conectado.\nEsperando telemetría..."
	
	# Realizar suscripción segura una vez abierta la sesión MQTT
	mqtt_node.subscribe(topic_zona, 0)
	print("[ECOPULSE] Suscrito al tópico: ", topic_zona)

func _on_broker_failed() -> void:
	printerr("[ECOPULSE] Error crítico: No se pudo conectar al servidor MQTT.")
	label_indice.text = "Error de Conexión\nBroker inalcanzable"
	sprite_antena.modulate = Color.RED

func _on_mqtt_message_received(topic: String, message: String) -> void:
	# Filtrar para procesar únicamente mensajes de nuestra zona de interés
	if topic != topic_zona:
		return
		
	# Instanciar el decodificador nativo de JSON en Godot
	var json = JSON.new()
	var error = json.parse(message)
	
	if error != OK:
		print("Error al decodificar el payload del sensor.")
		return
		
	var data = json.get_data()
	
	# Extracción de contaminantes generados por tu mqtt_sender.py
	var co2 = data.get("lectura_de_co2", 400.0)
	var nox = data.get("lectura_de_nox", 0.0)
	var pm25 = data.get("lectura_de_pm25", 0.0)
	
	# --- IMPLEMENTACIÓN DE LA LÓGICA MATEMÁTICA DEL ICA ---
	# 1. Normalización individual de rangos
	var co2_normalizado = (co2 - 400.0) / 800.0
	var nox_normalizado = nox / 150.0
	var pm25_normalizado = pm25 / 150.0
	
	# 2. Ponderación lineal compuesta (20% CO2, 30% NOx, 50% PM2.5)
	var indice = (0.2 * co2_normalizado) + (0.3 * nox_normalizado) + (0.5 * pm25_normalizado)
	indice = clamp(indice, 0.0, 1.0) # Restringir el índice entre el rango absoluto 0 y 1
	indice = snapped(indice, 0.01)   # Redondeo exacto a 2 decimales
	
	# Actualizar la interfaz física del nodo
	_actualizar_estado_visual(indice)

func _actualizar_estado_visual(indice: float) -> void:
	var estado: String
	var color_nodo: Color
	
	if indice >= 0.80:
		estado = "CRÍTICO"
		color_nodo = Color.DARK_RED
		
		# CONFIGURACIÓN PARA SMOG CRÍTICO
		particulas_smog.emitting = true
		particulas_smog.amount = 60 # Mucho más denso
		# Un color marrón/grisáceo tóxico desagradable
		particulas_smog.modulate = Color(0.4, 0.35, 0.25, 0.8) 
		
	elif indice >= 0.60:
		estado = "ALTO"
		color_nodo = Color.DARK_ORANGE
		
		# CONFIGURACIÓN PARA SMOG ALTO
		particulas_smog.emitting = true
		particulas_smog.amount = 25 # Contaminación ligera
		# Gris industrial tenue
		particulas_smog.modulate = Color(0.5, 0.5, 0.5, 0.5) 
		
	elif indice >= 0.40:
		estado = "MODERADO"
		color_nodo = Color.YELLOW
		particulas_smog.emitting = false # El aire aún es aceptable
	else:
		estado = "BAJO"
		color_nodo = Color.GREEN
		particulas_smog.emitting = false # Sin contaminación

	# Modificación del Label posicionado debajo de la antena en tu escena
	label_indice.text = "ICA: %s\nEstado: %s" % [str(indice), estado]
	
	# Modulación dinámica del Sprite2D
	sprite_antena.modulate = color_nodo
	print("[GODOT NOTIFY] Zona Actualizada -> ICA: ", indice, " | [", estado, "]")
