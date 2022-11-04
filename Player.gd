extends KinematicBody2D

export var active = true
export var GRAVITY = 700
export var MAX_SPEED = 400
export var JUMP_SPEED = 600
export var ACCEL = 10
export var DEACCEL= 40

var dir = Vector2.LEFT
var vel = Vector2.ZERO
var jumping = false
var left_ground = false

func grounded():
	return $GroundChecker1.is_colliding() or $GroundChecker2.is_colliding()

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
			_on_jump_end()
	if grounded() and !jumping:
		if Input.is_action_just_pressed("jump"):
			vel.y = -JUMP_SPEED
			jumping = true
			left_ground = false
			_on_jump_start()

func process_movement(delta):
	if !grounded():
		vel.y += delta * GRAVITY
	
	var target_vel = dir*MAX_SPEED
	target_vel.y = vel.y
	
	var accel = ACCEL
	if dir.length_squared() < 0.5:
		accel = DEACCEL
	var n_vel = vel.linear_interpolate(target_vel, accel*delta)
	n_vel.y = vel.y
	vel = move_and_slide(n_vel, Vector2.UP)

func _on_jump_start():
	print("jump start")
	if randi()%2 == 0:
		$JumpSound1.play()
	else:
		$JumpSound2.play()

func _on_jump_end():
	print("jump end")
	pass
