extends Node2D

onready var player_instance = preload("res://Player.tscn")

func _ready():
	$Player.spawn($Spawn.position)

func _on_Player_killed(lastCheck):
	$DeathSound.play()
	print("killed")
	var new_player = player_instance.instance()
	new_player.name = "Player"
	call_deferred("_respawn_player", new_player, lastCheck)

func _respawn_player(new_player, lastCheck):
	add_child(new_player)
	new_player.position = lastCheck
	new_player.LastCheckPoint = lastCheck
	new_player.get_node("Camera2D").current = true
	new_player.connect("killed", self, "_on_Player_killed")
