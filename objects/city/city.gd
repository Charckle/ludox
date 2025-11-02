extends Control


@onready var all_tiles = $tiles
@onready var all_soldiers = $soldiers

var tile_size = Vector2i(40,40)

var all_board_positions
var corners
var border_tiles

var my_player = 3 # for multiplayer
var player_turn = 2

var board_size = GlobalSet.settings["board_size"]
var city_size: Vector2i = Vector2(8, 8)
var default_scale = Vector2(1.3, 1.3)
 
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


# virtualization
var vcb = {} # virtual city board
# {1: {"pg": Vector2i(4,2),
#	"player": 2,
#	"dux": true,
#	"id": 1
#  }}
var vcb_sim = {}



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

var m_m = null
var multi_play = false

@onready var lvl_ = get_parent()

var Soldier = preload("res://objects/soldier/soldier.tscn")
var Tile = preload("res://objects/tile/base_tile.tscn")
var SlainScene = preload("res://objects/soldier/slain_anim/slain_anim.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_city()

func initial_multiplayer_set(m_m_, players_data):
	self.m_m = m_m_
	
	self.multi_play = true
	self.my_player = m_m.my_player
	# player_tunr is the player ID, not his color
	self.player_turn = players_data[m_m.player_turn]
	if self.my_player != players_data[m_m.player_turn]:
		can_interact = false

	initialize_city(m_m.city_size, m_m.rules)
	

func initialize_city(board_size_=board_size, rules_=int(GlobalSet.settings["game_rules"])):
	if board_size_ == 1:
		city_size = Vector2(12, 8)
	remove_all_units()
	remove_all_tiles()
	rules = rules_
	#GlobalSet.game_type = $game_type_btn.selected
	#GlobalSet.ai_lvl = $ai_lvl_btn.select
	#pivot_offset = size * 0.5
	scale = default_scale
	
	
	if board_size != 99:
		createboard()
	
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


func createboard():
	for y in range(city_size.y):
		for x in range(city_size.x):
			var tile_ = Tile.instantiate()
			#var my_size = tile_.my_size
			all_tiles.add_child(tile_)
			tile_.position = Vector2i(x, y) * tile_.my_size
			tile_.position_grid = Vector2i(x, y)
	
	for x in range(city_size.x):
		var unit_ = Soldier.instantiate()
	
		#var my_size = tile_.my_size
		unit_.player = 1
		all_soldiers.add_child(unit_)
		unit_.position = Vector2i(x, 0) * unit_.my_size
		
		unit_.position_grid = Vector2i(x, 0)
	
	var max_y = city_size.y - 1

	for x in range(city_size.x):
		var unit_ = Soldier.instantiate()
		#var my_size = tile_.my_size
		unit_.player = 2
		all_soldiers.add_child(unit_)
		unit_.position = Vector2i(x, max_y) * unit_.my_size
		
		unit_.position_grid = Vector2i(x, max_y)

		
	
	# set city_tile_size
	tile_size = all_tiles.get_child(0).my_size
	
	# place duxes
	place_dux()
	set_city_for_calc()
	get_city_size()
	center_board()

func get_city_size():
	var s_size = city_size * tile_size

func place_dux():
	var half_city = city_size.x / 2
	var max_y = city_size.y - 1
	
	# bottom player 2
	var unit_ = Soldier.instantiate()
	unit_.player = 2
	unit_.dux = true
	all_soldiers.add_child(unit_)
	unit_.position = Vector2i(half_city, max_y -1) * unit_.my_size
	unit_.position_grid = Vector2i(half_city, max_y -1)
	
	# top player 1
	var unit_2 = Soldier.instantiate()
	unit_2.player = 1
	unit_2.dux = true
	all_soldiers.add_child(unit_2)
	unit_2.position = Vector2i(half_city -1, 1) * unit_2.my_size
	unit_2.position_grid = Vector2i(half_city -1, 1)
	
func center_board():
	var viewport := get_viewport()
	var viewport_rect := viewport.get_visible_rect()
	var top_left := viewport_rect.position
	#var viewport_size = get_viewport_rect().size

	# total board size
	var board_size_ = Vector2(
		city_size.x * tile_size.x,
		city_size.y * tile_size.y
	)

	# position of top-left corner so it's centered
	#var top_left = (viewport_size - board_size) / 2.0
	
	self.global_position = top_left - (board_size_ / 2.0)
	
	# because of scale
	self.global_position.x -= 70
	self.global_position.y -= 45

func set_city_for_calc():
	var valu = 1
	for unit in all_soldiers.get_children():
		
		var new_unit = {"pg": unit.position_grid,
						"player": unit.player,
						"dux": unit.dux,
						"id": valu}
		
		vcb[valu] = new_unit
		valu = valu + 1



func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Mouse Click/Unclick at: ", event.position)
		if can_interact:
			check_tile(get_global_mouse_position())


func check_tile(mouse_pos):
	# set if multiplayer or not
	if not multi_play:
		my_player = self.player_turn
	for tile in all_tiles.get_children():
		if tile.get_child(0).get_global_rect().has_point(mouse_pos):
			#print("Clicked on:", tile.name)
			var tile_coord = tile.position_grid
			var soldier_on_pos = get_soldier_on_position(tile_coord)
			#print("bana")
			# if there is a soldier on that position
			if soldier_on_pos != null:
				if soldier_on_pos["player"] == my_player:
					select_soldier(soldier_on_pos["pg"])
					show_selected_piece(soldier_on_pos["pg"])
					tile_selected = tile
					#print("Selected tile:", tile_selected.position_grid)
			else:
				if tile_selected != null:
					if tile.position_grid in possible_moves:
						# move selcted unit to position
						if multi_play:
							m_m.game.rpc_id(1, "send_move", m_m.room_id,
												tile_selected.position_grid, tile.position_grid)
						else:
							self.move_unit(my_player, tile_selected.position_grid, tile.position_grid)
				

func get_soldier_on_position(pos_coord, simulation=false):
	var soldier_on_pos = null
	
	var pool = vcb
	
	if simulation == true:
		pool = vcb_sim
	
	for soldier in pool.values():
		if soldier["pg"] == pos_coord:
			soldier_on_pos = soldier
	
	return soldier_on_pos

func _get_soldier_on_position(pos_coord, simulation=false):
	var pool = all_soldiers
	
	if simulation == true:
		pool = $simulation
		
	var soldier_on_pos = null
	for soldier in pool.get_children():
		if soldier.position_grid == pos_coord:
			soldier_on_pos = soldier
	
	return soldier_on_pos

func get_tile_on_position(pos_coord):
	var tile_on_pos = null
	for tile in all_tiles.get_children():
		if tile.position_grid == pos_coord:
			tile_on_pos = tile
	
	return tile_on_pos


func select_soldier(soldier_coord):
	get_possible_moves(soldier_coord)
	
	show_where_can_move(true)
	

func show_where_can_move(yes=false):
	var tiles = all_tiles.get_children()

	for tile in tiles:
		tile.dim(false)
		
		if GlobalSet.settings["movement_highlight"] == 1:
			if yes and not tile.position_grid in possible_moves:
				tile.dim(yes)

func show_pieces_turn():
	var units = all_soldiers.get_children()
	for unit in units:
		if unit.player == player_turn:
			unit.set_pieces_turn(true)
		else:
			unit.set_pieces_turn(false)

func show_selected_piece(unit_position=null):
	var units = all_soldiers.get_children()
	for unit in units:
		if unit.position_grid == unit_position:
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
	var iks = 8
	iks = city_size.x
	
	for x in range(iks):
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
	var unit_v = get_soldier_on_position(start_pos)
	var unit = _get_soldier_on_position(start_pos)
	
	var start_tile = get_tile_on_position(start_pos)
	var tile = get_tile_on_position(end_pos)
	
	unit_v["pg"] = end_pos
	vcb[unit_v["id"]] = unit_v
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





func eat_unit(position_grid, simulation=false, inplace=false):
	var pool = vcb
	
	if simulation == true:
		pool = vcb_sim
	
	var unit_v = get_soldier_on_position(position_grid, simulation)
	var unit = _get_soldier_on_position(position_grid, simulation)
	
	unit.captured = true
	
	if unit_v != null:
		pool.erase(unit_v["id"])
	self.since_last_eat = -1
	
	if GlobalSet.settings["animation"] == 1:
		spawn_slain_anim(unit.global_position)
	
	if inplace:
		unit.free()
	else:
		unit.queue_free()

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
		var start_coord = unit["pg"]
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
				units_att_dux.append([unit["pg"], move])
	
	if not units_with_possible_eat and not units_att_dux and not possible_moves:
		can_move = false
		
	var result = {
		"can_move": can_move,
		"units_with_possible_eat": units_with_possible_eat,
		"units_att_dux": units_att_dux,
		"possible_moves": possible_moves
	}
	
	return result

func get_adjacent_tiles(position_grid):
	var top = position_grid + Vector2i(0,1)
	var bottom = position_grid + Vector2i(0,-1)
	var left = position_grid + Vector2i(-1,0)
	var right = position_grid + Vector2i(1,0)
	
	var adj_tiles = [top, bottom, left, right]
	for c_tile in adj_tiles:
		if c_tile not in self.all_board_positions:
			adj_tiles.erase(c_tile)

	return adj_tiles


func get_blocking_tiles(position_grid, player, foes_only=false, simulation=false):
	var pool = vcb
	
	if simulation == true:
		pool = vcb_sim
		
	var adj_units = []
	var adj_tiles = self.get_adjacent_tiles(position_grid)
	var adj_free_tile_pos = adj_tiles.duplicate() 
	
	for c_tile in adj_tiles:
		if c_tile not in self.all_board_positions:
			adj_tiles.erase(c_tile)
	
	for unit_ in pool.values():
		var unit_pos = unit_["pg"]
		
		if unit_pos in adj_tiles:
			adj_free_tile_pos.erase(unit_pos)
			if not foes_only:
				adj_units.append(unit_)
			elif unit_["player"] != player:
				adj_units.append(unit_)

	var blocking_tiles = []
		
	for cord in adj_tiles:
		if cord not in adj_free_tile_pos:
			blocking_tiles.append(cord)
	
	return [adj_units, adj_tiles, adj_free_tile_pos, blocking_tiles]
	
	
	


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
	var pool = vcb
	
	if simulation == true:
		pool = vcb_sim
	
	if player:
		var units = []
		for unit in pool.values():
			if unit["player"] == player:
				units.append(unit)
		return units
	else:
		return pool.values()

func clear_all_last_moved():
	for tile in all_tiles.get_children():
		tile.last_moved(false)
	for unit in all_soldiers.get_children():
		unit.set_moved(false)

func set_all_last_moved():
	clear_all_last_moved()
	var tile =  get_tile_on_position(self.previous_tile)
	var soldier = _get_soldier_on_position(self.moved_to_tile)

	if tile != null:
		tile.last_moved(true)
	if soldier != null:
		soldier.set_moved(true)


func check_win():
	# check if both have any units left
	var score = {1: 0, 2: 0}
	
	for unit_ in vcb.values():
		if unit_["dux"] == false:
			score[unit_["player"]] = score[unit_["player"]] + 1 
	
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
	for unit_ in vcb.values():
		
		if unit_["dux"] == true:
			var blocking_tiles = self.get_blocking_tiles(unit_["pg"],unit_["player"])
			var blocking_units = blocking_tiles[0]
			var all_tiles = blocking_tiles[1]
			
			if len(blocking_units) == len(all_tiles):
				var winner = get_enemy_pid(unit_["player"])
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
	
	for unit_ in all_soldiers.get_children():
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
		"all_moves": self.all_moves,
		"moves_till_attack_dux_ai": self.moves_till_attack_dux_ai,
		"board_size": self.board_size
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
	for unit in all_soldiers.get_children():
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
	self.moves_till_attack_dux_ai = int(game_state["moves_till_attack_dux_ai"])
	self.board_size = int(game_state["board_size"])

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

func remove_all_tiles():
	for tile_ in all_tiles.get_children():
		tile_.queue_free()


func remove_all_units():
	for unit in all_soldiers.get_children():
		eat_unit(unit.position_grid, false, true)


func restore_unit(unit_data):
	var unit = Soldier.instantiate()
	var position_grid = l_t_v(unit_data[0])
	var global_pos = l_t_v(unit_data[1])
	
	unit.player = unit_data[2]
	unit.dux = unit_data[3]
	all_soldiers.add_child(unit)
	unit.global_position = global_pos
	#unit.set_position_grid()
	unit.position_grid = position_grid
	
	var valu = len(vcb) + 1
	
	var new_unit = {"pg": unit.position_grid,
						"player": unit.player,
						"dux": unit.dux,
						"id": valu}
	
	vcb[valu] = new_unit

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
