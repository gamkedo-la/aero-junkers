class_name AeroJunker
extends KinematicBody

signal switch_cam

var max_speed: float = 4000.0 #units/second
var altitude_adjust_speed: float = 5.0 #units/second
var acceleration: Vector3 = Vector3.ZERO
var acceleration_direction: int = 0
var velocity: Vector3 = Vector3.ZERO
var target_altitude: Vector3 = Vector3.UP * 3

# Follow Cam Variables
onready var followcam: Camera = $ChaseCam
onready var campos_node: Spatial = $CameraPositions
var camera_positions = []
var cam_lerps = [11.5, 15.0, 20.0, 20.0, 20.0]
var cur_camera_idx:int = 0

enum TURN_DIRECTION {LEFT, RIGHT}
const MAX_ENGINE_ROTATION_ANGLE = 23

func _ready():
	if not CheckpointSingleton.is_connected("checkpoint_reached", self, "_player_reached_checkpoint"):
		assert(CheckpointSingleton.connect("checkpoint_reached", self, "_player_reached_checkpoint") == OK)
	_init_follow_cam()


func _init_follow_cam() -> void:
	camera_positions = campos_node.get_children()
	# Initialize Chase Camera
	assert(followcam.initialize(self) == true)
	emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func _physics_process(delta):
	get_input(delta)
	apply_acceleration(delta)
	
	#change velocity from global to local orientation
	velocity = global_transform.basis.orthonormalized().xform(velocity)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	moveToTargetAltitude(delta)


func get_input(delta):
	#Button Pressed
	if Input.is_action_pressed("turn_left"):
		rotate_y(0.02)
		calculate_turn_engines(0.02, TURN_DIRECTION.LEFT)
	if Input.is_action_pressed("turn_right"):
		rotate_y(-0.02)
		calculate_turn_engines(-0.02, TURN_DIRECTION.RIGHT)
	if Input.is_action_pressed("accelerate"):
		acceleration_direction = -1
	if Input.is_action_pressed("reverse"):
		acceleration_direction = 1
		
	#Button Released
	if Input.is_action_just_released("accelerate"):
		acceleration_direction = 0
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


func reset_engine_rotation() -> void:
	$MeshInstance_R_Engine.rotation_degrees.y = 0.0
	$MeshInstance_L_Engine.rotation_degrees.y = 0.0
	$CollisionShape_R_Engine.rotation_degrees.y = 0.0
	$CollisionShape_L_Engine.rotation_degrees.y = 0.0


func apply_acceleration(delta) -> void:
	acceleration.z += ((max_speed * acceleration_direction) - acceleration.z) * delta
	velocity = acceleration * delta


func moveToTargetAltitude(delta) -> void:
	var target_position_y = ($RayCast_L_Engine.get_collision_point() + target_altitude).y
	transform.origin.y = transform.origin.y + (target_position_y - transform.origin.y) * delta * altitude_adjust_speed


func _toggle_camera_up() -> void:
	if cur_camera_idx < camera_positions.size() - 1:
		cur_camera_idx += 1
	else:
		cur_camera_idx = 0
	emit_signal("switch_cam", camera_positions[cur_camera_idx], cam_lerps[cur_camera_idx])


func _player_reached_checkpoint() -> void:
	print("Player Reached Checkpoint")
