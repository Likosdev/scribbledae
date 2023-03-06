extends Node

@export var TileMaps : Array[PackedScene]
@export var PlayerScene : PackedScene
# Called when the node enters the scene tree for the first time.

@onready var main_camera : MainCamera = $MainCamera
@onready var canvas_layer_0 : CanvasLayer = $CanvasLayer
@onready var background_noise : NoiseTexture2D = $CanvasLayer/BackgroundNoise.texture
@onready var my_hud : HUD = $Hudlayer/HUD
@onready var my_fx_spawner : FX = $FX

var current_level : Level = null
var current_level_index : int = 0
var current_player_instance : Player = null


enum GameState {loading, running, pause_menu, main_menu}

var current_game_state : GameState = GameState.loading

func _ready():
	init_run()

func spawn_level_by_index(index:int) -> Level:
	return TileMaps[index].instantiate()

func spawn_player() -> Player:
	return PlayerScene.instantiate()

func despawn_level() -> bool:
	var level = current_level
	if level == null: return false # could not despawn, return false
	
	for pickup in get_tree().get_nodes_in_group('health_pickups'):
		var p = pickup as HealthPickup
		p.disconnect("collected", self.on_health_pickup_collected)
		
	current_level.disconnect('completed', self.on_level_completed)
	current_level.disconnect("player_in_instadeath_area", self.on_insta_death_area_entered)
	current_level = null # remove reference
	level.queue_free() # despawn
	return true

func despawn_player()-> bool:
	var player = current_player_instance
	if player == null: return false
	player.disconnect("health_changed", my_hud.on_player_health_changed)
	current_player_instance = null
	player.queue_free()
	return true

func get_current_level_spawn_position() -> Vector2:
	if current_level: 
		return current_level.get_spawn_point()
	else:
		return Vector2.ZERO

func init_run():
	current_level = spawn_level_by_index(current_level_index)
	current_player_instance = spawn_player()
	attach_player_and_level()
	attach_camera()
	current_game_state = GameState.running

func _physics_process(delta):
	match current_game_state:
		GameState.loading:
			pass
		GameState.running:
			var offset_x:float = main_camera.position.x * delta * 15
			var offset_y:float = main_camera.position.y * delta * 15
			background_noise.noise.set_offset(Vector3(offset_x,offset_y, 0.0))

func attach_camera():
	main_camera.set_target_player(current_player_instance)

func attach_player_and_level() -> bool:
	add_child(current_level)
	current_level.add_child(current_player_instance)
	current_player_instance.position = get_current_level_spawn_position()
	
	for pickup in get_tree().get_nodes_in_group('health_pickups'):
		var p = pickup as HealthPickup
		p.connect("collected", self.on_health_pickup_collected)
	
	current_player_instance.connect(
			'health_changed',my_hud.on_player_health_changed 
	)
	current_player_instance.connect("player_defeated", self.on_player_defeated)
	
	current_level.connect("player_in_instadeath_area", self.on_insta_death_area_entered)
	current_level.connect('completed', self.on_level_completed)
	
	my_fx_spawner.attach_current_level(current_level)
	return true

func next_level():
	current_game_state = GameState.loading
	current_level_index += 1
	if current_level_index > self.TileMaps.size() - 1:
		current_level_index = 0
	if despawn_level() and despawn_player():
		current_level = spawn_level_by_index(current_level_index)
		current_player_instance = spawn_player()
		var _success = attach_player_and_level()
		attach_camera()
		current_game_state = GameState.running


func on_level_completed():
	print("on level completed yayyyyy")
	call_deferred("next_level") 

func on_health_pickup_collected(position: Vector2):
	current_player_instance.heal(1)

func on_insta_death_area_entered(body : Player):
	reset_level()
		
func on_player_defeated():
	reset_level()
	
func reset_level():
	main_camera.stopped = true
	await get_tree().create_timer(2).timeout
	#current_player_instance.position = get_current_level_spawn_position()
	#current_player_instance.heal(3)
	get_tree().reload_current_scene()
	pass
