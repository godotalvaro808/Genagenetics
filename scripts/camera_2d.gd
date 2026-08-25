extends Camera2D

@export var velocidade_teclado :float = 400.0
@export var permitir_arraste_mouse :bool = true
@export var botao_arraste :MouseButton = MOUSE_BUTTON_MIDDLE

@export var permitir_zoom :bool = true
@export var zoom_min :float = 0.5
@export var zoom_max :float = 2.0
@export var passo_zoom :float = 0.1

var arrastando :bool = false
var posicao_mouse_anterior :Vector2


func _unhandled_input(event :InputEvent) -> void:
	
	if permitir_arraste_mouse and event is InputEventMouseButton:
		
		if event.button_index == botao_arraste:
			arrastando = event.pressed
			posicao_mouse_anterior = event.position
		
		if permitir_zoom:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				aplicar_zoom(-passo_zoom)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				aplicar_zoom(passo_zoom)
	
	if permitir_arraste_mouse and event is InputEventMouseMotion and arrastando:
		
		var delta_mouse :Vector2 = event.position - posicao_mouse_anterior
		posicao_mouse_anterior = event.position
		
		# Divide pelo zoom para o arraste acompanhar o mouse
		# corretamente mesmo quando a câmera está com zoom aplicado.
		position -= delta_mouse / zoom


func _process(delta :float) -> void:
	
	var direcao := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direcao.x += 1.0
	if Input.is_action_pressed("ui_left"):
		direcao.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		direcao.y += 1.0
	if Input.is_action_pressed("ui_up"):
		direcao.y -= 1.0
	
	if direcao != Vector2.ZERO:
		position += direcao.normalized() * velocidade_teclado * delta


func aplicar_zoom(quantidade :float) -> void:
	
	var novo_zoom :float = clampf(
		zoom.x + quantidade,
		zoom_min,
		zoom_max
	)
	
	zoom = Vector2(novo_zoom, novo_zoom)
