extends Control #jogo.gd
@onready var painel = $PainelControle
@onready var simulacao = $Simulacao

func _ready():
	painel.iniciar_simulacao.connect(_iniciar_simulacao)
	painel.avancar_fase.connect(_avancar_fase)

func _iniciar_simulacao(inf):
	simulacao.iniciar(inf)
func _avancar_fase():
	simulacao.avancar_fase()
