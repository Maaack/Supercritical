extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_select") or event.is_action_pressed("interact"):
		InGameMenuController.close_menu()
		get_tree().set_input_as_handled()

func _on_ResumeButton_pressed():
	InGameMenuController.close_menu()
