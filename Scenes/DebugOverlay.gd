extends CanvasLayer

onready var draw = $DebugDraw3D

func _input(event):
	if event.is_action_pressed("debug"):
		for n in get_children():
			n.visible = not n.visible
