extends Node2D

signal unit_moved(direction)

func _input(event):
	var direction : Vector2 = Vector2.ZERO
	if event is InputEventKey:
		if event.is_action_pressed("move_up"):
			direction = Vector2.UP
		elif event.is_action_pressed("move_down"):
			direction = Vector2.DOWN
		elif event.is_action_pressed("move_left"):
			direction = Vector2.LEFT
		elif event.is_action_pressed("move_right"):
			direction = Vector2.RIGHT
	if direction != Vector2.ZERO:
		emit_signal("unit_moved", direction)
		set_process_input(false)

