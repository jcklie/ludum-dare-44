extends Area2D

var velocity : Vector2

func _ready():
	set_collision_mask(0xFF)

func _process(delta):
	move(delta)

func move(delta):
	global_position += velocity * delta