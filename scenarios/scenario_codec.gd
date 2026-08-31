extends RefCounted
class_name ScenarioCodec

# User-authored battles. Same pawn shape as BattleData / AsciiLayout.
# Share string: LUDOX1.<base64url(gzip json)>

const VERSION := 1
const PREFIX := "LUDOX1."
const RULE_NAMES := ["Classic", "Classic PLUS", "XXI"]
const AI_NAMES := ["Easy", "Normal", "Hard", "Caesar"]


static func make_blank() -> Dictionary:
	return {
		"v": VERSION,
		"id": "",
		"title": "New Scenario",
		"description": "",
		"rules": 2,
		"ai_lvl": 1,
		"city_size": [8, 8],
		"pawns": [],
	}


static func new_id() -> String:
	return "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]


static func sanitize(data: Dictionary) -> Dictionary:
	var size_raw = data.get("city_size", [8, 8])
	var w := 8
	var h := 8
	if typeof(size_raw) == TYPE_ARRAY and size_raw.size() >= 2:
		w = int(size_raw[0])
		h = int(size_raw[1])
	elif typeof(size_raw) == TYPE_VECTOR2I:
		w = size_raw.x
		h = size_raw.y
	if w != 12:
		w = 8
	h = 8

	var pawns: Array = []
	var seen := {}
	for p in data.get("pawns", []):
		if typeof(p) != TYPE_DICTIONARY:
			continue
		var pos_raw = p.get("pos", [0, 0])
		var x := 0
		var y := 0
		if typeof(pos_raw) == TYPE_ARRAY and pos_raw.size() >= 2:
			x = int(pos_raw[0])
			y = int(pos_raw[1])
		elif typeof(pos_raw) == TYPE_VECTOR2I:
			x = pos_raw.x
			y = pos_raw.y
		if x < 0 or y < 0 or x >= w or y >= h:
			continue
		var key := "%d,%d" % [x, y]
		if seen.has(key):
			continue
		seen[key] = true
		var faction := str(p.get("faction", "roman"))
		if not PawnCosmetics.FACTIONS.has(faction):
			faction = "roman"
		var player := int(p.get("player", 2))
		if player != 1:
			player = 2
		pawns.append({
			"pos": [x, y],
			"player": player,
			"dux": bool(p.get("dux", false)),
			"faction": faction,
		})

	var rules := int(data.get("rules", 2))
	rules = clampi(rules, 0, 2)
	var ai_lvl := int(data.get("ai_lvl", 1))
	ai_lvl = clampi(ai_lvl, 0, 3)
	var title := str(data.get("title", "")).strip_edges()
	if title == "":
		title = "Untitled"

	return {
		"v": VERSION,
		"id": str(data.get("id", "")),
		"title": title,
		"description": str(data.get("description", "")),
		"rules": rules,
		"ai_lvl": ai_lvl,
		"city_size": [w, h],
		"pawns": pawns,
	}


static func validate(data: Dictionary) -> Dictionary:
	var s := sanitize(data)
	var n1 := 0
	var n2 := 0
	var d1 := 0
	var d2 := 0
	for p in s["pawns"]:
		if int(p["player"]) == 1:
			n1 += 1
			if p["dux"]:
				d1 += 1
		else:
			n2 += 1
			if p["dux"]:
				d2 += 1
	if n2 < 1:
		return {"ok": false, "error": "Place at least one pawn for you (bottom)."}
	if n1 < 1:
		return {"ok": false, "error": "Place at least one pawn for the opponent (top)."}
	if d2 != 1:
		return {"ok": false, "error": "You need exactly one dux (bottom)."}
	if d1 != 1:
		return {"ok": false, "error": "The opponent needs exactly one dux (top)."}
	return {"ok": true, "error": "", "data": s}


static func city_size_of(data: Dictionary) -> Vector2i:
	var s := sanitize(data)
	return Vector2i(int(s["city_size"][0]), int(s["city_size"][1]))


