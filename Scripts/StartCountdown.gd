extends Control


onready var cdtext = $CDLabel
onready var tween = Tween.new()
var cdown_time: float = 5.0

func _ready():
	call_deferred("add_child", tween)
	tween.connect("tween_all_completed",self, "start_race")
	
	pass # Replace with function body.

func _process(delta) -> void:
	cdown_time -= delta
	cdtext.text = str(int(cdown_time))
	if cdown_time <= 1.0:
		cdtext.text = "0"
		tween.interpolate_property(cdtext, "rect_scale", cdtext.rect_scale, Vector2(10,10), cdown_time, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween.start()
		set_process(false)

func start_race() -> void:
	cdtext.visible = false
	Global.emit_signal("race_start")
