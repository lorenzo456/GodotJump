extends Control

@onready var final_score_label: Label = $CenterContainer/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	get_tree().get_root().get_node("World/Player").game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_menu_button.disabled = false
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_game_over() -> void:
	var score: int = get_tree().get_root().get_node("World/ObstacleSpawner").score
	SaveData.update_high_score(score)
	final_score_label.text = "Score: " + str(score)
	show()
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
