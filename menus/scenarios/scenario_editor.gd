extends CanvasLayer

signal saved(data: Dictionary)
signal cancelled

var _data: Dictionary = {}
var _forces: Array = []
var _selected_force: int = -1
var _place_dux: bool = false
var _erase: bool = false

var _title_edit: LineEdit
var _desc_edit: TextEdit
var _size_btn: OptionButton
var _rules_btn: OptionButton
var _ai_btn: OptionButton
var _board: BoardPreview
var _you_list: VBoxContainer
var _opp_list: VBoxContainer
var _you_faction: OptionButton
var _opp_faction: OptionButton
var _status: Label
var _dux_btn: Button
var _paint_btn: Button
var _erase_btn: Button
var _tool_group: ButtonGroup
var _board_wrap: CenterContainer


func _ready() -> void:
	layer = 40
	visible = false
	_build()


func open(data: Dictionary) -> void:
	_data = data.duplicate(true)
	if _data.is_empty():
		_data = ScenarioCodec.make_blank()
	_data = ScenarioCodec.sanitize(_data)
	_erase = false
	_place_dux = false
	if _paint_btn:
		_paint_btn.button_pressed = true
	if _dux_btn:
		_dux_btn.button_pressed = false
	_refresh_tool_styles()
	_rebuild_forces_from_pawns()
	_sync_fields()
	_refresh_board()
	_refresh_force_lists()
	_update_status()
	visible = true
	_refresh_board.call_deferred()


func close() -> void:
	visible = false


func _build() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	backdrop.grow_vertical = Control.GROW_DIRECTION_BOTH
	backdrop.color = Color(0.04, 0.03, 0.02, 0.96)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.grow_horizontal = Control.GROW_DIRECTION_BOTH
	root.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.add_theme_constant_override("margin_left", 12)
	root.add_theme_constant_override("margin_right", 12)
	root.add_theme_constant_override("margin_top", 8)
	root.add_theme_constant_override("margin_bottom", 8)
	add_child(root)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	root.add_child(vbox)

	vbox.add_child(_build_topbar())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	vbox.add_child(body)

	body.add_child(_build_forces_col())

	_board_wrap = CenterContainer.new()
	_board_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_board_wrap)

	_board = BoardPreview.new()
	_board.editable = true
	_board.cell_clicked.connect(_on_cell_clicked)
	_board_wrap.add_child(_board)
	body.add_child(_build_desc_col())

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_status)


