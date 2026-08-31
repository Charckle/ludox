extends RefCounted

# Greco-Persian Wars. XXI rules, human = player 2 (bottom).
# map_position is a UV on greek_persian_wars.png. Attica sites are nudged
# apart so Marathon / Salamis / Plataea do not stack at this zoom.
#
# LETTERS:
#   e/E  Persian (campaign default)
#   a/A  Athenian    s/S Spartan     c/C Corinthian   g/G Aeginetan
#   h/H  Thespian    m/M Milesian    p/P Plataean
#   i/I  Milesian levy with Persia (Salamis)
#   b/B  Theban (medizer, Plataea)

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2
const CEASAR := 3

const LETTERS := {
	"E": {"player": 1, "dux": true},
	"e": {"player": 1, "dux": false},
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
}


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "greco_persian_wars"
	c.title = "Greco-Persian Wars"
	c.map_texture = preload("res://sprites/images/greek_persian_wars.png")
	c.cosmetics = {
		"1": {"faction": "persian", "color": "purple"},
		"2": {"faction": "athenian", "color": "blue"},
	}
	c.battles = [
		_sardis(),
		_marathon(),
		_thermopylae(),
		_salamis(),
		_plataea(),
		_mycale(),
	]
	return c


static func _battle(id: String, title: String, desc: String, map_pos: Vector2,
		ai: int, rows: Array, epic_track: String = "") -> BattleData:
	var parsed := AsciiLayout.parse(rows, LETTERS)
	var b := BattleData.new()
	b.id = id
	b.title = title
	b.description = desc
	b.map_position = map_pos
	b.rules = RULES_XXI
	b.ai_lvl = ai
	b.city_size = parsed["size"]
	b.pawns = parsed["pawns"]
	b.epic_track = epic_track
	return b


static func _with_victory(b: BattleData, text: String) -> BattleData:
	b.victory_text = text
	return b


static func _sardis() -> BattleData:
	return _with_victory(_battle(
		"sardis",
		"Mission 1 - Burning of Sardis (498 BCE)",
		"The Ionian cities have risen against the Great King. Milesians lead the strike on "
		+ "the satrapal capital of Lydia, with Athenian ships at their back. Sardis burns — "
		+ "and Persia learns that Greece will not kneel.",
		Vector2(0.80, 0.40),  # inland Lydia, east of the Ionian coast
		EASY,
		[
			"e e e e e e e e",
			". . E . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . M . . . .",
			"m m m a a m m m",
		]
	), "Sardis burns. The satrapal capital of Lydia is a ruin, and Persia learns that Greece will not kneel.")


static func _marathon() -> BattleData:
	return _with_victory(_battle(
		"marathon",
		"Mission 2 - Battle of Marathon (490 BCE)",
		"Darius has landed a host on the plain of Marathon, a day's march from Athens. "
		+ "Athenian hoplites hold the center; Plataeans take the wings. The charge must hit "
		+ "the Persian line before the archers can be brought to bear.",
		Vector2(0.40, 0.48),  # east coast of Attica
		NORMAL,
		[
			"e e e e e e e e",
			"e . . E . . . e",
			". . . . . . . .",
			"e . e e e e e .",
			". . . . . . . .",
			"a a . A . . a .",
			". a a . a a . .",
			"p p . . . . p p",
		],
		"res://audio/music/epic/Marathon Plain.ogg"
	), "The Persian line breaks on the plain. Athens is saved — a day's march away, and still free.")


static func _thermopylae() -> BattleData:
	return _with_victory(_battle(
		"thermopylae",
		"Mission 3 - Battle of Thermopylae (480 BCE)",
		"Xerxes pours into Greece. Leonidas holds the Hot Gates with his Spartans; the "
		+ "Thespians stand with them. The pass is so narrow that numbers count for little. "
		+ "If it falls, the road to Athens lies open.",
		Vector2(0.30, 0.30),  # Malian Gulf, north of Attica
		CEASAR,
		[
			". e e . . e e .",
			". e . . E . e .",
			". e e . . e e .",
			". . . e . . e .",
			". . . . . . . .",
			". . . S . s . .",
			"h s s . . s s h",
			". s s . . . . .",
		]
	), "The Hot Gates hold. Xerxes' host is thrown back from the pass, and the road to Athens remains closed.")


static func _salamis() -> BattleData:
	return _with_victory(_battle(
		"salamis",
		"Mission 4 - Battle of Salamis (480 BCE)",
		"Athens is evacuated. Themistocles packs the allied fleet into the strait — "
		+ "Athenian, Aeginetan, and Corinthian ships, with a Spartan among them. Persian "
		+ "and Ionian hulls crowd in after them. In the channel, numbers become a trap.",
		Vector2(0.28, 0.54),  # island west of Athens
		HARD,
		[
			". i . . . . . . . . i .",
			"e . . e e E e e . . . e",
			". . . . . . . . . . . .",
			". . . . . . . . . . . .",
			". . . . e e e . . . . .",
			". . . . . . . . . . . .",
			". . . a a A a g . . . .",
			". c . . . . . . . . s .",
		]
	), "The strait is choked with wrecks. The Great King's fleet is broken, and the empty city of Athens still stands.")


static func _plataea() -> BattleData:
	return _with_victory(_battle(
		"plataea",
		"Mission 5 - Battle of Plataea (479 BCE)",
		"Mardonius still holds Boeotia. Athens and Plataea take the left; Corinthians "
		+ "the center; Spartans the right under Pausanias. Opposite the Athenians, Thebes "
		+ "has taken the Persian side. The last Persian army in Greece stands or falls here.",
		Vector2(0.34, 0.41),  # Boeotia, NW of Athens
		CEASAR,
		[
			"b b b e e e e e e e e e e",
			". . b e e . E . . e e e .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			"p a a a . c s . S . s . .",
			"p a a . c . s s s . s . .",
		],
		"res://audio/music/epic/At Plataea.ogg"
	), "Mardonius is dead and his army scattered. The last Persian host in Greece is destroyed.")


static func _mycale() -> BattleData:
	return _with_victory(_battle(
		"mycale",
		"Mission 6 - Battle of Mycale (479 BCE)",
		"The invasion of Greece is broken, but a Persian force still holds the Ionian coast. "
		+ "Spartans and Athenians cross to Mycale; the Milesians rise with them. The beached "
		+ "camp is stormed, and the war ends on Asia's shore.",
		Vector2(0.70, 0.50),  # promontory opposite Samos
		CEASAR,
		[
			". . . . . . . .",
			". . e e E . . .",
			". . e e e e e .",
			". . . . . . e e",
			". . . e . a . .",
			". m . . . . . m",
			". . a a S . a .",
			"m . . . . . . .",
		]
	), "The beached camp is stormed. On Asia's shore the war ends, and Ionia is free.")
