extends Node2D

var DebugLevel = preload("res://DebugLevel.tscn")
var test_lvl = preload("res://level designs/test level.tscn")
var lvl3 = preload("res://level designs/Level3.tscn")

var level_nr = 0
var levels = [test_lvl, test_lvl, DebugLevel, DebugLevel]

var MUSIC_VOLUME = 0
var in_game = false

func _ready():
	randomize()
	_on_HSlider_value_changed(90)

func _input(event):
	if in_game:
		if event is InputEventKey and event.scancode == KEY_ESCAPE and event.pressed == false:
			var lvl = get_node("Level"+String(level_nr))
			remove_child(lvl)
			lvl.queue_free()
			in_game = false
			$CanvasLayer/MMenu.visible = true
			fade($InGameSoundtrack, $MainMenuSoundtrack)

func _on_Play_pressed():
	load_level(0)
	in_game = true
	$CanvasLayer/MMenu.visible = false
	fade($MainMenuSoundtrack, $InGameSoundtrack)

func load_level(state):
	print("loading level: ", level_nr)
	print("state: ", state)
	var lvl = levels[level_nr].instance()
	lvl.name = "Level"+String(level_nr)
	add_child(lvl)
	lvl.initialize(state)
	lvl.connect("finished", self, "_on_level_finished")

func _on_Settings_pressed():
	$CanvasLayer/MMenu.visible = false
	$CanvasLayer/SettingsMenu.visible = true

func _on_Credits_pressed():
	pass

func _on_BackToMenu_pressed():
	$CanvasLayer/MMenu.visible = true
	$CanvasLayer/SettingsMenu.visible = false

func _on_TextureButton_pressed():
	var lvl = DebugLevel.instance()
	lvl.name = "Level"+String(level_nr)
	add_child(lvl)
	lvl.connect("finished", self, "_on_level_finished")
	in_game = true
	$CanvasLayer/MMenu.visible = false
	fade($MainMenuSoundtrack, $InGameSoundtrack)

func _on_level_finished(state):
	level_nr += 1
	load_level(state)

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

func play_click_sound():
	if randi()%2 == 0:
		$ClickSound1.play()
	else:
		$ClickSound2.play()

func _on_button_down():
	play_click_sound()

func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), ((2-2/(sqrt(value/90)+1)-1)*90 ))
