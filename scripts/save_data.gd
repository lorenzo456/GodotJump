extends Node

const SAVE_PATH = "user://save.cfg"

const ITEMS = [
	{
		"id": "shortened_jump",
		"name": "Shortened Jump",
		"description": "Reduces jump height for more precise control.",
		"cost": 30,
		"color": Color(0.4, 0.75, 1.0, 1.0),
	},
	{
		"id": "double_lives",
		"name": "Double Lives",
		"description": "Start each run with an extra life.",
		"cost": 75,
		"color": Color(1.0, 0.4, 0.4, 1.0),
	},
	{
		"id": "movement_speed",
		"name": "Movement Speed",
		"description": "Increases the scroll speed for a harder challenge.",
		"cost": 50,
		"color": Color(0.4, 0.9, 0.4, 1.0),
	},
]

var coins: int = 0
var high_score: int = 0
var owned_items: Dictionary = {}
var equipped_item: String = ""

func _ready() -> void:
	_load()

func get_stock(item_id: String) -> int:
	return owned_items.get(item_id, 0)

func add_coins(amount: int) -> void:
	coins += amount
	_save()

func update_high_score(score: int) -> void:
	if score > high_score:
		high_score = score
		_save()

func buy_item(item_id: String, cost: int) -> bool:
	if coins < cost:
		return false
	coins -= cost
	owned_items[item_id] = owned_items.get(item_id, 0) + 1
	_save()
	return true

func equip_item(item_id: String) -> void:
	if owned_items.get(item_id, 0) > 0:
		equipped_item = item_id
		_save()

func unequip() -> void:
	equipped_item = ""
	_save()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "coins", coins)
	cfg.set_value("player", "high_score", high_score)
	cfg.set_value("player", "owned_items", owned_items)
	cfg.set_value("player", "equipped_item", equipped_item)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("SaveData: failed to save (%s)" % error_string(err))

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	coins = cfg.get_value("player", "coins", 0)
	high_score = cfg.get_value("player", "high_score", 0)
	equipped_item = cfg.get_value("player", "equipped_item", "")
	var raw = cfg.get_value("player", "owned_items", {})
	owned_items = raw if raw is Dictionary else {}
