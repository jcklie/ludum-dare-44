extends Node2D

onready var nav = get_node("../Navigation2D")

var done = true
var path

var goal

# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_goal_position()
	start_movement()

func start_movement():
	path = nav.get_simple_path(global_position, goal, true)
	done = false

func set_new_goal_position():
	var space = get_world_2d().direct_space_state
	var size = get_viewport().size
	var space_state = get_world_2d().direct_space_state
	
	var newPosition
	
	var collision = true
	while collision:
		newPosition = Vector2(randi() % int(size.x), randi() % int(size.y))
		collision = space_state.intersect_point(newPosition).size() != 0
		
	# spawn the object at spawnPosition
	goal = newPosition
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if done:
		set_new_goal_position()
		start_movement()
	
	if path.size() != 0:
		var d = global_position.distance_to(path[0])
		if d > 2:
			# move to next path node
			position += ((path[0] - global_position).normalized() * 100 * delta)
		else:
			path.remove(0)
	else:
		done = true
			
	update()
	
func _draw():
	draw_circle(global_transform.inverse() * position, 10, Color.black)
	draw_circle(global_transform.inverse() * goal, 10, Color.green)
