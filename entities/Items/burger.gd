extends RigidBody2D
class_name Burger

@export var push_multiplier := 10.0

@onready var my_debug_label := $Label
 

func _physics_process(delta):
	my_debug_label.text = "Velocity: {}".format([self.linear_velocity], '{}')
	
	
func push(p_velocity : Vector2) -> void:
	print("push")
	print(p_velocity)
	p_velocity.y = 0
	var dir = (p_velocity * push_multiplier) + Vector2.UP
	print("dir; " + str(dir))
	apply_central_force(dir)
	
	
	
