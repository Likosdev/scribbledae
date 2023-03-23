extends Node
class_name SpawnHandler


@export var Burger_Scene : PackedScene = null


func SpawnBurger(p_parent: Level, p_position: Vector2, _align_ground = true):
	var burger : Burger = Burger_Scene.instantiate()
	
	p_parent.call_deferred('add_child', burger)
	burger.position = p_position
	EventBus.burger_spawned.emit(burger.position, burger)

