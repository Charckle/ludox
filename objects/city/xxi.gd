extends Node

@onready var city = get_parent()

enum Where {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_moves(soldier_pos, dryrun=false):
	var _possible_moves_local = []
	var possible_basic_moves = city.get_basic_moves(soldier_pos, true)
	var possible_moves = []
	# check enemies around you
	var current_unit = city.get_soldier_on_position(soldier_pos)
	
	var blocking_tiles = current_unit.get_blocking_tiles(city, true)
	var blocking_enemy_units = blocking_tiles[0]
	var all_tiles_coord = blocking_tiles[1]
	var all_free_tiles_coord = blocking_tiles[2]
	var all_blocking_tiles_coord = blocking_tiles[3]
	
	# if there are no enemies, you can go anywhere
	if len(blocking_enemy_units) == 0:
		_possible_moves_local = possible_basic_moves
	# if there are enemies, check if they have at least another unit next to them
	elif current_unit.dux:
		if len(blocking_enemy_units) == 1: 
			if not current_unit.position_grid in city.corners["all"]:
				for tile_pos in all_free_tiles_coord:
					possible_moves.append(tile_pos)
			# can move to dux
			var dux_pos = get_coord_nxt_to_dux(soldier_pos, possible_basic_moves, othr_p(city.player_turn))
			for pos in dux_pos:
				possible_moves.append(pos)
			# add to all those, that would attack another unit
			for pos in possible_basic_moves:
				if self.eatable_rules(soldier_pos, pos, true):
					possible_moves.append(pos)
					
			_possible_moves_local = possible_moves
			
		elif len(blocking_enemy_units) == 2: 
			if current_unit.position_grid in city.border_tiles:
				possible_moves = []
			else:
				# can move to dux
				var dux_pos = get_coord_nxt_to_dux(soldier_pos, possible_basic_moves, othr_p(city.player_turn))
				
				for pos in dux_pos:
					possible_moves.append(pos)
				# add to all those, that would attack another unit
				for pos in possible_basic_moves:
					if self.eatable_rules(soldier_pos, pos, true):
						possible_moves.append(pos)
						
				_possible_moves_local = possible_moves
	else:
		for adj_enemy in blocking_enemy_units:
			var blocking_tiles_enemy = adj_enemy.get_blocking_tiles(city, true)
			var blocking_enemy_units_enemy = blocking_tiles_enemy[0]
			var all_tiles_coord_enemy = blocking_tiles_enemy[1]
			
			if len(blocking_enemy_units_enemy) == 1:
				# add to the possible moves all those, that are next to an enemy dux
				var dux_pos = get_coord_nxt_to_dux(soldier_pos, possible_basic_moves, blocking_enemy_units[0].player)
				
				for pos in dux_pos:
					possible_moves.append(pos)

				# add to all those, that would attack another unit
				for pos in possible_basic_moves:
					if self.eatable_rules(soldier_pos, pos, true):
						possible_moves.append(pos)
						
				_possible_moves_local = possible_moves
			# if the unit is not the only one pinning his adjecant emenies, can move freely
			elif len(blocking_enemy_units_enemy) > 1:
				_possible_moves_local = possible_basic_moves
			else:
				_possible_moves_local = possible_basic_moves
	
