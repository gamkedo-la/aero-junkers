extends KinematicBody

var max_speed = 4000 #units/second
var altitude_adjust_speed = 5 #units/second
var acceleration = Vector3.ZERO
var acceleration_direction = 0
var turn_direction = 0
var velocity = Vector3.ZERO
var target_altitude = Vector3.UP * 3

var base_length = 5 #used as a "wheel base" length
var max_turning_angle = 15
var current_turning_angle = 0

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)

func _physics_process(delta):

	get_input(delta)
	#current_turning_angle = turn_direction * deg2rad(max_turning_angle)
	#calculate_turning(delta)
	apply_acceleration(delta)
	
	#change velocity from global to local orientation
	velocity = global_transform.basis.orthonormalized().xform(velocity)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	moveToTargetAltitude(delta)

func get_input(delta):
	if Input.is_action_pressed("turn_left"):
#		turn_direction = -1
		rotate_y(0.2)
	if Input.is_action_pressed("turn_right"):
#		turn_direction = 1
		rotate_y(-0.2)
	if Input.is_action_pressed("accelerate"):
		acceleration_direction = -1
	if Input.is_action_pressed("reverse"):
		acceleration_direction = 1
	if Input.is_action_just_released("accelerate"):
		acceleration_direction = 0
	if Input.is_action_just_released("reverse"):
		acceleration_direction = 0
#	if Input.is_action_just_released("turn_left"):
#		turn_direction = 0
#	if Input.is_action_just_released("turn_right"):
#		turn_direction = 0
		
func calculate_turning(delta):
	var engine_position: Vector3 = Vector3.ZERO
	var cockpit_position: Vector3 = $MeshInstance_Cockpit.transform.origin
	
	$Cockpit_Pos.transform.origin = cockpit_position
	$Engine_Pos.transform.origin = engine_position
	
	cockpit_position += velocity * delta
	engine_position += velocity.rotated(transform.basis.y, current_turning_angle) * delta
	
	var new_heading: Vector3 = cockpit_position.direction_to(engine_position)
	
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = new_heading * velocity.length()
	if d < 0:
		velocity = new_heading * min(velocity.length(), max_speed)
	look_at(transform.origin + new_heading, transform.basis.y)
	
	velocity = new_heading * velocity
	#rotation = new_heading.angle()
		
func apply_acceleration(delta):
	acceleration.z += ((max_speed * acceleration_direction) - acceleration.z) * delta
	velocity = acceleration * delta
	
func moveToTargetAltitude(delta):
	var target_position_y = ($RayCast_L_Engine.get_collision_point() + target_altitude).y
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta * altitude_adjust_speed

func _player_reached_checkpoint():
	print("Player Reached Checkpoint")
