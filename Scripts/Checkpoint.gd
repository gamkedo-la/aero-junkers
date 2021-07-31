class_name Checkpoint
extends Area

func _ready():
	if not self.is_connected("body_entered", self, "_checkpoint_entered"):
		assert(self.connect("body_entered", self, "_checkpoint_entered") == OK)


func _checkpoint_entered(_body: Node) -> void:
	CheckpointSingleton.emit_signal("checkpoint_reached")
