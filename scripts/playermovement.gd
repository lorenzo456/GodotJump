extends CharacterBody2D

signal game_over

const GRAVITY = 1800.0
const JUMP_FORCE = -600.0
const JUMP_FORCE_SHORT = -400.0
const INVINCIBILITY_DURATION = 3.0
const BLINK_INTERVAL = 0.1

var dead: bool = false
var _viewport_height: float
var _jump_force: float
var _lives: int = 1
var _invincible: bool = false
var _invincibility_timer: float = 0.0
var _blink_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_viewport_height = get_viewport_rect().size.y
	_jump_force = JUMP_FORCE_SHORT if SaveData.equipped_item == "shortened_jump" else JUMP_FORCE
	if SaveData.equipped_item == "double_lives":
		_lives = 2

func _physics_process(delta: float) -> void:
	if dead:
		return

	if _invincible:
		_invincibility_timer -= delta
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			_sprite.visible = not _sprite.visible
			_blink_timer = BLINK_INTERVAL
		if _invincibility_timer <= 0.0:
			_invincible = false
			_sprite.visible = true

	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = _jump_force

	move_and_slide()

	if not _invincible:
		if get_slide_collision_count() > 0 or position.y < 0.0 or position.y > _viewport_height:
			_on_hit()

func _on_hit() -> void:
	if _lives > 1:
		_lives -= 1
		_invincible = true
		_invincibility_timer = INVINCIBILITY_DURATION
		_blink_timer = BLINK_INTERVAL
		position.y = clamp(position.y, 50.0, _viewport_height - 50.0)
		velocity.y = 0.0
	else:
		dead = true
		_sprite.visible = true
		game_over.emit()
