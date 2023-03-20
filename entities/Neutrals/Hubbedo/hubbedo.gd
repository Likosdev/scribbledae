extends AnimatableBody2D
class_name Hubbedo

@onready var my_small_face := $SpriteSmall/FaceSpriteSmall
@onready var my_big_face := $SpriteBig/FaceSpriteBig

@onready var my_animation_player := $AnimationPlayer



func _on_area_2d_body_entered(body):
	my_animation_player.play("angry_face")


func _on_area_2d_body_exited(body):
	my_animation_player.play("neutral_face")
