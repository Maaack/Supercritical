extends BaseLevel

const MESSAGE_0 = "Stop the flower from getting more than 20 nutrients.\nDon't trim too many vines and starve it, either."

func _finish_tutorials():
	._finish_tutorials()
	emit_signal("ingame_message_sent", MESSAGE_0, 8)
