extends CanvasLayer

signal on_reset()
func reset(): emit_signal("on_reset")