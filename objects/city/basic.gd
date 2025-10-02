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



func get_basic_moves(soldier_pos, dryrun=false):
	# check bottom positions
	var _possible_moves_local = []
	var ckeck_from = soldier_pos
	
	while true:
		ckeck_from.y = ckeck_from.y - 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check top positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.y = ckeck_from.y + 1
				
		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check left positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x - 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	# check right positions
	ckeck_from = soldier_pos
	while true:
		ckeck_from.x = ckeck_from.x + 1

		if ckeck_from in city.all_board_positions and city.get_soldier_on_position(ckeck_from) == null:
			_possible_moves_local.append(ckeck_from)
		else:
			break
	
	if dryrun:
		return _possible_moves_local
	else:
		city.possible_moves = _possible_moves_local


func basic_eatable_rules(my_player, start_coord, pos_coord, dryrun=false):
	var can_eat = []
	# check bottom
	can_eat.append(check_basic_kill(Where.BOTTOM, my_player, pos_coord, dryrun))
	# check top
	can_eat.append(check_basic_kill(Where.TOP, my_player, pos_coord, dryrun))
	# check left
	can_eat.append(check_basic_kill(Where.LEFT, my_player, pos_coord, dryrun))
	# check right
	can_eat.append(check_basic_kill(Where.RIGHT, my_player, pos_coord, dryrun))

	if dryrun:
		if true in can_eat:
			return true
		else:
			return false

func check_basic_kill(where: Where, my_player, pos_coord, dryrun=false):
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
	var enemy_unit = city.get_soldier_on_position(position_to_check)
	if enemy_unit != null:
		if enemy_unit.player != my_player:
			position_to_check[axis] = position_to_check[axis] + up
			var friendly_unit = city.get_soldier_on_position(position_to_check)
			if friendly_unit != null and friendly_unit.player == my_player:
				if enemy_unit.dux == false:
					if not dryrun:
						city.eat_unit(enemy_unit)
					else:
						can_eat = true

	return can_eat


func basic_plus_eatable_rules(my_player, start_coord, pos_coord, dryrun=false):
	var can_eat = []

	can_eat.append(basic_eatable_rules(my_player, start_coord, pos_coord, dryrun))
	# check corners
	# Check top, bottom, left right, if there is an enemy
	
	can_eat.append(basic_eatable_rules(my_player, start_coord, pos_coord, dryrun))
	
	var current_tile = city.get_tile_on_position(pos_coord)

	var adj_tiles = current_tile.get_adjacent_tiles(city)
	
	# if there is, check if its in a corner
	for tile_coord in adj_tiles:
		#print(corners)
		if tile_coord in city.corners["all"]:
			# check if unit there
			var unit_ = city.get_soldier_on_position(tile_coord)
			if unit_ != null and unit_.player != my_player:
				# check if that unit ha another player unit alongside it
				var enemy_adj_tiles = unit_.get_adjacent_tiles(city)
				# remove the player unit
				enemy_adj_tiles.erase(pos_coord)
				for adj_tile_coord in enemy_adj_tiles:
					var unit_adj = city.get_soldier_on_position(adj_tile_coord)
					if unit_adj != null:
						if unit_adj.player == my_player:
							if unit_.dux == false:
								if not dryrun:
									can_eat.append(true)
									city.eat_unit(unit_)
									
	if dryrun:
		if true in can_eat:
			return true
		else:
			return false


func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
