extends Area2D

export(String, FILE, "*.tscn") var target_scene

onready var packed_target_scene = load(target_scene)

var entered

func on_entered():
	if entered: return
	$"/root/Root".load_scene(packed_target_scene)
	var player = get_tree().get_nodes_in_group("Player")[0]
	var player_positions = get_tree().get_nodes_in_group("Player Position")
	for pos in player_positions:
		if not pos.find_parent(get_parent().name):
			player.set_start_position(pos.global_position)
			break
	entered = true

func on_body_entered(body):
	if body.is_in_group("Player"): call_deferred("on_entered")