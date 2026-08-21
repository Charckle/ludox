extends Panel

# Set to false when you're done testing campaign flow.
const SHOW_DEBUG_WIN := true

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
	if GlobalSet.current_battle != null:
		$undo_btn.visible = false
		$ai_difficulty_btn.visible = false
	if SHOW_DEBUG_WIN and GlobalSet.current_battle != null:
		_build_debug_win_btn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	is_visible = !is_visible
	
	if is_visible:
		pass
	
	if city.unit_moving or GlobalSet.current_battle != null:
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


func toggle_menu() -> void:
	toggle_console()
	if city:
		city.multi_play_menu_open = is_visible


func _on_texture_button_pressed() -> void:
	toggle_menu()


func _on_main_menu_btn_pressed() -> void:
	GlobalSet.current_battle = null
	GlobalSet.match_cosmetics = null
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_rematch_btn_pressed() -> void:
	# Keep GlobalSet.match_cosmetics so random faction/color stays the same.
	get_tree().reload_current_scene()


func _on_ai_difficulty_btn_item_selected(index: int) -> void:
	GlobalSet.settings["ai_lvl"] = $ai_difficulty_btn.selected


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
	city.set_winner(2)
	city.lvl_.show_info_pan("You won the day!\n(Debug win)")
