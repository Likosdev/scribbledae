extends CharacterBody2D
class_name Player


# TODO:
"""
Floating State sometimes stays after land and close animation is not played


"""

enum PlayerStates {
	IDLE,
	WALKING,
	JUMPING,
	DOUBLE_JUMPING,
	FLOATING,
	FALLING,
	DEFEATED
}

var state_to_string_map = {
	PlayerStates.IDLE : "idle",
	PlayerStates.WALKING : "walk",
	PlayerStates.JUMPING : "jump",
	PlayerStates.DOUBLE_JUMPING : "double_jump",
	PlayerStates.FLOATING : "floating",
	PlayerStates.FALLING : 'falling',
	PlayerStates.DEFEATED: 'defeated'
}

@export var SPEED := 150.0
@export var JUMP_VELOCITY := -400
@export var KNOCKBACK_STRENGTH := -100
@export var I_TIME := 1.0 # seconds of invulnerability after damage ??


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumping := false
var floating := false
var knockback := false
var has_burger := false
var jumps_left := 2
var float_threshold := 0.5
var invulnerable := false
var controllable := true

var jump_held_delta := 0.0

var state := PlayerStates.IDLE

var health : int = 3
const MAX_HEALTH := 3

@onready var my_knockback_timer := $KnockbackTimer
@onready var my_animation_player := $AnimationPlayer
@onready var my_sprite := $Sprite2D
@onready var my_umbrella_sprite := $Umbrella
@onready var my_umbrella_animation_player := $Umbrella/AnimationPlayer
@onready var my_state_label_container := $DebugStateLabelContainer
@onready var my_burger_marker := %Burger

signal health_changed(new_health : int)
signal player_defeated

func _ready():
	EventBus.pickup_collected.connect(self.on_pickup_collected)

func _physics_process(delta):
	if not controllable: return

	my_process_new(delta)

func my_process_new(delta :float):
	var direction := Input.get_axis("left","right") \
		if not state == PlayerStates.DEFEATED \
		else 0.0
	
	
	if Input.is_action_pressed("jump"):
		jump_held_delta += delta
	else:
		jump_held_delta = 0.0
	
	match state:
		PlayerStates.DEFEATED:
			my_animation_player.play("dead")
			move_and_slide()
			display_state_and_velocity()
			
		PlayerStates.IDLE:
			if is_on_floor(): jumps_left = 2
			if direction and is_on_floor():
				state = PlayerStates.WALKING
			
			if Input.is_action_just_pressed("jump"):
				jumps_left -=1
				state = PlayerStates.JUMPING
				Sounds.play_sound(Globals.SOUND_NAME_JUMP)
				velocity.y += JUMP_VELOCITY
			
			my_animation_player.play('idle')	
			
				
		PlayerStates.WALKING:
			
			jumps_left = 2
			if not direction and is_on_floor():
				state = PlayerStates.IDLE
				

			if Input.is_action_just_pressed("jump"):
				jumps_left -= 1
				state = PlayerStates.JUMPING
				Sounds.play_sound(Globals.SOUND_NAME_JUMP)
				velocity.y = JUMP_VELOCITY
				
			my_animation_player.play("walk")
			
			
		PlayerStates.JUMPING:
			if is_on_floor():
				state = PlayerStates.IDLE
			
			if not has_burger and jump_held_delta > float_threshold and not knockback:
				state = PlayerStates.FLOATING
				my_umbrella_animation_player.play("open")
			elif Input.is_action_just_pressed("jump") and jumps_left > 0: 
				jumps_left -= 1
				state = PlayerStates.DOUBLE_JUMPING
				Sounds.play_sound(Globals.SOUND_NAME_JUMP)
				velocity.y = JUMP_VELOCITY
				
			if velocity.y > 10:
				state = PlayerStates.FALLING
			
			my_animation_player.play('jump')
			

		PlayerStates.DOUBLE_JUMPING:
			if is_on_floor():
				state = PlayerStates.IDLE
			
			if not has_burger and jump_held_delta > float_threshold / 2 and not knockback:
				my_umbrella_animation_player.play("open")
				state = PlayerStates.FLOATING
				Sounds.play_sound(Globals.SOUND_NAME_UMBRELLA_OPEN)
			
			if velocity.y > 10:
				state = PlayerStates.FALLING
				
			my_animation_player.play('jump')

		PlayerStates.FALLING:
			if not has_burger and jump_held_delta > float_threshold / 3 and not knockback:
				state = PlayerStates.FLOATING
				my_umbrella_animation_player.play("open")
				Sounds.play_sound(Globals.SOUND_NAME_UMBRELLA_OPEN)
			elif jumps_left > 0 and Input.is_action_just_pressed("jump"):
				state = PlayerStates.DOUBLE_JUMPING
				Sounds.play_sound(Globals.SOUND_NAME_JUMP)
				jumps_left -= 1
				velocity.y = JUMP_VELOCITY

			if is_on_floor():
				jump_held_delta = 0.0
				state = PlayerStates.IDLE

			my_animation_player.play('fall')

		PlayerStates.FLOATING:
			if Input.is_action_just_released("jump") or knockback or is_on_floor():
				jump_held_delta = 0.0
				my_umbrella_animation_player.play("close")
				Sounds.play_sound(Globals.SOUND_NAME_UMBRELLA_CLOSE)
				state = PlayerStates.IDLE  \
						if is_on_floor() \
						else PlayerStates.FALLING
				

			if is_on_floor():
				jump_held_delta = 0.0
				my_umbrella_animation_player.play("close")
				Sounds.play_sound(Globals.SOUND_NAME_UMBRELLA_CLOSE)
				state = PlayerStates.IDLE if velocity.x != 0 else PlayerStates.WALKING

			else:
				velocity.y = velocity.y * .75

	
	velocity.y += gravity * delta \
			if state != PlayerStates.FALLING \
			else gravity * 1.2 * delta 

	velocity.x = direction * SPEED if not knockback else velocity.x
	
	if state == PlayerStates.DEFEATED: return
	
	if has_burger and Input.is_action_just_pressed("interact"):
		handle_burger_loss()
	
	my_sprite.flip_h = direction < 0  \
			if not state == PlayerStates.IDLE and direction \
			else my_sprite.flip_h
	
	move_and_slide()
	display_state_and_velocity()
	#my_sprite.position = Vector2(roundi(my_sprite.position.x), roundi(my_sprite.position.y))


