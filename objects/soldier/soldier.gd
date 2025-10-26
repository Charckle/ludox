extends Node2D

@export var player: int = 1
@export var dux: bool = false
var captured = false
var position_grid: Vector2i = Vector2i.ZERO

var my_size = Vector2i(40,40)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player == 1:
		$rect_dux.color = Color.RED
		$ColorRect.color = Color.RED
	else:
		$rect_dux.color = Color.DEEP_SKY_BLUE
		$ColorRect.color = Color.DEEP_SKY_BLUE
	if dux:
		$rect_dux.color = Color.YELLOW
		
	self.set_position_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_position_grid(pos_grid=null):
	if not pos_grid:
		for tile in $"../..".get_node("tiles").get_children():
			if tile.global_position == self.global_position:
				position_grid = tile.position_grid
	else:
		position_grid = pos_grid

func set_moved(yes_no):
	if yes_no:
		$moved.visible = true
	else:
		$moved.visible = false

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

func get_blocking_tiles(city, foes_only=false, simulation=false):
	var pool = "soldiers"
	
	if simulation == true:
		pool = "simulation"
		
	var adj_units = []
	var adj_tiles = self.get_adjacent_tiles(city)
	var adj_free_tile_pos = adj_tiles.duplicate() 
	
	for c_tile in adj_tiles:
		if c_tile not in city.all_board_positions:
			adj_tiles.erase(c_tile)
	
	for unit_ in city.get_node(pool).get_children():
		var unit_pos = unit_.position_grid

		if unit_pos in adj_tiles and unit_.captured == false:
			adj_free_tile_pos.erase(unit_pos)
			if not foes_only:
				adj_units.append(unit_)
			elif unit_.player != self.player:
				adj_units.append(unit_)

	var blocking_tiles = []
		
	for cord in adj_tiles:
		if cord not in adj_free_tile_pos:
			blocking_tiles.append(cord)
	
	return [adj_units, adj_tiles, adj_free_tile_pos, blocking_tiles]

func set_lost():
	$ColorRect.color = Color.BLACK

func set_selected(yes=true):
	$selectedpiece.visible = yes

func set_pieces_turn(yes=true):
	$myturn.visible = yes


func tween_to_global_and_resume(target_global: Vector2, city, start_pos, end_pos) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# If your game is paused and you still want this tween to run, keep this line:
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(self, "global_position", target_global, 0.8)
	await tween.finished
	city.unit_stopped_moving(self.player, start_pos, end_pos)
