extends Node2D

func _ready() -> void:
	var item_id := SaveData.equipped_item
	if item_id == "":
		return

	var item_name := ""
	for item in SaveData.ITEMS:
		if item["id"] == item_id:
			item_name = item["name"]
			break

	if item_name == "":
		return

	var label := Label.new()
	label.text = "Equipped: " + item_name 
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05, 1))

	var viewport_size := get_viewport_rect().size
	label.position = Vector2(16, viewport_size.y - 48)

	$HUD.add_child(label)
