extends Node2D

const OBSTACLE_TEXTURE = preload("res://obstacles/block_spikes.png")

var pipe_width: float = 0.0
var top_height: float = 0.0
var bottom_height: float = 0.0
var screen_height: float = 0.0
var scored: bool = false

func setup(p_screen_height: float, p_gap_center: float, p_gap_size: float, _pipe_width: float) -> void:
	screen_height = p_screen_height
	pipe_width = OBSTACLE_TEXTURE.get_width()
	top_height = p_gap_center - p_gap_size / 2.0
	bottom_height = screen_height - (p_gap_center + p_gap_size / 2.0)
	_add_collision()
	queue_redraw()

func _add_collision() -> void:
	if top_height > 0:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(pipe_width, top_height)
		shape.shape = rect
		shape.position = Vector2(pipe_width / 2.0, top_height / 2.0)
		body.add_child(shape)
		add_child(body)

	if bottom_height > 0:
		var bottom_y := screen_height - bottom_height
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(pipe_width, bottom_height)
		shape.shape = rect
		shape.position = Vector2(pipe_width / 2.0, bottom_y + bottom_height / 2.0)
		body.add_child(shape)
		add_child(body)

func _draw() -> void:
	if top_height > 0:
		# Flip vertically so spikes point downward toward the gap
		draw_set_transform(Vector2(0.0, top_height), 0.0, Vector2(1.0, -1.0))
		draw_texture_rect(OBSTACLE_TEXTURE, Rect2(0.0, 0.0, pipe_width, top_height), true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if bottom_height > 0:
		# Normal orientation — spikes point upward toward the gap
		draw_texture_rect(OBSTACLE_TEXTURE, Rect2(0.0, screen_height - bottom_height, pipe_width, bottom_height), true)
