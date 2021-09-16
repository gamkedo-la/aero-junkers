extends Node

signal race_start
signal return_to_menu
signal changing_scene

var current_scene = null
var debug_mode = false
var current_level = 0
const level_list = ["res://Scenes/Tracks/canyon_track.tscn",
					"res://Scenes/Tracks/tundra_track.tscn",
					"res://Scenes/Tracks/canyon_night_track.tscn"]

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func goto_scene(path):
	# Defer the load until the current scene is done executing code
	print("Getting to goto_scene...")
	emit_signal("changing_scene")
	call_deferred("_deferred_goto_scene", path)

# A function to simplify reparenting nodes, a function that will likely happen a lot as we design things "Modularly"
func reparent(child: Node, new_parent: Node):
	if child:
		var old_parent = child.get_parent()
		old_parent.remove_child(child)
		new_parent.add_child(child)
	else:
		print_debug("Global.gd: Attempt to reparent child node failed due to child being null.")
		
func pause_game(pause: bool):
	get_tree().paused = pause
	

func _deferred_goto_scene(path):
	
	current_scene.free()
	
	#print_debug("Loading level...", path)
	var s = load(path)
	
	current_scene = s.instance()
	
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene(current_scene)
