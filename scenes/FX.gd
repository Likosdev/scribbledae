extends Node
class_name FX

@export var FXS : Array[NamedFX] = []

var current_level : Level = null

func _ready():
	EventBus.connect('enemie_defeated', on_enemy_defeated)


func on_enemy_defeated(p_position : Vector2):
	spawn_fx_by_name('poof', p_position)
	

func attach_current_level(level: Level):
	self.current_level = level

func get_fx_by_name(p_name : String) -> NamedFX:
	for fx in FXS:
		if fx.name == p_name:
			return fx
	
	return null
	
	


func spawn_fx_by_name(p_name:String, p_position:Vector2):
	var named_fx = get_fx_by_name(p_name)

	if current_level:
		var fx_instance = named_fx.fx.instantiate()
		fx_instance.position = p_position
		current_level.add_child(fx_instance)
		
	
	
