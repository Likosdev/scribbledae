extends Area2D
class_name HitBox


func _ready():
	if not self.is_in_group(Globals.GROUP_NAME_HITBOXES):
		self.add_to_group(Globals.GROUP_NAME_HITBOXES)

