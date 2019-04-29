extends KinematicBody2D

var death_animation = preload("res://player/HitParticles.tscn")
var player_controller = preload("res://player/Controller.gd")
var ai_controller =  preload("res://player/AIController.gd")

const DEFAULT_SPEED = 200
const DASH_SPEED = 800

var player_id
var speed = DEFAULT_SPEED
export(Global.Currency) var currency = Global.Currency.Euro
var is_ai = false

var controller
var ani = Global.IDLE

onready var weapons = $Weapons.get_children()
var weapon_idx = 0

var max_health: float = 100
onready var health: float = max_health
var dead: bool = false
var immobile: bool = false		# if true, player cannot be moved
var invincible: bool = false	# if true, player cannot be hurt

const DASH_MAX_COOLDOWN = 1.5
var dashing: bool = false
var dash_cooldown = 0

var velocity = Vector2()
var direction = Vector2()

var target = Vector2(0, 0)

# Signals

signal player_life_lost
signal player_death(player_id)
signal player_hurt(source)

var death_animation_duration = 1

var max_raycast_length = 2000
var show_target_raycast = true

func init():
	if not is_ai:
		controller = player_controller.new()
	else:
		controller = ai_controller.new()
		
	controller.player = self
	controller.init()
	add_child(controller)
	
	update_currency_visuals()
	
	$DashTimer.connect("timeout", self, "_on_DashTimer_timeout")
	
	# register sounds
	connect("player_hurt", AudioEngine, "_on_player_hurt")
	connect("player_death", AudioEngine, "_on_player_death")
	
	$IDText.text = str(player_id)

func update_currency(new_currency):
	# change health according to current value
	var scaling_factor = Global.get_currency_scaling(currency) / Global.get_currency_scaling(new_currency)
	health = min(max_health, max(health, 10) * scaling_factor)
	# set the new currency
	currency = new_currency
	update_currency_visuals()

func update_currency_visuals():
	# select the current sprite frames
	$AnimatedSprite.frames = Global.sprite_frames[currency]

func _process(delta):
	if dead:
		# make the player smaller (assumes scale.x = scale.y)
		var new_scale_x = max(0.0, scale.x - delta / death_animation_duration)
		scale.x = new_scale_x
		scale.y = new_scale_x
		return
	
	if not dashing:
		dash_cooldown -= delta
	
	if controller != null and !dead:
		# process inputs
		controller.process_input(delta)
	
	var hit = cast_shoot_ray_to(global_position + direction * max_raycast_length)
	if hit.size() != 0:
		target = hit["position"]
	
	select_animation()
	update()

func cast_shoot_ray_to(global_pos):
	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_ray(global_position, global_pos, [], 4 + 8)

func get_random_valid_position():
	var size = get_viewport().size
	var freePosition
	var collision = true
	
	while collision:
		# just generate some random position and check whether we can actually be there
		freePosition = Vector2(randi() % int(size.x), randi() % int(size.y))
		collision = test_move(Transform2D(0, freePosition), Vector2(0.1, 0.1))
	
	return freePosition
	
func get_random_valid_position_nearby(pos: Vector2, radius, max_tries = 100):
	var size = get_viewport().size
	var freePosition
	var collision = true
	
	var min_x = max(0, pos.x - radius)
	var max_x = min(size.x, pos.x + radius)
	var min_y = max(0, pos.y - radius)
	var max_y = min(size.y, pos.y + radius)
	
	var tries = 0
	
	while collision:
		# just generate some random position and check whether we can actually be there
		freePosition = Vector2(min_x + randi() % int(max_x - min_x), min_y + randi() % int(max_y - min_y))
		collision = test_move(Transform2D(0, freePosition), Vector2(0.1, 0.1))
		
		tries += 1
		if tries >= max_tries:
			return null
	
	return freePosition

func reset_health():
	health = max_health

func shoot(delta):
	if dead:
		return
	
	var weapon = get_weapon()
	if weapon:
		weapon.shoot(self, delta)

func select_animation():
	var rotation_degs = rad2deg(get_angle_to(position + direction)) + 180
	var ani_ang_step =  int(round(Global.SKIN_ANGULAR_STEPS/2 + Global.SKIN_ANGULAR_STEPS * (rotation_degs / 360.0))) % Global.SKIN_ANGULAR_STEPS
	var ani_name = ani + "_" + str(ani_ang_step)
	$AnimatedSprite.animation = ani_name
	
func _physics_process(delta):
	if immobile or dead:
		return
	
	if not dashing:
		move_and_slide(velocity)
	else:
		move_and_collide(velocity * delta)
		
func damage(damage):
	if invincible or dashing or dead:
		return
	
	$HitParticles.emitting = true
	emit_signal("player_hurt", self)
	
	health -= damage / get_strength()
	# print("Lost health: " + str(damage / get_strength()))
	if health < 0:
		emit_signal("player_life_lost")
		destroy()
		
func destroy():
	if dead:
		return
		
	emit_signal("player_death", player_id)
	play_death_animation()
	
	dead = true
	$HealthBar.queue_free()
	update()

func swap_weapon():
	weapon_idx = (weapon_idx + 1) % weapons.size()
	
func swap_weapon_random():
	weapon_idx = randi() % weapons.size()

func set_movement(movementDirection, facingDirection):
	self.velocity = movementDirection * speed
	self.direction = facingDirection

func dash():
	# Dont dash if the player is not moving or currently dashing / on cooldown
	if dashing or dash_cooldown > 0 or velocity == Vector2():
		return
		
	speed = DASH_SPEED
	dashing = true
	$DashTimer.start()
	$DashParticles.emitting = true
	
func _on_DashTimer_timeout():
	speed = DEFAULT_SPEED
	dashing = false
	dash_cooldown = DASH_MAX_COOLDOWN
	$DashParticles.emitting = false
		
func get_weapon():
	var weapon = weapons[weapon_idx]
	weapon.player = self
	return weapon

var dealth_anim

func play_death_animation():
	if dead:
		return
	
	dealth_anim = death_animation.instance()
	dealth_anim.emitting = true
	dealth_anim.get_process_material().scale = .5
	dealth_anim.set_one_shot(false)
	dealth_anim.get_process_material().initial_velocity = 400

	var timer = Timer.new()
	timer.set_wait_time(death_animation_duration)
	timer.connect("timeout", self, "disable_player")
	
	add_child(dealth_anim)
	add_child(timer)
	
	timer.start()

var already_disabled = false

func disable_player():
	if already_disabled:
		return
		
	already_disabled = true
	dealth_anim.emitting = false
	get_node("CollisionShape2D").queue_free()
	
func kill_self():
	queue_free()
	
func get_strength():
	"""
	Player strength is a factor for player damage / defense (use multiplication / division).
	"""
	return Global.get_currency_scaling(currency)

func _draw():
	show_target_raycast = get_weapon().HasLaser
	if !dead and show_target_raycast:
		draw_circle(global_transform.inverse() * target, 5, Global.colors[currency])
		draw_line(global_transform.inverse() * global_position, global_transform.inverse() * target, Global.colors[currency], 1, true)
