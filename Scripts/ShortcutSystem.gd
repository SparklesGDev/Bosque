extends Node

class ShortcutPair:
	var shortcut_1
	var shortcut_2
	
	func _init(shortcut_1, shortcut_2):
		self.shortcut_1 = shortcut_1
		self.shortcut_2 = shortcut_2

var shortcuts = {}
var unlocked_shortcuts = []

func _ready(): add_to_group("Savable")
	
func clear_shortcuts(): shortcuts = {}

func get_shortcut(shortcut_name): return shortcuts[shortcut_name] if shortcuts.has(shortcut_name) else null

func register_shortcut(shortcut_name, shortcut):
	var pair = get_shortcut(shortcut_name)
	if not pair: pair = ShortcutPair.new(shortcut, null)
	else: pair.shortcut_2 = shortcut
	shortcuts[shortcut_name] = pair

func get_other_end(shortcut_name, this_end):
	var pair = get_shortcut(shortcut_name)
	if not pair: return null
	if pair.shortcut_1 == this_end: return pair.shortcut_2
	else: return pair.shortcut_1

func check_if_unlocked(shortcut_name): return shortcut_name in unlocked_shortcuts
func unlock_shortcut(shortcut_name): unlocked_shortcuts.push_back(shortcut_name)

var save_key = "shortcuts"
func load_data(data):
	if data: for shortcut in data.unlocked:
		unlocked_shortcuts.push_back(shortcut)

func save_data():
	return { "unlocked": unlocked_shortcuts }