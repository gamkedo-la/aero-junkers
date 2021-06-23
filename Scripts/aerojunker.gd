extends KinematicBody

var speed = 50
var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity = Vector3.ZERO
	get_input(delta)
	velocity = move_and_slide(velocity, Vector3.UP)

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
	velocity -= transform.basis.z * speed

func moveBackward(_delta):
	velocity += transform.basis.z * speed

func turnLeft(_delta):
	rotate_y(0.2)

func turnRight(_delta):
	rotate_y(-0.2)

func _on_Checkpoint_body_entered(_body):
	print("Checkpoint Entered")
