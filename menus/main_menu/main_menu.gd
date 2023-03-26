extends Control

class_name MainMenu

signal new_game_pressed
signal load_game_pressed
signal options_pressed
signal quit_pressed


@export var button_hover_scale_multiplier := 1.5
@export var button_hover_duration := 0.3
@onready var my_button_container := $PanelContainer/Panel

func _ready():
	# connect_button_tweens()
	self.position = Vector2.ZERO
	pass

func _on_button_new_game_pressed():
	self.new_game_pressed.emit()


func _on_button_continue_pressed():
	self.load_game_pressed.emit()


func _on_button_options_pressed():
	self.options_pressed.emit()


func _on_button_quit_pressed():
	self.quit_pressed.emit()
	await get_tree().create_timer(.3).timeout
	get_tree().quit()


func connect_button_tweens():
	for b in my_button_container.get_children():
		if not b is Button : continue
		var btn : Button = b
		if btn: 
			btn.mouse_entered.connect(func():
					print("mouse entered" + str(btn))
					var tw = create_tween()
					tw.tween_property(
							btn, "scale", 
							Vector2.ONE * button_hover_scale_multiplier, 
							button_hover_duration
					)
			)
			btn.mouse_exited.connect(func():
					print("mouse entered" + str(btn))
					var tw = create_tween()
					tw.tween_property(
							btn, "scale", 
							Vector2.ONE, 
							button_hover_duration
					)
			)
	
"""
	rewrite as tween maybe
	var scale = Vector2(.5, .5)
	var button_size = self.get_size()
	var button_pos = self.get_global_pos()

	self.set_scale(scale)
	self.set_global_pos(button_pos + button_size * scale / 2)


"""
