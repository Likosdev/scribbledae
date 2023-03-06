extends Resource

class_name NamedFX

@export var name : String
@export var fx : PackedScene

func _init(p_name : String = "unknown", p_fx : PackedScene = null):
	name = p_name
	fx = p_fx
