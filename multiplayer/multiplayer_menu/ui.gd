extends CanvasModulate

@onready var chat_btn =  $game_ui/chat_btn
@onready var option_panel =  $game_ui/option_panel
@onready var rule_book =  $game_ui/rule_book

var multiplayer_s = null

var multiplayer_menu = null


var option_panel_shown = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chat_btn_pressed() -> void:
	$chat.visible = not $chat.visible
	if $chat.visible:
		set_multi_play_menu(true)
	else:
		set_multi_play_menu(false)
	if chat_btn.position.x == -416:
		chat_btn.position.x = 48
	else:
		chat_btn.position.x = -416


func _on_options_btn_pressed() -> void:
	if option_panel_shown:
		hide_game_options()
	else:
		set_multi_play_menu(false)
		option_panel_shown = true
		option_panel.position.x = 432.0


func _on_leave_btn_pressed() -> void:
	hide_game_options()
	multiplayer_s.rooms_obj.rpc_id(1, "leave_room_request", multiplayer_s.room_id)


func _on_rules_btn_pressed() -> void:
	rule_book.visible = true


func _on_close_won_txt_btn_pressed() -> void:
	$game_ui/who_won_msg.visible = false


func _on_to_loby_btn_pressed() -> void:
	hide_game_options()
	multiplayer_s.rooms_obj.rpc_id(1, "move_back_room_request", multiplayer_s.room_id)


func hide_game_options():
	set_multi_play_menu(true)
	option_panel_shown = false
	option_panel.position.x = 0

func set_multi_play_menu(can=true):
	if can:
		multiplayer_menu.game_city.multi_play_menu_open = true
	else:
		multiplayer_menu.game_city.multi_play_menu_open = false
