extends AudioStreamPlayer

func _ready():
	if not Global.is_connected("changing_scene", self, "_on_Global_changing_scene"):
		assert(Global.connect("changing_scene", self, "_on_Global_changing_scene") == OK)


func _on_Global_changing_scene():
	if self.playing:
		print_debug("stopping audio")
		self.stop()
