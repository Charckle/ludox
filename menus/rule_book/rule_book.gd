extends Panel

var current_rule = 0
var all_rules

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_rules = $rules.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_previous_btn_pressed() -> void:
	hide_all()
	current_rule = current_rule -1
	if current_rule < 0:
		current_rule = 0
	all_rules[current_rule].visible = true


func _on_next_btn_pressed() -> void:
	hide_all()
	current_rule = current_rule +1
	if current_rule >= len(all_rules):
		current_rule = len(all_rules)-1
	all_rules[current_rule].visible = true

func hide_all():
	for rule in all_rules:
		rule.visible = false


func _on_closes_btn_pressed() -> void:
	self.visible = false
