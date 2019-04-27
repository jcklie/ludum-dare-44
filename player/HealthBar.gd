extends Node2D

onready var player = get_parent()

func _process(delta):
	update()

func _draw():
	draw_healthbar()

func draw_healthbar():
	var width = player.health / 100.0 * 32.0
	width = max(width, 2)
	var rect = Rect2(-16, -20, width, 4) 
	draw_rect(rect, Color.red, true)

