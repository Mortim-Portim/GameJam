extends Node2D

signal finished()

onready var ent = get_node("Entered")

func _on_Entered_finished():
	emit_signal("finished")

func _on_GoalArea_area_entered(_a):
	ent.play()
