class_name AeroJunker
extends KinematicBody

signal switch_cam
signal new_lap

export(bool) var is_ai_controlled: bool = false
export(Array, NodePath) var checkpoints
export var pilotName = "player"
var nextCheckpointIndex = 0
var nextCheckpoint
var distance_to_next_checkpoint = 0
var previousCheckpoint = null
var directionToNextCheckpoint: Vector3 = Vector3.ZERO
var directionToNextCheckpoint2D: Vector2 = Vector2.ZERO
var prevDirectionToNextCheckpoint2D: Vector2 = Vector2.ZERO
var currentLap: int = 0
var trackLaps: int = 3

var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

var max_speed: float = 7500.0 #units/second
var throttle: float = 1 #percent of max_speed
var acceleration: Vector3 = Vector3.ZERO
var acceleration_direction: int = 0
var velocity: Vector3 = Vector3.ZERO
var velocity2D: Vector2 = Vector2.ZERO
var is_drifting: bool = false
var target_altitude: Vector3 = Vector3.UP * 3
var verticle_bob_amplitude: float = 2
var verticle_bob_period: float = 200.0
var health = 100.0
var test_max_speed: float = 0

const BOOST_SPEED_INCREMENT: float = 10000.0
const BOOST_MAX_DURATION: float = 3.5 #seconds
const BOOST_COOLDOWN_DURATION: float = 10.0 #seconds
var boost_ready: bool = true
var boost_activated: bool = false

var reset_to_last_checkpoint_in_porgress: bool = false

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
	CheckpointSingleton.positions.push_back(self)
	nextCheckpoint = get_node(checkpoints[nextCheckpointIndex])
	
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)
	if not CheckpointSingleton.is_connected("finish_line_reached", self, "_player_reached_finish_line"):
		assert(CheckpointSingleton.connect("finish_line_reached", self, "_player_reached_finish_line") == OK)
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
	prevDirectionToNextCheckpoint2D = directionToNextCheckpoint2D
	directionToNextCheckpoint2D = vector2DtoTarget(nextCheckpoint)
	
	if is_ai_controlled:
		get_ai_input(delta)
	else: 
		get_input(delta)
		
	apply_acceleration(delta)
	apply_gravity(delta)
	
	#change velocity from global to local orientation
	if not is_drifting:
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
	distance_to_next_checkpoint = transform.origin.distance_to(nextCheckpoint.transform.origin)
	$EngineRunningSFX.unit_db = min((velocity.length() * 0.5), 15)
	
	if health < 90:
		$Engine_L/Fire/FireParticles.emitting = true
		$Engine_R/Fire/FireParticles.emitting = true
	else:
		$Engine_L/Fire/FireParticles.emitting = false
		$Engine_R/Fire/FireParticles.emitting = false

func get_input(_delta):
	#Button Pressed
	if Input.is_action_pressed("turn_left"): turn_left()
	if Input.is_action_pressed("turn_right"): turn_right()
	if Input.is_action_pressed("accelerate"): accelerate()
	if Input.is_action_pressed("reverse"): reverse()
	if Input.is_action_pressed("boost"): boost()
	if Input.is_action_pressed("drift"): is_drifting = true
	
	if not is_ai_controlled:
		if Input.is_action_pressed("reset_to_previous_checkpoint"): reset_to_previous_checkpoint()
		
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
	if Input.is_action_just_released("drift"): 
		is_drifting = false
		boost()
	
	# Camera Input
	if Input.is_action_just_pressed("cam_toggle"):
		_toggle_camera_up()
	if Input.is_action_just_pressed("chase_cam"):
		cur_camera_idx = 0
		emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func get_ai_input(delta):
	var degreesToNextCheckpoint = rad2deg(velocity2D.normalized().angle_to(directionToNextCheckpoint2D))
	var prevDegreesToNextCheckpoint = rad2deg(velocity2D.normalized().angle_to(prevDirectionToNextCheckpoint2D))
	
	accelerate()
	
	if (abs(degreesToNextCheckpoint) > abs(prevDegreesToNextCheckpoint)):
		throttle *= 0.95
		
	if degreesToNextCheckpoint > 1:
		turn_right()
	elif degreesToNextCheckpoint < -1:
		turn_left()
	else:
		throttle = 1
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
	if (direction == TURN_DIRECTION.RIGHT && $Engine_R.rotation_degrees.y > -MAX_ENGINE_ROTATION_ANGLE):
		rotate_engines_y(radians)
	elif (direction == TURN_DIRECTION.LEFT && $Engine_R.rotation_degrees.y < MAX_ENGINE_ROTATION_ANGLE):
		rotate_engines_y(radians)


