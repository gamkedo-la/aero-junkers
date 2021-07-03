extends KinematicBody

var max_speed = 4000 #units/second
var altitude_adjust_speed = 5 #units/second
var acceleration = Vector3.ZERO
var acceleration_direction = 0
var velocity = Vector3.ZERO
var target_altitude = Vector3.UP * 3

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)

func _physics_process(delta):
	
	get_input(delta)
	apply_acceleration(delta)
	
	#change velocity from global to local orientation
	velocity = global_transform.basis.orthonormalized().xform(velocity)
	
	move_and_slide(velocity, Vector3.UP)
	moveToTargetAltitude(delta)

func get_input(delta):
	if Input.is_action_pressed("turn_left"):
		rotate_y(0.2)
	if Input.is_action_pressed("turn_right"):
		rotate_y(-0.2)
	if Input.is_action_pressed("accelerate"):
		acceleration_direction = -1
	if Input.is_action_pressed("reverse"):
		acceleration_direction = 1
	if Input.is_action_just_released("accelerate"):
		acceleration_direction = 0
	if Input.is_action_just_released("reverse"):
		acceleration_direction = 0
		
func apply_acceleration(delta):
	acceleration.z += ((max_speed * acceleration_direction) - acceleration.z) * delta
	velocity = acceleration * delta
	
func moveToTargetAltitude(delta):
	var target_position_y = ($RayCast_L_Engine.get_collision_point() + target_altitude).y
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta * altitude_adjust_speed

func _player_reached_checkpoint():
	print("Player Reached Checkpoint")
