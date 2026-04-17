extends Node2D

@onready var high_score_label: Label = $HUD/CenterContainer/VBoxContainer/HighScoreLabel

func _ready() -> void:
	high_score_label.text = "Best: " + str(SaveData.high_score)

	$HUD/CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$HUD/CenterContainer/VBoxContainer/ShopButton.pressed.connect(_on_shop_pressed)
	$HUD/CenterContainer/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://gameplay.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://shop.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
