extends Node2D

var Level1 = preload("res://Level1.tscn")

var MUSIC_VOLUME = 0

func _ready():
	randomize()

func _on_Play_pressed():
	var lvl1 = Level1.instance()
	add_child(lvl1)
	$CanvasLayer/MMenu.visible = false
	fade($MainMenuSoundtrack, $InGameSoundtrack)

func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	pass # Replace with function body.

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
