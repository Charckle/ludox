extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	populate_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func populate_settings():
	$GridContainer/animation_btn.selected = $GridContainer/animation_btn.get_item_index(int(GlobalSet.settings["animation"]))
	$GridContainer/movement_btn.selected = $GridContainer/movement_btn.get_item_index(int(GlobalSet.settings["movement_highlight"]))

func _on_animation_btn_item_selected(index: int) -> void:
	GlobalSet.settings["animation"] = $GridContainer/animation_btn.get_item_id(index)
	SettingsLoad.save_settings()


func _on_movement_btn_item_selected(index: int) -> void:
	GlobalSet.settings["movement_highlight"] = $GridContainer/movement_btn.get_item_id(index)
	SettingsLoad.save_settings()
