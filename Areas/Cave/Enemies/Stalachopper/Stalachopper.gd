extends KinematicBody2D

const GRAVITY = 900

onready var states_map = {
	"idle_start": $States/IdleStatic,
	"fall": $States/Fall,
	"idle": $States/Idle,
	"jump": $States/Jump
}

var current_state
var flashing = 0

var entity

var target
var is_upside_down = false

func _ready():
	entity = Entity.get_from_node(self)
	change_state("idle_start")
	for enemy in get_tree().get_nodes_in_group("Enemy"): add_collision_exception_with(enemy)

func _physics_process(delta):
	if entity.is_hurt: move_and_slide(entity.last_attack.direction * entity.hurtTime / entity.hurtDuration)
	
	var new_state = current_state.update(delta)
	if new_state: change_state(new_state)
	$Sprite.material.set_shader_param("flash_amount", flashing)

func change_state(state_name):
	if current_state: current_state.exit()
	var state = states_map[state_name]
	state.start(self)
	current_state = state

func on_hurt(attack_data, new_health):
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Hurt")
	$"Hurt Sound".pitch_scale = rand_range(0.95, 1.05)
	$"Hurt Sound".play()
	pass
	
func on_death(attack_data):
	var hurt_sound = $"Hurt Sound"
	hurt_sound.pitch_scale = rand_range(0.6, 0.65)
	hurt_sound.bus = "Death Sounds"
	hurt_sound.play()
	remove_child(hurt_sound)
	get_parent().add_child(hurt_sound)
	hurt_sound.global_position = global_position
	hurt_sound.get_node("Death Particles").emitting = true
	queue_free()

func on_body_detected(body): if body.is_in_group("Player"): target = body
func on_body_lost(body): if target == body: target = null