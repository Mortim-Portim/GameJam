extends RigidBody2D

var hanging = true
var is_ground = false
var time_since_fall = 0
var is_killer = true

func _physics_process(delta):
	if hanging:
		if $RayCast2D.is_colliding() or $RayCast2D2.is_colliding():
			print("falling")
			hanging = false
			$RayCast2D.enabled=false
			$RayCast2D2.enabled=false
			mode = RigidBody2D.MODE_RIGID
	elif !is_ground:
		time_since_fall += delta
	if !hanging and is_killer and !is_ground and time_since_fall > 0.5:
		if linear_velocity.length_squared() < 50:
			remove_from_group("Killer")
			is_killer = false
	if !hanging and !is_ground and time_since_fall > 0.1:
		if linear_velocity.length_squared() < 0.01 and abs(angular_velocity) < 0.001:
			mode = RigidBody2D.MODE_STATIC
			add_to_group("Ground")
			is_ground = true
