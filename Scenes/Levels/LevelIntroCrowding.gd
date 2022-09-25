extends BaseLevel

const MESSAGE_0 = "This vine is slowing the flower from reaching the deposit.\nTrim this vine to allow new growth at its neighbors."


func _process(delta):
	emit_signal("ingame_message_sent", MESSAGE_0, 8)
	set_process(false)
