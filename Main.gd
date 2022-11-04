extends Node2D

var Level1 = preload("res://Level1.tscn")

func _ready():
	randomize()

func _on_Play_pressed():
	var lvl1 = Level1.instance()
	add_child(lvl1)
	$CanvasLayer/MMenu.visible = false

func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	pass # Replace with function body.
