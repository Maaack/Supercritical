extends BaseLevel

var tutorial_screen = preload("res://Scenes/Levels/Level3Tutorial.tscn")

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	InGameMenuController.open_menu(tutorial_screen)
