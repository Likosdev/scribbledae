extends Node
class_name SoundPlayer

@onready var soundplayers = {
	Globals.SOUND_NAME_COLLECT: $AudioPlayers/COLLECT as AudioStreamPlayer,
	Globals.SOUND_NAME_JUMP: $AudioPlayers/JUMP as AudioStreamPlayer,
	Globals.SOUND_NAME_DEFEAT: $AudioPlayers/DEFEAT as AudioStreamPlayer,
	Globals.SOUND_NAME_UMBRELLA_OPEN: $AudioPlayers/UMBRELLA_OPEN as AudioStreamPlayer,
	Globals.SOUND_NAME_UMBRELLA_CLOSE: $AudioPlayers/UMBRELLA_CLOSE as AudioStreamPlayer,
	Globals.SOUND_NAME_TAKE_DAMAGE: $AudioPlayers/TAKE_DAMAGE as AudioStreamPlayer,
	Globals.SOUND_NAME_HEAL: $AudioPlayers/HEAL as AudioStreamPlayer,
	Globals.SOUND_NAME_ENEMY_DEFEATED: $AudioPlayers/ENEMY_DEFEATED as AudioStreamPlayer,
	Globals.SOUND_NAME_BUMP: $AudioPlayers/BUMP as AudioStreamPlayer,
	Globals.SOUND_NAME_LOOSE_ITEM : $AudioPlayers/LOOSE_ITEM as AudioStreamPlayer,
	Globals.SOUND_NAME_GROW : $AudioPlayers/GROW as AudioStreamPlayer,
	Globals.SOUND_NAME_FEED : $AudioPlayers/FEED as AudioStreamPlayer,
	Globals.SOUND_NAME_STEP : $AudioPlayers/STEP as AudioStreamPlayer,
	
}


func play_sound(p_name : String, random_pitch := false):

	if p_name in soundplayers.keys():
		var sp : AudioStreamPlayer = soundplayers[p_name]
		if random_pitch:
			sp.pitch_scale += randf_range(-.1, .1)
			
		sp.play()
		await sp.finished
		if random_pitch: sp.pitch_scale = 1
		
		
	else:
		print("NO SUCH SOUND SET UP")
