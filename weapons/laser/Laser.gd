extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/laser/LaserProjectile.tscn")
	MaxFireDelay = .5
	Velocity = 800
	Damage = 5
	MaxBullets = 2