extends Node

@onready var city = get_parent()


var rng := RandomNumberGenerator.new()

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
	var ai_lvl = GlobalSet.settings["ai_lvl"]
	
	var ai_perc = ai_perc_set()
	print(ai_perc)
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
	
	# check option to attack
	var eat = false
	if len(units_with_possible_eat) > 0:
		eat = chance(ai_perc)
		
		if eat:
			#var random_value = units_with_possible_eat.pick_random()
			var random_value = pop_random_fast(units_with_possible_eat)
			if ai_lvl == city.Ai_lvl.EASY:
				city.move_unit(random_value[0], random_value[1])
				return
				# check if you get eaten on that spot
				#while true:
					#pass#if check_if_eaten()
			else:
				city.move_unit(random_value[0], random_value[1])
				return
			
	
	var eat_dux = false
	if not eat and len(units_att_dux) > 0:
		eat_dux = chance(ai_perc)
		
		if eat_dux:
			var random_value = units_att_dux.pick_random()
			city.move_unit(random_value[0], random_value[1])
			
			return
	else:
		var random_value = possible_moves.pick_random()
		
		city.move_unit(random_value[0], random_value[1])
		return



func chance(prob: float) -> bool:
	# prob in 0.0 .. 1.0 (e.g., 0.2 for 20%)
	prob = clamp(prob, 0.0, 1.0)
	return rng.randf() < prob


func ai_perc_set():
	match GlobalSet.settings["ai_lvl"]:
		city.Ai_lvl.EASY:
			return 0.65
		city.Ai_lvl.NORMAL:
			return 0.9


func pop_random_fast(arr: Array) -> Variant:
	if arr.is_empty():
		return null
	var i := randi_range(0, arr.size() - 1)
	var v = arr[i]
	arr[i] = arr.back()
	arr.pop_back()
	return v
