extends Marker2D

class_name WallDetector


@onready var my_right_ray = $RaycastRight
@onready var my_left_ray = $RaycastLeft

signal wall_detected(side: String, what : PhysicsBody2D)


func _physics_process(delta):
	if my_left_ray.is_colliding():
		var what = my_left_ray.get_collider()
		if what is Level:
			emit_wall_detected('left', what)
	if my_right_ray.is_colliding():
		var what = my_right_ray.get_collider()
		if what is Level:
			emit_wall_detected('right', what)

	
func emit_wall_detected(side : String, what = PhysicsBody2D):
	emit_signal("wall_detected", side, what)
