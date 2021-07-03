extends KinematicBody

var speed = 3000 #units/second
var altitude_adjust_speed = 30 #units/second
var velocity = Vector3.ZERO
var target_altitude = Vector3.UP * 3

var l_engine_height = 0

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)
	pass

func _physics_process(delta):
	velocity = Vector3.ZERO
	get_input(delta)
	moveToTargetAltitude(delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _process(_delta):
	pass

func get_input(delta):
	if Input.is_action_pressed("turn_left"):
		turnLeft(delta)
	if Input.is_action_pressed("turn_right"):
		turnRight(delta)
	if Input.is_action_pressed("accelerate"):
		moveForward(delta)
	if Input.is_action_pressed("reverse"):
		moveBackward(delta)

func moveForward(delta):
	velocity -= transform.basis.z * speed * delta
	
func moveBackward(delta):
	velocity += transform.basis.z * speed * delta
	
func turnLeft(_delta):
	rotate_y(0.2)

func turnRight(_delta):
	rotate_y(-0.2)
	
func moveToTargetAltitude(delta):
	var target_position_y = ($RayCast_L_Engine.get_collision_point() + target_altitude).y
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta * altitude_adjust_speed

func _player_reached_checkpoint():
	print("Player Reached Checkpoint")
