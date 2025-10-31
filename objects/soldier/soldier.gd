extends Node2D

@export var player: int = 1
@export var dux: bool = false
var captured = false
var position_grid: Vector2i = Vector2i.ZERO

var my_size = Vector2i(40,40)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player == 1:
		$rect_dux.color = Color.RED
		$ColorRect.color = Color.RED
	else:
		$rect_dux.color = Color.DEEP_SKY_BLUE
		$ColorRect.color = Color.DEEP_SKY_BLUE
	if dux:
		$rect_dux.color = Color.YELLOW
		
	self.set_position_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_position_grid(pos_grid=null):
	if not pos_grid:
		for tile in $"../..".get_node("tiles").get_children():
			if tile.global_position == self.global_position:
				position_grid = tile.position_grid
	else:
		position_grid = pos_grid

func set_moved(yes_no):
	if yes_no:
		$moved.visible = true
	else:
		$moved.visible = false


func set_lost():
	$ColorRect.color = Color.BLACK

func set_selected(yes=true):
	$selectedpiece.visible = yes

func set_pieces_turn(yes=true):
	$myturn.visible = yes


func tween_to_global_and_resume(target_global: Vector2, city, start_pos, end_pos) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# If your game is paused and you still want this tween to run, keep this line:
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(self, "global_position", target_global, 0.8)
	await tween.finished
	city.unit_stopped_moving(self.player, start_pos, end_pos)
