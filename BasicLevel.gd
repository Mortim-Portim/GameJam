extends Node2D

signal finished(state)

onready var player_instance = preload("res://Player.tscn")

func initialize(state):
	$Player.state = state
	$Player.spawn($Spawn.position)
	$Player.update_sprite_from_state()

func _on_Player_killed(lastCheck):
	$DeathSound.play()
	call_deferred("_respawn_player", lastCheck)

func _respawn_player(lastCheck):
	remove_child(get_node("Player"))
	print("killed")
	var new_player = player_instance.instance()
	new_player.name = "Player"
	add_child(new_player)
	new_player.position = lastCheck
	new_player.LastCheckPoint = lastCheck
	new_player.get_node("Camera2D").current = true
	new_player.connect("killed", self, "_on_Player_killed")


func _on_Goal_finished():
	emit_signal("finished", get_node("Player").state)
	queue_free()
