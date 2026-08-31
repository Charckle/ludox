extends Node

# Saved user scenarios. user://scenarios.json

var path := "user://scenarios.json"
var scenarios: Array = []


func _ready() -> void:
	load_all()


func load_all() -> void:
	scenarios = []
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open scenarios file.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for item in parsed.get("scenarios", []):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var s: Dictionary = ScenarioCodec.sanitize(item)
		if str(s.get("id", "")) == "":
			s["id"] = ScenarioCodec.new_id()
		scenarios.append(s)


func save_all() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write scenarios file.")
		return
	file.store_string(JSON.stringify({"scenarios": scenarios}, "\t"))
	file.close()


func get_by_id(id: String) -> Dictionary:
	for s in scenarios:
		if str(s.get("id", "")) == id:
			return s
	return {}


func upsert(data: Dictionary) -> Dictionary:
	var s: Dictionary = ScenarioCodec.sanitize(data)
	if str(s.get("id", "")) == "":
		s["id"] = ScenarioCodec.new_id()
	for i in scenarios.size():
		if str(scenarios[i].get("id", "")) == s["id"]:
			scenarios[i] = s
			save_all()
			return s
	scenarios.append(s)
	save_all()
	return s


func remove(id: String) -> void:
	for i in range(scenarios.size() - 1, -1, -1):
		if str(scenarios[i].get("id", "")) == id:
			scenarios.remove_at(i)
	save_all()


func import_code(code: String) -> Dictionary:
	var decoded := ScenarioCodec.decode(code)
	if not decoded["ok"]:
		return decoded
	var data: Dictionary = decoded["data"].duplicate(true)
	data["id"] = ScenarioCodec.new_id()
	var saved := upsert(data)
	return {"ok": true, "error": "", "data": saved}
