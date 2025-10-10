extends Node2D

@onready var multiplayer_s = get_tree().root.get_node("Main-multiplayer")

@onready var main_container = $main_container
@onready var chat_container = $chat/base_node/Panel/RichTextLabel
@onready var msg_log_container = $chat/base_node/Panel/msg_log_cont

@onready var chat_insert = $chat/base_node/LineEdit



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_s.multiplayer_menu = self
	multiplayer_s.rooms_obj.multiplayer_menu = self
	multiplayer_s.try_connect()
	$background.visible = true
	$waiting_conn_pan.visible = true
	show_default_windows()
	
	$main_container.multiplayer_s = self.multiplayer_s
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_default_windows():
	main_container.visible = true
	$room_container.visible = false

func insert_message(message):
	message += "\n"
	msg_log_container.text += message

func _on_line_edit_text_submitted(new_text: String) -> void:
	var msg = chat_insert.text
	multiplayer_s.rpc_id(1, "propagate_message", msg, multiplayer_s.room_id)

	chat_insert.clear()


func exit_multiplayer():
	multiplayer_s.stop_multy()
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_new_room_btn_pressed() -> void:
	multiplayer_s.rooms_obj.rpc_id(1, "create_room")


func show_room(room_name):
	main_container.visible = false
	$room_container.visible = true
	msg_log_container.text = ""
	var color = color_for_username(room_name)
	var message = "Welcome to [color=#%s]%s[/color] room!" % [color, room_name]
	insert_message(message)

func color_for_username(name: String) -> String:
	var hue := float(abs(hash(name)) % 360) / 360.0
	var c := Color.from_hsv(hue, 0.65, 1.0)
	return c.to_html(false)
