extends Node
## Faction/shield cosmetics for local skirmish and campaigns.

const RANDOM_ID := "random"

const FACTIONS := {
	"roman": {
		"id": "roman",
		"name": "Roman",
		"shield": "res://sprites/pawns/shield_types/scutum.png",
		"insignia": "res://sprites/pawns/factions/f_roman.png",
	},
	"spartan": {
		"id": "spartan",
		"name": "Spartan",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_spartan_big.png",
	},
	"athenian": {
		"id": "athenian",
		"name": "Athenian",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_athenian_big.png",
	},
	"theban": {
		"id": "theban",
		"name": "Theban",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_thebes_big.png",
	},
	"corinthian": {
		"id": "corinthian",
		"name": "Corinthian",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_corinth_big.png",
	},
	"aeginetan": {
		"id": "aeginetan",
		"name": "Aeginetan",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_aegina_big.png",
	},
	"thespian": {
		"id": "thespian",
		"name": "Thespian",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_thespians_big.png",
	},
	"milesian": {
		"id": "milesian",
		"name": "Milesian",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_miletuss_big.png",
	},
	"plataean": {
		"id": "plataean",
		"name": "Plataean",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_plateans_big.png",
	},
	"gaul": {
		"id": "gaul",
		"name": "Gaul",
		"shield": "res://sprites/pawns/shield_types/oval.png",
		"insignia": "res://sprites/pawns/factions/f_gaul.png",
	},
	"carthage": {
		"id": "carthage",
		"name": "Carthage",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_carthage.png",
	},
	"persian": {
		"id": "persian",
		"name": "Persian",
		"shield": "res://sprites/pawns/shield_types/rectangular.png",
		"insignia": "res://sprites/pawns/factions/f_persian.png",
	},
	"pontus": {
		"id": "pontus",
		"name": "Pontus",
		"shield": "res://sprites/pawns/shield_types/round_big.png",
		"insignia": "res://sprites/pawns/factions/f_pontus_big.png",
	},
	"numidian": {
		"id": "numidian",
		"name": "Numidian",
		"shield": "res://sprites/pawns/shield_types/round_small.png",
		"insignia": "res://sprites/pawns/factions/f_numidia_small.png",
	},
	"german": {
		"id": "german",
		"name": "German",
		"shield": "res://sprites/pawns/shield_types/round_small.png",
		"insignia": "res://sprites/pawns/factions/f_germans_small.png",
	},
}

## Full picker palette (settings).
const COLOR_PALETTE := {
	"red": {"name": "Red", "color": Color(0.85, 0.12, 0.12)},
	"blue": {"name": "Blue", "color": Color(0.15, 0.45, 0.95)},
	"green": {"name": "Green", "color": Color(0.12, 0.65, 0.28)},
	"smaragd": {"name": "Smaragd", "color": Color(0.06, 0.52, 0.38)},
	"yellow": {"name": "Yellow", "color": Color(0.92, 0.78, 0.12)},
	"orange": {"name": "Orange", "color": Color(0.95, 0.45, 0.08)},
	"purple": {"name": "Purple", "color": Color(0.55, 0.22, 0.75)},
	"teal": {"name": "Teal", "color": Color(0.1, 0.7, 0.7)},
	"white": {"name": "White", "color": Color(0.92, 0.92, 0.92)},
	"brown": {"name": "Brown", "color": Color(0.55, 0.32, 0.14)},
}

## High-contrast subset used when color is Random.
const RANDOM_COLOR_IDS := ["red", "blue", "green", "yellow", "white"]

## Default shield color when a pawn has a per-piece faction.
const FACTION_COLORS := {
	"spartan": "red",
	"athenian": "blue",
	"theban": "green",
	"corinthian": "white",
	"aeginetan": "yellow",
	"thespian": "brown",
	"milesian": "orange",
	"plataean": "teal",
	"persian": "purple",
	"pontus": "purple",
	"numidian": "brown",
	"german": "smaragd",
	"roman": "red",
	"gaul": "green",
	"carthage": "yellow",
}

