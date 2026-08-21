extends Node2D

@export var player: int = 1
@export var dux: bool = false
var captured = false
var position_grid: Vector2i = Vector2i.ZERO

var my_size = Vector2i(40,40)


func _ready() -> void:
	_apply_match_cosmetics()
	self.set_position_grid()


func _apply_match_cosmetics() -> void:
	var look: Dictionary = PawnCosmetics.cosmetics_for_player(player)
	var faction_id := str(look.get("faction", "roman"))
	var color_id := str(look.get("color", "blue" if player == 1 else "red"))
	var pawn_scale := Vector2(PawnCosmetics.PAWN_SCALE, PawnCosmetics.PAWN_SCALE)

	for node in [$dux_outline, $shield, $insignia]:
		node.position = Vector2(20, 20)
		node.centered = true
		node.scale = pawn_scale

	PawnCosmetics.apply_to_sprites(
		$shield,
		$insignia,
		faction_id,
		color_id,
		dux,
		$dux_outline
	)


func set_position_grid(pos_grid=null):
	if not pos_grid:
		for tile in $"../..".get_node("tiles").get_children():
			if tile.global_position == self.global_position:
				position_grid = tile.position_grid
	else:
		position_grid = pos_grid


func set_lost():
	$shield.modulate = Color(0.15, 0.15, 0.15)
	$insignia.modulate = Color(0.35, 0.35, 0.35)
	$dux_outline.visible = false

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
