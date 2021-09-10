extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not CheckpointSingleton.is_connected("race_finished", self, "_on_Checkpoint_Singleton_race_finished"):
		assert(CheckpointSingleton.connect("race_finished", self, "_on_Checkpoint_Singleton_race_finished") == OK)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("left_click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()


func _on_Checkpoint_Singleton_race_finished():
	$AeroRacingSong.stop()
