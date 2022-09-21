tool
extends Node2D

export(Color) var positive_font_color : Color
export(Color) var negative_font_color : Color
export(int) var amount : int = 0 setget set_amount

func set_amount(value : int = 0) -> void:
	amount = value
	if amount > 0:
		$Label.set("custom_colors/font_color", positive_font_color)
	elif amount < 0:
		$Label.set("custom_colors/font_color", negative_font_color)
	else:
		$Label.set("custom_colors/font_color", Color.white)
	$Label.text = "%d" % amount

func _randomize_position():
	var x = randi() % 5 - 2
	var y = randi() % 5 - 2
	position += Vector2(x, y)
	
func play():
	_randomize_position()
	$AnimationPlayer.play("GoUpAndFadeOut")
