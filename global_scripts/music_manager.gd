extends Node

const MENU_TRACK := "res://audio/music/imperium-aeternum-v1-430851.ogg"
const BATTLE_MUSIC_DIR := "res://audio/music/battle"
const FADE_DURATION := 1.5
const SILENT_DB := -80.0
const FULL_DB := 0.0

var menu_player: AudioStreamPlayer
var battle_player: AudioStreamPlayer
var battle_tracks: Array = []
var battle_playlist: Array = []
var battle_index := 0
var _loop_start := 0
var rng := RandomNumberGenerator.new()

var _mode := ""
var _fade_tween: Tween
var _ignore_finished := false


func _ready() -> void:
	rng.randomize()
	_load_battle_tracks()
	_create_players()


func play_menu() -> void:
	if _mode == "menu" and _is_menu_active():
		return
	_mode = "menu"
	if not _audio_enabled():
		_kill_tween()
		_stop_battle_now()
		return
	_crossfade_to_menu()


func play_battle() -> void:
	_shuffle_playlist()
	if GlobalSet.skip_epic_opener:
		GlobalSet.skip_epic_opener = false
	else:
		_prepend_epic_opener()
	battle_index = 0
	var from_menu := _mode != "battle"
	_mode = "battle"
	if not _audio_enabled() or battle_playlist.is_empty():
		_kill_tween()
		_pause_menu()
		_stop_battle_now()
		return
	if from_menu:
		_crossfade_to_battle()
	else:
		battle_player.volume_db = FULL_DB
		_play_current_battle_track()


func set_audio_enabled(enabled: bool) -> void:
	if enabled:
		if _mode == "battle":
			if battle_playlist.is_empty():
				return
			battle_player.volume_db = FULL_DB
			_play_current_battle_track()
		else:
			_mode = ""
			play_menu()
	else:
		_kill_tween()
		if menu_player.playing:
			menu_player.stream_paused = true
		_stop_battle_now()


func _audio_enabled() -> bool:
	if GlobalSet.settings == null:
		return true
	return int(GlobalSet.settings.get("audio", 1)) == 1


func _is_menu_active() -> bool:
	return menu_player.playing and not menu_player.stream_paused


func _create_players() -> void:
	menu_player = AudioStreamPlayer.new()
	menu_player.name = "MenuMusic"
	menu_player.bus = "Master"
	var menu_stream = load(MENU_TRACK)
	_set_stream_loop(menu_stream, true)
	menu_player.stream = menu_stream
	add_child(menu_player)

	battle_player = AudioStreamPlayer.new()
	battle_player.name = "BattleMusic"
	battle_player.bus = "Master"
	add_child(battle_player)
	battle_player.finished.connect(_on_battle_track_finished)


func _load_battle_tracks() -> void:
	battle_tracks.clear()
	var paths := _list_audio_files(BATTLE_MUSIC_DIR)
	for path in paths:
		var stream := _load_audio_stream(path)
		if stream != null:
			_set_stream_loop(stream, false)
			battle_tracks.append(stream)
	if battle_tracks.is_empty():
		push_warning("MusicManager: no battle tracks found in %s" % BATTLE_MUSIC_DIR)


func _load_audio_stream(path: String) -> AudioStream:
	var stream = load(path)
	if stream is AudioStream:
		return stream
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var bytes := file.get_buffer(file.get_length())
	file.close()
	var ext := path.get_extension().to_lower()
	if ext == "mp3":
		var mp3 := AudioStreamMP3.new()
		mp3.data = bytes
		return mp3
	if ext == "ogg":
		return AudioStreamOggVorbis.load_from_buffer(bytes)
	return null


func _list_audio_files(dir_path: String) -> Array:
	var paths: Array = []
	var seen := {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("MusicManager: could not open %s" % dir_path)
		return paths
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var real_name := file_name
			if real_name.ends_with(".import"):
				real_name = real_name.trim_suffix(".import")
			if real_name.ends_with(".remap"):
				real_name = real_name.trim_suffix(".remap")
			var ext := real_name.get_extension().to_lower()
			if ext in ["mp3", "ogg", "wav"]:
				var full_path := dir_path.path_join(real_name)
				if not seen.has(full_path):
					seen[full_path] = true
					paths.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths


func _set_stream_loop(stream: AudioStream, enabled: bool) -> void:
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = enabled
	elif stream is AudioStreamMP3:
		stream.loop = enabled
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if enabled else AudioStreamWAV.LOOP_DISABLED


func _shuffle_playlist() -> void:
	battle_playlist = battle_tracks.duplicate()
	_loop_start = 0
	for i in range(battle_playlist.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = battle_playlist[i]
		battle_playlist[i] = battle_playlist[j]
		battle_playlist[j] = tmp


func _prepend_epic_opener() -> void:
	_loop_start = 0
	if not _epic_enabled():
		return
	var battle = GlobalSet.current_battle
	if battle == null or str(battle.epic_track) == "":
		return
	var stream := _load_audio_stream(battle.epic_track)
	if stream == null:
		push_warning("MusicManager: could not load epic track %s" % battle.epic_track)
		return
	_set_stream_loop(stream, false)
	battle_playlist.insert(0, stream)
	if battle_playlist.size() > 1:
		_loop_start = 1


func _epic_enabled() -> bool:
	if GlobalSet.settings == null:
		return false
	return int(GlobalSet.settings.get("epic", 0)) == 1


func _play_current_battle_track() -> void:
	if battle_playlist.is_empty():
		return
	_ignore_finished = true
	battle_player.stream = battle_playlist[battle_index]
	battle_player.play()
	_ignore_finished = false


func _on_battle_track_finished() -> void:
	if _ignore_finished or _mode != "battle" or not _audio_enabled():
		return
	if battle_playlist.is_empty():
		return
	battle_index += 1
	if battle_index >= battle_playlist.size():
		battle_index = _loop_start
		if battle_index >= battle_playlist.size():
			battle_index = 0
	_play_current_battle_track()


func _crossfade_to_battle() -> void:
	_kill_tween()
	battle_player.volume_db = SILENT_DB
	_play_current_battle_track()
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	if menu_player.playing and not menu_player.stream_paused:
		_fade_tween.tween_property(menu_player, "volume_db", SILENT_DB, FADE_DURATION)
	_fade_tween.tween_property(battle_player, "volume_db", FULL_DB, FADE_DURATION)
	_fade_tween.chain().tween_callback(_pause_menu)


func _crossfade_to_menu() -> void:
	_kill_tween()
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	if battle_player.playing:
		_fade_tween.tween_property(battle_player, "volume_db", SILENT_DB, FADE_DURATION)
	menu_player.volume_db = SILENT_DB
	if menu_player.stream_paused:
		menu_player.stream_paused = false
	if not menu_player.playing:
		menu_player.play()
	_fade_tween.tween_property(menu_player, "volume_db", FULL_DB, FADE_DURATION)
	_fade_tween.chain().tween_callback(_stop_battle_now)


func _pause_menu() -> void:
	if _mode != "battle":
		return
	if menu_player.playing:
		menu_player.stream_paused = true


func _stop_battle_now() -> void:
	_ignore_finished = true
	battle_player.stop()
	_ignore_finished = false


func _kill_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
