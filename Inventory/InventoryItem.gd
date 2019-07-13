class_name InventoryItem

const EQUIPPABLE = 1
const CONSUMABLE = 2
const FULL_HEALTH = 4

const CATEGORY_WEAPON = 0
const CATEGORY_FOOD = 1

var id
var name : String
var description : String
var icon : Texture
var category : int
var effects : Dictionary
var amount = -1
var flags
#var data = {}

func _init(id, name, description, icon, category, effects, flags):
	self.id = id
	self.name = name
	self.description = description
	self.icon = icon
	self.category = category
	self.effects = effects
	self.flags = flags

func in_category(category) -> bool: return self.category == category
func has_flag(flag) -> bool: return flags & flag