func _build_topbar() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	_title_edit = LineEdit.new()
	_title_edit.placeholder_text = "Title"
	_title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_edit.custom_minimum_size = Vector2(0, 36)
	row.add_child(_title_edit)

	_size_btn = OptionButton.new()
	_size_btn.custom_minimum_size = Vector2(90, 36)
	_size_btn.add_item("8x8", 0)
	_size_btn.add_item("12x8", 1)
	_size_btn.item_selected.connect(_on_size_changed)
	row.add_child(_size_btn)

	_rules_btn = OptionButton.new()
	_rules_btn.custom_minimum_size = Vector2(140, 36)
	_rules_btn.add_item("Classic", 0)
	_rules_btn.add_item("Classic PLUS", 1)
	_rules_btn.add_item("XXI", 2)
	row.add_child(_rules_btn)

	_ai_btn = OptionButton.new()
	_ai_btn.custom_minimum_size = Vector2(110, 36)
	_ai_btn.add_item("AI Easy", 0)
	_ai_btn.add_item("AI Normal", 1)
	_ai_btn.add_item("AI Hard", 2)
	_ai_btn.add_item("AI Caesar", 3)
	row.add_child(_ai_btn)

	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(80, 36)
	save_btn.pressed.connect(_on_save)
	row.add_child(save_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(80, 36)
	cancel_btn.pressed.connect(_on_cancel)
	row.add_child(cancel_btn)
	return row


func _build_forces_col() -> Control:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(200, 0)
	col.add_theme_constant_override("separation", 6)

	col.add_child(_make_header("You (bottom)"))
	var you_add := HBoxContainer.new()
	_you_faction = OptionButton.new()
	_you_faction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fill_factions(_you_faction)
	you_add.add_child(_you_faction)
	var you_add_btn := Button.new()
	you_add_btn.text = "Add"
	you_add_btn.pressed.connect(_on_add_force.bind(2, _you_faction))
	you_add.add_child(you_add_btn)
	col.add_child(you_add)
	var you_scroll := DragScroll.new()
	you_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_you_list = VBoxContainer.new()
	_you_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	you_scroll.add_child(_you_list)
	col.add_child(you_scroll)

	col.add_child(_make_header("Opponent (top)"))
	var opp_add := HBoxContainer.new()
	_opp_faction = OptionButton.new()
	_opp_faction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fill_factions(_opp_faction)
	opp_add.add_child(_opp_faction)
	var opp_add_btn := Button.new()
	opp_add_btn.text = "Add"
	opp_add_btn.pressed.connect(_on_add_force.bind(1, _opp_faction))
	opp_add.add_child(opp_add_btn)
	col.add_child(opp_add)
	var opp_scroll := DragScroll.new()
	opp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_opp_list = VBoxContainer.new()
	_opp_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opp_scroll.add_child(_opp_list)
	col.add_child(opp_scroll)

	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 6)
	var tool_group := ButtonGroup.new()
	_tool_group = tool_group
	_paint_btn = Button.new()
	_paint_btn.text = "Paint"
	_paint_btn.toggle_mode = true
	_paint_btn.button_group = tool_group
	_paint_btn.button_pressed = true
	_paint_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_paint_btn.pressed.connect(_on_paint_pressed)
	tools.add_child(_paint_btn)
	_erase_btn = Button.new()
	_erase_btn.text = "Erase"
	_erase_btn.toggle_mode = true
	_erase_btn.button_group = tool_group
	_erase_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_erase_btn.pressed.connect(_on_erase_pressed)
	tools.add_child(_erase_btn)
	col.add_child(tools)

	_dux_btn = Button.new()
	_dux_btn.text = "Place dux"
	_dux_btn.toggle_mode = true
	_dux_btn.toggled.connect(_on_dux_toggled)
	col.add_child(_dux_btn)
	_refresh_tool_styles()

	var hint := Label.new()
	hint.text = "Click the board to place. One dux per side."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	col.add_child(hint)
	return col


func _build_desc_col() -> Control:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(200, 0)
	col.add_child(_make_header("Description"))
	_desc_edit = TextEdit.new()
	_desc_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_desc_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	col.add_child(_desc_edit)
	return col


func _on_paint_pressed() -> void:
	_erase = false
	_refresh_tool_styles()


func _on_erase_pressed() -> void:
	_erase = true
	_refresh_tool_styles()


func _on_dux_toggled(on: bool) -> void:
	_place_dux = on
	_refresh_tool_styles()


func _refresh_tool_styles() -> void:
	if _paint_btn:
		_apply_tool_style(_paint_btn, not _erase)
	if _erase_btn:
		_apply_tool_style(_erase_btn, _erase)
	if _dux_btn:
		_apply_tool_style(_dux_btn, _place_dux)


func _apply_tool_style(btn: Button, selected: bool) -> void:
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(4)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	if selected:
		box.bg_color = Color(0.38, 0.30, 0.12)
		box.border_color = Color(0.92, 0.78, 0.32)
		box.set_border_width_all(3)
	else:
		box.bg_color = Color(0.14, 0.12, 0.10)
		box.border_color = Color(0.32, 0.28, 0.24)
		box.set_border_width_all(1)
	btn.add_theme_stylebox_override("normal", box)
	btn.add_theme_stylebox_override("hover", box)
	btn.add_theme_stylebox_override("pressed", box)
	btn.add_theme_stylebox_override("focus", box)
	var font_col := Color(0.98, 0.92, 0.70) if selected else Color(0.82, 0.80, 0.76)
	btn.add_theme_color_override("font_color", font_col)
	btn.add_theme_color_override("font_hover_color", font_col)
	btn.add_theme_color_override("font_pressed_color", font_col)
	btn.add_theme_color_override("font_focus_color", font_col)


