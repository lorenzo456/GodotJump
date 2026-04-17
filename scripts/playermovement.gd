extends CharacterBody2D

signal game_over

const GRAVITY = 1800.0
const JUMP_FORCE = -600.0

var dead: bool = false
var _viewport_height: float

func _ready() -> void:
	_viewport_height = get_viewport_rect().size.y

func _physics_process(delta: float) -> void:
	if dead:
		return

	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()

	if get_slide_collision_count() > 0 or position.y < 0.0 or position.y > _viewport_height:
		dead = true
		game_over.emit()
