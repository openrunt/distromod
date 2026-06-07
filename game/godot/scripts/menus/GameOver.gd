extends Control

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		if error != OK:
			push_error("GameOver failed to load %s: %s" % [MAIN_MENU_SCENE, error])
