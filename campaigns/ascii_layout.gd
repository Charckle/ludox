extends RefCounted
class_name AsciiLayout

# Parses an ASCII grid into pawn data.
#
# Legend (whitespace between cells is ignored):
#   . = empty
#   E/e = enemy dux/pawn (player 1), side default look
#   D/d = your dux/pawn (player 2), side default look
#
# Optional city-state letters set faction (and that faction's color).
# Uppercase = dux. You (player 2):
#   A/a Athenian   S/s Spartan   C/c Corinthian   G/g Aeginetan
#   H/h Thespian   M/m Milesian  P/p Plataean     F/f Gaul (Caesar's cavalry)
# Enemy (player 1) city-states:
#   I/i Milesian (Ionian levy)   B/b Theban (medizer)   U/u Gaul (Hannibal's Celts)
#   O/o Pontus   N/n Numidian   T/t German
#
# Row 0 is the top of the board. Returns:
#   { "pawns": Array, "size": Vector2i }

const TOKEN := {
	"E": {"player": 1, "dux": true},
	"e": {"player": 1, "dux": false},
	"D": {"player": 2, "dux": true},
	"d": {"player": 2, "dux": false},
	"A": {"player": 2, "dux": true, "faction": "athenian"},
	"a": {"player": 2, "dux": false, "faction": "athenian"},
	"S": {"player": 2, "dux": true, "faction": "spartan"},
	"s": {"player": 2, "dux": false, "faction": "spartan"},
	"C": {"player": 2, "dux": true, "faction": "corinthian"},
	"c": {"player": 2, "dux": false, "faction": "corinthian"},
	"G": {"player": 2, "dux": true, "faction": "aeginetan"},
	"g": {"player": 2, "dux": false, "faction": "aeginetan"},
	"H": {"player": 2, "dux": true, "faction": "thespian"},
	"h": {"player": 2, "dux": false, "faction": "thespian"},
	"M": {"player": 2, "dux": true, "faction": "milesian"},
	"m": {"player": 2, "dux": false, "faction": "milesian"},
	"P": {"player": 2, "dux": true, "faction": "plataean"},
	"p": {"player": 2, "dux": false, "faction": "plataean"},
	"I": {"player": 1, "dux": true, "faction": "milesian"},
	"i": {"player": 1, "dux": false, "faction": "milesian"},
	"B": {"player": 1, "dux": true, "faction": "theban"},
	"b": {"player": 1, "dux": false, "faction": "theban"},
	"U": {"player": 1, "dux": true, "faction": "gaul"},
	"u": {"player": 1, "dux": false, "faction": "gaul"},
	"F": {"player": 2, "dux": true, "faction": "gaul"},
	"f": {"player": 2, "dux": false, "faction": "gaul"},
	"O": {"player": 1, "dux": true, "faction": "pontus"},
	"o": {"player": 1, "dux": false, "faction": "pontus"},
	"N": {"player": 1, "dux": true, "faction": "numidian"},
	"n": {"player": 1, "dux": false, "faction": "numidian"},
	"T": {"player": 1, "dux": true, "faction": "german"},
	"t": {"player": 1, "dux": false, "faction": "german"},
}


static func parse(rows: Array) -> Dictionary:
	var pawns: Array = []
	var height: int = rows.size()
	var width: int = 0

	for y in height:
		var cells := _cells(rows[y])
		width = max(width, cells.size())
		for x in cells.size():
			var ch: String = cells[x]
			if not TOKEN.has(ch):
				continue
			var spec: Dictionary = TOKEN[ch]
			var pawn := {
				"pos": Vector2i(x, y),
				"player": spec["player"],
				"dux": spec["dux"],
			}
			if spec.has("faction"):
				pawn["faction"] = spec["faction"]
			pawns.append(pawn)

	return {"pawns": pawns, "size": Vector2i(width, height)}


static func _cells(row: String) -> Array:
	var out: Array = []
	for c in row:
		if c == " " or c == "\t":
			continue
		out.append(c)
	return out
