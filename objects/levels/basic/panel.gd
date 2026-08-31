extends Panel

# Set to false when you're done testing campaign flow.
const SHOW_DEBUG_WIN := true

var city = null
var tween: Tween

var menu_open = false
var hidden_x := 0.0  # Adjust based on your panel height
var visible_x := 0.0    # Y position when shown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hidden_x = self.position.x
	visible_x = -200 # In case it's already anchored where you want it

	#self.position.x = hidden_x  # Start hidden
	var is_campaign := GlobalSet.current_battle != null \
		and str(GlobalSet.current_campaign_id) != ""
	var is_preset := GlobalSet.current_battle != null
	if is_campaign:
		$undo_btn.visible = false
		$ai_difficulty_btn.visible = false
		$campaign_menu_btn.visible = true
		$rematch_btn.offset_top = 152.0
		$rematch_btn.offset_bottom = 207.0
	elif is_preset:
		$ai_difficulty_btn.visible = false
	if SHOW_DEBUG_WIN and is_campaign:
		_build_debug_win_btn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GlobalSet.current_battle != null:
		return
	# set ai lvl
	if GlobalSet.settings["ai_lvl"] != $ai_difficulty_btn.selected:
		$ai_difficulty_btn.selected = GlobalSet.settings["ai_lvl"]


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if $rule_book.visible:
		$rule_book.visible = false
		get_viewport().set_input_as_handled()
		return
	toggle_menu()
	get_viewport().set_input_as_handled()


func toggle_console():
	menu_open = !menu_open
	
	if menu_open:
		pass
	
	if city.unit_moving or (GlobalSet.current_battle != null \
			and str(GlobalSet.current_campaign_id) != ""):
		$undo_btn.disabled = true
	else:
		$undo_btn.disabled = false
	if tween != null and tween.is_valid():
		tween.kill()

	tween = create_tween()
	tween.tween_property(
		self, "position:x",
		visible_x if menu_open else hidden_x,
		0.50
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func toggle_menu() -> void:
	toggle_console()
	if city:
		city.multi_play_menu_open = menu_open


func _on_texture_button_pressed() -> void:
	toggle_menu()


func _on_main_menu_btn_pressed() -> void:
	GlobalSet.current_battle = null
	GlobalSet.current_campaign_id = ""
	GlobalSet.match_cosmetics = null
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_campaign_menu_btn_pressed() -> void:
	GlobalSet.return_to_campaign_menu()
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_rematch_btn_pressed() -> void:
	# Keep GlobalSet.match_cosmetics so random faction/color stays the same.
	get_tree().reload_current_scene()


func _on_ai_difficulty_btn_item_selected(index: int) -> void:
	GlobalSet.settings["ai_lvl"] = index


func _on_rule_book_btn_pressed() -> void:
	$rule_book.visible = true


func _build_debug_win_btn() -> void:
	var btn := Button.new()
	btn.name = "debug_win_btn"
	btn.text = "Debug Win"
	btn.custom_minimum_size = Vector2(0, 50)
	btn.position = Vector2(72, 400)
	btn.size = Vector2(256, 55)
	btn.pressed.connect(_on_debug_win_pressed)
	add_child(btn)


func _on_debug_win_pressed() -> void:
	if GlobalSet.current_battle == null:
		return
	city.announce_winner(2, "(Debug win)")
