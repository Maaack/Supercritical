extends ParallaxBackground

var speed = 20.0

func _process(delta):
	scroll_offset.x -= speed * delta
