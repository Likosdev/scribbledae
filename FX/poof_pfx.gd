extends GPUParticles2D



func _ready():
	self.emitting = true
	self.one_shot = true
	$Timer.start()
	pass


func _on_timer_timeout():
	queue_free()
