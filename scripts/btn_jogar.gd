extends Button #btn_jogar.gd

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/jogo.tscn");
