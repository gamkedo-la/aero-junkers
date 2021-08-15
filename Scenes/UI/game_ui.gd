extends CanvasLayer


func _on_AeroJunker_new_lap(lap: int):
	$MarginContainer/ScreenVB/TopBar/Right/LapCounterLabel.bbcode_text = "[right]Lap %s/3 [/right]" % lap 
