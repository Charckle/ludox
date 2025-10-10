extends Node

@onready var m_m = get_parent()
var multiplayer_menu = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# runs only on server, ignored here
@rpc("any_peer", "call_remote", "reliable")
func create_room():
	pass


@rpc("authority", "call_remote", "reliable")
func move_to_room(room_id, room_name):
	m_m.room_id = room_id
	multiplayer_menu.show_room(room_name)


@rpc("authority", "call_remote", "reliable")
func update_room_list(room_data):
	multiplayer_menu.main_container.recreate_room_list(room_data)

@rpc("any_peer", "call_remote", "reliable")
func join_room_request(room_id):
	pass
