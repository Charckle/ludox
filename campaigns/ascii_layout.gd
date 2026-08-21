extends RefCounted
class_name AsciiLayout

# Parses an ASCII grid into pawn data.
#
# Legend (whitespace between cells is ignored):
#   E = enemy dux   (player 1, AI, top)
#   e = enemy pawn
#   D = your dux    (player 2, human, bottom)
#   d = your pawn
#   . = empty
#
# Row 0 is the top of the board. Returns:
#   { "pawns": Array, "size": Vector2i }
static func parse(rows: Array) -> Dictionary:
	var pawns: Array = []
	var height: int = rows.size()
	var width: int = 0

	for y in height:
		var cells := _cells(rows[y])
		width = max(width, cells.size())
		for x in cells.size():
			var ch: String = cells[x]
			match ch:
				"E":
					pawns.append({"pos": Vector2i(x, y), "player": 1, "dux": true})
				"e":
					pawns.append({"pos": Vector2i(x, y), "player": 1, "dux": false})
				"D":
					pawns.append({"pos": Vector2i(x, y), "player": 2, "dux": true})
				"d":
					pawns.append({"pos": Vector2i(x, y), "player": 2, "dux": false})
				_:
					pass

	return {"pawns": pawns, "size": Vector2i(width, height)}


static func _cells(row: String) -> Array:
	var out: Array = []
	for c in row:
		if c == " " or c == "\t":
			continue
		out.append(c)
	return out
