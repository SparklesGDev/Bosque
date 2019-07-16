extends KinematicBody2D

const gravity = 20;

export(float) var movement_speed = 2;
export(float) var flashing
export(float) var knockback = 100

var time = 0;
var direction = 1;
var velocity = Vector2();

var entity : Entity
var sprite_material : ShaderMaterial;
var player_inside_area

func _ready():
	sprite_material = $"./Sprite".material;
	entity = Entity.get_from_node(self)

func _process(delta):
	render(delta);
	process_movement(delta)
	process_damage(delta)
	process_attacks(delta)
	pass

func render(delta):
	time += delta;
	sprite_material.set_shader_param("Stripe_Count", (abs(sin(time)) + 1) / 2);
	sprite_material.set_shader_param("invincible", entity.attackers.size() > 0)
	sprite_material.set_shader_param("flash_amount", flashing)

func process_movement(delta):
	var moveY = gravity + velocity.y;
	var move_x = direction * movement_speed if not entity.is_hurt else 0
	velocity = move_and_slide(Vector2(move_x, moveY));

func process_damage(delta):
	if entity.is_hurt: move_and_slide(entity.last_attack.direction * entity.hurtTime / entity.hurtDuration);

func process_attacks(delta):
	if player_inside_area == null: return
	var offset = player_inside_area.position - position;
	offset.x = sign(offset.x) if offset.x != 0 else 1.0;
	offset.y = sign(offset.y) if offset.y != 0 else 1.0;
	offset *= knockback
		
	player_inside_area.entity.hurt(AttackData.new(1, self, offset))

func on_hurt(attack_data, health):
	$"Hurt Sound".pitch_scale = rand_range(0.95, 1.05)
	$"Hurt Sound".play()
	$AnimationPlayer.play("Hurt")

func on_death(attack_data):
	var hurt_sound = $"Hurt Sound"
	hurt_sound.pitch_scale = rand_range(0.6, 0.65)
	hurt_sound.bus = "Death Sounds"
	hurt_sound.play()
	remove_child(hurt_sound)
	get_parent().add_child(hurt_sound)
	hurt_sound.global_position = global_position
	hurt_sound.get_node("Death Particles").emitting = true
#	hurt_sound.active = true
	queue_free()

func _on_Turn_Area_body_entered(body):
	if body.is_in_group("World"):
		direction *= -1;
		$"Turn Area".position.x *= -1;

func _on_Hurt_Area_body_entered(body):
	if not body: return
	if body.is_in_group("Player"): player_inside_area = body as Player
	if body.is_in_group("Enemy"): add_collision_exception_with(body)
	
func _on_Hurt_Area_body_exited(body):
	if body and body.is_in_group("Player"): player_inside_area = null