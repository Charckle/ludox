extends VBoxContainer

@onready var main_menu = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ContinueGame.check_continue_exists():
		$continue_btn.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_btn_pressed() -> void:
	main_menu.hide_all_oth_containers()
	main_menu.get_node("othr_containers").get_node("new_game_pan").visible = true


func _on_continue_btn_pressed() -> void:
	ContinueGame.load_continue()
	GlobalSet.load_saved_continue = true
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")
