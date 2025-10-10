extends Node2D

var MultiplayerScene = preload("res://multiplayer/main_multiplayer/main_multiplayer.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_all_oth_containers()
	
	if get_tree().root.get_node("Main-multiplayer") == null:
		var multiplyer_s = MultiplayerScene.instantiate()
		#get_tree().root.add_child(multiplyer_s)
		get_tree().root.call_deferred("add_child", multiplyer_s)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_all_oth_containers():
	for child in $othr_containers.get_children():
		child.visible = false
