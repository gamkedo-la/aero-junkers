extends RayCast

func _physics_process(delta):
	$GroundIndicator.global_transform.origin = get_collision_point()


func get_distance_to_collision(_delta):
	var origin = global_transform.origin
	var collision_point = get_collision_point()
	var distance = origin.distance_to(collision_point)
	return distance
