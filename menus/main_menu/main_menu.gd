extends Node2D

var MultiplayerScene = preload("res://multiplayer/main_multiplayer/main_multiplayer.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create player name
	$version_lbl.text = ProjectSettings.get_setting("application/config/version")
	do_easter_egs()
	hide_all_oth_containers()
	var multiplyer_s = get_tree().root.get_node_or_null("Main-multiplayer")
	if multiplyer_s == null:
		multiplyer_s = MultiplayerScene.instantiate()
		#get_tree().root.add_child(multiplyer_s)
		get_tree().root.call_deferred("add_child", multiplyer_s)
	
	if multiplyer_s.disconnect_reason_ != null:
		print(multiplyer_s.disconnect_reason_)

	MusicManager.play_menu()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if $othr_containers/campaign_pan.close_battle_modal_if_open():
		get_viewport().set_input_as_handled()
		return
	var any_open := false
	for child in $othr_containers.get_children():
		if child.visible:
			any_open = true
			break
	if any_open:
		hide_all_oth_containers()
		get_viewport().set_input_as_handled()


func hide_all_oth_containers():
	for child in $othr_containers.get_children():
		child.visible = false


func do_easter_egs():
	var time = Time.get_datetime_dict_from_system()
	var month = time["month"]
	
	if month == 12 or month == 1:
		var new_sprite_image = load("res://sprites/images/main_menu_01_snow.png")
		$Sprite2D.texture = new_sprite_image
		$title_ctrl/SnowParticle.emitting = true
	else:
		$SparkParticle.emitting = true

