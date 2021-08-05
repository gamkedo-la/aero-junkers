extends VBoxContainer

onready var minimapViewport: Viewport = $Viewport
onready var mapTexture: TextureRect = $MapTexture

var texture

func _ready():
	texture = minimapViewport.get_texture()
	mapTexture.texture = texture
	
func _process(_delta): 
	mapTexture.texture = texture
