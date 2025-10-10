extends PanelContainer

@onready var multiplayer_menu = get_parent()
var multiplayer_s = null #multiplayer_menu.multiplayer_s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func recreate_room_list(room_data):
	var room_cont = $top_cont/room_cont/rooms_list
	for child in room_cont.get_children():
		child.queue_free()
	
	for room_id in room_data:
		#var room_id = room_data["room_id"]
		var room_name = room_data[room_id]["room_name"]
		var room_players = len(room_data[room_id]["players"])
		var btn := Button.new()
		btn.text = "%s room (%s)" % [room_name, room_players]
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(func(): multiplayer_s.rooms_obj.rpc_id(1, "join_room_request", room_id))
		room_cont.add_child(btn)
