extends BaseLevel

const MESSAGE_0 = "This vine does nothing to feed the plant.\nCut the vine to make the plant stronger."
const MESSAGE_1 = "Good minion. You are not as useless as you seem.\nTry cutting another."
const MESSAGE_2 = "You will be given tasks by the great GARDENZILLA to keep her bonsai's healthy.\nFail her... at your own peril."
const MESSAGE_3 = "For now, keep the flower alive and do not starve it!."

var tutorial_1_1_screen = preload("res://Scenes/Levels/Level0Tutorial1-1.tscn")
var tutorial_1_2_screen = preload("res://Scenes/Levels/Level0Tutorial1-2.tscn")
var tutorial_1_3_screen = preload("res://Scenes/Levels/Level0Tutorial1-3.tscn")
var tutorial_2_screen = preload("res://Scenes/Levels/Level0Tutorial2.tscn")
var tutorial_3_screen = preload("res://Scenes/Levels/Level0Tutorial3.tscn")

var tutorial_screen_counter : int = 0

func _ready():
	emit_signal("goals_visibility_updated", false)

func _process(delta):
	tutorial_screen_counter += 1
	match tutorial_screen_counter:
		1:
			InGameMenuController.open_menu(tutorial_1_1_screen)
		2:
			InGameMenuController.open_menu(tutorial_1_2_screen)
		3:
			InGameMenuController.open_menu(tutorial_1_3_screen)
		4:
			InGameMenuController.open_menu(tutorial_2_screen)
		5:
			InGameMenuController.open_menu(tutorial_3_screen)
		_:
			emit_signal("ingame_message_sent", MESSAGE_0)
			$Control.show()
			set_process(false)

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		$Control/Label2.text = "Shift: Run"
		emit_signal("ingame_message_sent", MESSAGE_1)
	elif current_level_goal == 2:
		$Control/Label2.text = "Z: Wait"
		emit_signal("ingame_message_sent", MESSAGE_2)
		emit_signal("goals_visibility_updated", true)
	elif current_level_goal == 3:
		$Control/Label2.hide()
		emit_signal("ingame_message_sent", MESSAGE_3)
