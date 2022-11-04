extends Node2D

export var active = true
export var GRAVITY = -24.8
export var MAX_SPEED = 9
export var JUMP_SPEED = 10
export var ACCEL = 2.5
export var DEACCEL= 14

var dir = Vector2.LEFT
var vel = Vector2.ZERO
var jumping = false
var left_ground = false

func grounded():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.get_groups().has("Ground"):
			return true
	return false

func _physics_process(delta):
	if active:
		process_input(delta)
		process_movement(delta)

func process_input(delta):
	dir = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		dir += Vector2.RIGHT
	
	if jumping and !left_ground:
		left_ground = !grounded()
	if jumping and left_ground:
		if grounded():
			jumping = false
			left_ground = false
	if grounded() and !jumping:
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
			jumping = true
			left_ground = false

func process_movement(delta):
	if !grounded():
		vel.y += delta * GRAVITY
	
	var target_vel = dir*MAX_SPEED
	target_vel.y = vel.y
	
	if dir.length_squared() < 0.5:
		
	

func _on_jump_start():
	print("jump start")
	pass

func _on_jump_end():
	print("jump end")
	pass
