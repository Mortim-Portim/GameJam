extends Spatial

export var active = true
export var GRAVITY = -24.8
export var MAX_SPEED = 9
export var JUMP_SPEED = 10
export var ACCEL = 2.5
export var DEACCEL= 14
export var MAX_SLOPE_ANGLE = 40
export var MOUSE_SENSITIVITY = 0.05
export var max_ground_dis = 0.05
export (NodePath) var player_path

var player = KinematicBody.new()
var dir = Vector3()
var vel = Vector3()

func activate():
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	$RayCast.set_cast_to(Vector3.DOWN*max_ground_dis)
	player = get_node(player_path)
	if active:
		activate()
	else:
		deactivate()

func _physics_process(delta):
	if active:
		process_input(delta)
		process_movement(delta)

func grounded():
	return $RayCast.is_colliding()

func process_input(delta):
	dir = Vector3()
	var cam_xform = $Camera.get_global_transform()
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("move_up"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_down"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x

	if player.grounded():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	if !player.grounded():
		vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = player.move_and_slide(vel, Vector3(0, 1, 0), false, 4, deg2rad(MAX_SLOPE_ANGLE), true)

func _input(event):
	if !active:
		pass
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotate_x(deg2rad(event.relative.y * -MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * -MOUSE_SENSITIVITY))

		var camera_rot = $Camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -89, 89)
		$Camera.rotation_degrees = camera_rot
