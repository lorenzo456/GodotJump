extends Node2D

@onready var grid: GridContainer = $HUD/ScrollContainer/GridContainer
@onready var coins_label: Label = $HUD/CoinsLabel

func _ready() -> void:
	$HUD/BackButton.pressed.connect(_on_back_pressed)
	_refresh()

func _refresh() -> void:
	coins_label.text = "Coins: " + str(SaveData.coins)
	for child in grid.get_children():
		child.queue_free()
	for item in SaveData.ITEMS:
		grid.add_child(_create_tile(item))

func _create_tile(item: Dictionary) -> PanelContainer:
	var is_free: bool = false
	var stock: int = SaveData.get_stock(item["id"])
	var equipped: bool = SaveData.equipped_item == item["id"]
	var can_afford: bool = SaveData.coins >= item["cost"]

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 255)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Color preview
	var preview := ColorRect.new()
	preview.color = item["color"]
	preview.custom_minimum_size = Vector2(100, 80)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(preview)

	# Name
	var name_label := Label.new()
	name_label.text = item["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	# Description
	var desc_label := Label.new()
	desc_label.text = item["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Stock count
	var stock_label := Label.new()
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stock_label.add_theme_font_size_override("font_size", 15)
	stock_label.text = "In stock: " + str(stock)
	vbox.add_child(stock_label)

	# Cost label
	var cost_label := Label.new()
	cost_label.text = str(item["cost"]) + " coins each"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color",
		Color(0.2, 0.55, 0.2) if can_afford else Color(0.7, 0.25, 0.2))
	vbox.add_child(cost_label)

	# Buttons row
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	# Buy button
	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.disabled = not can_afford
	buy_btn.pressed.connect(func(): _on_buy(item["id"], item["cost"]))
	hbox.add_child(buy_btn)

	# Equip button
	var equip_btn := Button.new()
	if equipped:
		equip_btn.text = "Equipped"
		equip_btn.disabled = true
	else:
		equip_btn.text = "Equip"
		equip_btn.disabled = stock == 0
		equip_btn.pressed.connect(func(): _on_equip(item["id"]))
	hbox.add_child(equip_btn)

	return panel

func _on_buy(item_id: String, cost: int) -> void:
	if SaveData.buy_item(item_id, cost):
		_refresh()

func _on_equip(item_id: String) -> void:
	SaveData.equip_item(item_id)
	_refresh()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
