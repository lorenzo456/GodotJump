extends Node2D

const SCORE_URL = "http://127.0.0.1:5000/players/me/score"

@onready var high_score_label: Label = $HUD/CenterContainer/VBoxContainer/HighScoreLabel
@onready var start_button: Button = $HUD/CenterContainer/VBoxContainer/StartButton
@onready var shop_button: Button = $HUD/CenterContainer/VBoxContainer/ShopButton
@onready var ludo_health_button: Button = $HUD/CenterContainer/VBoxContainer/LudoHealthButton
@onready var auth_status_label: Label = $HUD/CenterContainer/VBoxContainer/AuthStatusLabel
@onready var exit_button: Button = $HUD/CenterContainer/VBoxContainer/ExitButton

var _http: HTTPRequest

func _ready() -> void:
	high_score_label.text = "Best: " + str(SaveData.high_score)
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/gameplay.tscn"))
	shop_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/shop.tscn"))
	exit_button.pressed.connect(func(): get_tree().quit())
	ludo_health_button.pressed.connect(_on_ludo_health_pressed)
	_refresh_auth_ui()
	if SaveData.is_signed_in():
		_fetch_ludo_score()

func _refresh_auth_ui() -> void:
	if SaveData.is_signed_in():
		ludo_health_button.text = "Sign Out of Ludo Health"
		auth_status_label.text = "Signed in as " + SaveData.player_first_name
		auth_status_label.visible = true
	else:
		ludo_health_button.text = "Sign In to Ludo Health"
		auth_status_label.visible = false

func _on_ludo_health_pressed() -> void:
	if SaveData.is_signed_in():
		SaveData.sign_out()
		_refresh_auth_ui()
	else:
		get_tree().change_scene_to_file("res://scenes/login.tscn")

func _fetch_ludo_score() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_score_fetched)
	var headers := ["Authorization: Bearer " + SaveData.auth_token]
	_http.request(SCORE_URL, headers, HTTPClient.METHOD_GET)

func _on_score_fetched(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var data = json.get_data()
	if data is Dictionary and data.has("score"):
		SaveData.coins = data["score"]
		SaveData.save()
