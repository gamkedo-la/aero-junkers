class_name AeroJunker
extends KinematicBody

signal switch_cam

export(bool) var is_ai_controlled: bool = false
export(Array, NodePath) var checkpoints
onready var nextCheckpointIndex = 0
onready var nextCheckpoint = get_node(checkpoints[nextCheckpointIndex])
var directionToNextCheckpoint: Vector3 = Vector3.ZERO
var directionToNextCheckpoint2D: Vector2 = Vector2.ZERO

var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

var max_speed: float = 10000.0 #units/second
var acceleration: Vector3 = Vector3.ZERO
var acceleration_direction: int = 0
var velocity: Vector3 = Vector3.ZERO
var velocity2D: Vector2 = Vector2.ZERO
var target_altitude: Vector3 = Vector3.UP * 3
var verticle_bob_amplitude: float = 2
var verticle_bob_period: float = 200.0
var health = 100.0
var test_max_speed: float = 0

# Follow Cam Variables
onready var followcam: Camera = $ChaseCam
onready var campos_node: Spatial = $CameraPositions
var camera_positions = []
var cam_lerps = [11.5, 15.0, 20.0, 20.0, 20.0]
var cur_camera_idx:int = 0

enum TURN_DIRECTION {LEFT, RIGHT}
const MAX_ENGINE_ROTATION_ANGLE = 23
const ENVIRONMENT_DAMAGE = 0.1

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)
	_init_follow_cam()
	
	# We can likely come up witha better way to pre-calculate *actual* max speed, but for right now, the 
	# Junker tends to max out at around velocity.length() = 165ish
	# The max will auto-adjust if the max is exceeded, and the speedometer will update accordingly
	test_max_speed = 165
	AeroSingleton.aero_max_speed = 165
	
	DebugOverlay.draw.add_vector(self, "directionToNextCheckpoint", 5, 4, Color(0,1,0, 0.5))
	

func _init_follow_cam() -> void:
	camera_positions = campos_node.get_children()
	# Initialize Chase Camera
	assert(followcam.initialize(self) == true)
	emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func _physics_process(delta):
	directionToNextCheckpoint = (nextCheckpoint.transform.origin - transform.origin).normalized()
	directionToNextCheckpoint2D.x = nextCheckpoint.transform.origin.x - transform.origin.x
	directionToNextCheckpoint2D.y = nextCheckpoint.transform.origin.z - transform.origin.z
	directionToNextCheckpoint2D = directionToNextCheckpoint2D.normalized()
	
	if is_ai_controlled:
		get_ai_input(delta)
	else: 
		get_input(delta)
		
	apply_acceleration(delta)
	apply_gravity(delta)
	
	#change velocity from global to local orientation
	velocity = global_transform.basis.orthonormalized().xform(velocity)
	
	velocity2D.x = velocity.x
	velocity2D.y = velocity.z
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if velocity.length() > test_max_speed:
		test_max_speed = velocity.length()		
	
	# If player aerojunker, update UI elements etc...
	if not is_ai_controlled:
		AeroSingleton.aero_max_speed = test_max_speed
		AeroSingleton.aero_speed = velocity.length()
#	print_debug("velocity: ", velocity, "velocity.length()", velocity.length())
	detect_collision(delta)
	maintainAltitude(delta)


func _process(_delta):
	nextCheckpoint = get_node(checkpoints[nextCheckpointIndex])
	$EngineRunningSFX.unit_db = min((velocity.length() * 0.5), 15)


func get_input(_delta):
	#Button Pressed
	if Input.is_action_pressed("turn_left"): turn_left()
	if Input.is_action_pressed("turn_right"): turn_right()
	if Input.is_action_pressed("accelerate"): accelerate()
	if Input.is_action_pressed("reverse"): reverse()
		
	#Button Released
	if Input.is_action_just_released("accelerate"):
		acceleration_direction = 0
		$EngineAcceleratingSFX.stop()
		play_engine_breaking_sound()
	if Input.is_action_just_released("reverse"):
		acceleration_direction = 0
	if Input.is_action_just_released("turn_left"):
		reset_engine_rotation()
	if Input.is_action_just_released("turn_right"):
		reset_engine_rotation()
	
	# Camera Input
	if Input.is_action_just_pressed("cam_toggle"):
		_toggle_camera_up()
	if Input.is_action_just_pressed("chase_cam"):
		cur_camera_idx = 0
		emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func get_ai_input(_delta):
	accelerate()
	if rad2deg(velocity2D.normalized().angle_to(directionToNextCheckpoint2D)) > 10:
		turn_right()
	elif rad2deg(velocity2D.normalized().angle_to(directionToNextCheckpoint2D)) < -10:
		turn_left()
	else:
		reset_engine_rotation()


