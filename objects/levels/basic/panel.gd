extends Panel

var city = null
@onready var tween = create_tween()

var is_visible = false
var hidden_x := 0.0  # Adjust based on your panel height
var visible_x := 0.0    # Y position when shown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get panel height dynamically
	var panel_lenght = self.size.x
	hidden_x = self.position.x 
	
	visible_x = - 200# panel_lenght # In case it's already anchored where you want it

	#self.position.x = hidden_x  # Start hidden


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# set ai lvl
	if GlobalSet.settings["ai_lvl"] != $ai_difficulty_btn.selected:
		$ai_difficulty_btn.selected = GlobalSet.settings["ai_lvl"]


func toggle_console():
	is_visible = !is_visible
	
	if is_visible:
		pass
	
	if city.unit_moving:
		$undo_btn.disabled = true
	else:
		$undo_btn.disabled = false
	tween.kill()  # Stop any ongoing tween before starting a new one

	tween = create_tween()
	tween.tween_property(
		self, "position:x",
		visible_x if is_visible else hidden_x,
		0.50
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_texture_button_pressed() -> void:
	toggle_console()
	city.multi_play_menu_open = !city.multi_play_menu_open


func _on_main_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_rematch_btn_pressed() -> void:
	get_tree().reload_current_scene()


func _on_ai_difficulty_btn_item_selected(index: int) -> void:
	GlobalSet.settings["ai_lvl"] = $ai_difficulty_btn.selected


func _on_rule_book_btn_pressed() -> void:
	$rule_book.visible = true
