extends KinematicBody2D

export (NodePath) var player_path
export var MAX_DIS = 1000
export var GRAVITY = 900

var player = Node.new()
var dir = Vector2.ZERO
var vel = Vector2.ZERO

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	if player.position.distance_to(position) < MAX_DIS:
		print("aggressiv")
	
	if !is_on_floor():
		print("in the air")
		vel.y += delta * GRAVITY
	vel = move_and_slide(vel, Vector2.UP, true, 4, 0.78, false)
