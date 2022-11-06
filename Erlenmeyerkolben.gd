extends KinematicBody2D

export (NodePath) var player_path
export var MAX_SPEED = 400
export var MAX_XDIS = 1000
export var MAX_YDIS = 200
export var GRAVITY = 900
export var accel = 0.5
export var suck_dis = 300

var player = Node.new()
var dir = Vector2.ZERO
var vel = Vector2.ZERO
var ded =false
var running = false
var sucking = false

var sucking_pos = 1

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	var xdis = abs(player.position.x - position.x)
	if xdis > 40 and xdis < MAX_XDIS and abs(player.position.y - position.y) < MAX_YDIS:
		if player.position.x > position.x:
			change_dir(Vector2(1,0))
		else:
			change_dir(Vector2(-1,0))
	if player.state == 1:
		if !ded:
			if $Ded.is_colliding() or $Ded2.is_colliding():
				ded = true
				$Death.play()
				$AnimatedSprite.stop()
				visible = false
				$CollisionPolygon2D.disabled = true
	if !sucking and xdis < suck_dis:
		sucking = true
		start_suck()
	if sucking and xdis > suck_dis:
		sucking = false
		stop_suck()
	
	if sucking:
		if $LeftIsPlayer.get_overlapping_areas().size() == 1:
			change_sucking_pos(0)
		elif $RightIsPlayer.get_overlapping_areas().size() == 1:
			change_sucking_pos(2)
		elif $TopIsPlayer.get_overlapping_areas().size() == 1:
			change_sucking_pos(1)
	
	if !is_on_floor():
		vel.y += delta * GRAVITY
	if !is_on_wall():
		if !($Right.is_colliding() and dir.x > 0) and !($Left.is_colliding() and dir.x < 0):
			vel.x = lerp(vel.x, dir.x*MAX_SPEED, accel)
		else:
			vel.x = 0
	if xdis < suck_dis:
		vel.x = 0
	
	var v = abs(vel.x)
	if running and v < 20:
		running = false
		start_idle()
	if !running and v > 20:
		start_running()
		running = true
	
	vel = move_and_slide(vel, Vector2.UP, true, 4, 0.78, false)

func start_idle():
	print("start_idle")
	$Running.stop()
	if !sucking:
		$AnimatedSprite.play("idle")
func start_running():
	print("start_running")
	if !sucking:
		$Running.play()
		$AnimatedSprite.play("running")
func change_dir(ndir):
	if dir == ndir or ndir.is_equal_approx(Vector2.ZERO):
		return
	print("change_dir")
	$AnimatedSprite.flip_h = ndir.x > 0
	dir = ndir

func start_suck():
	print("start_suck")
	$Sucking.play()
	$AnimatedSprite.play("sucking")
	$AnimatedSprite.playing = false
	$Sucker.visible = true
	$Sucker/Area2D/CollisionPolygon2D.disabled = false
	
func stop_suck():
	print("stop_suck")
	$Sucking.stop()
	$Sucker.visible = false
	$Sucker/Area2D/CollisionPolygon2D.disabled = true

func _on_Death_finished():
	queue_free()

func change_sucking_pos(p):
	if p != sucking_pos:
		print("sucking: ", p)
		if sucking_pos == 0:
			if p == 1:
				$AnimationPlayer.play_backwards("TopLeft")
			elif p == 2:
				$AnimationPlayer.play_backwards("TopLeft")
				$AnimationPlayer.queue("TopRight")
		elif sucking_pos == 1:
			if p == 0:
				$AnimationPlayer.play("TopLeft")
			elif p == 2:
				$AnimationPlayer.play("TopRight")
		elif sucking_pos == 2:
			if p == 0:
				$AnimationPlayer.play_backwards("TopRight")
				$AnimationPlayer.queue("TopLeft")
			elif p == 1:
				$AnimationPlayer.play_backwards("TopRight")
		sucking_pos = p
	else:
		if p == 1:
			$AnimatedSprite.frame=0
		else:
			$AnimatedSprite.frame=2
