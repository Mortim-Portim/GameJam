extends Node2D

var player = Node.new()
var destination = Position2D.new()

var enabled = true
var time_since_last = 0
var abklingzeit = 0.2

func _physics_process(delta):
	if !enabled:
		time_since_last += delta
		if time_since_last > abklingzeit:
			enabled = true

func _on_Area2D_area_entered(area):
	if !enabled:
		return
	player = area.get_parent()
	player.visible = false
	destination = $Area2D2.global_position
	$AnimatedSprite.play("Flowing")

func _on_Area2D2_area_entered(area):
	if !enabled:
		return
	player = area.get_parent()
	player.visible = false
	destination = $Area2D.global_position
	$AnimatedSprite.play("Flowing", true)


func _on_AnimatedSprite_animation_finished():
	enabled = false
	time_since_last = 0
	player.visible = true
	player.position = destination
