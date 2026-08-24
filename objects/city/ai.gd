extends Node

@onready var city = get_parent()


var rng := RandomNumberGenerator.new()

const SIMS_PER_FRAME := 8
var _sims_this_frame := 0


# get all units
# get all possible moves for that unit
# check all positions, if you can eat anything
# if you cannot eat anything, move randomly somewhere
# if you can eat something, choose randomly one
# throw a random if you actually will eat. if fails, choose randomly one of the places you can move

func execute_move(my_player):
	print("AI moving")
	_sims_this_frame = 0

	#var player_actions = get_player_actions(my_player, false)
	var simulation = false
	var player_actions = city.where_can_player_move(my_player, simulation)
	await _think_yield()
	
	var units_with_possible_eat = player_actions["units_with_possible_eat"]
	var units_att_dux = player_actions["units_att_dux"]
	var possible_moves = player_actions["possible_moves"]
	
	
	var ai_lvl = GlobalSet.settings["ai_lvl"]
	var ai_perc = ai_perc_set()
	var random_value
	
	# check option to attack
	var eat = false
	if len(units_with_possible_eat) > 0:
		eat = chance(ai_perc)
		
		if eat:
			print("eating")
			if ai_lvl == city.Ai_lvl.HARD:
				var safe_eats = []
				for move in units_with_possible_eat:
					new_scenarion()
					var unit_s = city.get_soldier_on_position(move[0], true)
					unit_s["pg"] = move[1]
					var eaten_s = city.get_soldier_on_position(move[2], true)
					if eaten_s:
						city.vcb_sim.erase(eaten_s["id"])
					var opp_actions = city.where_can_player_move(othr_p(my_player), true)
					var opp_eats = opp_actions["units_with_possible_eat"]
					var is_safe = true
					for opp_eat in opp_eats:
						if opp_eat[2] == move[1]:
							is_safe = false
							break
					if is_safe and is_dux_move_safe(move, my_player) and is_own_dux_safe_in_sim(my_player):
						safe_eats.append(move)
					await _think_yield()
				if len(safe_eats) > 0:
					random_value = pop_random_fast(safe_eats)
					city.move_unit(my_player, random_value[0], random_value[1])
					return
				print("no safe eats, falling through")
			elif ai_lvl == city.Ai_lvl.EASY:
				random_value = pop_random_fast(units_with_possible_eat)
				city.move_unit(my_player, random_value[0], random_value[1])
				return
			else:
				var dux_safe_eats = units_with_possible_eat.filter(func(m): return is_dux_move_safe(m, my_player))
				if len(dux_safe_eats) > 0:
					random_value = pop_random_fast(dux_safe_eats)
					city.move_unit(my_player, random_value[0], random_value[1])
					return
				print("no dux-safe eats for normal, falling through")
		else:
			print("not eating")
	
	# check if you can have a unit eaten
	if ai_lvl != city.Ai_lvl.EASY:
		var possible_intercept = []
		
		new_scenarion()
		
		var simulation_ss = true
		# enemy moves
		var player_actions_ss = city.where_can_player_move(othr_p(my_player), simulation_ss)
		await _think_yield()
		var units_with_possible_eat_s = player_actions_ss["units_with_possible_eat"]
		
		var player_actions_my = city.where_can_player_move(my_player, simulation_ss)
		await _think_yield()
		var player_poss_moves = player_actions_my["possible_moves"]

		for att_move in units_with_possible_eat_s:
			# check if it collides with possible moves your units can make,
			# and then move that unit to prevent from eating
			for move in player_poss_moves:
				# if the eating unit will move to a possible move
				# and if the unit with the possible move is not the one who will be eaten
				if att_move[1] == move[1] and att_move[2] != move[0]:
					print("intercepting")
					possible_intercept.append(move)
		
		var safe_intercepts = possible_intercept.filter(func(m): return is_dux_move_safe(m, my_player))
		if len(safe_intercepts) != 0:
			random_value = pop_random_fast(safe_intercepts)
			city.move_unit(my_player, random_value[0], random_value[1])
			return
		

	
	var eat_dux = false
	if not eat and len(units_att_dux) > 0:
		print("going after the dux")
		eat_dux = chance(ai_perc)
		
		if eat_dux:
			# Don't send own dux at enemy dux unless enemy dux is already cornered
			var enemy_dux_pos = null
			for u in city.vcb.values():
				if u["player"] == othr_p(my_player) and u["dux"] == true:
					enemy_dux_pos = u["pg"]
					break
			if enemy_dux_pos:
				var bt = city.get_blocking_tiles(enemy_dux_pos, othr_p(my_player))
				if len(bt[2]) > 2:
					units_att_dux = units_att_dux.filter(func(m):
						var unit = city.get_soldier_on_position(m[0])
						return unit == null or unit["dux"] != true
					)
			
			if ai_lvl == city.Ai_lvl.EASY:
				if units_att_dux.is_empty():
					print("no good moves available")
				else:
					random_value = units_att_dux.pick_random()
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
					unit_s["pg"] = move[1]
					# calculate, if it can be eaten
					var player_actions_s = city.where_can_player_move(othr_p(my_player), simulation_s)
					
					var units_with_possible_eat_s = player_actions_s["units_with_possible_eat"]
					for att_move in units_with_possible_eat_s:
						if att_move[2] == move[1]:
							units_att_dux.erase(move)
					await _think_yield()

				var dux_safe_att = units_att_dux.filter(func(m): return is_dux_move_safe(m, my_player))
				if dux_safe_att.is_empty():
					print("no good moves available")
				else:
					random_value = dux_safe_att.pick_random()
					city.move_unit(my_player, random_value[0], random_value[1])
					return
		else:
			print("deciding not to")
				
	
	if ai_lvl != city.Ai_lvl.EASY:
		var my_dux = null
		for u in city.vcb.values():
			if u["player"] == my_player and u["dux"] == true:
				my_dux = u
				break
		if my_dux:
			var bt = city.get_blocking_tiles(my_dux["pg"], my_player)
			var free_tiles = bt[2]
			if len(free_tiles) <= 2:
				print("dux rescue mode")
				var dux_adj = city.get_adjacent_tiles(my_dux["pg"])
				var rescue_moves = []
				for move in possible_moves:
					if move[0] in dux_adj and move[0] != my_dux["pg"]:
						if is_dux_move_safe(move, my_player):
							rescue_moves.append(move)
				if len(rescue_moves) > 0:
					var chosen = rescue_moves.pick_random()
					city.move_unit(my_player, chosen[0], chosen[1])
					return

	if ai_lvl == city.Ai_lvl.HARD:
		var safe_moves = []
		for move in possible_moves:
			new_scenarion()
			var unit_s = city.get_soldier_on_position(move[0], true)
			unit_s["pg"] = move[1]
			var opp_actions = city.where_can_player_move(othr_p(my_player), true)
			var opp_eats = opp_actions["units_with_possible_eat"]
			var dominated = false
			for opp_eat in opp_eats:
				if opp_eat[2] == move[1]:
					dominated = true
					break
			if not dominated and is_dux_move_safe(move, my_player) and is_own_dux_safe_in_sim(my_player):
				safe_moves.append(move)
			await _think_yield()
		if len(safe_moves) > 0:
			var center = Vector2(city.city_size) / 2.0
			safe_moves.sort_custom(func(a, b):
				return Vector2(a[1]).distance_to(center) < Vector2(b[1]).distance_to(center)
			)
			var top_n = safe_moves.slice(0, min(3, safe_moves.size()))
			var chosen = top_n.pick_random()
			city.move_unit(my_player, chosen[0], chosen[1])
			return
	
	if ai_lvl != city.Ai_lvl.EASY:
		var dux_safe_moves = possible_moves.filter(func(m): return is_dux_move_safe(m, my_player))
		if len(dux_safe_moves) > 0:
			random_value = dux_safe_moves.pick_random()
			city.move_unit(my_player, random_value[0], random_value[1])
			return

	if possible_moves.is_empty():
		print("no moves available")
		return
	random_value = possible_moves.pick_random()
	city.move_unit(my_player, random_value[0], random_value[1])



