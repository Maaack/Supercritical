extends BaseLevel


var tutorial_1_screen = preload("res://Scenes/Levels/Level0Tutorial1.tscn")
var tutorial_2_screen = preload("res://Scenes/Levels/Level0Tutorial2.tscn")
var tutorial_3_screen = preload("res://Scenes/Levels/Level0Tutorial3.tscn")
var tutorial_4_screen = preload("res://Scenes/Levels/Level0Tutorial4.tscn")
var tutorial_5_screen = preload("res://Scenes/Levels/Level0Tutorial5.tscn")

func _vines_grow(growth_max : int = 0) -> int:
	return ._vines_grow(1)

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	InGameMenuController.open_menu(tutorial_1_screen)

func _level_takes_turn(delay : float):
	._level_takes_turn(delay)
	yield(get_tree().create_timer(delay), "timeout")
	match turn_counter:
		3:
			InGameMenuController.open_menu(tutorial_2_screen)
		6: 
			InGameMenuController.open_menu(tutorial_3_screen)
		10: 
			InGameMenuController.open_menu(tutorial_4_screen)
		16: 
			InGameMenuController.open_menu(tutorial_5_screen)
