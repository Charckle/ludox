extends Node

@onready var city = get_parent()

var can_interact = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Mouse Click/Unclick at: ", event.position)
		if can_interact:
			check_tile(city.get_global_mouse_position())

func check_tile(mouse_pos):
	var my_player = self.player_turn
	for tile in $tiles.get_children():
		if tile.get_child(0).get_global_rect().has_point(mouse_pos):
			#print("Clicked on:", tile.name)
			var tile_coord = tile.position_grid
			var soldier_on_pos = _get_soldier_on_position(tile_coord)
			
			# if there is a soldier on that position
			if soldier_on_pos != null:
				if soldier_on_pos.player == city.my_player:
					select_soldier(soldier_on_pos.position_grid)
					show_selected_piece(soldier_on_pos.position_grid)
					tile_selected = tile
					#print("Selected tile:", tile_selected.position_grid)
			else:
				if tile_selected != null:
					if tile.position_grid in possible_moves:
						# move selcted unit to position
						self.move_unit(my_player, tile_selected.position_grid, tile.position_grid)
				

func _get_soldier_on_position(pos_coord):
	var pool = city.all_soldiers
	
	var soldier_on_pos = null
	for soldier in pool.get_children():
		if soldier.position_grid == pos_coord:
			soldier_on_pos = soldier
	
	return soldier_on_pos


func select_soldier(soldier_coord):
	get_possible_moves(soldier_coord)
	
	show_where_can_move(true)


func show_selected_piece(unit_position=null):
	var units = city.all_soldiers.get_children()
	for unit in units:
		if unit.position_grid == unit_position:
			unit.set_selected(true)
		else:
			unit.set_selected(false)
