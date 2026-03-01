extends Panel

var current_rule = 0
var all_rules: Array

# [display_title, page_index] — one entry per section; multi-page sections use first page index
const TOC_SECTIONS: Array[Dictionary] = [
	{"title": "Classic", "index": 2},
	{"title": "Classic Plus", "index": 3},
	{"title": "Latrunculi XXI", "index": 4},
	{"title": "Latrunculi XXI - Movement", "index": 5},
	{"title": "Latrunculi XXI - Offensive movement", "index": 7},
	{"title": "Latrunculi XXI - Offensive movement - Push and crush", "index": 8},
	{"title": "Latrunculi XXI - Offensive movement - Flank attack", "index": 9},
	{"title": "Latrunculi XXI - Offensive movement - Phalanx", "index": 10},
]


func _ready() -> void:
	all_rules = $rules.get_children()
	_build_toc()
	hide_all()
	all_rules[0].visible = true
	current_rule = 0


func _build_toc() -> void:
	var container: VBoxContainer = $rules/table_of_contents/toc_buttons
	for section in TOC_SECTIONS:
		var btn := Button.new()
		btn.text = section.title
		btn.pressed.connect(_on_toc_button_pressed.bind(section.index))
		container.add_child(btn)


func _on_toc_button_pressed(page_index: int) -> void:
	show_rule_index(page_index)


func show_rule_index(idx: int) -> void:
	if idx < 0 or idx >= all_rules.size():
		return
	hide_all()
	current_rule = idx
	all_rules[idx].visible = true


func _on_previous_btn_pressed() -> void:
	hide_all()
	current_rule = current_rule - 1
	if current_rule < 0:
		current_rule = 0
	all_rules[current_rule].visible = true


func _on_next_btn_pressed() -> void:
	hide_all()
	current_rule = current_rule + 1
	if current_rule >= all_rules.size():
		current_rule = all_rules.size() - 1
	all_rules[current_rule].visible = true


func hide_all() -> void:
	for rule in all_rules:
		rule.visible = false


func _on_closes_btn_pressed() -> void:
	self.visible = false
