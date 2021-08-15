extends CanvasLayer

onready var draw = $DebugDraw3D

signal return_player_to_last_checkpoint()

func _input(event):
	if event.is_action_pressed("debug"):
		for n in get_children():
			n.visible = not n.visible


func _on_CheckpointReset_pressed():
	emit_signal("return_player_to_last_checkpoint")
