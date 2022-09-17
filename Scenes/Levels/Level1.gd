extends BaseLevel

var tutorial_screen = preload("res://Scenes/Levels/Level1Tutorial.tscn")

func _vines_grow(growth_max : int = 0) -> int:
	return ._vines_grow(max(1, growth_max))

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	InGameMenuController.open_menu(tutorial_screen)