func turn_left():
	rotate_y(0.02)
	calculate_turn_engines(0.02, TURN_DIRECTION.LEFT)


func turn_right():
	rotate_y(-0.02)
	calculate_turn_engines(-0.02, TURN_DIRECTION.RIGHT)


func accelerate():
	acceleration_direction = -1
	if !$EngineAcceleratingSFX.playing: $EngineAcceleratingSFX.play()


func reverse():
	acceleration_direction = 1


func calculate_turn_engines(radians, direction) -> void:
	if (direction == TURN_DIRECTION.RIGHT && $MeshInstance_R_Engine.rotation_degrees.y > -MAX_ENGINE_ROTATION_ANGLE):
		rotate_engines_y(radians)
	elif (direction == TURN_DIRECTION.LEFT && $MeshInstance_R_Engine.rotation_degrees.y < MAX_ENGINE_ROTATION_ANGLE):
		rotate_engines_y(radians)


func rotate_engines_y(radians) -> void:
	$MeshInstance_L_Engine.rotate_y(radians)
	$CollisionShape_L_Engine.rotate_y(radians)
	$MeshInstance_R_Engine.rotate_y(radians)
	$CollisionShape_R_Engine.rotate_y(radians)
	
	$MeshInstance_L_Engine.rotate_z(radians * 0.6)
	$CollisionShape_L_Engine.rotate_z(radians * 0.6)
	$MeshInstance_R_Engine.rotate_z(radians * 0.6)
	$CollisionShape_R_Engine.rotate_z(radians * 0.6)
	
	$Cockpit.rotate_z(radians)


func reset_engine_rotation() -> void:
	$MeshInstance_R_Engine.rotation_degrees.y = 0.0
	$MeshInstance_L_Engine.rotation_degrees.y = 0.0
	$CollisionShape_R_Engine.rotation_degrees.y = 0.0
	$CollisionShape_L_Engine.rotation_degrees.y = 0.0
	
	$MeshInstance_R_Engine.rotation_degrees = Vector3.ZERO
	$MeshInstance_L_Engine.rotation_degrees = Vector3.ZERO
	$Cockpit.rotation_degrees = Vector3.ZERO
	
	$CollisionShape_R_Engine.rotation_degrees = Vector3.ZERO
	$CollisionShape_L_Engine.rotation_degrees = Vector3.ZERO
	$Cockpit.rotation_degrees = Vector3.ZERO


func apply_acceleration(delta) -> void:
	acceleration.z += ((max_speed * acceleration_direction) - acceleration.z) * delta
	velocity = acceleration * delta


func apply_gravity(_delta) -> void:
	if transform.origin.y > $RayCast_L_Engine.get_collision_point().y + target_altitude.y + verticle_bob_amplitude:
		velocity += gravity


func maintainAltitude(delta) -> void:
	var altitude_oscillation_modifier: float = sin(OS.get_ticks_msec()/verticle_bob_period) * verticle_bob_amplitude
	var target_position_y: float = $RayCast_L_Engine.get_collision_point().y + target_altitude.y + altitude_oscillation_modifier
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta


func detect_collision(_delta) -> void:
	for index in range(get_slide_count()):
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("environment"):
			health -= ENVIRONMENT_DAMAGE
			if (health > 0):
				print_debug('health: %f'	% health)
			else:
				print_debug('aerojunker is dead')


func play_engine_breaking_sound() -> void:
	if !$EngineBreakingSFX.playing:
		$EngineBreakingSFX.play()


func _toggle_camera_up() -> void:
	if cur_camera_idx < camera_positions.size() - 1:
		cur_camera_idx += 1
	else:
		cur_camera_idx = 0
	emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func _player_reached_checkpoint(_checkpoint) -> void:
	if _checkpoint == nextCheckpoint:
		if nextCheckpointIndex >= checkpoints.size() - 1:
			nextCheckpointIndex = 0
		else:
			nextCheckpointIndex = nextCheckpointIndex + 1
