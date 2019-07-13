extends VBoxContainer

const MAXIMUM_NOTIFICATIONS = 5
const SIZE_PER_CHARACTER = 18

export(PackedScene) var notification_scene

var current_notifications = []

func _ready(): NotificationSystem.connect("on_notify", self, "notify")

func _process(delta):
	for notif in current_notifications:
		if not is_instance_valid(notif):
			current_notifications.erase(notif)
	
func notify(message, duration = 2, icon = null):
	var new_not = notification_scene.instance()
	add_child(new_not)
	if icon: new_not.rect_min_size.x += 48
	new_not.rect_min_size.x += message.length() * SIZE_PER_CHARACTER
	new_not.initialize(message, duration, icon)
	current_notifications.push_back(new_not)
	if current_notifications.size() > MAXIMUM_NOTIFICATIONS:
		if not current_notifications.front().is_queued_for_deletion(): current_notifications.front().destroy()