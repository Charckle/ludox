extends VBoxContainer

@onready var main_menu = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_btn_pressed() -> void:
	get_tree().quit()



func _on_settings_btn_pressed() -> void:
	main_menu.hide_all_oth_containers()
	main_menu.get_node("othr_containers").get_node("settings_pan").visible = true


func _on_game_rules_btn_pressed() -> void:
	main_menu.hide_all_oth_containers()
	main_menu.get_node("othr_containers").get_node("rule_book").visible = true
