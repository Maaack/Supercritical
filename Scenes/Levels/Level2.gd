extends BaseLevel

var tutorial_2_screen = preload("res://Scenes/Levels/Level2Tutorial2.tscn")

var tutorial_screen_counter : int = 0

func _process(delta):
	tutorial_screen_counter += 1
	match tutorial_screen_counter:
		1:
			InGameMenuController.open_menu(tutorial_2_screen)
		_:
			set_process(false)
