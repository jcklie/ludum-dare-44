extends Node

var alive = 0

func _ready():
	pass

func _process(delta):
	if alive == 0:
		spawn()

func player_died():
	alive -= 1

func spawn():
	var player = load("res://player/Player.tscn").instance()
	var ai_controller = load("res://player/AIController.gd").new()
	
	player.add_child(ai_controller)
	player.skin = "eur"
	player.controller = ai_controller
	player.speed = 100
	player.player_id = 7
	
	add_child(player)

	player.position = player.get_random_valid_position()
	ai_controller.move_to_new_goal()
	
	alive += 1
	player.connect("player_death", self, "player_died")
	