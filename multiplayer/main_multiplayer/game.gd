extends Node

@onready var m_m = get_parent()
#var multiplayer_menu = null

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
	pass
