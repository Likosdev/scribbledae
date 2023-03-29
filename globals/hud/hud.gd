extends Control

class_name HUD

@onready var heart_1 = $Heart_1
@onready var heart_2 = $Heart_2
@onready var heart_3 = $Heart_3

@onready var my_level_announcement : LevelAnnouncementPanel = $LevelAnnouncementPanel


signal level_announcement_show
signal level_announcement_done

func  _ready():
	EventBus.connect("level_restart", self.reset)
	my_level_announcement.level_display_show.connect(
			func(): self.level_announcement_show.emit()
	)
	my_level_announcement.level_display_done.connect(
			func(): self.level_announcement_done.emit()
	)

func reset():
	on_player_health_changed(3)

func on_pickup_collected(_position: Vector2, pickup: String):
	if pickup == "burger":
		pass

func display_level_announcement(world: int, level: int, p_name : String):
	my_level_announcement.display(world, level, p_name)

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
			
