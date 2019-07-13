extends Panel

signal state_changed(state)

export(PackedScene) var slot_scene
export(Array, NodePath) var tabs

var food_tab_node
var slots = {}
var is_cutscene_running
var is_opened = false
var is_player_dead

onready var stats_label
func _ready():
	generate_ui()
	# these two lines below here both connect signals to the same thing
	# is this correct?
	InventorySystem.connect("on_item_equipped", self, "on_item_equipped")
	InventorySystem.connect("on_item_consumed", self, "on_item_amount_changed")
	InventorySystem.connect("on_item_amount_changed", self, "on_item_amount_changed")
	InventorySystem.connect("on_food_capacity_changed", self, "on_food_capacity_changed")

func generate_ui():
	var tab_nodes = []
	for tab in tabs:
		var tab_node = get_node(tab)
		tab_nodes.push_back(tab_node)
		if tab_node.is_in_group("Limited Capacity"): food_tab_node = tab_node

	for item in InventorySystem.database:
		var new_slot = slot_scene.instance()
		new_slot.initialize(item)
		new_slot.connect("on_item_used", InventorySystem, "use_item")
		tab_nodes[item.category].add_slot(new_slot)
		slots[item.id] = new_slot
	
func _process(delta):
	if not is_cutscene_running and not is_player_dead and Input.is_action_just_pressed("open_inventory"): toggle_screen()

func toggle_screen():
	print("Is opened: %s" % is_opened)
	is_opened = !is_opened
	visible = is_opened
	emit_signal("state_changed", is_opened)

func on_item_used(item, used):
	slots[item.id].refresh(item)

func on_item_equipped(item, equipped_properly):
	if equipped_properly: on_item_amount_changed(item, item.amount)
	elif not InventorySystem.is_setting_up: NotificationSystem.notify("Failed to unequip: is holding food", item.icon)

func on_item_amount_changed(item, old_amount):
	slots[item.id].refresh(item)
	if item.in_category(InventoryItem.CATEGORY_FOOD):
		food_tab_node.refresh(InventorySystem.food_amount)

func on_food_capacity_changed(new_value): food_tab_node.on_capacity_changed(new_value)

func _on_cutscene_state_changed(state):
	is_cutscene_running = state >= 0 and state < 2
	if is_opened and is_cutscene_running: toggle_screen()

func on_player_death(attack_data):
	is_player_dead = true