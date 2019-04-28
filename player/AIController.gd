extends Node2D

onready var nav = get_tree().get_root().get_node("Main/World/Navigation2D")

var navigation_done = true
var path

var goal

onready var player = get_parent()

func process_input(delta):
	if navigation_done:
		move_to_new_goal()
	
	if path.size() != 0:
		var d = global_position.distance_to(path[0])
		if d > 3:
			# move to next path node
			var direction = (path[0] - global_position).normalized() 
			player.set_movement(direction, direction)	
		else:
			# delete the current node (-> move to the next one)
			path.remove(0)
	else:
		navigation_done = true
		
	update()

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to_new_goal()
	
	# TODO: Set the collision shape correctly such that the
	# AI player can actually move freely..
	player.get_node("CollisionShape2D").shape.radius = 14

func move_to_new_goal():
	goal = player.get_random_valid_position()
	start_movement()

func start_movement():
	path = nav.get_simple_path(global_position, goal, false)
	navigation_done = false

func _draw():
	draw_circle(global_transform.inverse() * goal, 10, Color.green)
