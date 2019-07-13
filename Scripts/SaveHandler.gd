extends Node

const SAVE_FILE_NAME = "save{0}"

var current_save = 0

func load_json(save_file):
	var save_path = "user://saves/" + SAVE_FILE_NAME.format([current_save])
	if not save_file.file_exists(save_path): return null # doesn't load if there's no file
	save_file.open(save_path, File.READ)
	return parse_json(save_file.get_as_text())
	
func load_data():
	var save_file = File.new() as File
	var data = load_json(save_file)
	if not data: data = {}
	
	var savable_nodes = get_tree().get_nodes_in_group("Savable")
	for node in savable_nodes:
		if weakref(node).is_queued_for_deletion(): continue
		var key = node.save_key
		node.call("load_data", data[key] if data.has(key) else null)
	
	save_file.close()

func save_data():
	Directory.new().make_dir("user://saves/")
	var save_file = File.new() as File
	var data = load_json(save_file)
	if not data: data = {}
	save_file.open("user://saves/" + SAVE_FILE_NAME.format([current_save]), File.WRITE)
	
	var savable_nodes = get_tree().get_nodes_in_group("Savable")
	for node in savable_nodes:
		if node.is_queued_for_deletion(): continue
		data[node.save_key] = node.call("save_data")
	
	save_file.store_string(to_json(data))
	save_file.close()