extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	populate_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func populate_settings():
	var gameplay = $TabContainer/Gameplay/GridContainer
	var multiplayer = $TabContainer/Multiplayer/GridContainer
	gameplay.get_node("animation_btn").selected = gameplay.get_node("animation_btn").get_item_index(int(GlobalSet.settings["animation"]))
	gameplay.get_node("movement_btn").selected = gameplay.get_node("movement_btn").get_item_index(int(GlobalSet.settings["movement_highlight"]))
	gameplay.get_node("audio_btn").selected = gameplay.get_node("audio_btn").get_item_index(int(GlobalSet.settings["audio"]))
	multiplayer.get_node("username_lnd").text = GlobalSet.settings["multiplayer"]["username"]
	multiplayer.get_node("server_ip_lnd").text = GlobalSet.settings["multiplayer"]["server_ip"]


func _on_animation_btn_item_selected(index: int) -> void:
	GlobalSet.settings["animation"] = $TabContainer/Gameplay/GridContainer/animation_btn.get_item_id(index)
	SettingsLoad.save_settings()


func _on_movement_btn_item_selected(index: int) -> void:
	GlobalSet.settings["movement_highlight"] = $TabContainer/Gameplay/GridContainer/movement_btn.get_item_id(index)
	SettingsLoad.save_settings()


func _on_username_lnd_focus_exited() -> void:
	save_user_ip()


func _on_server_ip_lnd_focus_exited() -> void:
	save_user_ip()

func save_user_ip():
	var user_v = $TabContainer/Multiplayer/GridContainer/username_lnd.text
	var ip_v = $TabContainer/Multiplayer/GridContainer/server_ip_lnd.text
	
	GlobalSet.settings["multiplayer"]["username"] = user_v
	GlobalSet.settings["multiplayer"]["server_ip"] = ip_v
	SettingsLoad.save_settings()
	


func _on_audio_btn_item_selected(index: int) -> void:
	var root = get_tree().root

	GlobalSet.settings["audio"] = $TabContainer/Gameplay/GridContainer/audio_btn.get_item_id(index)
	SettingsLoad.save_settings()
	
	if GlobalSet.settings["audio"] == 1:
		root.get_node_or_null("BackgroundMusic").play()
	else:
		root.get_node_or_null("BackgroundMusic").stop()
