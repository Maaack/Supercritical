extends BaseLevel

var goal_1_screen = preload("res://Scenes/Levels/Level3Goal1.tscn")

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		InGameMenuController.open_menu(goal_1_screen)
