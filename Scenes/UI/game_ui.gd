extends CanvasLayer


func _on_AeroJunker_new_lap(lap: int):
	if lap > 3:
		$EndScreen.visible = true
		print_debug("show results")
	else:
		$MarginContainer/ScreenVB/TopBar/Right/LapCounterLabel.bbcode_text = "[right]Lap %s/3 [/right]" % lap
