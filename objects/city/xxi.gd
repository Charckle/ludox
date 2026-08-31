extends Node

@onready var city = get_parent()
@onready var basic = city.get_node("basic")

enum Where {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}


func get_moves(soldier_pos, dryrun=false, simulation=false):
	var _possible_moves_local = []
	var possible_basic_moves = basic.get_basic_moves(soldier_pos, true, simulation)
	var possible_moves = []
	# check enemies around you
	var current_unit = city.get_soldier_on_position(soldier_pos, simulation)
	
	var blocking_tiles = city.get_blocking_tiles(soldier_pos, current_unit["player"], true, simulation)
	var blocking_enemy_units = blocking_tiles[0]
	var all_free_tiles_coord = blocking_tiles[2]
	
	# if there are no enemies, you can go anywhere
	if len(blocking_enemy_units) == 0:
		_possible_moves_local = possible_basic_moves
	# if there are enemies, check if they have at least another unit next to them
	elif current_unit["dux"]:
		if len(blocking_enemy_units) == 1: 
			if not current_unit["pg"] in city.corners["all"]:
				for tile_pos in all_free_tiles_coord:
					possible_moves.append(tile_pos)
			# can move to dux
			var dux_pos = get_coord_nxt_to_dux(soldier_pos, othr_p(current_unit["player"]), simulation)
			for pos in dux_pos:
				possible_moves.append(pos)
			# add to all those, that would attack another unit
			for pos in possible_basic_moves:
				if self.xxi_eatable_rules(current_unit["player"], soldier_pos, pos, true, simulation):
					possible_moves.append(pos)
					
			_possible_moves_local = possible_moves
			
		elif len(blocking_enemy_units) == 2: 
			if current_unit["pg"] in city.border_tiles:
				possible_moves = []
			else:
				# can move to dux
				var dux_pos = get_coord_nxt_to_dux(soldier_pos, othr_p(current_unit["player"]), simulation)
				
				for pos in dux_pos:
					possible_moves.append(pos)
				# add to all those, that would attack another unit
				for pos in possible_basic_moves:
					if self.xxi_eatable_rules(current_unit["player"], soldier_pos, pos, true, simulation):
						possible_moves.append(pos)
						
				_possible_moves_local = possible_moves
	else:
		for adj_enemy in blocking_enemy_units:
			var blocking_tiles_enemy = city.get_blocking_tiles(adj_enemy["pg"], adj_enemy["player"], 
															true, simulation)
			var blocking_enemy_units_enemy = blocking_tiles_enemy[0]
			
			if len(blocking_enemy_units_enemy) == 1:
				# add to the possible moves all those, that are next to an enemy dux
				var dux_pos = get_coord_nxt_to_dux(soldier_pos,
				blocking_enemy_units[0]["player"], simulation)
				
				for pos in dux_pos:
					possible_moves.append(pos)
				
				# add to all those, that would attack another unit
				for pos in possible_basic_moves:
					if self.xxi_eatable_rules(current_unit["player"], soldier_pos, pos, true, simulation):
						possible_moves.append(pos)
						
				_possible_moves_local = possible_moves
			# if the unit is not the only one pinning his adjecant emenies, can move freely
			elif len(blocking_enemy_units_enemy) > 1:
				_possible_moves_local = possible_basic_moves
			else:
				_possible_moves_local = possible_basic_moves
	
	#rm_duplicates_in_list(_possible_moves_local)
	
	if dryrun:
		return _possible_moves_local
	else:
		city.possible_moves = _possible_moves_local
	
func get_coord_nxt_to_dux(soldier_pos, player_of_dux, simulation):
	var enemy_pid = city.get_enemy_pid(player_of_dux)
	var _moves = []
	for tile_pos in basic.get_basic_moves(soldier_pos, true, simulation):
		if city.check_adj_enemy_dux_of(tile_pos, enemy_pid, simulation):
			_moves.append(tile_pos)
	return _moves
	

func eatable_rules(my_player, start_coord, pos_coord, dryrun=false, 
			simulation=false):
	var can_eat = []
	can_eat.append_array(eat_p_and_c_attack(my_player, start_coord, pos_coord, 
				dryrun, simulation))
	can_eat.append_array(eat_flank_attack(my_player, start_coord, pos_coord, 
				dryrun, simulation))
	can_eat.append_array(eat_phalanx_attack(my_player, start_coord, pos_coord, 
				dryrun, simulation))
	
	return can_eat


