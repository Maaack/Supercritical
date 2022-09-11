extends KinematicBody2D

var velocity : Vector2
var speed : float = 200

func _physics_process(delta):
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	
	move_and_slide(velocity)

