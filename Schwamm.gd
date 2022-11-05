extends KinematicBody2D

export (NodePath) var player_path
export var MAX_SPEED = 400
export var MAX_XDIS = 1000
export var MAX_YDIS = 200
export var GRAVITY = 900
export var accel = 0.5

var player = Node.new()
var dir = Vector2.ZERO
var vel = Vector2.ZERO
var ded =false
var running = false

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	var dis = player.position.distance_to(position)
	if abs(player.position.x - position.x) < MAX_XDIS and abs(player.position.y - position.y) < MAX_YDIS:
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
				$CollisionShape2D.disabled = true
		if dis < 300:
			dir = Vector2.ZERO
	
	if !is_on_floor():
		vel.y += delta * GRAVITY
	if !is_on_wall():
		if !($Right.is_colliding() and dir.x > 0) and !($Left.is_colliding() and dir.x < 0):
			vel.x = lerp(vel.x, dir.x*MAX_SPEED, accel)
		else:
			vel.x = 0
	
	var v = vel.length_squared()
	if running and v < 60:
		running = false
		start_idle()
	if !running and v > 2:
		start_running()
		running = true
	
	vel = move_and_slide(vel, Vector2.UP, true, 4, 0.78, false)

func start_idle():
	$Running.stop()
	$AnimatedSprite.play("idle")
func start_running():
	$Running.play()
	$AnimatedSprite.play("running")
func change_dir(ndir):
	if dir == ndir or ndir.is_equal_approx(Vector2.ZERO):
		return
	$AnimatedSprite.flip_h = ndir.x > 0
	dir = ndir


func _on_Death_finished():
	queue_free()
