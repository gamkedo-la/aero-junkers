extends KinematicBody

var speed = 50
var velocity = Vector3.ZERO

var l_engine_height = 0

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)
	pass

func _physics_process(delta):
	velocity = Vector3.ZERO
	get_input(delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	l_engine_height = $MeshInstance_L_Engine/RayCast_L_Engine.get_distance_to_collision(delta)
	
func _process(_delta):
#	print(l_engine_height)
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

func moveForward(_delta):
	if $MeshInstance_L_Engine/RayCast_L_Engine.is_colliding():
		velocity -= transform.basis.z * speed

func moveBackward(_delta):
	velocity += transform.basis.z * speed

func turnLeft(_delta):
	rotate_y(0.2)

func turnRight(_delta):
	rotate_y(-0.2)

func _player_reached_checkpoint():
	print("Player Reached Checkpoint")
