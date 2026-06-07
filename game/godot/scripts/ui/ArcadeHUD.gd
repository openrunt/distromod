extends CanvasLayer

@onready var objective_label: Label = $ObjectiveLabel

func set_objective(message: String) -> void:
	if objective_label != null:
		objective_label.text = message
