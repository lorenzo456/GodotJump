extends Node2D

const TILE_SIZE := Vector2(165, 260)
const FONT_SIZE_NAME := 18
const FONT_SIZE_DESC := 12
const FONT_SIZE_STOCK := 15
const FONT_SIZE_COST := 14
const COLOR_DESC := Color(0.5, 0.5, 0.5)
const COLOR_AFFORDABLE := Color(0.2, 0.55, 0.2)
const COLOR_EXPENSIVE := Color(0.7, 0.25, 0.2)

@onready var grid: GridContainer = $HUD/ScrollContainer/GridContainer
@onready var coins_label: Label = $HUD/CoinsLabel

func _ready() -> void:
	$HUD/BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	_refresh()

func _refresh() -> void:
	coins_label.text = "Coins: " + str(SaveData.coins)
	for child in grid.get_children():
		child.queue_free()
	for item in SaveData.ITEMS:
		grid.add_child(_create_tile(item))

func _create_tile(item: Dictionary) -> PanelContainer:
	var stock: int = SaveData.get_stock(item["id"])
	var equipped: bool = SaveData.equipped_item == item["id"]
	var can_afford: bool = SaveData.coins >= item["cost"]

	var panel := PanelContainer.new()
	panel.custom_minimum_size = TILE_SIZE

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var preview := ColorRect.new()
	preview.color = item["color"]
	preview.custom_minimum_size = Vector2(100, 80)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(preview)

	var name_label := Label.new()
	name_label.text = item["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", FONT_SIZE_NAME)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = item["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", FONT_SIZE_DESC)
	desc_label.add_theme_color_override("font_color", COLOR_DESC)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	var stock_label := Label.new()
	stock_label.text = "In stock: " + str(stock)
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stock_label.add_theme_font_size_override("font_size", FONT_SIZE_STOCK)
	vbox.add_child(stock_label)

	var cost_label := Label.new()
	cost_label.text = str(item["cost"]) + " coins each"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", FONT_SIZE_COST)
	cost_label.add_theme_color_override("font_color", COLOR_AFFORDABLE if can_afford else COLOR_EXPENSIVE)
	vbox.add_child(cost_label)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.disabled = not can_afford
	buy_btn.pressed.connect(func(): _on_buy(item["id"], item["cost"], item["name"]))
	hbox.add_child(buy_btn)

	var equip_btn := Button.new()
	equip_btn.text = "Equipped" if equipped else "Equip"
	equip_btn.disabled = equipped or stock == 0
	if not equipped:
		equip_btn.pressed.connect(func(): _on_equip(item["id"]))
	hbox.add_child(equip_btn)

	return panel

func _on_buy(item_id: String, cost: int, item_name: String) -> void:
	if SaveData.buy_item(item_id, cost):
		_refresh()
		if SaveData.is_signed_in():
			_post_purchase_activity(cost, item_name)

func _on_equip(item_id: String) -> void:
	SaveData.equip_item(item_id)
	_refresh()

func _post_purchase_activity(cost: int, item_name: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_r, _c, _h, _b): http.queue_free())

	var body := JSON.stringify({
		"activity_type_id": 4,
		"source": "godot_jump",
		"points": -cost,
		"properties": [
			{"activity_property_id": 7, "value": cost},
			{"activity_property_id": 8, "value": "bought " + item_name.to_lower()},
		]
	})
	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + SaveData.auth_token,
	]
	http.request("https://web-production-538cd.up.railway.app/activities", headers, HTTPClient.METHOD_POST, body)
