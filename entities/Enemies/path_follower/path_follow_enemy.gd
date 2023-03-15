extends Path2D
class_name PathFollowEnemy


@export var SPEED := 100


@onready var my_animation_player := $AnimationPlayer
@onready var my_path_follower := $PathFollow2D
@onready var my_sprite := $PathFollow2D/Sprite2D

func _ready():
	my_path_follower.set_rotates(false)
	my_animation_player.play("float")
	

func _physics_process(delta):
	my_path_follower.progress += delta * SPEED


func _on_hit_box_area_entered(area):
	EventBus.emit_signal('enemie_defeated', my_sprite.global_position) 
	queue_free()
