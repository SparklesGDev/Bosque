extends Area2D

signal cutscene_state_changed(state)

var player : Player;
var cutscene_state = -1;
var cutscene_played

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	if cutscene_state >= 0 and player.input.y == 2: player.input.y = 1;

func _on_Cutscene_Trigger_body_entered(body):
	if body.is_in_group("Player") and not cutscene_played:
		cutscene_state += 1;
		match cutscene_state:
			0:
				player.isCutsceneRunning = true
				$"../Cutscene Light".get_node("./Animation").play("Fade")
				$"../Cutscene Music".playing = true
			1:
				player.input.y = 2;
			2:
				player.input.y = 0;
				player.isCutsceneRunning = false;
				cutscene_played = true
		emit_signal("cutscene_state_changed", cutscene_state)

var save_key = "cutscene"
func load_data(data):
	if not data: return
	cutscene_played = data.played
	if cutscene_played: $"../Cutscene Light".visible = false
func save_data(): return { "played": cutscene_played }