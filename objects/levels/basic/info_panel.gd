extends Panel

const NORM_LEFT := -144.0
const NORM_TOP := -72.0
const NORM_RIGHT := 144.0
const NORM_BOTTOM := 109.0

var campaign_btn: Button


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.10, 1.0)
	style.border_color = Color(0.85, 0.72, 0.35, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)
	$RichTextLabel.bbcode_enabled = true
	$RichTextLabel.scroll_active = true
	campaign_btn = Button.new()
	campaign_btn.name = "campaign_btn"
	campaign_btn.text = "Return to Campaign"
	campaign_btn.visible = false
	campaign_btn.pressed.connect(_on_campaign_btn_pressed)
	add_child(campaign_btn)


func setup_for_result(to_campaign: bool, hide_rematch: bool) -> void:
	var label: RichTextLabel = $RichTextLabel
	var rematch: Button = $rematch_btn
	var ok: Button = $ok_btn
	if to_campaign:
		offset_left = -200.0
		offset_top = -150.0
		offset_right = 200.0
		label.offset_left = 12.0
		label.offset_top = 8.0
		label.offset_right = 388.0
		label.offset_bottom = 148.0
		campaign_btn.visible = true
		campaign_btn.size = Vector2(376, 36)
		ok.offset_left = 12.0
		ok.offset_right = 388.0
		if hide_rematch:
			offset_bottom = 130.0
			rematch.visible = false
			campaign_btn.position = Vector2(12, 156)
			ok.offset_top = 200.0
			ok.offset_bottom = 231.0
		else:
			offset_bottom = 170.0
			rematch.visible = true
			rematch.offset_left = 12.0
			rematch.offset_top = 156.0
			rematch.offset_right = 388.0
			rematch.offset_bottom = 187.0
			campaign_btn.position = Vector2(12, 196)
			ok.offset_top = 236.0
			ok.offset_bottom = 267.0
	else:
		offset_left = NORM_LEFT
		offset_top = NORM_TOP
		offset_right = NORM_RIGHT
		offset_bottom = NORM_BOTTOM
		label.offset_left = 8.0
		label.offset_top = 0.0
		label.offset_right = 280.0
		label.offset_bottom = 96.0
		campaign_btn.visible = false
		rematch.visible = true
		ok.offset_left = 8.0
		ok.offset_top = 104.0
		ok.offset_right = 280.0
		ok.offset_bottom = 135.0
		rematch.offset_left = 8.0
		rematch.offset_top = 140.0
		rematch.offset_right = 280.0
		rematch.offset_bottom = 171.0


func _on_campaign_btn_pressed() -> void:
	GlobalSet.return_to_campaign_menu()
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")


func _on_button_pressed() -> void:
	self.visible = false
