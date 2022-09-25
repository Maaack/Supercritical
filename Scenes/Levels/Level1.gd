extends BaseLevel

const MESSAGE_0 = "This vine is slowing the flower from reaching the deposit.\nTrim this vine to allow new growth at its neighbors."

var tutorial_2_screen = preload("res://Scenes/Levels/LevelIntroCrowdingTutorial2.tscn")

var tutorial_screen_counter : int = 0

func _process(delta):
	tutorial_screen_counter += 1
	match tutorial_screen_counter:
		1:
			InGameMenuController.open_menu(tutorial_2_screen)
		_:
			emit_signal("ingame_message_sent", MESSAGE_0, 8)
			set_process(false)
			