func eat_p_and_c_attack(my_player, start_coord, pos_coord, dryrun=false, 
				simulation=false):
	var can_eat = []
	
	var direction_ = get_direction(start_coord, pos_coord)

	match direction_:
		"right":
			can_eat.append_array(push_and_crush(Where.RIGHT, my_player, start_coord, 
				pos_coord, dryrun, simulation))
		"down":
			can_eat.append_array(push_and_crush(Where.BOTTOM, my_player, start_coord, 
				pos_coord, dryrun, simulation))
		"up":
			can_eat.append_array(push_and_crush(Where.TOP, my_player, start_coord, 
				pos_coord, dryrun, simulation))
		"left":
			can_eat.append_array(push_and_crush(Where.LEFT, my_player, start_coord, 
				pos_coord, dryrun, simulation))
	

	return can_eat



func push_and_crush(where, my_player, start_coord, target_pos, dryrun=false, 
				simulation=false):
	var can_eat = []
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
	
	# check if first is friendly
	var position_to_check = target_pos
	position_to_check[axis] = position_to_check[axis] + up
	
	var unit_r = city.get_soldier_on_position(position_to_check, simulation)
	if unit_r != null and unit_r["player"] == my_player:
		if unit_r["pg"] == start_coord:
			pass
		
		#position_to_check = unit_r["pg"]
		position_to_check[axis] = position_to_check[axis] + up
		var unit_rr = city.get_soldier_on_position(position_to_check, simulation)

		if unit_rr != null:
			# if the unit is on the edge of the city
			# if the unit is the enemies
			if unit_rr["player"] != my_player:
				if unit_rr["pg"] in city.border_tiles:
					#position_to_check = unit_rr["pg"]
					position_to_check[axis] = position_to_check[axis] + up
					
					if not position_to_check in city.all_board_positions:

						if not unit_rr.dux:
							if dryrun:
								can_eat.append([start_coord, target_pos, position_to_check])
							else:
								city.eat_unit(unit_rr["pg"])
				# if the unit is squashed between two other
				else:
					position_to_check = unit_rr["pg"]
					position_to_check[axis] = position_to_check[axis] + up
					var unit_rrr = city.get_soldier_on_position(position_to_check, simulation)
					
					if unit_rrr != null and unit_rrr["player"] == my_player:
						if not unit_rr["dux"]:
							if dryrun:
								can_eat.append([start_coord, target_pos, position_to_check])
							else:
								city.eat_unit(unit_rr["pg"])
	
	return can_eat


func eat_flank_attack(my_player, start_coord, pos_coord, dryrun=false, 
				simulation=false):
	var can_eat = []
	
	var direction_ = get_direction(start_coord, pos_coord)
	
	match direction_:
		"right":
			can_eat.append_array(flank_nomnom(Where.RIGHT, my_player, start_coord, 
				pos_coord, dryrun, simulation))
		"down":
			can_eat.append_array(flank_nomnom(Where.BOTTOM, my_player, start_coord, 
				pos_coord, dryrun, simulation))
		"up":
			can_eat.append_array(flank_nomnom(Where.TOP, my_player, start_coord, pos_coord, 
				dryrun, simulation))
		"left":
			can_eat.append_array(flank_nomnom(Where.LEFT, my_player, start_coord, pos_coord, 
				dryrun, simulation))
	

	return can_eat

func flank_nomnom(where, my_player, start_coord, target_pos, dryrun=false, 
			simulation=false):
	var can_eat = []
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
	var unit_r = city.get_soldier_on_position(position_to_check, simulation)
	#position_to_check[axis] = position_to_check[axis] + up
	#var unit_rr = city.get_soldier_on_position(position_to_check)
	#position_to_check[axis] = position_to_check[axis] + up
	#var unit_rrr = city.get_soldier_on_position(position_to_check)
	
	
	var enemy_unit_exists = false
	
	if unit_r != null and unit_r["player"] != my_player:
		enemy_unit_exists = true

	
	if enemy_unit_exists:
		var next_unit = null
		while true:
			position_to_check[axis] = position_to_check[axis] + up
			next_unit = city.get_soldier_on_position(position_to_check, simulation)

			if position_to_check not in city.all_board_positions or next_unit == null:
				break
			
			if next_unit["player"] == my_player:
				if not unit_r["dux"]:
					if dryrun:
						can_eat.append([start_coord, target_pos, position_to_check])
					else:
						city.eat_unit(unit_r["pg"])
	
	return can_eat


