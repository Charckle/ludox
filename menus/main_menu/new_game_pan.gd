extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass # Replace with function body.




func populate_settings():
	$game_rules_btn.selected = int(GlobalSet.settings["game_rules"])
	$game_type_btn.selected = int(GlobalSet.settings["game_type"])
	
	if int(GlobalSet.settings["game_type"]) == 1:
		$ai_lvl_btn.visible = true
	else:
		$ai_lvl_btn.visible = false
	$ai_lvl_btn.selected = int(GlobalSet.settings["ai_lvl"])
	

func _on_start_g_btn_pressed() -> void:
	GlobalSet.settings["game_rules"] = $game_rules_btn.selected
	GlobalSet.settings["game_type"] = $game_type_btn.selected
	GlobalSet.settings["ai_lvl"] = $ai_lvl_btn.selected
	SettingsLoad.save_settings()
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")


func _on_game_type_btn_item_selected(index: int) -> void:
	if index == 1:
		$ai_lvl_btn.visible = true
	else:
		$ai_lvl_btn.visible = false
