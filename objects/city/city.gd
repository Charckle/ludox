extends Control

var all_board_positions
var corners
var border_tiles

var player_turn = 2

var can_interact = true

var tile_selected = null
var possible_moves = []
var tile_target = null

var previous_tile = Vector2i(0,0)
var moved_to_tile = Vector2i(0,0)

var all_moves = 0
var since_last_eat = 0
var moves_to_draw = 50

var all_units = []





enum Rules {
	BASIC,
	BASIC_PLUS,
	XXI
}

enum Game_types {
	PVP,
	PVAI
}

enum Ai_lvl {
	EASY,
	NORMAL
}

var moves_till_attack_dux_ai = 6

var rules

var game_move_states = []

@onready var lvl_ = get_parent()

var SoldierUnitScene = preload("res://objects/soldier/soldier.tscn")
var SlainScene = preload("res://objects/soldier/slain_anim/slain_anim.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rules = GlobalSet.settings["game_rules"]
	#GlobalSet.game_type = $game_type_btn.selected
	#GlobalSet.ai_lvl = $ai_lvl_btn.select
	#pivot_offset = size * 0.5
	scale = Vector2(1.3, 1.3)
	
	all_board_positions = blank_board()
	corners = get_corners()
	border_tiles = get_border_tiles()

	if GlobalSet.load_saved_continue:
		GlobalSet.load_saved_continue = false
		load_game_state(ContinueGame.load_continue())
	else:
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
	var my_player = self.player_turn
	for tile in $tiles.get_children():
		if tile.get_child(0).get_global_rect().has_point(mouse_pos):
			#print("Clicked on:", tile.name)
			var tile_coord = tile.position_grid
			var soldier_on_pos = get_soldier_on_position(tile_coord)
			
			# if there is a soldier on that position
			if soldier_on_pos != null:
				if soldier_on_pos.player == my_player:
					select_soldier(soldier_on_pos)
					show_selected_piece(soldier_on_pos)
					tile_selected = tile
					#print("Selected tile:", tile_selected.position_grid)
			else:
				if tile_selected != null:
					if tile.position_grid in possible_moves:
						# move selcted unit to position
						self.move_unit(my_player, tile_selected.position_grid, tile.position_grid)
				

func get_soldier_on_position(pos_coord, simulation=false):
	var pool = $soldiers
	
	if simulation == true:
		pool = $simulation
		
	var soldier_on_pos = null
	for soldier in pool.get_children():
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
		
		if GlobalSet.settings["movement_highlight"] == 1:
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
		

func get_possible_moves(soldier_pos, dryrun=false, simulation=false):
	var poss_moves = []
	if not dryrun:
		possible_moves.clear()
	
	match rules:
		Rules.BASIC:
			poss_moves = $basic.get_basic_moves(soldier_pos, dryrun, simulation)
		Rules.BASIC_PLUS:
			poss_moves = $basic.get_basic_moves(soldier_pos, dryrun, simulation)
		Rules.XXI:
			poss_moves = $xxi.get_moves(soldier_pos, dryrun, simulation)
	
	return poss_moves





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

func move_unit(my_player, start_pos, end_pos):
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
	self.all_moves = all_moves + 1
	
	# move and end turn
	if GlobalSet.settings["animation"] == 0:
		unit.global_position = tile.global_position
		unit_stopped_moving(my_player, start_pos, end_pos)
	else:
		unit.tween_to_global_and_resume(tile.global_position, self, start_pos, end_pos)
	
	
	

func unit_stopped_moving(my_player, start_pos, end_pos):
	# check if you eat anything
	check_if_eatable(my_player, start_pos, end_pos)
	can_interact = true
	
	end_turn()

func check_if_eatable(my_player, start_coord, pos_coord, dryrun=false, simulation=false):
	var can_eat = []
	
	match rules:
		Rules.BASIC:
			can_eat.append_array($basic.basic_eatable_rules(my_player, 
					start_coord, pos_coord, dryrun, simulation))
		Rules.BASIC_PLUS:
			can_eat.append_array($basic.basic_plus_eatable_rules(my_player, 
					start_coord, pos_coord, dryrun, simulation))
		Rules.XXI:
			can_eat.append_array($xxi.xxi_eatable_rules(my_player, 
					start_coord, pos_coord, dryrun, simulation))
	
	return can_eat





func eat_unit(unit):
	unit.captured = true
	unit.queue_free()
	self.since_last_eat = -1
	
	if GlobalSet.settings["animation"] == 1:
		spawn_slain_anim(unit.global_position)

func spawn_slain_anim(gb):
	var fx = SlainScene.instantiate()
	$trash.add_child(fx)
	fx.global_position = gb

func where_can_player_move(player, simulation=false):
	var soldiers = self.get_soldiers(player, simulation)
	
	var can_move = true
	var units_with_possible_eat = []
	var units_att_dux = []
	var possible_moves = []
	
	for unit in soldiers:
		var start_coord = unit.position_grid
		var poss_moves = self.get_possible_moves(start_coord, true, simulation)
		
		for move in poss_moves:
			possible_moves.append([start_coord, move])
			var is_eatable = self.check_if_eatable(player, start_coord, move, true, simulation)
			var tile =  self.get_tile_on_position(move)
			
			#var is_eatable = false
			if len(is_eatable) > 0:
				# can_eat.append([start_coord, pos_coord, who_gonna_be_eaten_coord])
				units_with_possible_eat.append_array(is_eatable)
				
			if tile.do_adj_dux(self, self.get_enemy_pid(player), simulation):
				units_att_dux.append([unit.position_grid, move])
	
	if not units_with_possible_eat and not units_att_dux and not possible_moves:
		can_move = false
		
	var result = {
		"can_move": can_move,
		"units_with_possible_eat": units_with_possible_eat,
		"units_att_dux": units_att_dux,
		"possible_moves": possible_moves
	}
	
	return result





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
	
	if not check_win():
		if player_turn != 3 and GlobalSet.settings["game_type"] != Game_types.PVP:
			if player_turn != 2:
				$ai.execute_move(self.player_turn)


func get_soldiers(player=false, simulation=false):
	var pool = $soldiers
	
	if simulation == true:
		pool = $simulation
	
	if player:
		var units = []
		for unit in pool.get_children():
			if unit.player == player and unit.captured == false:
				units.append(unit)
		return units
	else:
		return pool.get_children()

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
		if unit_.dux == false and unit_.captured == false:
			score[unit_.player] = score[unit_.player] + 1 
	
	var winner_ = 0
	
	if score[1] == 0:
		winner_ = 2
	elif score[2] == 0:
		winner_ = 1
	
	if winner_ != 0:
		var text_ = get_winner_text(winner_) + " won the day!\nThere has no more pawns."
		lvl_.show_info_pan(text_)
		set_winner(winner_)
		return true
	
	# check for dux
	for unit_ in $soldiers.get_children():
		if unit_.dux == true:
			var blocking_tiles = unit_.get_blocking_tiles(self)
			var blocking_units = blocking_tiles[0]
			var all_tiles = blocking_tiles[1]
			
			if len(blocking_units) == len(all_tiles):
				var winner = get_enemy_pid(unit_.player)
				var text_ = get_winner_text(winner) + " won the day!\nThe dux is sorounded."
				lvl_.show_info_pan(text_)
				set_winner(winner)
				return true
	
	# check if player can move
	print("Calculating if the player can move")
	var results = where_can_player_move(player_turn)
	
	if results["can_move"] == false:
		var winner = get_enemy_pid(player_turn)
		var text_ = get_winner_text(winner) + " won the day! No more moves available"
		lvl_.show_info_pan(text_)
		set_winner(winner)
		return true
	
	
	if since_last_eat >= moves_to_draw:
		var text_ = "The game ends in a draw. Throw some dice to decide the winner"
		lvl_.show_info_pan(text_)
		player_turn = 3
		ContinueGame.delete_continue()
	return false


func set_winner(player_n):
	player_turn = 3
	
	for unit_ in $soldiers.get_children():
		if unit_.player != player_n:
			unit_.set_lost()
	
	ContinueGame.delete_continue()

func get_current_game_state():
	var game_state = {
		"player_turn": self.player_turn,
		"rules": self.rules,
		"game_type": GlobalSet.settings["game_type"],
		"ai_lvl": GlobalSet.settings["ai_lvl"],
		"previous_tile": v_t_l(self.previous_tile),
		"moved_to_tile": v_t_l(self.moved_to_tile),
		"all_units": get_all_units_for_bckup(),
		"since_last_eat": self.since_last_eat,
		"all_moves": self.all_moves
	}
	return game_state

func v_t_l(vector_):
	var my_list = [vector_[0], vector_[1]]
	return my_list
	
func l_t_v(list_):
	var my_vector = Vector2i(list_[0], list_[1])
	return my_vector

func get_all_units_for_bckup():
	var all_units = []
	for unit in $soldiers.get_children():
		all_units.append([
			v_t_l(unit.position_grid),
			v_t_l(unit.global_position),
			unit.player,
			unit.dux
		])
	
	return all_units

func save_move_state():
	var cur_state = get_current_game_state()
	self.game_move_states.append(cur_state)
	ContinueGame.save_continue(cur_state)

	
func undo_move():
	self.show_where_can_move()
	
	if len( self.game_move_states) > 1:
		self.game_move_states.pop_back() 
		if GlobalSet.settings["game_type"] != 0:
			self.game_move_states.pop_back() 
		var previous_state = self.game_move_states[-1]
		
		self.load_game_state(previous_state)
		

func load_game_state(game_state):
	self.player_turn = int(game_state["player_turn"])
	self.rules = int(game_state["rules"])
	GlobalSet.settings["game_type"] = int(game_state["game_type"])
	GlobalSet.settings["ai_lvl"] = int(game_state["ai_lvl"])
	self.previous_tile = l_t_v(game_state["previous_tile"])
	self.moved_to_tile = l_t_v(game_state["moved_to_tile"])
	self.all_units = game_state["all_units"]
	self.since_last_eat = int( game_state["since_last_eat"])
	self.all_moves = int(game_state["all_moves"])

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
	var unit = SoldierUnitScene.instantiate()
	var position_grid = l_t_v(unit_data[0])
	var global_pos = l_t_v(unit_data[1])
	
	unit.player = unit_data[2]
	unit.dux = unit_data[3]
	$soldiers.add_child(unit)
	unit.global_position = global_pos
	#unit.set_position_grid()
	unit.position_grid = position_grid


func get_enemy_pid(manual_player = null):
	if manual_player == null:
		manual_player = player_turn
	if manual_player == 1:
		return 2
	else:
		return 1

func get_winner_text(player):
	if GlobalSet.settings["game_type"] != Game_types.PVP:
		if player == 2:
			return "You"
		else:
			return "The opponent"
	else:
		if player == 2:
			return "Red Player"
		else:
			return "Blue Player"
