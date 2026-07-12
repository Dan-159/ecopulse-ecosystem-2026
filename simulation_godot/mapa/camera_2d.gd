extends Camera2D

# Configuración de velocidad y límites de Zoom
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 3.0

# Variables internas para el arrastre (Pan)
var target_zoom: Vector2 = Vector2.ONE
var is_dragging: bool = false

func _ready() -> void:
	target_zoom = zoom
	# Asegurarse de que la cámara sea la actual al iniciar
	make_current()

func _unhandled_input(event: InputEvent) -> void:
	# --- LÓGICA DEL ARRASTRE (PANNING) ---
	# Detectar click derecho (puedes cambiarlo a MOUSE_BUTTON_MIDDLE si prefieres el click central)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
				
		# --- LÓGICA DEL ZOOM (RUEDA DEL MOUSE) ---
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_ajustar_target_zoom(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_ajustar_target_zoom(-zoom_speed)

	# Mover la cámara si se está arrastrando el mouse
	if event is InputEventMouseMotion and is_dragging:
		# Dividimos por el zoom actual para que el arrastre sea proporcional a la escala visual
		position -= event.relative / zoom.x

func _process(delta: float) -> void:
	# Interpolación lineal (Lerp) para que el movimiento del zoom sea suave
	zoom = zoom.lerp(target_zoom, 10.0 * delta)

func _ajustar_target_zoom(factor: float) -> void:
	# Calcular el nuevo zoom objetivo sumando el factor
	var nuevo_zoom_x = clamp(target_zoom.x + factor, min_zoom, max_zoom)
	var nuevo_zoom_y = clamp(target_zoom.y + factor, min_zoom, max_zoom)
	target_zoom = Vector2(nuevo_zoom_x, nuevo_zoom_y)
