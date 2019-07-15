extends KinematicBody2D

const GRAVITY = 30

var velocity = Vector2()
var item : InventoryItem
var stack_size = 1

func initialize(item, stack_size = 1):
	self.item = item
	self.stack_size = stack_size
	$Sprite.texture = item.icon
	refresh()
	
func _ready(): interaction_disabled()

func _process(delta):
	velocity = move_and_slide(velocity + Vector2.DOWN * GRAVITY)
	if get_slide_count() > 0 and not velocity == Vector2(): velocity = Vector2()
#	if player and Input.is_action_just_pressed("interact"): pick_up()

func refresh():
	var pickup_text = "{0} {1}s".format([stack_size, item.name]) if item.has_flag(InventoryItem.CONSUMABLE) and stack_size > 1 else item.name
	$"Pick-up Label".text = "Pick %s" % pickup_text

func pick_up():
	var amount_added = InventorySystem.add_item(item, stack_size)
	
	# if nothing was added and isn't equipment (as they've max. 1 amount), then inventory's full
	if amount_added == 0 and not item.has_flag(InventoryItem.EQUIPPABLE):
		NotificationSystem.notify("Inventory Full", preload("res://Textures/error.png"), 2)
		start_interaction_delay()
	else: # otherwise, at least part was added
		var added_all = amount_added >= stack_size or item.has_flag(InventoryItem.EQUIPPABLE)
		var pickup_sound = $"Pickup Sound"
		if added_all:
			remove_child(pickup_sound)
			get_parent().add_child(pickup_sound)
		pickup_sound.play()
		pickup_sound.active = added_all
		
		var count_text = ("%sx " % amount_added) if not item.has_flag(InventoryItem.EQUIPPABLE) else ""
		var full_inventory_text = "(Inventory Full)" if not added_all else ""
		NotificationSystem.notify("Picked up {0}{1}{2}".format([count_text, item.name, full_inventory_text]), item.icon, 2)
		
		if added_all: queue_free()
		else:
			stack_size -= amount_added
			start_interaction_delay()
			refresh()

func start_interaction_delay():
	$"Interaction Area".interaction_possible = false
	$Timer.start()
	
func interact(): pick_up()
func interaction_enabled(): $"Pick-up Label".visible = true
func interaction_disabled(): $"Pick-up Label".visible = false
	
func _on_body_entered(body): if not body.is_in_group("World"): add_collision_exception_with(body)

func _on_body_exited(body): pass # if body == player: player = null

func _on_Timer_timeout():
	$"Interaction Area".interaction_possible = true