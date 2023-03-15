extends Control
class_name DebugStateLabelContainer

@onready var my_label := $LabelState
@onready var my_velocity_label := $LabelVelocity

var state_to_label_map := {
	'idle':'STATE: idle',
	'walk':'STATE: WALK',
	'jump':'STATE: JUMP',
	'double_jump':'STATE: DOUBLE_JUMP',
	'floating':'STATE: FLOATING',
	'falling':'STATE: FALLING',
	'defeated': 'STATE: DED LOL'
}


func match_label(state: String):
	my_label.text = state_to_label_map[state]
	
func match_velocity(velocity : Vector2):
	my_velocity_label.text = str(velocity)
