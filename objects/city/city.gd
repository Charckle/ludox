extends Node2D

var all_board_positions
var corners
var border_tiles

var player_turn = 2

var can_interact = true

var tile_selected = null
var possible_moves = []
var tile_target = null

var previous_tile = null
var moved_to_tile = null

var since_last_eat = 0

var all_units = []


enum Where {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}


enum Rules {
	BASIC,
	BASIC_PLUS,
	XXI
}

enum Game_types {
	PVP,
	PVAI
}

var fast_game = false # move pieces slowly
var rules : int
var ai_lvl = 0

var game_move_states = []

var soldierUnitScene = preload("res://objects/soldier/soldier.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rules = GlobalSet.game_rules
	#GlobalSet.game_type = $game_type_btn.selected
	#GlobalSet.ai_lvl = $ai_lvl_btn.select
	
	all_board_positions = blank_board()
	corners = get_corners()
	border_tiles = get_border_tiles()
	
	show_pieces_turn()
	save_move_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Mouse Click/Unclick at: ", event.position)
		if can_interact:
			check_tile(get_global_mouse_position())


func check_tile(mouse_pos):
	for tile in $tiles.get_children():
		if tile.get_child(0).get_global_rect().has_point(mouse_pos):
			#print("Clicked on:", tile.name)
			var tile_coord = tile.position_grid
			var soldier_on_pos = get_soldier_on_position(tile_coord)
			
			# if there is a soldier on that position
			if soldier_on_pos != null:
				if soldier_on_pos.player == self.player_turn:
					select_soldier(soldier_on_pos)
					show_selected_piece(soldier_on_pos)
					tile_selected = tile
					#print("Selected tile:", tile_selected.position_grid)
			else:
				if tile_selected != null:
					if tile.position_grid in possible_moves:
						# move selcted unit to position
						self.move_unit(tile_selected.position_grid, tile.position_grid)
				

func get_soldier_on_position(pos_coord):
	var soldier_on_pos = null
	for soldier in $soldiers.get_children():
		if soldier.position_grid == pos_coord:
			soldier_on_pos = soldier
	
	return soldier_on_pos

func get_tile_on_position(pos_coord):
	var tile_on_pos = null
	for tile in $tiles.get_children():
		if tile.position_grid == pos_coord:
			tile_on_pos = tile
	
	return tile_on_pos

func select_soldier(soldier):
	#soldier.set_selected(true)
	get_possible_moves(soldier.position_grid)
	
	show_where_can_move(true)

func show_where_can_move(yes=false):
	var tiles = $tiles.get_children()

	for tile in tiles:
		tile.dim(false)
		
		if yes and not tile.position_grid in possible_moves:
			tile.dim(yes)

func show_pieces_turn():
	var units = $soldiers.get_children()
	for unit in units:
		if unit.player == player_turn:
			unit.set_pieces_turn(true)
		else:
			unit.set_pieces_turn(false)

func show_selected_piece(unit_=null):
	var units = $soldiers.get_children()
	for unit in units:
		if unit == unit_:
			unit.set_selected(true)
		else:
			unit.set_selected(false)
		

func get_possible_moves(soldier_pos, dryrun=false):
	var poss_moves = []
	if not dryrun:
		possible_moves.clear()
	
	match rules:
		Rules.BASIC:
			poss_moves = get_basic_moves(soldier_pos, dryrun)
		Rules.BASIC_PLUS:
			poss_moves = get_basic_moves(soldier_pos, dryrun)
		Rules.XXI:
			poss_moves = $xxi.get_moves(soldier_pos, dryrun)

	return poss_moves


func get_basic_moves(soldier_pos, dryrun=false):
	# check bottom positions
	var _possible_moves_local = []
	var ckeck_from = soldier_pos
	
	while true:
		ckeck_from.y = ckeck_from.y - 1

		if ckeck_from in all_board_positions and get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check top positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.y = ckeck_from.y + 1
				
		if ckeck_from in all_board_positions and get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check left positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x - 1

		if ckeck_from in all_board_positions and get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check right positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x + 1

		if ckeck_from in all_board_positions and get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	if dryrun:
		return _possible_moves_local
	else:
		possible_moves = _possible_moves_local


func blank_board():
	var positions: Array = []

	for x in range(8):
		for y in range(8):
			positions.append(Vector2i(x, y))
	
	return positions

func get_corners(all_positions = null):
	if all_positions == null:
		all_positions = self.all_board_positions
	
	var highest_x = 0
	var lowest_x = 0
	var highest_y = 0
	var lowest_y = 0
	
	for pos_ in all_positions:
		if highest_x < pos_.x:
			highest_x = pos_.x
		if lowest_x > pos_.x:
			lowest_x = pos_.x
		if highest_y < pos_.y:
			highest_y = pos_.y
		if lowest_y < pos_.y:
			lowest_y = pos_.y
	
	var tr_ = Vector2i(highest_x, highest_y)
	var tl_ = Vector2i(lowest_x, highest_y)
	var br_ = Vector2i(highest_x, lowest_y)
	var bl_ = Vector2i(lowest_x, lowest_y)
	
	return {"TR": tr_,
	"TL":  tl_,
	"BR":  br_,
	"BL":  bl_,
	"all": [tr_, tl_, br_, bl_]}

func get_border_tiles(all_positions = null):
	if all_positions == null:
		all_positions = self.all_board_positions
	
	var highest_x = -INF
	var lowest_x = INF
	var highest_y = -INF
	var lowest_y = INF

	# Find bounds
	for pos_ in all_positions:
		if pos_.x > highest_x:
			highest_x = pos_.x
		if pos_.x < lowest_x:
			lowest_x = pos_.x
		if pos_.y > highest_y:
			highest_y = pos_.y
		if pos_.y < lowest_y:
			lowest_y = pos_.y

	var border_tiles_: Array = []

	# Collect all tiles that are on the border
	for pos_ in all_positions:
		if pos_.x == lowest_x \
		or pos_.x == highest_x \
		or pos_.y == lowest_y \
		or pos_.y == highest_y:
			border_tiles_.append(pos_)
	
	return border_tiles_

func move_unit(start_pos, end_pos):
	can_interact = false
	var unit = get_soldier_on_position(start_pos)
	var start_tile = get_tile_on_position(start_pos)
	var tile = get_tile_on_position(end_pos)
	
	
	unit.position_grid = end_pos
	
	# set last moved	
	self.previous_tile = start_pos
	self.moved_to_tile = end_pos
	set_all_last_moved()
	
	
	
	self.since_last_eat = self.since_last_eat + 1
	
	# move and end turn
	
	if fast_game:
		unit.global_position = tile.global_position
		unit_stopped_moving(start_pos, end_pos)
	else:
		unit.tween_to_global_and_resume(tile.global_position, self, start_pos, end_pos)
	
	
	

func unit_stopped_moving(start_pos, end_pos):
	# check if you eat anything
	check_if_eatable(start_pos, end_pos)
	can_interact = true
	end_turn()

func check_if_eatable(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	
	match rules:
		Rules.BASIC:
			can_eat.append(basic_eatable_rules(pos_coord, dryrun))
		Rules.BASIC_PLUS:
			can_eat.append(basic_plus_eatable_rules(pos_coord, dryrun))
		Rules.XXI:
			can_eat.append(xxi_eatable_rules(start_coord, pos_coord, dryrun))
	
	if dryrun:
		if true in can_eat:
			return true
		else:
			return false



func basic_eatable_rules(pos_coord, dryrun=false):
	var can_eat = []
	# check bottom
	can_eat.append(check_basic_kill(Where.BOTTOM, pos_coord, dryrun))
	# check top
	can_eat.append(check_basic_kill(Where.TOP, pos_coord, dryrun))
	# check left
	can_eat.append(check_basic_kill(Where.LEFT, pos_coord, dryrun))
	# check right
	can_eat.append(check_basic_kill(Where.RIGHT, pos_coord, dryrun))

	if dryrun:
		if true in can_eat:
			return true
		else:
			return false

func basic_plus_eatable_rules(pos_coord, dryrun=false):
	var can_eat = []

	can_eat.append(basic_eatable_rules(pos_coord, dryrun))
	# check corners
	# Check top, bottom, left right, if there is an enemy
	var current_unit = get_soldier_on_position(pos_coord)
	var adj_tiles = current_unit.get_adjacent_tiles(self)
	
	# if there is, check if its in a corner
	for tile_coord in adj_tiles:
		#print(corners)
		if tile_coord in corners["all"]:
			# check if unit there
			var unit_ = get_soldier_on_position(tile_coord)
			if unit_ != null and unit_.player != player_turn:
				# check if that unit ha another player unit alongside it
				var enemy_adj_tiles = unit_.get_adjacent_tiles(self)
				# remove the player unit
				enemy_adj_tiles.erase(pos_coord)
				for adj_tile_coord in enemy_adj_tiles:
					var unit_adj = get_soldier_on_position(adj_tile_coord)
					if unit_adj != null:
						if unit_adj.player == player_turn:
							if unit_.dux == false:
								if not dryrun:
									can_eat.append(true)
									self.eat_unit(unit_)
									
	if dryrun:
		if true in can_eat:
			return true
		else:
			return false

func eat_unit(unit):
	unit.queue_free()
	self.since_last_eat = -1

func xxi_eatable_rules(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	can_eat.append(basic_eatable_rules(pos_coord, dryrun))
	
	can_eat.append($xxi.eatable_rules(start_coord, pos_coord, dryrun))
	
	if dryrun:
		if true in can_eat:
			return true
		else:
			return false


func check_basic_kill(where: Where, pos_coord, dryrun=false):
	var can_eat = false
	var up = 1
	var axis = 0
	match where:
		Where.TOP:
			up = up * 1
			axis = 1
		Where.BOTTOM:
			up = up * -1
			axis = 1
		Where.LEFT:
			up = up * -1
		Where.RIGHT:
			up = up * 1
	
	# check right
	var position_to_check = pos_coord
	position_to_check[axis] = position_to_check[axis] + up
	var enemy_unit = get_soldier_on_position(position_to_check)
	if enemy_unit != null:
		if enemy_unit.player != player_turn:
			position_to_check[axis] = position_to_check[axis] + up
			var friendly_unit = get_soldier_on_position(position_to_check)
			if friendly_unit != null and friendly_unit.player == player_turn:
				if enemy_unit.dux == false:
					if not dryrun:
						self.eat_unit(enemy_unit)
					else:
						can_eat = true

	return can_eat


func end_turn():
	# clear display where can move
	show_where_can_move()
	
	if player_turn == 1:
		player_turn = 2
	else:
		player_turn = 1
	
	# show whos pieces turn is
	show_pieces_turn()
	show_selected_piece()

	tile_selected = null
	possible_moves = []
	tile_target = null
	
	
	save_move_state()
	
	check_win()
	if player_turn != 3 and GlobalSet.game_type != Game_types.PVP:
		if player_turn != 2:
			$ai.execute_move()

func get_soldiers(player=false):
	
	if player:
		var units = []
		for unit in $soldiers.get_children():
			if unit.player == player:
				units.append(unit)
		return units
	else:
		return $soldiers.get_children()

func clear_all_last_moved():
	for tile in $tiles.get_children():
		tile.last_moved(false)
	for unit in $soldiers.get_children():
		unit.set_moved(false)

func set_all_last_moved():
	clear_all_last_moved()
	var tile =  get_tile_on_position(self.previous_tile)
	var soldier = get_soldier_on_position(self.moved_to_tile)

	if tile != null:
		tile.last_moved(true)
	if soldier != null:
		soldier.set_moved(true)


func check_win():
	# check if both have any units left
	var score = {1: 0, 2: 0}
	
	for unit_ in $soldiers.get_children():
		if unit_.dux == false:
			score[unit_.player] = score[unit_.player] + 1 
	if score[1] == 0:
		print("player 2 wins!")
		set_winner(2)
	elif score[2] == 0:
		print("player 1 wins!")
		set_winner(1)
	# check for dux
	for unit_ in $soldiers.get_children():
		if unit_.dux == true:
			var blocking_tiles = unit_.get_blocking_tiles(self)
			var blocking_units = blocking_tiles[0]
			var all_tiles = blocking_tiles[1]
			
			if len(blocking_units) == len(all_tiles):
				if unit_.player == 1:
					print("player 2 wins!")
					set_winner(2)
				else:
					print("player 1 wins!")
					set_winner(1)

func set_winner(player_n):
	player_turn = 3
	
	for unit_ in $soldiers.get_children():
		if unit_.player != player_n:
			unit_.set_lost()

func get_current_game_state():
	var game_state = {
		"player_turn": self.player_turn,
		"rules": self.rules,
		"game_type": GlobalSet.game_type,
		"ai_lvl": self.ai_lvl,
		"previous_tile": self.previous_tile,
		"moved_to_tile": self.moved_to_tile,
		"all_units": get_all_units_for_bckup(),
		"since_last_eat": self.since_last_eat
	}
	return game_state

func get_all_units_for_bckup():
	var all_units = []
	for unit in $soldiers.get_children():
		all_units.append([
			unit.position_grid,
			unit.global_position,
			unit.player,
			unit.dux
		])
	
	return all_units

func save_move_state():
	self.game_move_states.append(get_current_game_state())
	
func undo_move():
	self.show_where_can_move()
	
	if len( self.game_move_states) > 1:
		self.game_move_states.pop_back() 
		var previous_state = self.game_move_states[-1]
		
		self.load_game_state(previous_state)
		

func load_game_state(game_state):
	self.player_turn = game_state["player_turn"]
	self.rules = game_state["rules"]
	GlobalSet.game_type = game_state["game_type"]
	self.ai_lvl = game_state["ai_lvl"]
	self.previous_tile = game_state["previous_tile"]
	self.moved_to_tile = game_state["moved_to_tile"]
	self.all_units = game_state["all_units"]
	self.since_last_eat = game_state["since_last_eat"]
	
	remove_all_units()
	
	for unit_data in self.all_units:
		self.restore_unit(unit_data)
	
	
	
	#for unit in $soldiers.get_children():
		#print(unit.name)
		#print(unit.position_grid)
	# show player turn
	show_pieces_turn()
	# show last move
	set_all_last_moved()
	print("Undone")


func remove_all_units():
	for unit in $soldiers.get_children():
		eat_unit(unit)


func restore_unit(unit_data):
	var unit = soldierUnitScene.instantiate()
	unit.position_grid = unit_data[0]
	unit.player = unit_data[2]
	unit.dux = unit_data[3]
	$soldiers.add_child(unit)
	unit.global_position = unit_data[1]
	unit.set_position_grid()


func get_enemy_pid(manual_player = null):
	if manual_player == null:
		manual_player = player_turn
	if manual_player == 1:
		return 2
	else:
		return 1
