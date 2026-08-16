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
	func ponto_aleatorio_circulo(center: Vector2, radius: float) -> Vector2:
		var angle = randf() * TAU #TAU = PI * 2 -> unidade de radianos para círculo
		var distance = sqrt(randf()) * radius
		
		return center + Vector2.from_angle(angle) * distance

	static func organizar_interfase(celula: Celula):
		var pares = celula.pares_homologos
		var count = pares.size()
		
		const TOP = 20.0
		const BOTTOM = 535.0
		const IDEAL_SPACING = 50.0
		
		var center = (TOP + BOTTOM) / 2.0
		var spacing = IDEAL_SPACING
		
		if count > 1:
			spacing = min(
				IDEAL_SPACING,
				(BOTTOM - TOP) / float(count - 1)
			)
		
		var total_height = (count - 1) * spacing
		var first_y = center - total_height / 2.0
		
		for i in count:
			var y = first_y + i * spacing
			pares[i].materno.posicao_alvo = Vector2(420, y)
			pares[i].paterno.posicao_alvo = Vector2(
				420 + pares[i].materno.largura_visual * 3,
				y
			)

	static func organizar_profase(celula: Celula):
		var pares = celula.pares_homologos
		var count = pares.size()
		
		const TOP := 10.0
		const BOTTOM := 535.0
		const IDEAL_SPACING := 250.0
		
		var center = 313
		var spacing = IDEAL_SPACING
		
		if count > 1:
			spacing = min(
				IDEAL_SPACING,
				center / float(count - 1)
			)
		
		var total_height = (count - 1) * spacing
		var first_y = center - total_height / 2.0
		
		for i in count:
			var y = first_y + i * spacing
			pares[i].materno.posicao_alvo = Vector2(420, y)
			pares[i].paterno.posicao_alvo = Vector2(
				420 + pares[i].materno.largura_visual * 3,
				y
			)

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
	#---------- genético ----------#
	var a :Cromatide
	var b :Cromatide = null
	var origem :String
	#----------- visual -----------#
	var visual :Node2D
	var posicao :Vector2
	var posicao_alvo : Vector2
	var tamanho_visual :float
	var largura_visual :float
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
		
		while pontos_usados.size() < quantidade_trocas:
			var p := randi_range(0, tamanho - 1)
			if p in pontos_usados:
				continue
			
			pontos_usados.append(p)
			var temp := materno.a.segmentos[p]
			materno.a.segmentos[p] = paterno.a.segmentos[p]
			paterno.a.segmentos[p] = temp
		
		
		quantidade_trocas = randi_range(minimo, maximo)
		pontos_usados = []
		
		while pontos_usados.size() < quantidade_trocas:
			var p = randi_range(0, tamanho - 1)
			if p in pontos_usados:
				continue
			
			pontos_usados.append(p)
			var temp = materno.b.segmentos[p]
			materno.b.segmentos[p] = paterno.b.segmentos[p]
			paterno.b.segmentos[p] = temp

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
var gametas :Array[Gameta]
var informacoes :Dictionary
var organizador :OrganizadorCelular = OrganizadorCelular.new()

#================================================#
#=================== INICIAR ====================#
#================================================#
# Recebe os dados enviados pelo painel.
func iniciar(inf :Dictionary) -> void:
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
		var altura :float = randf_range(200, 300)
		var largura :float = randf_range(20, 60)
		
		par.materno = criar_cromossomo(
			indiceCrom,
			"materna",
			informacoes["seg"],
			informacoes["ades"],
			informacoes["alelos1"][indiceCrom]
		)
		par.materno.visual = cenaCromossomoVisual.instantiate()
		par.materno.largura_visual = largura / informacoes["crom"] * 1.25
		par.materno.tamanho_visual = altura / informacoes["crom"]
		
		par.paterno = criar_cromossomo(
			indiceCrom,
			"paterna",
			informacoes["seg"],
			informacoes["ades"],
			informacoes["alelos2"][indiceCrom]
		)
		par.paterno.largura_visual = largura / informacoes["crom"] * 1.25
		par.paterno.tamanho_visual = altura / informacoes["crom"]
		par.paterno.visual = cenaCromossomoVisual.instantiate()
		
		celula.pares_homologos.append(par)
	for par in celula.pares_homologos:
		
		par.materno.posicao_alvo = Vector2(
			organizador.ponto_aleatorio_circulo(Vector2(335, 313), 50.0 + 75.0 * pow(informacoes["crom"], 0.35) )
		)
		par.paterno.posicao_alvo= Vector2(
			organizador.ponto_aleatorio_circulo(Vector2(335, 313), 50.0 + 75.0 * pow(informacoes["crom"], 0.35) )
		)

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
	var novo_crom = Cromossomo.new()
	novo_crom.a = Cromatide.new()
	var origem_croma :Cromatide
	
	if utilizar_cromatide_a:
		origem_croma = crom_original.a
	else:
		origem_croma = crom_original.b
	for seg_original in origem_croma.segmentos:
		
		var novo_alelo = Alelo.new()
		novo_alelo.tipo = seg_original.alelo.tipo
		novo_alelo.valor = seg_original.alelo.valor
		
		var novo_segmento = Segmento.new()
		novo_segmento.alelo = novo_alelo
		novo_segmento.adesividade = seg_original.adesividade
		
		novo_crom.a.segmentos.append(novo_segmento)
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
	
	var y :float = 100
	
	for par in celula.pares_homologos:
		par.materno.duplicar()
		par.materno.duplicado = true
		par.paterno.duplicar()
		par.paterno.duplicado = true
		par.materno.posicao_alvo = Vector2(450, y)
		par.paterno.posicao_alvo = Vector2(550, y)
		y += 120
	organizador.organizar_interfase(celula)
	atualizar_visuais()
	faseAtual = FaseMeiose.PROFASE_I

