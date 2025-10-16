extends Node

var ADDRESS
var PORT

var multiplayer_menu = null

var room_id = null


@onready var rooms_obj = $rooms

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connected_to_server.connect(_local_on_connected_ok) # emmited on the clinet ONLY
	multiplayer.connection_failed.connect(_local_on_connected_fail) # emmited on the clinet ONLY
	multiplayer.server_disconnected.connect(_local_on_server_disconnected) # emmited on the clinet ONLY
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#0 → CONNECTION_DISCONNECTED
	#1 → CONNECTION_CONNECTING
	#2 → CONNECTION_CONNECTED
	
	#if (multiplayer.multiplayer_peer != null):
	#	print(multiplayer.multiplayer_peer.get_connection_status())


func _local_on_connected_ok():
	#send the server your data
	#_register_player_on_server.rpc_id(1, player_info)
	var username = GlobalSet.settings["multiplayer"]["username"]
	self.rpc_id(1, "_register_player_on_server", username)

	# welcome message
	#var text_to_display = "Welcome to the lobby."
	multiplayer_menu.get_node("waiting_conn_pan").visible = false
	#multiplayer_menu.insert_message(text_to_display)
	
func _local_on_connected_fail():
	multiplayer.multiplayer_peer = null
	var text_to_display = "Could not connect to the server"
	multiplayer_menu.insert_message(text_to_display)
	
	
func _local_on_server_disconnected():
	#multiplayer_menu = null
	stop_multy()
	#GlobalSettings.multiplayer_data["players"].clear()
	print("Disconected from server")
	#server_disconnected.emit()
	multiplayer_menu.exit_multiplayer()

func stop_multy():
	multiplayer.multiplayer_peer = null

func try_connect():
	var ip_text = GlobalSet.settings["multiplayer"]["server_ip"]
	
	if ip_text.is_empty():
		var text_to_display = "The IP cannot be blank"
		multiplayer_menu.insert_message(text_to_display)
		#show_error_panel(text_to_display)
	elif not is_valid_ipv4(ip_text):
		var text_to_display = "Not a valid IPv4 address"
		#show_error_panel(text_to_display)
		multiplayer_menu.insert_message(text_to_display)
	else:
		join_game()


func join_game(address = ""):
	if address.is_empty():
		ADDRESS = GlobalSet.settings["multiplayer"]["server_ip"]
		PORT = GlobalSet.settings["multiplayer"]["port"]
	
	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(ADDRESS, PORT)
	
	if error:
		var text_to_display = "Could not connect to the server."
		multiplayer_menu.insert_message(text_to_display)
		return error
	
	multiplayer.multiplayer_peer = peer


func is_valid_ipv4(ip: String) -> bool:
	var ipv4_regex = RegEx.create_from_string(r"^(\d{1,3}\.){3}\d{1,3}$")
	
	if not ipv4_regex.search(ip):
		return false  # Doesn't match basic format

	var parts = ip.split(".")
	for part in parts:
		var num = part.to_int()
		if num < 0 or num > 255:  # Ensure each octet is within range
			return false

	return true  # Valid IPv4 address


# runs only on server, ignored here
@rpc("any_peer", "call_remote", "reliable")
func propagate_user_message(message: String, room_id= null):
	pass


@rpc("authority", "call_remote", "reliable")
func receive_chat_message(message: String):
	multiplayer_menu.insert_message(message)

# runs only on the server
@rpc("any_peer", "call_remote", "reliable")
func _register_player_on_server(new_player_info):
	pass
	
