extends Panel

const ScenarioEditor := preload("res://menus/scenarios/scenario_editor.gd")

var _list: ItemList
var _empty_lbl: Label
var _preview_layer: CanvasLayer
var _preview_title: Label
var _preview_desc: RichTextLabel
var _preview_meta: Label
var _preview_board: BoardPreview
var _preview_board_wrap: CenterContainer
var _copy_btn: Button
var _pvp_btn: Button
var _pvai_btn: Button
var _paste_layer: CanvasLayer
var _paste_edit: TextEdit
var _paste_status: Label
var _confirm: ConfirmationDialog
var _editor: CanvasLayer
var _selected_id: String = ""
var _pending_delete_id: String = ""


func _ready() -> void:
	_build_list_ui()
	_build_preview()
	_build_paste()
	_build_confirm()
	_editor = ScenarioEditor.new()
	add_child(_editor)
	_editor.saved.connect(_on_editor_saved)
	_editor.cancelled.connect(func(): _editor.close())
	visibility_changed.connect(_on_visibility_changed)
	_refresh_list()


func close_overlays_if_open() -> bool:
	if _editor and _editor.visible:
		_editor.close()
		return true
	if _paste_layer and _paste_layer.visible:
		_paste_layer.visible = false
		return true
	if _preview_layer and _preview_layer.visible:
		_hide_preview()
		return true
	return false


func _on_visibility_changed() -> void:
	if visible:
		_refresh_list()
	else:
		close_overlays_if_open()


func _build_list_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	margin.grow_vertical = Control.GROW_DIRECTION_BOTH
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Scenarios"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	_empty_lbl = Label.new()
	_empty_lbl.text = "No scenarios yet. Create one, or paste a code."
	_empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_empty_lbl)

	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_clicked.connect(_on_item_clicked)
	vbox.add_child(_list)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var new_btn := Button.new()
	new_btn.text = "New"
	new_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_btn.custom_minimum_size = Vector2(0, 44)
	new_btn.pressed.connect(_on_new)
	row.add_child(new_btn)
	var paste_btn := Button.new()
	paste_btn.text = "Paste code"
	paste_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paste_btn.custom_minimum_size = Vector2(0, 44)
	paste_btn.pressed.connect(_show_paste)
	row.add_child(paste_btn)
	vbox.add_child(row)


func _build_preview() -> void:
	_preview_layer = CanvasLayer.new()
	_preview_layer.layer = 25
	_preview_layer.visible = false
	add_child(_preview_layer)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	backdrop.grow_vertical = Control.GROW_DIRECTION_BOTH
	backdrop.color = Color(0, 0, 0, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_preview_layer.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_layer.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(620, 0)
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_preview_title = Label.new()
	_preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(_preview_title)

	_preview_board_wrap = CenterContainer.new()
	_preview_board_wrap.custom_minimum_size = Vector2(0, 176)
	vbox.add_child(_preview_board_wrap)
	_preview_board = BoardPreview.new()
	_preview_board_wrap.add_child(_preview_board)

	_preview_meta = Label.new()
	_preview_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_preview_meta)

	_preview_desc = RichTextLabel.new()
	_preview_desc.bbcode_enabled = false
	_preview_desc.fit_content = true
	_preview_desc.custom_minimum_size = Vector2(560, 48)
	_preview_desc.scroll_active = true
	vbox.add_child(_preview_desc)

	var play_row := HBoxContainer.new()
	play_row.alignment = BoxContainer.ALIGNMENT_CENTER
	play_row.add_theme_constant_override("separation", 12)
	_pvp_btn = Button.new()
	_pvp_btn.text = "Play vs Player"
	_pvp_btn.custom_minimum_size = Vector2(180, 42)
	_pvp_btn.pressed.connect(_play.bind(true))
	play_row.add_child(_pvp_btn)
	_pvai_btn = Button.new()
	_pvai_btn.text = "Play vs AI"
	_pvai_btn.custom_minimum_size = Vector2(180, 42)
	_pvai_btn.pressed.connect(_play.bind(false))
	play_row.add_child(_pvai_btn)
	vbox.add_child(play_row)

	var util_row := HBoxContainer.new()
	util_row.alignment = BoxContainer.ALIGNMENT_CENTER
	util_row.add_theme_constant_override("separation", 10)
	var edit_btn := Button.new()
	edit_btn.text = "Edit"
	edit_btn.custom_minimum_size = Vector2(110, 36)
	edit_btn.pressed.connect(_on_edit)
	util_row.add_child(edit_btn)
	_copy_btn = Button.new()
	_copy_btn.text = "Copy code"
	_copy_btn.custom_minimum_size = Vector2(120, 36)
	_copy_btn.pressed.connect(_on_copy)
	util_row.add_child(_copy_btn)
	var del_btn := Button.new()
	del_btn.text = "Delete"
	del_btn.custom_minimum_size = Vector2(110, 36)
	del_btn.pressed.connect(_on_delete)
	util_row.add_child(del_btn)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(110, 36)
	close_btn.pressed.connect(_hide_preview)
	util_row.add_child(close_btn)
	vbox.add_child(util_row)


