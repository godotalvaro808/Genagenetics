extends Node2D
#================================================#
#=================== CONFIG =====================#
#================================================#
# Cada posição representa um cromossomo.
# Cada item dentro representa um segmento.
#
# Exemplo:
# Cromossomo 0:
#	Segmento 0 = Cor da Pele
#	Segmento 1 = Cor do Olho
#
# Cromossomo 1:
#	Segmento 0 = Forma do Corpo
#	Segmento 1 = Forma da Borda
#
# Caso o usuário crie mais cromossomos/segmentos do que os
# definidos aqui, serão gerados nomes genéricos.
@onready var area_2d: Area2D = $Celula/Area2D
var tiposAlelo :Array = [
	[
		"Cor da Pele",
		"Cor do Olho",
		"Cor da Listra",
		"Cor da Borda",
		"Cor do Cabelo",
		"Cor da Boca",
		"Cor do Segundo Olho",
		"Cor Secundária da Listra",
		"Cor da Mecha",
		"Cor Secundária da Borda"
	],
	[
		"Forma do Corpo",
		"Forma da Borda",
		"Forma da Listra",
		"Forma do Rosto",
		"Forma do Torso",
		"",
		"",
		"",
		"",
		""
	],
	[],
	[],
	[]]


#================================================#
#==================== ENUM ======================#
#================================================#
# Utilizado para controlar em qual etapa da meiose estamos.
enum FaseMeiose {
	INTERFASE,
	PROFASE_I,
	METAFASE_I,
	ANAFASE_I,
	TELOFASE_I,
	METAFASE_II,
	ANAFASE_II,
	TELOFASE_II,
	FINALIZADA}

#================================================#
#=================== CLASSES ====================#
#================================================#
#------------------Organizador-------------------#
class OrganizadorCelular:

	static func organizar_metafase_II(
		haploide :CelulaHaploide,
		centro :Vector2
	) -> Array[Vector2]:
		
		var posicoes :Array[Vector2] = []
		
		var quantidade := haploide.cromossomos.size()
		
		for i in range(quantidade):
			
			var y := lerpf(
				180.0,
				450.0,
				float(i) / max(quantidade - 1, 1)
			)
			
			posicoes.append(
				Vector2(
					centro.x,
					y
				)
			)
		return posicoes

#---------------------ALELO----------------------#
# Um alelo representa uma característica.
# Exemplo:
# tipo = "Cor da Pele"
# valor = 0
#-----------------------------------
# valor = 0 pode significar Vermelho
# valor = 1 pode significar Azul
# valor = 2 pode significar Verde
class Alelo:
	var tipo :String
	var valor :int

#--------------------SEGMENTO--------------------#
# Um segmento contém um alelo e sua adesividade.
# A adesividade será utilizada futuramente durante o
# crossing-over.
class Segmento:
	var alelo :Alelo
	var adesividade :float

#------------------CROMÁTIDE---------------------#
# Uma cromátide é uma sequência de segmentos, contendo
# as especificidades de um tipo de característica.
class Cromatide:
	var segmentos :Array[Segmento] = []

#------------------CROMOSSOMO--------------------#
# O cromossomo é a cromátide irmã, mas como ele 
# duplica o material para fazer meiose e mitose, 
# ele cria uma "linha" extra, agora contendo 2
# cópias do material (cromátides) mesmo sendo uma
# coisa só.
class Cromossomo:
	var a :Cromatide
	var b :Cromatide = null
	var origem :String
	var duplicado :bool = false
	
	#--------------------------------------------#
	# Duplicação da cromátide para a Interfase
	#--------------------------------------------#
	# Ao invés de fazer b = a, b é criado do início
	# para calcular o fator de mutação genética
	func duplicar() -> void:
		
		b = Cromatide.new()
		
		for segmento_original in a.segmentos:
			var novo_segmento = Segmento.new()
			var novo_alelo = Alelo.new()
			
			novo_alelo.tipo = segmento_original.alelo.tipo
			novo_alelo.valor = segmento_original.alelo.valor
			
			novo_segmento.alelo = novo_alelo
			novo_segmento.adesividade = segmento_original.adesividade
			
			b.segmentos.append(novo_segmento)
		duplicado = true


