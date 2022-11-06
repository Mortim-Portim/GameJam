extends KinematicBody2D

signal killed(lastCheck)

export var active = true
export var GRAVITY = 900
export var levitation_gas_force = 150
export var levitation_gas_max_speed = 200
export var MAX_SPEED = 400
export var MAX_ICE_SPEED = 600
export var JUMP_SPEED = 600
export var ACCEL = 10
export var DEACCEL= 40
export var Ice_Deaccel = 0.001
export var Ice_Accel = 40
export var max_time_in_ice_form = 10
export var gas_fall_vel_max = 400

var temps =  [159, 337, 12]

var gas_is_sucked = false
var sprites = []
var state = 0
var currentSprite = AnimatedSprite.new()

var last_dir = Vector2.LEFT
var dir = Vector2.LEFT
var vel = Vector2.ZERO
var jumping = false
var time_since_jumpstart = 0
var left_ground = false
var running = false
var was_running = false
var LastCheckPoint = Vector2.ZERO

var landing = false
var time_since_landed = 0
var landing_anim_time = 0.15

var time_since_ice = 0
var ice_to_water_start = false

func _ready():
	sprites.append(get_node("WaterSprite"))
	sprites.append(get_node("IceSprite"))
	sprites.append(get_node("GasSprite"))
	currentSprite = sprites[state]
	update_sprite_from_state()
	$CanvasLayer/Control/TextureRect/TextureRect2.rect_position.y = temps[state]

func grounded():
	return $GroundChecker1.is_colliding() or $GroundChecker2.is_colliding() or $GroundChecker3.is_colliding()
func Wall_left():
	return $WallChecker1.is_colliding()
func Wall_right():
	return $WallChecker2.is_colliding()

func _physics_process(delta):
	if active:
		process_input(delta)
		process_movement(delta)

func process_input(delta):
	if Input.is_key_pressed(KEY_R):
		kill()
	dir = Vector2.ZERO
	if Input.is_action_pressed("move_left") and !Wall_left():
		dir += Vector2.LEFT
	if Input.is_action_pressed("move_right") and !Wall_right():
		dir += Vector2.RIGHT
	if !dir.is_equal_approx(Vector2.ZERO) and !dir.is_equal_approx(last_dir):
		if dir.is_equal_approx(Vector2.LEFT):
			currentSprite.flip_h=false
		else:
			currentSprite.flip_h=true
	if !running and !dir.is_equal_approx(Vector2.ZERO):
		running = true
		_on_running_start()
	if running and dir.is_equal_approx(Vector2.ZERO):
		running = false
		_on_running_end()
	
	if jumping:
		time_since_jumpstart += delta
	if jumping and !left_ground:
		left_ground = !grounded()
		if !left_ground and ($CeillingChecker1.is_colliding() or $CeillingChecker2.is_colliding()):
			jumping = false
			left_ground = false
			currentSprite.play("idle")
	if jumping and left_ground:
		if grounded():
			jumping = false
			left_ground = false
			_on_jump_end()
	elif time_since_jumpstart > 8:
		jumping = false
		left_ground = false
		currentSprite.play("idle")
	if grounded() and !jumping and state != 2:
		if Input.is_action_just_pressed("jump"):
			vel.y = -JUMP_SPEED
			jumping = true
			time_since_jumpstart = 0
			left_ground = false
			_on_jump_start()
	
	if landing:
		time_since_landed += delta
		if time_since_landed > landing_anim_time:
			_on_landed()
			landing = false
	
	if state == 1:
		time_since_ice += delta
		if time_since_ice > 1:
			if !ice_to_water_start:
				ice_to_water_start = true
				print("playing")
				$CanvasLayer/Control/AnimationPlayer.play("IceWater", -1, 1/float(max_time_in_ice_form-1))
		if time_since_ice > max_time_in_ice_form:
			$CanvasLayer/Control/AnimationPlayer.playback_speed=1
			to_water(false)
	
	last_dir = dir

