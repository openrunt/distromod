extends Node2D

signal objective_updated(message: String)

func _ready() -> void:
	objective_updated.emit("Reach the outpost gate.")
