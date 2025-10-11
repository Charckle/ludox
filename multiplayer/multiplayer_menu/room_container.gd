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
	print("kurac")
	multiplayer_s.rooms_obj.rpc_id(1, "leave_room_request", multiplayer_s.room_id)
