extends Area2D

export(String) var shortcut_name
onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	ShortcutSystem.register_shortcut(shortcut_name, self)
	$"Interact Label".rect_scale = Vector2.ONE / scale
	interaction_disabled()

func _process(delta):
	interaction_possible = ShortcutSystem.check_if_unlocked(shortcut_name)
	if interaction_possible: set_process(false)
	
func enter():
	$"Enter Sound".play()
	player.global_position = ShortcutSystem.get_other_end(shortcut_name, self).global_position
	# places the player at the other end of this shortcut

# Interaction #
var interaction_priority = 1
var interaction_possible = false
func interact(): enter()
func interaction_enabled(): $"Interact Label".visible = true
func interaction_disabled(): $"Interact Label".visible = false