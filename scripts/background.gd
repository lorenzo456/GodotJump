extends Node2D

const BASE_SCROLL_SPEED = 60.0
var scroll_speed: float

@onready var sprite1: Sprite2D = $Sprite1
@onready var sprite2: Sprite2D = $Sprite2

var textures: Array[Texture2D] = []
var next_index: int = 0
var tex_width: float

func _ready() -> void:
	scroll_speed = BASE_SCROLL_SPEED * (1.3 if SaveData.equipped_item == "movement_speed" else 1.0)
	_load_textures()
	if textures.is_empty():
		push_error("No PNG files found in res://assets/backgrounds/")
		return

	var viewport_size = get_viewport_rect().size
	var tex_size = textures[0].get_size()
	var scale_factor = max(viewport_size.x / tex_size.x, viewport_size.y / tex_size.y)
	tex_width = tex_size.x * scale_factor
	var y = viewport_size.y / 2.0

	sprite1.texture = textures[0]
	sprite1.scale = Vector2(scale_factor, scale_factor)
	sprite1.position = Vector2(tex_width / 2.0, y)

	sprite2.texture = textures[1 % textures.size()]
	sprite2.scale = Vector2(scale_factor, scale_factor)
	sprite2.position = Vector2(tex_width + tex_width / 2.0, y)

	next_index = 2 % textures.size()

func _load_textures() -> void:
	var files = DirAccess.get_files_at("res://assets/backgrounds/")
	for file in files:
		if file.ends_with(".png"):
			var tex: Texture2D = load("res://assets/backgrounds/" + file)
			if tex != null:
				textures.append(tex)

func _process(delta: float) -> void:
	if textures.is_empty():
		return

	sprite1.position.x -= scroll_speed * delta
	sprite2.position.x -= scroll_speed * delta

	# Use elif so both can't recycle in the same frame
	if sprite1.position.x + tex_width / 2.0 < 0.0:
		sprite1.texture = textures[next_index]
		next_index = (next_index + 1) % textures.size()
		sprite1.position.x = sprite2.position.x + tex_width
	elif sprite2.position.x + tex_width / 2.0 < 0.0:
		sprite2.texture = textures[next_index]
		next_index = (next_index + 1) % textures.size()
		sprite2.position.x = sprite1.position.x + tex_width
