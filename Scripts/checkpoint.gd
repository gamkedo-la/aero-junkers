class_name Checkpoint
extends Area

export var is_finish_line: bool = false

func _ready():
	if not self.is_connected("body_entered", self, "_checkpoint_entered"):
		assert(self.connect("body_entered", self, "_checkpoint_entered") == OK)


func _checkpoint_entered(_body: Node) -> void:
	if is_finish_line:
		print_debug("Finish Line emitting signal")
		CheckpointSingleton.emit_signal("finish_line_reached", self, _body)
	
	print_debug("Checkpoint emitting signal")
	CheckpointSingleton.emit_signal("checkpoint_reached", self, _body)
