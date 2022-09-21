tool
extends Node2D

export(Color) var positive_color : Color
export(Color) var negative_color : Color
export(int) var amount : int = 0 setget set_amount

func set_amount(value : int = 0) -> void:
	amount = value
	var node = get_node_or_null("Label")
	if node == null:
		return
	if amount > 0:
		$Label.set("custom_colors/font_color", positive_color)
		$Panel.modulate = positive_color
	elif amount < 0:
		$Label.set("custom_colors/font_color", negative_color)
		$Panel.modulate = negative_color
	else:
		$Label.set("custom_colors/font_color", Color.white)
	$Label.text = "%d" % amount


func _ready():
	self.amount = amount
