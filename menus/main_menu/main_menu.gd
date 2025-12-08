extends Node2D

var MultiplayerScene = preload("res://multiplayer/main_multiplayer/main_multiplayer.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create player name
	$version_lbl.text = ProjectSettings.get_setting("application/config/version")
	do_easter_egs()
	hide_all_oth_containers()
	var multiplyer_s = get_tree().root.get_node("Main-multiplayer") 
	if multiplyer_s == null:
		multiplyer_s = MultiplayerScene.instantiate()
		#get_tree().root.add_child(multiplyer_s)
		get_tree().root.call_deferred("add_child", multiplyer_s)
	
	if multiplyer_s.disconnect_reason_ != null:
		print(multiplyer_s.disconnect_reason_)

	call_deferred("ensure_music_player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_all_oth_containers():
	for child in $othr_containers.get_children():
		child.visible = false


func do_easter_egs():
	var time = Time.get_datetime_dict_from_system()
	var day = time["day"]
	var month = time["month"]
	
	if month == 12:
		var new_sprite_image = load("res://sprites/images/main_menu_01_snow.png")
		$Sprite2D.texture = new_sprite_image
		$title_ctrl/SnowParticle.emitting = true

func ensure_music_player():
	var root = get_tree().root

	# Check if a music player already exists
	var music = root.get_node_or_null("BackgroundMusic")
	if music:
		return  # Already exists, nothing to do
	
	# Create one
	music = AudioStreamPlayer.new()
	music.name = "BackgroundMusic"
	music.stream = preload("res://audio/music/imperium-aeternum-v1-430851.ogg")
	music.bus = "Master"
	#music.bus = "Music"     # Optional: assign audio bus
	music.stream.loop = true       # Ensure looping

	root.add_child(music)

	if GlobalSet.settings.get("audio", 1) == 1:
		music.play()
