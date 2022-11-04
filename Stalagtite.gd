extends RigidBody2D

var fixed = true

func _physics_process(delta):
	if fixed:
		if $RayCast2D.is_colliding() or $RayCast2D2.is_colliding():
			print("falling")
			fixed = false
			$RayCast2D.enabled=false
			$RayCast2D2.enabled=false
			mode = RigidBody2D.MODE_RIGID
