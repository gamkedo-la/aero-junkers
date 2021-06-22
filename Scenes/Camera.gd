extends Camera

func _process(delta):
	transform.origin.y = get_node("PlaceHolder_AeroJunker").transform.origin.y + 50 
