extends Node2D

@onready var city = $City

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasModulate/Panel.city = city
	MusicManager.play_battle()
	if GlobalSet.current_battle != null:
		_show_mission_banner(str(GlobalSet.current_battle.title))


func show_info_pan(text_, to_campaign := false, hide_rematch := false):
	$CanvasModulate/info_panel/RichTextLabel.text = text_
	$CanvasModulate/info_panel.setup_for_result(to_campaign, hide_rematch)
	$CanvasModulate/info_panel.visible = true

func _on_undo_btn_pressed() -> void:
	city.undo_move()

func fill_console(text_):
	$CanvasModulate/console_pnl/consol.append_text(str(text_) + "\n")


func _show_mission_banner(title: String) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.offset_left = -240.0
	panel.offset_right = 240.0
	panel.offset_top = 28.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	root.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.07, 0.88)
	style.border_color = Color(0.85, 0.72, 0.35, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	panel.add_child(label)

	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.45)
	tween.tween_callback(layer.queue_free)
