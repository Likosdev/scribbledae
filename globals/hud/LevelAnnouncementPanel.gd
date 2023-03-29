extends Panel

class_name LevelAnnouncementPanel

@onready var level_number_label := $LevelAnnouncementNumbers
@onready var level_name_label := $LevelAnnouncementName
@onready var my_display_timer := $DisplayTimer


signal level_display_show
signal level_display_done


func _ready():
	self.modulate = Color.TRANSPARENT

func display(world: int, level: int, level_name: String):
	var world_text = "World {world} - Level {level}".format(
			{'world': str(world), 'level':str(level)}
	)
	
	var level_name_text = level_name
	level_number_label.text = world_text
	level_name_label.text = level_name_text
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, .5)
	await tw.finished
	my_display_timer.start()
	await my_display_timer.timeout
	level_display_show.emit()
	tw = create_tween()
	tw.tween_property(self, "modulate", Color.TRANSPARENT, .5)
	level_display_done.emit()
	
	
