extends BaseLevel

var tutorial_1_1_screen = preload("res://Scenes/Levels/Level0Tutorial1-1.tscn")
var tutorial_1_2_screen = preload("res://Scenes/Levels/Level0Tutorial1-2.tscn")
var tutorial_1_3_screen = preload("res://Scenes/Levels/Level0Tutorial1-3.tscn")
var tutorial_2_screen = preload("res://Scenes/Levels/Level0Tutorial2.tscn")
var tutorial_3_screen = preload("res://Scenes/Levels/Level0Tutorial3.tscn")
var tutorial_4_screen = preload("res://Scenes/Levels/Level0Tutorial4.tscn")
var tutorial_5_screen = preload("res://Scenes/Levels/Level0Tutorial5.tscn")
var tutorial_screen_counter : int = 0

func _vines_grow(growth_max : int = 0) -> int:
	return ._vines_grow(max(1, growth_max))

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
		6:
			InGameMenuController.open_menu(tutorial_4_screen)
		_:
			$Control.show()
			set_process(false)

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		$Control/Label2.text = "Shift: Run"
		$Control/InGameMessageBox/MarginContainer/Label.text = "Good minion. You are not as useless as you seem.\nTry cutting another."
	elif current_level_goal == 2:
		$Control/Label2.text = "Z: Wait"
		$Control/InGameMessageBox/MarginContainer/Label.text = "You will be given tasks by the great GARDENZILLA to keep her bonsai's healthy.\nFail her... at your own peril."
		emit_signal("goals_visibility_updated", true)
	elif current_level_goal == 3:
		$Control/Label2.hide()
		$Control/InGameMessageBox/MarginContainer/Label.text = "For now, keep the flower alive and do not starve it!."
