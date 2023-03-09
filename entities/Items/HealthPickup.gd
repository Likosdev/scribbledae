extends Node2D
class_name HealthPickup

signal collected(position : Vector2)


func _on_area_2d_body_entered(_body):
	emit_signal("collected", self.position)
	queue_free()
