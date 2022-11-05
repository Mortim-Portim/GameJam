extends KinematicBody2D

export var active = true
export var GRAVITY = 900
export var MAX_SPEED = 400
export var JUMP_SPEED = 600
export var ACCEL = 10
export var DEACCEL= 40

var last_dir = Vector2.LEFT
var dir = Vector2.LEFT
var vel = Vector2.ZERO
var jumping = false
var left_ground = false
var running = false
var was_running = false

func grounded():
	return $GroundChecker1.is_colliding() or $GroundChecker2.is_colliding() or $GroundChecker3.is_colliding()

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
	if !dir.is_equal_approx(Vector2.ZERO) and !dir.is_equal_approx(last_dir):
		if dir.is_equal_approx(Vector2.LEFT):
			$AnimatedSprite.flip_h=false
		else:
			$AnimatedSprite.flip_h=true
	if !running and !dir.is_equal_approx(Vector2.ZERO):
		running = true
		_on_running_start()
	if running and dir.is_equal_approx(Vector2.ZERO):
		running = false
		_on_running_end()
	
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
	
	last_dir = dir

func process_movement(delta):
	vel.y += delta * GRAVITY
	
	var target_vel = dir*MAX_SPEED
	target_vel.y = vel.y
	
	var accel = ACCEL
	if dir.length_squared() < 0.5:
		accel = DEACCEL
	var n_vel = vel.linear_interpolate(target_vel, accel*delta)
	n_vel.y = vel.y
	vel = move_and_slide(n_vel, Vector2.UP, true, 4, 0.78, true)

func _on_jump_start():
	was_running = running
	if running:
		_on_running_end()
	$AnimatedSprite.play("jump")
	if randi()%2 == 0:
		$JumpSound1.play()
	else:
		$JumpSound2.play()

func _on_jump_end():
	$AnimatedSprite.play("idle")
	if was_running and abs(vel.x) > 1:
		_on_running_start()

func _on_running_start():
	if !jumping:
		$AnimatedSprite.play("running")
	$RunningSound.play()
func _on_running_end():
	if !jumping:
		$AnimatedSprite.play("idle")
	$RunningSound.stop()


func _on_Hitbox_area_entered(area):
	if area.get_groups().has("Killer"):
		kill()


func _on_Hitbox_body_entered(body):
	if body.get_groups().has("Killer"):
		kill()

func kill():
	print("Killed")
