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
