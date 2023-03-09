extends Control

class_name HUD

@onready var heart_1 = $Heart_1
@onready var heart_2 = $Heart_2
@onready var heart_3 = $Heart_3


func  _ready():
	EventBus.connect("level_restart", self.reset)
	
	
func reset():
	on_player_health_changed(3)
	

func on_player_health_changed(health: int):
	match health:
		1:
			$Heart_3.visible = false
			$Heart_2.visible = false
			$Heart_1.visible = true
		2:
			$Heart_3.visible = false
			$Heart_2.visible = true
			$Heart_1.visible = true
		3:
			$Heart_3.visible = true
			$Heart_2.visible = true
			$Heart_1.visible = true
		0:
			$Heart_3.visible = false
			$Heart_2.visible = false
			$Heart_1.visible = false
			
