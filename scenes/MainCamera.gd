extends Camera2D
class_name MainCamera

@export var lerp_weight : float = 0.1

var target_player : Player = null

var stopped = false

func set_target_player(player:Player):
	self.target_player = player
	print("target player attached")

func _physics_process(_delta):
	if target_player and not stopped:
		self.position = lerp(self.position, target_player.position, lerp_weight)
		
