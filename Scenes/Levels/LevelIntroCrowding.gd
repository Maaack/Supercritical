extends BaseLevel

const MESSAGE_0 = "This vine is slowing the flower from reaching the deposit.\nTrim this vine to allow new growth at its neighbors."
const MESSAGE_1 = "Long vines drain nutrients from your flower.\nRemember to clip vines that don't reach for deposits."

func _finish_tutorials():
	._finish_tutorials()
	emit_signal("ingame_message_sent", MESSAGE_0, 8)

func _complete_goal(goal : LevelGoals):
	._complete_goal(goal)
	if current_level_goal == 3:
		emit_signal("ingame_message_sent", MESSAGE_1, 8)
