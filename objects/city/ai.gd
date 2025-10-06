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

func execute_move(my_player):
	print("AI moving")

	#var player_actions = get_player_actions(my_player, false)
	var simulation = false
	var player_actions = city.where_can_player_move(my_player, simulation)
	
	var units_with_possible_eat = player_actions["units_with_possible_eat"]
	var units_att_dux = player_actions["units_att_dux"]
	var possible_moves = player_actions["possible_moves"]
	
	
	var ai_lvl = GlobalSet.settings["ai_lvl"]
	var ai_perc = ai_perc_set()
	
	# check option to attack
	var eat = false
	if len(units_with_possible_eat) > 0:
		eat = chance(ai_perc)
		
		if eat:
			print("eating")
			#var random_value = units_with_possible_eat.pick_random()
			var random_value = pop_random_fast(units_with_possible_eat)
			if ai_lvl == city.Ai_lvl.EASY:
				city.move_unit(my_player, random_value[0], random_value[1])
				return
				# check if you get eaten on that spot
				#while true:
					#pass#if check_if_eaten()
			else:
				city.move_unit(my_player, random_value[0], random_value[1])
				return
		else:
			print("not eating")
	
	var eat_dux = false
	if not eat and len(units_att_dux) > 0:
		print("going after the dux")
		eat_dux = true#chance(ai_perc) FIXXXX THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
		
		if eat_dux:
			if ai_lvl == city.Ai_lvl.EASY:
				if city.all_moves > city.moves_till_attack_dux_ai:
					var random_value = units_att_dux.pick_random()
					city.move_unit(my_player, random_value[0], random_value[1])
					return
			else:
				var units_att_dux_copy = units_att_dux.duplicate()
				for move in units_att_dux_copy:
					# simulate to see, if the opponent can eat your unit
					new_scenarion()
					#print($"../simulation".get_children())
					#print(move[0])
					#for unit in city.get_soldiers(1,true):
					#	print(unit.position_grid)
					# move unit
					var simulation_s = true
					var unit_s = city.get_soldier_on_position(move[0], simulation_s)
					unit_s.position_grid = move[1]
					# calculate, if it can be eaten
					var player_actions_s = city.where_can_player_move(othr_p(my_player), simulation_s)

					var units_with_possible_eat_s = player_actions_s["units_with_possible_eat"]
					for att_move in units_with_possible_eat_s:
						if att_move[2] == move[1]:
							units_att_dux.erase(move)

				var random_value = units_att_dux.pick_random()

				if random_value != null:
					city.move_unit(my_player, random_value[0], random_value[1])
					return
				else:
					print("no good moves available")
		else:
			print("deciding not to")
				
	
	var random_value = possible_moves.pick_random()
	
	city.move_unit(my_player, random_value[0], random_value[1])



func chance(prob: float) -> bool:
	# prob in 0.0 .. 1.0 (e.g., 0.2 for 20%)
	prob = clamp(prob, 0.0, 1.0)
	return rng.randf() < prob




func ai_perc_set():
	match int(GlobalSet.settings["ai_lvl"]):
		city.Ai_lvl.EASY:
			return 0.65
		city.Ai_lvl.NORMAL:
			return 0.85


func pop_random_fast(arr: Array) -> Variant:
	if arr.is_empty():
		return null
	var i := randi_range(0, arr.size() - 1)
	var v = arr[i]
	arr[i] = arr.back()
	arr.pop_back()
	return v


func new_scenarion():
	# clear all
	for unit in $"../simulation".get_children():
		unit.free()
	
	for unit in $"../soldiers".get_children():
		var new_unit = city.SoldierUnitScene.instantiate()
		new_unit.player = unit.player
		new_unit.dux = unit.dux
		$"../simulation".add_child(new_unit)
		new_unit.set_position_grid(unit.position_grid)


func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
