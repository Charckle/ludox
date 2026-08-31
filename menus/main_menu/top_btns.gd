extends VBoxContainer

@onready var main_menu = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ContinueGame.check_continue_exists():
		$continue_btn.visible = true


func _on_new_game_btn_pressed() -> void:
	main_menu.hide_all_oth_containers()
	$"../../../othr_containers/new_game_pan".visible = true


func _on_continue_btn_pressed() -> void:
	if not ContinueGame.apply_continue_to_global():
		$continue_btn.visible = false
		return
	get_tree().change_scene_to_file("res://objects/levels/basic/basic_lvl.tscn")


func _on_button_pressed() -> void:
	main_menu.hide_all_oth_containers()
	var pan = $"../../../othr_containers/campaign_pan"
	pan.visible = true
	var camp_id := ContinueGame.get_continue_campaign_id()
	if camp_id != "":
		pan.show_campaign(camp_id)


func _on_scenarios_btn_pressed() -> void:
	main_menu.hide_all_oth_containers()
	$"../../../othr_containers/scenarios_pan".visible = true


func _on_online_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://multiplayer/multiplayer_menu/multiplayer_menu.tscn")