#================================================#
#================= PRÓFASE I ====================#
#================================================#
# Apenas o crossing-over altera a genética.
#
# Pareamento visual NÃO é feito aqui.
func executar_profase_I() -> void:
	print("PROFASE I")
	
	for par in celula.pares_homologos:
		par.crossOver()
	
	organizador.organizar_profase(celula)
	atualizar_visuais()
	
	faseAtual = FaseMeiose.METAFASE_I

#================================================#
#================ METÁFASE I ====================#
#================================================#
# Não altera genética.
# Futuramente apenas animação.
func executar_metafase_I() -> void:
	print("METÁFASE I")
	atualizar_visuais()
	
	faseAtual = FaseMeiose.ANAFASE_I

#================================================#
#================= ANÁFASE I ====================#
#================================================
# Separação dos cromossomos homólogos.

func executar_anafase_I() -> void:
	print("ANÁFASE I")
	haploideA = CelulaHaploide.new()
	haploideB = CelulaHaploide.new()
	
	for par in celula.pares_homologos:
		var a :int = randi_range(0, 1)
		
		if a == 0:
			haploideA.cromossomos.append(par.materno)
			haploideB.cromossomos.append(par.paterno)
		else:
			haploideA.cromossomos.append(par.paterno)
			haploideB.cromossomos.append(par.materno)
	
	var i :int = 0
	print("Haploide A")
	for crom in haploideA.cromossomos:
		print("Cromossomo " + str(i))
		print("Cromátide A")
		for seg in crom.a.segmentos:
			print(str(seg.alelo.tipo) + ": " + str(seg.alelo.valor))
		print("Cromátide B")
		for seg in crom.b.segmentos:
			print(str(seg.alelo.tipo) + ": " + str(seg.alelo.valor))
		i += 1
	i = 0
	print("Haploide B")
	for crom in haploideB.cromossomos:
		print("Cromossomo " + str(i))
		print("Cromátide A")
		for seg in crom.a.segmentos:
			print(str(seg.alelo.tipo) + ": " + str(seg.alelo.valor))
		print("Cromátide B")
		for seg in crom.b.segmentos:
			print(str(seg.alelo.tipo) + ": " + str(seg.alelo.valor))
		i += 1
	atualizar_visuais()
	
	faseAtual = FaseMeiose.TELOFASE_I

#================================================#
#================ TELOFASE I ====================#
#================================================#
# Futuramente:
#
# Formação de duas células.

func executar_telofase_I() -> void:
	print("TELOFASE I")
	atualizar_visuais()
	faseAtual = FaseMeiose.METAFASE_II

#================================================#
#================ METÁFASE II ===================#
#================================================#

func executar_metafase_II() -> void:
	print("METÁFASE II")
	atualizar_visuais()
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
	for a in range(4):
		var gameta = Gameta.new()
		gametas.append(gameta)
		
	var a :bool
	var i :int = 0
	for crom in haploideA.cromossomos:
		a = randi_range(0, 1)
		gametas[0].cromossomos.append(
			criar_cromossomo_simples(crom, a)
		)
		var g0 :String = ""
		for j in range(gametas[0].cromossomos[i].a.segmentos.size()):
			g0 += " " + str(gametas[0].cromossomos[i].a.segmentos[j].alelo.valor)
		print("gameta 0:" + g0)
		gametas[1].cromossomos.append(
			criar_cromossomo_simples(crom, !a)
		)
		var g1 :String = ""
		for j in range(gametas[1].cromossomos[i].a.segmentos.size()):
			g1 += " " + str(gametas[1].cromossomos[i].a.segmentos[j].alelo.valor)
		print("gameta 1:" + g1)
		i += 1
	i = 0
	for crom in haploideB.cromossomos:
		a = randi_range(0, 1)
		gametas[2].cromossomos.append(
			criar_cromossomo_simples(crom, a)
		)
		var g2 :String = ""
		for j in range(gametas[2].cromossomos[i].a.segmentos.size()):
			g2 += " " + str(gametas[2].cromossomos[i].a.segmentos[j].alelo.valor)
		print("gameta 2:" + g2)
		gametas[3].cromossomos.append(
			criar_cromossomo_simples(crom, !a)
		)
		var g3 :String = ""
		for j in range(gametas[3].cromossomos[i].a.segmentos.size()):
			g3 += " " + str(gametas[3].cromossomos[i].a.segmentos[j].alelo.valor)
		print("gameta 3:" + g3)
		i += 1
	atualizar_visuais()
	
	faseAtual = FaseMeiose.TELOFASE_II

#================================================#
#================ TELOFASE II ===================#
#================================================#
# Futuramente:
#
# Formação dos quatro gametas.

func executar_telofase_II() -> void:
	print("TELOFASE II")
	atualizar_visuais()
	faseAtual = FaseMeiose.FINALIZADA

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
var cenaCromossomoVisual = preload(
	"res://cenas/cromossomo_visual.tscn"
)
func criar_visuais() -> void:
	
	for par in celula.pares_homologos:
		
		par.materno.visual = cenaCromossomoVisual.instantiate()
		par.paterno.visual = cenaCromossomoVisual.instantiate()
		
		add_child(par.materno.visual)
		add_child(par.paterno.visual)
		
		par.materno.visual.configurar(par.materno)
		par.paterno.visual.configurar(par.paterno)
		
func atualizar_visuais() -> void:
	for par in celula.pares_homologos:
		
		if par.materno.visual != null:
			par.materno.visual.position = par.materno.posicao
			par.materno.visual.queue_redraw()
			
		if par.paterno.visual != null:
			par.paterno.visual.position = par.paterno.posicao
			par.paterno.visual.queue_redraw()
