extends Button

const DEBUG_MODE = false
const EQUIPPED_ICON_TEXT = " [img]res://Inventory/equipped_icon.png[/img]"

signal on_item_used(item)

var item : InventoryItem

func initialize(item):
	self.item = item
	$Name.bbcode_text = item.name
	$VBoxContainer/Description.bbcode_text = item.description
	$Icon.texture = item.icon
	refresh(item)

func refresh(item):
	if item.has_flag(InventoryItem.EQUIPPABLE):
		if DEBUG_MODE: disabled = item.amount < 1
		else: visible = item.amount > 0
		if InventorySystem.equipment.has(item): $Name.bbcode_text += EQUIPPED_ICON_TEXT
		else: $Name.bbcode_text = $Name.bbcode_text.trim_suffix(EQUIPPED_ICON_TEXT)
	if item.has_flag(InventoryItem.CONSUMABLE):
		if DEBUG_MODE: disabled = item.amount < 0
		else: visible = item.amount > 0
	$Amount.text = str(item.amount) if item.has_flag(InventoryItem.CONSUMABLE) else ""
	
func _pressed():
	emit_signal("on_item_used", item)