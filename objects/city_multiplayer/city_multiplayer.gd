extends Control

var city_size: Vector2i = Vector2(8, 8)
@onready var all_tiles = $tiles
@onready var all_soldiers = $soldiers
var tile_size = Vector2i(40,40)

var players_data = null

var Soldier = preload("res://objects/soldier/soldier.tscn")
var Tile = preload("res://objects/tile/base_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#createboard("big")
	createboard()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func createboard(size=null):
	if size == "big":
		city_size = Vector2i(12, 8)
	
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
		unit_.position_grid = Vector2i(x, 0)
		unit_.player = 1
		all_soldiers.add_child(unit_)
		unit_.position = Vector2i(x, 0) * unit_.my_size
	
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
	
	center_board()

func get_city_size():
	var s_size = city_size * tile_size

func place_dux():
	var half_city = city_size.x / 2
	var max_y = city_size.y - 1
	
	# bottom player 2
	var unit_ = Soldier.instantiate()
	unit_.position_grid = Vector2i(half_city, 1)
	unit_.player = 2
	unit_.dux = true
	all_soldiers.add_child(unit_)
	unit_.position = Vector2i(half_city, max_y -1) * unit_.my_size
	
	# top player 1
	var unit_2 = Soldier.instantiate()
	unit_2.player = 1
	unit_2.dux = true
	all_soldiers.add_child(unit_2)
	unit_2.position = Vector2i(half_city -1, 1) * unit_2.my_size
	unit_2.position_grid = Vector2i(half_city -1, max_y -1)
	
func center_board():
	var viewport_size = get_viewport_rect().size

	# total board size
	var board_size = Vector2(
		city_size.x * tile_size.x,
		city_size.y * tile_size.y
	)

	# position of top-left corner so it's centered
	var top_left = (viewport_size - board_size) / 2.0

	self.position = top_left


func initial_set(city_size, players_data, player_turn):
	self.createboard(size)
	
	
	self.players_data = players_data
	
	self.set_players_turn(player_turn)

func set_players_turn(my_player):
	var player_color = players_data[my_player]
	
	for soldier in all_soldiers:
		if soldier.player == player_color:
			soldier.set_pieces_turn(true)
