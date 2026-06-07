extends Control

const BRIGHT_VALE_CHASM_SCENE := "res://scenes/realms/BrightValeChasm.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		var error := get_tree().change_scene_to_file(BRIGHT_VALE_CHASM_SCENE)
		if error != OK:
			push_error("LoreIntro failed to load %s: %s" % [BRIGHT_VALE_CHASM_SCENE, error])
