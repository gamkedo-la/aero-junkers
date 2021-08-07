extends Control

class Vector:
	var object
	var property
	var scale
	var width
	var color
	
	func _init(_object, _property, _scale, _width, _color):
		object = _object
		property = _property
		scale = _scale
		width = _width
		color = _color
	
	func draw(node, camera):
		var start = camera.unproject_position(object.global_transform.origin)
		var end = camera.unproject_position(object.global_transform.origin + object.get(property) * scale)
		node.draw_line(start, end, color, width)
		node.draw_triangle(end, start.direction_to(end), width*2, color)


var vectors = []


func _process(_delta):
	if not visible:
		return
	update()


func _draw():
	var camera = get_viewport().get_camera()
	for vector in vectors:
		vector.draw(self, camera)


func add_vector(object, property, scale, width, color):
	vectors.append(Vector.new(object,property,scale,width, color))


func draw_triangle(pos, dir, size, color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))
