extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_all_oth_containers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_all_oth_containers():
	for child in $othr_containers.get_children():
		child.visible = false
