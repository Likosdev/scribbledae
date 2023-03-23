extends CharacterBody2D
class_name Burger

var pickable:=false
var is_tweened:=false

func _ready():
	await get_tree().create_timer(.5).timeout
	
	pickable = true

func _physics_process(_delta):
	if is_tweened: return
	self.velocity.y += 18.0
	move_and_slide()

func _on_pickup_area_body_entered(body):
	if body is Player and pickable:
		EventBus.pickup_collected.emit(self.position, Globals.PICKUP_NAME_BURGER)
		queue_free()
