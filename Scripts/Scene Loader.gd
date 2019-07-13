extends Node2D

signal on_scene_changed(new_scene)

export(PackedScene) var default_scene

var current_scene
var current_scene_node

onready var player = $Player

func _ready(): load_scene(default_scene, false)

func load_scene(scene, save_before_loading = true):
	if save_before_loading: SaveHandler.save_data()
	ShortcutSystem.clear_shortcuts()
	ShortcutSystem.unlocked_shortcuts = []
	emit_signal("on_scene_changed", scene)
	
	if current_scene_node:
		current_scene_node.remove_child(player)
		add_child(player)
		current_scene_node.queue_free()
		var savable_nodes = get_tree().get_nodes_in_group("Savable")
		for node in savable_nodes:
			if node.find_parent(current_scene_node.name):
				node.remove_from_group("Savable")
#		print("	Queued: %s" % current_scene_node.get_child(0).is_queued_for_deletion())
	current_scene_node = scene.instance()
	add_child(current_scene_node)
	
	remove_child(player)
	current_scene_node.add_child(player)
	player.global_position = current_scene_node.get_node("Player Position").global_position
	current_scene_node.move_child(player, current_scene_node.get_node("Player Position").get_index())
	
	current_scene = scene
	SaveHandler.load_data()

func reload_scene():
	load_scene(current_scene)
	player.initialize()
	$Interface.reset()