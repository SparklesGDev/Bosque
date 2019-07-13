extends Control

func update_visibility(state): visible = not state

func on_death(attack_data):
	update_visibility(true)