func _build_paste() -> void:
	_paste_layer = CanvasLayer.new()
	_paste_layer.layer = 30
	_paste_layer.visible = false
	add_child(_paste_layer)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	backdrop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	backdrop.grow_vertical = Control.GROW_DIRECTION_BOTH
	backdrop.color = Color(0, 0, 0, 0.92)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_paste_layer.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center.grow_vertical = Control.GROW_DIRECTION_BOTH
	_paste_layer.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(520, 0)
	center.add_child(card)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	var title := Label.new()
	title.text = "Paste scenario code"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	_paste_edit = TextEdit.new()
	_paste_edit.custom_minimum_size = Vector2(480, 90)
	_paste_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	vbox.add_child(_paste_edit)
	_paste_status = Label.new()
	_paste_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_paste_status)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var import_btn := Button.new()
	import_btn.text = "Import"
	import_btn.custom_minimum_size = Vector2(140, 40)
	import_btn.pressed.connect(_on_import)
	row.add_child(import_btn)
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(140, 40)
	cancel_btn.pressed.connect(func(): _paste_layer.visible = false)
	row.add_child(cancel_btn)
	vbox.add_child(row)


func _build_confirm() -> void:
	_confirm = ConfirmationDialog.new()
	_confirm.title = "Delete scenario"
	_confirm.dialog_text = "Delete this scenario?"
	_confirm.confirmed.connect(_on_delete_confirmed)
	add_child(_confirm)


func _refresh_list() -> void:
	_list.clear()
	for s in ScenarioLibrary.scenarios:
		var idx := _list.add_item(str(s.get("title", "Untitled")))
		_list.set_item_metadata(idx, str(s.get("id", "")))
	_empty_lbl.visible = ScenarioLibrary.scenarios.is_empty()
	_list.visible = not ScenarioLibrary.scenarios.is_empty()


func _on_item_clicked(index: int, _at: Vector2, mouse_button: int) -> void:
	if mouse_button != MOUSE_BUTTON_LEFT:
		return
	_open_preview(str(_list.get_item_metadata(index)))


func _open_preview(id: String) -> void:
	var data := ScenarioLibrary.get_by_id(id)
	if data.is_empty():
		return
	_selected_id = id
	_preview_title.text = str(data.get("title", "Untitled"))
	var check := ScenarioCodec.validate(data)
	if check["ok"]:
		_preview_meta.text = ScenarioCodec.summary_line(data)
		_preview_meta.modulate = Color.WHITE
	else:
		_preview_meta.text = str(check["error"])
		_preview_meta.modulate = Color(1.0, 0.7, 0.45)
	_pvp_btn.disabled = not check["ok"]
	_pvai_btn.disabled = not check["ok"]
	var desc := str(data.get("description", "")).strip_edges()
	_preview_desc.text = desc if desc != "" else "(No description)"
	_preview_board.configure(
		ScenarioCodec.city_size_of(data),
		ScenarioCodec.pawns_for_board(data),
		Vector2(280, 168),
		false
	)
	_copy_btn.text = "Copy code"
	_preview_layer.visible = true


func _hide_preview() -> void:
	_preview_layer.visible = false


func _on_new() -> void:
	_selected_id = ""
	_hide_preview()
	_editor.open(ScenarioCodec.make_blank())


func _on_edit() -> void:
	var data := ScenarioLibrary.get_by_id(_selected_id)
	if data.is_empty():
		return
	_hide_preview()
	_editor.open(data)


func _on_editor_saved(data: Dictionary) -> void:
	var saved: Dictionary = ScenarioLibrary.upsert(data)
	_editor.close()
	_refresh_list()
	_open_preview(str(saved["id"]))


func _on_copy() -> void:
	var data := ScenarioLibrary.get_by_id(_selected_id)
	if data.is_empty():
		return
	DisplayServer.clipboard_set(ScenarioCodec.encode(data))
	_copy_btn.text = "Copied"
	get_tree().create_timer(1.4).timeout.connect(func():
		if is_instance_valid(_copy_btn):
			_copy_btn.text = "Copy code"
	)


func _on_delete() -> void:
	_pending_delete_id = _selected_id
	var data := ScenarioLibrary.get_by_id(_selected_id)
	var title := str(data.get("title", "this scenario"))
	_confirm.dialog_text = "Delete \"%s\"?" % title
	_confirm.popup_centered()


func _on_delete_confirmed() -> void:
	if _pending_delete_id == "":
		return
	ScenarioLibrary.remove(_pending_delete_id)
	_pending_delete_id = ""
	_selected_id = ""
	_hide_preview()
	_refresh_list()


func _show_paste() -> void:
	_paste_edit.text = DisplayServer.clipboard_get().strip_edges()
	_paste_status.text = ""
	_paste_layer.visible = true


func _on_import() -> void:
	var result := ScenarioLibrary.import_code(_paste_edit.text)
	if not result["ok"]:
		_paste_status.text = str(result["error"])
		_paste_status.modulate = Color(1.0, 0.6, 0.45)
		return
	_paste_layer.visible = false
	_refresh_list()
	_open_preview(str(result["data"]["id"]))


func _play(pvp: bool) -> void:
	var data := ScenarioLibrary.get_by_id(_selected_id)
	if data.is_empty():
		return
	var check := ScenarioCodec.validate(data)
	if not check["ok"]:
		return
	var battle := ScenarioCodec.to_battle(check["data"])
	GlobalSet.load_saved_continue = false
	GlobalSet.skip_epic_opener = false
	GlobalSet.current_battle = battle
	GlobalSet.current_campaign_id = ""
	GlobalSet.settings["game_type"] = 0 if pvp else 1
	GlobalSet.settings["ai_lvl"] = int(check["data"]["ai_lvl"])
	GlobalSet.match_cosmetics = null
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")
