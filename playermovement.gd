extends CharacterBody2D

signal game_over

const GRAVITY = 1800.0
const JUMP_FORCE = -600.0

var dead: bool = false

func _physics_process(delta: float) -> void:
	if dead:
		return

	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()

	# Hit an obstacle
	if get_slide_collision_count() > 0:
		_trigger_game_over()
		return

	# Fell off bottom or jumped off top
	var vp_height := get_viewport_rect().size.y
	if position.y < 0.0 or position.y > vp_height:
		_trigger_game_over()

func _trigger_game_over() -> void:
	dead = true
	game_over.emit()
