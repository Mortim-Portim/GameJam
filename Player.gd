extends Node2D

export var active = true

func grounded():
	var bodies = $Area2D.get_overlapping_bodies()
	
