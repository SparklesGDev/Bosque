extends Node
class_name Entity

export(int) var maximum_health = 3; # this entities' maximum health
export(float) var invincibilityDuration = 1; # for how long you'll not take damage from an enemy after it hurts you
export(float) var hurtDuration = 0.3; # for how many seconds the character will be knocked back when hurt

var attackers = Dictionary();

var health; # your current amount of hit points
var hurtTime = 0; # how long you'll still be hurt 
var is_hurt; # true when you get hit; when it's the case, you cannot move
var last_attack # the last attack this entity suffered
var alive = true # if this entity has not died yet
var invincible # makes this entity invincible against all attacks

signal on_hurt(attack_data, new_health)
signal on_heal(amount, source, new_health)
signal on_death(attack_data)

static func get_from_node(node) -> Entity: return node.find_node("Entity")

func _ready(): initialize()

func initialize():
	alive = true
	hurtTime = 0
	health = maximum_health;
	attackers = Dictionary()
	is_hurt = false
	last_attack = null
	invincible = false

func _process(delta):
	for attacker in attackers:
		attackers[attacker] -= delta;
		if attackers[attacker] <= 0: attackers.erase(attacker);
	
	is_hurt = health <= 0
	if hurtTime > 0:
		hurtTime -= delta
		is_hurt = true

func hurt(attack : AttackData) -> bool:
	if invincible or attackers.has(attack.source): return false
	attackers[attack.source] = invincibilityDuration; # adds this source to the list of recent attackers
	last_attack = attack
	health -= attack.damage
	hurtTime = hurtDuration; # keeps you from doing anything for some time
	if health <= 0 and alive: die()
	elif health > 0: emit_signal("on_hurt", attack, health)
	
	return true

func heal(amount, source):
	amount = min(maximum_health - health, amount)
	health += amount
	emit_signal("on_heal", amount, source, health)

func die():
	alive = false
	emit_signal("on_death", last_attack)