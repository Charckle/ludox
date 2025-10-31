extends CanvasModulate

@onready var chat_btn =  $game_ui/chat_btn
@onready var option_panel =  $game_ui/option_panel
@onready var rule_book =  $game_ui/rule_book

var multiplayer_s = null


var option_panel_shown = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chat_btn_pressed() -> void:
	$chat.visible = not $chat.visible
	if chat_btn.position.x == -416:
		chat_btn.position.x = 48
	else:
		chat_btn.position.x = -416


func _on_options_btn_pressed() -> void:
	if option_panel_shown:
		option_panel_shown = false
		option_panel.position.x = 0
	else:
		option_panel_shown = true
		option_panel.position.x = 432.0


func _on_leave_btn_pressed() -> void:
	multiplayer_s.rooms_obj.rpc_id(1, "leave_room_request", multiplayer_s.room_id)


func _on_rules_btn_pressed() -> void:
	rule_book.visible = true