const DUX_GOLD := Color(0.95, 0.78, 0.2)
const PAWN_SCALE := 0.82
const DUX_OUTLINE_PX := 2

var _outline_cache := {}

const DEFAULT_COSMETICS_SETTINGS := {
	"you": {"faction": "roman", "color": "red"},
	"opponent": {"faction": "roman", "color": "blue"},
}


func faction_ids() -> Array:
	return FACTIONS.keys()


func faction_display_name(faction_id: String) -> String:
	if FACTIONS.has(faction_id):
		return FACTIONS[faction_id]["name"]
	return faction_id.capitalize()


func color_ids() -> Array:
	return COLOR_PALETTE.keys()


func color_display_name(color_id: String) -> String:
	if COLOR_PALETTE.has(color_id):
		return COLOR_PALETTE[color_id]["name"]
	return color_id.capitalize()


func get_color(color_id: String) -> Color:
	if COLOR_PALETTE.has(color_id):
		return COLOR_PALETTE[color_id]["color"]
	return Color.WHITE


func get_faction(faction_id: String) -> Dictionary:
	if FACTIONS.has(faction_id):
		return FACTIONS[faction_id]
	return FACTIONS["roman"]


func color_for_faction(faction_id: String) -> String:
	if FACTION_COLORS.has(faction_id):
		return FACTION_COLORS[faction_id]
	return "red"


func campaign_cosmetics() -> Dictionary:
	# player 1 = AI (top), player 2 = human (bottom)
	var battle = GlobalSet.current_battle
	if battle != null and not battle.cosmetics.is_empty():
		return battle.cosmetics.duplicate(true)
	var camp_id := str(GlobalSet.current_campaign_id)
	if camp_id != "":
		var camp = Campaigns.get_by_id(camp_id)
		if camp != null and not camp.cosmetics.is_empty():
			return camp.cosmetics.duplicate(true)
	return {
		"1": {"faction": "gaul", "color": "green"},
		"2": {"faction": "roman", "color": "red"},
	}


func resolve_from_settings(settings: Dictionary) -> Dictionary:
	var cosmetics: Dictionary = settings.get("cosmetics", DEFAULT_COSMETICS_SETTINGS)
	var you: Dictionary = cosmetics.get("you", DEFAULT_COSMETICS_SETTINGS["you"])
	var opp: Dictionary = cosmetics.get("opponent", DEFAULT_COSMETICS_SETTINGS["opponent"])

	var you_faction := _resolve_faction(str(you.get("faction", "roman")))
	var opp_faction := _resolve_faction(str(opp.get("faction", "roman")))

	var you_color_pref := str(you.get("color", "red"))
	var opp_color_pref := str(opp.get("color", "blue"))
	var colors := _resolve_colors(you_color_pref, opp_color_pref)

	return {
		"1": {"faction": opp_faction, "color": colors["opponent"]},
		"2": {"faction": you_faction, "color": colors["you"]},
	}


func _resolve_faction(pref: String) -> String:
	if pref == RANDOM_ID:
		var ids: Array = faction_ids()
		return str(ids[randi() % ids.size()])
	if FACTIONS.has(pref):
		return pref
	return "roman"


func _resolve_colors(you_pref: String, opp_pref: String) -> Dictionary:
	var you_id: String
	var opp_id: String

	if you_pref != RANDOM_ID and COLOR_PALETTE.has(you_pref):
		you_id = you_pref
	else:
		you_id = ""

	if opp_pref != RANDOM_ID and COLOR_PALETTE.has(opp_pref):
		opp_id = opp_pref
	else:
		opp_id = ""

	if you_id == "":
		you_id = _pick_random_color([] if opp_id == "" else [opp_id])
	if opp_id == "":
		opp_id = _pick_random_color([you_id])
	elif opp_id == you_id:
		# Prefer uniqueness for readability when prefs collide.
		opp_id = _pick_random_color([you_id])

	return {"you": you_id, "opponent": opp_id}


