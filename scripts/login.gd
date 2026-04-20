extends Node2D

const API_URL = "https://web-production-538cd.up.railway.app/auth/login"

@onready var email_field: LineEdit = $HUD/CenterContainer/VBoxContainer/EmailField
@onready var password_field: LineEdit = $HUD/CenterContainer/VBoxContainer/PasswordField
@onready var login_button: Button = $HUD/CenterContainer/VBoxContainer/LoginButton
@onready var status_label: Label = $HUD/CenterContainer/VBoxContainer/StatusLabel
@onready var back_button: Button = $HUD/CenterContainer/VBoxContainer/BackButton

var http_request: HTTPRequest

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	login_button.pressed.connect(_on_login_pressed)
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _on_login_pressed() -> void:
	var email := email_field.text.strip_edges()
	var password := password_field.text

	if email == "" or password == "":
		status_label.text = "Please enter email and password."
		return

	login_button.disabled = true
	status_label.text = "Signing in..."

	var body := JSON.stringify({"email": email, "password": password})
	var headers := ["Content-Type: application/json"]
	var err := http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		status_label.text = "Network error. Is the server running?"
		login_button.disabled = false
		return

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	login_button.disabled = false

	if result != HTTPRequest.RESULT_SUCCESS:
		status_label.text = "Could not reach the server. Is it running?"
		return

	if response_code == 200:
		var json := JSON.new()
		if json.parse(body.get_string_from_utf8()) != OK or not (json.get_data() is Dictionary):
			status_label.text = "Unexpected server response."
			return
		var data: Dictionary = json.get_data()
		if not data.has("token"):
			status_label.text = "Unexpected server response."
			return
		var player: Dictionary = data.get("player", {})
		SaveData.sign_in(data["token"], player.get("first_name", ""), player.get("email", ""))
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return

	# Try to read a message from the JSON body, fall back to status-code defaults.
	var message := _error_message_for(response_code)
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and json.get_data() is Dictionary:
		var data: Dictionary = json.get_data()
		if data.has("message") and data["message"] != "":
			message = data["message"]
	status_label.text = message

func _error_message_for(code: int) -> String:
	match code:
		400: return "Please enter your email and password."
		401: return "Incorrect email or password."
		404: return "Account not found."
		500, 502, 503: return "Server error. Please try again later."
		_:   return "Login failed. Please try again."