func _make_header(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 16)
	return lbl


func _fill_factions(btn: OptionButton) -> void:
	btn.clear()
	for id in PawnCosmetics.faction_ids():
		btn.add_item(PawnCosmetics.faction_display_name(str(id)))
		btn.set_item_metadata(btn.item_count - 1, str(id))


func _rebuild_forces_from_pawns() -> void:
	_forces = []
	var seen := {}
	for p in _data.get("pawns", []):
		var key := "%d:%s" % [int(p["player"]), str(p["faction"])]
		if seen.has(key):
			continue
		seen[key] = true
		_forces.append({"player": int(p["player"]), "faction": str(p["faction"])})
	if _forces.is_empty():
		_forces = [
			{"player": 2, "faction": "roman"},
			{"player": 1, "faction": "gaul"},
		]
	_selected_force = 0 if _forces.size() else -1


func _sync_fields() -> void:
	_title_edit.text = str(_data.get("title", ""))
	_desc_edit.text = str(_data.get("description", ""))
	var w := int(_data["city_size"][0])
	_size_btn.select(1 if w >= 12 else 0)
	_rules_btn.select(int(_data.get("rules", 2)))
	_ai_btn.select(int(_data.get("ai_lvl", 1)))


func _read_fields() -> void:
	_data["title"] = _title_edit.text
	_data["description"] = _desc_edit.text
	_data["city_size"] = [12, 8] if _size_btn.selected == 1 else [8, 8]
	_data["rules"] = _rules_btn.selected
	_data["ai_lvl"] = _ai_btn.selected


func _on_size_changed(_index: int) -> void:
	_read_fields()
	var w := int(_data["city_size"][0])
	var kept: Array = []
	for p in _data.get("pawns", []):
		if int(p["pos"][0]) < w:
			kept.append(p)
	_data["pawns"] = kept
	_refresh_board()
	_update_status()


func _refresh_board() -> void:
	if _board == null:
		return
	var avail := Vector2(420, 340)
	if _board_wrap:
		var sz := _board_wrap.size
		if sz.x > 8.0 and sz.y > 8.0:
			avail = sz
	_board.configure(ScenarioCodec.city_size_of(_data), ScenarioCodec.pawns_for_board(_data), avail, true)


func _refresh_force_lists() -> void:
	_fill_force_list(_you_list, 2)
	_fill_force_list(_opp_list, 1)


func _fill_force_list(box: VBoxContainer, player: int) -> void:
	while box.get_child_count() > 0:
		var child := box.get_child(0)
		box.remove_child(child)
		child.queue_free()
	for i in _forces.size():
		var f: Dictionary = _forces[i]
		if int(f["player"]) != player:
			continue
		var row := HBoxContainer.new()
		var btn := Button.new()
		btn.text = PawnCosmetics.faction_display_name(str(f["faction"]))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.toggle_mode = true
		btn.set_meta("force_i", i)
		btn.pressed.connect(_select_force.bind(i))
		row.add_child(btn)
		var del := Button.new()
		del.text = "x"
		del.custom_minimum_size = Vector2(28, 0)
		del.pressed.connect(_remove_force.bind(i))
		row.add_child(del)
		box.add_child(row)
	_highlight_force_buttons()


func _highlight_force_buttons() -> void:
	_highlight_force_box(_you_list)
	_highlight_force_box(_opp_list)


