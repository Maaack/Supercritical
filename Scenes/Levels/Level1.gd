extends BaseLevel


func _vines_grow(grow_count : int) -> int:
	return ._vines_grow(min(grow_count, 1))
