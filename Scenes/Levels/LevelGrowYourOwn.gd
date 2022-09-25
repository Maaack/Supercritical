extends BaseLevel

var goal_1_screen = preload("res://Scenes/Tutorials/Level5Goal1.tscn")
var goal_2_screen = preload("res://Scenes/Tutorials/Level4Goal1.tscn")

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		InGameMenuController.open_menu(goal_1_screen)
	if current_level_goal == 2:
		InGameMenuController.open_menu(goal_2_screen)
