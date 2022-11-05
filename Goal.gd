extends Area2D


onready var tween_fade = get_node("Fade")
export var transition_duration = 0.5
export var transition_type = 0
var fade_out_player = null

func fade(stream_player1, stream_player2):
	stream_player2.volume_db = -80
	stream_player2.play()
	fade_out_player = stream_player1
	tween_fade.interpolate_property(stream_player1, "volume_db", MUSIC_VOLUME, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_fade.interpolate_property(stream_player2, "volume_db", -80, MUSIC_VOLUME, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_fade.start()

func _on_Fade_tween_all_completed():
	fade_out_player.stop()
	fade_out_player.volume_db = MUSIC_VOLUME

func _on_Area2D_area_entered(area):
	pass # Replace with function body.


func _on_Entered_finished():
	pass # Replace with function body.


func _on_Goal_area_entered(area):
	
