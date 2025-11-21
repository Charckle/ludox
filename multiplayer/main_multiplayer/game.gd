extends Node

@onready var m_m = get_parent()
var multiplayer_menu = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@rpc("any_peer", "call_remote", "reliable")
func send_move(room_id, start_pos, end_pos):
	pass


@rpc("authority", "call_remote", "reliable")
func move_unit(start_pos, end_pos):
	multiplayer_menu.game_city.move_unit(34, start_pos, end_pos)


@rpc("authority", "call_remote", "reliable")
func can_move_unit():
	multiplayer_menu.can_move_units()

@rpc("any_peer", "call_remote", "reliable")
func unit_moved(room_id):
	pass

@rpc("authority", "call_remote", "reliable")
func remove_this_units(units):
	for unit in units:
		var to_delete_pg = unit[2]
		multiplayer_menu.game_city.eat_unit(to_delete_pg, false, true)

@rpc("authority", "call_remote", "reliable")
func endturn(player_turn):
	multiplayer_menu.game_city.end_turn_multiplayer()

@rpc("authority", "call_remote", "reliable")
func send_won_msg(player_data):
	# display won pieces
	multiplayer_menu.game_city.set_winner(player_data["player_color"])
	#display message who won
	var text_ = "banana"
	multiplayer_menu.show_who_won(text_)
