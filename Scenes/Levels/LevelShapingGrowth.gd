extends BaseLevel

const MESSAGE_0 = "Trim the vines growing away from the deposits.\nLeave the vines growing toward them alone."

func _vines_grow(growth_max : int = 0) -> int:
	return ._vines_grow(max(1, growth_max))

func _finish_tutorials():
	._finish_tutorials()
	emit_signal("ingame_message_sent", MESSAGE_0, 8)
