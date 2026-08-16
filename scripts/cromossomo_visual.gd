extends Node2D

var cromossomo :Object

func _process(delta):
	if cromossomo == null:
		return
	
	position = position.lerp(
		cromossomo.posicao_alvo,
		delta * 3.0
	)

func configurar(crom):
	cromossomo = crom
	position = cromossomo.posicao
	queue_redraw()

func _draw():
	if cromossomo == null:
		return
	if cromossomo.a == null:
		return
	
	var altura_total :float = cromossomo.tamanho_visual
	var largura :float = cromossomo.largura_visual
	
	var quantidade_segmentos :int = cromossomo.a.segmentos.size()
	
	if quantidade_segmentos == 0:
		return
	
	var altura_segmento :float = altura_total / quantidade_segmentos
	
	var espacamento_cromatides := largura * 0.2
	
	# Cromatide A
	desenhar_cromatide(
		cromossomo.a,
		-largura * 0.5 - espacamento_cromatides,
		largura,
		altura_total,
		altura_segmento,
	)
	
	# Cromatide B (após duplicação)
	if cromossomo.duplicado and cromossomo.b != null:
		desenhar_cromatide(
			cromossomo.b,
			largura * 0.5 + espacamento_cromatides,
			largura,
			altura_total,
			altura_segmento,
		)
		desenhar_centromero(largura)

func desenhar_cromatide(
	cromatide,
	x_base :float,
	largura :float,
	altura_total :float,
	altura_segmento :float,
) -> void:
	for i in range(cromatide.segmentos.size()):
		var valor = cromatide.segmentos[i].alelo.valor
		var y = -altura_total * 0.5 + i * altura_segmento
		
		draw_rect(
			Rect2(
				x_base,
				y,
				largura,
				altura_segmento
			),
			obter_cor(valor)
		)
		
		draw_rect(
			Rect2(
				x_base,
				y,
				largura,
				altura_segmento
			),
			Color.BLACK,
			false,
			2
		)


func desenhar_centromero(
	largura :float,
) -> void:
	
	draw_line(
		Vector2(-largura * 0.5, 0),
		Vector2(largura * 1.5, 0),
		Color.BLACK,
		3
	)

func obter_cor(valor :int) -> Color:
	var cores = [
		Color("#ff5d5d"), #1
		Color("#ff4400"), #2
		Color("#dd773d"), #3
		Color("#ffe14d"), #4
		Color("#55dd66"), #5
		Color("#338822"), #6
		Color("#66ffff"),
		Color("#4d7dff"),
		Color("#bb66ff"),
		Color("#ff66bb"),
	]
	return cores[valor % cores.size()]
