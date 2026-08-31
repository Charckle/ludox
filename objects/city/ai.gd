extends Node

@onready var city = get_parent()


var rng := RandomNumberGenerator.new()

const SIMS_PER_FRAME := 8
var _sims_this_frame := 0


func execute_move(my_player):
	print("AI moving")
	_sims_this_frame = 0

	var simulation = false
	var player_actions = city.where_can_player_move(my_player, simulation)
	await _think_yield()

	var units_with_possible_eat = player_actions["units_with_possible_eat"]
	var units_att_dux = player_actions["units_att_dux"]
	var possible_moves = player_actions["possible_moves"]

	var ai_lvl = GlobalSet.settings["ai_lvl"]
	var ai_perc = ai_perc_set()
	var hard_plus = _is_hard_plus(ai_lvl)
	var caesar = ai_lvl == city.Ai_lvl.CAESAR
	var random_value

	# check option to attack
	var eat = false
	if len(units_with_possible_eat) > 0:
		eat = chance(ai_perc)

		if eat:
			print("eating")
			if hard_plus:
				var safe_eats = []
				var best_opp_eats := 999
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
						var opp_n = _unique_eat_count(opp_eats)
						if caesar:
							if opp_n < best_opp_eats:
								best_opp_eats = opp_n
								safe_eats = [move]
							elif opp_n == best_opp_eats:
								safe_eats.append(move)
						else:
							safe_eats.append(move)
					await _think_yield()
				if len(safe_eats) > 0:
					random_value = pop_random_fast(safe_eats)
					city.move_unit(my_player, random_value[0], random_value[1])
					return
				print("no safe eats, falling through")
			elif ai_lvl == city.Ai_lvl.EASY:
				var sane_eats = units_with_possible_eat.filter(
					func(m): return is_dux_move_safe(m, my_player))
				if len(sane_eats) > 0:
					random_value = pop_random_fast(sane_eats)
					city.move_unit(my_player, random_value[0], random_value[1])
					return
				print("no sane eats for easy, falling through")
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
		var player_actions_ss = city.where_can_player_move(othr_p(my_player), simulation_ss)
		await _think_yield()
		var units_with_possible_eat_s = player_actions_ss["units_with_possible_eat"]

		var player_actions_my = city.where_can_player_move(my_player, simulation_ss)
		await _think_yield()
		var player_poss_moves = player_actions_my["possible_moves"]

		for att_move in units_with_possible_eat_s:
			var path_squares := []
			if caesar:
				path_squares = _squares_between(att_move[0], att_move[1])
			for move in player_poss_moves:
				if att_move[2] == move[0]:
					continue
				if att_move[1] == move[1]:
					print("intercepting")
					possible_intercept.append(move)
				elif caesar and move[1] in path_squares:
					possible_intercept.append(move)

		var safe_intercepts = possible_intercept.filter(func(m): return is_dux_move_safe(m, my_player))
		if caesar and len(safe_intercepts) > 0:
			safe_intercepts = await _filter_caesar_intercepts(safe_intercepts, my_player)
		if len(safe_intercepts) != 0:
			random_value = pop_random_fast(safe_intercepts)
			city.move_unit(my_player, random_value[0], random_value[1])
			return

	var eat_dux = false
	if not eat and len(units_att_dux) > 0:
		print("going after the dux")
		eat_dux = chance(ai_perc)

		if eat_dux:
			units_att_dux = units_att_dux.filter(
				func(m): return is_dux_move_safe(m, my_player))

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
					if not _apply_move_to_sim(move):
						units_att_dux.erase(move)
						await _think_yield()
						continue
					var player_actions_s = city.where_can_player_move(othr_p(my_player), true)
					var units_with_possible_eat_s = player_actions_s["units_with_possible_eat"]
					for att_move in units_with_possible_eat_s:
						if att_move[2] == move[1]:
							units_att_dux.erase(move)
							break
					if move in units_att_dux and not is_own_dux_safe_in_sim(my_player):
						units_att_dux.erase(move)
					await _think_yield()

				if units_att_dux.is_empty():
					print("no good moves available")
				else:
					random_value = units_att_dux.pick_random()
					city.move_unit(my_player, random_value[0], random_value[1])
					return
		else:
			print("deciding not to")

	var my_dux = _live_dux(my_player)
	if my_dux:
		var bt = city.get_blocking_tiles(my_dux["pg"], my_player)
		var free_tiles = bt[2]
		if len(free_tiles) <= 2:
			print("dux rescue mode")
			var dux_adj = city.get_adjacent_tiles(my_dux["pg"])
			var rescue_moves = []
			for move in possible_moves:
				if move[0] in dux_adj and move[0] != my_dux["pg"]:
					if is_dux_move_safe(move, my_player, true):
						rescue_moves.append(move)
			if len(rescue_moves) > 0:
				var chosen = rescue_moves.pick_random()
				city.move_unit(my_player, chosen[0], chosen[1])
				return

	if caesar:
		var caesar_move = await _pick_caesar_quiet(possible_moves, my_player, player_actions)
		if caesar_move != null:
			city.move_unit(my_player, caesar_move[0], caesar_move[1])
			return
	elif ai_lvl == city.Ai_lvl.HARD:
		var pawn_safe = []
		var dux_safe = []
		for move in possible_moves:
			new_scenarion()
			var unit_s = city.get_soldier_on_position(move[0], true)
			if unit_s == null:
				await _think_yield()
				continue
			unit_s["pg"] = move[1]
			var opp_actions = city.where_can_player_move(othr_p(my_player), true)
			var opp_eats = opp_actions["units_with_possible_eat"]
			var dominated = false
			for opp_eat in opp_eats:
				if opp_eat[2] == move[1]:
					dominated = true
					break
			if not dominated and is_dux_move_safe(move, my_player) and is_own_dux_safe_in_sim(my_player):
				if _is_dux_piece(move[0]):
					dux_safe.append(move)
				else:
					pawn_safe.append(move)
			await _think_yield()
		var safe_moves = pawn_safe if len(pawn_safe) > 0 else dux_safe
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
		if hard_plus:
			var pawn_moves = dux_safe_moves.filter(func(m): return not _is_dux_piece(m[0]))
			if len(pawn_moves) > 0:
				random_value = pawn_moves.pick_random()
				city.move_unit(my_player, random_value[0], random_value[1])
				return
		if len(dux_safe_moves) > 0:
			random_value = dux_safe_moves.pick_random()
			city.move_unit(my_player, random_value[0], random_value[1])
			return

	if possible_moves.is_empty():
		print("no moves available")
		return
	var sane_moves = possible_moves.filter(func(m): return is_dux_move_safe(m, my_player))
	if sane_moves.is_empty():
		print("only suicidal dux moves left")
		random_value = possible_moves.pick_random()
	else:
		random_value = sane_moves.pick_random()
	city.move_unit(my_player, random_value[0], random_value[1])


