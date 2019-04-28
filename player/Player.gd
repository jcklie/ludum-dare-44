extends KinematicBody2D

const IDLE = "idle"
const SKIN_ANGULAR_STEPS = 16

export(int) var player_id
export (int) var speed = 200
export(String) var skin = "eur"
var ani = IDLE

onready var weapons = $Weapons.get_children()
var weapon_idx = 0

var velocity = Vector2()
var direction = Vector2()

var health: int = 100

const DASH_MAX_COOLDOWN = 1.5
var dashing : bool = false
var dash_cooldown = 0

# Key bindings
var key_left
var key_right
var key_up
var key_down
var key_shoot
var key_swap_weapon
var key_special

# Signals

signal player_life_lost

func _ready():
	# load all animation sprite frames
	var path_template = "res://player/skin/{skin}/{ani}/{step}.png"
	var sf = SpriteFrames.new()
	for ani in [IDLE]:
		for ang_step in range(SKIN_ANGULAR_STEPS):
			var ani_ang_step = ani + "_" + str(ang_step)
			sf.add_animation(ani_ang_step)
			# we only one frame per animation right now
			var path = path_template.format({"skin": skin, "ani": ani, "step": ang_step})
			sf.add_frame(ani_ang_step, load(path))
	
	$AnimatedSprite.frames = sf
	
	key_left = "player_%s_left" % player_id
	key_right = "player_%s_right" % player_id
	key_up = "player_%s_up" % player_id
	key_down = "player_%s_down" % player_id
	key_shoot = "player_%s_shoot" % player_id
	key_swap_weapon = "player_%s_switch_weapon" % player_id
	key_special = "player_%s_special" % player_id
		
	set_collision_layer_bit(0, false)
	set_collision_layer_bit(player_id, true)
	
	collision_mask = 0xFF
	
	$DashTimer.connect("timeout",self,"_on_DashTimer_timeout") 
		
func _process(delta):
	get_input()
	select_animation()
	
	if not dashing:
		dash_cooldown -= delta
	
	update()

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
		
	if Input.is_action_just_pressed(key_special) && not dashing and dash_cooldown < 0:
		dash()
	
	if Input.is_action_just_released(key_swap_weapon):
		weapon_idx = (weapon_idx + 1) % weapons.size()
		
	velocity = velocity.normalized() * speed
	direction = (get_pointer_position() - global_position).normalized()
	
func select_animation():
	var rotation_degs = rad2deg(get_angle_to(get_global_mouse_position())) + 180
	var ani_ang_step =  int(round(SKIN_ANGULAR_STEPS/2 + SKIN_ANGULAR_STEPS * (rotation_degs / 360.0))) % SKIN_ANGULAR_STEPS
	var ani_name = ani + "_" + str(ani_ang_step)
	$AnimatedSprite.animation = ani_name

func get_pointer_position():
	return get_global_mouse_position()
	
func _physics_process(delta):
	var weapon = get_weapon()
	if weapon && Input.is_action_pressed(key_shoot):
		weapon.shoot(delta)
	
	if not dashing:
		move_and_slide(velocity)
	else:
		move_and_collide(velocity * delta)
		
func damage(damage):
	if dashing:
		return
	
	$HitParticles.emitting = true

	health -= damage
	if health < 0:
		emit_signal("player_life_lost", player_id)
		queue_free()
		
func dash():
	# Dont dash if the player is not moving
	if velocity == Vector2():
		return
		
	speed = 800
	dashing = true
	$DashTimer.start()
	$DashParticles.emitting = true
	
func _on_DashTimer_timeout():
	speed = 200
	dashing = false
	dash_cooldown = DASH_MAX_COOLDOWN
	$DashParticles.emitting = false
		
func get_weapon():
	var weapon = weapons[weapon_idx]
	weapon.player = self
	return weapon