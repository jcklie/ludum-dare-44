extends KinematicBody2D

const IDLE = "idle"
const SKIN_ANGULAR_STEPS = 16

var death_animation = preload("res://player/HitParticles.tscn")

export(int) var player_id
export (int) var speed = 200
export(Global.Currency) var currency = Global.Currency.Euro
export(NodePath) var controllerPath
var controller
var ani = IDLE

onready var weapons = $Weapons.get_children()
var weapon_idx = 0

var max_health: int = 100
onready var health = max_health
var dead : bool = false

const DASH_MAX_COOLDOWN = 1.5
var dashing : bool = false
var dash_cooldown = 0

var velocity = Vector2()
var direction = Vector2()

# Signals

signal player_life_lost
signal player_death
signal player_hurt(source)

var death_animation_duration = 1

var max_raycast_length = 2000
var show_target_raycast = true

func _ready():
	# load all animation sprite frames
	var path_template = "res://player/skin/{skin}/{ani}/{step}.png"
	var sf = SpriteFrames.new()
	for ani in [IDLE]:
		for ang_step in range(SKIN_ANGULAR_STEPS):
			var ani_ang_step = ani + "_" + str(ang_step)
			sf.add_animation(ani_ang_step)
			# we only one frame per animation right now
			var path = path_template.format({"skin": Global.skins[currency], "ani": ani, "step": ang_step})
			sf.add_frame(ani_ang_step, load(path))
	
	$AnimatedSprite.frames = sf
		
	set_collision_layer_bit(0, false)
	set_collision_layer_bit(player_id, true)
	
	collision_mask = 0xFF
	
	$DashTimer.connect("timeout", self, "_on_DashTimer_timeout")
	
	if controllerPath != "":
		controller = get_node(controllerPath)
		
	# register sounds
	connect("player_hurt", AudioEngine, "_on_player_hurt")
	connect("player_death", AudioEngine, "_on_player_death")

var target = Vector2(0, 0)

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

func reset_health():
	health = max_health

func shoot(delta):
	if dead:
		return
	
	var weapon = get_weapon()
	if weapon:
		weapon.shoot(delta)

func select_animation():
	var rotation_degs = rad2deg(get_angle_to(position + direction)) + 180
	var ani_ang_step =  int(round(SKIN_ANGULAR_STEPS/2 + SKIN_ANGULAR_STEPS * (rotation_degs / 360.0))) % SKIN_ANGULAR_STEPS
	var ani_name = ani + "_" + str(ani_ang_step)
	$AnimatedSprite.animation = ani_name
	
func _physics_process(delta):
	if dead:
		return
	
	if not dashing:
		move_and_slide(velocity)
	else:
		move_and_collide(velocity * delta)
		
func damage(damage):
	if dashing or dead:
		return
	
	$HitParticles.emitting = true
	emit_signal("player_hurt", self)
	
	health -= damage
	if health < 0:
		emit_signal("player_life_lost")
		destroy()
		
func destroy():
	emit_signal("player_death")
	dead = true
	$HealthBar.queue_free()
	play_death_animation()
	update()

func swap_weapon():
	weapon_idx = (weapon_idx + 1) % weapons.size()

func set_movement(movementDirection, facingDirection):
	self.velocity = movementDirection * speed
	self.direction = facingDirection

func dash():
	# Dont dash if the player is not moving or currently dashing / on cooldown
	if dashing or dash_cooldown > 0 or velocity == Vector2():
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

func play_death_animation():
	var anim = death_animation.instance()
	anim.emitting = true
	anim.get_process_material().scale = .5
	anim.set_one_shot(false)
	anim.get_process_material().initial_velocity = 400

	var timer = Timer.new()
	timer.set_wait_time(death_animation_duration)
	timer.connect("timeout", self, "queue_free")
	
	add_child(anim)
	add_child(timer)
	
	timer.start()	
	
func kill_self():
	queue_free()
	
func _draw():
	if !dead and show_target_raycast:
		draw_circle(global_transform.inverse() * target, 5, Global.colors[currency])
		draw_line(global_transform.inverse() * global_position, global_transform.inverse() * target, Global.colors[currency], 1)
