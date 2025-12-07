extends Node

@onready var m_m = get_parent()
var multiplayer_menu = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# runs only on server, ignored zhere
@rpc("any_peer", "call_remote", "reliable")
func create_room():
	pass


@rpc("authority", "call_remote", "reliable")
func move_to_room(room_id, room_name, msg=null):
	m_m.room_id = room_id
	multiplayer_menu.show_room(room_name, msg)


@rpc("authority", "call_remote", "reliable")
func update_room_list(room_data):
	multiplayer_menu.main_container.recreate_room_list(room_data)

@rpc("authority", "call_remote", "reliable")
func update_room_data(room_data):
	m_m.room_data = room_data
	m_m.rules = room_data["rules"]
	m_m.being_played = room_data["being_played"]
	
	if m_m.my_peer_id not in get_playing_players_data():
		m_m.is_spectator = true
	else:
		m_m.is_spectator = false
	
	multiplayer_menu.room_container.update_room_data(room_data)

@rpc("any_peer", "call_remote", "reliable")
func push_room_settings(room_id, room_data):
	pass

@rpc("any_peer", "call_remote", "reliable")
func join_room_request(room_id):
	pass

@rpc("any_peer", "call_remote", "reliable")
func leave_room_request(room_id):
	pass

@rpc("any_peer", "call_remote", "reliable")
func move_back_room_request(room_id):
	pass



@rpc("authority", "call_remote", "reliable")
func move_to_loby():
	m_m.room_id = null
	multiplayer_menu.show_loby()

@rpc("any_peer", "call_remote", "reliable")
func start_game(room_id):
	pass

@rpc("any_peer", "call_remote", "reliable")
func spectator_requerst_join_game(room_id):
	pass

@rpc("authority", "call_remote", "reliable")
func move_player_to_game(players_data, player_turn, city_size, vcb=null):
	m_m.players_data = players_data
	
	if m_m.my_peer_id in players_data:
		m_m.is_playing = true
		multiplayer_menu.can_move_units()
		m_m.my_player = players_data[m_m.my_peer_id]
	m_m.being_played = true
	m_m.player_turn = player_turn
	m_m.city_size = city_size
	
	multiplayer_menu.prepare_game(m_m, players_data, vcb)
	multiplayer_menu.show_game()



func get_playing_players_data():
	var player_data = {}
	
	for player in m_m.room_data["players_data"]:
		var player_id = player["id"]
		var is_playing = player["is_playing"]
		var player_color = player["player_color"]
		
		if is_playing:
			player_data[player_id] = player_color
			
	return player_data
