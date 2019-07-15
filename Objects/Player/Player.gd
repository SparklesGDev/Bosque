extends KinematicBody2D
class_name Player

const jumpThreshold = 0.05;
const gravity = 20;

export(float) var movementSpeed = 100;
export(float) var acceleration = 0.2; # how fast the character gets to full speed
export(float) var deceleration = 0.2; # how fast the character stops when no input is given
export(float) var jumpHeight = 400; # how high the character should jump (at the most)
export(float) var smallJumpFactor = 10; # how high the character should jump (at the most)
export(float) var fastFallFactor = 10; # how high the character should jump (at the most)
export(Vector2) var knockback = Vector2(100, 100); # for how many seconds the character will be knocked back when hurt
export(PackedScene) var dustFX : PackedScene; # the scene to instantiate when touching the ground

# ANIMATION-CONTROLLED FIELDS
export(float) var flashing
export(bool) var play_footstep

# MOVEMENT AND INPUT
var velocity = Vector2(); # stores last velocity; used by gravity
var movement : Vector2; # current movement
var input; # current input

# HORIZONTAL MOVEMENT
var currAcceleration = 0; # the current acceleration; drops to zero unless there's any input
var direction = 1; # last value for moveX; never zero

# JUMPING
var jumping = false;
var onGround = false; # true when there's an object below
var smallJumpTriggered = false; # true when the jump button was released while jumping

# ATTACKING
var attack_requested # if you requested an attack
var attacking # if you're attacking this frame
var attack_damage # set every time you attack from your stats

var isCutsceneRunning;
var is_ui_open # whether or not there's any UI opened at the moment
var was_hurt = false
var start_position_set = false

onready var entity : Entity = Entity.get_from_node(self)

func _ready():
	InventorySystem.player = self
	$Stats.connect("on_stat_changed", InventorySystem.get_node("."), "on_stat_changed")
	initialize()
	call_deferred("_recalc_capacity")

func _recalc_capacity(): $Stats.recalculate_stat("food_capacity")

func initialize():
	entity.initialize()
	$"Interaction Area".is_dead = false
	$"Hurt Sound".bus = "Master"
	update_stat("damage")
	update_stat("maximum_health")
	update_stat("movement_speed")

func _process(delta):
	var wasOnGround = onGround;
	if Input.is_key_pressed(KEY_O): entity.hurt(AttackData.new(999, self, Vector2()))
	
	process_input();
	process_damage(delta);
	process_attacks(delta)
	process_horizontal();
	process_vertical();
	
	velocity = move_and_slide(Vector2(abs(direction) * movementSpeed * currAcceleration, movement.y));
	process_collisions();
	process_animations(delta, wasOnGround, was_hurt);
	
	was_hurt = entity.is_hurt;

func process_input():
	if isCutsceneRunning: return
	input = Vector2();
	if is_ui_open: return
	if Input.is_action_pressed("ui_left"): input.x += -1
	if Input.is_action_pressed("ui_right"): input.x += 1;
	if Input.is_action_just_pressed("ui_up"): input.y = 2;
	elif Input.is_action_pressed("ui_up"): input.y = 1;
	if Input.is_action_just_pressed("attack") and not entity.is_hurt: attack_requested = true

func process_damage(delta):
	if entity.is_hurt and (entity.alive or not onGround): move_and_slide(entity.lastAttack.direction * entity.hurtTime / entity.hurtDuration);

func process_attacks(delta):
	if attack_requested:
		if not attacking: attack()
		else: attack_requested = false

func attack():
	attacking = true
	$"Attack Sound".pitch_scale = rand_range(0.85, 1.05)
	$"Attack Sound".play()

func process_horizontal():
	if isCutsceneRunning:
		currAcceleration = GameHandler.CUTSCENE_SPEED;
		direction = 1;
	elif entity.is_hurt or (onGround and attacking): currAcceleration = 0; # being knocked back by a monster
	else:
		movement.x = input.x;
		if movement.x != 0: direction = movement.x;
		currAcceleration = lerp(currAcceleration, 0, deceleration) if movement.x == 0 else clamp(currAcceleration + movement.x * acceleration, -1, 1);

