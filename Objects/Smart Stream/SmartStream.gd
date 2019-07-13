extends AudioStreamPlayer2D

export(bool) var active = true

func on_stream_finished():
	if active: queue_free()