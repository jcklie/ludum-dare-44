extends KinematicBody2D

export(int) var player_id
export (int) var speed = 200
export(Texture) var my_texture

onready var weapon = $Weapon

var velocity = Vector2()
var direction = Vector2()

# Key bindings
var key_left
var key_right
var key_up
var key_down
var key_shoot

func _ready():
	get_node("Sprite").texture = my_texture
	key_left = "player_%s_left" % player_id
	key_right = "player_%s_right" % player_id
	key_up = "player_%s_up" % player_id
	key_down = "player_%s_down" % player_id
	key_shoot = "player_%s_shoot" % player_id

func _process(delta):
	get_input()
	
	look_at(get_pointer_position())

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
	direction = (get_pointer_position() - global_position).normalized()
	
func get_pointer_position():
	return get_global_mouse_position()
	
func _physics_process(delta):
	if weapon && Input.is_action_pressed(key_shoot):
		weapon.shoot(delta)
	
	move_and_slide(velocity)
	
	