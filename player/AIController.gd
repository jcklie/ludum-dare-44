extends Node2D

enum State {RandomMovement, FollowPlayer}

var state = State.RandomMovement

var nav
var navigation_done = true
var path

var goal

# The timespan which is used to check whether the player did not move
var newgoal_check_timespan = 0.1
# The distance threshold below which movement is considered as "no movement" 
var newgoal_distance_threshold = 5
var newgoal_last_position
var newgoal_delta_sum
var newgoal_tracked_distance

var player

var target_player

var target_player_recalculate_path_threshold = 50
var target_player_switch_to_random_movement_threshold = 150
var target_player_switch_to_new_player_focus_threshold = 80

var current_facing_direction = Vector2(0, 0)
var facing_turn_speed = 5
var facing_distance_fire_threshold = 0.2


# Called when the node enters the scene tree for the first time.
func init():
	nav = GameManager.current_level.get_node("Navigation2D")
	
	# Update when the player died (to reset _draw)
	player.connect("player_death", self, "update")

func get_nearest_player():
	var smallestDistance = 100000
	var nearest_player = null
	
	for player_id in GameManager.players:
		var p = GameManager.players[player_id]
		
		if p != player and !p.dead and global_position.distance_to(p.global_position) <= smallestDistance:
			nearest_player = p
			smallestDistance = global_position.distance_to(p.global_position)
	
	return nearest_player

func process_input(delta):
	
	# Check whether we moved less than "newgoal_distance_threshold" in the last
	# "newgoal_check_timespan" seconds. When this is the case, move to a new goal.
	
	if newgoal_last_position == null:
		newgoal_last_position = global_position
		newgoal_delta_sum = 0
		newgoal_tracked_distance = 0
	
	if newgoal_delta_sum >= newgoal_check_timespan:
		if newgoal_tracked_distance < newgoal_distance_threshold:
			# fallback to random movement state
			state = State.RandomMovement
			move_to_random_goal()
		
		newgoal_delta_sum = 0
		newgoal_tracked_distance = 0
		
	newgoal_delta_sum += delta
	newgoal_tracked_distance += newgoal_last_position.distance_to(global_position)
	newgoal_last_position = global_position
	
	# state update logic
	
	if state == State.RandomMovement:
		if navigation_done:
			target_player = get_nearest_player()
			
			if target_player != null:
				state = State.FollowPlayer
			else:
				move_to_random_goal()
		else:
			# Move to the rearest player when we are very close to some player
			var nearest_player = get_nearest_player()
			# TODO: Replace with something better
			if randf() <= 0.001 and nearest_player.global_position.distance_to(global_position) <= target_player_switch_to_new_player_focus_threshold:
				target_player = nearest_player
				state = State.FollowPlayer
				move_to_random_goal()
	
	if state == State.FollowPlayer:
		# When we are too close to the player, move randomly again
		if target_player != null:
			var target_pos = target_player.global_position
			# update the path when the player moved too much
			if goal != null and target_pos.distance_to(goal) >= target_player_recalculate_path_threshold:
				move_to_player_target()
			
			if target_pos.distance_to(global_position) <= target_player_switch_to_random_movement_threshold:
				state = State.RandomMovement
				move_to_random_goal()
		
		if navigation_done:
			move_to_player_target()
	
	# Follow the path to the goal
	
	var movementDirection = Vector2(0, 0)
	
	if path != null and path.size() != 0:
		var d = global_position.distance_to(path[0])
		if d > 3:
			# move to next path node
			movementDirection = (path[0] - global_position).normalized()	
		else:
			# delete the current node (-> move to the next one)
			path.remove(0)
			
			if path.size() == 0:
				navigation_done = true
	else:
		navigation_done = true
			
	# update the facing direction
	
	var facingDirection
	if target_player != null:
		var hit = player.cast_shoot_ray_to(target_player.global_position)
		if hit.size() != 0 and hit.collider == target_player:
			# focus the target player when visible
			facingDirection = (target_player.global_position - global_position).normalized()
			
			# fire the weapon when we are almost facing the same direction
			if facingDirection.distance_to(current_facing_direction) <= facing_distance_fire_threshold:
				player.shoot(delta)
			
		else:
			if state == State.RandomMovement:
				# look in the movement direction
				facingDirection = movementDirection
				
			if state == State.FollowPlayer:
				# still look in the direction of the player, even when the ray did not hit
				facingDirection = (target_player.global_position - global_position).normalized()
				
	else:
		# Target player is null
		facingDirection = movementDirection
		
	# interpolate the current facing direction for smooth transitions
	current_facing_direction = current_facing_direction.linear_interpolate(facingDirection, delta * facing_turn_speed)
	
	player.set_movement(movementDirection, current_facing_direction)
	
	update()

func move_to_random_goal():
	if target_player != null:
		# try to move somewhere nearby the player
		goal = player.get_random_valid_position_nearby(target_player.global_position, 300)
	else:
		# we have no target, move completely random
		goal = player.get_random_valid_position()
		
	start_movement()
	
func move_to_player_target():
	if target_player != null:
		goal = target_player.global_position
		start_movement()

func start_movement():
	path = nav.get_simple_path(global_position, goal, false)
	navigation_done = false

func _draw():
	if !player.dead and goal != null:
		draw_circle(global_transform.inverse() * goal, 10, Global.colors[player.currency])
