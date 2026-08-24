extends Panel

var _you_faction_btn: OptionButton
var _you_color_btn: OptionButton
var _opp_faction_btn: OptionButton
var _opp_color_btn: OptionButton
var _you_shield: TextureRect
var _you_insignia: TextureRect
var _opp_shield: TextureRect
var _opp_insignia: TextureRect
var _updating_ui := false


func _ready() -> void:
	_build_appearance_ui()
	populate_settings()


func populate_settings():
	var gameplay = $TabContainer/Gameplay/GridContainer
	var mp_grid = $TabContainer/Multiplayer/GridContainer
	gameplay.get_node("animation_btn").selected = gameplay.get_node("animation_btn").get_item_index(int(GlobalSet.settings["animation"]))
	gameplay.get_node("movement_btn").selected = gameplay.get_node("movement_btn").get_item_index(int(GlobalSet.settings["movement_highlight"]))
	gameplay.get_node("audio_btn").selected = gameplay.get_node("audio_btn").get_item_index(int(GlobalSet.settings["audio"]))
	gameplay.get_node("epic_btn").selected = gameplay.get_node("epic_btn").get_item_index(int(GlobalSet.settings.get("epic", 1)))
	mp_grid.get_node("username_lnd").text = GlobalSet.settings["multiplayer"]["username"]
	mp_grid.get_node("server_ip_lnd").text = GlobalSet.settings["multiplayer"]["server_ip"]
	_populate_cosmetics_ui()


func _build_appearance_ui() -> void:
	var root: VBoxContainer = $TabContainer/Appearance/appearance_root
	while root.get_child_count() > 0:
		var child := root.get_child(0)
		root.remove_child(child)
		child.free()

	var note := Label.new()
	note.text = "Used for local New Game (not campaigns). Random resolves when a match starts."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(note)

	var you_block := _make_side_block("You (bottom)", true)
	root.add_child(you_block)
	var opp_block := _make_side_block("Opponent (top)", false)
	root.add_child(opp_block)


func _make_side_block(title: String, is_you: bool) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var title_lbl := Label.new()
	title_lbl.text = title
	box.add_child(title_lbl)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(grid)

	var faction_lbl := Label.new()
	faction_lbl.text = "Faction"
	grid.add_child(faction_lbl)
	var faction_btn := OptionButton.new()
	faction_btn.custom_minimum_size = Vector2(0, 40)
	_fill_faction_options(faction_btn)
	grid.add_child(faction_btn)

	var color_lbl := Label.new()
	color_lbl.text = "Color"
	grid.add_child(color_lbl)
	var color_btn := OptionButton.new()
	color_btn.custom_minimum_size = Vector2(0, 40)
	_fill_color_options(color_btn)
	grid.add_child(color_btn)

	var preview := Control.new()
	preview.custom_minimum_size = Vector2(48, 48)
	row.add_child(preview)

	var outline := TextureRect.new()
	outline.name = "outline"
	outline.position = Vector2(2, 2)
	outline.size = Vector2(44, 44)
	outline.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	outline.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	outline.visible = false
	preview.add_child(outline)

	var shield := TextureRect.new()
	shield.name = "shield"
	shield.position = Vector2(4, 4)
	shield.size = Vector2(40, 40)
	shield.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shield.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.add_child(shield)

	var insignia := TextureRect.new()
	insignia.name = "insignia"
	insignia.position = Vector2(4, 4)
	insignia.size = Vector2(40, 40)
	insignia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	insignia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.add_child(insignia)

	if is_you:
		_you_faction_btn = faction_btn
		_you_color_btn = color_btn
		_you_shield = shield
		_you_insignia = insignia
		faction_btn.item_selected.connect(_on_you_cosmetics_changed)
		color_btn.item_selected.connect(_on_you_cosmetics_changed)
	else:
		_opp_faction_btn = faction_btn
		_opp_color_btn = color_btn
		_opp_shield = shield
		_opp_insignia = insignia
		faction_btn.item_selected.connect(_on_opp_cosmetics_changed)
		color_btn.item_selected.connect(_on_opp_cosmetics_changed)

	return box


