class_name AttackData

var damage : int
var source
var direction : Vector2

func _init(damage, source, direction):
	self.damage = damage
	self.source = source
	self.direction = direction