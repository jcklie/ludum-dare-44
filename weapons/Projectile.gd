extends Node2D

var velocity : Vector2

func _process(delta):
	move(delta)

func move(delta):
	global_position += velocity * delta