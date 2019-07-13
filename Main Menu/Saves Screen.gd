extends Control

export(PackedScene) var slot_scene
export(NodePath) var slot_container

var slots = []
var last_save_id = 0

func _ready():
	generate_ui()

func generate_ui():
	var save_directory = Directory.new() as Directory
	save_directory.open("user://saves/")
	save_directory.list_dir_begin(true)
	
	var slot_container_node = get_node(slot_container)
	
	while true:
		var file = save_directory.get_next()
		if file == "": break # file is empty when it's the end of the directory
		
		var new_slot = slot_scene.instance()
		new_slot.initialize(file, last_save_id)
		new_slot.connect("on_save_chosen", self, "choose_save")
		new_slot.connect("on_save_deleted", self, "on_save_deleted")
		slot_container_node.add_child(new_slot)
		slot_container_node.move_child(new_slot, last_save_id) # adjusts the id of this child because of the "New Save" button
		slots.push_back(new_slot)
		last_save_id += 1
	
	slot_container_node.get_child(last_save_id).initialize(last_save_id)

func choose_save(save_id):
	SaveHandler.current_save = save_id
	GameHandler.go_to_game()

func on_save_deleted(save_id):
	slots.remove(save_id)

	var save_directory = Directory.new() as Directory
	save_directory.open("user://saves/")
	save_directory.list_dir_begin(true)
	
	if last_save_id > 0:
		for _i in range(save_id): save_directory.get_next()
		for id in range(save_id, last_save_id):
			var file_name = save_directory.get_next()
			if file_name == "": break # file is empty when it's the end of the directory
			slots[id].initialize(file_name, id)
			save_directory.rename(file_name, SaveHandler.SAVE_FILE_NAME.format([id]))

	last_save_id -= 1
	get_node(slot_container).get_child(last_save_id + 1).initialize(last_save_id)

func show_screen():
	if $Tween.is_active(): return
	$Tween.interpolate_method(self, "_change_pos_x", get_viewport_rect().size.x, 0, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func hide_screen():
	if $Tween.is_active(): return
	$Tween.interpolate_method(self, "_change_pos_x", 0, get_viewport_rect().size.x, 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween.start()
	
func _change_pos_x(value): rect_position.x = value