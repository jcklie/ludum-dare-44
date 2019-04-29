extends Node2D

var nav

var navigation_done = true
var path

var goal

# The timespan which is used to check whether the player did not move
var newgoal_check_timespan = 0.5
# The distance threshold below which movement is considered as "no movement" 
var newgoal_distance_threshold = 5
var newgoal_last_position
var newgoal_delta_sum
var newgoal_tracked_distance

var player

func process_input(delta):
	if navigation_done:
		move_to_new_goal()
	
	# Check whether we moved less than "newgoal_distance_threshold" in the last
	# "newgoal_check_timespan" seconds. When this is the case, move to a new goal.
	
	if newgoal_last_position == null:
		newgoal_last_position = global_position
		newgoal_delta_sum = 0
		newgoal_tracked_distance = 0
	
	if newgoal_delta_sum >= newgoal_check_timespan:
		if newgoal_tracked_distance < newgoal_distance_threshold:
			move_to_new_goal()
		
		newgoal_delta_sum = 0
		newgoal_tracked_distance = 0
		
	newgoal_delta_sum += delta
	newgoal_tracked_distance += newgoal_last_position.distance_to(global_position)
	newgoal_last_position = global_position
	
	# Follow the path to the goal
	
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
func init():
	print("Hello AI", player.player_id)
	print(GameManager.current_level.get_children())
	
	nav = GameManager.current_level.get_node("Navigation2D")
	
	move_to_new_goal()
	# Update when the player died (to reset _draw)
	player.connect("player_death", self, "update")

func move_to_new_goal():
	goal = player.get_random_valid_position()
	start_movement()

func start_movement():
	path = nav.get_simple_path(global_position, goal, false)
	navigation_done = false

func _draw():
	if !player.dead:
		draw_circle(global_transform.inverse() * goal, 10, Color.green)
