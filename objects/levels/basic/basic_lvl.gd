extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasModulate/Panel.city = $City


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_undo_btn_pressed() -> void:
	$City.undo_move()
