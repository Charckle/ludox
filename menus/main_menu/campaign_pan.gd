extends Panel

const DOT_SIZE := Vector2(20, 20)

var current_campaign: CampaignData = null
var selected_battle: BattleData = null

var dots_root: Control
var modal_layer: CanvasLayer
var desc_title: Label
var desc_label: RichTextLabel


func _ready() -> void:
	_build_dots_root()
	_build_battle_modal()
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if not visible:
		_hide_desc()
	elif current_campaign != null:
		_refresh_dots()


func _on_galic_btn_pressed() -> void:
	show_campaign("gallic_wars")


func show_campaign(camp_id: String) -> void:
	current_campaign = Campaigns.get_by_id(camp_id)
	_hide_desc()
	_refresh_dots()


func _build_dots_root() -> void:
	dots_root = Control.new()
	dots_root.name = "dots_root"
	dots_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dots_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	dots_root.z_index = 1
	add_child(dots_root)


func _refresh_dots() -> void:
	for c in dots_root.get_children():
		c.queue_free()
	if current_campaign == null:
		return

	for i in current_campaign.battles.size():
		var b = current_campaign.battles[i]
		var won: bool = CampaignProgress.is_won(current_campaign.id, b.id)
		var unlocked: bool = CampaignProgress.is_unlocked(current_campaign, i)

		var dot_color: Color
		var clickable := true
		var is_next := false
		if won:
			dot_color = Color.GOLD
		elif unlocked:
			dot_color = Color.WHITE
			is_next = true
		else:
			dot_color = Color(0.35, 0.35, 0.35)
			clickable = false

		var dot := Control.new()
		dot.position = b.map_position - DOT_SIZE / 2.0
		dot.custom_minimum_size = DOT_SIZE
		dot.size = DOT_SIZE

		if clickable:
			var visual := Control.new()
			visual.custom_minimum_size = DOT_SIZE
			visual.size = DOT_SIZE
			visual.pivot_offset = DOT_SIZE / 2.0
			visual.position = Vector2.ZERO
			dot.add_child(visual)

			var rect := ColorRect.new()
			rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			rect.anchor_right = 1.0
			rect.anchor_bottom = 1.0
			rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
			rect.grow_vertical = Control.GROW_DIRECTION_BOTH
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect.color = dot_color
			visual.add_child(rect)

			var hit := Button.new()
			hit.flat = true
			hit.set_anchors_preset(Control.PRESET_FULL_RECT)
			hit.anchor_right = 1.0
			hit.anchor_bottom = 1.0
			hit.grow_horizontal = Control.GROW_DIRECTION_BOTH
			hit.grow_vertical = Control.GROW_DIRECTION_BOTH
			hit.pressed.connect(_on_dot_pressed.bind(b))
			dot.add_child(hit)

			if is_next:
				_animate_next_dot(visual)
		else:
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dot.add_child(_make_circle_dot(dot_color))

		dots_root.add_child(dot)


func _make_circle_dot(color: Color) -> Panel:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = color
	var radius := int(DOT_SIZE.x / 2)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _animate_next_dot(dot: Control) -> void:
	var rot_tween := dot.create_tween()
	rot_tween.set_loops()
	rot_tween.tween_property(dot, "rotation", TAU, 6.0).from(0.0)

	var pulse_tween := dot.create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(dot, "scale", Vector2(1.2, 1.2), 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(dot, "scale", Vector2(0.8, 0.8), 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_dot_pressed(battle) -> void:
	selected_battle = battle
	desc_title.text = battle.title
	desc_label.text = battle.description
	modal_layer.visible = true


func _build_battle_modal() -> void:
	modal_layer = CanvasLayer.new()
	modal_layer.name = "battle_modal"
	modal_layer.layer = 20
	modal_layer.visible = false
	add_child(modal_layer)

	var backdrop := ColorRect.new()
	backdrop.name = "backdrop"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	backdrop.grow_vertical = Control.GROW_DIRECTION_BOTH
	backdrop.color = Color(0, 0, 0, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_layer.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(440, 0)
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	desc_title = Label.new()
	desc_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(desc_title)

	desc_label = RichTextLabel.new()
	desc_label.bbcode_enabled = false
	desc_label.custom_minimum_size = Vector2(392, 160)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.scroll_active = true
	vbox.add_child(desc_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	var start_btn := Button.new()
	start_btn.text = "Start Battle"
	start_btn.custom_minimum_size = Vector2(160, 44)
	start_btn.pressed.connect(_on_start_pressed)
	btn_row.add_child(start_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(160, 44)
	close_btn.pressed.connect(_hide_desc)
	btn_row.add_child(close_btn)


func _hide_desc() -> void:
	if modal_layer:
		modal_layer.visible = false


func _on_start_pressed() -> void:
	if selected_battle == null:
		return
	GlobalSet.current_battle = selected_battle
	GlobalSet.current_campaign_id = current_campaign.id
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")
