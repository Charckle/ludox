extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_in():
	self.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.3)  # fade over 1.2s
	tween.tween_callback(Callable(self, "_on_fade_finished"))

func _on_fade_finished():
	queue_free()  # Remove fade overlay after animation
