extends Panel

const DOT_SIZE := Vector2(20, 20)
const MIN_DOT_SEPARATION := 36.0
const MAP_SLOT := Vector2(360, 224)
const DEFAULT_MAP := preload("res://sprites/images/europe_map.png")

var current_campaign: CampaignData = null
var selected_battle: BattleData = null

var dots_root: Control
var modal_layer: CanvasLayer
var desc_title: Label
var desc_label: RichTextLabel
var start_btn: Button
var restart_btn: Button


func _ready() -> void:
	_build_dots_root()
	_build_battle_modal()
	_apply_map()
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if not visible:
		_hide_desc()
	elif current_campaign != null:
		_refresh_dots()


func _on_gallic_btn_pressed() -> void:
	show_campaign("gallic_wars")


func _on_greco_persian_btn_pressed() -> void:
	show_campaign("greco_persian_wars")


func _on_punic_btn_pressed() -> void:
	show_campaign("punic_wars")


func _on_civil_war_btn_pressed() -> void:
	show_campaign("civil_war")


func show_campaign(camp_id: String) -> void:
	current_campaign = Campaigns.get_by_id(camp_id)
	_apply_map()
	_hide_desc()
	_refresh_dots()


func _apply_map() -> void:
	var spr: Sprite2D = $map
	var tex: Texture2D = DEFAULT_MAP
	if current_campaign != null and current_campaign.map_texture != null:
		tex = current_campaign.map_texture
	spr.texture = tex
	var tex_size := tex.get_size()
	var s := minf(MAP_SLOT.x / tex_size.x, MAP_SLOT.y / tex_size.y)
	spr.scale = Vector2(s, s)
	spr.position = Vector2(size.x * 0.5 if size.x > 0.0 else 192.0, 120.0)


func _build_dots_root() -> void:
	dots_root = Control.new()
	dots_root.name = "dots_root"
	dots_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dots_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	dots_root.z_index = 1
	add_child(dots_root)


func _map_uv_to_panel(uv: Vector2) -> Vector2:
	var spr: Sprite2D = $map
	if spr.texture == null:
		return Vector2.ZERO
	var displayed := spr.texture.get_size() * spr.scale
	var top_left := spr.position - displayed * 0.5
	return top_left + Vector2(uv.x * displayed.x, uv.y * displayed.y)


func _spread_dot_centers(centers: Array) -> Array:
	var spr: Sprite2D = $map
	if spr.texture == null or centers.is_empty():
		return centers
	var displayed := spr.texture.get_size() * spr.scale
	var top_left := spr.position - displayed * 0.5
	var margin := DOT_SIZE * 0.5
	var min_c := top_left + margin
	var max_c := top_left + displayed - margin
	var pts: Array = centers.duplicate()
	for _n in 10:
		var moved := false
		for i in pts.size():
			for j in range(i + 1, pts.size()):
				var delta: Vector2 = pts[j] - pts[i]
				var dist := delta.length()
				if dist >= MIN_DOT_SEPARATION:
					continue
				moved = true
				var n := Vector2.RIGHT if dist < 0.01 else delta.normalized()
				var push := (MIN_DOT_SEPARATION - dist) * 0.5
				pts[i] = (pts[i] - n * push).clamp(min_c, max_c)
				pts[j] = (pts[j] + n * push).clamp(min_c, max_c)
		if not moved:
			break
	return pts


func _refresh_dots() -> void:
	for c in dots_root.get_children():
		c.queue_free()
	if current_campaign == null:
		return

	var centers: Array = []
	for b in current_campaign.battles:
		centers.append(_map_uv_to_panel(b.map_position))
	centers = _spread_dot_centers(centers)

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
		dot.position = centers[i] - DOT_SIZE / 2.0
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
	_update_modal_buttons()
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
	card.custom_minimum_size = Vector2(560, 0)
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
	desc_label.custom_minimum_size = Vector2(512, 160)
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

	start_btn = Button.new()
	start_btn.text = "Start Battle"
	start_btn.custom_minimum_size = Vector2(160, 44)
	start_btn.pressed.connect(_on_start_pressed)
	btn_row.add_child(start_btn)

	restart_btn = Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size = Vector2(160, 44)
	restart_btn.visible = false
	restart_btn.pressed.connect(_on_restart_pressed)
	btn_row.add_child(restart_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(160, 44)
	close_btn.pressed.connect(_hide_desc)
	btn_row.add_child(close_btn)


func close_battle_modal_if_open() -> bool:
	if modal_layer and modal_layer.visible:
		_hide_desc()
		return true
	return false


func _hide_desc() -> void:
	if modal_layer:
		modal_layer.visible = false


func _update_modal_buttons() -> void:
	var in_progress := current_campaign != null and selected_battle != null \
		and ContinueGame.is_continue_for(current_campaign.id, selected_battle.id)
	if in_progress:
		start_btn.text = "Continue Battle"
		restart_btn.visible = true
	else:
		start_btn.text = "Start Battle"
		restart_btn.visible = false


func _launch_battle(resume: bool) -> void:
	if selected_battle == null or current_campaign == null:
		return
	if resume:
		if not ContinueGame.apply_continue_to_global():
			_update_modal_buttons()
			return
	else:
		GlobalSet.load_saved_continue = false
		GlobalSet.skip_epic_opener = false
		GlobalSet.current_battle = selected_battle
		GlobalSet.current_campaign_id = current_campaign.id
		GlobalSet.match_cosmetics = null
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")


func _on_start_pressed() -> void:
	var resume := current_campaign != null and selected_battle != null \
		and ContinueGame.is_continue_for(current_campaign.id, selected_battle.id)
	_launch_battle(resume)


func _on_restart_pressed() -> void:
	ContinueGame.delete_continue()
	_launch_battle(false)
