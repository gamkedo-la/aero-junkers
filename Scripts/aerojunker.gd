extends KinematicBody

var speed = 50
var altitude_adjust_speed = speed/3
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
	
	#Debug
	$RayCast_L_Engine/MeshInstance.global_transform.origin.y = $RayCast_L_Engine.get_collision_point().y
#	l_engine_height = $RayCast_L_Engine.get_distance_to_collision(delta)
	
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
	if Input.is_action_pressed("increase_altitude"):
		increaseAltitude(delta)
	if Input.is_action_pressed("decrease_altitude"):
		decreaseAltitude(delta)
		
func moveForward(_delta):
	velocity -= transform.basis.z * speed

func moveBackward(_delta):
	velocity += transform.basis.z * speed

func turnLeft(_delta):
	rotate_y(0.2)

func turnRight(_delta):
	rotate_y(-0.2)
	
func increaseAltitude(_delta):
	velocity += transform.basis.y * (speed/2)
	
func decreaseAltitude(_delta):
	velocity -= transform.basis.y * (speed/2)
	
func moveToTargetAltitude(delta):
	var target_position_y = ($RayCast_L_Engine.get_collision_point() + target_altitude).y
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta * altitude_adjust_speed

func _player_reached_checkpoint():
	print("Player Reached Checkpoint")
