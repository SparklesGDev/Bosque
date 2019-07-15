extends Button

signal on_save_chosen(save_id)
signal on_save_deleted(save_id)

var save_id
var file_name

func initialize(file, save_id):
	file_name = file
	self.save_id = save_id
	print(file_name + ": %s" % save_id)
	$Name.text = "Save #%s" % (save_id + 1)
	$VBoxContainer/Description.text = ""

func delete_save():
	print(file_name)
	var dir = Directory.new()
	dir.remove("user://saves/%s" % file_name)
	emit_signal("on_save_deleted", save_id)
	queue_free()
	
func _pressed(): emit_signal("on_save_chosen", save_id)