extends Camera

var targJunker: AeroJunker = null
var camTarget: Position3D = null
export (float) var lerp_speed = 7.5


func _ready() -> void:
	self.set_as_toplevel(true)
	
func _physics_process(delta) -> void:
	if !camTarget:
		return
		
	global_transform = global_transform.interpolate_with(camTarget.global_transform, lerp_speed * delta)
		

func initialize(_junker: AeroJunker) -> bool:
	if _junker:
		targJunker = _junker
		if not targJunker.is_connected("switch_cam", self, "_on_camera_change"):
			assert(targJunker.connect("switch_cam", self, "_on_camera_change") == OK )
		return true
	
	return false

func _on_camera_change(_targ: Position3D, _lerp_speed: float) -> void:
	camTarget = _targ
	lerp_speed = _lerp_speed
	