	if dryrun:
		return _possible_moves_local
	else:
		city.possible_moves = _possible_moves_local
	
func get_coord_nxt_to_dux(soldier_pos, possible_moves, player_of_dux):
	var _moves = []
	for tile_pos in city.get_basic_moves(soldier_pos, true):
		var tile = city.get_tile_on_position(tile_pos)
		if tile.do_adj_dux(city, player_of_dux):
			_moves.append(tile_pos)
	return _moves
	

func eatable_rules(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	can_eat.append(city.basic_eatable_rules(pos_coord, dryrun))
	can_eat.append(eat_p_and_c_attack(start_coord, pos_coord, dryrun))
	can_eat.append(eat_flank_attack(start_coord, pos_coord, dryrun))
	can_eat.append(eat_phalanx_attack(start_coord, pos_coord, dryrun))
	
	if dryrun:
		if true in can_eat:
			return true
		else:
			return false


func eat_p_and_c_attack(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	
	# check right
	can_eat.append(push_and_crush(Where.RIGHT, start_coord, pos_coord, dryrun))
	# check bottom
	can_eat.append(push_and_crush(Where.BOTTOM, start_coord, pos_coord, dryrun))
	# check top
	can_eat.append(push_and_crush(Where.TOP, start_coord, pos_coord, dryrun))
	# check left
	can_eat.append(push_and_crush(Where.LEFT, start_coord, pos_coord, dryrun))

	if dryrun:
		if true in can_eat:
			return true
		else:
			return false



func push_and_crush(where, start_coord, target_pos, dryrun=false):
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
	
	
	var position_to_check = target_pos
	position_to_check[axis] = position_to_check[axis] + up
	var unit_r = city.get_soldier_on_position(position_to_check)
	if unit_r != null and unit_r.player == city.player_turn:
		if unit_r.position_grid == start_coord:
			pass
		elif start_coord.x == unit_r.position_grid.x or start_coord.y == unit_r.position_grid.y:
			position_to_check = unit_r.position_grid
			position_to_check[axis] = position_to_check[axis] + up
			var unit_rr = city.get_soldier_on_position(position_to_check)

			if unit_rr != null:
				# if the unit is on the edge of the city
				if unit_rr.player != city.player_turn and unit_rr.position_grid in city.border_tiles:
					position_to_check = unit_rr.position_grid
					position_to_check[axis] = position_to_check[axis] + up
					var tile_ = city.get_tile_on_position(position_to_check)
					
					if tile_ == null:
						if not unit_rr.dux:
							if dryrun:
								can_eat = true 
							else:
								city.eat_unit(unit_rr)
				# if the unit is squashed between two other
				else:
					position_to_check = unit_rr.position_grid
					position_to_check[axis] = position_to_check[axis] + up
					var unit_rrr = city.get_soldier_on_position(position_to_check)
					
					if unit_rrr != null and unit_rrr.player != city.player_turn:
						if not unit_rr.dux:
							if dryrun:
								can_eat = true 
							else:
								city.eat_unit(unit_rr)
	return can_eat

func eat_flank_attack(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	
	# check right
	can_eat.append(flank_nomnom(Where.RIGHT, start_coord, pos_coord, dryrun))
	# check bottom
	can_eat.append(flank_nomnom(Where.BOTTOM, start_coord, pos_coord, dryrun))
	# check top
	can_eat.append(flank_nomnom(Where.TOP, start_coord, pos_coord, dryrun))
	# check left
	can_eat.append(flank_nomnom(Where.LEFT, start_coord, pos_coord, dryrun))

	if dryrun:
		if true in can_eat:
			return true
		else:
			return false

func flank_nomnom(where, start_coord, target_pos, dryrun=false):
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
	
	var position_to_check = target_pos
	position_to_check[axis] = position_to_check[axis] + up
	var unit_r = city.get_soldier_on_position(position_to_check)
	#position_to_check[axis] = position_to_check[axis] + up
	#var unit_rr = city.get_soldier_on_position(position_to_check)
	#position_to_check[axis] = position_to_check[axis] + up
	#var unit_rrr = city.get_soldier_on_position(position_to_check)
	
	
	var enemy_unit_exists = false
	var target_in_path = false
	
	if unit_r != null and unit_r.player != city.player_turn:
		enemy_unit_exists = true
		if start_coord.x == unit_r.position_grid.x or start_coord.y == unit_r.position_grid.y:
			target_in_path = true
	
	if enemy_unit_exists and target_in_path:
		var next_unit = null
		while true:
			position_to_check[axis] = position_to_check[axis] + up
			next_unit = city.get_soldier_on_position(position_to_check)

			if position_to_check not in city.all_board_positions or next_unit == null:
				break
			
			if next_unit.player == city.player_turn:
				can_eat = true 
				break
	
	if can_eat:
		if not unit_r.dux and not dryrun:
			city.eat_unit(unit_r)

	
	return can_eat


func eat_phalanx_attack(start_coord, pos_coord, dryrun=false):
	var can_eat = []
	
	# check right
	can_eat.append(phalanx_attack(Where.RIGHT, start_coord, pos_coord, dryrun))
	# check bottom
	can_eat.append(phalanx_attack(Where.BOTTOM, start_coord, pos_coord, dryrun))
	# check top
	can_eat.append(phalanx_attack(Where.TOP, start_coord, pos_coord, dryrun))
	# check left
	can_eat.append(phalanx_attack(Where.LEFT, start_coord, pos_coord, dryrun))

	if dryrun:
		if true in can_eat:
			return true
		else:
			return false

func phalanx_attack(where, start_coord, target_pos, dryrun=false):
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

	var testudo_side = false

	var next_position = target_pos
	next_position[axis] = target_pos[axis] + up
	
	var unit = city.get_soldier_on_position(next_position)
	var first_unit = false
	
	if unit != null and unit.player == city.player_turn:
		if start_coord.x == unit.position_grid.x or start_coord.y == unit.position_grid.y:
			first_unit = true

	if first_unit:
		# check on which side your units are
		var tile = city.get_tile_on_position(target_pos)
		var unit_sourounding_tiles = tile.get_adjacent_tiles(city)
		unit_sourounding_tiles.erase(start_coord)
		var xyz_pos = target_pos
		xyz_pos[axis] = xyz_pos[axis] + up
		unit_sourounding_tiles.erase(xyz_pos)
		# erase one in the back
		xyz_pos = target_pos
		xyz_pos[axis] = xyz_pos[axis] - up
		unit_sourounding_tiles.erase(xyz_pos)
		if len(unit_sourounding_tiles) > 1:
			var left_side_pos = unit_sourounding_tiles[0]
			var right_side_pos = unit_sourounding_tiles[1]

			var unit_l = city.get_soldier_on_position(left_side_pos)
			var unit_r = city.get_soldier_on_position(right_side_pos)

			# if there is a friendly unit on one side, and no unit on the other
			var mlist = [unit_l, unit_r]
			if mlist.has(null) and mlist.count(null) < mlist.size():
				if unit_l == null:
					if unit_r.player == city.player_turn:
						testudo_side = right_side_pos
				elif unit_r == null:
					if unit_l.player == city.player_turn:
						testudo_side = left_side_pos
		
		
		if testudo_side:
			# check if the next unit has our unit on the right side
			var unit_pos_testudo_side = next_position + testudo_side
			var unit_opos_testudo_side = next_position - testudo_side
			var test_no_unit = city.get_soldier_on_position(unit_pos_testudo_side)
			var test_yes_unit = city.get_soldier_on_position(unit_opos_testudo_side)
			if test_no_unit != null and (test_yes_unit == null or test_yes_unit.player != city.player_turn):
				testudo_side = false
				first_unit = false


	if first_unit and testudo_side:
		while true:
			
			next_position[axis] = next_position[axis] + up
			var unit_r = city.get_soldier_on_position(next_position)

			if unit_r != null and unit_r.player != city.player_turn:
				if not unit_r.dux:
					can_eat = true
					
					if not dryrun:
						city.eat_unit(unit_r)
				break
			elif unit_r != null and unit_r.player == city.player_turn:
				var unit_pos_testudo_side = next_position + testudo_side
				var unit_opos_testudo_side = next_position - testudo_side
				var test_no_unit = city.get_soldier_on_position(unit_pos_testudo_side)
				var test_yes_unit = city.get_soldier_on_position(unit_opos_testudo_side)
				if test_no_unit != null and (test_yes_unit == null or test_yes_unit.player != city.player_turn):
					break
			else:
				break


	return can_eat

func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
	