func _highlight_force_box(box: VBoxContainer) -> void:
	if box == null:
		return
	for row in box.get_children():
		if row.get_child_count() == 0:
			continue
		var btn := row.get_child(0) as Button
		if btn == null:
			continue
		var i := int(btn.get_meta("force_i", -1))
		var selected := i == _selected_force
		btn.set_pressed_no_signal(selected)
		if i >= 0 and i < _forces.size():
			var faction := str(_forces[i]["faction"])
			var tint := PawnCosmetics.get_color(PawnCosmetics.color_for_faction(faction))
			btn.modulate = tint.lightened(0.35) if selected else Color.WHITE


func _select_force(index: int) -> void:
	if DragScroll.swallow_click:
		return
	_selected_force = index
	_erase = false
	_paint_btn.button_pressed = true
	_erase_btn.button_pressed = false
	_refresh_tool_styles()
	_highlight_force_buttons()


func _on_add_force(player: int, picker: OptionButton) -> void:
	if picker.selected < 0:
		return
	var faction := str(picker.get_item_metadata(picker.selected))
	if faction == "":
		return
	for i in _forces.size():
		var f: Dictionary = _forces[i]
		if int(f["player"]) == player and str(f["faction"]) == faction:
			_select_force(i)
			return
	_forces.append({"player": player, "faction": faction})
	_selected_force = _forces.size() - 1
	_erase = false
	_paint_btn.button_pressed = true
	_erase_btn.button_pressed = false
	_refresh_tool_styles()
	_refresh_force_lists()


func _remove_force(index: int) -> void:
	if DragScroll.swallow_click:
		return
	if index < 0 or index >= _forces.size():
		return
	var f: Dictionary = _forces[index]
	var player := int(f["player"])
	var faction := str(f["faction"])
	var kept: Array = []
	for p in _data.get("pawns", []):
		if int(p["player"]) == player and str(p["faction"]) == faction:
			continue
		kept.append(p)
	_data["pawns"] = kept
	_forces.remove_at(index)
	if _selected_force == index:
		_selected_force = 0 if _forces.size() else -1
	elif _selected_force > index:
		_selected_force -= 1
	_refresh_force_lists()
	_refresh_board()
	_update_status()


func _on_cell_clicked(pos: Vector2i) -> void:
	if _erase:
		_remove_pawn_at(pos)
		_refresh_board()
		_update_status()
		return
	if _selected_force < 0 or _selected_force >= _forces.size():
		_status.text = "Add and select a faction first."
		return
	var force: Dictionary = _forces[_selected_force]
	var player := int(force["player"])
	var faction := str(force["faction"])
	var existing = _pawn_at(pos)
	var become_dux := _place_dux
	if existing != null and bool(existing.get("dux", false)) and not _place_dux:
		become_dux = true
	if become_dux:
		_clear_dux(player)
	_remove_pawn_at(pos)
	_data["pawns"].append({
		"pos": [pos.x, pos.y],
		"player": player,
		"dux": become_dux,
		"faction": faction,
	})
	_refresh_board()
	_update_status()


func _pawn_at(pos: Vector2i):
	for p in _data.get("pawns", []):
		if int(p["pos"][0]) == pos.x and int(p["pos"][1]) == pos.y:
			return p
	return null


func _remove_pawn_at(pos: Vector2i) -> void:
	var kept: Array = []
	for p in _data.get("pawns", []):
		if int(p["pos"][0]) == pos.x and int(p["pos"][1]) == pos.y:
			continue
		kept.append(p)
	_data["pawns"] = kept


func _clear_dux(player: int) -> void:
	for p in _data.get("pawns", []):
		if int(p["player"]) == player:
			p["dux"] = false


func _update_status() -> void:
	var check := ScenarioCodec.validate(_data)
	if check["ok"]:
		_status.text = "Ready to save."
		_status.modulate = Color(0.7, 1.0, 0.7)
	else:
		_status.text = str(check["error"])
		_status.modulate = Color(1.0, 0.85, 0.55)


func _on_save() -> void:
	_read_fields()
	var check := ScenarioCodec.validate(_data)
	if not check["ok"]:
		_update_status()
		return
	saved.emit(check["data"])


func _on_cancel() -> void:
	cancelled.emit()