func eat_phalanx_attack(my_player, start_coord, pos_coord, dryrun=false,
				simulation=false):
	var can_eat = []
	
	
	var direction_ = get_direction(start_coord, pos_coord)

	match direction_:
		"right":
			can_eat.append_array(phalanx_attack(Where.RIGHT, my_player, start_coord, 
						pos_coord, dryrun, simulation))
		"down":
			can_eat.append_array(phalanx_attack(Where.BOTTOM, my_player, start_coord, 
						pos_coord, dryrun, simulation))
		"up":
			can_eat.append_array(phalanx_attack(Where.TOP, my_player, start_coord, 
						pos_coord, dryrun, simulation))
		"left":
			can_eat.append_array(phalanx_attack(Where.LEFT, my_player, start_coord, 
						pos_coord, dryrun, simulation))

	return can_eat

func phalanx_attack(where, my_player, start_coord, target_pos, dryrun=false, 
				simulation=false):
	var can_eat = []
	
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

	var next_position = target_pos
	next_position[axis] = target_pos[axis] + up
	
	var unit = city.get_soldier_on_position(next_position, simulation)
	if unit == null or unit["player"] != my_player:
		return can_eat
	# if the first unit is the one your are moving, shit is afoot, stop
	if next_position == start_coord:
		return can_eat

	# Perpendicular neighbours of the landing square (not front/back).
	var unit_sourounding_tiles = city.get_adjacent_tiles(target_pos, true)
	unit_sourounding_tiles.erase(start_coord)
	unit_sourounding_tiles.erase(target_pos)
	var xyz_pos = target_pos
	xyz_pos[axis] = xyz_pos[axis] - up
	unit_sourounding_tiles.erase(xyz_pos)
	unit_sourounding_tiles.erase(next_position)

	# Any friendly side that already has a matching friend on the first rank
	# is a candidate testudo. Extra pieces on the other flank do not cancel it.
	var candidates: Array = []
	for side_pos in unit_sourounding_tiles:
		var side_unit = city.get_soldier_on_position(side_pos, simulation)
		if side_unit == null or side_unit["player"] != my_player:
			continue
		if side_unit["pg"] == start_coord:
			continue
		var dv = signed_axis(target_pos, side_pos)
		if dv in candidates:
			continue
		if _testudo_rank_ok(next_position, dv, my_player, simulation):
			candidates.append(dv)

	for diff_vector in candidates:
		var scan_pos = next_position
		var captured = false
		while true:
			scan_pos[axis] = scan_pos[axis] + up
			var unit_r = city.get_soldier_on_position(scan_pos, simulation)

			if unit_r != null and unit_r["player"] != my_player:
				if not unit_r["dux"]:
					if dryrun:
						can_eat.append([start_coord, target_pos, scan_pos])
					else:
						city.eat_unit(unit_r["pg"])
					captured = true
				break
			elif unit_r != null and unit_r["player"] == my_player:
				if not _testudo_rank_ok(scan_pos, diff_vector, my_player, simulation):
					break
			else:
				break
		if captured:
			break

	return can_eat

func _testudo_rank_ok(rank_pos, diff_vector, my_player, simulation):
	var test_yes_unit = city.get_soldier_on_position(rank_pos + diff_vector, simulation)
	return test_yes_unit != null and test_yes_unit["player"] == my_player

# Unit axis (±1 on the dominant axis) from `from_p` toward `to_p`
func signed_axis(from_p: Vector2i, to_p: Vector2i) -> Vector2i:
	var d := to_p - from_p
	if abs(d.x) >= abs(d.y):
		return Vector2i(sign(d.x), 0)
	else:
		return Vector2i(0, sign(d.y))

func get_direction(start: Vector2, end: Vector2) -> String:
	var d := end - start
	if abs(d.x) > abs(d.y):
		return "right" if d.x > 0 else "left"
	elif abs(d.y) > 0:
		return "down" if d.y < 0 else "up"
	else:
		return "same spot"
		
		
func xxi_eatable_rules(my_player, start_coord, pos_coord, dryrun=false, 
				simulation=false):
	var can_eat = []
	can_eat.append_array(basic.basic_plus_eatable_rules(my_player, start_coord, 
				pos_coord, dryrun, simulation))
	
	
	can_eat.append_array(eatable_rules(my_player, start_coord, pos_coord, dryrun,
				simulation))
	
	return can_eat


func rm_duplicates_in_list(my_list):
	var seen := {}
	var out: Array = []
	for v in my_list:
		if not seen.has(v):
			seen[v] = true
			out.append(v)
	my_list = out

func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
	
