extends BaseLevel

var tutorial_screen = preload("res://Scenes/Levels/Level3Tutorial.tscn")
var goal_1_screen = preload("res://Scenes/Levels/Level3Goal1.tscn")

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	InGameMenuController.open_menu(tutorial_screen)

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		InGameMenuController.open_menu(goal_1_screen)
