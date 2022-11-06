extends Node2D

signal finished(state)
signal reload(state)

onready var player_instance = preload("res://Player.tscn")

func initialize(state):
	$Player.state = state
	$Player.spawn($Spawn.position)
	$Player.update_sprite_from_state()

func reload_after_death(state, lastCheck):
	$Player.state = state
	$Player.position = lastCheck
	$Player.LastCheckPoint = lastCheck
	$Player.get_node("Camera2D").current = true
	$Player._ready()

func _on_Player_killed(lastCheck):
	emit_signal("reload", $Player.state, lastCheck)
	queue_free()

func _on_Goal_finished():
	emit_signal("finished", $Player.state)
	queue_free()
