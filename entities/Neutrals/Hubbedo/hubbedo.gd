extends AnimatableBody2D
class_name Hubbedo


@onready var my_big_sprite := $SpriteBig
@onready var my_small_sprite := $SpriteSmall
@onready var my_small_collider := $ColSmall
@onready var my_big_collider := $ColBig
@onready var my_small_face := $SpriteSmall/FaceSpriteSmall
@onready var my_big_face := $SpriteBig/FaceSpriteBig
@onready var my_mouth_position := %MouthPosition
@onready var my_animation_player := $AnimationPlayer

var player_in_proximity : Player = null
var fed := false


func _ready():
	EventBus.burger_spawned.connect(self.on_burger_spawned)
	
func on_burger_spawned(_p_position: Vector2, burger : Burger):

	if player_in_proximity:

		tween_burger_to_mouth(burger)
		

func tween_burger_to_mouth(burger : Burger):
	if fed: return
	burger.is_tweened = true

	var TW = create_tween()
	TW.tween_property(burger, 'position', self.position + my_mouth_position.position, .2)
	TW.chain().tween_property(burger, 'scale', Vector2.ZERO, .1)
	await TW.step_finished
	my_animation_player.play("eat_burger")
	await TW.finished
	

	burger.queue_free()
	fed = true
	await my_animation_player.animation_finished
	my_animation_player.play("friendly_face")
	grow()
	

func play_feed_sound():
	Sounds.play_sound(Globals.SOUND_NAME_FEED, true)

func grow():
	var TW = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	TW.tween_property(
			my_small_sprite, 'scale', my_small_sprite.scale * 2, .5
	)

	TW.tween_property(
			my_small_sprite, 'position', my_small_sprite.position + (Vector2.UP * 29), .5
	)
	Sounds.play_sound(Globals.SOUND_NAME_GROW)
	await TW.finished

	my_small_collider.disabled = true
	my_small_sprite.hide()
	my_big_collider.disabled = false
	my_big_sprite.show()

func _on_area_2d_body_entered(_body):
	if fed: return
	my_animation_player.play("angry_face")


func _on_area_2d_body_exited(_body):
	if fed: return
	my_animation_player.play("neutral_face")


func _on_proximity_detection_area_body_entered(body):
	if fed: return
	if not body is Player: return
	body = body as Player
	player_in_proximity = body
	if body.has_burger:
		my_animation_player.play("happy_face")
	else:
		my_animation_player.play("friendly_face")


func _on_proximity_detection_area_body_exited(body):
	if fed: return
	if not body is Player: return
	body = body as Player
	player_in_proximity = null
	my_animation_player.play("neutral_face")
