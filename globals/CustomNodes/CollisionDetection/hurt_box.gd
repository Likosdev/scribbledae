extends Area2D
class_name  HurtBox


func _ready():
	if not self.is_in_group(Globals.GROUP_NAME_HURTBOXES):
		self.add_to_group(Globals.GROUP_NAME_HURTBOXES)
