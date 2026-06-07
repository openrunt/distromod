extends Control

const BRIGHT_VALE_CHASM_SCENE := "res://scenes/realms/BrightValeChasm.tscn"
const LORE_INTRO_SCENE := "res://scenes/menus/LoreIntro.tscn"

func _ready() -> void:
	var start_button := get_node_or_null("CenterContainer/VBoxContainer/StartButton")
	if start_button != null:
		start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	_start_game()

func _start_game() -> void:
	var error := get_tree().change_scene_to_file(BRIGHT_VALE_CHASM_SCENE)
	if error != OK:
		push_error("MainMenu failed to load %s: %s" % [BRIGHT_VALE_CHASM_SCENE, error])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()