#------------------PAR HOMÓLOGO------------------#
# Representa um par de cromossomos com a mesma
# distribuição de mateiral genético. No caso
# deste joguinho, cromossomos com alelos de
# mesma classe.
class ParHomologo:
	var materno :Cromossomo
	var paterno :Cromossomo
	
	#--------------------------------------------#
	# Crossing-over
	#
	# Atualmente faz uma troca simples.
	# Depois poderá utilizar adesividade, mutação.
	#--------------------------------------------#
	
	func crossOver() -> void:
		if materno == null:
			return
		if paterno == null:
			return
		
		var tamanho := materno.a.segmentos.size()
		var minimo := ceili(tamanho / 10.0)
		var maximo := ceili(tamanho / 1.25)
		var quantidade_trocas := randi_range(minimo, maximo)
		var pontos_usados :Array[int] = []
		
		var mesmo :bool = (randi_range(0, 1) == 1)
		while pontos_usados.size() < quantidade_trocas:
			var p := randi_range(0, tamanho - 1)
			if p in pontos_usados:
				continue
			
			pontos_usados.append(p)
			var temp := materno.a.segmentos[p]
			if(mesmo):
				materno.a.segmentos[p] = paterno.a.segmentos[p]
				paterno.a.segmentos[p] = temp
			else:
				materno.a.segmentos[p] = paterno.b.segmentos[p]
				paterno.b.segmentos[p] = temp
			
		
		
		quantidade_trocas = randi_range(minimo, maximo)
		pontos_usados = []
		
		while pontos_usados.size() < quantidade_trocas:
			var p = randi_range(0, tamanho - 1)
			if p in pontos_usados:
				continue
			
			pontos_usados.append(p)
			var temp = materno.b.segmentos[p]
			if(mesmo):
				materno.b.segmentos[p] = paterno.b.segmentos[p]
				paterno.b.segmentos[p] = temp
			else:
				materno.b.segmentos[p] = paterno.a.segmentos[p]
				paterno.a.segmentos[p] = temp

#---------------------CÉLULA---------------------#
# Representa uma célula completa, participante
# da meiose 1.
class Celula:
	var pares_homologos :Array[ParHomologo] = []

#---------------------CÉLULA---------------------#
# Representa uma célula completa, participante
# da meiose 1.
class CelulaHaploide:
	var cromossomos :Array[Cromossomo] = []
	
#---------------------GAMETA---------------------#
# Célula haplóide com metade do material
# genético, utilizado na formação de
# um zigoto.
class Gameta:
	var cromossomos :Array[Cromossomo] = []

#================================================#
#=================== VARIÁVEIS ==================#
#================================================#
var faseAtual :FaseMeiose
var celula :Celula
var haploideA :CelulaHaploide
var haploideB :CelulaHaploide
var gametas :Array[Gameta] = []
var informacoes :Dictionary
var visuais :Dictionary = {}
var cenaCromossomoVisual = preload(
	"res://cenas/cromossomo_visual.tscn"
)

#================================================#
#=================== INICIAR ====================#
#================================================#
# Recebe os dados enviados pelo painel.
func iniciar(inf :Dictionary) -> void:
	
	limpar_visuais()
	
	informacoes = inf
	faseAtual = FaseMeiose.INTERFASE
	celula = Celula.new()
	
	criar_pares_homologos()
	criar_visuais()
	
	print("--------------------------------")
	print("-------SIMULAÇÃO INICIADA-------")
	print("--------------------------------")
	
	imprimir_genoma()

#================================================#
#=========== CRIAÇÃO DOS CROMOSSOMOS ============#
#================================================#
# Formará a célula que será utilizada na meiose
func criar_pares_homologos() -> void:
	for indiceCrom in range(informacoes["crom"]):
		var par = ParHomologo.new()
		
		par.materno = criar_cromossomo(
			indiceCrom,
			"materna",
			informacoes["seg"],
			informacoes["ades"],
			informacoes["alelos1"][indiceCrom]
		)
		
		par.paterno = criar_cromossomo(
			indiceCrom,
			"paterna",
			informacoes["seg"],
			informacoes["ades"],
			informacoes["alelos2"][indiceCrom]
		)
		
		celula.pares_homologos.append(par)
func criar_cromossomo(
	indiceCrom :int,
	origem :String,
	quantidadeSegmentos :int,
	adesividade :float,
	valoresAlelos :Array
) -> Cromossomo:
	var crom = Cromossomo.new()
	crom.a = Cromatide.new()
	
	for indiceSeg in range(quantidadeSegmentos):
		var alelo = Alelo.new()
		
		if indiceCrom < tiposAlelo.size():
			if indiceSeg < tiposAlelo[indiceCrom].size():
				alelo.tipo = tiposAlelo[indiceCrom][indiceSeg]
				
			else:
				
				alelo.tipo = "Característica " + str(indiceSeg)
				
		else:
			
			alelo.tipo = "Característica " + str(indiceSeg)
			
		alelo.valor = valoresAlelos[indiceSeg]
		
		var segmento = Segmento.new()
		
		segmento.alelo = alelo
		segmento.adesividade = adesividade
		
		crom.a.segmentos.append(segmento)
		crom.origem = origem
		
	return crom