func rotate_engines_y(radians) -> void:
	$Engine_L.rotate_y(radians)
	#$CollisionShape_L_Engine.rotate_y(radians)
	$Engine_R.rotate_y(radians)
	#$CollisionShape_R_Engine.rotate_y(radians)
	
	$Engine_L.rotate_z(radians * 0.6)
#	$CollisionShape_L_Engine.rotate_z(radians * 0.6)
	$Engine_R.rotate_z(radians * 0.6)
#	$CollisionShape_R_Engine.rotate_z(radians * 0.6)
	
	$Cockpit.rotate_z(radians)


func reset_engine_rotation() -> void:
	$Engine_R.rotation_degrees.y = 0.0
	$Engine_L.rotation_degrees.y = 0.0
#	$CollisionShape_R_Engine.rotation_degrees.y = 0.0
#	$CollisionShape_L_Engine.rotation_degrees.y = 0.0
	
	$Engine_R.rotation_degrees = Vector3.ZERO
	$Engine_L.rotation_degrees = Vector3.ZERO
	$Cockpit.rotation_degrees = Vector3.ZERO
	
#	$CollisionShape_R_Engine.rotation_degrees = Vector3.ZERO
#	$CollisionShape_L_Engine.rotation_degrees = Vector3.ZERO
	$Cockpit.rotation_degrees = Vector3.ZERO


func apply_acceleration(delta) -> void:
	if not is_drifting:
		acceleration.z += ((((max_speed * throttle) + calculate_boost()) * acceleration_direction) - acceleration.z) * delta
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
			$Engine_L/Sparks/SparkParticles.emitting = true
			$Engine_R/Sparks/SparkParticles.emitting = true


func play_engine_breaking_sound() -> void:
	if !$EngineBreakingSFX.playing:
		$EngineBreakingSFX.play()


func _toggle_camera_up() -> void:
	if cur_camera_idx < camera_positions.size() - 1:
		cur_camera_idx += 1
	else:
		cur_camera_idx = 0
	emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func _player_reached_checkpoint(checkpoint, aeroJunker) -> void:
	if not self == aeroJunker:
		return
	if checkpoint == nextCheckpoint:
		previousCheckpoint = nextCheckpoint
#		print_debug("WIP: Player ", get_instance_id(), " previousCheckpoint changed to: get_path-", previousCheckpoint.get_path(), " get_instance_id- ", previousCheckpoint.get_instance_id())
		if nextCheckpointIndex >= checkpoints.size() - 1:
			nextCheckpointIndex = 0
		else:
			nextCheckpointIndex = nextCheckpointIndex + 1
			
		if currentLap > trackLaps:
			endRace()
			_toggle_camera_up()


func _player_reached_finish_line(checkpoint, aeroJunker) -> void:
	if not self == aeroJunker:
		return
	if checkpoint == nextCheckpoint:
		currentLap += 1
		emit_signal("new_lap", currentLap)


func endRace() -> void:
	is_ai_controlled = true


func vector2DtoTarget(target) -> Vector2:
# warning-ignore:unused_variable
	var directionToTarget3D: Vector3 = Vector3.ZERO
	var directionToTarget2D: Vector2 = Vector2.ZERO
	
	directionToTarget3D = (target.transform.origin - transform.origin).normalized()
	directionToTarget2D.x = target.transform.origin.x - transform.origin.x
	directionToTarget2D.y = target.transform.origin.z - transform.origin.z
	return directionToTarget2D.normalized()

func calculate_boost() -> float:
	if boost_activated:
		return BOOST_SPEED_INCREMENT
	else:
		return 0.0

func boost() -> void:
	if !boost_activated && boost_ready:
		$BoosterTimer.start(BOOST_MAX_DURATION)
		boost_activated = true
		boost_ready = false

func _on_BoosterCooldownTimer_timeout():
	$BoosterCooldownTimer.stop()
	boost_ready = true
	print_debug('boost ready')


func _on_BoosterTimer_timeout():
	$BoosterTimer.stop()
	boost_activated = false
	$BoosterCooldownTimer.start(BOOST_COOLDOWN_DURATION)
	
func reset_to_previous_checkpoint():
	if previousCheckpoint != null:
		
		var distance_to_previous_checkpoint = transform.origin.distance_to(previousCheckpoint.transform.origin)		
		if distance_to_previous_checkpoint >= 1.0:
			print_debug(" [", get_instance_id(), "]", "Reset, distance", distance_to_previous_checkpoint)
			acceleration = Vector3.ZERO
			velocity = Vector3.ZERO
			transform.origin = previousCheckpoint.transform.origin
			look_at(nextCheckpoint.transform.origin, Vector3.UP)
		else :
			print_debug(" [", get_instance_id(), "]", "Too close to reset, distance = ", distance_to_previous_checkpoint)
