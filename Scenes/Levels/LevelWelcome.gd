extends BaseLevel

const MESSAGE_0 = "This vine does nothing to feed the plant.\nCut the vine to make the plant stronger."
const MESSAGE_1 = "Good minion. You are not as useless as you seem.\nTry cutting another."
const MESSAGE_2 = "You will be given tasks by the great GARDENZILLA to keep her bonsai's healthy.\nFail her... at your own peril."
const MESSAGE_3 = "For now, keep the flower alive and do not starve it!."

var tutorial_screen_counter : int = 0
var event_turn_counter : int = 0
var finished_goals : bool = false

func _ready():
	emit_signal("goals_visibility_updated", false)

func _finish_tutorials():
	._finish_tutorials()
	emit_signal("ingame_message_sent", MESSAGE_0)
	$Control.show()

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 1:
		$Control/Label2.text = "Shift: Run"
		emit_signal("ingame_message_sent", MESSAGE_1)
	elif current_level_goal == 2:
		$Control/Label2.text = "Z: Wait"
		emit_signal("ingame_message_sent", MESSAGE_2)
		emit_signal("goals_visibility_updated", true)
		finished_goals = true

func _level_takes_turn(delay: float):
	._level_takes_turn(delay)
	if not finished_goals:
		return
	event_turn_counter += 1
	if event_turn_counter == 4:
		$Control/Label2.text = "P: Pause"
		emit_signal("ingame_message_sent", MESSAGE_3, 4)
	elif event_turn_counter == 8:
		$Control/Label2.hide()