func criar_cromossomo_simples(
	crom_original :Cromossomo,
	utilizar_cromatide_a :bool
) -> Cromossomo:
	
	var novo_crom := Cromossomo.new()
	
	novo_crom.a = Cromatide.new()
	novo_crom.origem = crom_original.origem
	
	var origem_croma :Cromatide
	
	if utilizar_cromatide_a:
		origem_croma = crom_original.a
	else:
		origem_croma = crom_original.b
	
	if origem_croma == null:
		return novo_crom
	
	for seg_original in origem_croma.segmentos:
		
		var novo_alelo := Alelo.new()
		
		novo_alelo.tipo = seg_original.alelo.tipo
		novo_alelo.valor = seg_original.alelo.valor
		
		var novo_segmento := Segmento.new()
		
		novo_segmento.alelo = novo_alelo
		novo_segmento.adesividade = seg_original.adesividade
		
		novo_crom.a.segmentos.append(
			novo_segmento
		)
		
	return novo_crom

#================================================#
#=================== MEIOSE =====================#
#================================================#

func avancar_fase() -> void:
	# Avança uma etapa da meiose.
	# Chama essa função quando apertar
	# o botão  "Próxima Etapa".
	print(faseAtual)
	match faseAtual:
		
		FaseMeiose.INTERFASE:
			executar_interfase()
			
		FaseMeiose.PROFASE_I:
			executar_profase_I()
			
		FaseMeiose.METAFASE_I:
			executar_metafase_I()
			
		FaseMeiose.ANAFASE_I:
			executar_anafase_I()
			
		FaseMeiose.TELOFASE_I:
			executar_telofase_I()
			
		FaseMeiose.METAFASE_II:
			executar_metafase_II()
			
		FaseMeiose.ANAFASE_II:
			executar_anafase_II()
			
		FaseMeiose.TELOFASE_II:
			executar_telofase_II()
			
		FaseMeiose.FINALIZADA:
			print("Meiose já concluída")


#================================================#
#================= INTERFASE ====================#
#================================================#
# Duplica todos os cromossomos.

func executar_interfase() -> void:
	
	print("INTERFASE")
	
	for par in celula.pares_homologos:
		
		par.materno.duplicar()
		par.paterno.duplicar()
	
	atualizar_desenhos()
	
	var centro := obter_centro_celula()
	var raio := obter_raio_celula()
	
	for par in celula.pares_homologos:
		
		var visual_materno :CromossomoVisual = (
			visuais[par.materno]
		)
		
		var visual_paterno :CromossomoVisual = (
			visuais[par.paterno]
		)
		
		visual_materno.iniciar_flutuacao(
			centro,
			raio
		)
		
		visual_paterno.iniciar_flutuacao(
			centro,
			raio
		)
		
	faseAtual = FaseMeiose.PROFASE_I

#================================================#
#================= PRÓFASE I ====================#
#================================================#
func executar_profase_I() -> void:
	
	var centro := obter_centro_celula()
	
	var quantidade := celula.pares_homologos.size() * 2
	
	var espacamento := 0.0
	
	if quantidade > 1:
		espacamento = 300.0 / float(quantidade - 1)
	
	var indice := 0
	
	for par in celula.pares_homologos:
		
		var visual_materno :CromossomoVisual = visuais[par.materno]
		var visual_paterno :CromossomoVisual = visuais[par.paterno]
		
		var destino_materno := Vector2(
			centro.x,
			centro.y - 150.0 + espacamento * indice
		)
		
		indice += 1
		
		var destino_paterno := Vector2(
			centro.x,
			centro.y - 150.0 + espacamento * indice
		)
		
		indice += 1
		
		visual_materno.mover_para(
			destino_materno
		)
		
		visual_paterno.mover_para(
			destino_paterno
		)
		
	faseAtual = FaseMeiose.METAFASE_I

#================================================#
#================ METÁFASE I ====================#
#================================================#
# Não altera genética.
# Futuramente apenas animação.
func executar_metafase_I() -> void:
	
	print("METAFASE I")
	
	var quantidade := celula.pares_homologos.size()
	
	for i in range(quantidade):
		
		var par := celula.pares_homologos[i]
		
		var y := 150.0 + i * 80.0
		
		mover_cromossomo(
			par.materno,
			Vector2(
				300.0,
				y
			)
		)
		
		mover_cromossomo(
			par.paterno,
			Vector2(
				400.0,
				y
			)
		)
		
	faseAtual = FaseMeiose.ANAFASE_I

