extends Node

@onready var city = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# get all units
# get all possible moves for that unit
# check all positions, if you can eat anything
# if you cannot eat anything, move randomly somewhere
# if you can eat something, choose randomly one
# throw a random if you actually will eat. if fails, choose randomly one of the places you can move

func execute_move():
	print("AI moving")
	var soldiers = city.get_soldiers(city.player_turn)
	
	var units_with_possible_eat = []
	var units_att_dux = []
	var possible_moves = []
	
	for unit in soldiers:
		var start_coord = unit.position_grid
		var poss_moves = city.get_possible_moves(start_coord, true)
		
		for move in poss_moves:
			possible_moves.append([start_coord, move])
			var is_eatable = city.check_if_eatable(start_coord, move, true)
			var tile =  city.get_tile_on_position(move)
			
			#var is_eatable = false
			if is_eatable:
				units_with_possible_eat.append([unit.position_grid, move])
				#break
			if tile.do_adj_dux(city, city.get_enemy_pid()):
				units_att_dux.append([unit.position_grid, move])
	
	if len(units_with_possible_eat) > 0:
		var random_value = units_with_possible_eat.pick_random()
		
		city.move_unit(random_value[0], random_value[1])
		#print(random_value)
	elif len(units_att_dux) > 0:
		var random_value = units_att_dux.pick_random()
		city.move_unit(random_value[0], random_value[1])
	else:
		var random_value = possible_moves.pick_random()
		#print(random_value)
		city.move_unit(random_value[0], random_value[1])
	
