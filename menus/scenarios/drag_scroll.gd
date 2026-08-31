extends ScrollContainer
class_name DragScroll

# Mouse/touch drag-to-scroll, plus a thicker vertical bar.

const BAR_WIDTH := 22.0
const DRAG_THRESHOLD := 6.0

static var swallow_click := false

var _dragging := false
var _did_drag := false
var _last := Vector2.ZERO
var _origin := Vector2.ZERO


func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = true
	_style_bar()


func _get_minimum_size() -> Vector2:
	# Native ScrollContainer min-size includes the bar and widens the column.
	# Report no extra width so the bar is taken from the list, not the parent.
	return Vector2.ZERO


func _style_bar() -> void:
	var bar := get_v_scroll_bar()
	if bar == null:
		return
	bar.custom_minimum_size.x = BAR_WIDTH
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.85, 0.72, 0.35)
	grabber.set_corner_radius_all(4)
	grabber.content_margin_left = 6
	grabber.content_margin_right = 6
	var grabber_hi := grabber.duplicate()
	grabber_hi.bg_color = Color(0.95, 0.84, 0.45)
	var scroll_bg := StyleBoxFlat.new()
	scroll_bg.bg_color = Color(0.12, 0.1, 0.08, 0.95)
	scroll_bg.set_corner_radius_all(4)
	scroll_bg.content_margin_left = 2
	scroll_bg.content_margin_right = 2
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber_hi)
	bar.add_theme_stylebox_override("grabber_pressed", grabber_hi)
	bar.add_theme_stylebox_override("scroll", scroll_bg)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_press(event.pressed, event.global_position)
	elif event is InputEventScreenTouch:
		_handle_press(event.pressed, event.position)
	elif event is InputEventMouseMotion and _dragging:
		_handle_drag(event.global_position)
	elif event is InputEventScreenDrag and _dragging:
		_handle_drag(event.position)


func _handle_press(pressed: bool, global_pos: Vector2) -> void:
	if pressed:
		if not get_global_rect().has_point(global_pos):
			return
		_dragging = true
		_did_drag = false
		_last = global_pos
		_origin = global_pos
	else:
		if _dragging and _did_drag:
			swallow_click = true
			get_viewport().set_input_as_handled()
			get_tree().create_timer(0.05).timeout.connect(func(): swallow_click = false)
		_dragging = false
		_did_drag = false


func _handle_drag(global_pos: Vector2) -> void:
	var delta: Vector2 = global_pos - _last
	_last = global_pos
	if _origin.distance_to(global_pos) > DRAG_THRESHOLD:
		_did_drag = true
	if not _did_drag:
		return
	scroll_vertical -= int(delta.y)
	get_viewport().set_input_as_handled()