func process_movement(delta):
	if state == 2:
		if gas_is_sucked:
			vel.y += delta * GRAVITY
			if vel.y > gas_fall_vel_max:
				vel.y = gas_fall_vel_max
		else:
			vel.y -= delta * levitation_gas_force
			if vel.y < -levitation_gas_max_speed:
				vel.y = -levitation_gas_max_speed
	else:
		vel.y += delta * GRAVITY
	
	var target_vel = dir*MAX_SPEED
	if state == 1:
		target_vel = dir*MAX_ICE_SPEED
	target_vel.y = vel.y
	
	var accel = ACCEL
	if state == 1:
		accel = Ice_Accel
	if dir.length_squared() < 0.5:
		if state == 1:
			accel = Ice_Deaccel
		else:
			accel = DEACCEL
	var n_vel = vel.linear_interpolate(target_vel, accel*delta)
	n_vel.y = vel.y
	vel = move_and_slide(n_vel, Vector2.UP, true, 4, 0.78, false)

func _on_jump_start():
	was_running = running
	if running:
		_on_running_end()
	currentSprite.play("jump")
	if randi()%2 == 0:
		$JumpSound1.play()
	else:
		$JumpSound2.play()

func _on_jump_end():
	currentSprite.play("jump", true)
	landing = true
	time_since_landed = 0

func _on_landed():
	if abs(vel.x) > 1:
		_on_running_start()
	else:
		_on_running_end()

func _on_running_start():
	if !jumping and !(currentSprite.playing and currentSprite.animation == "running"):
		currentSprite.play("running")
	$RunningSound.play()
func _on_running_end():
	if !jumping:
		currentSprite.play("idle")
	$RunningSound.stop()


func _on_Hitbox_area_entered(area):
	var grps = area.get_groups()
	check_group_kill(grps)
	if grps.has("CheckPoint"):
		LastCheckPoint = area.position
	if grps.has("0") and state != 0:
		to_water()
	if grps.has("1") and state != 1:
		to_ice()
	if grps.has("2") and state != 2:
		to_gas()
	if grps.has("Sucker") and state != 1:
		kill()
	if grps.has("GasFall") and state == 2:
		gas_is_sucked = true

func _on_Hitbox_area_exited(area):
	var grps = area.get_groups()
	if grps.has("GasFall"):
		gas_is_sucked = false

func to_water(play_anim=true):
	if play_anim:
		if state == 1:
			$CanvasLayer/Control/AnimationPlayer.play("IceWater")
		elif state == 2:
			$CanvasLayer/Control/AnimationPlayer.play_backwards("WaterGas")
	$ToWaterSound.play()
	state = 0
	update_sprite_from_state()

func to_ice(play_anim=true):
	if play_anim:
		if state == 0:
			$CanvasLayer/Control/AnimationPlayer.play_backwards("IceWater")
		elif state == 2:
			$CanvasLayer/Control/AnimationPlayer.play_backwards("IceGas")
	$ToIceSound.play()
	state = 1
	time_since_ice = 0
	ice_to_water_start = false
	update_sprite_from_state()

func to_gas(play_anim=true):
	if play_anim:
		if state == 0:
			$CanvasLayer/Control/AnimationPlayer.play("WaterGas")
		elif state == 1:
			$CanvasLayer/Control/AnimationPlayer.play("IceGas")
	jumping = false
	left_ground = false
	landing = false
	vel = vel*0.3
	_on_landed()
	$ToGasSound.play()
	state = 2
	update_sprite_from_state()

func _on_Hitbox_body_entered(body):
	var grps = body.get_groups()
	check_group_kill(grps)

func check_group_kill(grps):
	if grps.has("Killer"):
		kill()
	elif grps.has("Killer0") and state == 0:
		kill()
	elif grps.has("Killer1") and state == 1:
		kill()
	elif grps.has("Killer2") and state == 2:
		kill()

func kill():
	currentSprite.play("death")
	$Death.play()

func update_sprite_from_state():
	var flh = currentSprite.flip_h
	var ani = currentSprite.animation
	$WaterSprite.visible = state == 0
	$IceSprite.visible = state == 1
	$GasSprite.visible = state == 2
	currentSprite = sprites[state]
	currentSprite.flip_h = flh
	currentSprite.play(ani)

func spawn(pos):
	$SpawnSound.play()
	LastCheckPoint = pos
	position = LastCheckPoint
	vel = Vector2.ZERO


func _on_Death_finished():
	emit_signal("killed", LastCheckPoint)
	queue_free()
