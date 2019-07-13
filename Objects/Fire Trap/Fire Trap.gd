extends StaticBody2D

export(float) var damage
export(float) var knockback = 100

func _ready(): activate_trap()

func activate_trap():
	$"Activation Timer".start()

func _on_Activation_Timer_timeout():
	$Fire/Particles2D.emitting = true
	$Fire/Light2D.enabled = true
	$Fire.monitoring = true
	$"Deactivation Timer".start()

func _on_Deactivation_Timer_timeout():
	$Fire/Particles2D.emitting = false
	$Fire/Light2D.enabled = false
	$Fire.monitoring = false
	$"Activation Timer".start()

func _on_Fire_body_entered(body):
	if body.is_in_group("Player"):
		var rand_dir = sign(body.global_position.x - global_position.x)
		body.entity.hurt(AttackData.new(int(damage), self, Vector2.RIGHT * rand_dir * knockback))