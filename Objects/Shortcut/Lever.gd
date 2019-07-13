extends Area2D

export(String) var shortcut_name

func _ready():
	$"Interact Label".rect_scale = Vector2.ONE / scale
	interaction_disabled()
	call_deferred("check_if_interactive")
	
func check_if_interactive():
	interaction_possible = not ShortcutSystem.check_if_unlocked(shortcut_name)
	$Sprite.flip_h = not interaction_possible
	
func toggle():
	ShortcutSystem.unlock_shortcut(shortcut_name)
	interaction_possible = false
	$Sprite.flip_h = true
	$"Interact Sound".play()
	
# Interaction #
var interaction_priority = 1
var interaction_possible = false
func interact(): toggle()
func interaction_enabled(): $"Interact Label".visible = true
func interaction_disabled(): $"Interact Label".visible = false