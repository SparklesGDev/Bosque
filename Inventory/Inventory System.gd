extends Node2D

signal on_item_consumed(item, consumed_properly)
signal on_item_equipped(item, equipped_properly)

signal on_item_amount_changed(item, old_amount)
signal on_food_capacity_changed(new_value)

export(String, FILE, "*.json") var database_path
export(PackedScene) var dropped_item_scene

var food_amount = 0
var food_capacity = 0

var equipment = []
var database = []
var player # set by the player himself

var is_setting_up = false

func _ready():
	equipment = []
	generate_database()

func generate_database():
	var file = File.new()
	file.open(database_path, File.READ)
	var parsed_database = parse_json(file.get_as_text())
	for category in range(parsed_database.size()):
		for category_id in parsed_database[category]:
			var item = generate_item(parsed_database[category][category_id], category_id, category)
			database.push_back(item)

# generate_item() creates a new item from the json data of it
func generate_item(parsed_json, id, category) -> InventoryItem:
	var flags = 0
	if parsed_json.has("flags"):
		for f in parsed_json.flags:
			match f:
				"equippable": flags += InventoryItem.EQUIPPABLE
				"consumable": flags += InventoryItem.CONSUMABLE
				"full_health": flags += InventoryItem.FULL_HEALTH
	
	return InventoryItem.new(id, parsed_json.name, parsed_json.description,
		load("res://Inventory/Items/%s" % parsed_json.icon), category, parsed_json.effects, flags)
	
func get_item_by_id(id) -> InventoryItem:
	for item in database: if item.id == id: return item
	return null

func use_item(item : InventoryItem):
	var player_stats = player.get_node("Stats")
	player_stats.remove_all_modifiers_from(item)
	
	if item.has_flag(InventoryItem.EQUIPPABLE):
		var equipping_result = _equip_item(item)
		var is_equipped = equipping_result[0]
		for e in item.effects:
			if is_equipped: player_stats.add_modifier(e, item.effects[e], item)
			else: player_stats.recalculate_stat(e)
		emit_signal("on_item_equipped", item, equipping_result[1])
		return equipping_result[1]
	elif item.has_flag(InventoryItem.CONSUMABLE):
		var has_consumed = _consume_item(item)
		for effect in item.effects:
			match effect:
				"heal":
					if has_consumed: player.entity.heal(item.effects[effect], item)
		emit_signal("on_item_consumed", item, has_consumed)
		return has_consumed
		
	"""
	this thing is broken
	you need to fix this whole inventory system
	godamnit
	if you dont remember what it is,
	the bag shouldnt get unequipped when its holding items
	but this breaks everything
	so give it a better look
	thx
		Also code:
		#
		if item.effects.has("food_capacity") and food_amount > food_capacity - item.effects["food_capacity"]:
			emit_signal("on_item_use_failed", item)
			return true
		else: 
		#
	"""

func _equip_item(item):
	if item.amount == 0: return false # can't equip item if you don't own it
	
	var was_equipped = equipment.has(item)
	var holds_items = item.effects.has("food_capacity") and was_equipped and food_amount > food_capacity - item.effects["food_capacity"]
	# if the item isn't equipped, equip it
	if not was_equipped or (holds_items and not is_setting_up):
		var unequipped_other = true
		for equip in equipment: # goes through all equipment, and unequips the equipment (if any) of this category
			if not equip == item and equip.category == item.category:
				unequipped_other = use_item(equip)
				break
		if not was_equipped and unequipped_other: equipment.push_back(item) # then puts it into the equipment list
		return [unequipped_other, not holds_items]
	
	# else, unequip it
	equipment.erase(item)
	return [false, true]

func _consume_item(item):
	# true if it doesn't require max hp or it does and you have it
	var full_health_met = not item.has_flag(InventoryItem.FULL_HEALTH) or player.entity.health < player.entity.maximum_health
	
	if item.amount > 0 and full_health_met:
		item.amount -= 1
		if item.in_category(InventoryItem.CATEGORY_FOOD): food_amount -= 1
		return true
	return false
	
func add_item(item : InventoryItem, amount = 1):
	if item.has_flag(InventoryItem.CONSUMABLE) or item.amount < 1:
		var old_amount = item.amount
		if old_amount < 0: amount += 1 # increases amount to add by 1 when the item wasn't unlocked yet, since the amount was -1
		item.amount += amount
		if item.in_category(InventoryItem.CATEGORY_FOOD):
			calculate_food_amount()
			if food_amount > food_capacity and not is_setting_up:
				item.amount -= (food_amount - food_capacity)
				food_amount = food_capacity
		emit_signal("on_item_amount_changed", item, old_amount)
		var amount_added = item.amount - old_amount
		if old_amount < 0: amount_added -= 1 # because the first time you add an item, its amount'll be -1
		return amount_added
	return -1

func remove_item(item : InventoryItem, amount = 1):
	var old_amount = item.amount
	if item.amount > 0: item.amount -= amount
	if item.in_category(InventoryItem.CATEGORY_FOOD):
		calculate_food_amount()
	emit_signal("on_item_amount_changed", item, old_amount)

# Food #

func calculate_food_amount():
	food_amount = 0
	for item in database:
		if item.amount >= 0 and item.in_category(InventoryItem.CATEGORY_FOOD):
			food_amount += item.amount

func on_stat_changed(stat, new_value):
	if stat == "food_capacity":
		food_capacity = new_value
		emit_signal("on_food_capacity_changed", new_value)

func clear_food():
	for item in database:
		if item.amount > 0 and item.in_category(InventoryItem.CATEGORY_FOOD):
			remove_item(item, item.amount)

# Saving Code #
var save_key = "inventory"
func load_data(data):
	call_deferred("load_equipment", data) # loads equipment deferredly so the player can load properly

func load_equipment(data):
	is_setting_up = true
	for equip in InventorySystem.equipment: use_item(equip)
	var items = data.amounts if data else database
	for item in items: # can't loop 'database' since new items would cause issues
		if item is String: item = get_item_by_id(item)
		var target_amount = data.amounts[item.id] if data else -1
		if target_amount > item.amount: add_item(item, target_amount - max(0, item.amount))
		else: remove_item(item, item.amount - target_amount)
	
	if data and data.equipment: for item_id in data.equipment: use_item(get_item_by_id((item_id)))
	is_setting_up = false
	
func save_data():
	var amounts = {}
	for item in database: amounts[item.id] = item.amount
	var equipment_ids = []
	for item in equipment: equipment_ids.push_back(item.id)
	return {
		"equipment": equipment_ids,
		"amounts": amounts
	}