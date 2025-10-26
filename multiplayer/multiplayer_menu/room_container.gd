extends Panel

@onready var mult_menu = get_parent()
var multiplayer_s = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_leave_btn_pressed() -> void:
	multiplayer_s.rooms_obj.rpc_id(1, "leave_room_request", multiplayer_s.room_id)

func update_room_data(room_data):
	var cont_playr = $player_v_cont/player_cont
	for child in cont_playr.get_children():
		child.queue_free()
	
	var cont_spect = $player_v_cont/spectator_cont
	for child in cont_spect.get_children():
		child.queue_free()
	
	
	for player_data in room_data["players_data"]:
		var player_name = player_data["username"]
		var is_playing = player_data["is_playing"]
		var label = Label.new()
		label.text = player_name
		
		if is_playing == true:
			cont_playr.add_child(label)
		else:
			cont_spect.add_child(label)
	
	if room_data["can_start"] == true and room_data["room_id"] == multiplayer_s.my_peer_id:
		$start_btn.disabled = false
	else:
		$start_btn.disabled = true


func _on_start_btn_pressed() -> void:
	multiplayer_s.rooms_obj.rpc_id(1, "start_game", multiplayer_s.room_id)
