extends CharacterBody2D
class_name Player

@export var SPEED = 150.0
@export var JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumping = false
var knockback = false
var jumps_left = 2


var health : int = 3
const MAX_HEALTH = 3

@onready var my_knockback_timer = $KnockbackTimer
@onready var my_animation_player = $AnimationPlayer

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
		velocity.y += gravity * delta
		if velocity.y > 10:
			$AnimatedSprite2D.play("fall")
			velocity.y += 3
			jumping = false

	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or jumps_left > 0):
		$AnimatedSprite2D.play("jump")
		jumping = true
		jumps_left -= 1
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = velocity.x <= 0
		if is_on_floor() and not jumping: 
			$AnimatedSprite2D.play("walk")
			jumps_left = 2

	else:
		if is_on_floor() and not jumping: 
			$AnimatedSprite2D.play("idle")
			jumps_left = 2
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func take_damage():
	health -= 1
	my_animation_player.play("hurt")
	
	emit_signal("health_changed", health)
	await my_animation_player.animation_finished
	my_animation_player.stop()
	if health == 0:
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
