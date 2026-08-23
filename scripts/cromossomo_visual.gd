class_name CromossomoVisual
extends Node2D


var cromossomo :Object

var largura_visual :float = 40.0
var altura_visual :float = 100.0

var centro_flutuacao :Vector2
var raio_flutuacao :float

var posicao_alvo :Vector2

var flutuando :bool = false

var velocidade_movimento :float = 80.0
var velocidade_flutuacao :float = 25.0

var tempo_novo_destino :float = 0.0
var intervalo_novo_destino :float = 2.0


func configurar(
	novo_cromossomo :Object,
	nova_largura :float,
	nova_altura :float,
	posicao_inicial :Vector2
) -> void:
	
	cromossomo = novo_cromossomo
	
	largura_visual = nova_largura
	altura_visual = nova_altura
	
	position = posicao_inicial
	posicao_alvo = posicao_inicial
	
	queue_redraw()


func iniciar_flutuacao(
	centro :Vector2,
	raio :float
) -> void:
	
	centro_flutuacao = centro
	raio_flutuacao = raio
	
	flutuando = true
	
	# Define a posição inicial aleatoriamente.
	position = obter_posicao_aleatoria(
		centro_flutuacao,
		raio_flutuacao
	)
	
	# Depois escolhe o primeiro destino.
	escolher_novo_destino()


func escolher_novo_destino() -> void:
	
	posicao_alvo = obter_posicao_aleatoria(
		centro_flutuacao,
		raio_flutuacao
	)
	
	# Cada cromossomo recebe um intervalo ligeiramente diferente.
	# Isso evita que todos mudem de direção ao mesmo tempo.
	tempo_novo_destino = randf_range(
		1.5,
		3.0
	)


func obter_posicao_aleatoria(
	centro :Vector2,
	raio :float
) -> Vector2:
	
	# O cromossomo possui tamanho próprio.
	# Portanto, não podemos permitir que seu centro chegue
	# até a borda da célula.
	
	var espacamento_cromatides := largura_visual * 0.2
	
	var margem_x := (
		largura_visual
		+ espacamento_cromatides * 0.5
	)
	
	var margem_y := (
		altura_visual * 0.5
	)
	
	var margem :float = max(
		margem_x,
		margem_y
	)
	
	var raio_disponivel :float = raio - margem
	
	if raio_disponivel <= 0.0:
		return centro
	
	# sqrt(randf()) distribui os pontos uniformemente
	# pela área do círculo, em vez de concentrá-los
	# excessivamente no centro.
	
	var angulo := randf() * TAU
	
	var distancia := (
		sqrt(randf())
		* raio_disponivel
	)
	
	return (
		centro
		+ Vector2.from_angle(angulo) * distancia
	)


func mover_para(
	nova_posicao :Vector2
) -> void:
	
	flutuando = false
	
	posicao_alvo = nova_posicao


func _process(delta :float) -> void:
	
	if flutuando:
		
		tempo_novo_destino -= delta
		
		if tempo_novo_destino <= 0.0:
			
			escolher_novo_destino()
			
		var velocidade := velocidade_flutuacao
		
		position = position.move_toward(
			posicao_alvo,
			velocidade * delta
		)
		
	else:
		
		position = position.move_toward(
			posicao_alvo,
			velocidade_movimento * delta
		)

func _draw() -> void:
	
	if cromossomo == null:
		return
	
	var metade_largura := largura_visual / 2.0
	var metade_altura := altura_visual / 2.0
	
	var distancia := metade_largura * 0.5
	
	var segmentos_a = cromossomo.a.segmentos
	
	var possui_b :bool = cromossomo.b != null
	var segmentos_b = null
	
	if possui_b:
		segmentos_b = cromossomo.b.segmentos
	
	var quantidade_segmentos :int = segmentos_a.size()
	
	if quantidade_segmentos == 0:
		return
	
	var altura_segmento := altura_visual / float(quantidade_segmentos)
	
	for i in range(quantidade_segmentos):
		
		var y_inicial := -metade_altura + altura_segmento * i
		var y_final := y_inicial + altura_segmento
		
		# Segmento → alelo → valor
		var alelo_a :int = segmentos_a[i].alelo.valor
		var cor_a :Color = cores[alelo_a]
		
		# Desenha a cromátide A.
		draw_line(
			Vector2(-distancia, y_inicial),
			Vector2(-distancia, y_final),
			cor_a,
			4.0
		)
		
		if possui_b:
			
			# Segmento → alelo → valor
			var alelo_b :int = segmentos_b[i].alelo.valor
			var cor_b :Color = cores[alelo_b]
			
			# Desenha a cromátide B.
			draw_line(
				Vector2(distancia, y_inicial),
				Vector2(distancia, y_final),
				cor_b,
				4.0
			)
			
			# Conecta as duas cromátides.
			draw_line(
				Vector2(-distancia, y_inicial),
				Vector2(distancia, y_inicial),
				cor_a.lerp(cor_b, 0.5),
				2.0
			)
	
	# A linha final que fecha a última extremidade
	# só existe quando o cromossomo possui duas cromátides.
	if possui_b:
		
		var ultimo_a :int = (
			segmentos_a[quantidade_segmentos - 1].alelo.valor
		)
		
		var ultimo_b :int = (
			segmentos_b[quantidade_segmentos - 1].alelo.valor
		)
		
		draw_line(
			Vector2(-distancia, metade_altura),
			Vector2(distancia, metade_altura),
			cores[ultimo_a].lerp(
				cores[ultimo_b],
				0.5
			),
			2.0
		)

func atualizar_desenho() -> void:
	queue_redraw()

var cores := {
	0: Color.from_rgba8(255, 50, 50, 255),
	1: Color.from_rgba8(255, 90, 60, 255),
	2: Color.from_rgba8(255, 255, 100, 255),
	3: Color.from_rgba8(170, 255, 100, 255),
	4: Color.from_rgba8(90, 190, 100, 255),
	5: Color.from_rgba8(40, 200, 150, 255),
	6: Color.from_rgba8(20, 150, 200, 255),
	7: Color.from_rgba8(20, 80, 200, 255),
	8: Color.from_rgba8(80, 40, 190, 255),
	9: Color.from_rgba8(150, 20, 150, 255)
}