func _pick_random_color(exclude: Array) -> String:
	var pool: Array = []
	for id in RANDOM_COLOR_IDS:
		if id not in exclude:
			pool.append(id)
	if pool.is_empty():
		for id in COLOR_PALETTE.keys():
			if id not in exclude:
				pool.append(id)
	if pool.is_empty():
		return "blue"
	return str(pool[randi() % pool.size()])


func apply_to_sprites(
	shield: CanvasItem,
	insignia: CanvasItem,
	faction_id: String,
	color_id: String,
	is_dux: bool = false,
	outline: CanvasItem = null
) -> void:
	var faction := get_faction(faction_id)
	var shield_tex: Texture2D = _load_texture(faction["shield"])
	var insignia_tex: Texture2D = _load_texture(faction["insignia"])
	var tint := get_color(color_id)

	_set_texture(shield, shield_tex)
	_set_texture(insignia, insignia_tex)
	shield.modulate = tint
	insignia.modulate = Color.WHITE

	if outline:
		if is_dux:
			_set_texture(outline, get_outline_texture(shield_tex, DUX_GOLD, DUX_OUTLINE_PX))
			outline.visible = true
			outline.modulate = Color.WHITE
		else:
			outline.visible = false


func get_outline_texture(src: Texture2D, color: Color = DUX_GOLD, width: int = 2) -> Texture2D:
	if src == null:
		return null
	var key := "%s_%s_%d" % [src.resource_path, color.to_html(false), width]
	if _outline_cache.has(key):
		return _outline_cache[key]
	var tex := _make_outline_texture(src, color, width)
	_outline_cache[key] = tex
	return tex


func _make_outline_texture(src: Texture2D, color: Color, width: int) -> Texture2D:
	var src_img := _texture_to_image(src)
	if src_img == null:
		return null
	var w := src_img.get_width()
	var h := src_img.get_height()
	var ow := w + width * 2
	var oh := h + width * 2
	var out := Image.create(ow, oh, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	for y in range(oh):
		for x in range(ow):
			var sx := x - width
			var sy := y - width
			if _alpha_at(src_img, sx, sy) > 0.1:
				continue
			var near := false
			for dy in range(-width, width + 1):
				for dx in range(-width, width + 1):
					if _alpha_at(src_img, sx + dx, sy + dy) > 0.1:
						near = true
						break
				if near:
					break
			if near:
				out.set_pixel(x, y, color)
	return ImageTexture.create_from_image(out)


func _alpha_at(img: Image, x: int, y: int) -> float:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return 0.0
	return img.get_pixel(x, y).a


func _texture_to_image(src: Texture2D) -> Image:
	var img: Image = src.get_image()
	if img == null and src.resource_path != "":
		img = Image.load_from_file(ProjectSettings.globalize_path(src.resource_path))
	if img == null:
		push_error("Could not read pixels for outline: %s" % src.resource_path)
		return null
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img


func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var img := Image.new()
	var err := img.load(ProjectSettings.globalize_path(path))
	if err != OK:
		push_error("Failed to load pawn texture: %s (%s)" % [path, error_string(err)])
		return null
	return ImageTexture.create_from_image(img)


func _set_texture(node: CanvasItem, tex: Texture2D) -> void:
	if node is Sprite2D:
		(node as Sprite2D).texture = tex
	elif node is TextureRect:
		(node as TextureRect).texture = tex


func cosmetics_for_player(player_id: int) -> Dictionary:
	var mc = GlobalSet.match_cosmetics
	if mc == null:
		mc = campaign_cosmetics()
	var key := str(player_id)
	if mc.has(key):
		return mc[key]
	return {"faction": "roman", "color": "blue" if player_id == 1 else "red"}
