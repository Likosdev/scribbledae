extends Camera2D
class_name MainCamera

@export var lerp_weight : float = 0.1

var target_player : Player = null

var stopped = false

func set_target_player(player:Player):
	self.target_player = player


func _physics_process(_delta):
	if target_player and not stopped:
		self.position =  target_player.global_position
		