func _fill_faction_options(btn: OptionButton) -> void:
	btn.clear()
	btn.add_item("Random", 0)
	btn.set_item_metadata(0, PawnCosmetics.RANDOM_ID)
	var i := 1
	for faction_id in PawnCosmetics.faction_ids():
		btn.add_item(PawnCosmetics.faction_display_name(faction_id), i)
		btn.set_item_metadata(i, faction_id)
		i += 1


func _fill_color_options(btn: OptionButton) -> void:
	btn.clear()
	btn.add_item("Random", 0)
	btn.set_item_metadata(0, PawnCosmetics.RANDOM_ID)
	var i := 1
	for color_id in PawnCosmetics.color_ids():
		btn.add_item(PawnCosmetics.color_display_name(color_id), i)
		btn.set_item_metadata(i, color_id)
		i += 1


func _populate_cosmetics_ui() -> void:
	_updating_ui = true
	var cosmetics: Dictionary = GlobalSet.settings.get("cosmetics", PawnCosmetics.DEFAULT_COSMETICS_SETTINGS)
	var you: Dictionary = cosmetics.get("you", PawnCosmetics.DEFAULT_COSMETICS_SETTINGS["you"])
	var opp: Dictionary = cosmetics.get("opponent", PawnCosmetics.DEFAULT_COSMETICS_SETTINGS["opponent"])
	_select_by_metadata(_you_faction_btn, str(you.get("faction", "roman")))
	_select_by_metadata(_you_color_btn, str(you.get("color", "red")))
	_select_by_metadata(_opp_faction_btn, str(opp.get("faction", "roman")))
	_select_by_metadata(_opp_color_btn, str(opp.get("color", "blue")))
	_updating_ui = false
	_refresh_previews()


func _select_by_metadata(btn: OptionButton, value: String) -> void:
	for i in range(btn.item_count):
		if str(btn.get_item_metadata(i)) == value:
			btn.select(i)
			return
	btn.select(0)


func _meta_of(btn: OptionButton) -> String:
	return str(btn.get_item_metadata(btn.selected))


func _on_you_cosmetics_changed(_index: int = 0) -> void:
	if _updating_ui:
		return
	_save_cosmetics_from_ui()
	_refresh_previews()


func _on_opp_cosmetics_changed(_index: int = 0) -> void:
	if _updating_ui:
		return
	_save_cosmetics_from_ui()
	_refresh_previews()


func _save_cosmetics_from_ui() -> void:
	if not GlobalSet.settings.has("cosmetics"):
		GlobalSet.settings["cosmetics"] = PawnCosmetics.DEFAULT_COSMETICS_SETTINGS.duplicate(true)
	GlobalSet.settings["cosmetics"]["you"] = {
		"faction": _meta_of(_you_faction_btn),
		"color": _meta_of(_you_color_btn),
	}
	GlobalSet.settings["cosmetics"]["opponent"] = {
		"faction": _meta_of(_opp_faction_btn),
		"color": _meta_of(_opp_color_btn),
	}
	SettingsLoad.save_settings()


func _refresh_previews() -> void:
	_apply_preview(_you_shield, _you_insignia, _meta_of(_you_faction_btn), _meta_of(_you_color_btn), "red")
	_apply_preview(_opp_shield, _opp_insignia, _meta_of(_opp_faction_btn), _meta_of(_opp_color_btn), "blue")


func _apply_preview(shield: TextureRect, insignia: TextureRect, faction_pref: String, color_pref: String, fallback_color: String) -> void:
	var faction_id := faction_pref
	if faction_id == PawnCosmetics.RANDOM_ID:
		faction_id = "roman"
	var color_id := color_pref
	if color_id == PawnCosmetics.RANDOM_ID:
		color_id = fallback_color
	PawnCosmetics.apply_to_sprites(shield, insignia, faction_id, color_id, false, null)


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
	GlobalSet.settings["audio"] = $TabContainer/Gameplay/GridContainer/audio_btn.get_item_id(index)
	SettingsLoad.save_settings()
	MusicManager.set_audio_enabled(GlobalSet.settings["audio"] == 1)


func _on_epic_btn_item_selected(index: int) -> void:
	GlobalSet.settings["epic"] = $TabContainer/Gameplay/GridContainer/epic_btn.get_item_id(index)
	SettingsLoad.save_settings()
