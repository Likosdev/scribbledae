extends Sprite2D


func _ready():
	var r = randf()
	if r > 0.5:
		flip_h = true # randomly flip for more variety
		
