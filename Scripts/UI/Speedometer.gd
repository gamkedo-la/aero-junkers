extends Control

var stages = []
var top_speed_val = 1000
var full_bar = 0
var cur_bar_idx = 0
var test_val = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var tot_child = get_child_count()
	_initialize()
	
	if tot_child > 0:
		full_bar = top_speed_val / tot_child
		for child in get_children():
			if child is TextureProgress:
				stages.append(child)
				child.value = 0
				child.max_value = full_bar
	
	
func _initialize() -> void:
	if not AeroSingleton.is_connected("aero_speed_changed", self, "update_speed"):
		assert(AeroSingleton.connect("aero_speed_changed", self, "update_speed") == OK)
	if not AeroSingleton.is_connected("aero_max_speed_changed", self, "update_top_speed"):
		assert(AeroSingleton.connect("aero_max_speed_changed", self, "update_top_speed") == OK)

#func _process(delta) -> void:
#	test_val += 1
#	update_speed(test_val)
#	if test_val > top_speed_val + 100:
#		test_val = 0



func update_speed(val) -> void:
	for stage in stages:
		if val > full_bar:
			stage.value = full_bar
			val -= full_bar
		else:
			stage.value = val
			val = 0


func update_top_speed(val) -> void:
	top_speed_val = val
	full_bar = top_speed_val / stages.size()
	for stage in stages:
		stage.max_value = full_bar
	
