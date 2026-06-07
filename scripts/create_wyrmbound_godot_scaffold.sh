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

cat > game/godot/scripts/actors/Knight.gd <<'GDSCRIPT'
extends CharacterBody2D

@export var run_speed: float = 320.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -560.0
@export var gravity: float = 1600.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * run_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if not is_on_floor():
		velocity.y += gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	if direction != 0.0:
		$Visual.scale.x = sign(direction)

	move_and_slide()
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

cat > game/godot/scenes/actors/Knight.tscn <<'TSCN'
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/actors/Knight.gd" id="1_knight"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_knight"]
size = Vector2(36, 58)

[node name="Knight" type="CharacterBody2D" groups=["player"]]
position = Vector2(180, 520)
script = ExtResource("1_knight")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -29)
shape = SubResource("RectangleShape2D_knight")

[node name="Visual" type="Node2D" parent="."]

[node name="CapeGlow" type="Polygon2D" parent="Visual"]
color = Color(0.0823529, 0.85098, 1, 0.35)
polygon = PackedVector2Array(-28, -38, -12, -42, -8, 4, -30, 8)

[node name="ArmorBody" type="Polygon2D" parent="Visual"]
color = Color(0.156863, 0.321569, 0.65098, 1)
polygon = PackedVector2Array(-18, -48, 18, -48, 22, -4, 14, 10, -14, 10, -22, -4)

[node name="Helmet" type="Polygon2D" parent="Visual"]
color = Color(0.62, 0.78, 0.96, 1)
polygon = PackedVector2Array(-16, -64, 16, -64, 20, -50, 12, -42, -12, -42, -20, -50)

[node name="HelmetShine" type="Polygon2D" parent="Visual"]
color = Color(1, 0.86, 0.28, 1)
polygon = PackedVector2Array(-4, -68, 4, -68, 6, -42, -6, -42)

[node name="Shield" type="Polygon2D" parent="Visual"]
position = Vector2(-24, -26)
color = Color(0.05, 0.95, 1, 1)
polygon = PackedVector2Array(-14, -16, 10, -20, 16, -2, 8, 20, -10, 16, -18, -2)

[node name="ShieldEmblem" type="Polygon2D" parent="Visual"]
position = Vector2(-24, -26)
color = Color(1, 0.74, 0.18, 1)
polygon = PackedVector2Array(-2, -9, 6, 0, -2, 10, -10, 0)

[node name="Sword" type="Polygon2D" parent="Visual"]
position = Vector2(28, -30)
color = Color(0.9, 0.96, 1, 1)
polygon = PackedVector2Array(0, -38, 7, -4, 3, 18, -3, 18, -7, -4)

[node name="SwordHilt" type="Polygon2D" parent="Visual"]
position = Vector2(28, -30)
color = Color(1, 0.74, 0.18, 1)
polygon = PackedVector2Array(-12, 16, 12, 16, 12, 22, -12, 22)
TSCN

cat > game/godot/scenes/realms/BrightValeChasm.tscn <<'TSCN'
[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scripts/realms/RealmController.gd" id="1_realm"]
[ext_resource type="PackedScene" path="res://scenes/ui/ArcadeHUD.tscn" id="2_hud"]
[ext_resource type="PackedScene" path="res://scenes/actors/Knight.tscn" id="3_knight"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_ground"]
size = Vector2(1280, 80)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_platform"]
size = Vector2(220, 26)

[node name="BrightValeChasm" type="Node2D"]
script = ExtResource("1_realm")

[node name="Sky" type="Polygon2D" parent="."]
color = Color(0.0352941, 0.0392157, 0.16, 1)
polygon = PackedVector2Array(0, 0, 1280, 0, 1280, 720, 0, 720)

[node name="Ground" type="StaticBody2D" parent="."]
position = Vector2(640, 680)

[node name="GroundShape" type="CollisionShape2D" parent="Ground"]
shape = SubResource("RectangleShape2D_ground")

[node name="GroundVisual" type="Polygon2D" parent="Ground"]
color = Color(0.08, 0.18, 0.22, 1)
polygon = PackedVector2Array(-640, -40, 640, -40, 640, 40, -640, 40)

[node name="TrainingPlatform" type="StaticBody2D" parent="."]
position = Vector2(620, 520)

[node name="PlatformShape" type="CollisionShape2D" parent="TrainingPlatform"]
shape = SubResource("RectangleShape2D_platform")

[node name="PlatformVisual" type="Polygon2D" parent="TrainingPlatform"]
color = Color(0.16, 0.46, 0.5, 1)
polygon = PackedVector2Array(-110, -13, 110, -13, 110, 13, -110, 13)

[node name="Knight" parent="." instance=ExtResource("3_knight")]

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
