@tool
extends TileMap
class_name Level

@onready var spawn_point : Marker2D = $SpawnPoint
@onready var completion_area : Area2D = $CompletionArea
@onready var insta_death_area : Area2D = $InstaDeathArea
signal completed
signal player_in_instadeath_area

func _ready():
	# EDITOR CODE
	assert(
			spawn_point != null and spawn_point is Marker2D, 
			"Spawn Point Set Up is Bad"
	)

	assert(
			completion_area != null and completion_area is Area2D, 
			"Completion Area Set Up is Bad"
	)

	assert(
			insta_death_area != null and insta_death_area is Area2D, 
			"Insta Death Area Set Up is Bad"
	)
	

	
	if Engine.is_editor_hint():
		return

	# GAME CODE
	completion_area.connect(
			"body_entered", self.level_completed
	)
	
	insta_death_area.connect(
			"body_entered", self._on_insta_death_area_body_entered
	)

func get_spawn_point():
	if Engine.is_editor_hint(): return
	return self.spawn_point.position


func level_completed(body):
	if Engine.is_editor_hint(): return
	if body is Player:
		print("level completed")
		emit_signal("completed")


func _on_insta_death_area_body_entered(body):
	if Engine.is_editor_hint(): return
	emit_signal("player_in_instadeath_area", body)


func _get_configuration_warnings():
	var warnings : Array[String] = []
	var found_completion = completion_area !=  null
	var found_spawnpoint = spawn_point !=  null
	var found_instadeath = insta_death_area !=  null
	
	if not found_completion:
		warnings.append("No completion area set up")
	if not found_spawnpoint:
		warnings.append("No spawnpoint set")
	if not insta_death_area:
		warnings.append("No instadeath area set up")
		
	return warnings
