extends BaseLevel

var tutorial_screen = preload("res://Scenes/Levels/Level1Tutorial.tscn")

func _vines_grow(grow_count : int) -> int:
	return ._vines_grow(min(grow_count, 1))

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	InGameMenuController.open_menu(tutorial_screen)
