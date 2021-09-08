extends CanvasLayer

func _ready():
	if not CheckpointSingleton.is_connected("positions_updated", self, "_on_Checkpoint_Singleton_positions_updated"):
		assert(CheckpointSingleton.connect("positions_updated", self, "_on_Checkpoint_Singleton_positions_updated") == OK)

func _on_AeroJunker_new_lap(lap: int):
	if lap > 3:
		$EndScreen.visible = true
		$EndScreen/Menu/ResultsText.bbcode_text = "[center]1st Place: %s[/center]" % CheckpointSingleton.positions[0].pilotName
		$EndScreen/Menu/ResultsText2.bbcode_text = "[center]2nd Place: %s[/center]" % CheckpointSingleton.positions[1].pilotName
		$EndScreen/Menu/ResultsText3.bbcode_text = "[center]3rd Place: %s[/center]" % CheckpointSingleton.positions[2].pilotName
		$EndScreen/Menu/ResultsText4.bbcode_text = "[center]4th Place: %s[/center]" % CheckpointSingleton.positions[3].pilotName
		$EndScreen/Menu/ResultsText5.bbcode_text = "[center]5th Place: %s[/center]" % CheckpointSingleton.positions[4].pilotName
		$EndScreen/Menu/ResultsText6.bbcode_text = "[center]6th Place: %s[/center]" % CheckpointSingleton.positions[5].pilotName
		print_debug("show results")
	else:
		$MarginContainer/ScreenVB/TopBar/Right/LapCounterLabel.bbcode_text = "[right]Lap %s/3 [/right]" % lap

func _on_Checkpoint_Singleton_positions_updated(positions):
	for i in positions.size():
		if not positions[i].is_ai_controlled:
			$MarginContainer/ScreenVB/TopBar/Left/PositionLabel.bbcode_text = "%s/6" % (i + 1)
