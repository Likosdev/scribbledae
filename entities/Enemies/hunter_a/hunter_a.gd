extends CharacterBody2D

class_name Hunter_A

@export var speed : float = 100.0



@onready var my_sprite = $AnimatedSprite2D
@onready var my_collision_shape = $CollisionShape2D
@onready var my_hitbox = $HitBox
@onready var my_hurtbox = $HurtBox
@onready var my_hit_shape = $HitBox/CollisionShape2D
@onready var my_hurt_shape = $HurtBox/CollisionShape2D

var direction = Vector2.LEFT


enum EnemyStates {MOVE,IDLE,TURN}
var enemy_state : EnemyStates = EnemyStates.IDLE
var can_damage : bool = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var transitioning : bool = false

signal defeated(position: Vector2)


func _ready():
	change_state(EnemyStates.MOVE)




func _physics_process(delta):
	velocity.y += gravity * delta
	
	if not transitioning: 
		match enemy_state:
			EnemyStates.MOVE:
				velocity.x = direction.x * speed
				move_and_slide()
			EnemyStates.IDLE:
				pass

			EnemyStates.TURN:
				change_state(EnemyStates.MOVE)

	

func change_state(new_state : EnemyStates):
	transitioning = true
	$TransitionTimer.start()
	
	match new_state: 
		EnemyStates.MOVE:
			await $TransitionTimer.timeout
			my_sprite.play("walk")
		EnemyStates.IDLE:
			my_sprite.play("idle")
			await $TransitionTimer.timeout
		EnemyStates.TURN:
			my_sprite.play("idle")
			direction.x = direction.x * -1
			position += direction * 3
			await $TransitionTimer.timeout

	enemy_state = new_state
	transitioning = false

func turn_on_abyss_or_wall():
	turn()

func turn():
	if transitioning: return
	my_sprite.flip_h = direction.x < 0
	change_state(EnemyStates.TURN)

func _on_wall_detector_wall_detected(_side, _what):
	turn_on_abyss_or_wall()

func _on_abyss_detector_abyss_detected(_side):
	turn_on_abyss_or_wall()


func _on_hurt_box_area_entered(area):
	if area.owner is Player:
		turn()


func _on_hit_box_area_entered(area : Area2D):
	if area.owner is Player and area.is_in_group('HurtBoxes'):
		Sounds.play_sound(Globals.SOUND_NAME_ENEMY_DEFEATED)
		emit_signal("defeated", self.position)
		EventBus.emit_signal('enemie_defeated', self.position)
		queue_free()
