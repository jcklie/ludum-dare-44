extends KinematicBody2D

export (int) var speed = 200
export(Texture) var my_texture

export(int) var player_id

var velocity = Vector2()

# Key bindings
var key_left
var key_right
var key_up
var key_down

func _ready():
	get_node("Sprite").texture = my_texture
	key_left = "player_%s_left" % player_id
	key_right = "player_%s_right" % player_id
	key_up = "player_%s_up" % player_id
	key_down = "player_%s_down" % player_id

func _process(delta):
	get_input()
	
	look_at(get_global_mouse_position())
	
func get_input():
	velocity = Vector2()
	if Input.is_action_pressed(key_left):
		velocity.x -= 1
	if Input.is_action_pressed(key_right):
		velocity.x += 1
	if Input.is_action_pressed(key_up):
		velocity.y -= 1
	if Input.is_action_pressed(key_down):
		velocity.y += 1
		
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	move_and_slide(velocity)