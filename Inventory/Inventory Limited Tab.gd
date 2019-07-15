extends "res://Inventory/InventoryTab.gd"

var inventory_capacity = 0
var item_count = 0

func on_capacity_changed(new_capacity):
	inventory_capacity = new_capacity
	refresh(item_count)

func refresh(item_count):
	self.item_count = item_count
	$Capacity.text = "Capacity: {0}/{1}".format([item_count, inventory_capacity])

func clear_inventory():
	InventorySystem.clear_food()