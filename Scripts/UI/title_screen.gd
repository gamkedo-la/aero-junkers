extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func _on_StartButton_pressed():
#	get_tree().change_scene("res://Scenes/UI/TrackSelectScreen.tscn")
	Global.goto_scene("res://Scenes/UI/TrackSelectScreen.tscn")


func _on_OptionsButton_pressed():
	pass


func _on_CreditsButton_pressed():
#	get_tree().change_scene("res://Scenes/UI/CreditsScreen.tscn")
	Global.goto_scene("res://Scenes/UI/CreditsScreen.tscn")
