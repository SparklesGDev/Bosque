extends Node2D
class_name Looter

export(String, MULTILINE) var loot_table
export(float) var drop_force = 300

func on_death(attack_data): spawn_all_loot()

func spawn_all_loot():
	var json_parse = JSON.parse(loot_table)
	for pool in json_parse.result:
		var entry = get_entry_from(pool)
		if not entry.has("count"): entry.count = 1
		if entry.has("item"): call_deferred("spawn_stack", entry.item, entry.count, global_position)
		# ABOVE: unless this is an empty / fail entry, spawn it deferredly as it's a collision not. right now
	
func spawn_stack(item, stack_size, location):
	var item_drop = InventorySystem.dropped_item_scene.instance()
	item_drop.initialize(InventorySystem.get_item_by_id(item), stack_size)
	$"/root/Root".current_scene_node.add_child(item_drop)
	item_drop.global_position = location
	var rnd_angle = deg2rad(rand_range(-60, -120))
	item_drop.velocity = Vector2(cos(rnd_angle), sin(rnd_angle)) * drop_force
	
func get_entry_from(pool):
	var pool_max = 0
	for entry in pool: pool_max += int(entry.weight)
	var choice = randi() % pool_max
	for entry in pool:
		if choice < entry.weight:
			return entry
		else: choice -= entry.weight
	return null