static func pawns_for_board(data: Dictionary) -> Array:
	var out: Array = []
	for p in sanitize(data)["pawns"]:
		out.append({
			"pos": Vector2i(int(p["pos"][0]), int(p["pos"][1])),
			"player": int(p["player"]),
			"dux": bool(p["dux"]),
			"faction": str(p["faction"]),
		})
	return out


static func cosmetics_of(data: Dictionary) -> Dictionary:
	var s := sanitize(data)
	var f1 := ""
	var f2 := ""
	for p in s["pawns"]:
		if int(p["player"]) == 1 and f1 == "":
			f1 = str(p["faction"])
		elif int(p["player"]) == 2 and f2 == "":
			f2 = str(p["faction"])
	if f1 == "":
		f1 = "gaul"
	if f2 == "":
		f2 = "roman"
	return {
		"1": {"faction": f1, "color": PawnCosmetics.color_for_faction(f1)},
		"2": {"faction": f2, "color": PawnCosmetics.color_for_faction(f2)},
	}


static func to_battle(data: Dictionary) -> BattleData:
	var s := sanitize(data)
	var b := BattleData.new()
	b.id = str(s["id"])
	b.title = str(s["title"])
	b.description = str(s["description"])
	b.rules = int(s["rules"])
	b.ai_lvl = int(s["ai_lvl"])
	b.city_size = city_size_of(s)
	b.pawns = pawns_for_board(s)
	b.cosmetics = cosmetics_of(s)
	return b


static func summary_line(data: Dictionary) -> String:
	var s := sanitize(data)
	var size: Array = s["city_size"]
	var rule = RULE_NAMES[int(s["rules"])] if int(s["rules"]) < RULE_NAMES.size() else "XXI"
	var ai = AI_NAMES[int(s["ai_lvl"])] if int(s["ai_lvl"]) < AI_NAMES.size() else "Normal"
	return "%s  ·  %dx%d  ·  AI %s" % [rule, int(size[0]), int(size[1]), ai]


static func encode(data: Dictionary) -> String:
	var s := sanitize(data)
	s.erase("id")
	var json := JSON.stringify(s)
	var raw := json.to_utf8_buffer()
	var packed := raw.compress(FileAccess.COMPRESSION_GZIP)
	return PREFIX + _b64url(Marshalls.raw_to_base64(packed))


static func decode(code: String) -> Dictionary:
	var text := code.strip_edges()
	if text == "":
		return {"ok": false, "error": "Nothing to import."}
	if text.begins_with(PREFIX):
		var payload := text.substr(PREFIX.length()).strip_edges()
		var bytes := _b64url_to_raw(payload)
		if bytes.is_empty():
			return {"ok": false, "error": "Could not read that code."}
		var raw := bytes.decompress_dynamic(65536, FileAccess.COMPRESSION_GZIP)
		if raw.is_empty():
			return {"ok": false, "error": "Could not read that code."}
		var parsed = JSON.parse_string(raw.get_string_from_utf8())
		if typeof(parsed) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Could not read that code."}
		var check := validate(parsed)
		if not check["ok"]:
			return check
		return {"ok": true, "error": "", "data": check["data"]}
	# Bare JSON, for debugging or pasted library files.
	var parsed_json = JSON.parse_string(text)
	if typeof(parsed_json) == TYPE_DICTIONARY:
		var check_json := validate(parsed_json)
		if not check_json["ok"]:
			return check_json
		return {"ok": true, "error": "", "data": check_json["data"]}
	return {"ok": false, "error": "Not a Ludox scenario code."}


static func _b64url(b64: String) -> String:
	var s := b64.replace("+", "-").replace("/", "_")
	while s.ends_with("="):
		s = s.substr(0, s.length() - 1)
	return s


static func _b64url_to_raw(s: String) -> PackedByteArray:
	var t := s.replace("-", "+").replace("_", "/")
	while t.length() % 4 != 0:
		t += "="
	return Marshalls.base64_to_raw(t)
