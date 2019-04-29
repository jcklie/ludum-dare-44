extends Node2D

# Key bindings
var key_left
var key_right
var key_up
var key_down

var key_rleft
var key_rright
var key_rup
var key_rdown

var key_shoot
var key_swap_weapon
var key_special

var player

var last_direction = Vector2(1, 0)

func init():
	key_left = "player_%s_left" % player.player_id
	key_right = "player_%s_right" % player.player_id
	key_up = "player_%s_up" % player.player_id
	key_down = "player_%s_down" % player.player_id
	
	key_rleft = "player_%s_rleft" % player.player_id
	key_rright = "player_%s_rright" % player.player_id
	key_rup = "player_%s_rup" % player.player_id
	key_rdown = "player_%s_rdown" % player.player_id
	
	key_shoot = "player_%s_shoot" % player.player_id
	key_swap_weapon = "player_%s_switch_weapon" % player.player_id
	key_special = "player_%s_special" % player.player_id

func process_input(delta):
	# Get the input of the player
		
	# Actions
	if Input.is_action_just_pressed(key_special):
		player.dash()
	
	if Input.is_action_just_released(key_swap_weapon):
		player.swap_weapon()
		
	if Input.is_action_pressed(key_shoot):
		player.shoot(delta)
	
	# Movement
	var movement = Vector2()
	if Input.is_action_pressed(key_left):
		movement.x -= 1
	if Input.is_action_pressed(key_right):
		movement.x += 1
	if Input.is_action_pressed(key_up):
		movement.y -= 1
	if Input.is_action_pressed(key_down):
		movement.y += 1
	
	movement = movement.normalized()
	var facingDirection = get_facing_direction()
	
	player.set_movement(movement, facingDirection)
	
func get_facing_direction():
	if player.player_id == 1:
		var x = (get_global_mouse_position() - global_position).normalized()
		return x
	else:
		var horizontal = Input.get_action_strength(key_rright) - Input.get_action_strength(key_rleft)
		var vertical = Input.get_action_strength(key_rdown) - Input.get_action_strength(key_rup)
		var result = Vector2(horizontal, vertical).normalized()
		
		if result.length() < 0.01:
			return last_direction
		else:
			last_direction = result
			return result