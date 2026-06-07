#!/usr/bin/env bash
set -euo pipefail

# Ensure every parent folder exists before writing any generated file.
mkdir -p game/godot/scripts/boot
mkdir -p game/godot/scripts/menus
mkdir -p game/godot/scripts/realms
mkdir -p game/godot/scripts/actors
mkdir -p game/godot/scripts/enemies
mkdir -p game/godot/scripts/bosses
mkdir -p game/godot/scripts/ui
mkdir -p game/godot/scripts/core

mkdir -p game/godot/scenes/boot
mkdir -p game/godot/scenes/menus
mkdir -p game/godot/scenes/realms
mkdir -p game/godot/scenes/actors
mkdir -p game/godot/scenes/enemies
mkdir -p game/godot/scenes/bosses
mkdir -p game/godot/scenes/ui

mkdir -p game/godot/assets/ui
mkdir -p game/godot/assets/sprites
mkdir -p game/godot/assets/backgrounds
mkdir -p game/godot/assets/tilesets
mkdir -p game/godot/assets/audio

mkdir -p game/godot/data
mkdir -p docs

cat > game/godot/project.godot <<'GODOT_PROJECT'
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="Wyrmbound Vale"
run/main_scene="res://scenes/boot/Boot.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")
config/icon="res://assets/ui/icon.svg"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]

move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
attack={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":74,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)]
}
GODOT_PROJECT

cat > game/godot/scripts/boot/Boot.gd <<'GDSCRIPT'
extends Node

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

func _ready() -> void:
	call_deferred("_load_main_menu")

func _load_main_menu() -> void:
	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	if error != OK:
		push_error("Boot failed to load %s: %s" % [MAIN_MENU_SCENE, error])
GDSCRIPT

cat > game/godot/scripts/menus/MainMenu.gd <<'GDSCRIPT'
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
GDSCRIPT

cat > game/godot/scripts/menus/LoreIntro.gd <<'GDSCRIPT'
extends Control

const BRIGHT_VALE_CHASM_SCENE := "res://scenes/realms/BrightValeChasm.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		var error := get_tree().change_scene_to_file(BRIGHT_VALE_CHASM_SCENE)
		if error != OK:
			push_error("LoreIntro failed to load %s: %s" % [BRIGHT_VALE_CHASM_SCENE, error])
GDSCRIPT

cat > game/godot/scripts/menus/GameOver.gd <<'GDSCRIPT'
extends Control

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		if error != OK:
			push_error("GameOver failed to load %s: %s" % [MAIN_MENU_SCENE, error])
GDSCRIPT

cat > game/godot/scripts/menus/VictoryReturnHome.gd <<'GDSCRIPT'
extends Control

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		if error != OK:
			push_error("VictoryReturnHome failed to load %s: %s" % [MAIN_MENU_SCENE, error])
GDSCRIPT

cat > game/godot/scripts/menus/PauseMenu.gd <<'GDSCRIPT'
extends Control

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused
GDSCRIPT

cat > game/godot/scripts/realms/RealmController.gd <<'GDSCRIPT'
extends Node2D

signal objective_updated(message: String)

func _ready() -> void:
	objective_updated.emit("Reach the outpost gate.")
GDSCRIPT

cat > game/godot/scripts/ui/ArcadeHUD.gd <<'GDSCRIPT'
extends CanvasLayer

@onready var objective_label: Label = $ObjectiveLabel

func set_objective(message: String) -> void:
	if objective_label != null:
		objective_label.text = message
GDSCRIPT

cat > game/godot/scenes/boot/Boot.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/boot/Boot.gd" id="1_boot"]

[node name="Boot" type="Node"]
script = ExtResource("1_boot")
TSCN

cat > game/godot/scenes/menus/MainMenu.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/menus/MainMenu.gd" id="1_menu"]

[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_menu")

[node name="CenterContainer" type="CenterContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0

[node name="VBoxContainer" type="VBoxContainer" parent="CenterContainer"]
layout_mode = 2

[node name="TitleLabel" type="Label" parent="CenterContainer/VBoxContainer"]
layout_mode = 2
text = "Wyrmbound Vale"
horizontal_alignment = 1

[node name="StartButton" type="Button" parent="CenterContainer/VBoxContainer"]
layout_mode = 2
text = "Start Bright Vale Chasm"
TSCN

cat > game/godot/scenes/menus/LoreIntro.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/menus/LoreIntro.gd" id="1_lore"]

[node name="LoreIntro" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_lore")

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "The vale waits. Press Enter to begin."
horizontal_alignment = 1
vertical_alignment = 1
TSCN

cat > game/godot/scenes/menus/GameOver.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/menus/GameOver.gd" id="1_gameover"]

[node name="GameOver" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_gameover")

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "Game Over - Press Enter"
horizontal_alignment = 1
vertical_alignment = 1
TSCN

cat > game/godot/scenes/menus/VictoryReturnHome.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/menus/VictoryReturnHome.gd" id="1_victory"]

[node name="VictoryReturnHome" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_victory")

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "Bright Vale is safe - Press Enter"
horizontal_alignment = 1
vertical_alignment = 1
TSCN

cat > game/godot/scenes/menus/PauseMenu.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/menus/PauseMenu.gd" id="1_pause"]

[node name="PauseMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_pause")

[node name="Label" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "Paused"
horizontal_alignment = 1
vertical_alignment = 1
TSCN

cat > game/godot/scenes/realms/BrightValeChasm.tscn <<'TSCN'
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/realms/RealmController.gd" id="1_realm"]
[ext_resource type="PackedScene" path="res://scenes/ui/ArcadeHUD.tscn" id="2_hud"]

[node name="BrightValeChasm" type="Node2D"]
script = ExtResource("1_realm")

[node name="ArcadeHUD" parent="." instance=ExtResource("2_hud")]
TSCN

cat > game/godot/scenes/ui/ArcadeHUD.tscn <<'TSCN'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/ArcadeHUD.gd" id="1_hud"]

[node name="ArcadeHUD" type="CanvasLayer"]
script = ExtResource("1_hud")

[node name="ObjectiveLabel" type="Label" parent="."]
offset_left = 24.0
offset_top = 20.0
offset_right = 760.0
offset_bottom = 62.0
text = "Objective: Reach the outpost gate."
TSCN

cat > game/godot/assets/ui/icon.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="12" fill="#10102a"/>
  <path d="M32 8 L48 28 L40 54 L24 54 L16 28 Z" fill="#36f5ff" opacity="0.85"/>
  <path d="M32 14 L42 30 L36 48 L28 48 L22 30 Z" fill="#f6c453"/>
</svg>
SVG

cat > docs/wyrmbound_godot_scaffold.md <<'MARKDOWN'
# Wyrmbound Vale Godot Scaffold

This scaffold is intentionally minimal. It exists to make file creation robust and to keep scene script references pointed at files that exist before deeper gameplay work begins.

Run from the repository root:

```sh
./scripts/create_wyrmbound_godot_scaffold.sh
```
MARKDOWN
