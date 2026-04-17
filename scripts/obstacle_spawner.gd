extends Node2D

const SCROLL_SPEED = 150.0
const GAP_SIZE = 220.0
const EDGE_PADDING = 80.0
const MIN_INTERVAL = 2.5
const MAX_INTERVAL = 4.5

const ObstacleScript = preload("res://scripts/obstacle.gd")

var spawn_timer: float = 0.0
var next_spawn_time: float = 2.0
var active_obstacles: Array = []
var score: int = 0
var player_x: float

@onready var score_label: Label = get_parent().get_node("HUD/ScoreLabel")

func _ready() -> void:
	player_x = get_parent().get_node("Player").position.x
	_reset_timer()

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= next_spawn_time:
		_spawn_obstacle()
		_reset_timer()

	var to_remove: Array = []
	for obs in active_obstacles:
		obs.position.x -= SCROLL_SPEED * delta

		if not obs.scored and obs.position.x + obs.pipe_width < player_x:
			obs.scored = true
			score += 1
			score_label.text = str(score)

		if obs.position.x + obs.pipe_width < 0.0:
			to_remove.append(obs)

	for obs in to_remove:
		active_obstacles.erase(obs)
		obs.queue_free()

func _reset_timer() -> void:
	next_spawn_time = randf_range(MIN_INTERVAL, MAX_INTERVAL)
	spawn_timer = 0.0

func _spawn_obstacle() -> void:
	var vp_size := get_viewport_rect().size
	var gap_center := randf_range(
		EDGE_PADDING + GAP_SIZE / 2.0,
		vp_size.y - EDGE_PADDING - GAP_SIZE / 2.0
	)
	var obs := Node2D.new()
	obs.set_script(ObstacleScript)
	obs.position = Vector2(vp_size.x, 0.0)
	add_child(obs)
	obs.setup(vp_size.y, gap_center, GAP_SIZE)
	active_obstacles.append(obs)
