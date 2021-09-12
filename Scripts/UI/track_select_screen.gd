extends Control

func _on_Track1Button_pressed():
#	get_tree().change_scene("res://Scenes/Tracks/canyon_track.tscn")
	Global.current_level = 0
	Global.goto_scene(Global.level_list[Global.current_level])


func _on_Track2Button_pressed():
	Global.current_level = 1
	Global.goto_scene(Global.level_list[Global.current_level])


func _on_Track3Button_pressed():
	Global.current_level = 2
	Global.goto_scene(Global.level_list[Global.current_level])
