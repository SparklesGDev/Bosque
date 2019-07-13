extends Node2D
var t = 0;

const WINDOW_SIZE : Vector2 = Vector2(1280, 720);
const CUTSCENE_SPEED = 0.35;

export(String, FILE, "*.tscn") var game_scene_path
export(String, FILE, "*.tscn") var menu_scene_path

func _ready():
	OS.window_size = WINDOW_SIZE;
	get_viewport().set_size_override(true, WINDOW_SIZE);
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, WINDOW_SIZE);
	OS.window_fullscreen = false;

func _process(delta):
#	OS.window_position = OS.get_screen_size() - get_viewport().get_size / 2;
	if Input.is_action_just_pressed("fullscreen_toggle") and Input.is_key_pressed(KEY_ALT):
		OS.window_fullscreen = !OS.window_fullscreen;

func reload_scene(): $"/root/Root".reload_scene()

func go_to_main_menu():
	get_tree().paused = false
	SaveHandler.save_data()
	get_tree().change_scene(menu_scene_path)
func go_to_game():
	get_tree().paused = false
	get_tree().change_scene(game_scene_path)