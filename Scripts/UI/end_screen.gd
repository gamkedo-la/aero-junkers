extends Control


func _on_TitleScreenButton_pressed():
	Global.emit_signal("return_to_menu")
	Global.goto_scene("res://Scenes/UI/TitleScreen.tscn")

func _process(delta):
	if Input.is_action_just_released("return_to_title_screen") and self.visible:
		Global.emit_signal("return_to_menu")
		Global.goto_scene("res://Scenes/UI/TitleScreen.tscn")
		
	if Input.is_action_just_released("next_race") and self.visible:
		Global.emit_signal("return_to_menu")
		Global.goto_scene("res://Scenes/Tracks/tundra_track.tscn")
