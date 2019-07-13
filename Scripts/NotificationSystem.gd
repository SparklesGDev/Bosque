extends Node

signal on_notify(message, icon, duration)

func notify(message, icon = null, duration = 2): emit_signal("on_notify", message, icon, duration)