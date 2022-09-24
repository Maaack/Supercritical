extends BaseLevel

const MESSAGE_0 = "Stop the flower from getting more than 20 nutrients.\nDon't trim too many vines and starve it, either."

var tutorial_2_screen = preload("res://Scenes/Levels/Level2Tutorial2.tscn")

var tutorial_screen_counter : int = 0

func _process(delta):
	tutorial_screen_counter += 1
	match tutorial_screen_counter:
		1:
			InGameMenuController.open_menu(tutorial_2_screen)
		_:
			emit_signal("ingame_message_sent", MESSAGE_0, 8)
			set_process(false)
