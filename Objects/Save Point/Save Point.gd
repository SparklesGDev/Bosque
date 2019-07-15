extends Area2D

export(String) var save_point_name
export(float) var flashing = 0 # Animation-driven field

func _ready():
	$"Interact Label".rect_scale = Vector2.ONE / scale
	interaction_disabled()

func _process(delta):
	$Sprite.material.set_shader_param("flash_amount", flashing)
	if not $AnimationPlayer.current_animation == "Save": interaction_possible = true
	
func save():
	var player = get_tree().get_nodes_in_group("Player")[0]
	if player:
		player.entity.heal(999, self)
	$AnimationPlayer.play("Save")
	NotificationSystem.notify("Game saved")
	$"Save Sound".play()
	SaveHandler.save_data()

var interaction_priority = 1
var interaction_possible = true
func interact():
	if not $AnimationPlayer.current_animation == "Save":
		save()
		interaction_possible = false
func interaction_enabled(): $"Interact Label".visible = true
func interaction_disabled(): $"Interact Label".visible = false