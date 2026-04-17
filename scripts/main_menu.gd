extends Node2D

@onready var high_score_label: Label = $HUD/CenterContainer/VBoxContainer/HighScoreLabel
@onready var start_button: Button = $HUD/CenterContainer/VBoxContainer/StartButton
@onready var shop_button: Button = $HUD/CenterContainer/VBoxContainer/ShopButton
@onready var exit_button: Button = $HUD/CenterContainer/VBoxContainer/ExitButton

func _ready() -> void:
	high_score_label.text = "Best: " + str(SaveData.high_score)
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/gameplay.tscn"))
	shop_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/shop.tscn"))
	exit_button.pressed.connect(func(): get_tree().quit())
