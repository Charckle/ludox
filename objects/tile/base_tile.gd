extends Node2D

@export var position_grid: Vector2i = Vector2i.ZERO

var my_size = Vector2i(40,40)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_adjacent_tiles(city):
	var top = position_grid + Vector2i(0,1)
	var bottom = position_grid + Vector2i(0,-1)
	var left = position_grid + Vector2i(-1,0)
	var right = position_grid + Vector2i(1,0)
	
	var adj_tiles = [top, bottom, left, right]
	for c_tile in adj_tiles:
		if c_tile not in city.all_board_positions:
			adj_tiles.erase(c_tile)

	return adj_tiles

func do_adj_dux(city, player_id, simulation=false):
	var adj_tiles_pos = get_adjacent_tiles(city)
	for tile_pos in adj_tiles_pos:
		var unit = city.get_soldier_on_position(tile_pos, simulation)
		
		if unit != null and unit.player == player_id and unit.dux:
			return true
	return false

func dim(yes=false):
	if yes:
		$ColorRect/ColorRect2.visible = true
	else:
		$ColorRect/ColorRect2.visible = false

func last_moved(yes=false):
	if yes:
		$ColorRect/ColorRect3.visible = true
	else:
		$ColorRect/ColorRect3.visible = false
