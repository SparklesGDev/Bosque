extends Area2D

var interactives = []
var current_interactive
var is_dead

func _process(delta):
	if is_dead: return
	
	var closest = null
	
	for interactive in interactives:
		if interactive.interaction_possible and _can_replace(closest, interactive):
			if closest: closest.call("interaction_disabled") # the old closest will be disabled
			closest = interactive # the new closest will stay there until the end or someone is closer
		else: interactive.call("interaction_disabled") # the old closest will be disabled
	
	if closest and not current_interactive == closest: closest.call("interaction_enabled")
	current_interactive = closest
	
	if Input.is_action_just_pressed("interact") and current_interactive: current_interactive.call("interact")

func _can_replace(other_interactive, interactive): return not other_interactive or interactive == other_interactive or interactive.interaction_priority > other_interactive.interaction_priority or (_get_dst(interactive) < _get_dst(other_interactive) and interactive.interaction_priority == other_interactive.interaction_priority)
# Above: only if the interactive has a higher priority than the other_interactive or they have the same priority but the interactive is closer, returns true.
func _get_dst(interactive): return abs(interactive.global_position.x - global_position.x)

func on_area_entered(area): if area.is_in_group("Interactive"): interactives.push_back(area)
func on_area_exited(area):
	if interactives.has(area):
		interactives.erase(area)
		area.call("interaction_disabled")

func on_death():
	interactives = []
	if current_interactive: current_interactive.call("interaction_disabled")
	is_dead = true