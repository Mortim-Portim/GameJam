extends Node2D

var active = true
export (NodePath) var stalagtit_path
var stalagtit = Node.new()

func _ready():
	stalagtit = get_node(stalagtit_path)

func _physics_process(_delta):
	if active:
		active = stalagtit.hanging
		if !active:
			$Particles2D.emitting = false
			$Particles2D2.emitting = false
			$Particles2D3.emitting = false
			$AudioStreamPlayer2D.stop()
