extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/minigun/MinigunProjectile.tscn")
	MaxFireDelay = .1
	Velocity = 800
	Damage = 3
	MaxBullets = 5
	MaxTimeToLive = .3