#================================================#
#================= ANÁFASE I ====================#
#================================================
# Separação dos cromossomos homólogos.

func executar_anafase_I() -> void:
	
	print("ANAFASE I")
	
	haploideA = CelulaHaploide.new()
	haploideB = CelulaHaploide.new()
	
	for par in celula.pares_homologos:
		
		var lado := randi_range(0, 1)
		
		if lado == 0:
			
			haploideA.cromossomos.append(
				par.materno
			)
			
			haploideB.cromossomos.append(
				par.paterno
			)
		else:
			
			haploideA.cromossomos.append(
				par.paterno
			)
			
			haploideB.cromossomos.append(
				par.materno
			)
	
	organizar_haploide_visual(
		haploideA,
		Vector2(180, 315)
	)
	
	organizar_haploide_visual(
		haploideB,
		Vector2(510, 315)
	)
	
	faseAtual = FaseMeiose.TELOFASE_I

func organizar_haploide_visual(
	haploide :CelulaHaploide,
	centro :Vector2
) -> void:
	
	var quantidade := haploide.cromossomos.size()
	
	for i in range(quantidade):
		
		var cromossomo := haploide.cromossomos[i]
		
		var y := lerpf(
			200.0,
			430.0,
			float(i) / max(quantidade - 1, 1)
		)
		
		mover_cromossomo(
			cromossomo,
			Vector2(
				centro.x,
				y
			)
		)

#================================================#
#================ TELOFASE I ====================#
#================================================#
# Futuramente:
#
# Formação de duas células.

func executar_telofase_I() -> void:
	
	print("TELOFASE I")
	
	organizar_haploide_visual(
		haploideA,
		Vector2(160, 315)
	)
	
	organizar_haploide_visual(
		haploideB,
		Vector2(530, 315)
	)
	
	faseAtual = FaseMeiose.METAFASE_II

#================================================#
#================ METÁFASE II ===================#
#================================================#

func executar_metafase_II() -> void:
	
	print("METAFASE II")
	
	var posicoes_a :Array = OrganizadorCelular.organizar_metafase_II(
		haploideA,
		Vector2(180, 315)
	)
	
	var posicoes_b :Array = OrganizadorCelular.organizar_metafase_II(
		haploideB,
		Vector2(510, 315)
	)
	
	for i in range(haploideA.cromossomos.size()):
		
		var cromossomo := haploideA.cromossomos[i]
		
		mover_cromossomo(
			cromossomo,
			posicoes_a[i]
		)
	
	
	for i in range(haploideB.cromossomos.size()):
		
		var cromossomo := haploideB.cromossomos[i]
		
		mover_cromossomo(
			cromossomo,
			posicoes_b[i]
		)
		
	faseAtual = FaseMeiose.ANAFASE_II

#================================================#
#================= ANÁFASE II ===================#
#================================================#
# Futuramente:
#
# Separação das cromátides irmãs.

func executar_anafase_II() -> void:
	
	print("ANÁFASE II")
	
	gametas.clear()
	
	for i in range(4):
		
		gametas.append(
			Gameta.new()
		)
		
	for visual in visuais.values():
		
		if visual != null:
			visual.visible = false
			
	criar_cromossomos_gametas(
		haploideA,
		0,
		1
	)
	
	criar_cromossomos_gametas(
		haploideB,
		2,
		3
	)
	
	faseAtual = FaseMeiose.TELOFASE_II

func criar_cromossomos_gametas(
	haploide :CelulaHaploide,
	indiceGametaA :int,
	indiceGametaB :int
) -> void:
	
	for cromossomo in haploide.cromossomos:
		
		var utilizar_a :bool = randi_range(0, 1) == 0
		
		var cromossomo_a := criar_cromossomo_simples(
			cromossomo,
			utilizar_a
		)
		
		var cromossomo_b := criar_cromossomo_simples(
			cromossomo,
			not utilizar_a
		)
		
		gametas[indiceGametaA].cromossomos.append(
			cromossomo_a
		)
		
		gametas[indiceGametaB].cromossomos.append(
			cromossomo_b
		)
		
		criar_visual_cromossomo(
			cromossomo_a,
			largura_visual_padrao(),
			altura_visual_padrao(),
			obter_centro_celula()
		)
		
		criar_visual_cromossomo(
			cromossomo_b,
			largura_visual_padrao(),
			altura_visual_padrao(),
			obter_centro_celula()
		)

