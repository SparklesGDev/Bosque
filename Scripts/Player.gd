extends KinematicBody2D
class_name Player

const jumpThreshold = 0.05;

export(float) var movementSpeed = 100;
export(float) var acceleration = 0.2; # how fast the character gets to full speed
export(float) var deceleration = 0.2; # how fast the character stops when no input is given
export(float) var jumpHeight = 400; # how high the character should jump (at the most)
export(float) var smallJumpFactor = 10; # how high the character should jump (at the most)
export(float) var fastFallFactor = 10; # how high the character should jump (at the most)
export(float) var hurtTimeDuration = 0.3; # for how many seconds the character will be knocked back when hurt
export(float) var invincibilityDuration = 1; # for how many seconds the character will be knocked back when hurt
export(Vector2) var harmKnockback = Vector2.ONE; # for how many seconds the character will be knocked back when hurt
export(PackedScene) var dustFX : PackedScene; # the scene to instantiate when touching the ground

const gravity = 20;
var currAcceleration = 0; # the current acceleration; drops to zero unless there's any input
var direction = 1; # last value for moveX; never zero
var velocity = Vector2(); # stores last velocity; used by gravity
var jumping = false;
var onGround = false; # true when there's an object below
var smallJumpTriggered = false; # true when the jump button was released while jumping
var hurtTime = 0; # a short period of time where no movement is done
var hurtDirection = Vector2(); # the direction it should move the character when getting hurt
var attackers = Dictionary(); # a list with all enemies that attacked you
var wasHurt; # whether or not the character was hurt last frame
var isCutsceneRunning;
var movement : Vector2; # current movement
var input; # current input

func _process(delta):
	procces_input();
	var isHurt = proccess_hurt(delta) or (wasHurt and not onGround);
	procces_horizontal(isHurt);
	proccess_vertical(isHurt);
	
	wasHurt = isHurt;
	var wasOnGround = onGround;
	velocity = move_and_slide(Vector2(abs(direction) * movementSpeed * currAcceleration, movement.y));
	proccess_collisions();
	proccess_animations(delta, wasOnGround);

	pass

func procces_input():
	if isCutsceneRunning: return
	input = Vector2();
	if Input.is_action_pressed("ui_left"): input.x = -1
	elif Input.is_action_pressed("ui_right"): input.x = 1;
	if Input.is_action_just_pressed("ui_up"): input.y = 2;
	elif Input.is_action_pressed("ui_up"): input.y = 1;

func procces_horizontal(isHurt):
	if isCutsceneRunning:
		currAcceleration = GameHandler.CUTSCENE_SPEED;
		direction = 1;
	elif isHurt: currAcceleration = 0; # being knocked back by a monster
	else:
		movement.x = input.x;
		if movement.x != 0: direction = movement.x;
		currAcceleration = lerp(currAcceleration, 0, deceleration) if movement.x == 0 else clamp(currAcceleration + movement.x * acceleration, -1, 1);

func proccess_vertical(isHurt):
	jumping = jumping and not onGround;
	$"/root/Root/CanvasLayer/DebugText".text = String(jumping);

	if not isHurt and onGround and input.y == 2: jump(); # jumps if on ground
	else: movement.y = gravity + velocity.y; # otherwise moveY will be gravity

	if jumping and not isHurt:
		if input.y < 1: smallJumpTriggered = true;
		if smallJumpTriggered: movement.y += smallJumpFactor;
		if velocity.y > 0: movement.y += fastFallFactor;
	else: smallJumpTriggered = false;

func jump():
	movement.y = -jumpHeight;
	jumping = true;

func proccess_collisions():
	var wasOnGround = onGround;
	onGround = false;
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i);
		if collision:
			var angle = -rad2deg(collision.normal.angle());
			if not onGround: onGround = angle > 85 and angle < 95;

			var collisionBody = collision.collider as PhysicsBody2D;
			if collisionBody and collisionBody.is_in_group("Enemy") and not attackers.has(collisionBody):
				hurtTime = hurtTimeDuration;
				# -calculating hurtDirection- #
				var offset = position - collision.position;
				if offset.x == 0: offset.x = 1;
				print(offset.x);
				hurtDirection.x = sign(offset.x) * harmKnockback.x;
				hurtDirection.y = -harmKnockback.y;
				# -/- #
				attackers[collisionBody] = invincibilityDuration;
				break;
	pass

func proccess_animations(delta, wasOnGround):
	var anim = $AnimationPlayer;
	if not anim.current_animation == "Squish":
		if jumping and not onGround:
			if wasOnGround: anim.play("Jump");
		elif not wasOnGround and onGround: # INSTANTIATE dust particles when landing on ground
			var newParticle = dustFX.instance() as Sprite;
			newParticle.position = Vector2(position.x, position.y + $Sprite.get_rect().size.y / 2 * scale.y - newParticle.get_rect().size.y / 2);
			anim.play("Squish");
			get_parent().add_child(newParticle);
		elif abs(movement.x) > 0.1: anim.play("Walk");
		else: anim.play("Idle");
	$Sprite.flip_h = direction < 0;
	
	pass

func proccess_hurt(delta) -> bool:
	for i in attackers:
		attackers[i] -= delta;
		if attackers[i] <= 0:
			attackers.erase(i);

	if hurtTime > 0:
		move_and_slide(hurtDirection * hurtTime / hurtTimeDuration);
		hurtTime -= delta;
		return true;
	return false;