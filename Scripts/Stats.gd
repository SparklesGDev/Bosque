extends Node

signal on_stat_changed(stat, new_value)

class StatModifier:
	var stat : String
	var amount : float
	var source
	
	func _init(stat, amount, source = null):
		self.stat = stat
		self.amount = amount
		self.source = source

export(Dictionary) var stats = {
	"damage": 3.0,
	"maximum_health": 10.0,
	"movement_speed": 100
}

var default_stats
var modifiers = []

func _ready(): default_stats = stats.duplicate()

func get_value(stat) -> float: return stats[stat]

func add_modifier(stat, amount, source = null, auto_recalculate = true):
	modifiers.push_back(StatModifier.new(stat, amount, source))
	if auto_recalculate: recalculate_stat(stat)

func recalculate_stat(stat):
	stats[stat] = default_stats[stat]
	for mod in modifiers:
		if mod.stat != stat: continue
		stats[stat] += mod.amount
	emit_signal("on_stat_changed", stat, stats[stat])

func remove_all_modifiers_from(source):
	var targets = []
	for mod in modifiers:
		if mod.source == source: targets.push_back(mod) # stores this modifier to be removed (can't remove elements while iterating)

	for t in targets: modifiers.erase(t) # removes all modifiers that are marked to be removed