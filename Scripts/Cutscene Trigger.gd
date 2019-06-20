extends Area2D

export(NodePath) var cutsceneLight;
export(NodePath) var cutsceneAudio;

var player : Player;
var cutsceneState = -1;

func _ready():
	player = $"/root/Root/Player";

func _process(delta):
	if cutsceneState >= 0 and player.input.y == 2: player.input.y = 1;
func _on_Cutscene_Trigger_body_entered(body):
	if body.is_in_group("Player"):
		cutsceneState += 1;
		match cutsceneState:
			0:
				player.isCutsceneRunning = true;
				get_node(cutsceneLight).get_node("./Animation").play("Fade");
				get_node(cutsceneAudio).playing = true;
			1:
				player.input.y = 2;
			2:
				player.input.y = 0;
				player.isCutsceneRunning = false;
				player.get_node("./Camera").current = true;
	pass

#Hey. Don't forget to add particles when the player jumps and 
#fix the goddamn music