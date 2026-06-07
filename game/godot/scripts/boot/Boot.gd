extends Node

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

func _ready() -> void:
	call_deferred("_load_main_menu")

func _load_main_menu() -> void:
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("Boot failed to load %s: %s" % [MAIN_MENU_SCENE, error])