func process_vertical():
	jumping = jumping and not onGround;
	#$"/root/Root/Canvas/DebugText".text = String(jumping);
	
	if entity.is_hurt or attacking: movement.y += gravity;
	else:
		var wasJumping = jumping # used to determine if smallJumpTriggered should be set to false
		if onGround and input.y == 2: jump(); # jumps if on ground
		else: movement.y = gravity + velocity.y; # otherwise moveY will be gravity
		if wasJumping:
			if input.y < 1: smallJumpTriggered = true;
			if smallJumpTriggered: movement.y += smallJumpFactor;
			if velocity.y > 0: movement.y += fastFallFactor;
		else: smallJumpTriggered = false;
	
func jump():
	movement.y = -jumpHeight;
	jumping = true;

func process_collisions():
	var wasOnGround = onGround;
	onGround = false;
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i);
		if collision:
			var angle = -rad2deg(collision.normal.angle());
			if not onGround: onGround = angle > 85 and angle < 95;
	pass

func on_hurt(attack_data : AttackData, health):
	#health_bar.value = entity.health
	movement = Vector2()
	velocity = Vector2()
	$"Hurt Sound".pitch_scale = rand_range(0.85, 1.05)
	$"Hurt Sound".play()
	# This will be more useful when the code that hurts the player is *outside* the player
	pass

func on_death(attack_data : AttackData):
	var hurt_sound = $"Hurt Sound"
	hurt_sound.pitch_scale = rand_range(0.6, 0.65)
	hurt_sound.bus = "Death Sounds"
	hurt_sound.play()
	hurt_sound.global_position = global_position
	
	$"Interaction Area".on_death()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy is PhysicsBody2D: add_collision_exception_with(enemy)
	pass

func process_animations(delta, wasOnGround, was_hurt):
	var anim = $AnimationPlayer;
	var current = anim.current_animation
	if entity.is_hurt:
		if entity.alive:
			if not was_hurt: anim.play("Hurt", -1, 1 / entity.hurtDuration)
		else:
			if current != "Die":
				if not was_hurt: anim.play("Die")
				elif current != "Death Loop": anim.play("Death Loop")
	elif attack_requested: anim.play("Attack" + String(round(rand_range(1, 2))))
	elif current != "Hurt" and not "Attack" in current:
		attacking = false
		if jumping and wasOnGround: anim.play("Jump");
		elif current != "Squish":
			if not wasOnGround and onGround: # ALSO instantiates dust particles when landing on ground
				anim.play("Squish");
				var newParticle = dustFX.instance();
				newParticle.position = $"Dust Position".global_position;
				get_parent().add_child(newParticle);
			elif current != "Jump":
				if not onGround: anim.play("Falling")
				elif abs(movement.x) > 0.1: anim.play("Walk");
				else: anim.play("Idle");
	
	if not current in ['Hurt', 'Die']: flashing = 0
		
	apply_scale(Vector2(sign(scale.y) * direction, 1)) # flips you horizontally when moving to the left
	
	var sprite_material = $Sprite.material as ShaderMaterial
	sprite_material.set_shader_param("flash_amount", flashing) # flashes the player based on the animated value "flashing"
	
	if play_footstep:
		if onGround: $"Footstep Sound".play()
		play_footstep = false

func update_stat(stat, new_value = null):
	if not new_value: new_value = $Stats.stats[stat]
	match stat:
		"damage":
			attack_damage = int(new_value)
		"maximum_health":
			var old_max = entity.maximum_health
			entity.maximum_health = int(new_value)
			entity.heal(int(new_value) - old_max, self)
		"movement_speed":
			movementSpeed = new_value

func set_start_position(position = null):
	if start_position_set: return
	if position: global_position = position
	else: global_position = stored_position
	start_position_set = true
	
# Saving #
var save_key = "player"
var stored_position

func load_data(data):
	if not data: stored_position = Vector2(-1352, 296) # DEFAULT POSITION
	else: stored_position = Vector2(data.position_x, data.position_y)

func save_data(): return { "position_x": global_position.x, "position_y": global_position.y }

# Signals #
func _on_Sword_Area_body_entered(body):
	if entity.is_hurt or not attacking or body == null or body.is_in_group("Player"): return
	var body_entity = Entity.get_from_node(body)
	if body_entity:
		var offset = (body.position - position).normalized()
		body_entity.hurt(AttackData.new(attack_damage, self, offset * knockback))

func _on_Inventory_Screen_state_changed(state):
	get_tree().paused = state
	is_ui_open = state