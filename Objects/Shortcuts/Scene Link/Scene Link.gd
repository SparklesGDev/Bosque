extends Area2D

export(String) var link_name
export(String, FILE, "*.tscn") var target_scene

onready var packed_target_scene = load(target_scene)

func _ready():
	$"Interact Label".rect_scale = Vector2.ONE / scale
	interaction_disabled()

func enter():
	var enter_sound = $"Enter Sound"
	remove_child(enter_sound)
	$"/root/Root".add_child(enter_sound)
	enter_sound.play()
	
	$"/root/Root".load_scene(packed_target_scene)
	for link in get_tree().get_nodes_in_group("Scene Link"):
		if not link == self and link.link_name == link_name:
			var player = get_tree().get_nodes_in_group("Player")[0]
			player.set_start_position(link.global_position)
		
var interaction_priority = 1
var interaction_possible = true
func interact(): enter()
func interaction_enabled(): $"Interact Label".visible = true
func interaction_disabled(): $"Interact Label".visible = false