extends Control


func _on_TitleScreenButton_pressed():
	get_tree().change_scene("res://Scenes/UI/TitleScreen.tscn")

#func _process(delta):
#	if Input.is_action_just_released("return_to_title_screen"):
#		get_tree().change_scene("res://Scenes/UI/TitleScreen.tscn")
#		
#	if Input.is_action_just_released("next_race"):
#		get_tree().change_scene("res://Scenes/Tracks/track3.tscn")
