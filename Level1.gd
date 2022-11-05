extends Node2D

func _ready():
	$Player.spawn($Spawn.position)

