extends Node

# warning-ignore:unused_signal
signal checkpoint_reached(_checkpoint, aeroJunker)
# warning-ignore:unused_signal
signal finish_line_reached(_checkpoint, aeroJunker)
signal positions_updated(positions)

var positions = []
var timer


func _ready():
	timer = Timer.new()
	timer.set_wait_time(0.2)
	timer.set_one_shot(false)
	timer.connect("timeout", self, "calculate_positions")
	add_child(timer)
	timer.start()


func _process(delta):
	pass


func calculate_positions():
	positions.sort_custom(self, "sort_positions")
	emit_signal("positions_updated", positions)


static func sort_positions(a, b):
	if total_checkpoint_index(a) > total_checkpoint_index(b):
		return true
	elif (total_checkpoint_index(a) == total_checkpoint_index(b)) and (a.distance_to_next_checkpoint < b.distance_to_next_checkpoint):
		return true
	return false


static func total_checkpoint_index(aerojunker):
	return aerojunker.nextCheckpointIndex + ((aerojunker.currentLap - 1) * 9) #replace "9" w/ variable for total number of checkpoints
