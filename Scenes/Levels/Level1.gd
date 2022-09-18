extends BaseLevel

func _vines_grow(growth_max : int = 0) -> int:
	return ._vines_grow(max(1, growth_max))