func _pick_caesar_quiet(possible_moves, my_player, player_actions):
	var base_own = _unique_eat_count(player_actions["units_with_possible_eat"])
	new_scenarion()
	var base_opp_actions = city.where_can_player_move(othr_p(my_player), true)
	await _think_yield()
	var base_opp = _unique_eat_count(base_opp_actions["units_with_possible_eat"])
	var base_form = _formation_score(my_player, false)

	var scored := []
	for move in possible_moves:
		if not is_dux_move_safe(move, my_player):
			await _think_yield()
			continue
		new_scenarion()
		var unit_s = city.get_soldier_on_position(move[0], true)
		if unit_s == null:
			await _think_yield()
			continue
		unit_s["pg"] = move[1]
		if not is_own_dux_safe_in_sim(my_player):
			await _think_yield()
			continue
		var opp_actions = city.where_can_player_move(othr_p(my_player), true)
		var opp_eats = opp_actions["units_with_possible_eat"]
		var dominated = false
		for opp_eat in opp_eats:
			if opp_eat[2] == move[1]:
				dominated = true
				break
		if dominated:
			await _think_yield()
			continue
		var my_actions = city.where_can_player_move(my_player, true)
		var own_n = _unique_eat_count(my_actions["units_with_possible_eat"])
		var opp_n = _unique_eat_count(opp_eats)
		var form = _formation_score(my_player, true)
		var score = 0
		score += (own_n - base_own) * 80
		score += (base_opp - opp_n) * 90
		score += (form - base_form)
		score += _forward_delta(move, my_player) * 4
		if _abandons_unique_pin(move[0], my_player):
			score -= 45
		if _is_dux_piece(move[0]) and own_n <= base_own and opp_n >= base_opp:
			score -= 70
			if _forward_delta(move, my_player) <= 0:
				score -= 40
		scored.append([score, move])
		await _think_yield()

	if scored.is_empty():
		return null
	scored.sort_custom(func(a, b): return a[0] > b[0])
	var best: int = scored[0][0]
	var top := []
	for entry in scored:
		if entry[0] >= best - 8 and top.size() < 3:
			top.append(entry[1])
		else:
			if entry[0] < best - 8:
				break
	print("caesar quiet score ", best)
	return top.pick_random()


func _filter_caesar_intercepts(intercepts, my_player):
	var kept := []
	for move in intercepts:
		new_scenarion()
		var unit_s = city.get_soldier_on_position(move[0], true)
		if unit_s == null:
			await _think_yield()
			continue
		unit_s["pg"] = move[1]
		if not is_own_dux_safe_in_sim(my_player):
			await _think_yield()
			continue
		var opp_actions = city.where_can_player_move(othr_p(my_player), true)
		var dominated = false
		for opp_eat in opp_actions["units_with_possible_eat"]:
			if opp_eat[2] == move[1]:
				dominated = true
				break
		if not dominated:
			kept.append(move)
		await _think_yield()
	if kept.is_empty():
		return []
	var hold_pin := []
	for move in kept:
		if not _abandons_unique_pin(move[0], my_player):
			hold_pin.append(move)
	if len(hold_pin) > 0:
		return hold_pin
	return kept


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
		city.Ai_lvl.CAESAR:
			return 1.0
		_:
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
	city.vcb_sim = {}

	for valu_ in city.vcb.keys():
		var new_unit = {"pg": city.vcb[valu_]["pg"],
						"player": city.vcb[valu_]["player"],
						"dux": city.vcb[valu_]["dux"],
						"id": city.vcb[valu_]["id"]}

		city.vcb_sim[valu_] = new_unit


