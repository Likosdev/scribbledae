extends CharacterBody2D
class_name Player

@export var SPEED = 150.0
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumping = false
var floating = false
var knockback = false
var jumps_left = 2


var health : int = 3
const MAX_HEALTH = 3

@onready var my_knockback_timer := $KnockbackTimer
@onready var my_animation_player := $AnimationPlayer
@onready var my_sprite := $Sprite2D
@onready var my_umbrella_sprite := $Umbrella
@onready var my_umbrella_animation_player := $Umbrella/AnimationPlayer

signal health_changed(new_health : int)
signal player_defeated

func _physics_process(delta):
	if health <= 0: 
		velocity.y += (gravity * delta)
		move_and_slide()
		return
	
	if knockback:
		velocity.y += (gravity * delta)
		move_and_slide()
		return
	
	if not is_on_floor():
		if not floating and Input.is_action_pressed("jump"):
			my_umbrella_animation_player.play("open")
			floating = true
			
		velocity.y += gravity * delta if not floating else gravity * delta / 2
		if velocity.y > 10:
			my_animation_player.play("fall")
			velocity.y += 3
			jumping = false

	if Input.is_action_just_pressed("jump") and (is_on_floor() or jumps_left > 0):
		my_animation_player.play("jump")
		jumping = true
		jumps_left -= 1
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		my_sprite.flip_h = velocity.x <= 0
		if is_on_floor() and not jumping: 
			my_animation_player.play("walk")
			if floating: 
				floating = false
				my_umbrella_animation_player.play("close")
			jumps_left = 2

	else:
		if is_on_floor() and not jumping: 
			my_animation_player.play("idle")
			jumps_left = 2
			if floating: 
				floating = false
				my_umbrella_animation_player.play("close")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	my_sprite.position= Vector2(roundi(my_sprite.position.x), roundi(my_sprite.position.y))

func take_damage():
	health -= 1
	var TW = create_tween().set_parallel()
	TW.tween_property(my_sprite, 'self_modulate', Color.RED, .1)
	TW.chain().tween_property(my_sprite, 'self_modulate', Color.WHITE, .1)
	#my_animation_player.play("hurt")
	
	emit_signal("health_changed", health)
	#await my_animation_player.animation_finished
	#my_animation_player.stop()
	if health == 0:
		await TW.finished
		emit_signal("player_defeated")
		$CollisionShape2D.disabled = true
		
		

func heal(amount: int):
	health = clampi(health + amount,0, MAX_HEALTH)
	emit_signal("health_changed", health)

func apply_knockback(bounce : bool = true):
	if not knockback:
			knockback = true
			my_knockback_timer.start()
			
			velocity.y = -300
			velocity.x = -velocity.x if bounce else velocity.x
			await my_knockback_timer.timeout
			knockback = false

	


func _on_hurt_box_area_entered(area):
	if area.owner is Hunter_A:
		apply_knockback(false)


func _on_hit_box_area_entered(area):
	if area.owner is Hunter_A:
		if area.owner.can_damage:
			apply_knockback()
			take_damage()
