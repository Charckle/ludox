extends Control
class_name BoardPreview

signal cell_clicked(pos: Vector2i)

const TILE_A := Color(0.78, 0.52, 0.22)
const TILE_B := Color(0.62, 0.38, 0.08)
const TILE_HOVER := Color(1, 0.92, 0.55, 0.35)
const YOU_RED := Color(0.82, 0.16, 0.14)
const OPP_BLUE := Color(0.16, 0.38, 0.88)
const DUX_GOLD := Color(0.95, 0.78, 0.2)

var city_size: Vector2i = Vector2i(8, 8)
var pawns: Array = []
var editable: bool = false
var cell_px: float = 24.0
var hover_cell: Vector2i = Vector2i(-1, -1)

var _tex_cache: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func configure(p_size: Vector2i, p_pawns: Array, max_size: Vector2, p_editable: bool = false) -> void:
	city_size = p_size
	pawns = p_pawns
	editable = p_editable
	mouse_filter = Control.MOUSE_FILTER_STOP if editable else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if editable else Control.CURSOR_ARROW
	var cell := minf(max_size.x / float(maxi(city_size.x, 1)), max_size.y / float(maxi(city_size.y, 1)))
	cell_px = maxf(floorf(cell), 10.0)
	custom_minimum_size = Vector2(cell_px * city_size.x, cell_px * city_size.y)
	size = custom_minimum_size
	queue_redraw()


func set_pawns(p_pawns: Array) -> void:
	pawns = p_pawns
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not editable:
		return
	if event is InputEventMouseMotion:
		var cell := _cell_at(event.position)
		if cell != hover_cell:
			hover_cell = cell
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := _cell_at(event.position)
		if cell.x >= 0:
			cell_clicked.emit(cell)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		if hover_cell.x >= 0:
			hover_cell = Vector2i(-1, -1)
			queue_redraw()


func _cell_at(local: Vector2) -> Vector2i:
	if cell_px <= 0.0:
		return Vector2i(-1, -1)
	var x := int(local.x / cell_px)
	var y := int(local.y / cell_px)
	if x < 0 or y < 0 or x >= city_size.x or y >= city_size.y:
		return Vector2i(-1, -1)
	return Vector2i(x, y)


func _draw() -> void:
	var owner_at := {}
	for p in pawns:
		owner_at[p["pos"]] = int(p["player"])
	for y in city_size.y:
		for x in city_size.x:
			var r := Rect2(x * cell_px, y * cell_px, cell_px, cell_px)
			var pos := Vector2i(x, y)
			var col: Color
			if owner_at.has(pos):
				var base := YOU_RED if int(owner_at[pos]) == 2 else OPP_BLUE
				col = base.lightened(0.10) if (x + y) % 2 == 0 else base.darkened(0.10)
			else:
				col = TILE_A if (x + y) % 2 == 0 else TILE_B
			draw_rect(r, col)
	if hover_cell.x >= 0:
		draw_rect(Rect2(hover_cell.x * cell_px, hover_cell.y * cell_px, cell_px, cell_px), TILE_HOVER)
	for p in pawns:
		_draw_pawn(p)


func _draw_pawn(p: Dictionary) -> void:
	var pos: Vector2i = p["pos"]
	var faction := str(p.get("faction", "roman"))
	var spec: Dictionary = PawnCosmetics.get_faction(faction)
	var shield := _tex(str(spec.get("shield", "")))
	var insignia := _tex(str(spec.get("insignia", "")))
	var color_id := PawnCosmetics.color_for_faction(faction)
	var tint := PawnCosmetics.get_color(color_id)
	var pad := cell_px * 0.08
	var dest := Rect2(
		pos.x * cell_px + pad,
		pos.y * cell_px + pad,
		cell_px - pad * 2.0,
		cell_px - pad * 2.0
	)
	if bool(p.get("dux", false)) and shield:
		var outline := PawnCosmetics.get_outline_texture(shield, DUX_GOLD, 2)
		if outline:
			var grow := dest.size.x * 0.10
			draw_texture_rect(outline, dest.grow(grow), false)
	if shield:
		draw_texture_rect(shield, dest, false, tint)
	if insignia:
		var inner := dest.grow(-dest.size.x * 0.12)
		draw_texture_rect(insignia, inner, false)


func _tex(path: String) -> Texture2D:
	if path == "":
		return null
	if _tex_cache.has(path):
		return _tex_cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	_tex_cache[path] = tex
	return tex