func _apply_move_to_sim(move) -> bool:
	new_scenarion()
	var unit_s = city.get_soldier_on_position(move[0], true)
	if unit_s == null:
		return false
	unit_s["pg"] = move[1]
	if move.size() > 2:
		var eaten_s = city.get_soldier_on_position(move[2], true)
		if eaten_s:
			city.vcb_sim.erase(eaten_s["id"])
	return true


func is_dux_move_safe(move, my_player, rescue: bool = false) -> bool:
	var unit = city.get_soldier_on_position(move[0])
	if unit == null or unit["dux"] != true:
		return true
	if not _apply_move_to_sim(move):
		return false
	return _eval_dux_in_sim(my_player, rescue, true)


func is_own_dux_safe_in_sim(my_player, rescue: bool = false) -> bool:
	return _eval_dux_in_sim(my_player, rescue, false)


func _live_dux(my_player) -> Variant:
	for u in city.vcb.values():
		if u["player"] == my_player and u["dux"] == true:
			return u
	return null


func _live_dux_in_rescue(my_player) -> bool:
	var dux: Variant = _live_dux(my_player)
	if dux == null:
		return false
	return len(city.get_blocking_tiles(dux["pg"], my_player)[2]) <= 2


func _eval_dux_in_sim(my_player, rescue: bool = false, moving_dux: bool = false) -> bool:
	if rescue or _live_dux_in_rescue(my_player):
		rescue = true
	var my_dux: Variant = null
	var enemy_dux: Variant = null
	for u in city.vcb_sim.values():
		if u["dux"] != true:
			continue
		if u["player"] == my_player:
			my_dux = u
		else:
			enemy_dux = u
	if my_dux == null:
		return true
	if enemy_dux:
		var e_free = city.get_blocking_tiles(enemy_dux["pg"], othr_p(my_player), false, true)[2]
		if len(e_free) == 0:
			return true
	var free = city.get_blocking_tiles(my_dux["pg"], my_player, false, true)[2]
	var min_free := 2 if rescue else 3
	if len(free) < min_free:
		return false
	if moving_dux and not rescue and city.rules == city.Rules.XXI:
		var foes = city.get_blocking_tiles(my_dux["pg"], my_player, true, true)[0]
		if len(foes) > 0:
			return false
	if len(free) <= 2:
		var opp_actions = city.where_can_player_move(othr_p(my_player), true)
		for om in opp_actions["possible_moves"]:
			if om[1] in free:
				return false
	return true


func othr_p(player):
	if player == 1:
		return 2
	else:
		return 1


func _is_hard_plus(ai_lvl) -> bool:
	return ai_lvl == city.Ai_lvl.HARD or ai_lvl == city.Ai_lvl.CAESAR


func _is_dux_piece(pos) -> bool:
	var unit = city.get_soldier_on_position(pos)
	return unit != null and unit["dux"] == true


func _unique_eat_count(eats) -> int:
	var seen := {}
	for e in eats:
		seen[e[2]] = true
	return seen.size()


func _forward_delta(move, my_player) -> int:
	# Player 1 sits at low y (top); toward the enemy is +y.
	var dir := 1 if my_player == 1 else -1
	return (move[1].y - move[0].y) * dir


func _squares_between(a: Vector2i, b: Vector2i) -> Array:
	if a.x != b.x and a.y != b.y:
		return []
	var out := []
	var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
	if step == Vector2i.ZERO:
		return out
	var p := a + step
	while p != b:
		out.append(p)
		p += step
	return out


func _abandons_unique_pin(from_pos, my_player) -> bool:
	var adj = city.get_adjacent_tiles(from_pos)
	for a in adj:
		var other = city.get_soldier_on_position(a)
		if other == null or other["player"] == my_player:
			continue
		var foe_count := 0
		for ea in city.get_adjacent_tiles(a):
			var u = city.get_soldier_on_position(ea)
			if u != null and u["player"] == my_player:
				foe_count += 1
		if foe_count == 1:
			return true
	return false


func _formation_score(my_player, simulation: bool) -> int:
	var pool = city.vcb_sim if simulation else city.vcb
	var my_pos := {}
	for u in pool.values():
		if u["player"] == my_player:
			my_pos[u["pg"]] = u
	var connections := 0
	var isolated := 0
	var front := 0
	var max_y: int = city.city_size.y - 1
	for pos in my_pos.keys():
		var friends := 0
		for a in city.get_adjacent_tiles(pos):
			if my_pos.has(a):
				friends += 1
				if a.x > pos.x or (a.x == pos.x and a.y > pos.y):
					connections += 1
		if friends == 0 and my_pos[pos]["dux"] != true:
			isolated += 1
		if my_player == 1:
			front += pos.y
		else:
			front += max_y - pos.y
	return connections * 4 - isolated * 6 + front
