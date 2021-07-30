extends Node


signal aero_speed_changed(val)
signal aero_max_speed_changed(val)

var aero_speed: float = 0 setget set_aero_speed
var aero_max_speed: float = 165 setget set_aero_max_speed

func _ready():
	pass # Replace with function body.

func emit_signal_if_value_changed(signal_name, value, change_amount) -> void:
	if change_amount != 0:
		emit_signal(signal_name, value)

func set_aero_speed(val) -> void:
	var previous_val = aero_speed	
	aero_speed = clamp(val, 0, aero_max_speed)
	emit_signal_if_value_changed("aero_speed_changed", aero_speed, aero_speed - previous_val)

func set_aero_max_speed(val) -> void:
	var previous_val = aero_max_speed
	aero_max_speed = val
	emit_signal_if_value_changed("aero_max_speed_changed", aero_max_speed, aero_max_speed - previous_val)
