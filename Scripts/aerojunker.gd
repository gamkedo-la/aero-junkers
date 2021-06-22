extends KinematicBody

var speed = 10
var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity = Vector3.ZERO
	get_input(delta)
		
func get_input(delta):
	if Input.is_action_pressed("turn_left"):
		turnLeft(delta)
	if Input.is_action_pressed("turn_right"):
		turnRight(delta)
	if Input.is_action_pressed("accelerate"):
		moveForward(delta)
	if Input.is_action_pressed("reverse"):
		moveBackward(delta)
		
func moveForward(_delta):
	#print("moveForward")
	translation += Vector3.FORWARD
	#velocity = Vector3.FORWARD.rotated(rotation) * speed
	#velocity = move_and_slide(velocity)
	
func moveBackward(_delta):
	#print("moveBackward")
	translation += Vector3.BACK
	
func turnLeft(_delta):
	#print("turnLeft")
	rotate_y(0.2)
	
func turnRight(_delta):
	#print("turnRight")
	rotate_y(-0.2)
