extends BaseLevel

var goal_1_screen = preload("res://Scenes/Levels/Level3Goal1.tscn")
var tutorial_2_screen = preload("res://Scenes/Levels/Level3Tutorial2.tscn")

var tutorial_screen_counter : int = 0

func _process(delta):
	tutorial_screen_counter += 1
	match tutorial_screen_counter:
		1:
			InGameMenuController.open_menu(tutorial_2_screen)
		_:
			set_process(false)


func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		InGameMenuController.open_menu(goal_1_screen)
