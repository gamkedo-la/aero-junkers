extends Control

func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/Tracks/canyon_track.tscn")


func _on_OptionsButton_pressed():
	pass


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Scenes/UI/CreditsScreen.tscn")
