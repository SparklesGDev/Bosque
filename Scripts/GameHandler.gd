extends Node
var t = 0;

const WINDOW_SIZE : Vector2 = Vector2(1280, 720);
const CUTSCENE_SPEED = 0.35;
var viewport;

func _ready():
	viewport = get_viewport();
	viewport.set_size_override(true, Vector2(1024, 600));
	OS.window_size = WINDOW_SIZE;
	viewport.set_size_override(true, WINDOW_SIZE);
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, WINDOW_SIZE);
	OS.window_fullscreen = false;
	#get_node("/root").set_size_override(true, Vector2(300, 700));

func _process(delta):
#	OS.window_position = OS.get_screen_size() - get_node("/root").get_size / 2;
	if Input.is_key_pressed(KEY_5): viewport.set_size_override_stretch(true);
	if Input.is_key_pressed(KEY_6): viewport.set_size_override_stretch(false);
	if Input.is_key_pressed(KEY_7): viewport.set_size_override(true, Vector2(1024, 600));
	if Input.is_key_pressed(KEY_8): viewport.set_size_override(true, Vector2(1280, 720));
	if Input.is_key_pressed(KEY_9): viewport.set_size_override(true, Vector2(800, 600));
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen_toggle") and Input.is_key_pressed(KEY_ALT):
		OS.window_fullscreen = !OS.window_fullscreen;