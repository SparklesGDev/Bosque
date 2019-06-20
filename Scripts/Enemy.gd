extends KinematicBody2D

const turnThreshold = 0.01;
const gravity = 20;

export(float) var movementSpeed = 2;

var target : Material;

var time = 0;
var direction = 1;
var velocity = Vector2();

func _ready():
	target = $"./Sprite".material;
	
func _process(delta):
	render(delta);
	var moveY = gravity + velocity.y;
	velocity = move_and_slide(Vector2(direction * movementSpeed, moveY));
	pass
	
func render(delta):
	time += delta;
	target.set_shader_param("Stripe_Count", (abs(sin(time)) + 1) / 2);

func _on_Turn_Area_body_entered(body):
	var bodyNode : Node = body as Node;
	if bodyNode != self:
		direction *= -1;
		$"Turn Area".position.x *= -1;
	pass
