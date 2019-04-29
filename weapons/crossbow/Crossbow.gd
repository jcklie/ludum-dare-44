extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/crossbow/CrossbowProjectile.tscn")
	MaxFireDelay = 3
	Velocity = 800
	Damage = 80
	MaxBullets = 1
	HasLaser = true