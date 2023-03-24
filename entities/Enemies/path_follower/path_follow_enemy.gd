extends Path2D
class_name PathFollowEnemy


@export var SPEED := 100

@export var death_effect : PackedScene = null
@onready var my_animation_player := $AnimationPlayer
@onready var my_path_follower := $PathFollow2D
@onready var my_sprite := $PathFollow2D/Sprite2D
@onready var my_hurt_box := $PathFollow2D/Sprite2D/HurtBox
@onready var my_hit_box := $PathFollow2D/Sprite2D/HitBox

func _ready():
	my_path_follower.set_rotates(false)
	my_animation_player.play("float")
	

func _physics_process(delta):
	my_path_follower.progress += delta * SPEED


func _on_hit_box_area_entered(area):
	if not area.owner is Player: return
	var fx :GPUParticles2D = death_effect.instantiate()
	
	my_path_follower.add_child(fx)
	fx.position = my_sprite.position
	my_hit_box.set_deferred('monitorable', false)
	my_hurt_box.set_deferred('monitorable', false) 
	my_sprite.visible = false
	Sounds.play_sound(Globals.SOUND_NAME_ENEMY_DEFEATED)
	await get_tree().create_timer(.4).timeout
	queue_free()
