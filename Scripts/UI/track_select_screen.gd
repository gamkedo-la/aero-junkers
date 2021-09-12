extends Control

func _on_Track1Button_pressed():
#	get_tree().change_scene("res://Scenes/Tracks/canyon_track.tscn")
	Global.goto_scene("res://Scenes/Tracks/canyon_track.tscn")


func _on_Track2Button_pressed():
#	get_tree().change_scene("res://Scenes/Tracks/tundra_track.tscn")
	Global.goto_scene("res://Scenes/Tracks/tundra_track.tscn")


func _on_Track3Button_pressed():
	Global.goto_scene("res://Scenes/Tracks/canyon_night_track.tscn")
