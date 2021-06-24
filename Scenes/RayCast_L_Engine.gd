extends RayCast

func get_distance_to_collision(_delta):
	var origin = global_transform.origin
	var collision_point = get_collision_point()
	var distance = origin.distance_to(collision_point)
	return distance
