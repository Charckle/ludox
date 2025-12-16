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



func get_basic_moves(soldier_pos, dryrun=false, simulation=false):
	# check bottom positions
	var _possible_moves_local = []
	var ckeck_from = soldier_pos
	
	# fix this....
	while true:
		ckeck_from.y = ckeck_from.y - 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from, simulation) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check top positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.y = ckeck_from.y + 1
				
		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from, simulation) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check left positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x - 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from, simulation) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check right positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x + 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from, simulation) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	if dryrun:
		return _possible_moves_local
	else:
		city.possible_moves = _possible_moves_local


func basic_eatable_rules(my_player, start_coord, pos_coord, dryrun=false, simulation=false):
	var can_eat = []
	# check bottom
	can_eat.append_array(check_basic_kill(Where.BOTTOM, my_player, 
			start_coord, pos_coord, dryrun, simulation))
	# check top
	can_eat.append_array(check_basic_kill(Where.TOP, my_player, 
			start_coord, pos_coord, dryrun, simulation))
	# check left
	can_eat.append_array(check_basic_kill(Where.LEFT, my_player, 
			start_coord, pos_coord, dryrun, simulation))
	# check right
	can_eat.append_array(check_basic_kill(Where.RIGHT, my_player, 
			start_coord, pos_coord, dryrun, simulation))

	return can_eat

func check_basic_kill(where: Where, my_player, start_coord, pos_coord, 
						dryrun=false, simulation=false):
	var can_eat = [] # start position, move position, eat position, is dux
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
	var enemy_unit = city.get_soldier_on_position(position_to_check, simulation)
	if enemy_unit != null:
		if enemy_unit["player"] != my_player:
			position_to_check[axis] = position_to_check[axis] + up
			var friendly_unit = city.get_soldier_on_position(position_to_check, simulation)
			
			if friendly_unit != null and friendly_unit["player"] == my_player:
				if enemy_unit["dux"] == false:
					if not dryrun:
						city.eat_unit(enemy_unit["pg"], simulation)
					else:
						can_eat.append([start_coord, pos_coord, enemy_unit["pg"]])
	
	return can_eat


func basic_plus_eatable_rules_old(my_player, start_coord, pos_coord, dryrun=false, 
							simulation=false):
	var can_eat = []
	
	can_eat.append_array(basic_eatable_rules(my_player, start_coord, 
					pos_coord, dryrun, simulation))
	# check corners
	# Check top, bottom, left right, if there is an enemy
	
	#can_eat.append(basic_eatable_rules(my_player, start_coord, pos_coord, dryrun))
	var adj_tiles = city.get_adjacent_tiles(pos_coord)
	
	# if there is, check if its in a corner
	for tile_coord in adj_tiles:
		#print(corners)
		if tile_coord in city.corners["all"]:
			# check if unit there
			var unit_ = city.get_soldier_on_position(tile_coord, simulation)
			if unit_ != null and unit_["player"] != my_player:
				# check if that unit ha another player unit alongside it
				var enemy_adj_tiles = city.get_adjacent_tiles(unit_["pg"])
				# remove the player unit
				enemy_adj_tiles.erase(pos_coord)
				for adj_tile_coord in enemy_adj_tiles:
					var unit_adj = city.get_soldier_on_position(adj_tile_coord, simulation)
					if unit_adj != null:
						if unit_adj["player"] == my_player:
							if unit_["dux"] == false:
								if not dryrun:
									city.eat_unit(unit_["pg"])
								else:
									can_eat.append([start_coord, pos_coord, unit_["pg"]])

	return can_eat


func basic_plus_eatable_rules(my_player, start_coord, pos_coord, dryrun=false, 
							simulation=false):
	var can_eat = []
	
	can_eat.append_array(basic_eatable_rules(my_player, start_coord, 
					pos_coord, dryrun, simulation))
	# check corners
	# Check top, bottom, left right, if there is an enemy
	
	#can_eat.append(basic_eatable_rules(my_player, start_coord, pos_coord, dryrun))
	var adj_tiles = city.get_adjacent_tiles(pos_coord)
	
	# if there is, check if its in a corner
	for tile_coord in adj_tiles:
		#print(corners)
		if tile_coord in city.corners["all"]:
			# check if unit there
			var unit_ = city.get_soldier_on_position(tile_coord, simulation)
			if unit_ != null and unit_["player"] != my_player:
				# check if that unit has another player unit alongside it
				var enemy_adj_tiles = city.get_adjacent_tiles(unit_["pg"])
				# remove the player unit
				enemy_adj_tiles.erase(pos_coord)
				for adj_tile_coord in enemy_adj_tiles:
					var unit_adj = city.get_soldier_on_position(adj_tile_coord, simulation)
					if unit_adj != null:
						if unit_adj["player"] == my_player:
							if unit_["dux"] == false:
								if not dryrun:
									city.eat_unit(unit_["pg"])
								else:
									can_eat.append([start_coord, pos_coord, unit_["pg"]])

	return can_eat


func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