func display_state_and_velocity():
	my_state_label_container.match_label(state_to_string_map[state])
	my_state_label_container.match_velocity(velocity)

func take_damage():
	if invulnerable: return
	health -= 1
	invulnerable = true
	Sounds.play_sound(Globals.SOUND_NAME_TAKE_DAMAGE)
	var TW = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	TW.tween_property(my_sprite, 'self_modulate', Color.RED, I_TIME  / 2)
	TW.chain().tween_property(my_sprite, 'self_modulate', Color.WHITE, I_TIME / 2)
	
	if has_burger:
		handle_burger_loss()
	
	emit_signal("health_changed", health)

	if health == 0:
		state = PlayerStates.DEFEATED
		$CollisionShape2D.set_deferred("disabled", true)
		Sounds.play_sound(Globals.SOUND_NAME_DEFEAT)
		await TW.finished
		EventBus.emit_signal("player_defeated", self.global_position)
	else:	
		await TW.finished
		invulnerable = false

func heal(amount: int):
	health = clampi(health + amount,0, MAX_HEALTH)
	emit_signal("health_changed", health)
	Sounds.play_sound(Globals.SOUND_NAME_HEAL)
	EventBus.player_healed.emit(1)

func apply_knockback(dir : Vector2 = Vector2.ZERO):
	if not knockback and not state == PlayerStates.DEFEATED and not invulnerable:

		knockback = true
		state = PlayerStates.FALLING
		my_knockback_timer.start()

		dir *= KNOCKBACK_STRENGTH
		velocity.y = -dir.y if not is_on_floor() else dir.y
		velocity.x = -dir.x if is_on_floor() else velocity.x

		await my_knockback_timer.timeout

		if state == PlayerStates.DEFEATED: return
		knockback = false

func handle_burger_pickup():
	Sounds.play_sound(Globals.SOUND_NAME_COLLECT)
	has_burger = true
	my_burger_marker.show()

func handle_burger_deliver():
	Sounds.play_sound(Globals.SOUND_NAME_LOOSE_ITEM)
	has_burger = false
	my_burger_marker.hide()
	
func handle_burger_leave():
	Sounds.play_sound(Globals.SOUND_NAME_LOOSE_ITEM)
	has_burger = false
	my_burger_marker.hide()

func handle_burger_loss():
	Sounds.play_sound(Globals.SOUND_NAME_LOOSE_ITEM)
	handle_burger_leave()
	EventBus.pickup_left.emit(self.position, Globals.PICKUP_NAME_BURGER)

func play_walking_sound():
	Sounds.play_sound(Globals.SOUND_NAME_STEP, true)

func _on_hurt_box_area_entered(area : Area2D):
	var is_hurtable = area.is_in_group(Globals.GROUP_NAME_HITBOXES)
	if is_hurtable:
		var dir = Vector2(self.global_position - area.global_position).normalized()
		apply_knockback( dir)


func _on_hit_box_area_entered(area : Area2D):
	var is_hurter = area.is_in_group(Globals.GROUP_NAME_HURTBOXES)
	if is_hurter:
		var dir = Vector2(self.global_position - area.global_position).normalized()
		apply_knockback( dir)
		take_damage()


func on_pickup_collected(_p_position: Vector2, pickup : String):
	match pickup:
		Globals.PICKUP_NAME_BURGER:
			handle_burger_pickup()
		Globals.PICKUP_NAME_HEALTH:
			heal(1)

	
