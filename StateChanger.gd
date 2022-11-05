extends Area2D

export var state = 0

func _ready():
	add_to_group(String(state))