func _think_yield():
	_sims_this_frame += 1
	if _sims_this_frame >= SIMS_PER_FRAME:
		_sims_this_frame = 0
		await get_tree().process_frame


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
		city.Ai_lvl.HARD:
			return 0.95


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
	city.vcb_sim = {}
	
	for valu_ in city.vcb.keys():
		var new_unit = {"pg": city.vcb[valu_]["pg"],
						"player": city.vcb[valu_]["player"],
						"dux": city.vcb[valu_]["dux"],
						"id": city.vcb[valu_]["id"]}
						
		city.vcb_sim[valu_] = new_unit


func is_dux_move_safe(move, my_player) -> bool:
	var unit = city.get_soldier_on_position(move[0])
	if unit == null or unit["dux"] != true:
		return true
	var blocking = city.get_blocking_tiles(move[1], my_player)
	var free_tiles = blocking[2]
	var actual_free = len(free_tiles)
	if move[0] in city.get_adjacent_tiles(move[1]):
		actual_free += 1
	return actual_free >= 2


func is_own_dux_safe_in_sim(my_player) -> bool:
	for u in city.vcb_sim.values():
		if u["player"] == my_player and u["dux"] == true:
			var bt = city.get_blocking_tiles(u["pg"], my_player, false, true)
			return len(bt[2]) >= 2
	return true


func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1
