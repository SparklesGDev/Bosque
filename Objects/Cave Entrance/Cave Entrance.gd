extends Area2D

export(String, FILE, "*.tscn") var target_scene

onready var packed_target_scene = load(target_scene)

func _ready():
	$"Interact Label".rect_scale = Vector2.ONE / scale
	interaction_disabled()

func enter(): $"/root/Root".load_scene(packed_target_scene)

var interaction_priority = 1
var interaction_possible = true
func interact(): enter()
func interaction_enabled(): $"Interact Label".visible = true
func interaction_disabled(): $"Interact Label".visible = false