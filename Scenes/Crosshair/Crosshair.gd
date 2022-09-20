extends Sprite

func show():
	.show()
	$AnimationPlayer.play("Flashing")

func hide():
	.hide()
	$AnimationPlayer.stop()
