class_name CentrioloVisual #centriolo_visual.gd
extends Node2D


var posicao_alvo :Vector2
var velocidade :float = 100.0


func _ready() -> void:
	
	posicao_alvo = position


func configurar(posicao_inicial :Vector2) -> void:
	
	position = posicao_inicial
	posicao_alvo = posicao_inicial


func mover_para(
	nova_posicao :Vector2
) -> void:
	
	posicao_alvo = nova_posicao


func _process(delta :float) -> void:
	
	position = position.move_toward(
		posicao_alvo,
		velocidade * delta
	)


func _draw() -> void:
	
	draw_circle(
		Vector2.ZERO,
		12.0,
		Color("#dddddd")
	)
	
	draw_line(
		Vector2(-9, -5),
		Vector2(9, 5),
		Color("#555555"),
		5.0
	)
	
	draw_line(
		Vector2(-9, 5),
		Vector2(9, -5),
		Color("#555555"),
		5.0
	)
