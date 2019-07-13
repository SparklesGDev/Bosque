extends RichTextLabel

const HEADER = "[b] Player Stats[/b]\n\n"

var stats = {}

func _ready():
	stats = get_tree().get_nodes_in_group("Player")[0].get_node("Stats").stats
	refresh()
	
func on_stat_updated(stat, new_value):
	stats[stat] = new_value
	refresh()

func refresh():
	bbcode_text = HEADER
	for stat in stats:
		var stat_name = ""
		var ignore_stat = false
		
		match stat:
			"damage": stat_name = "Attack Damage"
			"defense": stat_name = "Defense"
			"maximum_health": stat_name = "Maximum Health"
			"movement_speed": stat_name = "Movement Speed"
			"food_capacity": ignore_stat = true
		
		if not ignore_stat: bbcode_text += "[b]{0}[/b] {1}\n".format([stat_name, stats[stat]])