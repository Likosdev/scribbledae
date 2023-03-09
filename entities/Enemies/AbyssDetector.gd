extends Marker2D



@onready var my_right_ray = $RaycastRight
@onready var my_left_ray = $RaycastLeft

signal abyss_detected(side: String)

func _physics_process(_delta):
	if not my_right_ray.is_colliding():
		emit_signal("abyss_detected","right")
	if not my_left_ray.is_colliding():
		emit_signal("abyss_detected","left")
