extends Node2D

@onready var left  := $slice/cert_1
@onready var right := $slice/rect_2
@onready var sword := $sword

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var duration := 0.5
	var offset := 50.0   # how far to slide

	# One tween, parallel tracks, eased out
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Slide in opposite directions
	t.tween_property(left,  "position:x", left.position.x  - offset, duration)
	t.tween_property(right, "position:x", right.position.x + offset, duration)
	t.tween_property(sword, "position:y", sword.position.y + offset, duration)

	# Fade both to transparent
	t.tween_property(left,  "modulate:a", 0.0, duration)
	t.tween_property(right, "modulate:a", 0.0, duration)
	t.tween_property(sword, "modulate:a", 0.0, duration)

	# Optional: clean up after
	t.finished.connect(func ():
		left.queue_free()
		right.queue_free()
		sword.queue_free()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
