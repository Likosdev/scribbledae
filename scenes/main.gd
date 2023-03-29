extends Node

enum GameState {loading,new_game, running, pause_menu, main_menu, init}
@export var current_game_state : GameState = GameState.init
@export var MainMenuScene: PackedScene
@export var TileMaps : Array[PackedScene]
@export var PlayerScene : PackedScene
@export_color_no_alpha var ScreenFaderColor : Color = Color.BLACK



@onready var main_camera : MainCamera = %MainCamera
@onready var my_hud : HUD = %HUD
@onready var my_screen_fader = %ScreenFader
@onready var my_fx_spawner : FX = $FX
@onready var my_spawn_handler : SpawnHandler = $SpawnHandler 
@onready var my_menu_layer := %MenuLayer


var current_level : Level = null
var current_level_index : int = 0
var current_player_instance : Player = null
var current_main_menu : MainMenu = null



func _ready():
	if current_game_state == GameState.init:
		change_game_state(GameState.main_menu)
	change_game_state(current_game_state)

func change_game_state(new_game_state : GameState):
	#if new_game_state == current_game_state: return
	
	if current_game_state == GameState.main_menu and current_main_menu != null:
		my_menu_layer.remove_child(current_main_menu)
		current_main_menu = null
	
	
	match new_game_state:
		GameState.main_menu:
			display_main_menu()
		GameState.new_game:
			run_first_level()
		
	current_game_state = new_game_state
	


func display_main_menu():
	if not current_main_menu:
		current_main_menu = MainMenuScene.instantiate()
		my_menu_layer.add_child(current_main_menu)
		current_main_menu.new_game_pressed.connect(run_first_level)
		current_main_menu.load_game_pressed.connect(
				func(): print("continue clicked")
		)

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

func run_first_level():
	change_game_state(GameState.running)
	EventBus.pickup_collected.connect(self.on_pickup_collected)
	EventBus.player_defeated.connect(self.on_player_defeated)
	EventBus.pickup_left.connect(self.on_pickup_left)
	my_screen_fader.color = ScreenFaderColor
	current_level = spawn_level_by_index(current_level_index)
	current_player_instance = spawn_player()
	attach_player_and_level()
	attach_camera()
	my_hud.display_level_announcement(
			current_level.WorldNumber, current_level.LevelNumber, current_level.LevelName
	)
	
	await my_hud.level_announcement_show
	await fade_in(.5)
	
	current_game_state = GameState.running

func on_pickup_collected(position: Vector2, pickup: String):
	print("Pickup {} Collected at {}".format([pickup, position], '{}'))
	

func fade_in(duration : float = 1):
	var TW = create_tween()
	TW.tween_property(my_screen_fader, "color", Color.TRANSPARENT, duration)
	await TW.finished
	return true
	
	
func fade_out():
	var TW = create_tween()
	TW.tween_property(my_screen_fader, "color", ScreenFaderColor, 1.0)
	await TW.finished
	return true

func _physics_process(_delta):
	match current_game_state:
		GameState.loading:
			pass
		GameState.running:
			pass

func attach_camera():
	main_camera.set_target_player(current_player_instance)

func attach_player_and_level() -> bool:
	add_child(current_level)
	current_player_instance.controllable = false
	current_level.add_child(current_player_instance)
	my_hud.level_announcement_done.connect(func(): current_player_instance.controllable = true)
	current_player_instance.position = get_current_level_spawn_position()
	
	for pickup in get_tree().get_nodes_in_group('health_pickups'):
		var p = pickup as HealthPickup
		p.connect("collected", self.on_health_pickup_collected)
	
	current_player_instance.connect(
			'health_changed',my_hud.on_player_health_changed 
	)
	
	
	current_level.connect("player_in_instadeath_area", self.on_insta_death_area_entered)
	current_level.connect('completed', self.on_level_completed)
	
	my_fx_spawner.attach_current_level(current_level)
	return true

func next_level():
	await fade_out()
	current_game_state = GameState.loading
	current_level_index += 1
	if current_level_index > self.TileMaps.size() - 1:
		current_level_index = 0
	if despawn_level() and despawn_player():
		current_level = spawn_level_by_index(current_level_index)
		
		current_player_instance = spawn_player()
		var _success = attach_player_and_level()
		my_hud.display_level_announcement(
			current_level.WorldNumber, current_level.LevelNumber, current_level.LevelName
		)
		attach_camera()
		await my_hud.level_announcement_done
		fade_in(1)
		current_game_state = GameState.running


func on_level_completed():
	
	call_deferred("next_level")

func on_health_pickup_collected(_position: Vector2):
	current_player_instance.heal(1)

func on_insta_death_area_entered(_body : Player):
	await fade_out()
	await reset_level()
	await fade_in()
	
func on_player_defeated(_pos : Vector2):
	await fade_out()
	await reset_level()
	await fade_in()
	
func on_pickup_left(position: Vector2, pickup: String):
	match pickup:
		Globals.PICKUP_NAME_BURGER:
			my_spawn_handler.SpawnBurger(current_level, position)
	
	
func reset_level():
	main_camera.stopped = true
	
	await get_tree().create_timer(1).timeout
	
	despawn_player()
	despawn_level()
	current_level = spawn_level_by_index(current_level_index)
	current_player_instance = spawn_player()
	attach_player_and_level()
	attach_camera()


	EventBus.emit_signal("level_restart")
	current_player_instance.controllable = true
	main_camera.stopped = false
	return true