#================================================#
#================ TELOFASE II ===================#
#================================================#
# Futuramente:
#
# Formação dos quatro gametas.

func executar_telofase_II() -> void:
	
	print("TELOFASE II")
	
	organizar_gameta_visual(
		gametas[0],
		Vector2(160, 180)
	)
	
	organizar_gameta_visual(
		gametas[1],
		Vector2(490, 180)
	)
	
	organizar_gameta_visual(
		gametas[2],
		Vector2(160, 450)
	)
	
	organizar_gameta_visual(
		gametas[3],
		Vector2(490, 450)
	)
	
	faseAtual = FaseMeiose.FINALIZADA

func organizar_gameta_visual(
	gameta :Gameta,
	centro :Vector2
) -> void:
	var quantidade := gameta.cromossomos.size()
	
	for i in range(quantidade):
		
		var cromossomo := gameta.cromossomos[i]
		
		var offset_y := (
			float(i)
			- float(quantidade - 1) * 0.5
		) * 45.0
		
		mover_cromossomo(
			cromossomo,
			centro + Vector2(0, offset_y)
		)
		
		visuais[cromossomo].visible = true

#================================================#
#================== DEBUG =======================#
#================================================#
# Exibe o genoma atual no console.

func imprimir_genoma() -> void:
	print("")
	print("===== GENOMA =====")
	
	for i in range(celula.pares_homologos.size()):
		var par = celula.pares_homologos[i]
		
		print("")
		print("PAR ", i)
		print("MATERNO")
		
		for segmento in par.materno.a.segmentos:
			print(segmento.alelo.tipo, " -> ", segmento.alelo.valor)
			
		print("PATERNO")
		
		for segmento in par.paterno.a.segmentos:
			
			print(segmento.alelo.tipo, " -> ", segmento.alelo.valor)
			
	print("==================")
	print("")


#================================================#
#================== VISUAL ======================#
#================================================#
func criar_visuais() -> void:
	
	var quantidade_cromossomos :int = informacoes["crom"]
	
	var altura :float = (
		350.0
		/ max(quantidade_cromossomos, 1)
	)
	
	var largura :float = ( 60.0 / max(quantidade_cromossomos, 1) * 1.25 )
	
	var centro := obter_centro_celula()
	var raio := obter_raio_celula()
	
	for par in celula.pares_homologos:
		
		var visual_materno := criar_visual_cromossomo(
			par.materno,
			largura,
			altura,
			centro
		)
		
		var visual_paterno := criar_visual_cromossomo(
			par.paterno,
			largura,
			altura,
			centro
		)
		
		visual_materno.iniciar_flutuacao(
			centro,
			raio
		)
		
		visual_paterno.iniciar_flutuacao(
			centro,
			raio
		)

func criar_visual_cromossomo(
	cromossomo :Cromossomo,
	largura :float,
	altura :float,
	posicao_inicial :Vector2
) -> CromossomoVisual:
	var visual :CromossomoVisual = (
		cenaCromossomoVisual.instantiate()
	)
	
	add_child(visual)
	
	visual.configurar(
		cromossomo,
		largura,
		altura,
		posicao_inicial
	)
	
	visuais[cromossomo] = visual
	
	return visual
func largura_visual_padrao() -> float:
	return 60.0 / max(informacoes["crom"], 1) * 1.25
func altura_visual_padrao() -> float:
	return 350.0 / max(informacoes["crom"], 1)
func obter_centro_celula() -> Vector2:
	return to_local(
		area_2d.global_position
	)
func obter_raio_celula() -> float:
	var forma := (
		$Celula/Area2D/CollisionShape2D.shape
		as CircleShape2D
	)
	if forma == null:
		return 0.0
	return forma.radius

func mover_cromossomo(
	cromossomo :Cromossomo,
	posicao :Vector2
) -> void:
	
	if not visuais.has(cromossomo):
		return
	
	var visual :CromossomoVisual = visuais[cromossomo]
	
	visual.mover_para(posicao)
func atualizar_desenhos() -> void:
	
	for visual in visuais.values():
		if visual == null:
			continue
		
		visual.atualizar_desenho()
func esconder_visual(
	cromossomo :Cromossomo
) -> void:
	
	if not visuais.has(cromossomo):
		return
		
	var visual :CromossomoVisual = visuais[cromossomo]
	
	visual.visible = false
func limpar_visuais() -> void:
	
	for visual in visuais.values():
		
		if visual != null:
			visual.queue_free()
	
	visuais.clear()
