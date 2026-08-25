extends Panel #painel_controle.gd
@warning_ignore("unused_parameter")

#-Enviar sinal para começar simulação-#
signal iniciar_simulacao(configuracoes)
func _on_btn_gerar_pressed() -> void:
	var alelos1 :Array[Array] = []
	for a in range(sCrom.value):
		var valoresParaCromX :Array[int] = []
		for b in range(sSeg.value):
			valoresParaCromX.append(randi_range(0, 9))
		alelos1.append(valoresParaCromX)
	print(alelos1)
	var alelos2 :Array[Array] = []
	for a in range(sCrom.value):
		var valoresParaCromX :Array[int] = []
		for b in range(sSeg.value):
			valoresParaCromX.append(randi_range(0, 9))
		alelos2.append(valoresParaCromX)
	print(alelos2)
	
	var informacoes = {
		"crom": sCrom.value,
		"seg": sSeg.value,
		"ades": sAdes.value / 100.00,
		"mutac": sMutac.value / 100.00,
		"alelos1": alelos1, 
		"alelos2": alelos2
	}
	iniciar_simulacao.emit(informacoes)
	
signal avancar_fase()
func _on_btn_proxima_etapa_pressed() -> void:
	avancar_fase.emit()

#-Cromossomos----#
@onready var sCrom := $SliderCromossomos
@onready var sbCrom := $SboxCromossomos
func _on_slider_cromossomos_changed(value) -> void:
	sbCrom.value = value
func _on_sbox_cromossomos_changed(value) -> void:
	sCrom.value = value

#-Segmentos------#
@onready var sSeg := $SliderSegmentos
@onready var sbSeg := $SboxSegmentos
func _on_slider_segmentos_changed(value) -> void:
	sbSeg.value = value
func _on_sbox_segmentos_changed(value) -> void:
	sSeg.value = value

#-Adesividade----#
@onready var sAdes := $SliderAdesividade
@onready var sbAdes := $SboxAdesividade
func _on_slider_adesividade_changed(value) -> void:
	sbAdes.value = value
func _on_sbox_adesividade_changed(value) -> void:
	sAdes.value = value

#-Mutação--------#
@onready var sMutac := $SliderMutacao
@onready var sbMutac := $SboxMutacao
func _on_slider_mutacao_changed(value) -> void:
	sbMutac.value = value
func _on_sbox_mutacao_changed(value) -> void:
	sMutac.value = value

func _ready() -> void:
	#---------------------------------------#
	#---CONEXÕES DOS SPINBOXES E HSLIDERS---#
	#---------------------------------------#
	sCrom.value_changed.connect(_on_slider_cromossomos_changed)
	sbCrom.value_changed.connect(_on_sbox_cromossomos_changed)
	sCrom.max_value = 20
	sbCrom.max_value = 20
	sCrom.min_value = 1
	sbCrom.min_value = 1
	sCrom.step = 1
	sbCrom.step = 1
	
	sSeg.value_changed.connect(_on_slider_segmentos_changed)
	sbSeg.value_changed.connect(_on_sbox_segmentos_changed)
	sSeg.max_value = 100
	sbSeg.max_value = 100
	sSeg.min_value = 2
	sbSeg.min_value = 2
	sSeg.step = 1
	sbSeg.step = 1
	
	sAdes.value_changed.connect(_on_slider_adesividade_changed)
	sbAdes.value_changed.connect(_on_sbox_adesividade_changed)
	sAdes.max_value = 100
	sbAdes.max_value = 100
	sAdes.min_value = 0
	sbAdes.min_value = 0
	sAdes.step = 0.01
	sbAdes.step = 0.01
	
	sMutac.value_changed.connect(_on_slider_mutacao_changed)
	sbMutac.value_changed.connect(_on_sbox_mutacao_changed)
	sMutac.max_value = 100
	sbMutac.max_value = 100
	sMutac.min_value = 0
	sbMutac.min_value = 0
	sMutac.step = 0.01
	sbMutac.step = 0.01
